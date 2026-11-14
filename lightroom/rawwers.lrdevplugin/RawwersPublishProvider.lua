--[[ "RAWWERS Portfolio": a Publish Service that puts photos in the
photographer's portfolio (docs/LIGHTROOM_PORTFOLIO.md).

Set up once in Lightroom's Publish Services panel: connect with a pairing
code (the same connection as Export To: RAWWERS, kept in the keychain per
server). Each published collection is one niche of the portfolio, chosen in
the collection's settings; the default collection is the main niche. Publish
sends new and edited photos; photos taken out of a collection are removed
from the portfolio when publishing.

SDK hooks used (SDK 15.3 reference, "SDK - Publish service provider"; all
present since SDK 3.0): supportsIncrementalPublish, getCollectionBehaviorInfo,
viewForCollectionSettings (info.collectionSettings, LR_canSaveCollection),
processRenderedPhotos with exportContext.publishedCollection
(:getCollectionInfoSummary), rendition.publishedPhotoId,
rendition:recordPublishedPhotoId, deletePhotosFromPublishedCollection,
deletePublishedCollection; and the export hooks of RawwersServiceProvider.lua.
The logic is in RawwersPortfolio.lua, tested without Lightroom.
]]

local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrErrors = import 'LrErrors'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'
local LrTasks = import 'LrTasks'
local LrView = import 'LrView'

local Checks = require 'RawwersChecks'
local Config = require 'RawwersConfig'
local Lightroom = require 'RawwersLightroom'
local Pipeline = require 'RawwersPipeline'
local Portfolio = require 'RawwersPortfolio'

local bind = LrView.bind

local provider = {}

provider.supportsIncrementalPublish = 'only'
provider.allowFileFormats = { 'JPEG' }
provider.allowColorSpaces = { 'sRGB' }
provider.hideSections = { 'exportLocation' }
provider.hidePrintResolution = true
provider.canExportVideo = false

provider.titleForPublishedCollection = 'Niche'
provider.titleForPublishedCollection_standalone = 'Niche'
provider.titleForGoToPublishedCollection = 'disable'
provider.titleForGoToPublishedPhoto = 'disable'

provider.exportPresetFields = {
	{ key = 'rawwersServer', default = '' },
	{ key = 'rawwersDeviceName', default = 'Lightroom Classic' },
	{ key = 'rawwersDefaultsApplied', default = false },
}

