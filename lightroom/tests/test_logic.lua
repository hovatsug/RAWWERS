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
	eq( Retry.classify( 426 ), 'outdated' )
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
	for _, name in ipairs { 'startUpload', 'startPortfolioUpload', 'removePortfolioPhoto', 'freshUploadUrl', 'startParts', 'partsReceived', 'partUrls', 'assembleParts', 'finish', 'putToStorage', 'addNiche' } do
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

test( 'a plug-in the server no longer supports is "update", not a failure', function()
	local a = fakeApi { startUpload = { ok = false, outcome = 'outdated', message = 'This RAWWERS plug-in (1.0.0) is too old.' } }
	local r = Upload.deliver( a, 'gig', file( 10 ) )
	eq( r.state, 'outdated' )
	eq( r.message, 'This RAWWERS plug-in (1.0.0) is too old.' )
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
	has( body, '3 photos are in the client\'s gallery: 2 new, 1 already there.' )
	has( body, '1 failed' )
	has( body, 'd.jpg: Larger than 50 MB.' )
	has( body, 'Export the same photos again' )
	has( body, 'e.jpg' )
	has( body, 'until you send the gallery from the RAWWERS Pro app' )
end )

test( 'all uploaded reads as done', function()
	local title, body = Summary.build( { { state = 'uploaded', name = 'a.jpg' } } )
	eq( title, 'RAWWERS: delivery uploaded' )
	has( body, '1 photo is in the client\'s gallery: 1 new, 0 already there.' )
	local _, withTotal = Summary.build( { { state = 'skipped', name = 'a.jpg' } }, nil, nil, { in_gallery = 4, processing = 2 } )
	has( withTotal, 'The gallery now has 6 photos (2 still processing).' )
end )

test( 'a plug-in too old stops the rest too', function()
	local s = scheduler()
	local started = 0
	local p = Pipeline.new {
		workers = 1, spawn = s.spawn, sleep = s.sleep,
		process = function( job )
			started = started + 1
			return { state = job.n == 1 and 'outdated' or 'uploaded' }
		end,
	}
	local reason
	s.run( function()
		p:start()
		for n = 1, 6 do p:add { n = n } end
		local _, why = p:finish()
		reason = why
	end )
	eq( reason, 'outdated' )
	eq( started, 1 )
end )

