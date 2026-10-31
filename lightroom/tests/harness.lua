-- A small test harness for plain Lua 5.1: the plug-in's logic is tested
-- without Lightroom, so without any test library either.

local H = { tests = {}, failures = 0 }

function H.test( name, fn ) H.tests[ #H.tests + 1 ] = { name = name, fn = fn } end

local function show( v )
	if type( v ) == 'string' then return string.format( '%q', v ) end
	if type( v ) ~= 'table' then return tostring( v ) end
	local keys = {}
	for k in pairs( v ) do keys[ #keys + 1 ] = k end
	table.sort( keys, function( a, b ) return tostring( a ) < tostring( b ) end )
	local parts = {}
	for _, k in ipairs( keys ) do parts[ #parts + 1 ] = tostring( k ) .. '=' .. show( v[ k ] ) end
	return '{' .. table.concat( parts, ', ' ) .. '}'
end
H.show = show

local function same( a, b )
	if type( a ) ~= type( b ) then return false end
	if type( a ) ~= 'table' then return a == b end
	for k, v in pairs( a ) do if not same( v, b[ k ] ) then return false end end
	for k in pairs( b ) do if a[ k ] == nil then return false end end
	return true
end
H.same = same

function H.eq( actual, expected, message )
	if not same( actual, expected ) then
		error( ( message and ( message .. ': ' ) or '' ) .. 'expected ' .. show( expected ) .. ', got ' .. show( actual ), 2 )
	end
end

function H.ok( value, message )
	if not value then error( message or 'expected a true value', 2 ) end
end

function H.has( text, piece, message )
	if type( text ) ~= 'string' or not text:find( piece, 1, true ) then
		error( ( message and ( message .. ': ' ) or '' ) .. show( piece ) .. ' not in ' .. show( text ), 2 )
	end
end

function H.run()
	for _, t in ipairs( H.tests ) do
		local ok, err = pcall( t.fn )
		if ok then
			io.write( 'ok    ', t.name, '\n' )
		else
			H.failures = H.failures + 1
			io.write( 'FAIL  ', t.name, '\n      ', tostring( err ), '\n' )
		end
	end
	io.write( string.format( '\n%d tests, %d failed\n', #H.tests, H.failures ) )
	return H.failures == 0
end

return H
