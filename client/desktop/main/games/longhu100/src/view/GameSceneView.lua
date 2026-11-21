local Server = require("longhu100.src.handle.Server")
local ZhuangView = require("longhu100.src.view.ZhuangView")
local ZouShiView = require("longhu100.src.view.ZouShiView")
local PlayerView = require("longhu100.src.view.PlayerView")
local WanFaView = require("longhu100.src.view.WanFaView")
local faceUI = require("hall.FaceUI.faceUI")
local Card = require("longhu100.src.Card")
local GPSShowLayer = require("hall.GPSShowLayer")
local SoundUtils = import("longhu100.src.SoundUtils")
local GameSceneView = class("GameSceneView", function()
    if device.platform == "ios" then
        if isiOSVerify then
            return cc.CSLoader:createNode("longhu100/res/GameScene/GameScene.csb")
        else
            return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "longhu100/res/GameScene/GameScene.csb")
        end
    else
        return cc.CSLoader:createNode("longhu100/res/GameScene/GameScene.csb")
    end
end)

function GameSceneView:ctor()
    GameUtils.setNodeNameBindObj(self)
    self:setNodeEventEnabled(true)
    self:initUI()
    self:initEvent()
    -- require("hall.util.GameMenu"):getDeviceInfo(self.hall.device_info_plane)
    self:setRoomId("000000")
    self:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
    self.xiaZhuTime = 0
    self.allChipsNode = {}
    self.chipsOrder = 100
end

function GameSceneView:initUI()
    self.btn_menu = self.hall.btn_menu
    self.ArmatureNode_1 = self.hall.ArmatureNode_1
    self.btn_gameConfig = self.hall.btn_gameConfig
    self.txt_gameConfig = self.hall.txt_gameConfig:setString("")
    self.chip_pnl = self.players.chip_pnl
    self.btn_chip1 = self.chip_pnl.btn_chip1
    self.btn_chip10 = self.chip_pnl.btn_chip10
    self.btn_chip50 = self.chip_pnl.btn_chip50
    self.btn_chip100 = self.chip_pnl.btn_chip100
    self.btn_chip500 = self.chip_pnl.btn_chip500
    self.btn_chip5 = self.chip_pnl.btn_chip5
    self.btn_chip1.chip = 1
    self.btn_chip10.chip = 10
    self.btn_chip50.chip = 50
    self.btn_chip100.chip = 100
    self.btn_chip500.chip = 500
    self.btn_chip5.chip = 5
    self.btn_pz = self.players.zhuang_pnl.btn_pz
    self.txt_id = self.players.userInfo.txt_id:setString("")
    self.txt_jf = self.players.userInfo.txt_jf:setString("")
    self.img_txt = self.players.img_txt:hide()
    self.online = self.players.online

    self.btn_zoushi = self.game.btn_zoushi
    self.chip_he = self.game.chip_he
    self.chip_hu = self.game.chip_hu
    self.chip_long = self.game.chip_long
    self.img_long = self.game.img_long
    self.img_hu = self.game.img_hu
    self.long_card = self.game.long_card:hide()
    self.hu_card = self.game.hu_card:hide()
    self.time = self.game.time:hide()
    self.ListView_record = self.game.ListView_record
    self.ListView_record:setScrollBarEnabled(false)
    self.ListView_record:removeAllItems()
   
    local director = cc.Director:getInstance()
    local size = director:getWinSize()
    local oriSize = self.hall:getContentSize()
    local scale = size.width / oriSize.width
    size.height = oriSize.height
    self.hall:setContentSize(size)
    self.players:setContentSize(size)
    display.doLayout(self)
    display.doLayout(self.hall)
    display.doLayout(self.players)
    if scale < 1 then
        self.chip_pnl:setScale(scale)
    end
    for i=1,10 do
        self["player"..i] = self.players["player"..i]:hide()
        self["player"..i] = require("longhu100.src.view.UserInfoView").new(self["player"..i])
    end

    for i=1,6 do
        self["zhuang"..i] = self.players.zhuang_pnl["zhuang"..i]
        self["zhuang"..i] = require("longhu100.src.view.UserInfoView").new(self["zhuang"..i], true)
    end
    self:clearData()
