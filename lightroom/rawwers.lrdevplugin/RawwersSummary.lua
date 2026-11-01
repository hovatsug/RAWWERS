--[[ What the photographer reads when the export ends, and the picker's rows.

Plain Lua 5.1: no Lightroom calls.
]]

local Summary = {}

local function plural( n, one, many ) return n == 1 and ( '1 ' .. one ) or ( n .. ' ' .. many ) end

--- results: list of { state, name, message }; warnings: { small = {names},
--- notSent = n }. Returns title, body.
function Summary.build( results, warnings, stopReason )
	local counts = { uploaded = 0, skipped = 0, failed = 0, reauth = 0, outdated = 0, cancelled = 0 }
	local failed, outdatedMessage = {}, nil
	for _, r in ipairs( results ) do
		counts[ r.state ] = ( counts[ r.state ] or 0 ) + 1
		if r.state == 'failed' then failed[ #failed + 1 ] = r end
		if r.state == 'outdated' and r.message then outdatedMessage = r.message end
	end
	warnings = warnings or {}

	local lines = {
		plural( counts.uploaded, 'photo uploaded', 'photos uploaded' ),
		plural( counts.skipped, 'skipped, already in the gallery', 'skipped, already in the gallery' ),
		plural( #failed, 'failed', 'failed' ),
	}
	if #failed > 0 then
		lines[ #lines + 1 ] = ''
		lines[ #lines + 1 ] = 'Failed:'
		for _, r in ipairs( failed ) do
			lines[ #lines + 1 ] = '  ' .. tostring( r.name ) .. ( r.message and ( ': ' .. r.message ) or '' )
		end
		lines[ #lines + 1 ] = 'Export the same photos again to retry: the ones already uploaded are skipped.'
	end
	if warnings.small and #warnings.small > 0 then
		lines[ #lines + 1 ] = ''
		lines[ #lines + 1 ] = plural( #warnings.small, 'photo is', 'photos are' ) .. ' under 2048 px on the long edge (sent anyway): ' .. table.concat( warnings.small, ', ' )
	end
	if stopReason == 'reauth' then
		lines[ #lines + 1 ] = ''
		lines[ #lines + 1 ] = 'This Mac is no longer connected to RAWWERS. Get a new pairing code in the RAWWERS Pro app (Settings > Connect Lightroom), connect again in the Export dialog, and export again.'
	elseif stopReason == 'outdated' then
		lines[ #lines + 1 ] = ''
		lines[ #lines + 1 ] = outdatedMessage or 'This RAWWERS plug-in is too old for the server.'
		lines[ #lines + 1 ] = 'Download the new plug-in from the RAWWERS Pro app (Settings > Connect Lightroom), install it in Lightroom\'s Plug-in Manager, and export again: the photos already uploaded are skipped, and this Mac stays connected.'
	elseif stopReason == 'cancelled' then
		lines[ #lines + 1 ] = ''
		lines[ #lines + 1 ] = 'Export cancelled. Export again to send the rest: the ones already uploaded are skipped.'
	end
	if warnings.notSent and warnings.notSent > 0 then
		lines[ #lines + 1 ] = plural( warnings.notSent, 'photo was', 'photos were' ) .. ' not sent.'
	end
	lines[ #lines + 1 ] = ''
	lines[ #lines + 1 ] = 'Nothing is shown to the client until you send the gallery from the RAWWERS Pro app.'

	local title
	if stopReason == 'reauth' then
		title = 'RAWWERS: connect again'
	elseif stopReason == 'outdated' then
		title = 'RAWWERS: update the plug-in'
	elseif #failed > 0 then
		title = 'RAWWERS: ' .. plural( #failed, 'photo', 'photos' ) .. ' did not upload'
	else
		title = 'RAWWERS: delivery uploaded'
	end
	return title, table.concat( lines, '\n' ), counts
end

--- One row of the client picker. gig: the API's DeliveryGigView; formatDate
--- turns seconds since 1970 into the Mac's short date (LrDate in Lightroom).
function Summary.gigLabel( gig, formatDate )
	local parts = { gig.client_name or 'Client' }
	if gig.shoot_starts_at_epoch and formatDate then parts[ #parts + 1 ] = formatDate( gig.shoot_starts_at_epoch ) end
	local what = gig.package_title or gig.niche_name
	if what then parts[ #parts + 1 ] = what end
	if gig.included_photos then parts[ #parts + 1 ] = gig.included_photos .. ' included' end
	if gig.delivery_state == 'in_progress' then
		parts[ #parts + 1 ] = 'In progress, ' .. tostring( gig.photos_in_gallery or 0 ) .. ' uploaded'
	else
		parts[ #parts + 1 ] = 'Waiting for photos'
	end
	return table.concat( parts, ' · ' )
end

return Summary
