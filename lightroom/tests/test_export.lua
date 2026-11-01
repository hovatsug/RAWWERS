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
	if headerValue( headers, 'Authorization' ) ~= 'Bearer ' .. server.token or server.revoked then
		return respond( 401, { error = { code = 'delivery_token_revoked', message = 'This device was disconnected. Connect Lightroom again with a new pairing code.' } } )
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
		server.assets[ id ] = { name = data.file_name, sha = data.sha256, size = data.byte_size, position = data.position }
		server.bySha[ data.sha256 ] = id
		return respond( 200, { media_asset_id = id, gallery_id = 'gal-1', duplicate = false, use_multipart = false,
			upload = { method = 'PUT', url = 'https://r2.test/' .. data.file_name, headers = { [ 'Content-Type' ] = 'image/jpeg' } } } )
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
	},
	LrErrors = { throwUserError = function( text ) error( 'USER: ' .. text, 0 ) end },
	LrDate = {
		currentTime = function() return 1000000 end,
		formatShortDate = function( t ) return 'date' .. t end,
		timeFromPosixDate = function( t ) return t end,
	},
	LrView = { bind = function( key ) return { bound = key } end },
	LrBinding = { negativeOfKey = function( key ) return { notKey = key } end },
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
	eq( info.LrExportServiceProvider.title, 'RAWWERS' )
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

os.exit( H.run() and 0 or 1 )
