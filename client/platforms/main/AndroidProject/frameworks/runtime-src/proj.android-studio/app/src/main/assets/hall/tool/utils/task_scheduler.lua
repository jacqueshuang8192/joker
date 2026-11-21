local TaskScheduler = {}

TaskScheduler.MAX_TIME_PER_FRAME = cc.Director:getInstance():getAnimationInterval() * 0.6

local scheduler = require("hall.tool.scheduler")
local frameHandle --全局帧事件
local taskHandle = 0 --任务句柄
local tasks = {} --当前全部任务
local running --是否在运行当前全部任务
local adds = {} --在运行当前全部任务时加入的所有任务
local removes = {} --需要移除的任务
local suspendTask
local currentTask
local interval
local startTime

--[[
运行单个任务
]]
local function runTask(task)
    if task == suspendTask then
        scheduler.unscheduleGlobal(frameHandle)
        frameHandle = nil
        return false
    end

    local nowTime = os.now()
    if interval then
        interval = nowTime - startTime
    else
        interval = 0
    end

    if nowTime - task.lastRunTime >= task.delay
        and interval + task.evaluateTime <= TaskScheduler.MAX_TIME_PER_FRAME then
        currentTask = task
        task.callback(task.params[1])
        table.remove(task.params, 1)
        currentTask = nil
        task.lastRunTime = os.now()
        return true
    end

    return false
end

--[[
运行当前全部任务
]]
local function onEnterFrame(dt)
    running = true
    startTime = os.now()
    interval = nil

    local completedTasks = {}
    for index, task in ipairs(tasks) do
        if not task.lastRunTime then
            task.lastRunTime = os.now()
        end

        while #task.params > 0 do
            if not frameHandle then
                break
            end
            if not runTask(task) then
                break
            end
        end

        --当前任务全部完成后回掉完成函数
        if #task.params == 0 then
            completedTasks[#completedTasks + 1] = task.handle
            if task.onComplete then
                task.onComplete(true)
            end
        end
    end

    running = false

    for _, taskHandle in ipairs(completedTasks) do
        TaskScheduler.removeTask(taskHandle)
    end

    if #adds > 0 then
        for _, task in ipairs(adds) do
            tasks[#tasks + 1] = task
        end
        adds = {}
    end

    if #removes > 0 then
        for _, taskHandle in ipairs(removes) do
            TaskScheduler.removeTask(taskHandle)
        end
        removes = {}
    end

    if table.empty(tasks)
        and frameHandle then
        scheduler.unscheduleGlobal(frameHandle)
        frameHandle = nil
    end
end

--[[
异步处理
params:异步处理参数，params应为一个table,里面的每一项都会作为参数传入callback中
callback:params每一项对应的处理函数
evaluateTime:执行每一次callback的时间
delay:每项执行的时间间隔
onComplete:执行完本次任务的回掉函数
]]
function TaskScheduler.addTask(params, callback, evaluateTime, delay, onComplete)
    if evaluateTime == nil then evaluateTime = 0 end
    if evaluateTime > TaskScheduler.MAX_TIME_PER_FRAME then 
        evaluateTime = TaskScheduler.MAX_TIME_PER_FRAME
    end
    if delay == nil then delay = 0 end
    local task = {params = params, callback = callback, evaluateTime = evaluateTime,
    				delay = delay, onComplete = onComplete}
    taskHandle = taskHandle + 1
    task.handle = taskHandle

    if running then
        adds[#adds + 1] = task
    else
        tasks[#tasks + 1] = task
    end

    return taskHandle
end

--[[
移除任务
]]
function TaskScheduler.removeTask(taskHandle)
    if running then
        removes[#removes + 1] = taskHandle
        return
    end

    for index, task in ipairs(tasks) do
        if task.handle == taskHandle then
            table.remove(tasks, index)
            break
        end
    end
end

--[[
开始运行
]]
function TaskScheduler.start()
    if frameHandle == nil and not table.empty(tasks) and not suspendTask then
        frameHandle = scheduler.scheduleUpdateGlobal(onEnterFrame)
    end
end

--[[
停止任务
]]
function TaskScheduler.stop()
    for index, task in pairs(tasks) do
        if task.onComplete then
            task.onComplete(false)
        end
        tasks[index] = nil
    end
    suspendTask = nil
    startTime = nil
    interval = nil
    currentTask = nil
    if frameHandle then
        scheduler.unscheduleGlobal(frameHandle)
        frameHandle = nil
    end
end

--[[
    暂停任务运行
]]
function TaskScheduler.suspend()
    suspendTask = currentTask

    if frameHandle then
        scheduler.unscheduleGlobal(frameHandle)
        frameHandle = nil
    end
end

--[[
    继续任务运行
]]
function TaskScheduler.resume()
    if suspendTask then
        table.remove(suspendTask.params, 1)
        suspendTask = nil
    end
    
    if frameHandle == nil 
        and not table.empty(tasks) then
        frameHandle = scheduler.scheduleUpdateGlobal(onEnterFrame)
    end
end


--[[
获取当前任务列表
]]
function TaskScheduler.getTasks()
    return tasks
end

--[[
判断当前任务运行状态
]]
function TaskScheduler.isRunning()
    return frameHandle ~= nil
end

return TaskScheduler

