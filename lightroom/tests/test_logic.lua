-- The plug-in's logic, with plain Lua 5.1 and no Lightroom: JSON, the retry
-- rules, the requests built and answers read, one photo's upload (skip,
-- resume, retry, refusal), several at once, the file checks and the summary.
--
--   lua5.1 tests/test_logic.lua        (run.sh runs it in a container)

package.path = './rawwers.lrdevplugin/?.lua;./tests/?.lua;' .. package.path

local H = require 'harness'
local Json = require 'RawwersJson'
local Retry = require 'RawwersRetry'
local Api = require 'RawwersApi'
local Upload = require 'RawwersUpload'
local Pipeline = require 'RawwersPipeline'
local Checks = require 'RawwersChecks'
local Summary = require 'RawwersSummary'
local test, eq, ok, has = H.test, H.eq, H.ok, H.has

-- JSON -------------------------------------------------------------------------

test( 'JSON round-trips what the API sends', function()
	local text = '{"items":[{"gig_id":"g1","included_photos":20,"gallery_id":null,"duplicate":false,"x":1.5}],"n":-3}'
	local v = Json.decode( text )
	eq( v.items[ 1 ].gig_id, 'g1' )
	eq( v.items[ 1 ].included_photos, 20 )
	eq( v.items[ 1 ].gallery_id, nil, 'null is absent' )
	eq( v.items[ 1 ].duplicate, false )
	eq( v.items[ 1 ].x, 1.5 )
	eq( v.n, -3 )
	eq( Json.decode( Json.encode( v ) ), v )
end )

test( 'JSON strings keep escapes and non-ASCII names', function()
	eq( Json.decode( '"Ana\\u00ef \\"Q\\" \\n\\ud83d\\udcf7"' ), 'Ana\195\175 "Q" \n\240\159\147\183' )
	eq( Json.encode( 'tab\there "q" \\ \n' ), '"tab\\there \\"q\\" \\\\ \\n"' )
	eq( Json.encode( { part_numbers = { 1, 2, 3 } } ), '{"part_numbers":[1,2,3]}' )
	eq( Json.encode( {} ), '{}' )
	eq( Json.encode( Json.emptyArray ), '[]' )
end )

test( 'JSON that is not JSON is nil with a reason, never an error', function()
	for _, bad in ipairs { '', '{', '[1,', '{"a" 1}', 'nul', '<html>502</html>', '{"a":1} x' } do
		local v, why = Json.decode( bad )
		eq( v, nil, bad )
		ok( type( why ) == 'string', 'a reason for ' .. bad )
	end
	eq( Json.decode( nil ), nil )
end )

-- Retry --------------------------------------------------------------------------

test( 'only network errors and 5xx are retried; 401 asks to connect again', function()
	eq( Retry.classify( 200 ), 'ok' )
	eq( Retry.classify( 204 ), 'ok' )
	eq( Retry.classify( 500 ), 'retry' )
	eq( Retry.classify( 503 ), 'retry' )
	eq( Retry.classify( nil, 'timedOut' ), 'retry' )
	eq( Retry.classify( nil, 'networkConnectionLost' ), 'retry' )
	eq( Retry.classify( nil, 'cancelled' ), 'cancelled' )
	eq( Retry.classify( 401 ), 'reauth' )
	for _, status in ipairs { 400, 403, 404, 409, 413, 422, 429 } do
		eq( Retry.classify( status ), 'refused', 'never retried: ' .. status )
	end
end )

