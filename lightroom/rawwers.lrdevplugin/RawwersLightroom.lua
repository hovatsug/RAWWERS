--[[ Everything that touches Lightroom's SDK: HTTP, the keychain, hashing,
files and tasks. The logic modules (RawwersApi, RawwersUpload,
RawwersPipeline, RawwersChecks, RawwersSummary) never call the SDK; this
file hands them the Lightroom versions of what they need.

SDK calls used here, all in the SDK 15.3 API reference (and present since
the versions noted, so in Lightroom Classic 13, 14 and 15 alike):
  LrHttp.get / LrHttp.post (method PUT, body as a string)   1.3
  LrPasswords.store / LrPasswords.retrieve                  3.0
  LrDigest.SHA256.init / :update / :digest                  4.0
  LrTasks.sleep / LrTasks.startAsyncTask                    1.3
  LrDate.timeFromPosixDate / LrDate.formatShortDate         1.3
  LrDate.currentTime                                        1.3
  LrFileUtils.fileAttributes / LrFileUtils.delete            1.3
Files are read with Lua's own io library, as Adobe's remote_control sample does.
]]

local LrDate = import 'LrDate'
local LrDigest = import 'LrDigest'
local LrFileUtils = import 'LrFileUtils'
local LrHttp = import 'LrHttp'
local LrPasswords = import 'LrPasswords'
local LrPathUtils = import 'LrPathUtils'
local LrTasks = import 'LrTasks'

local Api = require 'RawwersApi'
local Config = require 'RawwersConfig'

local Lightroom = {}

--- Seconds LrHttp waits in each phase of a connection before giving up.
local TIMEOUT = 120
local CHUNK = 1024 * 1024

--- LrHttp in the shape RawwersApi expects.
function Lightroom.http( method, url, headers, body, size )
	if method == 'GET' then
		return LrHttp.get( url, headers, TIMEOUT )
	end
	-- An empty body still needs a string, or LrHttp sends none at all.
	return LrHttp.post( url, body or '', headers, method, TIMEOUT, size )
end

function Lightroom.baseUrl( propertyTable )
	local url = propertyTable and propertyTable.rawwersServer
	if type( url ) == 'string' and url:match( '%S' ) then return ( url:gsub( '%s', '' ) ) end
	return Config.baseUrl
end

--- One keychain entry per server, so a development token is never sent to
--- the real server or the other way round.
local function keyFor( baseUrl ) return 'rawwers.delivery-token:' .. baseUrl end

function Lightroom.storedToken( baseUrl )
	local token = LrPasswords.retrieve( keyFor( baseUrl ) )
	if type( token ) == 'string' and token ~= '' then return token end
	return nil
end

function Lightroom.storeToken( baseUrl, token )
	LrPasswords.store( keyFor( baseUrl ), token or '' )
end

function Lightroom.api( baseUrl, opts )
	opts = opts or {}
	return Api.new {
		base_url = baseUrl,
		plugin_version = Config.version,
		http = Lightroom.http,
		sleep = LrTasks.sleep,
		token = opts.token,
		isCanceled = opts.isCanceled,
	}
end

--- A name for one export, sent with each of its photos: the gallery keeps
--- each export together, after the ones before it. It only has to differ
--- from this Mac's other exports (milliseconds, and a random number for two
--- started in the same one); the server checks it is letters, digits, dot,
--- dash or underscore, 64 at most.
function Lightroom.newExportId()
	return string.format( 'lr-%.0f-%d', math.floor( LrDate.currentTime() * 1000 ), math.random( 1, 2147483646 ) )
end

function Lightroom.formatDate( epoch )
	return LrDate.formatShortDate( LrDate.timeFromPosixDate( epoch ) )
end

--- The rendered file, as RawwersUpload reads it: hashed in 1 MB pieces, so
--- a 50 MB file is never held twice.
function Lightroom.renderedFile( path )
	local attributes = LrFileUtils.fileAttributes( path ) or {}
	local size = attributes.fileSize
	local handle = io.open( path, 'rb' )
	if not handle or not size then return nil end
	local digester = LrDigest.SHA256.init()
	local head
	while true do
		local chunk = handle:read( CHUNK )
		if not chunk then break end
		head = head or chunk:sub( 1, 65536 )
		digester:update( chunk )
	end
	handle:close()
	return {
		path = path,
		name = LrPathUtils.leafName( path ),
		size = size,
		sha256 = ( digester:digest() ),
		head = head or '',
		readAll = function()
			local f = io.open( path, 'rb' )
			if not f then return nil end
			local data = f:read( '*a' )
			f:close()
			return data
		end,
		readRange = function( offset, length )
			local f = io.open( path, 'rb' )
			if not f then return nil end
			f:seek( 'set', offset )
			local data = f:read( length )
			f:close()
			return data
		end,
	}
end

function Lightroom.spawn( fn ) LrTasks.startAsyncTask( fn, 'RAWWERS upload' ) end

Lightroom.sleep = LrTasks.sleep

return Lightroom