end

function GameSceneView:clearData()
    self.chip_long.txt_yxz:hide()
    self.chip_long.txt_kxz:hide()
    self.chip_long.txt_kxz1:hide()
    self.chip_long.Image_76:hide()
    self.chip_long.img_shine:hide()
    self.chip_long.img_shine:stopAllActions()
    self.chip_he.txt_yxz:hide()
    self.chip_he.txt_kxz:hide()
    self.chip_he.txt_kxz1:hide()
    self.chip_he.Image_76:hide()
    self.chip_he.img_shine:hide()
    self.chip_he.img_shine:stopAllActions()
    self.chip_hu.txt_yxz:hide()
    self.chip_hu.txt_kxz:hide()
    self.chip_hu.txt_kxz1:hide()
    self.chip_hu.Image_76:hide()
    self.chip_hu.img_shine:hide()
    self.chip_hu.img_shine:stopAllActions()
    self.chip_hu.txt_yxz_total:hide()
    self.chip_hu.txt_yxz1_total:hide()
    self.hu_card:hide()
    self.long_card:hide()
    self.chip_hu.txt_yxz_total:setString("")
    self.chip_hu.txt_kxz:setString("")
    self.chip_he.txt_kxz:setString("")
    self.chip_long.txt_kxz:setString("")

    local children = self.players:getChildren()
    for i,node in ipairs(children) do
        local name = node:getName()
        if name == "_chips" then
            node:stopAllActions()
            node:hide()
        end
    end
end

function GameSceneView:initEvent()
    self.btn_menu:onClick(handler(self, self.onClick_menu), true)
    self.btn_gameConfig:onClick(handler(self, self.onClick_gameConfig), true)
    self.btn_pz:onClick(handler(self, self.onClick_pz), true)

    self.btn_chip1:onClick(handler(self, self.onClickChip), true)
    self.btn_chip10:onClick(handler(self, self.onClickChip), true)
    self.btn_chip50:onClick(handler(self, self.onClickChip), true)
    self.btn_chip100:onClick(handler(self, self.onClickChip), true)
    self.btn_chip500:onClick(handler(self, self.onClickChip), true)
    self.btn_chip5:onClick(handler(self, self.onClickChip), true)
    self.chip_long:onClick(handler(self, self.onClickChip1))
    self.chip_hu:onClick(handler(self, self.onClickChip1))
    self.chip_he:onClick(handler(self, self.onClickChip1))
    self.btn_zoushi:onClick(handler(self, self.onClickZouShi))
    self.online:onClick(handler(self, self.onClickOnline))
    self.chip_long._type = 1
    self.chip_hu._type = 2
    self.chip_he._type = 3
end
function GameSceneView:onClickZouShi()
    ZouShiView.new():addTo(self)
end
function GameSceneView:onClickOnline()
    Server:CLIENT_COMMAND_USER_LIST()
end
function GameSceneView:showPlayerView(data)
    PlayerView.new(data):addTo(self)
end
function GameSceneView:onClickChip(event)
    local target = event.target

    local worldPosAR = target:getParent():convertToWorldSpace(cc.p(target:getPosition()))
    self.clickChip = target
    self.clickChipOriOps = worldPosAR
end

function GameSceneView:onClickChip1(event)
    if not self.clickChip then
        return
    end
    local userInfo = g_101.updateChips(USER_INFO.uid)
    if userInfo.seat_id < 0 then
        return
    end
    if g_101.gameStatus ~= 1 then
        viewMgr:showTip({text = "非下注时间！"})
        return
    end
    if userInfo.isBanker == 1 then
        viewMgr:showTip({text = "您是庄家！"})
        return
    end
    local target = event.target
    local _type = target._type
    local chip = self.clickChip.chip
    if userInfo.chips / 100 < chip then
        viewMgr:showTip({text = "筹码不足，请换筹码"})
        return
    end
    Server:CLIENT_COMMAND_USER_BET_SCORE(_type, chip)
