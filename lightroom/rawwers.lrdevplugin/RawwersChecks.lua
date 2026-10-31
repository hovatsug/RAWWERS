--[[ What the platform expects of an exported file, checked on the file itself.

JPEG and sRGB are locked in the Export dialog. The size is not, on purpose
(owner's decision 5: no hard minimum), so it is read from the rendered JPEG
- its frame header - rather than from Lightroom's size settings, whose
field names the SDK does not document. Below 2048 px on the long edge the
photo still goes, with a warning; above 50 MB the server refuses it, so the
plug-in says so before sending.

Plain Lua 5.1: no Lightroom calls.
]]

local Checks = {}

Checks.MIN_LONG_EDGE = 2048
Checks.MAX_BYTES = 50 * 1000 * 1000

local function u16( s, i )
	local a, b = s:byte( i, i + 1 )
	if not b then return nil end
	return a * 256 + b
end

--- Width and height from a JPEG's first bytes (the SOFn frame header), or
--- nil when it cannot be read there.
function Checks.jpegSize( bytes )
	if type( bytes ) ~= 'string' or bytes:sub( 1, 2 ) ~= '\255\216' then return nil end
	local i = 3
	while i + 3 <= #bytes do
		if bytes:byte( i ) ~= 0xFF then return nil end
		local marker = bytes:byte( i + 1 )
		if marker == 0xFF then
			i = i + 1 -- padding
		elseif marker == 0xD8 or ( marker >= 0xD0 and marker <= 0xD7 ) or marker == 0x01 then
			i = i + 2
		else
			local length = u16( bytes, i + 2 )
			if not length then return nil end
			local isFrame = marker >= 0xC0 and marker <= 0xCF and marker ~= 0xC4 and marker ~= 0xC8 and marker ~= 0xCC
			if isFrame then
				local height, width = u16( bytes, i + 5 ), u16( bytes, i + 7 )
				if height and width then return width, height end
				return nil
			end
			if marker == 0xDA then return nil end -- image data started: no frame header before it
			i = i + 2 + length
		end
	end
	return nil
end

--- 'too_large', 'small' or nil for a rendered file.
function Checks.problem( size, width, height )
	if size and size > Checks.MAX_BYTES then return 'too_large' end
	if width and height and math.max( width, height ) < Checks.MIN_LONG_EDGE then return 'small' end
	return nil
end

--- The preset the dialog suggests, in the words of Lightroom's Export dialog.
Checks.suggestedPreset = 'Suggested: quality 85-90, long edge 3000-6000 px (at least 2048), Output Sharpening for Screen, Standard. Metadata: All Metadata with Remove Location Info ticked, so your copyright and contact details go with each photo and where it was taken does not.'

return Checks
