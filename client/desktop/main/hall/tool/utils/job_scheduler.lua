local JobScheduler = {}

JobScheduler.MAX_TIME_PER_FRAME = cc.Director:getInstance():getAnimationInterval() * 0.6
local scheduler = require("hall.tool.scheduler")

-- local scheduler = cc.load("scheduler")
local handle
local jobHandle = 0
local jobs = {}
local startTime
local interval
local suspendJob
local currentJob
local running
local adds = {}
local removes = {}

local function runOne(job)
    if job == suspendJob then
        scheduler.unscheduleGlobal(handle)
        handle = nil
        return false
    end

    local now = os.now()
    if interval then
        interval = now - startTime
    else
        interval = 0
    end

    if now - job.latestRunTime >= job.delay
        and interval + job.evaluateTime <= JobScheduler.MAX_TIME_PER_FRAME then
        currentJob = job
        job.func(job.args[1])
        table.remove(job.args, 1)
        currentJob = nil
        job.latestRunTime = os.now()
        return true
    end

    return false
end

local function onEnterFrame(dt)
    running = true
    startTime = os.now()
    interval = nil

    local completedJobs = {}
    for index, job in ipairs(jobs) do
        if not job.latestRunTime then
            job.latestRunTime = os.now()
        end

        while #job.args > 0 do
            if not handle then
                break
            end
            if not runOne(job) then
                break
            end
        end
        if #job.args == 0 then
            completedJobs[#completedJobs + 1] = job.handle
            if job.onComplete then
                job.onComplete(true)
            end
        end
    end

    running = false

    for _, jobHandle in ipairs(completedJobs) do
        JobScheduler.removeJob(jobHandle)
    end

    if #adds > 0 then
        for _, job in ipairs(adds) do
            jobs[#jobs + 1] = job
        end
        adds = {}
    end

    if #removes > 0 then
        for _, jobHandle in ipairs(removes) do
            JobScheduler.removeJob(jobHandle)
        end
        removes = {}
    end

    if table.empty(jobs)
        and handle then
        scheduler.unscheduleGlobal(handle)
        handle = nil
    end
end

--[[
    添加异步处理
    @param args 异步处理参数，每一项会作为参数传入func
    @param func 工作处理函数
    @param evaluateTime 每执行一次func的预估时长(秒数)
    @param delay 执行完一项后的间隔时长(秒数)
    @param onComplete 处理完后的回到函数
]]
function JobScheduler.addJob(args, func, evaluateTime, delay, onComplete)
    -- args = copy(args)
    if evaluateTime == nil then evaluateTime = 0 end
    if evaluateTime > JobScheduler.MAX_TIME_PER_FRAME then 
        evaluateTime = JobScheduler.MAX_TIME_PER_FRAME
    end
    if delay == nil then delay = 0 end
    local job = {args = args, func = func
        , evaluateTime = evaluateTime, delay = delay
        , onComplete = onComplete}
    jobHandle = jobHandle + 1
    job.handle = jobHandle

    if running then
        adds[#adds + 1] = job
    else
        jobs[#jobs + 1] = job
    end

    return jobHandle
end

--[[
    移除任务项
    @param jobHandle 调用addJob时添加返回的任务句柄
]]
function JobScheduler.removeJob(jobHandle)
    if running then
        removes[#removes + 1] = jobHandle
        return
    end

    for index, job in ipairs(jobs) do
        if job.handle == jobHandle then
            table.remove(jobs, index)
            break
        end
    end
end

--[[
    开始任务运行
]]
function JobScheduler.run()
    if handle == nil 
        and not suspendJob
        and not table.empty(jobs) then
        handle = scheduler.scheduleUpdateGlobal(onEnterFrame)
    end
end

--[[
    暂停任务运行
]]
function JobScheduler.suspend()
    suspendJob = currentJob

    if handle then
        scheduler.unscheduleGlobal(handle)
        handle = nil
    end
end

--[[
    继续任务运行
]]
function JobScheduler.resume()
    if suspendJob then
        table.remove(suspendJob.args, 1)
        suspendJob = nil
    end
    
    if handle == nil 
        and not table.empty(jobs) then
        handle = scheduler.scheduleUpdateGlobal(onEnterFrame)
    end
end

--[[
    停止任务运行
]]
function JobScheduler.stop()
    for index, job in pairs(jobs) do
        if job.onComplete then
            --此情况下，如果在回调中添加或者移除job的操作，会引起问题
            job.onComplete(false)
        end
        jobs[index] = nil
    end
    suspendJob = nil
    startTime = nil
    interval = nil
    currentJob = nil
    if handle then
        scheduler.unscheduleGlobal(handle)
        handle = nil
    end
end

--[[
    获取当前任务列表
]]
function JobScheduler.getJobs()
    return jobs
end

--[[
    获取当前任务是否在运行
]]
function JobScheduler.isRunning()
    return handle ~= nil
end

return JobScheduler