end

function GameSceneView:getChipsByType(_type, chip)
    for i,node in ipairs(self.allChipsNode) do
        if node.chip == chip and node.state == "end" then
            node._type = _type
            return node:show()
        end
    end
end

function GameSceneView:setChipsState()
    local children = self.players:getChildren()
    self.allChipsNode = {}
    self.chipsOrder = 100
    for i,node in ipairs(children) do
        local name = node:getName()
        if name == "_chips" then
            node.state = "end"
            table.insert( self.allChipsNode, node )
        end
    end
end

function GameSceneView:newChips(_type, chip, oriOps, notAction)
    local toPos = self:getlonghuhePos(_type)
    local img = self:getChipsByType(_type, chip)
    if not img then
        img = ccui.ImageView:create("longhu100/res/GameScene/cion/"..chip..".png"):addTo(self.players)
    end
    img:setZOrder(self.chipsOrder)
    self.chipsOrder = self.chipsOrder + 1
    img.state = "on"
    img:setName("_chips")
    img._type = _type
    img.chip = chip
    if notAction then
        img:setPosition(toPos)
    else
        img:setPosition(oriOps)
        local MoveTo2 = cc.MoveTo:create(0.1, toPos)
        img:runAction(MoveTo2)
    end
end

function GameSceneView:updateChipPnlStatus()
    local userInfo = g_101.updateChips(USER_INFO.uid)
    if not userInfo then
        return
    end
    if userInfo.chips / 100 < 1 then
        self.chip_pnl:hide()
        self.img_txt:loadTexture("longhu100/res/GameScene/txt2.png")
        self.img_txt:ignoreContentAdaptWithSize(true)
        self.img_txt:show()
    else
        self.chip_pnl:show()
        self.img_txt:hide()
    end
    if userInfo.isBanker == 1 then
        self.chip_pnl:hide()
        self.img_txt:loadTexture("longhu100/res/GameScene/txt1.png")
        self.img_txt:ignoreContentAdaptWithSize(true)
        self.img_txt:show()
    end
end

function GameSceneView:playerXZ(userId, chips, betType)
    SoundUtils:Sound("金币")
    if userId == USER_INFO.uid and self.clickChipOriOps then
        self:newChips(betType, chips, self.clickChipOriOps)
    else
        local oriOps = self.online:getPosition()
        if g_101.userInfos(userId) and g_101.userInfos(userId).seat_id then
            local UserInfoView = self:getPlayerByUserId(userId)
            if UserInfoView then
                oriOps = UserInfoView:getPosition()
            end
        end
        
        self:newChips(betType, chips, oriOps)
    end
    local UserInfoView = self:getPlayerByUserId(userId)
    if UserInfoView then
        UserInfoView:setScore(chips)
    end
end

function GameSceneView:setXZScore(totalLongScore, totalHuScore, totalHeScore)
    
    self.chip_long.txt_yxz:show()
    self.chip_hu.txt_yxz:show()
    self.chip_he.txt_yxz:show()
    self.chip_hu.txt_yxz_total:show()
    self.chip_hu.txt_yxz1_total:show()

    self:setLongScore(totalLongScore)
    self:setHuScore(totalHuScore)
    self:setHeScore(totalHeScore)
end

function GameSceneView:onClick_pz()
    ZhuangView.new():addTo(self)
end

function GameSceneView:setGameResult( _type )
    local path = string.format("longhu100/res/GameScene/%d.png", _type)
    local node = ccui.ImageView:create(path)
    self.ListView_record:pushBackCustomItem(node)
    while #self.ListView_record:getItems() > 100 do
        self.ListView_record:removeItem(0)
    end
    self.ListView_record:jumpToRight()
end


function GameSceneView:onClick_gameConfig(event)
    if isOpenControl then
        Server:CLI_REQ_TEST_CARDS()
    else
        WanFaView.new():addTo(self)
        -- require("hall.util.GameMenu"):showConfigPanel(g_101.gameConfigTable)
    end
