require("cdpaohuzi.logic.CMD_BYZP")
local  scheduler = require("framework.scheduler")
local  phzServer = import("cdpaohuzi.handle.PHZSendHandle")
local  phzHandle = import("cdpaohuzi.handle.PHZReceiveHandle")
local  PROTOCOL = require("cdpaohuzi.handle.PaohuziCDProtocol")

local PHZMainScene = class("PHZMainScene", function()
    return display.newScene("PHZMainScene")
end)

PHZMainScene.TAG_MAINLAYER = 1

function PHZMainScene:ctor()
    -- cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)



    self:loadScriptPath()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(phzHandle.new())
    g_PHZMainScene = self
    self.waitInitDataQueue = {}
    self:loadResources()
    self:loadResTick()
    self:setNodeEventEnabled(true)

    self:init()

     audio.stopMusic(true) 
    audio.playMusic("cdpaohuzi/res/sound/byzp_Music.mp3", true)
end

function PHZMainScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))

end

function PHZMainScene:setRootSize(node)
    -- local children = node:getChildren()
    -- if not children or 0 == #children then
    --     return
    -- end 

    -- for i, child in ipairs(children) do
    --     local tempX = child:getPositionX()
    --     child:setPositionX(tempX*self:_getScaleParam2())
    --     self:setRootSize(child)
    -- end

end

function PHZMainScene:gameLoginRoom()
    --print("==USER_INFO['tid']===",USER_INFO["tid"])
    --print("==USER_INFO['seat_id']===",USER_INFO["seat_id"])
    --print("==USER_INFO['activity_id']===",USER_INFO["activity_id"])
    
    phzServer:LoginRoom(USER_INFO["tid"],USER_INFO["seat_id"],USER_INFO["activity_id"])
    HEART_BEAT_TID = USER_INFO["tid"]
end

function PHZMainScene:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function PHZMainScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(phzHandle.new())
    self:gameLoginRoom()
    --require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end

function PHZMainScene:onEnter()
    self:gameLoginRoom()

    --print("===USER_INFO['tid']===")

end

function PHZMainScene:onExit()
    self:removeSearchPathHead()
    self.mainLayer = nil
    
end

--¼ÓÔØÂ·¾¶ÎÄ¼þ
function PHZMainScene:loadScriptPath() 
    local scriptPath = "cdpaohuzi.logic.LuaHeader"
    package.loaded[scriptPath]  = nil   
    require(scriptPath)                                         
end

function PHZMainScene:loadResources() 
    table.insert(self.waitInitDataQueue, "PHZCardBig")
    table.insert(self.waitInitDataQueue, "PHZCardLitter")
    table.insert(self.waitInitDataQueue, "PHZOther")
    table.insert(self.waitInitDataQueue, "PHZSetting")
    table.insert(self.waitInitDataQueue, "PHZEndResult")
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
            elseif value == "PHZSetting" then
                display.addSpriteFrames("PHZSetting.plist","PHZSetting.png")
            elseif value == "PHZEndResult" then
                display.addSpriteFrames("PHZAllResult.plist","PHZAllResult.png")
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
        if string.find(v,"cdpaohuzi") then
            table.insert(keyTable,i)
        end
    end
     --É¾³ý»º´æÂ·¾¶
    for i=#keyTable,1,-1 do
        table.remove(searchPaths,keyTable[i])
    end
    cc.FileUtils:getInstance():setSearchPaths(searchPaths)
end

