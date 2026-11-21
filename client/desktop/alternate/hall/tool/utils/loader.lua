--[[
    自定义类，该类为加载管理类。主要用加载图片，动画，音效以及自定义任务。
    加载资源是异步的，但是加载资源进度则是虚假的，例如我需要加载5份资源，
    每加载一次的进度都是20%，而不是根据总大小与当前加载的大小进行对比。
]]

local scheduler = require("hall.tool.scheduler")
local TaskSch = TaskSch or import(".task_scheduler")
local LoadType = LoadType or import(".load_type")

local Loader = class("Loader")

Loader.EVENT_PROGRESS = "EVENT_PROGRESS"
Loader.EVENT_COMPLETE = "EVENT_COMPLETE"

local textureCache = cc.Director:getInstance():getTextureCache()

function Loader:ctor()
    local dispatcher = cc.load("event").new()
    dispatcher:bind(self)
    self:setData()
end

function Loader:setData()
    self.isLoading = false
    self.remainNum = 0
    self.totalNum = 0 
    self.loadItemTb = {}
    self.tasks = {}
    self:removeAllEventListeners()
end

--[[
    开始加载
]]
function Loader:start()
    assert(not self.isLoading, "it loading now,you can't not call start")
    self.isLoading = true
    if self.remainNum > 0 then
        TaskSch.start()
        return true
    end

    self:onProgress()

    return false
end

--[[
    停止加载
]]
function Loader:stop()
    for _, task in pairs(self.tasks) do
        TaskSch.removeTask(task.handle)
    end
    self.isLoading = false
    self:onComplete(false)
    self:setData()
end

--[[
    添加加载项
    items:准备加载项列表
    callback：加载项列表全部加载完后的回调函数
    evaluateTime：加载一项需要的时间
]]
function Loader:addItems(items, callback, evaluateTime)
    assert(not self.isLoading, "is loading now,you can't call the addItems")
    if not table.empty(items) then
        items = self:regulateItemPaths(items)
    end

    --把尚未加入的item添加到self.loadItemTb，如果已加入，则在已加入项后继续添加该项
    local task = {}
    for _, item in pairs(items) do
        local loadItem = self.loadItemTb[item.path]
        if not loadItem then
            loadItem = {}
            self.loadItemTb[item.path] = loadItem
            task[#task + 1] = item
        end
        loadItem[#loadItem + 1] = item
    end

    self.totalNum = self.totalNum + #task
    self.remainNum = self.totalNum
    evaluateTime = evaluateTime or TaskSch.MAX_TIME_PER_FRAME
    local handle = TaskSch.addTask(task, handler(self, self.startLoad), evaluateTime)
    self.tasks[#self.tasks + 1] = {handle = handle, items = items, callback = callback}
end

--[[
    调整传入的items，针对传入的是动画而做特殊处理
]]
function Loader:regulateItemPaths(items)
    local newItems = {}
    for _, item in pairs(items) do
        newItems[#newItems + 1] = self:regulateItemPath(item)
    end
    return newItems
end

function Loader:regulateItemPath(item)
    if item.type == LoadType.ANIMATION then
        local itemImage = {type = LoadType.IMAGE, path = item.path .. ".png"}
        itemImage.callback = function()
            local atlasFile = item.path .. ".atlas"
            animationCache:loadSkeleton(item.path .. ".skel", atlasFile, nil, 
                function(data)
                    if item.callback then
                        item.callback(data)
                    end
                    self:checkTask(itemImage.path, data)
                end)
            return true
        end
        return itemImage
    end

    return item
end

--[[
    开始加载资源
]]
function Loader:startLoad(item)
    local path = item.path
    local loadType = item.type
    local data
    if loadType == LoadType.IMAGE then 
        self:loadImage(path, item.callback)
        return true
    elseif loadType == LoadType.SOUND then
        data = self:loadSound(path)
    elseif loadType == LoadType.CUSTOM then
        if self:loadCustom(path) then
            return
        end
    end

    if item.callback then
        item.callback(item.path, data)
    end

    self:checkTask(path, data)

    return data
end

--[[
    加载图片
]]
function Loader:loadImage(path, callback)
    textureCache:addImageAsync(path, function(data)
            local notComplete
            if callback then
                notComplete = callback(path, data)
            end

            if not notComplete then
                self:checkTask(path, data)
            end
        end)
end

--[[
    加载图片资源
]]
function Loader:loadSound(path)
    audio.preloadSound(path)
    return true
end

--[[
    加载自定义任务
]]
function Loader:loadCustom(path)
    local data = path()
    return data
end

--[[
    检测任务是否加载完成，如果任务加载完成则回调callback。
    如果该资源是第一次加载，则会去掉onProgress更新进度
]]
function Loader:checkTask(path, data)
    for k, task in pairs(self.tasks) do
        for i, item in pairs(task.items) do
            if item.path == path then
                task.items[i] = nil
                if table.empty(task.items) then 
                    local callback = task.callback
                    if callback then 
                        callback(self, item)
                    end
                    self.tasks[k] = nil
                end
            end
        end
    end

    if self.loadItemTb[path] then
        self.loadItemTb[path] = nil
        self:onProgress(path, data)
    end
end

--[[
    发送资源加载进度
]]
function Loader:onProgress(path, data)
    if not self.isLoading then
        return
    end

    self.remainNum = math.max(0, self.remainNum - 1)
    self:dispatchEvent({name = Loader.EVENT_PROGRESS
        , data = {total = self.totalNum, left = self.remainNum, path = path, data = data}})
    if self.remainNum == 0 then
        self:onComplete(true)
    end
end

--[[
    发送资源加载完成事件
]]
function Loader:onComplete(isCompleted)
    self.isLoading = false
    self:dispatchEvent({name = Loader.EVENT_COMPLETE, data = isCompleted})
end

return Loader