--[[ One photo, from the rendered file to "processing" on the server.

  start (name, size, SHA-256)  -> already in the gallery?  -> skipped
                               -> one PUT, or parts for a large file
  finish (size, SHA-256)       -> uploaded; the server attaches it

Resume is exporting again: the server answers a file it already has (same
SHA-256) with "duplicate", so a second run after a lost connection or a
crash sends only what is missing. A large file sent in parts asks which
parts storage already holds and sends the rest.

`file` is { name, size, sha256, position, readAll(), readRange(offset, length) },
given by RawwersLightroom.lua; tests give their own.

Plain Lua 5.1: no Lightroom calls.
]]

local Upload = {}

--- Part URLs asked for at a time (the server allows up to 100).
Upload.PART_URL_BATCH = 20

local function failure( name, result )
	local state = 'failed'
	if result.outcome == 'reauth' then state = 'reauth' end
	if result.outcome == 'outdated' then state = 'outdated' end
	if result.outcome == 'cancelled' then state = 'cancelled' end
	return { state = state, name = name, message = result.message, code = result.code }
end

local function sendWhole( api, assetId, upload, file )
	local bytes = file.readAll()
	if not bytes or #bytes ~= file.size then
		return false, { outcome = 'refused', message = 'The exported file could not be read.' }
	end
	local put = api:putToStorage( upload.url, upload.headers, bytes )
	if not put.ok and put.expired then
		-- The URL lasts 15 minutes; a long export can outlive it.
		local fresh = api:freshUploadUrl( assetId )
		if not fresh.ok then return false, fresh end
		put = api:putToStorage( fresh.data.url, fresh.data.headers, bytes )
	end
	if not put.ok then return false, put end
	return true
end

local function sendParts( api, assetId, file )
	local started = api:startParts( assetId, file.size )
	if not started.ok then return false, started end
	local partSize, partCount = started.data.part_size, started.data.part_count

	local held = api:partsReceived( assetId )
	if not held.ok then return false, held end
	local done = {}
	for _, part in ipairs( held.data.parts or {} ) do done[ part.part_number ] = true end

	local missing = {}
	for n = 1, partCount do
		if not done[ n ] then missing[ #missing + 1 ] = n end
	end

	local i = 1
	while i <= #missing do
		local batch = {}
		for j = i, math.min( i + Upload.PART_URL_BATCH - 1, #missing ) do batch[ #batch + 1 ] = missing[ j ] end
		i = i + #batch
		local urls = api:partUrls( assetId, batch )
		if not urls.ok then return false, urls end
		for _, part in ipairs( urls.data.parts ) do
			local offset = ( part.part_number - 1 ) * partSize
			local length = math.min( partSize, file.size - offset )
			local bytes = file.readRange( offset, length )
			if not bytes or #bytes ~= length then
				return false, { outcome = 'refused', message = 'The exported file could not be read.' }
			end
			local put = api:putToStorage( part.url, {}, bytes )
			if not put.ok and put.expired then
				local again = api:partUrls( assetId, { part.part_number } )
				if not again.ok then return false, again end
				put = api:putToStorage( again.data.parts[ 1 ].url, {}, bytes )
			end
			if not put.ok then return false, put end
		end
	end

	local assembled = api:assembleParts( assetId )
	if not assembled.ok then return false, assembled end
	return true
end

--- Delivers one photo. Returns { state, name, message, gallery_id, media_asset_id }
--- with state 'uploaded', 'skipped' (already in the gallery), 'failed',
--- 'reauth' (connect again), 'outdated' (update the plug-in) or 'cancelled'.
function Upload.deliver( api, gigId, file )
	local started = api:startUpload( gigId, file )
	if not started.ok then return failure( file.name, started ) end
	local data = started.data
	local result = { name = file.name, gallery_id = data.gallery_id, media_asset_id = data.media_asset_id }
	if data.duplicate then
		result.state = 'skipped'
		return result
	end

	local sent, problem
	if data.use_multipart then
		sent, problem = sendParts( api, data.media_asset_id, file )
	elseif data.upload then
		sent, problem = sendWhole( api, data.media_asset_id, data.upload, file )
	else
		sent, problem = false, { outcome = 'refused', message = 'The server gave no address to upload to.' }
	end
	if not sent then
		local failed = failure( file.name, problem )
		failed.gallery_id, failed.media_asset_id = result.gallery_id, result.media_asset_id
		return failed
	end

	local finished = api:finish( data.media_asset_id, file.size, file.sha256 )
	if not finished.ok then
		local failed = failure( file.name, finished )
		failed.gallery_id, failed.media_asset_id = result.gallery_id, result.media_asset_id
		return failed
	end
	result.state = 'uploaded'
	return result
end

return Upload
