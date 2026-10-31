--[[ Uploading a few photos at once while Lightroom renders the next ones.

Lightroom runs plug-in tasks cooperatively on its main thread (LrTasks); a
task waiting on the network (LrHttp) lets the others run, so a few upload
tasks give a few uploads at once. The export loop adds each rendered photo
here and waits while `window` photos are already queued or uploading, so
rendering never runs far ahead of the uploads and the progress bar tracks
what has really been sent.

`spawn(fn)` starts a task (LrTasks.startAsyncTask) and `sleep(seconds)`
yields (LrTasks.sleep); tests give a small scheduler of their own. A
'reauth' result stops every worker: the device is no longer connected, and
trying the rest would only repeat the same refusal.

Plain Lua 5.1: no Lightroom calls.
]]

local Pipeline = {}
Pipeline.__index = Pipeline

Pipeline.DEFAULT_WORKERS = 3
local POLL = 0.1

--- opts: workers, window, spawn, sleep, isCanceled, process(job) -> result,
--- onResult(job, result) (optional).
function Pipeline.new( opts )
	local self = setmetatable( {}, Pipeline )
	self.workers = math.max( 1, opts.workers or Pipeline.DEFAULT_WORKERS )
	self.window = math.max( self.workers, opts.window or self.workers )
	self.spawn, self.sleep = opts.spawn, opts.sleep
	self.isCanceled = opts.isCanceled or function() return false end
	self.process, self.onResult = opts.process, opts.onResult
	-- head is the next job to take, tail the last one added. Lua's # is not
	-- defined once the front of the table has been emptied, so neither end
	-- is ever worked out from it.
	self.queue, self.head, self.tail = {}, 1, 0
	self.inFlight, self.running = 0, 0
	self.closed, self.stopped = false, false
	self.results = {}
	return self
end

function Pipeline:pending()
	return ( self.tail - self.head + 1 ) + self.inFlight
end

--- Why no more photos should start: 'cancelled', 'reauth' or nil.
function Pipeline:stopReason()
	if self.stopped then return self.stopped end
	if self.isCanceled() then return 'cancelled' end
	return nil
end

function Pipeline:start()
	for _ = 1, self.workers do
		self.running = self.running + 1
		self.spawn( function()
			while true do
				if self:stopReason() then break end
				local job = self.head <= self.tail and self.queue[ self.head ] or nil
				if job then
					self.queue[ self.head ] = nil
					self.head = self.head + 1
					self.inFlight = self.inFlight + 1
					local result = self.process( job )
					self.inFlight = self.inFlight - 1
					self.results[ #self.results + 1 ] = { job = job, result = result }
					if self.onResult then self.onResult( job, result ) end
					if result and result.state == 'reauth' then self.stopped = 'reauth' end
				elseif self.closed then
					break
				else
					self.sleep( POLL )
				end
			end
			self.running = self.running - 1
		end )
	end
end

--- Queue a rendered photo, waiting first while the window is full. Returns
--- false once the run has stopped, and the job is not queued.
function Pipeline:add( job )
	while self:pending() >= self.window and not self:stopReason() do
		self.sleep( POLL )
	end
	if self:stopReason() then return false end
	self.tail = self.tail + 1
	self.queue[ self.tail ] = job
	return true
end

--- No more photos: wait for the workers to finish what they have.
--- Returns the results, in the order they finished, and the stop reason.
function Pipeline:finish()
	self.closed = true
	while self.running > 0 do
		self.sleep( POLL )
	end
	return self.results, self:stopReason()
end

--- Jobs queued but never started (a stop came first).
function Pipeline:notStarted()
	local left = {}
	for i = self.head, self.tail do
		if self.queue[ i ] then left[ #left + 1 ] = self.queue[ i ] end
	end
	return left
end

return Pipeline