function PHZMainScene:init() 
    self.mainLayer = nil
    self:initMainLayer()

    self.m_lCellScore = 0       --»ù´¡»ý·Ö

    self.GameState = 0          --0 ×¼±¸½×¶Î 1£ºÓÎÏ·½×¶Î

    self.m_wOutCardUser = INVALID_CHAIR  --ÒÔÇ°³öÅÆÈËµÄseat_id

    self.m_cbOutCardData = 0 --ÒÔÇ°³öµÄÅÆ
    self.m_cbCurrentCard = 0 --ÏÖÔÚ³öµÄÅÆ

    self.m_bOutCard = false     --ÄÜ·ñ³öÅÆ
    self.m_CardReady = false    --×ÖÅÆÊÇ·ñ¾ÍÐ÷

    --Íæ¼Ò×Ô¼ºµÄ×ùÎ»ºÅ
    self.m_seatID = nil
    self.m_bankerSeatID = nil

    --×Ô½¨·¿ÅäÖÃ
    self.m_nMasterID = 0     --·¿Ö÷ID
    self.m_nRoomID = 0       --·¿¼äºÅ
    self.m_bGameCount = 0    --ÒÑÍæ´ÎÊý
    self.m_bMaxGameCount = 0 --×î´ó´ÎÊý

    self.m_diCardCount = 0   --µ×ÅÆ»¹Ê£¶àÉÙ

    self.m_isGameOver = false --ÊÇ·ñÈ«²¿½áÊøÓÎÏ·

    --ÆäËûÍæ¼ÒÐÅÏ¢
    self.otherInfo = {}

    self.isGetJieSanRoom = false

    --×îÐÂÃþµÄÅÆ
    self.m_newDiCard = nil

    -- --test
    -- self.m_CardReady = true
    -- self.m_bOutCard = true
end

function PHZMainScene:clearData()

    self.m_wOutCardUser = INVALID_CHAIR  --ÒÔÇ°³öÅÆÈËµÄseat_id

    self.m_cbOutCardData = 0 --ÒÔÇ°³öµÄÅÆ
    self.m_cbCurrentCard = 0 --ÏÖÔÚ³öµÄÅÆ


    --ÏÈ½«×´Ì¬ÒÔ¼°ÄÜ·ñ³öÅÆÉè¶¨ºÃ
    self.m_bOutCard = false     --ÄÜ·ñ³öÅÆ
    self.m_CardReady = false    --×ÖÅÆÊÇ·ñ¾ÍÐ÷

    --Íæ¼Ò×Ô¼ºµÄ×ùÎ»ºÅ
    self.m_seatID = nil
    self.m_bankerSeatID = nil

    --×Ô½¨·¿ÅäÖÃ
    self.m_nMasterID = 0     --·¿Ö÷ID
    self.m_nRoomID = 0       --·¿¼äºÅ
    self.m_bGameCount = 0    --ÒÑÍæ´ÎÊý
    self.m_bMaxGameCount = 0 --×î´ó´ÎÊý

    self.m_diCardCount = 0   --µ×ÅÆ»¹Ê£¶àÉÙ

    self.m_isGameOver = false--ÊÇ·ñÈ«²¿½áÊøÓÎÏ·

     --×îÐÂÃþµÄÅÆ
    self.m_newDiCard = nil
end

--¼ÓÔØÖ÷½çÃæ
function PHZMainScene:initMainLayer()
    local MainLayer  = require("cdpaohuzi.view.PHZMainLayer")
    self.mainLayer = MainLayer.new()
    self:addChild(self.mainLayer,PHZMainScene.TAG_MAINLAYER)
end

--×ÖÅÆÕûÀí¾ÍÐ÷
function PHZMainScene:isCardReady()
    return self.m_CardReady
end

--ÄÜ·ñ³öÅÆ
function PHZMainScene:ableOutCard()
    return self.m_bOutCard
end

--»ñÈ¡ÊÓÍ¼×ùÎ»
function PHZMainScene:getViewChairId(__chairId)
    if __chairId == INVALID_CHAIR then
        --print("chairId is INVALID_CHAIR!!!")
        return INVALID_CHAIR
    end
    --×ª»»ÒÎ×Ó
    local wViewId = 0
    local wMeChairId = self:getMeChairId()
    if wMeChairId then
        wViewId = (__chairId+2*GAME_PLAYER-wMeChairId) + 0
        wViewId = math.floor(wViewId % GAME_PLAYER)
        if wViewId == 1 then
            wViewId = 2
        elseif wViewId == 2 then
            wViewId = 1
        end
    end
    return wViewId
end

function PHZMainScene:getMeChairId()
    return self.m_seatID
end

--»ñÈ¡µ±Ç°×ÖÅÆ
function PHZMainScene:getCurrentCard()
    return self.m_cbCurrentCard
