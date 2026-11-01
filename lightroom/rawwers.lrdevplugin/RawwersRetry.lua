--[[ When to try a request again, and how long to wait first.

A network error and a 5xx are worth another try: a dropped Wi-Fi, a server
restarting. A 4xx is the server's answer and is never repeated: the plugin
shows the server's message instead. A 401 means the device is no longer
connected (revoked, expired) and asks for a new pairing code; a 426, that
this plug-in is older than the server supports and must be updated. The number of
tries is fixed, so the plugin never loops on an error.

Plain Lua 5.1: no Lightroom calls.
]]

local Retry = {}

--- Seconds to wait before each further try: about a minute in all, enough to
--- ride out a router restart, not so long that a dead connection hangs the
--- export.
Retry.delays = { 2, 5, 15, 30 }

--- 'ok', 'retry', 'reauth', 'outdated', 'refused' or 'cancelled', for one answer.
--- `errorCode` is Lightroom's network error code (LrHttp's info.error.errorCode)
--- when the request never got an answer.
function Retry.classify( status, errorCode )
	if errorCode then
		if errorCode == 'cancelled' then return 'cancelled' end
		return 'retry'
	end
	if type( status ) ~= 'number' then return 'retry' end
	if status >= 200 and status < 300 then return 'ok' end
	if status == 401 then return 'reauth' end
	if status == 426 then return 'outdated' end
	if status >= 500 then return 'retry' end
	return 'refused'
end

--- Calls `attempt()` until it gives an answer that is not 'retry', or the
--- delays run out. `attempt` returns (outcome, ...); `sleep(seconds)` waits;
--- `isCanceled()` stops between tries. Returns the last attempt's results.
function Retry.run( attempt, sleep, isCanceled, delays )
	delays = delays or Retry.delays
	local results
	for try = 1, #delays + 1 do
		results = { attempt( try ) }
		if results[ 1 ] ~= 'retry' then return unpack( results ) end
		if try > #delays or ( isCanceled and isCanceled() ) then break end
		sleep( delays[ try ] )
	end
	return unpack( results )
end

return Retry