end

function GameSceneView:onClick_menu(event)
    self:loadMoreFuncLayer()
end

function GameSceneView:setRoomId( roomId, my_id )
    self.roomId = roomId
    self.txt_gameConfig:setString("百人龙虎房号："..roomId)
    self.txt_id:setString(USER_INFO.uid)
    
end

function GameSceneView:setMyScore(score)
    self.txt_jf:setString(score)
end

function GameSceneView:setMaxKXZ(surpLongMaxScore, surpHuMaxScore, surpHeMaxScore, times)
    self.chip_long.txt_kxz:show()
    self.chip_long.txt_kxz1:show()
    self.chip_long.txt_kxz:setString(surpLongMaxScore)
    self.chip_long.Image_76:show()

    self.chip_hu.txt_kxz:show()
    self.chip_hu.txt_kxz1:show()
    self.chip_hu.txt_kxz:setString(surpHuMaxScore)
    self.chip_hu.Image_76:show()

    self.chip_he.txt_kxz:show()
    self.chip_he.txt_kxz1:show()
    self.chip_he.txt_kxz:setString(surpHeMaxScore)
    self.chip_he.Image_76:show()
    if not times then
        return
    end
    self.chip_hu.txt_yxz_total:show()
    self.chip_hu.txt_yxz_total:setString("0")
    self.chip_hu.txt_yxz1_total:show()
    
    self.time:show()
    self.time.times = times
    self.time.txt:setString(times)

    self.chip_long.txt_yxz:show()
    self.chip_hu.txt_yxz:show()
    self.chip_he.txt_yxz:show()
    self.chip_long.txt_yxz:setString(0)
    self.chip_hu.txt_yxz:setString(0)
    self.chip_he.txt_yxz:setString(0)
    self.time:stopAllActions()

    local DelayTime = cc.DelayTime:create(1)
    local CallFunc = cc.CallFunc:create(function()
        if self.time.times <= 0 then
            self.time:hide()
            self.time:stopAllActions()
        end
        self.time.times  = self.time.times - 1
        self.time.txt:setString(self.time.times)
    end)
    local Sequence = cc.Sequence:create(DelayTime, CallFunc)
    local Repeat = cc.Repeat:create(Sequence, 21)
    self.time:runAction(Repeat)
    self.ArmatureNode_1:getAnimation():playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环
    local userInfo = g_101.updateChips(USER_INFO.uid)
   
    
end

