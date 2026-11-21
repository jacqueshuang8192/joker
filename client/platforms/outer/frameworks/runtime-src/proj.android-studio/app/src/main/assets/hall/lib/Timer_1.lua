local Timer = class("Timer")

function Timer:ctor()
	return self
end

function Timer:start(this, callback, time)

	if self.duringExcute == true then 
		return
	end

	self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(this, callback), time, false)
	self.duringExcute = true
	
end

function Timer:release()
	dump(self.schedulerID, "release__schedulerID")
	if self.schedulerID then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
		self.schedulerID = nil
		self.duringExcute = false
	end
end

return Timer