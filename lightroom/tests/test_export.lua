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
		server.deliveryStarts = server.deliveryStarts or {}
		server.deliveryStarts[ #server.deliveryStarts + 1 ] = data
		local gallery = 'gal-' .. gig
		-- As the API (1.2.4): in this gig's gallery, the same Lightroom photo
		-- still waiting, or the same picture or file, is the same photo.
		local live = {}
		for id, asset in pairs( server.assets ) do if asset.gallery == gallery then live[ #live + 1 ] = id end end
		table.sort( live )
		local found
		for _, id in ipairs( live ) do
			local asset = server.assets[ id ]
			local keyed = data.delivery_key and asset.key == data.delivery_key
			if not found and ( ( keyed and not asset.done ) or asset.sha == data.sha256 or ( data.image_sha256 and asset.image == data.image_sha256 ) ) then found = id end
		end
		if found then
			local asset = server.assets[ found ]
			if asset.done then return respond( 200, { media_asset_id = found, gallery_id = gallery, duplicate = true } ) end
			asset.sha, asset.image = data.sha256, data.image_sha256 or asset.image
			return respond( 200, { media_asset_id = found, gallery_id = gallery, duplicate = false, use_multipart = false,
				upload = { method = 'PUT', url = 'https://r2.test/' .. data.file_name, headers = { [ 'Content-Type' ] = 'image/jpeg' } } } )
		end
		server.nextId = server.nextId + 1
		local id = 'asset-' .. server.nextId
		server.assets[ id ] = { name = data.file_name, sha = data.sha256, size = data.byte_size, position = data.position, exportId = data.export_id,
			gallery = gallery, key = data.delivery_key, image = data.image_sha256 }
		return respond( 200, { media_asset_id = id, gallery_id = gallery, duplicate = false, use_multipart = false,
			upload = { method = 'PUT', url = 'https://r2.test/' .. data.file_name, headers = { [ 'Content-Type' ] = 'image/jpeg' } } } )
	end
	local statusOf = path:match( '^/v1/delivery/galleries/([^/]+)/status$' )
	if statusOf and method == 'GET' then
		local processing = 0
		for _, asset in pairs( server.assets ) do if asset.gallery == statusOf and asset.done then processing = processing + 1 end end
		return respond( 200, { gallery_id = statusOf, photos_in_gallery = 0, processing = processing, uploading = 0, failed = {} } )
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
		local counts = {}
		for _, asset in pairs( server.assets ) do
			if asset.niche and asset.done and not asset.removed then counts[ asset.niche ] = ( counts[ asset.niche ] or 0 ) + 1 end
		end
		return respond( 200, { niches = server.niches, photo_count = 0, photo_minimum = 12, niche_photo_counts = counts } )
	end
	if path == '/v1/delivery/portfolio/uploads' and method == 'POST' then
		server.portfolioStarts[ #server.portfolioStarts + 1 ] = data
		-- As the API (lightroom_portfolio.existing_copy): the same Lightroom
		-- photo still waiting, or the same picture or file in this niche, is
		-- the same photo; the same Lightroom photo with another picture is
		-- an edit that replaces it.
		local live, keyed = {}, {}
		for id, asset in pairs( server.assets ) do
			if asset.niche == data.niche_slug and not asset.removed and not asset.failed then
				live[ #live + 1 ] = id
				if data.publish_key and asset.key == data.publish_key then keyed[ #keyed + 1 ] = id end
			end
		end
		table.sort( live ) table.sort( keyed )
		local function samePicture( asset )
			return asset.sha == data.sha256 or ( data.image_sha256 and asset.image == data.image_sha256 )
		end
		local found, replaces
		for _, id in ipairs( keyed ) do
			if not found and ( not server.assets[ id ].done or samePicture( server.assets[ id ] ) ) then found = id end
		end
		for _, id in ipairs( live ) do
			if not found and samePicture( server.assets[ id ] ) then found = id end
		end
		if not found then
			for _, id in ipairs( keyed ) do if server.assets[ id ].done then replaces = id end end
		end
		-- 1.2.4: the server removes the old version when the new one is
		-- finished, only the same Lightroom photo in this niche (or the one
		-- Lightroom names, from before keys), and keeps it if it is the cover.
		local old = data.previous_id and server.assets[ data.previous_id ]
		if old and not old.removed and old.niche == data.niche_slug and ( old.key == nil or old.key == data.publish_key ) then
			replaces = data.previous_id
		end
		if found then
			local asset = server.assets[ found ]
			if asset.done then return respond( 200, { media_asset_id = found, duplicate = true } ) end
			asset.sha, asset.image = data.sha256, data.image_sha256 or asset.image
			return respond( 200, { media_asset_id = found, duplicate = false, use_multipart = false,
				upload = { method = 'PUT', url = 'https://r2.test/' .. data.file_name, headers = { [ 'Content-Type' ] = 'image/jpeg' } } } )
		end
		server.nextId = server.nextId + 1
		local id = 'pf-' .. server.nextId
		server.assets[ id ] = { name = data.file_name, sha = data.sha256, size = data.byte_size, niche = data.niche_slug, key = data.publish_key, image = data.image_sha256, replaces = replaces }
		return respond( 200, { media_asset_id = id, duplicate = false, use_multipart = false, replaces = replaces,
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
		server.finishCalls = ( server.finishCalls or 0 ) + 1
		if ( server.finishFailures or 0 ) > 0 then
			-- The API rolls the whole finish back: the photo is still waiting.
			server.finishFailures = server.finishFailures - 1
			return respond( 500, { error = { code = 'internal_error', message = 'Internal server error' } } )
		end
		if asset.done and data.sha256 == asset.sha then return respond( 200, { ok = true, current_status = 'processing' } ) end
		if asset.replaces and data.sha256 == asset.sha then
			local old = server.assets[ asset.replaces ]
			asset.done = true
			if server.cover == asset.replaces then
				return respond( 200, { ok = true, current_status = 'processing', old_kept = 'The old version was kept in your portfolio: it is your profile cover.' } )
			end
			old.removed = true
			return respond( 200, { ok = true, current_status = 'processing', replaced = asset.replaces } )
		end
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
			return { update = function( _, s ) parts[ #parts + 1 ] = s end, digest = function()
				-- A stand-in hash of all the bytes (Lua 5.1 has no bit operators).
				local text, h1, h2 = table.concat( parts ), 7, 11
				for i = 1, #text do
					local b = text:byte( i )
					h1 = ( h1 * 31 + b ) % 4294967291
					h2 = ( h2 * 37 + b + i ) % 4294967279
				end
				return string.format( 'sha-%08x%08x', h1, h2 )
			end }
		end },
	},
	LrTasks = {
		startAsyncTask = function( fn ) tasks[ #tasks + 1 ] = coroutine.create( fn ) end,
		pcall = function( fn, ... ) return pcall( fn, ... ) end,
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

local renderCount = 0
--- A JPEG as Lightroom renders it: the export time in its EXIF (an APP1
--- segment) is new on every render; the picture is the same for the same
--- photo. Before 1.2.3 the stand-in renders were the same bytes every time,
--- so no test could see that a second publish sent a second photo.
local function lightroomJpeg( picture )
	renderCount = renderCount + 1
	local function segment( kind, body )
		local n = #body + 2
		return '\255' .. kind .. string.char( math.floor( n / 256 ), n % 256 ) .. body
	end
	return '\255\216' .. segment( '\225', 'Exif\0\0exported at render ' .. renderCount ) .. segment( '\219', 'quant' )
		.. '\255\218\0\8scan' .. 'pixels:' .. picture .. string.rep( '.', 100 ) .. '\255\217'
end

--- Rendered files for `names`. opts.lightroom: real-looking JPEG renders
--- (opts.pictures[i] the picture, default the name; opts.photoIds[i] the
--- Lightroom photo's uuid, default the name).
local function renderedFiles( names, opts )
	opts = opts or {}
	local renditions = {}
	for i, name in ipairs( names ) do
		local path = os.tmpname() .. '-' .. name
		local f = assert( io.open( path, 'wb' ) )
		if opts.lightroom then
			f:write( lightroomJpeg( opts.pictures and opts.pictures[ i ] or name ) )
		else
			f:write( 'JPEG:' .. name .. string.rep( '.', 100 ) )
		end
		f:close()
		local photoId = opts.photoIds and opts.photoIds[ i ] or name
		renditions[ #renditions + 1 ] = {
			path = path, failures = {},
			waitForRender = function( self ) return true, self.path end,
			uploadFailed = function( self, message ) self.failures[ #self.failures + 1 ] = message end,
			photo = {
				getFormattedMetadata = function() return name end,
				getRawMetadata = function( _, key ) if key == 'uuid' then return 'UUID-' .. photoId end end,
			},
		}
	end
	return renditions
end

local function export( names, props, opts )
	opts = opts or {}
	local renditions = renderedFiles( names, { lightroom = true, pictures = opts.pictures, photoIds = opts.photoIds } )
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
	eq( info.VERSION, { major = 1, minor = 2, revision = 4, build = 0 } )
	eq( require( 'RawwersConfig' ).version, '1.2.4' )
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
	has( summary.body, '3 photos are in the client\'s gallery: 3 new, 0 already there.' )
	has( summary.body, 'The gallery now has 3 photos (3 still processing).' )
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
	has( dialogs[ #dialogs ].body, '2 photos are in the client\'s gallery: 0 new, 2 already there.' )
	has( dialogs[ #dialogs ].body, 'The gallery now has 2 photos' )
end )

test( 'a photo that keeps failing is named, and the others still go', function()
	newServer()
	freshKeychain()
	server.failStorageFor[ 'IMG_2.jpg' ] = true
	local renditions = export { 'IMG_1.jpg', 'IMG_2.jpg', 'IMG_3.jpg' }
	local summary = dialogs[ #dialogs ]
	has( summary.title, '1 photo did not upload' )
	has( summary.body, '2 photos are in the client\'s gallery: 2 new, 0 already there.' )
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

local function publish( names, collection, previousIds, opts )
	opts = opts or {}
	local renditions = renderedFiles( names, { lightroom = true, pictures = opts.pictures, photoIds = opts.photoIds } )
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
		publishedCollection = { localIdentifier = collection and collection.id or 77, getCollectionInfoSummary = function()
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
	has( dialogs[ #dialogs ].body, '2 photos are in your RAWWERS portfolio (Portraits): 2 new, 0 already there.' )
	has( dialogs[ #dialogs ].body, 'Portraits now has 2 photos on RAWWERS.' )
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
	-- Rendered again: a new export time in the file, the same picture.
	local again = publish( { 'P_1.jpg' }, { slug = 'weddings' }, { oldId } )
	eq( again[ 1 ].recorded, oldId, 'the same photo became a new photo' )
	eq( server.removed, {}, 'the photo was removed while it is still the one published' )
	has( dialogs[ #dialogs ].body, '1 photo is in your RAWWERS portfolio (Weddings): 0 new, 1 already there.' )

	-- Edited in Lightroom: another picture. New first, then the old one goes.
	local renditions = publish( { 'P_1.jpg' }, { slug = 'weddings' }, { oldId }, { pictures = { 'P_1 edited' } } )
	ok( renditions[ 1 ].recorded ~= oldId )
	ok( server.assets[ oldId ].removed, 'the old version is still there' )
	eq( server.removed, {}, 'the plug-in removed it itself (1.2.4: the server does)' )
	eq( server.portfolioStarts[ #server.portfolioStarts ].previous_id, oldId )
	ok( server.assets[ renditions[ 1 ].recorded ].done, 'the new version was not finished before the old one went' )
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


-- Publishing again is safe (1.2.3) ---------------------------------------------------------------
-- The owner's case of 2026-11-16: 4 photos published; finishing 2 of them
-- failed on the server, the plug-in reported them as not published, and
-- publishing again made a second copy of each.

local function onServer()
	local n = 0
	for _, asset in pairs( server.assets ) do if asset.niche and not asset.removed then n = n + 1 end end
	return n
end

test( 'the owner\'s case: a finish that fails once is retried and the photo is published once', function()
	newServer()
	freshKeychain()
	server.finishFailures = 1
	local renditions = publish( { 'InaFoto-21.jpg', 'InaFoto-54.jpg', 'InaFoto-69.jpg', 'InaFoto-152.jpg' }, { slug = 'weddings' } )
	for _, r in ipairs( renditions ) do ok( r.recorded, r.photo:getFormattedMetadata() .. ' was left as new' ) end
	eq( onServer(), 4 )
	eq( dialogs[ #dialogs ].title, 'Published to RAWWERS' )
	has( dialogs[ #dialogs ].body, '4 photos are in your RAWWERS portfolio (Weddings): 4 new, 0 already there.' )
	has( dialogs[ #dialogs ].body, 'Weddings now has 4 photos on RAWWERS.' )
end )

test( 'a finish that keeps failing is said in plain words, left as new, and publishing again finishes it: one photo', function()
	newServer()
	freshKeychain()
	server.finishFailures = 99
	local first = publish( { 'InaFoto-21.jpg', 'InaFoto-69.jpg' }, { slug = 'weddings' } )
	eq( first[ 1 ].recorded, nil, 'a photo not finished on the server was marked published' )
	has( first[ 1 ].failures[ 1 ], 'it reached RAWWERS but could not be finished' )
	has( first[ 1 ].failures[ 1 ], 'Publish again: it will be finished there, not sent twice.' )
	ok( not first[ 1 ].failures[ 1 ]:find( 'current state' ) )
	has( dialogs[ #dialogs ].body, '2 photos not published:' )

	server.finishFailures = 0
	local again = publish( { 'InaFoto-21.jpg', 'InaFoto-69.jpg' }, { slug = 'weddings' } )
	for _, r in ipairs( again ) do ok( r.recorded, 'left as new although on the server' ) end
	eq( onServer(), 2, 'publishing again made another photo' )
	has( dialogs[ #dialogs ].body, '2 photos are in your RAWWERS portfolio (Weddings): 2 new, 0 already there.' )
end )

test( 'a photo the server has already is marked published, not left as new', function()
	newServer()
	freshKeychain()
	publish( { 'InaFoto-21.jpg' }, { slug = 'weddings' } )
	-- Lightroom lost the published state (a refused finish before 1.2.3, a crash):
	local again = publish( { 'InaFoto-21.jpg' }, { slug = 'weddings' } )
	ok( again[ 1 ].recorded, 'left under New Photos to Publish' )
	eq( onServer(), 1 )
	has( dialogs[ #dialogs ].body, '0 new, 1 already there.' )
	has( dialogs[ #dialogs ].body, 'Weddings now has 1 photo on RAWWERS.' )
end )

test( 'each publish sends the photo\'s key and its picture hash, the same on every render', function()
	newServer()
	freshKeychain()
	publish( { 'InaFoto-21.jpg' }, { slug = 'weddings', id = 12 } )
	publish( { 'InaFoto-21.jpg' }, { slug = 'weddings', id = 12 } )
	local a, b = server.portfolioStarts[ 1 ], server.portfolioStarts[ 2 ]
	eq( a.publish_key, 'lr:UUID-InaFoto-21.jpg:12' )
	eq( a.publish_key, b.publish_key )
	ok( a.sha256 ~= b.sha256, 'the renders should differ, as Lightroom\'s do' )
	ok( a.image_sha256 and a.image_sha256 == b.image_sha256, 'the picture hash changed with the export time' )
end )

test( 'the same photo in two niches is two photos; twice in one niche is one', function()
	newServer()
	freshKeychain()
	publish( { 'InaFoto-21.jpg' }, { slug = 'weddings', id = 1 } )
	publish( { 'InaFoto-21.jpg' }, { slug = 'portraits', id = 2 } )
	eq( onServer(), 2 )
	publish( { 'InaFoto-21.jpg' }, { slug = 'portraits', id = 2 } )
	eq( onServer(), 2 )
end )

test( 'an edit Lightroom lost track of: the server names the old version and it is removed', function()
	newServer()
	freshKeychain()
	local first = publish( { 'InaFoto-21.jpg' }, { slug = 'weddings' } )
	local edited = publish( { 'InaFoto-21.jpg' }, { slug = 'weddings' }, nil, { pictures = { 'InaFoto-21 edited' } } )
	ok( edited[ 1 ].recorded ~= first[ 1 ].recorded )
	ok( server.assets[ first[ 1 ].recorded ].removed )
	eq( server.removed, {} )
	eq( onServer(), 1 )
end )

-- Exporting again is safe (1.2.4) ------------------------------------------------------------------
-- Before 1.2.4 the stand-in renders were the same bytes each time, so
-- "exporting the same photos again skips them all" passed although a real
-- second export (a new export time in each file) doubled the gallery.

local function inGallery( gig )
	local n = 0
	for _, asset in pairs( server.assets ) do if asset.gallery == 'gal-' .. gig then n = n + 1 end end
	return n
end

test( 'an interrupted export run again sends only what is missing: each photo once in the gallery', function()
	newServer()
	freshKeychain()
	server.failStorageFor[ 'IMG_3.jpg' ] = true
	export { 'IMG_1.jpg', 'IMG_2.jpg', 'IMG_3.jpg' }
	eq( inGallery( 'gig-1' ), 3 ) -- IMG_3 started, never finished
	server.failStorageFor = {}
	local again = export { 'IMG_1.jpg', 'IMG_2.jpg', 'IMG_3.jpg' }
	eq( inGallery( 'gig-1' ), 3, 'the gallery got a second copy' )
	for _, r in ipairs( again ) do eq( r.failures, {}, 'a photo the gallery has was reported as failed' ) end
	for _, asset in pairs( server.assets ) do ok( asset.done, asset.name .. ' was left unfinished' ) end
	has( dialogs[ #dialogs ].body, '3 photos are in the client\'s gallery: 1 new, 2 already there.' )
	has( dialogs[ #dialogs ].body, 'The gallery now has 3 photos' )
end )

test( 'each export sends the photo\'s key with its gig, and the picture hash, the same on every render', function()
	newServer()
	freshKeychain()
	export { 'IMG_1.jpg' }
	export { 'IMG_1.jpg' }
	local a, b = server.deliveryStarts[ 1 ], server.deliveryStarts[ 2 ]
	eq( a.delivery_key, 'lr:UUID-IMG_1.jpg:gig:gig-1' )
	eq( a.delivery_key, b.delivery_key )
	ok( a.sha256 ~= b.sha256 )
	ok( a.image_sha256 and a.image_sha256 == b.image_sha256 )
end )

test( 'the same photo delivered to two gigs is in both galleries', function()
	newServer()
	freshKeychain()
	export { 'IMG_1.jpg' }
	export( { 'IMG_1.jpg' }, { rawwersServer = 'https://api.test', rawwersGigId = 'gig-2', rawwersGigLabel = 'Bea', rawwersGigChosenAt = 1000000 - 60 } )
	eq( inGallery( 'gig-1' ), 1 )
	eq( inGallery( 'gig-2' ), 1 )
	eq( server.deliveryStarts[ 2 ].delivery_key, 'lr:UUID-IMG_1.jpg:gig:gig-2' )
end )

test( 'a cover kept as the old version is said in plain words', function()
	newServer()
	freshKeychain()
	local first = publish( { 'P_1.jpg' }, { slug = 'weddings' } )
	server.cover = first[ 1 ].recorded
	publish( { 'P_1.jpg' }, { slug = 'weddings' }, { first[ 1 ].recorded }, { pictures = { 'P_1 edited' } } )
	ok( not server.assets[ first[ 1 ].recorded ].removed )
	has( dialogs[ #dialogs ].body, 'P_1.jpg: The old version was kept in your portfolio: it is your profile cover.' )
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
