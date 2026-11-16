--[[ "RAWWERS Portfolio": what the Publish Service does, without Lightroom.

The portfolio has no albums: its sections are the photographer's niches.
Each published collection in Lightroom is one niche, chosen in the
collection's settings; publishing puts its photos in the portfolio tagged
with that niche (docs/LIGHTROOM_PORTFOLIO.md).

- Publish: each photo is uploaded like a delivery (hash, one PUT or parts,
  finish). Publishing again after a lost connection sends only what is
  missing: the server answers a file already in that niche as "skipped".
- Re-publish (the photo was edited): the new version is uploaded first, then
  the old one removed, so the portfolio never shows both or neither.
- Remove: a photo taken out of the collection is removed from the portfolio.
  The server lets the plug-in remove only photos it published.

Plain Lua 5.1: no Lightroom calls (RawwersPublishProvider.lua is the glue).
]]

local Upload = require 'RawwersUpload'

local Portfolio = {}

--- The niche a collection publishes to: its own choice, else the primary
--- niche for the default collection. nil when neither names one the
--- photographer has.
function Portfolio.nicheFor( niches, chosenSlug, isDefaultCollection )
	for _, niche in ipairs( niches or {} ) do
		if niche.slug == chosenSlug then return niche end
	end
	if isDefaultCollection or not chosenSlug or chosenSlug == '' then
		for _, niche in ipairs( niches or {} ) do
			if niche.primary then return niche end
		end
		if isDefaultCollection then return ( niches or {} )[ 1 ] end
	end
	return nil
end

