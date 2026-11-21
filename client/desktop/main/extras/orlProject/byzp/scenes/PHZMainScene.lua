-- local MainLayer  = require("byzp.view.PHZMainLayer")
local PHZMainScene = class("PHZMainScene", function()
    return display.newScene("PHZMainScene")
end)

PHZMainScene.TAG_MAINLAYER = 10

function PHZMainScene:ctor()
	g_PHZMainScene = self
	self.waitInitDataQueue = {}
	self:loadScriptPath()
	self:loadResources()
	self:loadResTick()
	self:setNodeEventEnabled(true)

	self:init()
end

function PHZMainScene:onEnter()
end

function PHZMainScene:onExit()
	self:removeSearchPathHead()
	self.mainLayer = nil


end

--加载路径文件
function PHZMainScene:loadScriptPath()
    local scriptPath = "byzp.logic.LuaHeader"
    package.loaded[scriptPath]  = nil  
    require(scriptPath) 
end

function PHZMainScene:loadResources()
	table.insert(self.waitInitDataQueue, "PHZCardBig")
    table.insert(self.waitInitDataQueue, "PHZCardLitter")
    table.insert(self.waitInitDataQueue, "PHZOther")
end

function PHZMainScene:loadResTick()
    if table.nums(self.waitInitDataQueue) == 0 then
        return true
    end
    for key, value in pairs(self.waitInitDataQueue) do
        if value then
            self.key = key
             if value == "PHZCardBig" then
                display.addSpriteFrames("PHZCardBig.plist","PHZCardBig.png")
             elseif value == "BJLCard" then
                display.addSpriteFrames("PHZCardLitter.plist","PHZCardLitter.png")
             elseif value == "PHZOther" then
                display.addSpriteFrames("PHZOther.plist","PHZOther.png")
             end
            break
        end  
    end
    table.remove(self.waitInitDataQueue, self.key)
    self:loadResTick()
end

function PHZMainScene:removeSearchPathHead()
	local searchPaths = cc.FileUtils:getInstance():getSearchPaths()
    local keyTable = {}
    for i,v in ipairs(searchPaths) do
        if string.find(v,"byzp") then
            table.insert(keyTable,i)
        end
    end
	 --删除缓存路径
    for i=#keyTable,1,-1 do
        table.remove(searchPaths,keyTable[i])
    end
    cc.FileUtils:getInstance():setSearchPaths(searchPaths)
end

function PHZMainScene:init()
	self.mainLayer = nil
	self:initMainLayer()

    self.m_bOutCard = false     --能否出牌
    self.m_CardReady = false    --字牌是否就绪


    --test
    self.m_bOutCard = true
    self.m_CardReady = true

    CLUB_ID = nil
end

--加载主界面
function PHZMainScene:initMainLayer()
    local MainLayer  = require("byzp.view.PHZMainLayer")
	self.mainLayer = MainLayer.new()
	self:addChild(self.mainLayer,PHZMainScene.TAG_MAINLAYER)
end

--字牌整理就绪
function PHZMainScene:isCardReady()
    return self.m_CardReady
end

--能否出牌
function PHZMainScene:ableOutCard()
    return self.m_bOutCard
end

--获取视图座位
function PHZMainScene:getViewChairId(__chairId)
    if __chairId == INVALID_CHAIR then
        print("chairId is INVALID_CHAIR!!!")
        return __chairId
    end
    --转换椅子
    local wViewId = 0
    local wMeChairId = self:getMeChairId()
    if wMeChairId then
        wViewId = (__chairId+2*GAME_PLAYER-wMeChairId) + 0
        wViewId = math.floor(wViewId % GAME_PLAYER)
    end
    return wViewId
end

--------------------------------------------------------------------------------
----------------------客户端发送消息只发送数据不做刷新处理----------------------
--------------------------------------------------------------------------------
--发送出牌消息
function PHZMainScene:onOutCard( card )
    print("====出牌====")
end


--------------------------------------------------------------------------------
--------------------------服务器发送消息客户端刷新处理--------------------------
--------------------------------------------------------------------------------
--游戏开始
function PHZMainScene:OnSubGameStart(data)
    print("===返回游戏开始===")
end

--用户补牌
function PHZMainScene:OnSubBuCard(data)
    print("===返回用户补牌===")
end

--用户扫穿
function PHZMainScene:OnSubSaoExCard(data)
    -- body
end

--用户四张
function PHZMainScene:onSubFourCard(data)
     -- body
end 

--用户扫牌
function PHZMainScene:OnSubSaoCard(data)
     -- body
end 

--用户碰牌
function PHZMainScene:OnSubPengCard(data)
     -- body
end

--用户吃牌
function PHZMainScene:OnSubChiCard(data)
     -- body
end

--操作提示
function PHZMainScene:OnSubOperateNotify(data)
     -- body
end

--出牌提示
function PHZMainScene:OnSubOutCardNotify(data)
     
end

--用户出牌
function PHZMainScene:OnSubOutCard(data)
     --g_CardScene:playerOutCard(0,)
end

--发牌命令
function PHZMainScene:OnSubSendCard(data)
     -- body
end

--游戏结束
function PHZMainScene:OnSubGameEnd(data)
     -- body
end

--游戏托管
function PHZMainScene:OnSubTuoGuan(data)
     -- body
end
--------------------------------------------------------------------------------
-------------------------------其他函数逻辑处理---------------------------------
--------------------------------------------------------------------------------

--复原游戏进行状态
function PHZMainScene:restoreStatusPlay(data)
     -- body
end
return  PHZMainScene