--[[ "Export To: RAWWERS" - the Export dialog section and the export itself.

The dialog: connect once with a pairing code from the RAWWERS Pro app
(Settings > Connect Lightroom), then pick the client's gig and export. JPEG
and sRGB are the only choices offered. The export: each rendered photo is
hashed, sent, and finished, a few at a time; at the end a summary says what
was uploaded, skipped as already there, and failed. The plug-in never sends
anything to the client: that stays in the app.

The SDK hooks used here (SDK 15.3 reference, "SDK - Export service
provider"; all present since SDK 1.3 unless noted): allowFileFormats,
allowColorSpaces, hideSections, hidePrintResolution, canExportVideo (3.0),
exportPresetFields, startDialog, sectionsForTopOfDialog,
processRenderedPhotos; exportContext:configureProgress / :renditions;
rendition:waitForRender / :uploadFailed (2.0); LrView, LrBinding
(negativeOfKey), LrDialogs.message / .confirm, LrErrors.throwUserError,
propertyTable:addObserver, LR_cantExportBecause (as Adobe's Flickr sample).
]]

local LrBinding = import 'LrBinding'
local LrDate = import 'LrDate'
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
local Summary = require 'RawwersSummary'
local Upload = require 'RawwersUpload'

local bind = LrView.bind

local provider = {}

provider.allowFileFormats = { 'JPEG' }
provider.allowColorSpaces = { 'sRGB' }
-- Rendered into a temporary folder, deleted after the export.
provider.hideSections = { 'exportLocation' }
provider.hidePrintResolution = true
provider.canExportVideo = false

-- Saved with an export preset. Never the token (presets are plain files
-- people share; the token lives in the system keychain), and the client's
-- gig only together with when it was chosen (see processRenderedPhotos).
provider.exportPresetFields = {
	{ key = 'rawwersServer', default = '' },
	{ key = 'rawwersDeviceName', default = 'Lightroom Classic' },
	{ key = 'rawwersGigId', default = '' },
	{ key = 'rawwersGigLabel', default = '' },
	{ key = 'rawwersGigChosenAt', default = 0 },
	{ key = 'rawwersDefaultsApplied', default = false },
}

--- A choice older than this, reused by "Export with Previous" without the
--- dialog, is confirmed before anything is sent: the wrong client's gallery
--- is the one mistake this must not make quietly.
local CHOICE_FRESH_SECONDS = 30 * 60

local gigsById = {}

local function setConnection( p, connected, text )
	p.rawwersConnected = connected
	p.rawwersConnection = text
end

local function updateCantExport( p )
	if not p.rawwersConnected then
		p.LR_cantExportBecause = 'Connect to RAWWERS first: type the pairing code from the RAWWERS Pro app.'
	elseif not p.rawwersGigId or p.rawwersGigId == '' then
		p.LR_cantExportBecause = 'Choose the client in the RAWWERS section.'
	else
		p.LR_cantExportBecause = nil
	end
end

local function updateNote( p, api )
	if api and api.update_available then
		p.rawwersUpdateNote = 'A newer RAWWERS plug-in is available. Download it from the link RAWWERS sent you.'
	else
		p.rawwersUpdateNote = ''
	end
end

local function forget( p, base, why )
	Lightroom.storeToken( base, '' )
	gigsById = {}
	p.rawwersGigItems = {}
	p.rawwersGigId = ''
	setConnection( p, false, why )
end

local function loadGigs( p )
	local base = Lightroom.baseUrl( p )
	local token = Lightroom.storedToken( base )
	if not token then return end
	local api = Lightroom.api( base, { token = token } )
	p.rawwersGigNote = 'Loading your gigs...'
	local answer = api:gigs()
	updateNote( p, api )
	if not answer.ok then
		if answer.outcome == 'reauth' then
			forget( p, base, answer.message or 'This Mac is no longer connected. Type a new pairing code.' )
		end
		p.rawwersGigNote = answer.message
		return
	end
	gigsById = {}
	local items = {}
	for _, gig in ipairs( answer.data.items or {} ) do
		gigsById[ gig.gig_id ] = gig
		items[ #items + 1 ] = { title = Summary.gigLabel( gig, Lightroom.formatDate ), value = gig.gig_id }
	end
	p.rawwersGigItems = items
	if #items == 0 then
		p.rawwersGigNote = 'No gigs are waiting for photos. A booking appears here once it is paid and shot, until you send its gallery from the RAWWERS Pro app.'
	else
		p.rawwersGigNote = ''
	end
	if not gigsById[ p.rawwersGigId ] then p.rawwersGigId = '' end
end

local function checkConnection( p )
	local base = Lightroom.baseUrl( p )
	local token = Lightroom.storedToken( base )
	if not token then
		setConnection( p, false, 'Not connected.' )
		return
	end
	local api = Lightroom.api( base, { token = token } )
	local answer = api:me()
	updateNote( p, api )
	if answer.ok then
		setConnection( p, true, 'Connected as ' .. tostring( answer.data.photographer_name ) )
		loadGigs( p )
	elseif answer.outcome == 'reauth' then
		forget( p, base, answer.message )
	else
		-- Keep the token: the server may only be unreachable for now.
		setConnection( p, false, answer.message )
	end
end

local function connect( p )
	local base = Lightroom.baseUrl( p )
	local api = Lightroom.api( base )
	p.rawwersConnection = 'Connecting...'
	local answer = api:pair( p.rawwersPairingCode or '', p.rawwersDeviceName or 'Lightroom Classic' )
	updateNote( p, api )
	if not answer.ok then
		setConnection( p, false, answer.message )
		return
	end
	Lightroom.storeToken( base, answer.data.token )
	p.rawwersPairingCode = ''
	setConnection( p, true, 'Connected as ' .. tostring( answer.data.photographer_name ) )
	loadGigs( p )
end

function provider.startDialog( p )
	if not p.rawwersDefaultsApplied then
		-- First use only; the photographer may change them afterwards.
		-- LR_jpeg_quality appears in Adobe's samples; LR_removeLocationMetadata
		-- is not in the SDK reference - the owner's checklist confirms it.
		p.LR_jpeg_quality = 0.9
		pcall( function() p.LR_removeLocationMetadata = true end )
		p.rawwersDefaultsApplied = true
	end
	-- Pick the client again each time the dialog opens.
	p.rawwersGigId = ''
	p.rawwersGigItems = {}
	p.rawwersGigNote = ''
	p.rawwersUpdateNote = ''
	setConnection( p, false, 'Checking...' )
	p:addObserver( 'rawwersConnected', function() updateCantExport( p ) end )
	p:addObserver( 'rawwersGigId', function()
		local gig = gigsById[ p.rawwersGigId ]
		p.rawwersGigLabel = gig and Summary.gigLabel( gig, Lightroom.formatDate ) or ''
		p.rawwersGigChosenAt = gig and LrDate.currentTime() or 0
		updateCantExport( p )
	end )
	updateCantExport( p )
	LrTasks.startAsyncTask( function() checkConnection( p ) end, 'RAWWERS connection' )
end

function provider.sectionsForTopOfDialog( f, p )
	return {
		{
			title = 'RAWWERS',
			synopsis = bind 'rawwersConnection',
			f:row {
				f:static_text { title = bind 'rawwersConnection', fill_horizontal = 1 },
				f:push_button {
					title = 'Disconnect',
					enabled = bind 'rawwersConnected',
					action = function()
						forget( p, Lightroom.baseUrl( p ), 'Disconnected on this Mac. To stop it everywhere, revoke it in the RAWWERS Pro app.' )
					end,
				},
			},
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
				f:static_text {
					title = 'Get the code in the RAWWERS Pro app: Settings > Connect Lightroom. It works once, for 10 minutes.',
					fill_horizontal = 1,
				},
			},
			f:row {
				visible = LrBinding.negativeOfKey( 'rawwersConnected' ),
				f:static_text { title = 'This Mac is called:' },
				f:edit_field { value = bind 'rawwersDeviceName', width_in_chars = 30 },
			},
			f:row {
				visible = bind 'rawwersConnected',
				f:static_text { title = 'Client:' },
				f:popup_menu { items = bind 'rawwersGigItems', value = bind 'rawwersGigId', width_in_chars = 60 },
				f:push_button {
					title = 'Refresh',
					action = function() LrTasks.startAsyncTask( function() loadGigs( p ) end, 'RAWWERS gigs' ) end,
				},
			},
			f:row {
				f:static_text { title = bind 'rawwersGigNote', fill_horizontal = 1, height_in_lines = 2 },
			},
			f:row {
				f:static_text {
					title = 'JPEG and sRGB only. ' .. Checks.suggestedPreset .. ' Nothing reaches the client until you send the gallery from the RAWWERS Pro app.',
					fill_horizontal = 1,
					height_in_lines = 4,
					width_in_chars = 70,
				},
			},
			f:row {
				f:static_text { title = bind 'rawwersUpdateNote', fill_horizontal = 1 },
			},
			f:row {
				f:static_text { title = 'Server:' },
				f:edit_field { value = bind 'rawwersServer', width_in_chars = 40, placeholder_string = Config.baseUrl },
			},
		},
	}
end

local function photoName( rendition, fallback )
	local ok, name = pcall( function() return rendition.photo:getFormattedMetadata( 'fileName' ) end )
	return ( ok and name ) or fallback or 'a photo'
end

function provider.processRenderedPhotos( functionContext, exportContext )
	local p = exportContext.propertyTable
	local session = exportContext.exportSession
	local count = session:countRenditions()
	local progress = exportContext:configureProgress {
		title = count == 1 and 'Uploading 1 photo to RAWWERS' or ( 'Uploading ' .. count .. ' photos to RAWWERS' ),
	}

	local base = Lightroom.baseUrl( p )
	local token = Lightroom.storedToken( base )
	if not token then
		LrErrors.throwUserError( 'Connect to RAWWERS first: open the Export dialog and type a pairing code from the RAWWERS Pro app.' )
	end
	local gigId = p.rawwersGigId
	if not gigId or gigId == '' then
		LrErrors.throwUserError( 'Choose the client in the RAWWERS section of the Export dialog.' )
	end
	if LrDate.currentTime() - ( p.rawwersGigChosenAt or 0 ) > CHOICE_FRESH_SECONDS then
		local answer = LrDialogs.confirm(
			'Upload to ' .. ( p.rawwersGigLabel ~= '' and p.rawwersGigLabel or 'the client chosen last time' ) .. '?',
			'This export reuses the client chosen earlier. Check it is the right one.',
			'Upload', 'Cancel' )
		if answer ~= 'ok' then return end
	end

	local isCanceled = function() return progress:isCanceled() end
	local api = Lightroom.api( base, { token = token, isCanceled = isCanceled } )
	local results, small, done = {}, {}, 0

	local pipeline = Pipeline.new {
		workers = Pipeline.DEFAULT_WORKERS,
		spawn = Lightroom.spawn,
		sleep = Lightroom.sleep,
		isCanceled = isCanceled,
		process = function( job )
			local file = Lightroom.renderedFile( job.path )
			if not file then return { state = 'failed', name = job.name, message = 'The exported file could not be read.' } end
			file.position = job.position
			local width, height = Checks.jpegSize( file.head )
			local problem = Checks.problem( file.size, width, height )
			local result
			if problem == 'too_large' then
				result = { state = 'failed', name = file.name, message = 'Larger than 50 MB. Export it smaller.' }
			else
				if problem == 'small' then small[ #small + 1 ] = file.name end
				result = Upload.deliver( api, gigId, file )
			end
			LrFileUtils.delete( job.path )
			return result
		end,
		onResult = function( job, result )
			done = done + 1
			progress:setCaption( 'RAWWERS: ' .. done .. ' of ' .. count .. ' done' )
			if result.state == 'failed' then job.rendition:uploadFailed( result.message or 'Upload failed' ) end
		end,
	}
	pipeline:start()

	local renderFailures = {}
	for position, rendition in exportContext:renditions { stopIfCanceled = true } do
		local rendered, pathOrMessage = rendition:waitForRender()
		if progress:isCanceled() then break end
		if rendered then
			local queued = pipeline:add { rendition = rendition, path = pathOrMessage, name = LrPathUtils.leafName( pathOrMessage ), position = position }
			if not queued then
				LrFileUtils.delete( pathOrMessage )
				break
			end
		else
			renderFailures[ #renderFailures + 1 ] = { state = 'failed', name = photoName( rendition ), message = pathOrMessage }
		end
	end

	local finished, stopReason = pipeline:finish()
	for _, entry in ipairs( finished ) do results[ #results + 1 ] = entry.result end
	for _, failure in ipairs( renderFailures ) do results[ #results + 1 ] = failure end
	for _, job in ipairs( pipeline:notStarted() ) do LrFileUtils.delete( job.path ) end
	if stopReason == 'reauth' then Lightroom.storeToken( base, '' ) end

	local title, body = Summary.build( results, { small = small, notSent = count - #results }, stopReason )
	if api.update_available then
		body = body .. '\n\nA newer RAWWERS plug-in is available. Download it from the link RAWWERS sent you.'
	end
	LrDialogs.message( title, body, ( #results < count or stopReason ) and 'warning' or 'info' )
end

return provider