-- The connection (the publish service's settings) -------------------------------------

local function check( p )
	local base = Lightroom.baseUrl( p )
	local token = Lightroom.storedToken( base )
	if not token then
		p.rawwersConnected, p.rawwersConnection = false, 'Not connected.'
		return
	end
	local answer = Lightroom.api( base, { token = token } ):portfolio()
	if answer.ok then
		local names = {}
		for _, n in ipairs( answer.data.niches or {} ) do names[ #names + 1 ] = n.name end
		p.rawwersConnected = true
		p.rawwersConnection = 'Connected. Your niches: ' .. ( #names > 0 and table.concat( names, ', ' ) or 'none yet' )
	elseif answer.outcome == 'reauth' then
		Lightroom.storeToken( base, '' )
		p.rawwersConnected, p.rawwersConnection = false, answer.message
	else
		p.rawwersConnected, p.rawwersConnection = false, answer.message
	end
end

local function connect( p )
	local base = Lightroom.baseUrl( p )
	p.rawwersConnection = 'Connecting...'
	local answer = Lightroom.api( base ):pair( p.rawwersPairingCode or '', p.rawwersDeviceName or 'Lightroom Classic' )
	if not answer.ok then
		p.rawwersConnected, p.rawwersConnection = false, answer.message
		return
	end
	Lightroom.storeToken( base, answer.data.token )
	p.rawwersPairingCode = ''
	check( p )
end

function provider.startDialog( p )
	if not p.rawwersDefaultsApplied then
		p.LR_jpeg_quality = 0.9
		pcall( function() p.LR_removeLocationMetadata = true end )
		p.rawwersDefaultsApplied = true
	end
	p.rawwersConnected, p.rawwersConnection = false, 'Checking...'
	p:addObserver( 'rawwersConnected', function()
		p.LR_cantExportBecause = p.rawwersConnected and nil or 'Connect to RAWWERS first: type the pairing code from the RAWWERS Pro app.'
	end )
	p.LR_cantExportBecause = 'Connect to RAWWERS first: type the pairing code from the RAWWERS Pro app.'
	LrTasks.startAsyncTask( function() check( p ) end, 'RAWWERS portfolio connection' )
end

function provider.sectionsForTopOfDialog( f, p )
	return {
		{
			title = 'RAWWERS Portfolio',
			synopsis = bind 'rawwersConnection',
			f:row { f:static_text { title = bind 'rawwersConnection', fill_horizontal = 1, height_in_lines = 2, width_in_chars = 60 } },
			f:row {
				visible = LrBinding.negativeOfKey( 'rawwersConnected' ),
				f:static_text { title = 'Pairing code:' },
				f:edit_field { value = bind 'rawwersPairingCode', width_in_chars = 11, immediate = true },
				f:push_button {
					title = 'Connect',
					action = function() LrTasks.startAsyncTask( function() connect( p ) end, 'RAWWERS pairing' ) end,
				},
			},
			f:row {
				visible = LrBinding.negativeOfKey( 'rawwersConnected' ),
				f:static_text { title = 'Get the code in the RAWWERS Pro app: Settings > Connect Lightroom. It works once, for 10 minutes.', fill_horizontal = 1 },
			},
			f:row {
				visible = LrBinding.negativeOfKey( 'rawwersConnected' ),
				f:static_text { title = 'This Mac is called:' },
				f:edit_field { value = bind 'rawwersDeviceName', width_in_chars = 30 },
			},
			f:row {
				f:static_text {
					title = 'Each collection of this service is one niche of your portfolio: create a collection and choose its niche. JPEG and sRGB only, at most 25 MB a photo. Photos appear on your profile once processed.',
					fill_horizontal = 1, height_in_lines = 3, width_in_chars = 70,
				},
			},
			f:row {
				f:static_text { title = 'Server:' },
				f:edit_field { value = bind 'rawwersServer', width_in_chars = 40, placeholder_string = Config.baseUrl },
			},
		},
	}
end

-- Collections: one per niche ------------------------------------------------------------

function provider.getCollectionBehaviorInfo( publishSettings )
	return {
		defaultCollectionName = 'Portfolio (main niche)',
		defaultCollectionCanBeDeleted = false,
		canAddCollection = true,
		maxCollectionSetDepth = 0,
	}
end

function provider.viewForCollectionSettings( f, publishSettings, info )
	local settings = info.collectionSettings
	settings.rawwersNicheItems = settings.rawwersNicheItems or {}
	settings.rawwersNicheNote = 'Loading your niches...'
	if not settings.rawwersNicheSlug or settings.rawwersNicheSlug == '' then
		settings.LR_canSaveCollection = info.isDefaultCollection == true
	end
	settings:addObserver( 'rawwersNicheSlug', function()
		settings.LR_canSaveCollection = ( settings.rawwersNicheSlug or '' ) ~= '' or info.isDefaultCollection == true
	end )
	LrTasks.startAsyncTask( function()
		local base = Lightroom.baseUrl( publishSettings )
		local token = Lightroom.storedToken( base )
		if not token then
			settings.rawwersNicheNote = 'Connect to RAWWERS first: edit the publish service settings.'
			return
		end
		local answer = Lightroom.api( base, { token = token } ):portfolio()
		if not answer.ok then
			settings.rawwersNicheNote = answer.message
			return
		end
		settings.rawwersNicheItems = Portfolio.nicheItems( answer.data.niches )
		settings.rawwersNicheNote = #settings.rawwersNicheItems == 0
			and 'You have no niches yet. Choose them in the RAWWERS Pro app: Profile > Niches.'
			or 'The photos of this collection go to this niche of your portfolio.'
	end, 'RAWWERS niches' )
	return f:group_box {
		title = 'RAWWERS',
		bind_to_object = settings,
		f:row {
			f:static_text { title = 'Niche:' },
			f:popup_menu { items = bind 'rawwersNicheItems', value = bind 'rawwersNicheSlug', width_in_chars = 40 },
		},
		f:row { f:static_text { title = bind 'rawwersNicheNote', fill_horizontal = 1, width_in_chars = 50 } },
	}
end

-- Publishing ------------------------------------------------------------------------------

local function collectionInfo( exportContext )
	local collection = exportContext.publishedCollection
	local ok, summary = pcall( function() return collection:getCollectionInfoSummary() end )
	if not ok or type( summary ) ~= 'table' then return nil, false end
	local settings = summary.collectionSettings or {}
	return settings.rawwersNicheSlug, summary.isDefaultCollection == true
end

function provider.processRenderedPhotos( functionContext, exportContext )
	local p = exportContext.propertyTable
	local count = exportContext.exportSession:countRenditions()
	local progress = exportContext:configureProgress {
		title = count == 1 and 'Publishing 1 photo to RAWWERS' or ( 'Publishing ' .. count .. ' photos to RAWWERS' ),
	}

	local base = Lightroom.baseUrl( p )
	local token = Lightroom.storedToken( base )
	if not token then
		LrErrors.throwUserError( 'Connect to RAWWERS first: edit the RAWWERS Portfolio publish service and type a pairing code.' )
	end
	local isCanceled = function() return progress:isCanceled() end
	local api = Lightroom.api( base, { token = token, isCanceled = isCanceled } )

	local answer = api:portfolio()
	if not answer.ok then
		if answer.outcome == 'reauth' then Lightroom.storeToken( base, '' ) end
		LrErrors.throwUserError( answer.message )
	end
	local chosen, isDefault = collectionInfo( exportContext )
	local niche = Portfolio.nicheFor( answer.data.niches, chosen, isDefault )
	if not niche then
		LrErrors.throwUserError( 'Choose this collection\'s niche: right-click the collection > Edit Collection.' )
	end

	local results, done = {}, 0
	local pipeline = Pipeline.new {
		workers = Pipeline.DEFAULT_WORKERS,
		spawn = Lightroom.spawn,
		sleep = Lightroom.sleep,
		isCanceled = isCanceled,
		process = function( job )
			local file = Lightroom.renderedFile( job.path )
			local result
			if not file then
				result = { state = 'failed', name = job.name, message = 'The exported file could not be read.' }
			elseif Checks.problem( file.size, nil, nil, Checks.MAX_PORTFOLIO_BYTES ) == 'too_large' then
				result = { state = 'failed', name = file.name, message = 'Larger than 25 MB. Export it smaller.' }
			else
				result = Portfolio.publishOne( api, niche.slug, file, job.previousId )
			end
			LrFileUtils.delete( job.path )
			return result
		end,
		onResult = function( job, result )
			done = done + 1
			progress:setCaption( 'RAWWERS: ' .. done .. ' of ' .. count .. ' done' )
			if ( result.state == 'uploaded' or result.state == 'skipped' ) and result.media_asset_id then
				job.rendition:recordPublishedPhotoId( result.media_asset_id )
			else
				job.rendition:uploadFailed( result.message or 'Not published' )
			end
		end,
	}
	pipeline:start()

	for _, rendition in exportContext:renditions { stopIfCanceled = true } do
		local rendered, pathOrMessage = rendition:waitForRender()
		if progress:isCanceled() then break end
		if rendered then
			local queued = pipeline:add {
				rendition = rendition, path = pathOrMessage, name = LrPathUtils.leafName( pathOrMessage ),
				previousId = rendition.publishedPhotoId,
			}
			if not queued then
				LrFileUtils.delete( pathOrMessage )
				break
			end
		else
			results[ #results + 1 ] = { state = 'failed', name = 'a photo', message = pathOrMessage }
		end
	end

	local finished, stopReason = pipeline:finish()
	for _, entry in ipairs( finished ) do results[ #results + 1 ] = entry.result end
	for _, job in ipairs( pipeline:notStarted() ) do LrFileUtils.delete( job.path ) end
	if stopReason == 'reauth' then Lightroom.storeToken( base, '' ) end

	local title, body = Portfolio.summary( results, niche.name, stopReason )
	LrDialogs.message( title, body, stopReason and 'warning' or 'info' )
end

-- Removing ----------------------------------------------------------------------------------

local function removeIds( publishSettings, ids, deletedCallback )
	local base = Lightroom.baseUrl( publishSettings )
	local token = Lightroom.storedToken( base )
	if not token then
		LrErrors.throwUserError( 'Connect to RAWWERS first: edit the RAWWERS Portfolio publish service and type a pairing code.' )
	end
	local api = Lightroom.api( base, { token = token } )
	local failed, stopReason = Portfolio.removeAll( api, ids, deletedCallback )
	if stopReason == 'reauth' then Lightroom.storeToken( base, '' ) end
	if #failed > 0 then
		LrErrors.throwUserError( 'RAWWERS could not remove ' .. #failed .. ' photo(s): ' .. tostring( failed[ 1 ].message ) )
	end
end

function provider.deletePhotosFromPublishedCollection( publishSettings, arrayOfPhotoIds, deletedCallback )
	removeIds( publishSettings, arrayOfPhotoIds, deletedCallback )
end

--- Deleting a niche's collection removes its photos from the portfolio.
function provider.deletePublishedCollection( publishSettings, info )
	local ids = {}
	local ok, photos = pcall( function() return info.publishedCollection:getPublishedPhotos() end )
	if ok and photos then
		for _, published in ipairs( photos ) do
			local id = published:getRemoteId()
			if id then ids[ #ids + 1 ] = id end
		end
	end
	if #ids > 0 then removeIds( publishSettings, ids, function() end ) end
end

return provider