test( 'a plug-in too old ends with where to get the new one, and nothing lost', function()
	local title, body = Summary.build(
		{ { state = 'outdated', name = 'a.jpg', message = 'This RAWWERS plug-in (1.0.0) is too old. Download version 2.0.0.' } },
		{ notSent = 3 }, 'outdated' )
	eq( title, 'RAWWERS: update the plug-in' )
	has( body, 'This RAWWERS plug-in (1.0.0) is too old. Download version 2.0.0.' )
	has( body, 'Settings > Connect Lightroom' )
	has( body, 'already uploaded are skipped' )
	ok( not body:find( '1 failed', 1, true ), 'counted as a failure' )
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

-- The portfolio ------------------------------------------------------------------------------

local Portfolio = require 'RawwersPortfolio'
local NICHES = { { slug = 'portraits', name = 'Portraits', primary = false }, { slug = 'weddings', name = 'Weddings', primary = true } }

test( 'a collection publishes to its own niche, the default one to the main niche, and an unknown one to none', function()
	eq( Portfolio.nicheFor( NICHES, 'portraits', false ).slug, 'portraits' )
	eq( Portfolio.nicheFor( NICHES, nil, true ).slug, 'weddings' )
	eq( Portfolio.nicheFor( NICHES, '', true ).slug, 'weddings' )
	eq( Portfolio.nicheFor( NICHES, 'cars', false ), nil )
	eq( Portfolio.nicheFor( {}, nil, true ), nil )
	eq( Portfolio.nicheItems( NICHES ), { { title = 'Portraits', value = 'portraits' }, { title = 'Weddings (main)', value = 'weddings' } } )
end )

test( 'a portfolio upload names its niche, and goes the way a delivery does', function()
	local a = fakeApi { startPortfolioUpload = { ok = true, data = { media_asset_id = 'pf-1', upload = { url = 'u', headers = {} } } } }
	local r = Portfolio.publishOne( a, 'weddings', file( 10, 'P.jpg' ), nil )
	eq( r.state, 'uploaded' )
	eq( names( a.log ), { 'startPortfolioUpload', 'putToStorage', 'finish' } )
	eq( a.log[ 1 ][ 2 ], 'weddings' )
end )

test( 'an edited photo names its old version at the start; the server removes it at the finish (1.2.4)', function()
	local a = fakeApi {
		startPortfolioUpload = { ok = true, data = { media_asset_id = 'pf-2', upload = { url = 'u', headers = {} } } },
		finish = { ok = true, data = { ok = true, current_status = 'processing', replaced = 'pf-1' } },
	}
	local f = file( 10, 'P.jpg' )
	local r = Portfolio.publishOne( a, 'weddings', f, 'pf-1' )
	eq( names( a.log ), { 'startPortfolioUpload', 'putToStorage', 'finish' } )
	eq( a.log[ 1 ][ 3 ].previousId, 'pf-1' )
	eq( r.replaced, 'pf-1' )
end )

test( 'a failed upload keeps the old version', function()
	local a = fakeApi { startPortfolioUpload = { ok = false, outcome = 'refused', message = 'Rate limit exceeded' } }
	local r = Portfolio.publishOne( a, 'weddings', file( 10, 'P.jpg' ), 'pf-1' )
	eq( r.state, 'failed' )
	eq( names( a.log ), { 'startPortfolioUpload' } )
end )

test( 'an old version the server kept is said in the summary, in its words', function()
	local a = fakeApi {
		startPortfolioUpload = { ok = true, data = { media_asset_id = 'pf-2', upload = { url = 'u', headers = {} } } },
		finish = { ok = true, data = { ok = true, current_status = 'processing', old_kept = 'The old version was kept in your portfolio: it is your profile cover.' } },
	}
	local r = Portfolio.publishOne( a, 'weddings', file( 10, 'P.jpg' ), 'pf-1' )
	local _, body = Portfolio.summary( { r }, 'Weddings' )
	has( body, 'P.jpg: The old version was kept in your portfolio: it is your profile cover.' )
end )

test( 'removing stops at a refusal that would repeat, and counts a photo already gone as removed', function()
	local answers = { { ok = false, status = 404 }, { ok = true }, { ok = false, outcome = 'reauth', status = 401, message = 'connect again' }, { ok = true } }
	local a = fakeApi { removePortfolioPhoto = answers }
	local gone = {}
	local failed, stop = Portfolio.removeAll( a, { 'a', 'b', 'c', 'd' }, function( id ) gone[ #gone + 1 ] = id end )
	eq( gone, { 'a', 'b' } )
	eq( stop, 'reauth' )
	eq( failed, { { id = 'c', message = 'connect again' } } )
end )

test( 'the publish summary says where the photos went and names each failure', function()
	local title, body = Portfolio.summary( {
		{ state = 'uploaded', name = 'a.jpg' }, { state = 'uploaded', name = 'b.jpg' }, { state = 'skipped', name = 'c.jpg' },
		{ state = 'failed', name = 'd.jpg', message = 'Larger than 25 MB. Export it smaller.' },
	}, 'Weddings' )
	eq( title, 'Some photos were not published' )
	has( body, '3 photos are in your RAWWERS portfolio (Weddings): 2 new, 1 already there.' )
	has( body, '1 photo not published:' )
	has( body, 'd.jpg: Larger than 25 MB. Export it smaller.' )
	local okTitle = Portfolio.summary( { { state = 'uploaded', name = 'a.jpg' } }, 'Weddings' )
	eq( okTitle, 'Published to RAWWERS' )
	local _, outdated = Portfolio.summary( {}, 'Weddings', 'outdated' )
	has( outdated, 'too old for the portfolio' )
end )

test( 'the portfolio size limit is the app\'s 25 MB, apart from delivery\'s 50 MB', function()
	local Checks = require 'RawwersChecks'
	eq( Checks.MAX_PORTFOLIO_BYTES, 25000000 )
	eq( Checks.problem( 25000001, nil, nil, Checks.MAX_PORTFOLIO_BYTES ), 'too_large' )
	eq( Checks.problem( 25000001, nil, nil ), nil )
end )

test( 'the portfolio calls carry the niche, the hash and the version', function()
	local calls = {}
	local http = function( method, url, headers, body ) calls[ #calls + 1 ] = { method = method, url = url, body = body } return '{}', { status = 200 } end
	local client = Api.new { base_url = 'https://api.rawwers.test', plugin_version = '1.1.0', http = http, sleep = function() end, token = 'rwd_x' }
	client:portfolio()
	client:startPortfolioUpload( 'weddings', { name = 'P.jpg', size = 10, sha256 = string.rep( 'a', 64 ) } )
	client:removePortfolioPhoto( 'pf-1' )
	eq( { calls[ 1 ].method, calls[ 1 ].url }, { 'GET', 'https://api.rawwers.test/v1/delivery/portfolio' } )
	eq( calls[ 2 ].url, 'https://api.rawwers.test/v1/delivery/portfolio/uploads' )
	eq( Json.decode( calls[ 2 ].body ), { file_name = 'P.jpg', content_type = 'image/jpeg', byte_size = 10, sha256 = string.rep( 'a', 64 ), niche_slug = 'weddings' } )
	eq( { calls[ 3 ].method, calls[ 3 ].url }, { 'DELETE', 'https://api.rawwers.test/v1/delivery/portfolio/pf-1' } )
end )

-- Niches from the plug-in (1.2.0) ------------------------------------------------------------------

local ALL = {
	{ slug = 'weddings', name = 'Weddings', mine = true, primary = false },
	{ slug = 'cars', name = 'Automotive', mine = false, primary = false },
	{ slug = 'portraits', name = 'Portraits', mine = true, primary = true },
	{ slug = 'food', name = 'Food', mine = false, primary = false },
}

test( 'the own niches come out of the full list, the main one first', function()
	eq( Portfolio.ownNiches( ALL ), { { slug = 'portraits', name = 'Portraits', primary = true }, { slug = 'weddings', name = 'Weddings', primary = false } } )
	eq( Portfolio.ownNiches( {} ), {} )
	eq( Portfolio.ownNiches( nil ), {} )
end )

test( 'the add menu lists only niches not yet theirs, by name, after an entry that chooses nothing', function()
	eq( Portfolio.addMenuItems( ALL ), { { title = 'Add a niche...', value = '' }, { title = 'Automotive', value = 'cars' }, { title = 'Food', value = 'food' } } )
end )

test( 'another niche can be added only below the server\'s maximum', function()
	eq( Portfolio.canAdd( { count = 2, maximum = 3 } ), true )
	eq( Portfolio.canAdd( { count = 3, maximum = 3 } ), false )
	eq( Portfolio.canAdd( { count = 4, maximum = 3 } ), false )
	eq( Portfolio.canAdd( {} ), false )
	eq( Portfolio.canAdd( nil ), false )
end )

test( 'the service says when there are no niches, which ones there are, and when that is the most', function()
	eq( Portfolio.nichesText( { niches = { ALL[ 2 ] }, count = 0, maximum = 3 } ), 'Connected. You have no niches yet. Choose one to add.' )
	eq( Portfolio.nichesText( { niches = ALL, count = 2, maximum = 3 } ), 'Connected. Your niches: Portraits (main), Weddings.' )
	eq( Portfolio.nichesText( { niches = ALL, count = 2, maximum = 2 } ), 'Connected. Your niches: Portraits (main), Weddings. That is the most you can have (2).' )
end )

test( 'a collection\'s menu is their niches, then "Add a niche..." while one can be added', function()
	eq( Portfolio.collectionMenuItems( { niches = ALL, count = 2, maximum = 3 } ), {
		{ title = 'Portraits (main)', value = 'portraits' }, { title = 'Weddings', value = 'weddings' },
		{ title = 'Add a niche...', value = Portfolio.ADD_NICHE },
	} )
	eq( Portfolio.collectionMenuItems( { niches = ALL, count = 2, maximum = 2 } ), { { title = 'Portraits (main)', value = 'portraits' }, { title = 'Weddings', value = 'weddings' } } )
	eq( Portfolio.collectionMenuItems( { niches = { ALL[ 2 ] }, count = 0, maximum = 3 } ), { { title = 'Add a niche...', value = Portfolio.ADD_NICHE } } )
end )

test( 'adding a niche returns the new list, or the server\'s reason in its own words', function()
	local listing = { niches = ALL, count = 3, maximum = 3, added = { slug = 'food', name = 'Food', mine = true, primary = false } }
	local a = fakeApi { addNiche = { ok = true, data = listing } }
	local r = Portfolio.addNiche( a, 'food' )
	eq( { r.ok, r.added.slug, r.listing.count }, { true, 'food', 3 } )
	eq( a.log[ 1 ], { 'addNiche', 'food' } )

	local refused = fakeApi { addNiche = { ok = false, outcome = 'refused', status = 422, message = 'You can have at most 3 niches, and you have 3.' } }
	eq( Portfolio.addNiche( refused, 'food' ), { ok = false, outcome = 'refused', message = 'You can have at most 3 niches, and you have 3.' } )
end )

test( 'choosing nothing, or the menu entry itself, sends nothing', function()
	local a = fakeApi {}
	for _, slug in ipairs { '', nil, Portfolio.ADD_NICHE } do
		eq( Portfolio.addNiche( a, slug ).ok, false )
	end
	eq( #a.log, 0 )
end )

test( 'the niche calls go to the delivery routes with the version, and adding sends only the slug', function()
	local calls = {}
	local http = function( method, url, headers, body ) calls[ #calls + 1 ] = { method = method, url = url, body = body, headers = headers } return '{}', { status = 200 } end
	local client = Api.new { base_url = 'https://api.rawwers.test', plugin_version = '1.2.0', http = http, sleep = function() end, token = 'rwd_x' }
	client:availableNiches()
	client:addNiche( 'food' )
	eq( { calls[ 1 ].method, calls[ 1 ].url }, { 'GET', 'https://api.rawwers.test/v1/delivery/portfolio/niches' } )
	eq( { calls[ 2 ].method, calls[ 2 ].url }, { 'POST', 'https://api.rawwers.test/v1/delivery/portfolio/niches' } )
	eq( Json.decode( calls[ 2 ].body ), { slug = 'food' } )
	eq( Api.header( calls[ 2 ].headers, 'X-Rawwers-Plugin-Version' ), '1.2.0' )
end )


-- Publishing again is safe (1.2.3) ---------------------------------------------------------------

local function segment( kind, body )
	local n = #body + 2
	return '\255' .. kind .. string.char( math.floor( n / 256 ), n % 256 ) .. body
end
local function jpeg( exif, pixels )
	return '\255\216' .. segment( '\225', 'Exif\0\0' .. exif ) .. segment( '\254', 'a comment' ) .. segment( '\219', 'quant' )
		.. segment( '\192', 'frame' ) .. '\255\218\0\8scan' .. pixels .. '\255\217'
end
--- The bytes the picture hash covers.
local function pictureBytes( bytes )
	local layout = Upload.jpegPicture( bytes )
	if not layout then return nil end
	local out = {}
	for _, r in ipairs( layout.ranges ) do out[ #out + 1 ] = bytes:sub( r[ 1 ] + 1, r[ 1 ] + r[ 2 ] ) end
	return table.concat( out ) .. bytes:sub( layout.scanStart + 1 )
end

test( 'the picture hash leaves out the metadata Lightroom changes on every render', function()
	local a = jpeg( 'DateTime 2026:11:16 03:36:22', 'PIXELS' )
	local b = jpeg( 'DateTime 2026:11:16 03:40:23 and a longer XMP', 'PIXELS' )
	ok( a ~= b )
	eq( pictureBytes( a ), pictureBytes( b ) )
	ok( pictureBytes( a ) ~= pictureBytes( jpeg( 'DateTime 2026:11:16 03:36:22', 'PIXELS, exposure +1' ) ) )
	has( pictureBytes( a ), 'quant' )
	has( pictureBytes( a ), 'frame' )
	ok( not pictureBytes( a ):find( 'DateTime' ) and not pictureBytes( a ):find( 'comment' ) )
end )

test( 'the picture hash is skipped, not wrong, for a file that is not a JPEG or a header that does not fit', function()
	eq( Upload.jpegPicture( 'JPEG:not really' ), nil )
	eq( Upload.jpegPicture( nil ), nil )
	local whole = jpeg( 'x', 'PIXELS' )
	eq( Upload.jpegPicture( whole:sub( 1, 30 ) ), nil )
end )

test( 'a finish that failed after the file was sent is said plainly, and the photo is not marked done', function()
	local a = fakeApi {
		startPortfolioUpload = { ok = true, data = { media_asset_id = 'pf-2', upload = { url = 'u', headers = {} } } },
		finish = { ok = false, outcome = 'retry', status = 500, message = 'RAWWERS had a problem on its side (HTTP 500). Try again in a minute.' },
	}
	local r = Portfolio.publishOne( a, 'weddings', file( 10, 'P.jpg' ), nil )
	eq( r.state, 'failed' )
	has( r.message, 'it reached RAWWERS but could not be finished' )
	has( r.message, 'not sent twice' )
end )

test( 'the plug-in never removes an old version itself (1.2.4: only the server may)', function()
	local a = fakeApi {
		startPortfolioUpload = { ok = true, data = { media_asset_id = 'pf-3', replaces = 'pf-9', upload = { url = 'u', headers = {} } } },
		removePortfolioPhoto = { ok = true },
	}
	Portfolio.publishOne( a, 'weddings', file( 10, 'P.jpg' ), 'pf-1' )
	for _, n in ipairs( names( a.log ) ) do ok( n ~= 'removePortfolioPhoto', 'the plug-in removed a photo itself' ) end
end )

test( 'an old version removed when the photo was already there is reported too', function()
	local a = fakeApi { startPortfolioUpload = { ok = true, data = { media_asset_id = 'pf-3', duplicate = true, replaced = 'pf-1' } } }
	local r = Portfolio.publishOne( a, 'weddings', file( 10, 'P.jpg' ), 'pf-1' )
	eq( ( { r.state, r.replaced } ), { 'skipped', 'pf-1' } )
end )

test( 'the summary gives the server\'s numbers: on RAWWERS, new, already there, and the niche\'s total', function()
	local _, body = Portfolio.summary( { { state = 'uploaded', name = 'a.jpg' }, { state = 'skipped', name = 'b.jpg' } }, 'Family', nil, 6 )
	has( body, '2 photos are in your RAWWERS portfolio (Family): 1 new, 1 already there.' )
	has( body, 'Family now has 6 photos on RAWWERS.' )
	local _, one = Portfolio.summary( { { state = 'skipped', name = 'b.jpg' } }, 'Family', nil, 1 )
	has( one, '1 photo is in your RAWWERS portfolio (Family): 0 new, 1 already there.' )
	has( one, 'Family now has 1 photo on RAWWERS.' )
end )

test( 'a server error is said in plain words, not the server\'s internal text', function()
	local body = Json.encode { error = { code = 'internal_error', message = 'Internal server error' } }
	local client = api( { { status = 500, body = body }, { status = 500, body = body }, { status = 500, body = body } }, 'rwd_x' )
	local answer = client:finish( 'pf-1', 10, 'aa' )
	eq( answer.ok, false )
	eq( answer.message, 'RAWWERS had a problem on its side (HTTP 500). Try again in a minute.' )
end )

-- The publish service's connection state (1.2.1) ----------------------------------------------------

local Connection = require( 'RawwersPortfolio' ).Connection
local STATES = { 'connected', 'checking', 'connecting', 'not_paired', 'revoked', 'pair_failed', 'outdated', 'unreachable', 'something else' }

test( 'Save is allowed exactly when the line says "Connected", in every state', function()
	for _, state in ipairs( STATES ) do
		local v = Connection.view( state, state == 'connected' and 'Connected. Your niches: Food (main).' or 'The server said no.' )
		local says = v.text:sub( 1, 10 ) == 'Connected.'
		eq( v.cantSave == nil, says, state )
		eq( v.connected, says, state )
		eq( state == 'connected', says, state )
		if not says then ok( type( v.cantSave ) == 'string' and #v.cantSave > 0, state ) end
	end
end )

test( 'the code row shows when a code is the way forward; Check again when the server could not be asked', function()
	for _, state in ipairs { 'not_paired', 'revoked', 'pair_failed' } do eq( Connection.view( state ).needsCode, true, state ) end
	for _, state in ipairs { 'connected', 'checking', 'connecting', 'outdated', 'unreachable' } do eq( Connection.view( state, 'x' ).needsCode, false, state ) end
	eq( Connection.view( 'unreachable' ).canRetry, true )
	eq( Connection.view( 'connected', 'Connected.' ).canRetry, false )
	has( Connection.view( 'revoked' ).text, 'Not connected. Type a new pairing code' )
end )

test( 'only the server saying yes connects; only a 401 forgets the pairing', function()
	eq( { Connection.fromCheck( { ok = true, data = {} }, 'Connected. X.' ) }, { 'connected', 'Connected. X.', false } )
	eq( { Connection.fromCheck( { ok = false, outcome = 'reauth', status = 401, message = 'gone' } ) }, { 'revoked', nil, true } )
	eq( { Connection.fromCheck( { ok = false, outcome = 'outdated', status = 426, message = 'old' } ) }, { 'outdated', 'old', false } )
	eq( { Connection.fromCheck( { ok = false, outcome = 'retry', message = 'Could not reach RAWWERS. Check the internet connection and export again.' } ) }, { 'unreachable', nil, false } )
	eq( { Connection.fromCheck( { ok = false, outcome = 'retry', status = 503, message = 'Down for a minute' } ) }, { 'unreachable', 'Down for a minute', false } )
	eq( { Connection.fromCheck( { ok = false, outcome = 'refused', status = 403, message = 'No' } ) }, { 'unreachable', 'No', false } )
end )

os.exit( H.run() and 0 or 1 )