end

--------------------------------------------------------------------------------
            ---------------------Íæ¼ÒÌýÅÆº¯Êý begain-----------------------
--------------------------------------------------------------------------------

--»ñÈ¡ËùÓÐ´ò³öµÄÅÆµÄ¼¯ºÏ
function PHZMainScene:get_all_out_cardArr()
    if not g_CardScene then return nil end
    local tempArr = {}
    local handCardNodes = g_CardScene.handCardNodes or {}
    for idx,cardNode in ipairs(handCardNodes) do
        local cardId = cardNode.cardId
        table.insert(tempArr, cardId)
    end
    for k,v in pairs(g_CardScene.m_DCardData) do
        for k1,v1 in pairs(v) do
            table.insert(tempArr,v1)
        end
    end
    for k,v in pairs(g_CardScene.m_WeaveItem) do
        for k1,v1 in pairs(v) do
            for k2,v2 in pairs(v1.cbCardList) do
                table.insert(tempArr,v2)
            end
        end
    end
    
    return tempArr
end

--»ñÈ¡Ä³ÕÅÌýÅÆ»¹Ê£ÏÂµÄÊýÁ¿
function PHZMainScene:getTingCardNumByCardID(ID)
    if not ID then return 0 end
    local tempArr = self:get_all_out_cardArr()
    if ID == 9 then
        --print("0000000000000000000")
        dump(g_CardScene.m_DCardData)
        dump(tempArr)
    end
    if not tempArr then return 0 end
    local tempCardNum = 0
    for k,v in pairs(tempArr) do
        if ID == v then
            tempCardNum = tempCardNum + 1
        end
    end
    tempCardNum = 4 - tempCardNum 
    return tempCardNum
end

--«@È¡×Ô¼ºËùÓÐ²Ù×÷µÄÅÅ£¨³Ô¡¢ÅÜ¡¢Ìá¡¢ÙË£©
function PHZMainScene:get_my_down_card()
    local tempArr = {}
    if not g_CardScene.m_WeaveItem[0] then return tempArr end
    tempArr = g_CardScene.m_WeaveItem[0] 
    return tempArr
end


--------------------------------------------------------------------------------
            ---------------------Íæ¼ÒÌýÅÆº¯Êý end-----------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
----------------------¿Í»§¶Ë·¢ËÍÏûÏ¢Ö»·¢ËÍÊý¾Ý²»×öË¢ÐÂ´¦Àí----------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------·þÎñÆ÷·¢ËÍÏûÏ¢¿Í»§¶ËË¢ÐÂ´¦Àí--------------------------
--------------------------------------------------------------------------------
--ÓÎÏ·¿ªÊ¼
function PHZMainScene:OnSubGameStart(data)
    print("===·µ»ØÓÎÏ·¿ªÊ¼===")
end

--ÓÃ»§²¹ÅÆ
function PHZMainScene:OnSubBuCard(data)
    print("===·µ»ØÓÃ»§²¹ÅÆ===")
end

--ÓÃ»§ÅÜ
function PHZMainScene:OnSubSaoExCard(data)
    local wViewId = self:getViewChairId(data.seat_id)

    if self.m_wOutCardUser~=INVALID_CHAIR then
        local wResViewId = self:getViewChairId(self.m_wOutCardUser)
        g_CardScene:onEventCard(wViewId,wResViewId)
    end
    g_CardScene:onSaoExCard(wViewId,data.CardValue,4,true)
end

function PHZMainScene:OnSubSaoExCardTi(data)
    local wViewId = self:getViewChairId(data.seat_id)

    if self.m_wOutCardUser~=INVALID_CHAIR then
        local wResViewId = self:getViewChairId(self.m_wOutCardUser)
        g_CardScene:onEventCard(wViewId,wResViewId)
    end
    g_CardScene:onSaoExCard(wViewId,data.CardValue,4,false)
end
--ÓÃ»§ËÄÕÅ
function PHZMainScene:onSubFourCard(data)
    
end 