test( 'retries wait longer each time and stop after the last delay', function()
	local slept, tries = {}, 0
	local outcome = Retry.run( function() tries = tries + 1 return 'retry' end, function( s ) slept[ #slept + 1 ] = s end, nil, { 1, 2, 4 } )
	eq( outcome, 'retry' )
	eq( tries, 4 )
	eq( slept, { 1, 2, 4 } )
end )

test( 'a refusal is never tried twice', function()
	local tries = 0
	Retry.run( function() tries = tries + 1 return 'refused' end, function() error( 'slept after a refusal' ) end )
	eq( tries, 1 )
end )

test( 'cancelling stops between tries', function()
	local tries = 0
	Retry.run( function() tries = tries + 1 return 'retry' end, function() end, function() return true end, { 1, 1, 1 } )
	eq( tries, 1 )
end )

test( 'the default delays come to about a minute', function()
	local total = 0
	for _, d in ipairs( Retry.delays ) do total = total + d end
	ok( total >= 30 and total <= 90, 'total ' .. total )
end )

-- The API client ------------------------------------------------------------------

--- An LrHttp stand-in answering from a script: each call takes the next
--- answer, { status, body, headers } or { error = 'timedOut' }.
local function fakeHttp( answers )
	local calls = {}
	local function http( method, url, headers, body, size )
		calls[ #calls + 1 ] = { method = method, url = url, headers = headers, body = body, size = size }
		local a = table.remove( answers, 1 ) or { status = 500 }
		if a.error then return nil, { error = { errorCode = a.error, name = a.error } } end
		local h = { status = a.status }
		for field, value in pairs( a.headers or {} ) do h[ #h + 1 ] = { field = field, value = value } end
		return a.body or '', h
	end
	return http, calls
end

local function api( answers, token )
	local http, calls = fakeHttp( answers )
	local slept = {}
	local client = Api.new { base_url = 'https://api.rawwers.test/', plugin_version = '1.0.0', http = http, sleep = function( s ) slept[ #slept + 1 ] = s end, token = token, delays = { 1, 2 } }
	return client, calls, slept
end

local function headerOf( call, name ) return Api.header( call.headers, name ) end

test( 'only https, or this Mac and the local network, may receive the token', function()
	ok( Api.isSafeBaseUrl( 'https://api.rawwers.com' ) )
	ok( Api.isSafeBaseUrl( 'http://localhost:8000' ) )
	ok( Api.isSafeBaseUrl( 'http://127.0.0.1:8000' ) )
	ok( Api.isSafeBaseUrl( 'http://studio-mac.local:8000' ) )
	ok( not Api.isSafeBaseUrl( 'http://api.rawwers.com' ) )
	ok( not Api.isSafeBaseUrl( 'ftp://x' ) )
	ok( not pcall( Api.new, { base_url = 'http://example.com', http = function() end } ), 'refused at construction' )
end )

test( 'requests carry the token, the plug-in version and a JSON body', function()
	local client, calls = api( { { status = 200, body = '{"ok":true}' } }, 'rwd_secret' )
	local r = client:startUpload( 'gig-1', { name = 'IMG_1.jpg', size = 123, sha256 = 'ab' } )
	ok( r.ok )
	local call = calls[ 1 ]
	eq( call.method, 'POST' )
	eq( call.url, 'https://api.rawwers.test/v1/delivery/gigs/gig-1/uploads' )
	eq( headerOf( call, 'Authorization' ), 'Bearer rwd_secret' )
	eq( headerOf( call, 'X-Rawwers-Plugin-Version' ), '1.0.0' )
	eq( headerOf( call, 'Content-Type' ), 'application/json' )
	eq( Json.decode( call.body ), { file_name = 'IMG_1.jpg', content_type = 'image/jpeg', byte_size = 123, sha256 = 'ab' } )
	eq( call.size, #call.body )
end )

test( 'pairing sends no token, only the code, the name and the version', function()
	local client, calls = api( { { status = 200, body = '{"token":"rwd_x","photographer_name":"Alex"}' } } )
	local r = client:pair( 'ABCD-EFGH', 'Studio Mac' )
	eq( r.data.photographer_name, 'Alex' )
	eq( headerOf( calls[ 1 ], 'Authorization' ), nil )
	eq( Json.decode( calls[ 1 ].body ), { code = 'ABCD-EFGH', device_name = 'Studio Mac', plugin_version = '1.0.0' } )
end )

test( 'a refusal is shown in the server\'s own words and not repeated', function()
	local client, calls, slept = api( { { status = 409, body = '{"error":{"code":"gallery_sent","message":"These photos were already sent to the client."}}' } }, 'rwd_t' )
	local r = client:startUpload( 'g', { name = 'a.jpg', size = 1, sha256 = 's' } )
	eq( r.ok, false )
	eq( r.outcome, 'refused' )
	eq( r.message, 'These photos were already sent to the client.' )
	eq( r.code, 'gallery_sent' )
	eq( #calls, 1 )
	eq( slept, {} )
end )

test( 'a 5xx or a dropped connection is retried, then succeeds', function()
	local client, calls, slept = api( { { status = 502, body = '<html>' }, { error = 'networkConnectionLost' }, { status = 200, body = '{"items":[]}' } }, 'rwd_t' )
	local r = client:gigs()
	ok( r.ok )
	eq( #calls, 3 )
	eq( slept, { 1, 2 } )
end )

test( 'a connection that never comes back says so, after a bounded number of tries', function()
	local client, calls = api( { { error = 'cannotConnectToHost' }, { error = 'cannotConnectToHost' }, { error = 'cannotConnectToHost' }, { status = 200 } }, 'rwd_t' )
	local r = client:me()
	eq( r.ok, false )
	eq( #calls, 3, 'one try plus two retries, then it stops' )
	has( r.message, 'Could not reach RAWWERS' )
end )

test( 'a revoked or expired device is told to connect again, without retrying', function()
	local client, calls = api( { { status = 401, body = '{"error":{"code":"delivery_token_revoked","message":"This device was disconnected."}}' } }, 'rwd_t' )
	local r = client:gigs()
	eq( r.outcome, 'reauth' )
	eq( r.code, 'delivery_token_revoked' )
	eq( #calls, 1 )
end )

test( 'the server saying a newer plug-in exists is noticed', function()
	local client = api( { { status = 200, body = '{}', headers = { [ 'X-Rawwers-Update-Available' ] = 'true' } } }, 'rwd_t' )
	eq( client.update_available, false )
	client:me()
	eq( client.update_available, true )
end )

test( 'storage gets the bytes, its own headers, and never the token', function()
	local client, calls = api( { { status = 200, headers = { ETag = '"e1"' } } }, 'rwd_secret' )
	local r = client:putToStorage( 'https://r2.test/obj?sig=1', { [ 'Content-Type' ] = 'image/jpeg' }, 'JPEGBYTES' )
	ok( r.ok )
	eq( r.etag, '"e1"' )
	local call = calls[ 1 ]
	eq( call.method, 'PUT' )
	eq( call.body, 'JPEGBYTES' )
	eq( call.size, 9 )
	eq( headerOf( call, 'Authorization' ), nil, 'the token went to storage' )
	eq( headerOf( call, 'X-Rawwers-Plugin-Version' ), nil )
	eq( headerOf( call, 'Content-Type' ), 'image/jpeg' )
end )

test( 'a part with no content type tells LrHttp to add none', function()
	local client, calls = api( { { status = 200 } }, 'rwd_t' )
	client:putToStorage( 'https://r2.test/part', {}, 'x' )
	eq( headerOf( calls[ 1 ], 'Content-Type' ), 'skip' )
end )

test( 'an expired storage URL is reported as such, not retried', function()
	local client, calls = api( { { status = 403, body = 'SignatureDoesNotMatch' } }, 'rwd_t' )
	local r = client:putToStorage( 'https://r2.test/obj', {}, 'x' )
	eq( r.ok, false )
	eq( r.expired, true )
	eq( #calls, 1 )
end )

-- One photo --------------------------------------------------------------------

--- A stand-in for RawwersApi recording what was asked of it.
local function fakeApi( script )
	local log = {}
	local self = { log = log, update_available = false }
	local function step( name, ... )
		log[ #log + 1 ] = { name, ... }
		local handler = script[ name ]
		if type( handler ) == 'function' then return handler( ... ) end
		if type( handler ) == 'table' and handler[ 1 ] then return table.remove( handler, 1 ) end
		return handler or { ok = true, data = {} }
	end
	for _, name in ipairs { 'startUpload', 'freshUploadUrl', 'startParts', 'partsReceived', 'partUrls', 'assembleParts', 'finish', 'putToStorage' } do
		self[ name ] = function( _, ... ) return step( name, ... ) end
	end
	return self
end

local function names( log )
	local out = {}
	for _, entry in ipairs( log ) do out[ #out + 1 ] = entry[ 1 ] end
	return out
end

local function file( size, name )
	local bytes = string.rep( 'x', size )
	local reads = {}
	return {
		name = name or 'IMG_0412.jpg', size = size, sha256 = 'aa', reads = reads,
		readAll = function() reads[ #reads + 1 ] = 'all' return bytes end,
		readRange = function( offset, length ) reads[ #reads + 1 ] = { offset, length } return bytes:sub( offset + 1, offset + length ) end,
	}
end

test( 'a file already in the gallery is skipped: nothing is sent', function()
	local a = fakeApi { startUpload = { ok = true, data = { duplicate = true, media_asset_id = 'm1', gallery_id = 'gal' } } }
	local f = file( 10 )
	local r = Upload.deliver( a, 'gig', f )
	eq( r.state, 'skipped' )
	eq( names( a.log ), { 'startUpload' } )
	eq( f.reads, {}, 'the file was read for nothing' )
end )

test( 'a small file goes in one PUT, then is finished with its size and hash', function()
	local a = fakeApi { startUpload = { ok = true, data = { media_asset_id = 'm1', gallery_id = 'gal', upload = { url = 'https://r2/1', headers = { [ 'Content-Type' ] = 'image/jpeg' } } } } }
	local r = Upload.deliver( a, 'gig', file( 10 ) )
	eq( r.state, 'uploaded' )
	eq( r.gallery_id, 'gal' )
	eq( names( a.log ), { 'startUpload', 'putToStorage', 'finish' } )
	eq( a.log[ 3 ], { 'finish', 'm1', 10, 'aa' } )
end )

test( 'an expired upload URL is replaced once, and the upload carries on', function()
	local a = fakeApi {
		startUpload = { ok = true, data = { media_asset_id = 'm1', upload = { url = 'https://r2/old', headers = {} } } },
		putToStorage = { { ok = false, expired = true, message = 'expired' }, { ok = true } },
		freshUploadUrl = { ok = true, data = { url = 'https://r2/new', headers = {} } },
	}
	local r = Upload.deliver( a, 'gig', file( 10 ) )
	eq( r.state, 'uploaded' )
	eq( names( a.log ), { 'startUpload', 'putToStorage', 'freshUploadUrl', 'putToStorage', 'finish' } )
	eq( a.log[ 4 ][ 2 ], 'https://r2/new' )
end )

test( 'a large file goes in parts, skipping the parts storage already has', function()
	local a = fakeApi {
		startUpload = { ok = true, data = { media_asset_id = 'm1', use_multipart = true } },
		startParts = { ok = true, data = { part_size = 4, part_count = 3 } },
		partsReceived = { ok = true, data = { parts = { { part_number = 1, size = 4 } } } },
		partUrls = function( _, numbers )
			local parts = {}
			for _, n in ipairs( numbers ) do parts[ #parts + 1 ] = { part_number = n, url = 'https://r2/p' .. n } end
			return { ok = true, data = { parts = parts } }
		end,
	}
	local f = file( 10 )
	local r = Upload.deliver( a, 'gig', f )
	eq( r.state, 'uploaded' )
	eq( names( a.log ), { 'startUpload', 'startParts', 'partsReceived', 'partUrls', 'putToStorage', 'putToStorage', 'assembleParts', 'finish' } )
	eq( a.log[ 4 ][ 3 ], { 2, 3 }, 'only the missing parts' )
	eq( f.reads, { { 4, 4 }, { 8, 2 } }, 'each part read from its own offset, the last one short' )
end )

test( 'part URLs are asked for in batches', function()
	Upload.PART_URL_BATCH = 2
	local asked = {}
	local a = fakeApi {
		startUpload = { ok = true, data = { media_asset_id = 'm1', use_multipart = true } },
		startParts = { ok = true, data = { part_size = 1, part_count = 5 } },
		partsReceived = { ok = true, data = { parts = {} } },
		partUrls = function( _, numbers )
			asked[ #asked + 1 ] = numbers
			local parts = {}
			for _, n in ipairs( numbers ) do parts[ #parts + 1 ] = { part_number = n, url = 'u' .. n } end
			return { ok = true, data = { parts = parts } }
		end,
	}
	eq( Upload.deliver( a, 'gig', file( 5 ) ).state, 'uploaded' )
	eq( asked, { { 1, 2 }, { 3, 4 }, { 5 } } )
	Upload.PART_URL_BATCH = 20
end )

test( 'a refused start fails the photo with the server\'s words; nothing is sent', function()
	local a = fakeApi { startUpload = { ok = false, outcome = 'refused', message = 'IMG_0412.jpg is larger than 50 MB.' } }
	local r = Upload.deliver( a, 'gig', file( 10 ) )
	eq( r.state, 'failed' )
	eq( r.message, 'IMG_0412.jpg is larger than 50 MB.' )
	eq( names( a.log ), { 'startUpload' } )
end )

test( 'a storage failure fails the photo and does not finish it', function()
	local a = fakeApi {
		startUpload = { ok = true, data = { media_asset_id = 'm1', upload = { url = 'u', headers = {} } } },
		putToStorage = { { ok = false, outcome = 'retry', message = 'Could not reach RAWWERS.' } },
	}
	local r = Upload.deliver( a, 'gig', file( 10 ) )
	eq( r.state, 'failed' )
	eq( names( a.log ), { 'startUpload', 'putToStorage' } )
end )

test( 'a revoked device mid-photo is "connect again", not a failure', function()
	local a = fakeApi { startUpload = { ok = false, outcome = 'reauth', message = 'This device was disconnected.' } }
	eq( Upload.deliver( a, 'gig', file( 10 ) ).state, 'reauth' )
end )

test( 'a file that changed size since it was hashed is not sent', function()
	local a = fakeApi { startUpload = { ok = true, data = { media_asset_id = 'm1', upload = { url = 'u', headers = {} } } } }
	local f = file( 10 )
	f.size = 11
	local r = Upload.deliver( a, 'gig', f )
	eq( r.state, 'failed' )
	eq( names( a.log ), { 'startUpload' } )
end )

-- Several at once ----------------------------------------------------------------

--- A cooperative scheduler like LrTasks: spawned functions are coroutines,
--- sleep yields, and run() resumes them in turn until all have finished.
local function scheduler()
	local tasks = {}
	local s = {}
	function s.spawn( fn ) tasks[ #tasks + 1 ] = coroutine.create( fn ) end
	function s.sleep() coroutine.yield() end
	function s.run( main )
		local mainTask = coroutine.create( main )
		local all = { mainTask }
		repeat
			local alive = false
			for _, list in ipairs { all, tasks } do
				for _, co in ipairs( list ) do
					if coroutine.status( co ) == 'suspended' then
						alive = true
						local okResume, err = coroutine.resume( co )
						if not okResume then error( err ) end
					end
				end
			end
		until not alive
	end
	return s
end

test( 'every photo is uploaded once, and no more than the workers at a time', function()
	local s = scheduler()
	local inFlight, most, seen = 0, 0, {}
	local p = Pipeline.new {
		workers = 3, spawn = s.spawn, sleep = s.sleep,
		process = function( job )
			inFlight = inFlight + 1
			most = math.max( most, inFlight )
			s.sleep()
			s.sleep()
			inFlight = inFlight - 1
			seen[ #seen + 1 ] = job.n
			return { state = 'uploaded', name = 'f' .. job.n }
		end,
	}
	local results
	s.run( function()
		p:start()
		for n = 1, 10 do p:add { n = n } end
		results = p:finish()
	end )
	eq( #results, 10 )
	table.sort( seen )
	eq( seen, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 } )
	eq( most, 3 )
end )

test( 'rendering waits while the window is full', function()
	local s = scheduler()
	local maxPending = 0
	local p
	p = Pipeline.new {
		workers = 2, window = 2, spawn = s.spawn, sleep = s.sleep,
		process = function() s.sleep() s.sleep() s.sleep() return { state = 'uploaded' } end,
	}
	s.run( function()
		p:start()
		for n = 1, 8 do
			p:add { n = n }
			maxPending = math.max( maxPending, p:pending() )
		end
		p:finish()
	end )
	ok( maxPending <= 2, 'pending reached ' .. maxPending )
end )

test( 'a revoked device stops the rest: no photo starts after "connect again"', function()
	local s = scheduler()
	local started = 0
	local p = Pipeline.new {
		workers = 1, spawn = s.spawn, sleep = s.sleep,
		process = function( job )
			started = started + 1
			return { state = job.n == 2 and 'reauth' or 'uploaded' }
		end,
	}
	local reason, accepted = nil, 0
	s.run( function()
		p:start()
		for n = 1, 6 do if p:add { n = n } then accepted = accepted + 1 end end
		local _, why = p:finish()
		reason = why
	end )
	eq( reason, 'reauth' )
	eq( started, 2 )
	ok( accepted < 6, 'kept accepting photos after the refusal' )
end )

test( 'cancelling stops new photos; the ones started finish', function()
	local s = scheduler()
	local canceled, started, finished = false, 0, 0
	local p = Pipeline.new {
		workers = 2, spawn = s.spawn, sleep = s.sleep, isCanceled = function() return canceled end,
		process = function()
			started = started + 1
			if started == 2 then canceled = true end
			s.sleep()
			finished = finished + 1
			return { state = 'uploaded' }
		end,
	}
	local reason
	s.run( function()
		p:start()
		for n = 1, 10 do if not p:add { n = n } then break end end
		local _, why = p:finish()
		reason = why
	end )
	eq( reason, 'cancelled' )
	eq( started, finished, 'a photo was abandoned mid-upload' )
	ok( started < 10 )
end )

-- The file -------------------------------------------------------------------------

local function jpegHeader( width, height, marker )
	local function u16( n ) return string.char( math.floor( n / 256 ), n % 256 ) end
	local app0 = '\255\224' .. u16( 16 ) .. 'JFIF\0' .. string.rep( '\0', 9 )
	local exif = '\255\225' .. u16( 2 + 200 ) .. string.rep( 'e', 200 )
	local sof = '\255' .. string.char( marker or 0xC0 ) .. u16( 17 ) .. '\8' .. u16( height ) .. u16( width ) .. '\3' .. string.rep( '\1', 9 )
	return '\255\216' .. app0 .. exif .. sof .. '\255\218' .. u16( 12 ) .. string.rep( '\0', 10 )
end

test( 'the long edge is read from the JPEG itself, baseline or progressive', function()
	eq( { Checks.jpegSize( jpegHeader( 6000, 4000 ) ) }, { 6000, 4000 } )
	eq( { Checks.jpegSize( jpegHeader( 1600, 2400, 0xC2 ) ) }, { 1600, 2400 } )
	eq( Checks.jpegSize( 'not a jpeg' ), nil )
	eq( Checks.jpegSize( '\255\216\255\218' ), nil )
end )

test( 'under 2048 px on the long edge is a warning; over 50 MB a refusal', function()
	eq( Checks.problem( 5000000, 2047, 1365 ), 'small' )
	eq( Checks.problem( 5000000, 1365, 2048 ), nil )
	eq( Checks.problem( 50000001, 6000, 4000 ), 'too_large' )
	eq( Checks.problem( 50000000, 6000, 4000 ), nil )
	eq( Checks.problem( 1000, nil, nil ), nil, 'unknown size is not a problem' )
end )

test( 'the suggested preset keeps copyright and contact and drops the location', function()
	has( Checks.suggestedPreset, 'Remove Location Info' )
	has( Checks.suggestedPreset, 'copyright and contact' )
	has( Checks.suggestedPreset, '2048' )
end )

-- The summary ------------------------------------------------------------------------

test( 'the summary counts uploaded, skipped and failed, and names each failure', function()
	local title, body, counts = Summary.build( {
		{ state = 'uploaded', name = 'a.jpg' },
		{ state = 'uploaded', name = 'b.jpg' },
		{ state = 'skipped', name = 'c.jpg' },
		{ state = 'failed', name = 'd.jpg', message = 'Larger than 50 MB.' },
	}, { small = { 'e.jpg' } } )
	eq( counts.uploaded, 2 )
	has( title, '1 photo did not upload' )
	has( body, '2 photos uploaded' )
	has( body, '1 skipped, already in the gallery' )
	has( body, '1 failed' )
	has( body, 'd.jpg: Larger than 50 MB.' )
	has( body, 'Export the same photos again' )
	has( body, 'e.jpg' )
	has( body, 'until you send the gallery from the RAWWERS Pro app' )
end )

test( 'all uploaded reads as done', function()
	local title, body = Summary.build( { { state = 'uploaded', name = 'a.jpg' } } )
	eq( title, 'RAWWERS: delivery uploaded' )
	has( body, '1 photo uploaded' )
end )

test( 'a revoked device ends with how to connect again', function()
	local title, body = Summary.build( { { state = 'reauth', name = 'a.jpg' } }, { notSent = 3 }, 'reauth' )
	eq( title, 'RAWWERS: connect again' )
	has( body, 'Settings > Connect Lightroom' )
	has( body, '3 photos were not sent' )
end )

test( 'a picker row: name, date, package, included and state', function()
	local date = function( epoch ) return 'D' .. epoch end
	eq( Summary.gigLabel( { client_name = 'Ana S.', shoot_starts_at_epoch = 7, package_title = 'Portraits Starter', included_photos = 20, delivery_state = 'waiting_for_photos' }, date ),
		'Ana S. · D7 · Portraits Starter · 20 included · Waiting for photos' )
	eq( Summary.gigLabel( { client_name = 'Ana S.', niche_name = 'Weddings', included_photos = 300, delivery_state = 'in_progress', photos_in_gallery = 30 }, date ),
		'Ana S. · Weddings · 300 included · In progress, 30 uploaded' )
end )

os.exit( H.run() and 0 or 1 )
