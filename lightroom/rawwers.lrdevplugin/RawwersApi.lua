--[[ The RAWWERS delivery API, as the plug-in calls it.

Every request is built here: the URL, the headers (the delivery token, the
plug-in's version), the JSON body; and every answer is read here: success,
retry, refused with the server's own message, or "connect again". The HTTP
call itself is injected (`http`), so this runs with plain Lua in the tests
and with LrHttp inside Lightroom (RawwersLightroom.lua).

`http(method, url, headers, body, size)` returns (responseBody, headers)
like LrHttp: headers is a list of { field, value } with headers.status; on
a network error it returns nil and { error = { errorCode = ... } }.

Plain Lua 5.1: no Lightroom calls.
]]

local Json = require 'RawwersJson'
local Retry = require 'RawwersRetry'

local Api = {}
Api.__index = Api

Api.TOKEN_HEADER = 'Authorization'
Api.VERSION_HEADER = 'X-Rawwers-Plugin-Version'
Api.UPDATE_HEADER = 'X-Rawwers-Update-Available'

--- The token travels in clear over http, so only https - or this Mac, or the
--- local network while testing against a development server.
function Api.isSafeBaseUrl( url )
	if type( url ) ~= 'string' then return false end
	if url:match( '^https://[%w%.%-]+' ) then return true end
	local host = url:match( '^http://([%w%.%-]+)' )
	if not host then return false end
	return host == 'localhost' or host == '127.0.0.1' or host:match( '%.local$' ) ~= nil
end

--- config: base_url, plugin_version, http, sleep, token (optional),
--- isCanceled (optional), delays (optional, for tests).
function Api.new( config )
	assert( Api.isSafeBaseUrl( config.base_url ), 'The RAWWERS server address must start with https://' )
	local self = setmetatable( {}, Api )
	self.base_url = config.base_url:gsub( '/+$', '' )
	self.plugin_version = config.plugin_version
	self.http = config.http
	self.sleep = config.sleep
	self.token = config.token
	self.isCanceled = config.isCanceled
	self.delays = config.delays
	self.update_available = false
	return self
end

local function header( headers, name )
	if type( headers ) ~= 'table' then return nil end
	local wanted = name:lower()
	for _, h in ipairs( headers ) do
		if type( h ) == 'table' and type( h.field ) == 'string' and h.field:lower() == wanted then return h.value end
	end
	return nil
end
Api.header = header

--- What the server said when it refused, in its own words.
local function serverMessage( data, status )
	if type( data ) == 'table' and type( data.error ) == 'table' then
		local detail = data.error.message
		if type( detail ) == 'string' and detail ~= '' then return detail, data.error.code end
	end
	if type( data ) == 'table' and type( data.detail ) == 'string' then return data.detail end
	return 'The RAWWERS server refused this (HTTP ' .. tostring( status ) .. ').'
end

local function networkMessage( info )
	local err = type( info ) == 'table' and info.error or nil
	local name = type( err ) == 'table' and ( err.name or err.errorCode ) or nil
	return 'Could not reach RAWWERS' .. ( name and ( ' (' .. tostring( name ) .. ')' ) or '' ) .. '. Check the internet connection and export again.'
end

--- One API call, with retries. Returns a result table:
---   { ok = true, status, data }
---   { ok = false, outcome = 'refused' | 'reauth' | 'retry' | 'cancelled', status, message, code }
function Api:request( method, path, body )
	local headers = {
		{ field = Api.VERSION_HEADER, value = self.plugin_version },
		{ field = 'Accept', value = 'application/json' },
	}
	if self.token then headers[ #headers + 1 ] = { field = Api.TOKEN_HEADER, value = 'Bearer ' .. self.token } end
	local payload
	if body ~= nil then
		payload = Json.encode( body )
		headers[ #headers + 1 ] = { field = 'Content-Type', value = 'application/json' }
	end
	local url = self.base_url .. path

	local function attempt()
		local responseBody, info = self.http( method, url, headers, payload, payload and #payload or nil )
		local errorCode = responseBody == nil and type( info ) == 'table' and type( info.error ) == 'table' and info.error.errorCode or nil
		if responseBody == nil and not errorCode and not ( type( info ) == 'table' and info.status ) then errorCode = 'unknown' end
		local status = type( info ) == 'table' and info.status or nil
		local outcome = Retry.classify( status, errorCode )
		return outcome, status, responseBody, info, errorCode
	end

	local outcome, status, responseBody, info, errorCode = Retry.run( attempt, self.sleep, self.isCanceled, self.delays )
	if header( info, Api.UPDATE_HEADER ) == 'true' then self.update_available = true end
	local data = Json.decode( responseBody )
	if outcome == 'ok' then return { ok = true, status = status, data = data } end
	if errorCode then return { ok = false, outcome = outcome, message = networkMessage( info ) } end
	local message, code = serverMessage( data, status )
	return { ok = false, outcome = outcome, status = status, message = message, code = code }
end

-- The delivery routes ---------------------------------------------------------

function Api:pair( code, deviceName )
	return self:request( 'POST', '/v1/delivery/pair', { code = code, device_name = deviceName, plugin_version = self.plugin_version } )
end

function Api:me() return self:request( 'GET', '/v1/delivery/me' ) end

function Api:gigs() return self:request( 'GET', '/v1/delivery/gigs' ) end

function Api:startUpload( gigId, file )
	return self:request( 'POST', '/v1/delivery/gigs/' .. gigId .. '/uploads', {
		file_name = file.name, content_type = 'image/jpeg', byte_size = file.size, sha256 = file.sha256,
		-- The n-th photo of this export: the gallery is put in this order,
		-- whatever order the uploads finish in.
		position = file.position,
	} )
end

function Api:freshUploadUrl( assetId ) return self:request( 'POST', '/v1/delivery/uploads/' .. assetId .. '/url' ) end

function Api:startParts( assetId, size )
	return self:request( 'POST', '/v1/delivery/uploads/' .. assetId .. '/multipart', { byte_size = size } )
end

function Api:partsReceived( assetId ) return self:request( 'GET', '/v1/delivery/uploads/' .. assetId .. '/multipart/parts' ) end

function Api:partUrls( assetId, numbers )
	return self:request( 'POST', '/v1/delivery/uploads/' .. assetId .. '/multipart/part-urls', { part_numbers = numbers } )
end

function Api:assembleParts( assetId ) return self:request( 'POST', '/v1/delivery/uploads/' .. assetId .. '/multipart/complete' ) end

function Api:finish( assetId, size, sha256 )
	return self:request( 'POST', '/v1/delivery/uploads/' .. assetId .. '/complete', { byte_size = size, sha256 = sha256 } )
end

function Api:status( galleryId ) return self:request( 'GET', '/v1/delivery/galleries/' .. galleryId .. '/status' ) end

-- Storage ---------------------------------------------------------------------

--- PUT bytes to a presigned storage URL. No token: the URL carries its own
--- signature, and our header on top would be refused - and would hand the
--- token to the storage host. Retried like any request; a 403 means the URL
--- expired, which the caller fixes with a fresh one.
function Api:putToStorage( url, headers, bytes )
	local list = {}
	for field, value in pairs( headers or {} ) do list[ #list + 1 ] = { field = field, value = value } end
	if not ( headers and ( headers[ 'Content-Type' ] or headers[ 'content-type' ] ) ) then
		-- LrHttp would otherwise add text/plain, which the signature did not cover.
		list[ #list + 1 ] = { field = 'Content-Type', value = 'skip' }
	end
	local function attempt()
		local responseBody, info = self.http( 'PUT', url, list, bytes, #bytes )
		local errorCode = responseBody == nil and type( info ) == 'table' and type( info.error ) == 'table' and info.error.errorCode or nil
		local status = type( info ) == 'table' and info.status or nil
		if responseBody == nil and not errorCode and not status then errorCode = 'unknown' end
		local outcome = Retry.classify( status, errorCode )
		-- 401 from storage is not about the device; it is a bad signature.
		if outcome == 'reauth' then outcome = 'refused' end
		return outcome, status, info, errorCode
	end
	local outcome, status, info, errorCode = Retry.run( attempt, self.sleep, self.isCanceled, self.delays )
	if outcome == 'ok' then return { ok = true, status = status, etag = header( info, 'ETag' ) } end
	if errorCode then return { ok = false, outcome = outcome, message = networkMessage( info ) } end
	return { ok = false, outcome = outcome, status = status, expired = status == 403, message = 'Storage refused the upload (HTTP ' .. tostring( status ) .. ').' }
end

return Api