--- Popup items for the collection settings: one per niche, the primary first.
function Portfolio.nicheItems( niches )
	local items = {}
	for _, niche in ipairs( niches or {} ) do
		items[ #items + 1 ] = { title = niche.name .. ( niche.primary and ' (main)' or '' ), value = niche.slug }
	end
	return items
end

-- Niches: listing and adding (plug-in 1.2.0) ------------------------------------

--- The value of the "Add a niche..." entry in a collection's niche menu.
Portfolio.ADD_NICHE = '__rawwers_add_niche__'

--- The photographer's own niches from the full list, the main one first,
--- then by name: the shape GET /v1/delivery/portfolio gives.
function Portfolio.ownNiches( all )
	local own = {}
	for _, niche in ipairs( all or {} ) do
		if niche.mine then own[ #own + 1 ] = { slug = niche.slug, name = niche.name, primary = niche.primary == true } end
	end
	table.sort( own, function( a, b )
		if a.primary ~= b.primary then return a.primary end
		return string.lower( a.name ) < string.lower( b.name )
	end )
	return own
end

--- Whether another niche can be added: the server's count and maximum.
function Portfolio.canAdd( listing )
	if type( listing ) ~= 'table' then return false end
	local count, maximum = tonumber( listing.count ), tonumber( listing.maximum )
	if not count or not maximum then return false end
	return count < maximum
end

--- The "Add a niche..." menu: a first entry that chooses nothing, then the
--- niches the photographer does not have yet, by name.
function Portfolio.addMenuItems( all )
	local items = { { title = 'Add a niche...', value = '' } }
	local others = {}
	for _, niche in ipairs( all or {} ) do
		if not niche.mine then others[ #others + 1 ] = { title = niche.name, value = niche.slug } end
	end
	table.sort( others, function( a, b ) return string.lower( a.title ) < string.lower( b.title ) end )
	for _, item in ipairs( others ) do items[ #items + 1 ] = item end
	return items
end

--- The publish service's line about the photographer's niches.
function Portfolio.nichesText( listing )
	local own = Portfolio.ownNiches( listing and listing.niches )
	if #own == 0 then return 'Connected. You have no niches yet. Choose one to add.' end
	local names = {}
	for _, niche in ipairs( own ) do names[ #names + 1 ] = niche.name .. ( niche.primary and ' (main)' or '' ) end
	local text = 'Connected. Your niches: ' .. table.concat( names, ', ' ) .. '.'
	if not Portfolio.canAdd( listing ) and listing and listing.maximum then
		text = text .. ' That is the most you can have (' .. tostring( listing.maximum ) .. ').'
	end
	return text
end

--- A collection's niche menu: the photographer's niches, and "Add a
--- niche..." when another can be added.
function Portfolio.collectionMenuItems( listing )
	local items = Portfolio.nicheItems( Portfolio.ownNiches( listing and listing.niches ) )
	if Portfolio.canAdd( listing ) then items[ #items + 1 ] = { title = 'Add a niche...', value = Portfolio.ADD_NICHE } end
	return items
end

--- Adds a niche through the server. Returns { ok = true, listing, added }
--- with the new list, or { ok = false, message } in the server's words.
function Portfolio.addNiche( api, slug )
	if not slug or slug == '' or slug == Portfolio.ADD_NICHE then return { ok = false, message = 'Choose a niche to add.' } end
	local answer = api:addNiche( slug )
	if not answer.ok then return { ok = false, message = answer.message, outcome = answer.outcome } end
	return { ok = true, listing = answer.data, added = answer.data and answer.data.added }
end

--- Publishes one rendered photo. `previousId` is the portfolio photo this
--- one replaces (Lightroom's published photo id), or nil. Returns the
--- upload's result with, when the old version was replaced, `replaced` = its
--- id and `old_left` = true if removing it failed (shown in the summary).
function Portfolio.publishOne( api, nicheSlug, file, previousId )
	local result = Upload.toPortfolio( api, nicheSlug, file )
	if ( result.state == 'uploaded' or result.state == 'skipped' ) and previousId and previousId ~= result.media_asset_id then
		local removed = api:removePortfolioPhoto( previousId )
		result.replaced = previousId
		if not removed.ok and removed.status ~= 404 then result.old_left = true end
	end
	return result
end

--- Removes portfolio photos by id. `onRemoved(id)` is called for each one
--- that is gone (a 404 is gone already). Stops at the first answer that would
--- refuse the rest the same way (connect again, update the plug-in).
--- Returns the list of { id, message } that could not be removed and the
--- stop reason, if any.
function Portfolio.removeAll( api, ids, onRemoved )
	local failed = {}
	for _, id in ipairs( ids or {} ) do
		local answer = api:removePortfolioPhoto( id )
		if answer.ok or answer.status == 404 then
			onRemoved( id )
		else
			failed[ #failed + 1 ] = { id = id, message = answer.message }
			if answer.outcome == 'reauth' or answer.outcome == 'outdated' or answer.outcome == 'cancelled' then
				return failed, answer.outcome
			end
		end
	end
	return failed, nil
end

--- The closing message of a publish: where the photos went and what failed.
function Portfolio.summary( results, nicheName, stopReason )
	local uploaded, skipped, failed, oldLeft = 0, 0, {}, 0
	for _, r in ipairs( results ) do
		if r.state == 'uploaded' then uploaded = uploaded + 1
		elseif r.state == 'skipped' then skipped = skipped + 1
		else failed[ #failed + 1 ] = r end
		if r.old_left then oldLeft = oldLeft + 1 end
	end
	local where = 'your RAWWERS portfolio (' .. tostring( nicheName ) .. ')'
	local lines = {}
	if uploaded > 0 then
		lines[ #lines + 1 ] = ( uploaded == 1 and '1 photo' or ( uploaded .. ' photos' ) ) .. ' sent to ' .. where .. '. They appear once processed, in a minute or two.'
	end
	if skipped > 0 then
		lines[ #lines + 1 ] = ( skipped == 1 and '1 photo was' or ( skipped .. ' photos were' ) ) .. ' already there.'
	end
	if oldLeft > 0 then
		lines[ #lines + 1 ] = ( oldLeft == 1 and 'The old version of 1 edited photo' or ( 'The old versions of ' .. oldLeft .. ' edited photos' ) ) .. ' could not be removed; publish again to retry.'
	end
	for _, r in ipairs( failed ) do
		lines[ #lines + 1 ] = tostring( r.name ) .. ': ' .. tostring( r.message or 'not sent' )
	end
	if stopReason == 'reauth' then
		lines[ #lines + 1 ] = 'This Mac is no longer connected to RAWWERS. Edit the publish service and type a new pairing code.'
	elseif stopReason == 'outdated' then
		lines[ #lines + 1 ] = 'This RAWWERS plug-in is too old for the portfolio. Download the new one from Settings > Connect Lightroom in the RAWWERS Pro app.'
	elseif stopReason == 'cancelled' then
		lines[ #lines + 1 ] = 'Stopped. Publish again to send the rest.'
	end
	local title
	if #failed == 0 and not stopReason then
		title = 'Published to RAWWERS'
	else
		title = 'Some photos were not published'
	end
	return title, table.concat( lines, '\n' )
end

-- The publish service's connection state (1.2.1) ------------------------------------
--[[
One state decides everything the service settings show about the
connection AND whether Save is allowed, so the two can never disagree:

- 'connected' is the only state that allows Save, and the only one whose
  line starts with "Connected". It is reached only after the server answered
  with this Mac's stored pairing (RawwersPublishProvider.lua checks it).
- every other state blocks Save with its own reason.

1.2.0 had two sources: the line came from the check, Save from an observer
whose expression (`connected and nil or reason`) always gave the reason, so
Save stayed blocked even when connected.

Plain Lua 5.1: no Lightroom calls.
]]
-- Kept in this file, not a file of its own: Lightroom does not see a file
-- added to an installed plug-in until it is restarted (1.2.1's dev package).

local Connection = {}
Portfolio.Connection = Connection

local PAIR_HINT = 'Get the code in the RAWWERS Pro app: Settings > Connect Lightroom.'

--- What a state shows: `connected` (Save allowed), `needsCode` (the pairing
--- row), `canRetry` (the Check again button), `text` (the line) and
--- `cantSave` (Lightroom's LR_cantExportBecause: nil allows Save).
--- `detail`: the niches line when connected, else the server's words.
function Connection.view( state, detail )
	if state == 'connected' then
		return { connected = true, needsCode = false, canRetry = false, text = detail or 'Connected.', cantSave = nil }
	end
	local v = { connected = false, needsCode = false, canRetry = false }
	if state == 'checking' then
		v.text = 'Checking the connection to RAWWERS...'
		v.cantSave = 'Checking the connection to RAWWERS. Wait a moment.'
	elseif state == 'connecting' then
		v.text = 'Connecting...'
		v.cantSave = 'Connecting to RAWWERS. Wait a moment.'
	elseif state == 'not_paired' then
		v.needsCode = true
		v.text = 'Not connected. Type the pairing code from the RAWWERS Pro app. ' .. PAIR_HINT
		v.cantSave = 'Connect to RAWWERS first: type the pairing code from the RAWWERS Pro app.'
	elseif state == 'revoked' then
		v.needsCode = true
		v.text = 'Not connected. Type a new pairing code: this Mac\'s pairing was removed or has expired. ' .. PAIR_HINT
		v.cantSave = 'Connect to RAWWERS again: type a new pairing code from the RAWWERS Pro app.'
	elseif state == 'pair_failed' then
		v.needsCode = true
		v.text = 'Not connected. ' .. tostring( detail or 'That pairing code did not work.' )
		v.cantSave = 'Connect to RAWWERS first: type the pairing code from the RAWWERS Pro app.'
	elseif state == 'outdated' then
		v.text = tostring( detail or 'This RAWWERS plug-in is too old.' ) .. ' Download the new one from Settings > Connect Lightroom in the RAWWERS Pro app.'
		v.cantSave = 'This RAWWERS plug-in is too old. Install the new one first.'
	else -- 'unreachable', or any answer that is neither yes nor a revoked pairing
		v.canRetry = true
		v.text = 'Could not check the connection to RAWWERS' .. ( detail and ( ': ' .. tostring( detail ) ) or '.' ) .. ' Check the internet connection, then click Check again.'
		v.cantSave = 'Could not reach RAWWERS to check the connection. Click Check again.'
	end
	return v
end

--- The state for the server's answer to the check (GET the niches with the
--- stored token). Returns state, detail, and whether the stored pairing is
--- dead and must be forgotten (only a 401 says so; a network error or a
--- server error keeps it, it may work again in a minute).
function Connection.fromCheck( answer, nichesText )
	if answer.ok then return 'connected', nichesText, false end
	if answer.outcome == 'reauth' then return 'revoked', nil, true end
	if answer.outcome == 'outdated' then return 'outdated', answer.message, false end
	-- A network error's own text says to export again; only a server's words are kept.
	return 'unreachable', answer.status and answer.message or nil, false
end

return Portfolio
