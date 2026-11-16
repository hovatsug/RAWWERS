--[[ The publish service's connection state, without Lightroom (1.2.1).

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

local Connection = {}

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

return Connection