function GameSceneView:setTZXZ(longCard, huCard, isShowCard)
    if isShowCard then
        local ScaleTo1 = cc.ScaleTo:create(0.1, 0.01, 1)
        local CallFunc = cc.CallFunc:create(function()
            Card:changeImg(self.long_card, longCard)
        end)
        local ScaleTo = cc.ScaleTo:create(0.1, 1, 1)
        local Sequence = cc.Sequence:create(ScaleTo1, CallFunc, ScaleTo)
        self.long_card:runAction(Sequence)
    
    
        local CallFunc = cc.CallFunc:create(function()
            Card:changeImg(self.hu_card, huCard)
        end)
        local ScaleTo1 = cc.ScaleTo:create(0.1, 0.01, 1)
        local ScaleTo = cc.ScaleTo:create(0.1, 1, 1)
        local Sequence = cc.Sequence:create(ScaleTo1, CallFunc, ScaleTo)
        self.hu_card:runAction(Sequence)
        return
    end
    self.ArmatureNode_1:getAnimation():playWithIndex(1, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环

    self.chip_long.txt_kxz:show()
    self.chip_long.txt_kxz1:show()

    self.chip_hu.txt_kxz:show()
    self.chip_hu.txt_kxz1:show()

    self.chip_he.txt_kxz:show()
    self.chip_he.txt_kxz1:show()

    self.chip_hu.txt_yxz_total:show()
    self.chip_hu.txt_yxz1_total:show()

    self.time:hide()
    self.time:stopAllActions()


    self.long_card:setScale(-1, 1)
    self.long_card:setPosition(self.game:getPosition())
    self.long_card:show()
    local longpos = self.img_long:getPosition()
    Card:changeImg(self.long_card, 0)
    local MoveTo1 = cc.MoveTo:create(0.3, longpos)
    local CallFunc = cc.CallFunc:create(function()
        Card:changeImg(self.long_card, longCard)
    end)
    local ScaleTo = cc.ScaleTo:create(0.3, 1, 1)
    local Sequence = cc.Sequence:create(MoveTo1, CallFunc, ScaleTo)
    self.long_card:runAction(MoveTo1)


    self.hu_card:setScale(-1, 1)
    self.hu_card:setPosition(self.game:getPosition())
    self.hu_card:show()
    local hupos = self.img_hu:getPosition()
    hupos.y = longpos.y
    Card:changeImg(self.hu_card, 0)
    local MoveTo1 = cc.MoveTo:create(0.3, hupos)
    local CallFunc = cc.CallFunc:create(function()
        Card:changeImg(self.hu_card, huCard)
    end)
    local ScaleTo = cc.ScaleTo:create(0.3, 1, 1)
    local Sequence = cc.Sequence:create(MoveTo1, CallFunc, ScaleTo)
    self.hu_card:runAction(MoveTo1)
end

function GameSceneView:setLongScore(score)
    self.chip_long.txt_yxz:setString(score)
    local num1 = tonumber(self.chip_long.txt_yxz:getString())
    local num2 = tonumber(self.chip_hu.txt_yxz:getString())
    local num3 = tonumber(self.chip_he.txt_yxz:getString())
    self.chip_hu.txt_yxz_total:setString(num1+num2+num3)
end
function GameSceneView:setHuScore(score)
    self.chip_hu.txt_yxz:setString(score)
    local num1 = tonumber(self.chip_long.txt_yxz:getString())
    local num2 = tonumber(self.chip_hu.txt_yxz:getString())
    local num3 = tonumber(self.chip_he.txt_yxz:getString())
    self.chip_hu.txt_yxz_total:setString(num1+num2+num3)
end
function GameSceneView:setHeScore(score)
    self.chip_he.txt_yxz:setString(score)
    local num1 = tonumber(self.chip_long.txt_yxz:getString())
    local num2 = tonumber(self.chip_hu.txt_yxz:getString())
    local num3 = tonumber(self.chip_he.txt_yxz:getString())
    self.chip_hu.txt_yxz_total:setString(num1+num2+num3)
end

function GameSceneView:setTime(time)
    local func = function(value)
        local time = math.abs( value )
        self.time.txt:setString(math.abs( value ))
        if time < 0 then
            dump(time)
            self.time:hide()
        end
    end
    self:setTimingFun( func, time )
end

function GameSceneView:removeAllChip()
    local children = self.players:getChildren()
    for i,v in ipairs(children) do
        local name = v:getName()
        if name == "longchip" or name == "huchip" or name == "hechip" then
            v:removeSelf()
        end
    end
end

function GameSceneView:getlonghuhePos(_type)
    local pos2 = {}
    local size = {}
    local img_shine
    local num = 0.7
    local num1 = 0.85
    if _type == 1 then
        size = self.chip_long:getContentSize()
        pos2 = self.chip_long:getPosition()
        size.height = 80
        size.width = size.width * num1
    elseif _type == 2 then
        size = self.chip_hu:getContentSize()
        pos2 = self.chip_hu:getPosition()
        size.height = 80
        size.width = size.width * num1
    elseif _type == 3 then
        size = self.chip_he:getContentSize()
        size.width = size.width * 0.7
        size.height = 50
        pos2 = self.chip_he:getPosition()
    end

    -- local worldpoint = (self):convertToWorldSpace(pos2) --这样写是为了贴近函数的原始用法
    -- local worldPosAR = self.chip_long:getParent():convertToWorldSpaceAR(cc.p(pos2))

    local worldPos = self.game:convertToWorldSpace(pos2)
    local nodePos = self.players:convertToNodeSpace(worldPos)
    pos2 = nodePos

    local width = size.width / 2
    local height = size.height / 2

    local int = math.random(2)
    if int == 2 then
        int = -1
    end
    local int1 = math.random(2)
    if int1 == 2 then
        int1 = -1
    end
    pos2.x = pos2.x + (math.random(width) * int)
    pos2.y = pos2.y + (math.random(height) * int1) - 20
    return pos2
end

function GameSceneView:actionAllChip(_type, users)
    local children = self.players:getChildren()
    local long = {}
    local he = {}
    local hu = {}
    local allNode = {}
    for i,node in ipairs(children) do
        local name = node:getName()
        if name == "_chips" then
            if node._type == 1 then
                table.insert(long, node)
                table.insert(allNode, node)
            elseif node._type == 2 then 
                table.insert(hu, node)
                table.insert(allNode, node)
            elseif node._type == 3 then
                table.insert(he, node)
                table.insert(allNode, node)
            end
        end
    end
    local arr2 = {}
    local img_shine
    if _type == 1 then
        arr2 = tableConcat(hu,he)
        img_shine = self.chip_long.img_shine:hide()
    elseif _type == 2 then
        arr2 = tableConcat(long,he)
        img_shine = self.chip_hu.img_shine:hide()
    elseif _type == 3 then
        arr2 = tableConcat(long,hu)
        img_shine = self.chip_he.img_shine:hide()
    end

    img_shine:show()
    local Blink = cc.Blink:create(1, 2)
    local RepeatForever = cc.Repeat:create(Blink, 3)
    local CallFunc = cc.CallFunc:create(function()
        img_shine:hide()
    end)
    local Sequence = cc.Sequence:create(RepeatForever, CallFunc)
    img_shine:runAction(Sequence)
    

    local players = {}

    table.sort(allNode, function(a, b)
        return a.chip > b.chip
    end)
    local func = function (arr, score, pos)
        for i,v in ipairs(arr) do
            if v.chip <= score and score - v.chip >= 0 then
                score = score - v.chip
                v.toPos = pos
            end
        end
    end

    for i,v in ipairs(allNode) do
        v.toPos = self.online:getPosition()
    end

    for i, user in ipairs(users) do
        local UserInfoView = self:getPlayerByUserId(user.uid)
        if UserInfoView then
            local pos = UserInfoView:getPosition()
            func(allNode, user.turnBlc, pos)
        end
    end

    local pos1 = self.players.zhuang_pnl:getPosition()
    for i,v in ipairs(arr2) do
        local CallFunc = cc.CallFunc:create(function()
            SoundUtils:Sound("金币")
        end)
        local pos2 = self:getlonghuhePos(_type)
        local MoveTo1 = cc.MoveTo:create(0.3, pos1)
        local FadeOut1 = cc.FadeOut:create(0.1)
        local DelayTime = cc.DelayTime:create(0.1)
        local FadeOut2 = cc.FadeIn:create(0.1)
        local MoveTo2 = cc.MoveTo:create(0.3, pos2)
        local Sequence = cc.Sequence:create(CallFunc, MoveTo1, FadeOut1, DelayTime, FadeOut2, MoveTo2)
        v:runAction(Sequence)
    end

    local func =function ()
        for i,v in ipairs(allNode) do
            if not tolua.isnull(v) then
                local CallFunc = cc.CallFunc:create(function()
                    SoundUtils:Sound("金币")
                end)
                local MoveTo3 = cc.MoveTo:create(0.8, v.toPos)
                local Sequence = cc.Sequence:create(CallFunc, MoveTo3, cc.Hide:create())
                v:runAction(Sequence)
            end
        end
        img_shine:stopAllActions()
        img_shine:hide()
        for i, user in ipairs(users) do
            local UserInfoView = self:getPlayerByUserId(user.uid)
            if UserInfoView then
                UserInfoView:setScore(user.turnBlc, true)
            end
        end
    end
    self:setTimingFun( func, 1.5 )
end

function GameSceneView:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(self.gameMsgLayer)
    else
        self.gameMsgLayer:showContentByType(1)
    end
    self.gameMsgLayer:setVisible(true)
end

function GameSceneView:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function GameSceneView:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        local bgData = {
            bg = {
                "longhu100/res/GameScene/bg_1.png",
                "longhu100/res/GameScene/bg_2.png",
                "longhu100/res/GameScene/bg_3.png",
            },
            str = {
                "背景1",
                "背景2",
                "背景3",
            },
            cardDatas = {
                {
                    scale = 0.9,
                    txt = "牌型1",
                    path = "longhu100/res/cards/1/short/26.png",
                },
                {
                    scale = 0.9,
                    txt = "牌型2",
                    path = "longhu100/res/cards/2/short/26.png",
                },
                {
                    scale = 0.9,
                    txt = "牌型3",
                    path = "longhu100/res/cards/3/short/26.png",
                }

            }
        }
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new(bgData)
        self:addChild(self.moreFuncLayer, 99999)
        local data = {}
        data.quitRoom = handler(self, self.quitRoom)
        data.disbandRoom = handler(self, self.disbandRoom)
        self.moreFuncLayer:registerDisbandFuncs(data)
    else
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
    if g_101.gameConfig.dis_agree == 3 then
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    else
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    end
end

function GameSceneView:sendFaceByIdx(id, msgType, to_uid)
    Server:CLI_MSG_FACE(id, msgType, to_uid)
end

function GameSceneView:disbandRoom()
    Server:C2G_CMD_DISSOLVE_ROOM()
end

function GameSceneView:rejectDisband()
    Server:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function GameSceneView:agreeDisband()
    Server:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function GameSceneView:quitRoom()
    Server:quitRoom()
end

function GameSceneView:setDYJandXYX(mostUid, winUid, dyjScore)
    for i=1,10 do
        local UserInfoView = self["player"..i]
        UserInfoView:hide()
    end
    if winUid == nil then
        winUid = self.winUid
    end
    if mostUid == self.player1.uid then
        self.player1:showFh()
        self.player1:setFh(dyjScore)
    elseif mostUid ~= 0 then
        local userInfo = g_101.userInfos(mostUid)
        self.player1:showFh()
        self.player1:setFh(dyjScore)
    else
        self.player1:hideFh()
    end
    if winUid == self.player2.uid then
        self.player2:showXyx()
        self.winUid = winUid
    elseif winUid ~= 0 then
        local userInfo = g_101.userInfos(winUid)
        self.player2:showXyx()
        self.winUid = winUid
    else
        self.player2:hideXyx()
        self.winUid = nil
    end
    self:refreshPlayers()
end

function GameSceneView:refreshPlayers()
    local newUsers = {}
    for i,v in ipairs(g_101.allUser) do
        if v.uid == self.mostUid then
            table.insert(newUsers, v)
            break
        end
    end
    for i,v in ipairs(g_101.allUser) do
        if v.uid == self.winUid then
            table.insert(newUsers, v)
            break
        end
    end
    for i,v in ipairs(g_101.allUser) do
        if v.uid == self.mostUid or v.uid == self.winUid or v.isBanker == 1 then
        else
            dump(v,"1111111")
            table.insert(newUsers, v)
            if #newUsers >= 10 then
                break
            end
        end
    end
    for i=1,10 do
        local UserInfoView = self["player"..i]
        UserInfoView:hide()
    end
    for i,userInfo in ipairs(newUsers) do
        local UserInfoView = self["player"..i]
        UserInfoView:show()
        UserInfoView:refreshPlayerInfo(userInfo.portrait, userInfo.uid, userInfo.sex, userInfo.nickName, userInfo.ip, userInfo.addres)
    end
end

function GameSceneView:getPlayerBySeatId( seatId )
    for i=1,10 do
        local UserInfoView = self["player"..i]
        if UserInfoView.uid == -1 then
            return UserInfoView
        end
    end
    return
end

function GameSceneView:getPlayerByUserId( userId )
    for i=1,10 do
        local UserInfoView = self["player"..i]
        if UserInfoView.uid == userId then
            return UserInfoView
        end
    end
    return
end

function GameSceneView:getBankerPlayerByUid( seatId )
    return self["zhuang"..seatId]
end

function GameSceneView:hideAllZhuang()
    for i=1,6 do
        self["zhuang"..i]:resetFenE()
    end
end
function GameSceneView:updateXZ( dt )
    local num = #(g_101.xiaZhuData)
    if g_101.gameStatus == 1 and num >= 1 then
        self.xiaZhuTime = self.xiaZhuTime + dt
        if self.xiaZhuTime >= 1/num  then
            local int = math.random(2)
            for i=1,int do
                local pack = table.remove(g_101.xiaZhuData, 1)
                if pack then
                    self:xiaZhu(pack)
                end
            end
            self.xiaZhuTime = 0
        end
    end
end
function GameSceneView:xiaZhu(pack)
    local betScore = pack.betScore
    local uid = pack.uid
    if uid == USER_INFO.uid then
        -- pack.totalLongScore = tonumber(self.chip_long.txt_yxz:getString()) or 0
        -- pack.totalHuScore = tonumber(self.chip_hu.txt_yxz:getString()) or 0
        -- pack.totalHeScore = tonumber(self.chip_he.txt_yxz:getString()) or 0

        -- pack.surpLongMaxScore = tonumber(self.chip_long.txt_kxz:getString()) or 0
        -- pack.surpHuMaxScore = tonumber(self.chip_hu.txt_kxz:getString()) or 0
        -- pack.surpHeMaxScore = tonumber(self.chip_he.txt_kxz:getString()) or 0
        -- if pack.betType == 1 then
        --     pack.totalLongScore  = pack.totalLongScore + betScore
        --     pack.surpLongMaxScore  = pack.surpLongMaxScore - betScore
        --     pack.surpHuMaxScore  = pack.surpHuMaxScore + betScore
        -- elseif pack.betType == 2 then
        --     pack.totalHuScore  = pack.totalHuScore + betScore
        --     pack.surpHuMaxScore  = pack.surpHuMaxScore - betScore
        --     pack.surpLongMaxScore  = pack.surpLongMaxScore + betScore
        -- elseif pack.betType == 3 then
        --     pack.totalHeScore  = pack.totalHeScore + betScore
        --     pack.surpHeMaxScore  = pack.surpHeMaxScore - betScore
        --     pack.surpLongMaxScore  = pack.surpLongMaxScore + betScore
        --     pack.surpHuMaxScore  = pack.surpHuMaxScore + betScore
        -- end
    end
    self:setXZScore(pack.totalLongScore, pack.totalHuScore, pack.totalHeScore)
    self:setMaxKXZ(pack.surpLongMaxScore, pack.surpHuMaxScore, pack.surpHeMaxScore)
    self:playerXZ(uid, betScore, pack.betType)
    local userInfo = g_101.updateChips(uid)
    if userInfo then
        local chips = userInfo.chips - betScore * 100
        g_101.updateChips(uid, chips)
    end
    -- if uid == self.player1.uid then
    --     self.player1:setFh(chips / 100)
    -- end
    -- if uid == USER_INFO.uid then
    --     self:setMyScore(chips / 100)
    -- end
end

function GameSceneView:update( dt )
    self:updateXZ( dt )
    if self.timing and #self.timing >= 1 then
        for idx, timing in ipairs(self.timing) do
            timing.time = timing.time - dt
            self.timing[idx].time = timing.time
            if timing.time <= 0 then
                timing.func(timing.time)
                table.remove(self.timing, idx)
            end
        end
    end
end

function GameSceneView:setTimingFun( func, time, isTimeEnd )
    if not self.timing then
        self.timing = {}
    end
    table.insert(self.timing, {func = func, time = time, isTimeEnd = isTimeEnd})
end

function GameSceneView:onExit( )
    self:stopAllActions()
end

return GameSceneView
