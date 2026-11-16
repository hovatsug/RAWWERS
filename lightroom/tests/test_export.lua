-- The Export To: RAWWERS glue, run with stand-ins for Lightroom's modules
-- (LrHttp, LrPasswords, LrTasks, LrDialogs ...) and a small fake RAWWERS
-- server: a whole export, a second export (all skipped), a failing photo
-- among good ones, a revoked device, and the dialog's locked choices.
--
--   lua5.1 tests/test_export.lua

package.path = './rawwers.lrdevplugin/?.lua;./tests/?.lua;' .. package.path

local H = require 'harness'
local Json = require 'RawwersJson'
local test, eq, ok, has = H.test, H.eq, H.ok, H.has

-- A cooperative scheduler standing in for LrTasks -------------------------------------

local tasks = {}
--- Runs main and every task it starts until all have finished. Returns the
--- error main stopped with, if any (Lua 5.1 cannot yield inside pcall, so
--- the coroutine's own result is the only way to catch it).
local function runAll( main )
	local mainTask = coroutine.create( main )
	local all = { mainTask }
	local mainError
	repeat
		local alive = false
		for _, list in ipairs { all, tasks } do
			for _, co in ipairs( list ) do
				if coroutine.status( co ) == 'suspended' then
					alive = true
					local okResume, err = coroutine.resume( co )
					if not okResume then
						if co == mainTask then mainError = err else error( err, 0 ) end
					end
				end
			end
		end
	until not alive
	tasks = {}
	return mainError
end

-- The fake server ------------------------------------------------------------------------

local server
local function newServer()
	server = {
		token = 'rwd_good', revoked = false, assets = {}, bySha = {}, nextId = 0, stored = {},
		calls = {}, storageHeaders = {}, failStorageFor = {},
		niches = { { slug = 'weddings', name = 'Weddings', primary = true }, { slug = 'portraits', name = 'Portraits', primary = false } },
		portfolioStarts = {}, removed = {},
		catalog = { { slug = 'weddings', name = 'Weddings' }, { slug = 'portraits', name = 'Portraits' }, { slug = 'food', name = 'Food' }, { slug = 'cars', name = 'Automotive' } },
		maximum = 3,
	}
end

local function respond( status, body, headers )
	local h = { status = status }
	for field, value in pairs( headers or {} ) do h[ #h + 1 ] = { field = field, value = value } end
	return body and Json.encode( body ) or '', h
end

local function headerValue( headers, name )
	for _, h in ipairs( headers or {} ) do if h.field:lower() == name:lower() then return h.value end end
end

local function handle( method, url, headers, body )
	server.calls[ #server.calls + 1 ] = { method = method, url = url, headers = headers }
	local path = url:match( '^https://api%.test(/.*)$' )
	if not path then
		-- storage
		server.storageHeaders[ #server.storageHeaders + 1 ] = headers
		local key = url:match( '^https://r2%.test/(.*)$' )
		for name in pairs( server.failStorageFor ) do
			if key:sub( -#name ) == name then return respond( 500 ) end
		end
		server.stored[ key ] = body
		return respond( 200, nil, { ETag = '"etag"' } )
	end
	if server.down then return nil, { error = { errorCode = 'networkConnectionLost', name = 'The network connection was lost.' } } end
	if path == '/v1/delivery/pair' and method == 'POST' then
		local data = Json.decode( body ) or {}
		if data.code ~= 'GOOD-CODE' then
			return respond( 422, { error = { code = 'pairing_code_invalid', message = 'That code is wrong or has expired. Get a new one in the RAWWERS Pro app.' } } )
		end
		server.revoked = false
		return respond( 200, { token = server.token, device_id = 'dev-1', photographer_name = 'Pro One' } )
	end
	if headerValue( headers, 'Authorization' ) ~= 'Bearer ' .. server.token or server.revoked then
		return respond( 401, { error = { code = 'delivery_token_revoked', message = 'This device was disconnected. Connect Lightroom again with a new pairing code.' } } )
	end
	if server.minimum then
		return respond( 426, { error = { code = 'plugin_outdated', message = 'This RAWWERS plug-in (1.0.0) is too old: version ' .. server.minimum .. ' or newer is needed.' } } )
	end
	local data = body and body ~= '' and Json.decode( body ) or {}
	local gig = path:match( '^/v1/delivery/gigs/([^/]+)/uploads$' )
	if gig and method == 'POST' then
		local existing = server.bySha[ data.sha256 ]
		if existing and server.assets[ existing ].done then
			return respond( 200, { media_asset_id = existing, gallery_id = 'gal-1', duplicate = true } )
		end
		server.nextId = server.nextId + 1
		local id = 'asset-' .. server.nextId
		server.assets[ id ] = { name = data.file_name, sha = data.sha256, size = data.byte_size, position = data.position, exportId = data.export_id }
		server.bySha[ data.sha256 ] = id
		return respond( 200, { media_asset_id = id, gallery_id = 'gal-1', duplicate = false, use_multipart = false,
			upload = { method = 'PUT', url = 'https://r2.test/' .. data.file_name, headers = { [ 'Content-Type' ] = 'image/jpeg' } } } )
	end
	if path == '/v1/delivery/portfolio/niches' then
		local function listing()
			local mine = {}
			for _, n in ipairs( server.niches ) do mine[ n.slug ] = n end
			local all = {}
			for _, n in ipairs( server.catalog ) do
				all[ #all + 1 ] = { slug = n.slug, name = n.name, mine = mine[ n.slug ] ~= nil, primary = mine[ n.slug ] and mine[ n.slug ].primary or false }
			end
			return { niches = all, count = #server.niches, maximum = server.maximum }
		end
		if method == 'GET' then return respond( 200, listing() ) end
		if method == 'POST' then
			server.added = server.added or {}
			server.added[ #server.added + 1 ] = data
			if #server.niches >= server.maximum then
				return respond( 422, { error = { code = 'niche_limit_reached', message = 'You can have at most ' .. server.maximum .. ' niches, and you have ' .. #server.niches .. '.' } } )
			end
			local found
			for _, n in ipairs( server.catalog ) do if n.slug == data.slug then found = n end end
			local niche = { slug = found.slug, name = found.name, primary = #server.niches == 0 }
			server.niches[ #server.niches + 1 ] = niche
			local body = listing()
			body.added = { slug = niche.slug, name = niche.name, mine = true, primary = niche.primary }
			return respond( 200, body )
		end
	end
	if path == '/v1/delivery/portfolio' and method == 'GET' then
		return respond( 200, { niches = server.niches, photo_count = 0, photo_minimum = 12 } )
	end
	if path == '/v1/delivery/portfolio/uploads' and method == 'POST' then
		server.portfolioStarts[ #server.portfolioStarts + 1 ] = data
		local key = data.niche_slug .. ':' .. data.sha256
		local existing = server.bySha[ key ]
		if existing and server.assets[ existing ].done and not server.assets[ existing ].removed then
			return respond( 200, { media_asset_id = existing, duplicate = true } )
		end
		server.nextId = server.nextId + 1
		local id = 'pf-' .. server.nextId
		server.assets[ id ] = { name = data.file_name, sha = data.sha256, size = data.byte_size, niche = data.niche_slug }
		server.bySha[ key ] = id
		return respond( 200, { media_asset_id = id, duplicate = false, use_multipart = false,
			upload = { method = 'PUT', url = 'https://r2.test/' .. data.file_name, headers = { [ 'Content-Type' ] = 'image/jpeg' } } } )
	end
	local removedId = path:match( '^/v1/delivery/portfolio/([^/]+)$' )
	if removedId and method == 'DELETE' then
		server.removed[ #server.removed + 1 ] = removedId
		local asset = server.assets[ removedId ]
		if not asset then return respond( 404, { error = { code = 'not_found', message = 'Photo not found' } } ) end
		asset.removed = true
		return respond( 200, { ok = true, media_asset_id = removedId } )
	end
	local finished = path:match( '^/v1/delivery/uploads/([^/]+)/complete$' )
	if finished then
		local asset = server.assets[ finished ]
		if data.sha256 ~= asset.sha then return respond( 409, { error = { code = 'checksum_mismatch', message = 'Not the same file.' } } ) end
		asset.done = true
		return respond( 200, { ok = true, current_status = 'processing' } )
	end
	return respond( 404, { error = { message = 'no route ' .. path } } )
end

-- Lightroom's modules --------------------------------------------------------------------

local keychain, dialogs, deleted = {}, {}, {}
local stubs = {
	LrHttp = {
		get = function( url, headers ) return handle( 'GET', url, headers, nil ) end,
		post = function( url, body, headers, method ) coroutine.yield() return handle( method or 'POST', url, headers, body ) end,
	},
	LrPasswords = {
		store = function( key, value ) keychain[ key ] = value end,
		retrieve = function( key ) return keychain[ key ] end,
	},
	LrDigest = {
		SHA256 = { init = function()
			local parts = {}
			return { update = function( _, s ) parts[ #parts + 1 ] = s end, digest = function() return 'sha-' .. table.concat( parts ):sub( 1, 12 ) end }
		end },
	},
	LrTasks = {
		startAsyncTask = function( fn ) tasks[ #tasks + 1 ] = coroutine.create( fn ) end,
		sleep = function() coroutine.yield() end,
	},
	LrFileUtils = {
		fileAttributes = function( path )
			local f = io.open( path, 'rb' )
			if not f then return {} end
			local size = f:seek( 'end' )
			f:close()
			return { fileSize = size }
		end,
		delete = function( path ) deleted[ #deleted + 1 ] = path os.remove( path ) end,
	},
	LrPathUtils = { leafName = function( path ) return path:match( '[^/]+$' ) end },
	LrDialogs = {
		message = function( title, body, style ) dialogs[ #dialogs + 1 ] = { title = title, body = body, style = style } end,
		confirm = function() dialogs[ #dialogs + 1 ] = { confirm = true } return dialogs.answer or 'ok' end,
		-- The person picks `dialogs.choose` in the dialog's popup, then `dialogs.modal` (default Add).
		presentModalDialog = function( args )
			dialogs[ #dialogs + 1 ] = { modal = args.title }
			if dialogs.choose then args.contents.bind_to_object.slug = dialogs.choose end
			return dialogs.modal or 'ok'
		end,
	},
	LrErrors = { throwUserError = function( text ) error( 'USER: ' .. text, 0 ) end },
	LrDate = {
		currentTime = function() return 1000000 end,
		formatShortDate = function( t ) return 'date' .. t end,
		timeFromPosixDate = function( t ) return t end,
	},
	LrView = {
		bind = function( key ) return { bound = key } end,
		-- Every view call returns its own arguments, so a test can read them.
		osFactory = function() return setmetatable( {}, { __index = function() return function( _, t ) return t end end } ) end,
	},
	LrBinding = { negativeOfKey = function( key ) return { notKey = key } end, makePropertyTable = function() return {} end },
	LrFunctionContext = { callWithContext = function( _name, fn, ... ) return fn( {}, ... ) end },
}
function import( name ) return assert( stubs[ name ], 'no stub for ' .. name ) end

local provider = require 'RawwersServiceProvider'

-- An export ---------------------------------------------------------------------------

local function renderedFiles( names )
	local renditions = {}
	for _, name in ipairs( names ) do
		local path = os.tmpname() .. '-' .. name
		local f = assert( io.open( path, 'wb' ) )
		f:write( 'JPEG:' .. name .. string.rep( '.', 100 ) )
		f:close()
		renditions[ #renditions + 1 ] = {
			path = path, failures = {},
			waitForRender = function( self ) return true, self.path end,
			uploadFailed = function( self, message ) self.failures[ #self.failures + 1 ] = message end,
			photo = { getFormattedMetadata = function() return name end },
		}
	end
	return renditions
end

local function export( names, props )
	local renditions = renderedFiles( names )
	local canceled = false
	local context = {
		propertyTable = props or { rawwersServer = 'https://api.test', rawwersGigId = 'gig-1', rawwersGigLabel = 'Ana S.', rawwersGigChosenAt = 1000000 - 60 },
		exportSession = { countRenditions = function() return #renditions end },
		configureProgress = function() return { isCanceled = function() return canceled end, setCaption = function() end } end,
		renditions = function()
			local i = 0
			return function() i = i + 1 if renditions[ i ] then return i, renditions[ i ] end end
		end,
	}
	dialogs = {}
	local err = runAll( function() provider.processRenderedPhotos( {}, context ) end )
	return renditions, err
end

local function freshKeychain()
	keychain = { [ 'rawwers.delivery-token:https://api.test' ] = 'rwd_good' }
	deleted = {}
end

-- The dialog's locked choices --------------------------------------------------------------

test( 'only JPEG and only sRGB are offered; the export folder is a temporary one', function()
	eq( provider.allowFileFormats, { 'JPEG' } )
	eq( provider.allowColorSpaces, { 'sRGB' } )
	eq( provider.hideSections, { 'exportLocation' } )
	eq( provider.canExportVideo, false )
end )

test( 'presets never hold the token', function()
	for _, field in ipairs( provider.exportPresetFields ) do
		ok( not field.key:lower():find( 'token' ), 'a preset field holds the token: ' .. field.key )
	end
end )

test( 'the plug-in declares the last three Lightroom Classic versions', function()
	local info = dofile( './rawwers.lrdevplugin/Info.lua' )
	eq( info.LrSdkMinimumVersion, 13.0 )
	eq( info.LrSdkVersion, 15.3 )
	eq( info.LrExportServiceProvider[ 1 ], { title = 'RAWWERS', file = 'RawwersServiceProvider.lua' } )
	eq( info.LrExportServiceProvider[ 2 ], { title = 'RAWWERS Portfolio', file = 'RawwersPublishProvider.lua' } )
	eq( info.VERSION, { major = 1, minor = 2, revision = 2, build = 0 } )
	eq( require( 'RawwersConfig' ).version, '1.2.2' )
end )

-- Exports ---------------------------------------------------------------------------------

test( 'an export uploads every photo, says so, and cleans up the rendered files', function()
	newServer()
	freshKeychain()
	local renditions, err = export { 'IMG_1.jpg', 'IMG_2.jpg', 'IMG_3.jpg' }
	eq( err, nil )
	eq( server.nextId, 3 )
	for _, asset in pairs( server.assets ) do ok( asset.done, asset.name .. ' was not finished' ) end
	eq( #deleted, 3 )
	local summary = dialogs[ #dialogs ]
	eq( summary.title, 'RAWWERS: delivery uploaded' )
	has( summary.body, '3 photos uploaded' )
	has( summary.body, '0 skipped' )
	for _, r in ipairs( renditions ) do eq( r.failures, {} ) end
end )

test( 'each photo is sent with its place in the export, so the gallery keeps that order', function()
	newServer()
	freshKeychain()
	export { 'IMG_9.jpg', 'IMG_2.jpg', 'IMG_5.jpg' }
	local places = {}
	for _, asset in pairs( server.assets ) do places[ asset.name:match( 'IMG_%d' ) ] = asset.position end
	eq( places, { IMG_9 = 1, IMG_2 = 2, IMG_5 = 3 } )
end )

test( 'each export names itself, so a later export goes after the earlier ones in the gallery', function()
	newServer()
	freshKeychain()
	export { 'IMG_1.jpg', 'IMG_2.jpg' }
	local first = {}
	for _, asset in pairs( server.assets ) do first[ asset.exportId or 'none' ] = true end
	export { 'IMG_3.jpg', 'IMG_4.jpg' }
	local names, second = {}, {}
	for _, asset in pairs( server.assets ) do
		names[ #names + 1 ] = asset.exportId
		if asset.name:match( 'IMG_[34]%.jpg$' ) then second[ asset.exportId or 'none' ] = true end
	end
	eq( #names, 4 )
	local firstId, secondId = next( first ), next( second )
	ok( firstId and secondId, 'both exports were sent' )
	ok( next( first, firstId ) == nil, 'one export, one name' )
	ok( next( second, secondId ) == nil, 'one export, one name' )
	ok( firstId ~= 'none' and secondId ~= 'none', 'every photo names its export' )
	ok( firstId ~= secondId, 'two exports, two names' )
	-- What the server accepts: letters, digits, dot, dash, underscore; 64 at most.
	for _, id in ipairs { firstId, secondId } do ok( id:match( '^[%w._-]+$' ) and #id <= 64, id ) end
end )

test( 'storage never sees the token', function()
	newServer()
	freshKeychain()
	export { 'IMG_1.jpg' }
	ok( #server.storageHeaders == 1 )
	for _, headers in ipairs( server.storageHeaders ) do
		eq( headerValue( headers, 'Authorization' ), nil )
	end
end )

test( 'exporting the same photos again skips them all', function()
	newServer()
	freshKeychain()
	export { 'IMG_1.jpg', 'IMG_2.jpg' }
	local before = server.nextId
	export { 'IMG_1.jpg', 'IMG_2.jpg' }
	eq( server.nextId, before, 'a second copy was started' )
	has( dialogs[ #dialogs ].body, '2 skipped, already in the gallery' )
	has( dialogs[ #dialogs ].body, '0 photos uploaded' )
end )

test( 'a photo that keeps failing is named, and the others still go', function()
	newServer()
	freshKeychain()
	server.failStorageFor[ 'IMG_2.jpg' ] = true
	local renditions = export { 'IMG_1.jpg', 'IMG_2.jpg', 'IMG_3.jpg' }
	local summary = dialogs[ #dialogs ]
	has( summary.title, '1 photo did not upload' )
	has( summary.body, '2 photos uploaded' )
	has( summary.body, 'IMG_2.jpg' )
	eq( #renditions[ 2 ].failures, 1, 'Lightroom was not told the photo failed' )
	eq( renditions[ 1 ].failures, {} )
end )

test( 'a revoked device stops the export and asks for a new code', function()
	newServer()
	freshKeychain()
	server.revoked = true
	export { 'IMG_1.jpg', 'IMG_2.jpg', 'IMG_3.jpg', 'IMG_4.jpg', 'IMG_5.jpg' }
	local summary = dialogs[ #dialogs ]
	eq( summary.title, 'RAWWERS: connect again' )
	has( summary.body, 'Settings > Connect Lightroom' )
	eq( keychain[ 'rawwers.delivery-token:https://api.test' ], '', 'the dead token was kept' )
	local asked = 0
	for _, call in ipairs( server.calls ) do if call.url:find( '/uploads$' ) then asked = asked + 1 end end
	ok( asked <= 3, 'kept trying after the refusal: ' .. asked )
end )

test( 'a plug-in too old stops the export, says where to get the new one, and keeps the connection', function()
	newServer()
	freshKeychain()
	server.minimum = '2.0.0'
	export { 'IMG_1.jpg', 'IMG_2.jpg', 'IMG_3.jpg', 'IMG_4.jpg', 'IMG_5.jpg' }
	local summary = dialogs[ #dialogs ]
	eq( summary.title, 'RAWWERS: update the plug-in' )
	has( summary.body, 'version 2.0.0 or newer is needed' )
	eq( keychain[ 'rawwers.delivery-token:https://api.test' ], 'rwd_good', 'the connection was dropped' )
	local asked = 0
	for _, call in ipairs( server.calls ) do if call.url:find( '/uploads$' ) then asked = asked + 1 end end
	ok( asked <= 3, 'kept trying after the refusal: ' .. asked )
end )

test( 'without a connection the export stops before anything is sent', function()
	newServer()
	keychain = {}
	local _, err = export { 'IMG_1.jpg' }
	has( err, 'Connect to RAWWERS first' )
	eq( #server.calls, 0 )
end )

test( 'without a client chosen the export stops before anything is sent', function()
	newServer()
	freshKeychain()
	local _, err = export( { 'IMG_1.jpg' }, { rawwersServer = 'https://api.test', rawwersGigId = '' } )
	has( err, 'Choose the client' )
	eq( #server.calls, 0 )
end )

test( 'a client chosen long ago is confirmed first, and a "no" sends nothing', function()
	newServer()
	freshKeychain()
	dialogs = { answer = 'cancel' }
	local renditions = renderedFiles { 'IMG_1.jpg' }
	local context = {
		propertyTable = { rawwersServer = 'https://api.test', rawwersGigId = 'gig-1', rawwersGigLabel = 'Ana S.', rawwersGigChosenAt = 0 },
		exportSession = { countRenditions = function() return 1 end },
		configureProgress = function() return { isCanceled = function() return false end, setCaption = function() end } end,
		renditions = function() local i = 0 return function() i = i + 1 if renditions[ i ] then return i, renditions[ i ] end end end,
	}
	runAll( function() provider.processRenderedPhotos( {}, context ) end )
	ok( dialogs[ 1 ] and dialogs[ 1 ].confirm, 'no confirmation asked' )
	eq( #server.calls, 0 )
end )

-- The RAWWERS Portfolio publish service ------------------------------------------------------

local publisher = require 'RawwersPublishProvider'

local function publish( names, collection, previousIds )
	local renditions = renderedFiles( names )
	for i, r in ipairs( renditions ) do
		r.publishedPhotoId = previousIds and previousIds[ i ] or nil
		r.recordPublishedPhotoId = function( self, id ) self.recorded = id end
	end
	local context = {
		propertyTable = { rawwersServer = 'https://api.test' },
		exportSession = { countRenditions = function() return #renditions end },
		configureProgress = function() return { isCanceled = function() return false end, setCaption = function() end } end,
		renditions = function()
			local i = 0
			return function() i = i + 1 if renditions[ i ] then return i, renditions[ i ] end end
		end,
		publishedCollection = { getCollectionInfoSummary = function()
			return { collectionSettings = { rawwersNicheSlug = collection and collection.slug }, isDefaultCollection = collection and collection.default or false }
		end },
	}
	dialogs = {}
	local err = runAll( function() publisher.processRenderedPhotos( {}, context ) end )
	return renditions, err
end

test( 'the portfolio service is publish-only, JPEG and sRGB, and keeps no token in presets', function()
	eq( publisher.supportsIncrementalPublish, 'only' )
	eq( publisher.allowFileFormats, { 'JPEG' } )
	eq( publisher.allowColorSpaces, { 'sRGB' } )
	eq( publisher.canExportVideo, false )
	for _, field in ipairs( publisher.exportPresetFields ) do
		ok( not field.key:lower():find( 'token' ), 'a preset field holds the token: ' .. field.key )
	end
	local behaviour = publisher.getCollectionBehaviorInfo( {} )
	eq( behaviour.maxCollectionSetDepth, 0 )
	eq( behaviour.defaultCollectionCanBeDeleted, false )
end )

test( 'publishing sends each photo to the collection\'s niche and records its portfolio id', function()
	newServer()
	freshKeychain()
	local renditions, err = publish( { 'P_1.jpg', 'P_2.jpg' }, { slug = 'portraits' } )
	eq( err, nil )
	eq( #server.portfolioStarts, 2 )
	for _, start in ipairs( server.portfolioStarts ) do eq( start.niche_slug, 'portraits' ) end
	for _, r in ipairs( renditions ) do ok( r.recorded and r.recorded:match( '^pf%-' ), 'no portfolio id recorded' ) end
	eq( dialogs[ #dialogs ].title, 'Published to RAWWERS' )
	has( dialogs[ #dialogs ].body, '2 photos sent to your RAWWERS portfolio (Portraits)' )
	eq( #deleted, 2 )
end )

test( 'the default collection publishes to the main niche', function()
	newServer()
	freshKeychain()
	publish( { 'P_1.jpg' }, { default = true } )
	eq( server.portfolioStarts[ 1 ].niche_slug, 'weddings' )
end )

test( 'a collection without a niche of the photographer\'s sends nothing', function()
	newServer()
	freshKeychain()
	local _, err = publish( { 'P_1.jpg' }, { slug = 'cars' } )
	has( err, 'Choose this collection' )
	eq( #server.portfolioStarts, 0 )
end )

test( 'publishing again sends nothing new; an edited photo replaces the old one', function()
	newServer()
	freshKeychain()
	local first = publish( { 'P_1.jpg' }, { slug = 'weddings' } )
	local oldId = first[ 1 ].recorded
	local again = publish( { 'P_1.jpg' }, { slug = 'weddings' }, { oldId } )
	eq( again[ 1 ].recorded, oldId, 'the same file became a new photo' )
	eq( server.removed, {}, 'the photo was removed while it is still the one published' )
	has( dialogs[ #dialogs ].body, '1 photo was already there' )

	-- Edited in Lightroom: other bytes. New first, then the old one goes.
	local edited = renderedFiles { 'P_1b.jpg' }
	local renditions = publish( { 'P_1b.jpg' }, { slug = 'weddings' }, { oldId } )
	ok( renditions[ 1 ].recorded ~= oldId )
	eq( server.removed, { oldId } )
	ok( server.assets[ renditions[ 1 ].recorded ].done, 'the new version was not finished before the old one went' )
	os.remove( edited[ 1 ].path )
end )

test( 'a photo over 25 MB is refused before anything is sent', function()
	newServer()
	freshKeychain()
	local Checks = require 'RawwersChecks'
	local saved = Checks.MAX_PORTFOLIO_BYTES
	Checks.MAX_PORTFOLIO_BYTES = 10
	local renditions = publish( { 'P_big.jpg' }, { slug = 'weddings' } )
	Checks.MAX_PORTFOLIO_BYTES = saved
	eq( #server.portfolioStarts, 0 )
	has( renditions[ 1 ].failures[ 1 ], 'Larger than 25 MB' )
	eq( dialogs[ #dialogs ].title, 'Some photos were not published' )
end )

test( 'removing photos from a collection removes them from the portfolio; one gone already counts as removed', function()
	newServer()
	freshKeychain()
	local renditions = publish( { 'P_1.jpg', 'P_2.jpg' }, { slug = 'weddings' } )
	local gone = {}
	local err = runAll( function()
		publisher.deletePhotosFromPublishedCollection( { rawwersServer = 'https://api.test' },
			{ renditions[ 1 ].recorded, 'pf-unknown' }, function( id ) gone[ #gone + 1 ] = id end )
	end )
	eq( err, nil )
	eq( gone, { renditions[ 1 ].recorded, 'pf-unknown' } )
	ok( server.assets[ renditions[ 1 ].recorded ].removed )
	ok( not server.assets[ renditions[ 2 ].recorded ].removed )
end )

test( 'a revoked device stops the publish and forgets the token', function()
	newServer()
	freshKeychain()
	local renditions = publish( { 'P_1.jpg' }, { slug = 'weddings' } )
	server.revoked = true
	local err = runAll( function()
		publisher.deletePhotosFromPublishedCollection( { rawwersServer = 'https://api.test' }, { renditions[ 1 ].recorded }, function() end )
	end )
	has( err, 'could not remove' )
	eq( keychain[ 'rawwers.delivery-token:https://api.test' ], '' )
end )

-- Niches from Lightroom (1.2.0) --------------------------------------------------------------------

--- A property table: observers fire on every assignment, as Lightroom's do.
local function properties( initial )
	local values, observers = initial or {}, {}
	local p = {}
	function p:addObserver( key, fn )
		observers[ key ] = observers[ key ] or {}
		observers[ key ][ #observers[ key ] + 1 ] = fn
	end
	return setmetatable( p, {
		__index = values,
		__newindex = function( _, key, value )
			values[ key ] = value
			for _, fn in ipairs( observers[ key ] or {} ) do fn( p, key, value ) end
		end,
	} )
end

local function connected()
	newServer()
	dialogs = {}
	keychain[ 'rawwers.delivery-token:https://api.test' ] = 'rwd_good'
end

test( 'with no niches the service says so and offers them; choosing one adds it as the main niche', function()
	connected()
	server.niches = {}
	local p = properties { rawwersServer = 'https://api.test', rawwersDefaultsApplied = true }
	runAll( function() publisher.startDialog( p ) end )
	eq( p.rawwersConnection, 'Connected. You have no niches yet. Choose one to add.' )
	eq( p.LR_cantExportBecause, nil )
	eq( p.rawwersCanAddNiche, true )
	eq( p.rawwersAddItems[ 1 ], { title = 'Add a niche...', value = '' } )
	eq( #p.rawwersAddItems, 5 )

	runAll( function() p.rawwersAddSlug = 'food' end )
	eq( server.added, { { slug = 'food' } } )
	eq( server.niches, { { slug = 'food', name = 'Food', primary = true } } )
	eq( p.rawwersNicheMessage, 'Added Food, your main niche.' )
	eq( p.rawwersConnection, 'Connected. Your niches: Food (main).' )
	eq( p.rawwersAddSlug, '' )
	eq( #p.rawwersAddItems, 4 )
end )

test( 'at the maximum the menu goes, and a refusal is shown in the server\'s words', function()
	connected()
	server.maximum = 2
	local p = properties { rawwersServer = 'https://api.test', rawwersDefaultsApplied = true }
	runAll( function() publisher.startDialog( p ) end )
	eq( p.rawwersCanAddNiche, false )
	eq( p.rawwersConnection, 'Connected. Your niches: Weddings (main), Portraits. That is the most you can have (2).' )
	-- (the server's answer when the limit is reached between two looks)
	runAll( function() p.rawwersAddSlug = 'food' end )
	eq( p.rawwersNicheMessage, 'You can have at most 2 niches, and you have 2.' )
	eq( #server.niches, 2 )
end )

local function collectionView( isDefault, slug )
	local settings = properties { rawwersNicheSlug = slug }
	local f = setmetatable( {}, { __index = function() return function( _, t ) return t end end } )
	local view
	runAll( function()
		view = publisher.viewForCollectionSettings( f, { rawwersServer = 'https://api.test' }, { collectionSettings = settings, isDefaultCollection = isDefault } )
	end )
	return settings, view
end

test( 'a collection\'s niche menu ends with "Add a niche...", which adds the chosen niche and selects it', function()
	connected()
	local settings = collectionView( false, nil )
	local add = require( 'RawwersPortfolio' ).ADD_NICHE
	eq( settings.rawwersNicheItems, { { title = 'Weddings (main)', value = 'weddings' }, { title = 'Portraits', value = 'portraits' }, { title = 'Add a niche...', value = add } } )
	eq( settings.LR_canSaveCollection, false )

	dialogs.choose = 'cars'
	runAll( function() settings.rawwersNicheSlug = add end )
	eq( dialogs[ 1 ].modal, 'Add a niche to your RAWWERS profile' )
	eq( server.added, { { slug = 'cars' } } )
	eq( settings.rawwersNicheSlug, 'cars' )
	eq( settings.LR_canSaveCollection, true )
	eq( settings.rawwersNicheNote, 'Added Automotive. The photos of this collection go there.' )
	-- three niches now: the menu has no "Add a niche..." any more
	eq( settings.rawwersNicheItems[ #settings.rawwersNicheItems ].value, 'portraits' )
end )

test( 'cancelling "Add a niche..." adds nothing and keeps the earlier choice', function()
	connected()
	local settings = collectionView( false, 'portraits' )
	dialogs.modal = 'cancel'
	runAll( function() settings.rawwersNicheSlug = require( 'RawwersPortfolio' ).ADD_NICHE end )
	eq( server.added, nil )
	eq( settings.rawwersNicheSlug, 'portraits' )
	eq( settings.LR_canSaveCollection, true )
end )

test( 'with no niches the default collection says how to add one', function()
	connected()
	server.niches = {}
	local settings = collectionView( true, nil )
	eq( settings.rawwersNicheItems, { { title = 'Add a niche...', value = require( 'RawwersPortfolio' ).ADD_NICHE } } )
	eq( settings.rawwersNicheNote, 'You have no niches yet. Choose "Add a niche..." to add one.' )
end )


-- The connection and Save (1.2.1) ------------------------------------------------------------------
-- 1.2.0 showed "Connected" while Save stayed blocked: the line and the Save
-- check came from two places. Every state below is checked against one rule:
-- Save is allowed exactly when the line says "Connected", and only then.

local function saveAllowed( p ) return p.LR_cantExportBecause == nil end

local function agrees( p )
	local says = type( p.rawwersConnection ) == 'string' and p.rawwersConnection:sub( 1, 10 ) == 'Connected.'
	eq( saveAllowed( p ), says )
	eq( p.rawwersConnected == true, says )
	if says then eq( p.rawwersNeedsCode, false ) end
end

--- The service dialog's sections, as the stub factory returns them.
local function sections( p )
	local f = setmetatable( {}, { __index = function() return function( _, t ) return t end end } )
	return publisher.sectionsForTopOfDialog( f, p )
end

local function find( tree, pred )
	if type( tree ) ~= 'table' then return nil end
	if pred( tree ) then return tree end
	for _, v in pairs( tree ) do
		if type( v ) == 'table' then
			local hit = find( v, pred )
			if hit then return hit end
		end
	end
end

local function button( p, title )
	return find( sections( p ), function( t ) return t.title == title and type( t.action ) == 'function' end )
end

local function press( p, title )
	local b = assert( button( p, title ), 'no button ' .. title )
	runAll( function() b.action() end )
end

test( 'the bug of 1.2.0: paired Mac, valid pairing, a new unsaved service, niches added: Save is allowed', function()
	connected()
	server.niches = {}
	-- A service never saved: only what Lightroom fills in.
	local p = properties { rawwersServer = 'https://api.test' }
	runAll( function() publisher.startDialog( p ) end )
	eq( p.rawwersConnection, 'Connected. You have no niches yet. Choose one to add.' )
	eq( saveAllowed( p ), true )
	eq( p.rawwersNeedsCode, false )
	agrees( p )
	runAll( function() p.rawwersAddSlug = 'food' end )
	eq( p.rawwersConnection, 'Connected. Your niches: Food (main).' )
	eq( saveAllowed( p ), true )
	agrees( p )
end )

test( 'editing a saved service on a paired Mac: Save is allowed with no new code', function()
	connected()
	local p = properties { rawwersServer = 'https://api.test', rawwersDefaultsApplied = true, rawwersDeviceName = 'Studio Mac' }
	runAll( function() publisher.startDialog( p ) end )
	eq( p.rawwersConnection, 'Connected. Your niches: Weddings (main), Portraits.' )
	eq( saveAllowed( p ), true )
	agrees( p )
end )

test( 'while the check is still running: not "Connected", and Save waits', function()
	connected()
	local p = properties { rawwersServer = 'https://api.test' }
	publisher.startDialog( p ) -- the check is queued, not run yet
	eq( p.rawwersConnection, 'Checking the connection to RAWWERS...' )
	eq( saveAllowed( p ), false )
	agrees( p )
	runAll( function() end )
	eq( saveAllowed( p ), true )
	agrees( p )
end )

test( 'first install, no pairing: the code row, Save blocked; a wrong code keeps it blocked; a good code allows Save', function()
	newServer()
	dialogs = {}
	keychain = {}
	local p = properties { rawwersServer = 'https://api.test' }
	runAll( function() publisher.startDialog( p ) end )
	has( p.rawwersConnection, 'Not connected. Type the pairing code' )
	eq( p.rawwersNeedsCode, true )
	eq( saveAllowed( p ), false )
	agrees( p )

	p.rawwersPairingCode = 'WRONG'
	press( p, 'Connect' )
	has( p.rawwersConnection, 'That code is wrong or has expired' )
	eq( p.rawwersNeedsCode, true )
	eq( saveAllowed( p ), false )
	agrees( p )

	p.rawwersPairingCode = 'GOOD-CODE'
	press( p, 'Connect' )
	eq( keychain[ 'rawwers.delivery-token:https://api.test' ], 'rwd_good' )
	eq( p.rawwersPairingCode, '' )
	eq( p.rawwersConnection, 'Connected. Your niches: Weddings (main), Portraits.' )
	eq( saveAllowed( p ), true )
	agrees( p )
end )

test( 'a pairing revoked on the server: "Not connected. Type a new pairing code", Save blocked, the dead token forgotten', function()
	connected()
	server.revoked = true
	local p = properties { rawwersServer = 'https://api.test' }
	runAll( function() publisher.startDialog( p ) end )
	has( p.rawwersConnection, 'Not connected. Type a new pairing code' )
	eq( p.rawwersNeedsCode, true )
	eq( saveAllowed( p ), false )
	eq( keychain[ 'rawwers.delivery-token:https://api.test' ], '' )
	agrees( p )
	-- after Connect with a fresh code, Save works
	p.rawwersPairingCode = 'GOOD-CODE'
	press( p, 'Connect' )
	eq( saveAllowed( p ), true )
	agrees( p )
end )

test( 'server unreachable: a clear message, Save blocked, never "Connected", the pairing kept; Check again connects', function()
	connected()
	server.down = true
	local p = properties { rawwersServer = 'https://api.test' }
	runAll( function() publisher.startDialog( p ) end )
	has( p.rawwersConnection, 'Could not check the connection to RAWWERS' )
	eq( p.rawwersCanRetry, true )
	eq( p.rawwersNeedsCode, false )
	eq( saveAllowed( p ), false )
	eq( keychain[ 'rawwers.delivery-token:https://api.test' ], 'rwd_good' )
	agrees( p )
	server.down = false
	press( p, 'Check again' )
	eq( p.rawwersCanRetry, false )
	eq( saveAllowed( p ), true )
	agrees( p )
end )

test( 'a plug-in the server calls too old: not "Connected", Save blocked', function()
	connected()
	server.minimum = '1.3.0'
	local p = properties { rawwersServer = 'https://api.test' }
	runAll( function() publisher.startDialog( p ) end )
	has( p.rawwersConnection, 'too old' )
	eq( saveAllowed( p ), false )
	agrees( p )
end )

test( 'revoked while adding a niche: the line and Save both go to not connected', function()
	connected()
	local p = properties { rawwersServer = 'https://api.test' }
	runAll( function() publisher.startDialog( p ) end )
	eq( saveAllowed( p ), true )
	server.revoked = true
	runAll( function() p.rawwersAddSlug = 'food' end )
	has( p.rawwersConnection, 'Not connected. Type a new pairing code' )
	eq( saveAllowed( p ), false )
	eq( p.rawwersCanAddNiche, false )
	agrees( p )
end )

test( 'a refused add (the maximum) changes neither the line nor Save', function()
	connected()
	server.maximum = 2
	local p = properties { rawwersServer = 'https://api.test' }
	runAll( function() publisher.startDialog( p ) end )
	runAll( function() p.rawwersAddSlug = 'food' end )
	eq( saveAllowed( p ), true )
	agrees( p )
end )

test( 'the code row and Check again follow the same state as Save', function()
	connected()
	local p = properties { rawwersServer = 'https://api.test' }
	local tree = sections( p )
	local codeRow = find( tree, function( t ) return t.visible and find( t, function( u ) return u.title == 'Pairing code:' end ) end )
	eq( codeRow.visible, { bound = 'rawwersNeedsCode' } )
	local retryRow = find( tree, function( t ) return t.visible and find( t, function( u ) return u.title == 'Check again' end ) end )
	eq( retryRow.visible, { bound = 'rawwersCanRetry' } )
end )

test( 'the plug-in has the same files as 1.2.0: Lightroom does not see a new file until restarted', function()
	-- 1.2.1 added RawwersConnection.lua; a Lightroom that was open could not
	-- load it ("Could not load toolkit script"). A new file needs a release
	-- note telling photographers to restart Lightroom; then add it here.
	local names = {}
	for name in io.popen( 'ls rawwers.lrdevplugin' ):lines() do names[ #names + 1 ] = name end
	eq( names, { 'Info.lua', 'RawwersApi.lua', 'RawwersChecks.lua', 'RawwersConfig.lua', 'RawwersJson.lua', 'RawwersLightroom.lua',
		'RawwersPipeline.lua', 'RawwersPortfolio.lua', 'RawwersPublishProvider.lua', 'RawwersRetry.lua', 'RawwersServiceProvider.lua',
		'RawwersSummary.lua', 'RawwersUpload.lua' } )
end )

os.exit( H.run() and 0 or 1 )
