--[[ JSON for the RAWWERS API: just what the delivery routes send and receive.

Lightroom has no JSON library, and a plug-in cannot install one. Objects,
arrays, strings (with \uXXXX escapes, written back as UTF-8), numbers,
true/false and null. A JSON null decodes to nil, so the key is simply absent.

Plain Lua 5.1: no Lightroom calls, so it is tested with stock Lua.
]]

local Json = {}

-- Encoding --------------------------------------------------------------------

local escapes = {
	['"'] = '\\"', ['\\'] = '\\\\', ['\b'] = '\\b', ['\f'] = '\\f',
	['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t',
}

local function encodeString( s )
	return '"' .. s:gsub( '[%c"\\]', function( c )
		return escapes[ c ] or string.format( '\\u%04x', c:byte() )
	end ) .. '"'
end

local function isArray( t )
	local n = 0
	for k in pairs( t ) do
		if type( k ) ~= 'number' or k < 1 or k % 1 ~= 0 then return false end
		n = n + 1
	end
	for i = 1, n do
		if t[ i ] == nil then return false end
	end
	return true, n
end

local encodeValue

function encodeValue( v )
	local kind = type( v )
	if kind == 'nil' then return 'null' end
	if kind == 'boolean' then return v and 'true' or 'false' end
	if kind == 'number' then
		if v ~= v or v == math.huge or v == -math.huge then error( 'cannot encode ' .. tostring( v ) ) end
		if v % 1 == 0 and math.abs( v ) < 2^53 then return string.format( '%d', v ) end
		return string.format( '%.14g', v )
	end
	if kind == 'string' then return encodeString( v ) end
	if kind == 'table' then
		local array, n = isArray( v )
		local parts = {}
		if array and n > 0 then
			for i = 1, n do parts[ i ] = encodeValue( v[ i ] ) end
			return '[' .. table.concat( parts, ',' ) .. ']'
		end
		if array then return ( v == Json.emptyArray ) and '[]' or '{}' end
		local keys = {}
		for k in pairs( v ) do keys[ #keys + 1 ] = tostring( k ) end
		table.sort( keys )
		for _, k in ipairs( keys ) do
			parts[ #parts + 1 ] = encodeString( k ) .. ':' .. encodeValue( v[ k ] )
		end
		return '{' .. table.concat( parts, ',' ) .. '}'
	end
	error( 'cannot encode a ' .. kind )
end

--- An empty table encodes as {}; use this for [].
Json.emptyArray = setmetatable( {}, { __newindex = function() error( 'Json.emptyArray is read-only' ) end } )

function Json.encode( value )
	return encodeValue( value )
end

-- Decoding --------------------------------------------------------------------

local function utf8( code )
	if code < 0x80 then return string.char( code ) end
	if code < 0x800 then
		return string.char( 0xC0 + math.floor( code / 0x40 ), 0x80 + code % 0x40 )
	end
	if code < 0x10000 then
		return string.char( 0xE0 + math.floor( code / 0x1000 ), 0x80 + math.floor( code / 0x40 ) % 0x40, 0x80 + code % 0x40 )
	end
	return string.char(
		0xF0 + math.floor( code / 0x40000 ), 0x80 + math.floor( code / 0x1000 ) % 0x40,
		0x80 + math.floor( code / 0x40 ) % 0x40, 0x80 + code % 0x40 )
end

local Decoder = {}
Decoder.__index = Decoder

function Decoder:fail( what )
	error( string.format( 'invalid JSON at character %d: %s', self.i, what ), 0 )
end

function Decoder:space()
	self.i = self.s:find( '[^ \t\r\n]', self.i ) or ( #self.s + 1 )
end

function Decoder:string()
	local s, i, out = self.s, self.i + 1, {}
	while true do
		local stop = s:find( '["\\]', i )
		if not stop then self:fail( 'unterminated string' ) end
		out[ #out + 1 ] = s:sub( i, stop - 1 )
		if s:sub( stop, stop ) == '"' then
			self.i = stop + 1
			return table.concat( out )
		end
		local e = s:sub( stop + 1, stop + 1 )
		local simple = { ['"'] = '"', ['\\'] = '\\', ['/'] = '/', b = '\b', f = '\f', n = '\n', r = '\r', t = '\t' }
		if simple[ e ] then
			out[ #out + 1 ] = simple[ e ]
			i = stop + 2
		elseif e == 'u' then
			local hex = s:sub( stop + 2, stop + 5 )
			if not hex:match( '^%x%x%x%x$' ) then self:fail( 'bad \\u escape' ) end
			local code = tonumber( hex, 16 )
			i = stop + 6
			if code >= 0xD800 and code <= 0xDBFF and s:sub( i, i + 1 ) == '\\u' then
				local low = tonumber( s:sub( i + 2, i + 5 ), 16 )
				if low and low >= 0xDC00 and low <= 0xDFFF then
					code = 0x10000 + ( code - 0xD800 ) * 0x400 + ( low - 0xDC00 )
					i = i + 6
				end
			end
			out[ #out + 1 ] = utf8( code )
		else
			self:fail( 'bad escape' )
		end
	end
end

function Decoder:value()
	self:space()
	local s, i = self.s, self.i
	local c = s:sub( i, i )
	if c == '{' then
		local result = {}
		self.i = i + 1
		self:space()
		if s:sub( self.i, self.i ) == '}' then self.i = self.i + 1 return result end
		while true do
			self:space()
			if s:sub( self.i, self.i ) ~= '"' then self:fail( 'expected a key' ) end
			local key = self:string()
			self:space()
			if s:sub( self.i, self.i ) ~= ':' then self:fail( 'expected :' ) end
			self.i = self.i + 1
			result[ key ] = self:value()
			self:space()
			local d = s:sub( self.i, self.i )
			self.i = self.i + 1
			if d == '}' then return result end
			if d ~= ',' then self:fail( 'expected , or }' ) end
		end
	elseif c == '[' then
		local result, n = {}, 0
		self.i = i + 1
		self:space()
		if s:sub( self.i, self.i ) == ']' then self.i = self.i + 1 return result end
		while true do
			n = n + 1
			result[ n ] = self:value()
			self:space()
			local d = s:sub( self.i, self.i )
			self.i = self.i + 1
			if d == ']' then return result end
			if d ~= ',' then self:fail( 'expected , or ]' ) end
		end
	elseif c == '"' then
		return self:string()
	elseif s:sub( i, i + 3 ) == 'true' then
		self.i = i + 4 return true
	elseif s:sub( i, i + 4 ) == 'false' then
		self.i = i + 5 return false
	elseif s:sub( i, i + 3 ) == 'null' then
		self.i = i + 4 return nil
	else
		local number = s:match( '^-?%d+%.?%d*[eE]?[-+]?%d*', i )
		if not number or number == '' or number == '-' then self:fail( 'unexpected ' .. ( c ~= '' and c or 'end' ) ) end
		self.i = i + #number
		return tonumber( number ) or self:fail( 'bad number' )
	end
end

--- The value in `text`, or nil plus a message when it is not JSON.
function Json.decode( text )
	if type( text ) ~= 'string' then return nil, 'no response body' end
	local decoder = setmetatable( { s = text, i = 1 }, Decoder )
	local ok, value = pcall( function()
		local v = decoder:value()
		decoder:space()
		if decoder.i <= #text then decoder:fail( 'trailing characters' ) end
		return v
	end )
	if not ok then return nil, value end
	return value
end

return Json