--ÓÃ»§ÙËÅÆ
function PHZMainScene:OnSubSaoCard(data)
    local wViewId = self:getViewChairId(data.seat_id)
    if self.m_wOutCardUser~=INVALID_CHAIR then
        local wResViewId = self:getViewChairId(self.m_wOutCardUser)
        g_CardScene:onEventCard(wViewId,wResViewId)
    end
    --´Ë´¦È«²¿×÷ÎªÃ÷Ò»ÕÅ°µÈýÕÅ
    g_CardScene:onSaoCard(wViewId,data.CardValue,data.cardType)
end 

--ÓÃ»§ÅöÅÆ
function PHZMainScene:OnSubPengCard(data)
    local wViewId = self:getViewChairId(data.seat_id)
    if self.m_wOutCardUser~=INVALID_CHAIR then
        local wResViewId = self:getViewChairId(self.m_wOutCardUser)
        g_CardScene:onEventCard(wViewId,wResViewId)
    end
    g_CardScene:onPengCard(wViewId,data.CardValue)
end


--ÓÃ»§³ÔÅÆ
function PHZMainScene:OnSubChiCard(data)
     -- body
end

--ÓÃ»§³öÅÆ
function PHZMainScene:OnSubOutCard(data)
    print("========OnSubOutCard===±¾´ÎÍæ¼Ò³öÅÆ×ùÎ»ºÅ===",self:getViewChairId(data.seat_id))
    self.m_wOutCardUser = data.seat_id
    self.m_cbOutCardData = data.CardValue
    self.m_cbCurrentCard = data.CardValue
    local wViewId = self:getViewChairId(self.m_wOutCardUser)
    print("========ÉÏÒ»¸ö³öÅÆÍæ¼Ò×ùÎ»ºÅ===",wViewId)
    g_CardScene:playerOutCard(wViewId,self.m_cbOutCardData)
end

function PHZMainScene:OnSubSendCardWei()
    if self.m_cbOutCardData ~= 0 then
        if self.m_wOutCardUser == INVALID_CHAIR then self.m_wOutCardUser = 0 end
        local wDisViewId = self:getViewChairId(self.m_wOutCardUser)
        --print("====m_cbOutCardData",wDisViewId,self.m_cbOutCardData)
        g_CardScene:onDiscardCard(wDisViewId,self.m_cbOutCardData)
    end
end

--·¢ÅÆµ¥ÕÅ
function PHZMainScene:OnSubSendCard(seat_id,cardValue)
    --print("==OnSubSendCard seat_id",self:getViewChairId(self.m_seatID))
    --print("======OnSubSendCardcardValue===",cardValue)
    local wViewId = self:getViewChairId(seat_id)
    --¶ªÆúÔ­À´¾ÉµÄÅÆ
    if self.m_cbOutCardData ~= 0 then
        if self.m_wOutCardUser == INVALID_CHAIR then self.m_wOutCardUser = 0 end
        local wDisViewId = self:getViewChairId(self.m_wOutCardUser)
        --print("====m_cbOutCardData",wDisViewId,self.m_cbOutCardData)
        g_CardScene:onDiscardCard(wDisViewId,self.m_cbOutCardData)
    end

    self.m_wOutCardUser = seat_id
    self.m_cbOutCardData = cardValue
    self.m_cbCurrentCard = cardValue
    --·¢ËÍÐÂÅÆ
    g_CardScene:sendCard(wViewId,cardValue,1)
    --scheduler.performWithDelayGlobal(function ()
    --    if g_CardScene then
    --        g_CardScene:sendCard(wViewId,cardValue,1)
    --    end
    --end,0.3)
end

--ÓÎÏ·½áÊø
function PHZMainScene:OnSubGameEnd(data)
     -- body
end

--ÓÎÏ·ÍÐ¹Ü
function PHZMainScene:OnSubTuoGuan(data)
     -- body
end
--------------------------------------------------------------------------------
-------------------------------ÆäËûº¯ÊýÂß¼­´¦Àí---------------------------------
--------------------------------------------------------------------------------

--¸´Ô­ÓÎÏ·½øÐÐ×´Ì¬
function PHZMainScene:restoreStatusPlay(data)
     -- body
end
return  PHZMainScene