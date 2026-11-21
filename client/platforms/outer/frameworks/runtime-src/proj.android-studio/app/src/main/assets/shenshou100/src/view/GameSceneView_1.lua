local Server = require("shenshou100.src.handle.Server")
local ZhuangView = require("shenshou100.src.view.ZhuangView")
local ZouShiView = require("shenshou100.src.view.ZouShiView")
local PlayerView = require("shenshou100.src.view.PlayerView")
local WanFaView = require("shenshou100.src.view.WanFaView")
local faceUI = require("hall.FaceUI.faceUI")
local Card = require("shenshou100.src.Card")
local GPSShowLayer = require("hall.GPSShowLayer")
local SoundUtils = import("shenshou100.src.SoundUtils")
local GameSceneView = class("GameSceneView", function()
    if device.platform == "ios" then
        if isiOSVerify then
            return cc.CSLoader:createNode("shenshou100/res/GameScene/GameScene.csb")
        else
            return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "shenshou100/res/GameScene/GameScene.csb")
        end
    else
        return cc.CSLoader:createNode("shenshou100/res/GameScene/GameScene.csb")
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
    self.bg = self.bg
    self.btn_menu = self.hall.btn_menu
    self.ArmatureNode_1 = self.hall.ArmatureNode_1
    self.ArmatureNode_2 = self.hall.ArmatureNode_2
    self.btn_gameConfig = self.hall.btn_gameConfig
    self.txt_gameConfig = self.hall.Image_15.txt_gameConfig:setString("")
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

    self.btn_zoushi = self.game.record.btn_zoushi
    self.txt_kxz_total = self.game.txt_kxz_total:hide()
    self.txt_kxz_total1 = self.game.txt_kxz_total1:hide()
    self.txt_yxz_total = self.game.txt_yxz_total:hide()
    self.txt_yxz_total1 = self.game.txt_yxz_total1:hide()
    self.chip_wu = self.game.chip_wu
    self.chip_que = self.game.chip_que
    self.chip_hu = self.game.chip_hu
    self.chip_long = self.game.chip_long
    self.send_card = self.cards.send_card:hide()
    self.time = self.game.time:hide()
    self.item = self.game.record.item:hide()
    self.ListView_record = self.game.record.ListView_record
    self.ListView_record:setScrollBarEnabled(false)
    self.ListView_record:removeAllItems()

    self.card_wu = self.cards.card_wu:hide()
    self.card_que = self.cards.card_que:hide()
    self.card_hu = self.cards.card_hu:hide()
    self.card_long = self.cards.card_long:hide()

    self.card_wu.oriPos = self.card_wu:getPosition()
    self.card_que.oriPos = self.card_que:getPosition()
    self.card_hu.oriPos = self.card_hu:getPosition()
    self.card_long.oriPos = self.card_long:getPosition()
    self.send_card.oriPos = self.send_card:getPosition()
    local pos = self.send_card:getPosition()
    pos.y = pos.y - self.send_card:getHeight()
    self.send_card.sendPos = pos

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
        self["player"..i] = require("shenshou100.src.view.UserInfoView").new(self["player"..i])
    end

    for i=1,6 do
        self["zhuang"..i] = self.players.zhuang_pnl["zhuang"..i]
        self["zhuang"..i] = require("shenshou100.src.view.UserInfoView").new(self["zhuang"..i], true)
    end
    self:clearData()
    
end

function GameSceneView:clearData()
    self.chip_long.txt_yxz:hide()
    self.chip_long.txt_yxz:setString(0)
    self.chip_long.Image_76:hide()
    self.chip_long.img_shine:hide()
    self.card_long:hide()
    self.chip_long.img_shine:stopAllActions()
    self.chip_que.txt_yxz:hide()
    self.chip_que.txt_yxz:setString(0)
    self.chip_que.Image_76:hide()
    self.card_que:hide()
    self.chip_que.img_shine:hide()
    self.chip_que.img_shine:stopAllActions()
    self.chip_hu.txt_yxz:hide()
    self.chip_hu.txt_yxz:setString(0)
    self.chip_hu.Image_76:hide()
    self.card_hu:hide()
    self.chip_hu.img_shine:hide()
    self.chip_hu.img_shine:stopAllActions()
    self.chip_wu.txt_yxz:hide()
    self.chip_wu.txt_yxz:setString(0)
    self.chip_wu.Image_76:hide()
    self.card_wu:hide()
    self.chip_wu.img_shine:hide()
    self.chip_wu.img_shine:stopAllActions()
    self.send_card:hide()

    
    self.txt_kxz_total1:hide()
    self.txt_kxz_total:hide()
    self.txt_yxz_total1:hide()
    self.txt_yxz_total:hide()

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
    self.chip_que:onClick(handler(self, self.onClickChip1))
    self.chip_wu:onClick(handler(self, self.onClickChip1))
    self.btn_zoushi:onClick(handler(self, self.onClickZouShi))
    self.online:onClick(handler(self, self.onClickOnline))
    self.chip_long._type = 1
    self.chip_hu._type = 2
    self.chip_que._type = 3
    self.chip_wu._type = 4
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
    local userInfo = g_102.updateChips(USER_INFO.uid)
    if userInfo.seat_id < 0 then
        return
    end
    if g_102.gameStatus ~= 1 then
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
    local userInfo = g_102.updateChips(USER_INFO.uid)
    if not userInfo then
        return
    end
    if userInfo.chips / 100 < 1 then
        self.chip_pnl:hide()
        self.img_txt:loadTexture("shenshou100/res/GameScene/txt2.png")
        self.img_txt:ignoreContentAdaptWithSize(true)
        self.img_txt:show()
    else
        self.chip_pnl:show()
        self.img_txt:hide()
    end
    if userInfo.isBanker == 1 then
        self.chip_pnl:hide()
        self.img_txt:loadTexture("shenshou100/res/GameScene/txt1.png")
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
        if g_102.userInfos(userId) and g_102.userInfos(userId).seat_id then
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

function GameSceneView:setXZScore(totalLongScore, totalHuScore, totalQueScore, totalGuiScore)
    self:setLongScore(totalLongScore)
    self:setHuScore(totalHuScore)
    self:setQueScore(totalQueScore)
    self:setWuScore(totalGuiScore)
end

function GameSceneView:onClick_pz()
    ZhuangView.new():addTo(self)
end

function GameSceneView:setGameResult( data )
    local item = self.item:clone():show()
    GameUtils.setNodeNameBindObj(item)
    item.img1_shine:show()
    for i,v in ipairs(data) do
        local node = item[tostring(i)]
        local path = "shenshou100/res/GameScene/x.png"
        if v == 1 then
            path = "shenshou100/res/GameScene/v.png"
        end
        node:loadTexture(path)
    end
    local getItems = self.ListView_record:getItems()
    while #getItems > 20 do
        self.ListView_record:removeItem(0)
        getItems = self.ListView_record:getItems()
    end
    for i,item in ipairs(getItems) do
        item.img1_shine:hide()
    end
    self.ListView_record:pushBackCustomItem(item)
    self.ListView_record:jumpToRight()
    
end


function GameSceneView:onClick_gameConfig(event)
    if isOpenControl then
        Server:CLI_REQ_TEST_CARDS()
    else
        WanFaView.new():addTo(self)
        -- require("hall.util.GameMenu"):showConfigPanel(g_102.gameConfigTable)
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

function GameSceneView:setMaxKXZ(surpMaxScore, times)
    self.chip_long.Image_76:show()
    self.chip_hu.Image_76:show()
    self.chip_que.Image_76:show()
    self.chip_wu.Image_76:show()
    self.txt_kxz_total1:show()
    self.txt_kxz_total:setString(surpMaxScore or "")
    self.txt_kxz_total:show()

    if not times then
        return
    end
    self.txt_yxz_total:show()
    self.txt_yxz_total:setString("0")
    self.txt_yxz_total1:show()
    
    self.time:show()
    self.time.times = times
    self.time.txt:setString(times)

    self.chip_long.txt_yxz:show()
    self.chip_hu.txt_yxz:show()
    self.chip_que.txt_yxz:show()
    self.chip_wu.txt_yxz:show()
    self.chip_long.txt_yxz:setString(0)
    self.chip_hu.txt_yxz:setString(0)
    self.chip_que.txt_yxz:setString(0)
    self.chip_wu.txt_yxz:setString(0)
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
    self.ArmatureNode_2:getAnimation():playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环
    local fun = function()
        self.ArmatureNode_1:getAnimation():playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环
    end
    self:setTimingFun(fun, 0.5)
    local userInfo = g_102.updateChips(USER_INFO.uid)
end

function GameSceneView:setTZXZ(longCard, huCard, queCard, guiCard, bankerCard, func)
    if func then
        local sendCard1 = function(node, cardValue, isXiaZhu)
            node.cardValue = cardValue
            local beishu = cardValue % 16
            local CallFunc = cc.CallFunc:create(function()
                Card:changeImg(node.card, cardValue)
            end)
            local CallFunc1 = cc.CallFunc:create(function()
                node.img_vs:show()
                node.txt_beishu:show()
                node.txt_beishu:setString(string.format("x%d", beishu))
                if node.img_xz and not isXiaZhu then
                    -- node.img_xz:show()
                end
                if node == self.card_wu then
                    func()
                end
            end)
            local ScaleTo1 = cc.ScaleTo:create(0.1, 0.01, 1)
            local ScaleTo = cc.ScaleTo:create(0.1, 1, 1)
            local Sequence = cc.Sequence:create(ScaleTo1, CallFunc, ScaleTo, CallFunc1)
            node.card:runAction(Sequence)
        end
        
        local data = {
            {[1] = self.send_card, [2] = bankerCard},
            {[1] = self.card_long, [2] = longCard},
            {[1] = self.card_hu, [2] = huCard},
            {[1] = self.card_que, [2] = queCard},
            {[1] = self.card_wu, [2] = guiCard},
        }
        for i,v in ipairs(data) do
            local fun = function()
                sendCard1(v[1], v[2])
            end
            self:setTimingFun(fun, i*0.3)
        end
        return
    end
    local sendCard = function(node)
        local worldPos = self.game:convertToWorldSpace(self.send_card.sendPos)
        local nodePos = node:getParent():convertToNodeSpace(worldPos)
        node:setPosition(nodePos)
        node.card:setScale(-1, 1)
        node:show()
        node.img_vs:hide()
        node.txt_beishu:hide()
        if node.img_xz then
            node.img_xz:hide()
        end
        node:stopAllActions()
        Card:changeImg(node.card, 0)
        dump(node.oriPos)
        local MoveTo1 = cc.MoveTo:create(0.2, node.oriPos)
        node:runAction(MoveTo1)
    end
    sendCard(self.card_hu)
    sendCard(self.card_wu)
    sendCard(self.card_que)
    sendCard(self.card_long)
    sendCard(self.send_card)
    self.ArmatureNode_1:getAnimation():playWithIndex(1, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环
end

function GameSceneView:setLongScore(score)
    self.chip_long.txt_yxz:setString(score)
    local num1 = tonumber(self.chip_long.txt_yxz:getString())
    local num2 = tonumber(self.chip_hu.txt_yxz:getString())
    local num3 = tonumber(self.chip_que.txt_yxz:getString())
    local num4 = tonumber(self.chip_wu.txt_yxz:getString())
    dump(self.chip_que.txt_yxz:getString())
    self.txt_yxz_total:setString(num1+num2+num3+num4)
end
function GameSceneView:setHuScore(score)
    self.chip_hu.txt_yxz:setString(score)
    local num1 = tonumber(self.chip_long.txt_yxz:getString())
    local num2 = tonumber(self.chip_hu.txt_yxz:getString())
    local num3 = tonumber(self.chip_que.txt_yxz:getString())
    local num4 = tonumber(self.chip_wu.txt_yxz:getString())
    self.txt_yxz_total:setString(num1+num2+num3+num4)
end
function GameSceneView:setQueScore(score)
    self.chip_que.txt_yxz:setString(score)
    local num1 = tonumber(self.chip_long.txt_yxz:getString())
    local num2 = tonumber(self.chip_hu.txt_yxz:getString())
    local num3 = tonumber(self.chip_que.txt_yxz:getString())
    local num4 = tonumber(self.chip_wu.txt_yxz:getString())
    self.txt_yxz_total:setString(num1+num2+num3+num4)
end
function GameSceneView:setWuScore(score)
    self.chip_wu.txt_yxz:setString(score)
    local num1 = tonumber(self.chip_long.txt_yxz:getString())
    local num2 = tonumber(self.chip_hu.txt_yxz:getString())
    local num3 = tonumber(self.chip_que.txt_yxz:getString())
    local num4 = tonumber(self.chip_wu.txt_yxz:getString())
    self.txt_yxz_total:setString(num1+num2+num3+num4)
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
    local num1 = 180
    if _type == 1 then
        size = self.chip_long:getContentSize()
        pos2 = self.chip_long:getPosition()
        size.height = num1
        size.width = size.width * num
    elseif _type == 2 then
        size = self.chip_hu:getContentSize()
        pos2 = self.chip_hu:getPosition()
        size.width = size.width * num
        size.height = num1
    elseif _type == 3 then
        size = self.chip_que:getContentSize()
        size.width = size.width * num
        size.height = num1
        pos2 = self.chip_que:getPosition()
    elseif _type == 4 then
        size = self.chip_wu:getContentSize()
        size.width = size.width * num
        size.height = num1
        pos2 = self.chip_wu:getPosition()
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
    pos2.y = pos2.y + (math.random(height) * int1) - 25
    return pos2
end

function GameSceneView:actionAllChip(users, cardValue)
    dump(users)
    dump(cardValue)
    local children = self.players:getChildren()
    local long = {}
    local que = {}
    local hu = {}
    local wu = {}
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
                table.insert(que, node)
                table.insert(allNode, node)
            elseif node._type == 4 then
                table.insert(wu, node)
                table.insert(allNode, node)
            end
        end
    end
    local arrWin = {}
    local arrLose = {}
    local func = function(node, _type)
        local cardNode = self.card_long
        if _type == 1 then
            cardNode = self.card_long
        elseif _type == 2 then 
            cardNode = self.card_hu
        elseif _type == 3 then
            cardNode = self.card_que
        elseif _type == 4 then
            cardNode = self.card_wu
        end
        if cardValue % 16 > cardNode.cardValue % 16 then
            if _type == 1 then
                arrLose = tableConcat(arrLose,long)
            elseif _type == 2 then 
                arrLose = tableConcat(arrLose,hu)
            elseif _type == 3 then
                arrLose = tableConcat(arrLose,que)
            elseif _type == 4 then
                arrLose = tableConcat(arrLose,wu)
            end
        else
            if tonumber(node.txt_yxz:getString()) > 0 then
                table.insert(arrWin, _type)
            end
            local img_shine = node.img_shine
            img_shine:show()
            local Blink = cc.Blink:create(1, 2)
            local RepeatForever = cc.Repeat:create(Blink, 3)
            local CallFunc = cc.CallFunc:create(function()
                img_shine:hide()
            end)
            local Sequence = cc.Sequence:create(RepeatForever, CallFunc)
            img_shine:runAction(Sequence)
        end
    end
    func(self.chip_long, 1)
    func(self.chip_hu, 2)
    func(self.chip_que, 3)
    func(self.chip_wu, 4)
    if #arrWin > 0 then
        local num = math.ceil(#arrLose / #arrWin)
        local idx = 0
        local idx1 = 1
        for i, v in ipairs(arrLose) do
            local pos2 = self:getlonghuhePos(arrWin[idx1])
            v.lPos = pos2
            idx  = idx + 1
            if idx >= num then
                idx = 0
                idx1  = idx1 + 1
            end 
        end
    end

    local players = {}
    table.sort(allNode, function(a, b)
        return a.chip > b.chip
    end)
    local func1 = function (arr, score, pos)
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
            func1(allNode, user.turnBlc, pos)
        end
    end
    if #arrWin > 0 then
        local pos1 = self.players.zhuang_pnl:getPosition()
        for i,v in ipairs(arrLose) do
            local pos2 = v.lPos
            local MoveTo1 = cc.MoveTo:create(0.3, pos1)
            local FadeOut1 = cc.FadeOut:create(0.1)
            local DelayTime = cc.DelayTime:create(0.1)
            local FadeOut2 = cc.FadeIn:create(0.1)
            local MoveTo2 = cc.MoveTo:create(0.3, pos2)
            local CallFunc = cc.CallFunc:create(function()
                SoundUtils:Sound("金币")
            end)
            local Sequence = cc.Sequence:create(CallFunc, MoveTo1, FadeOut1, DelayTime, FadeOut2, MoveTo2)
            v:runAction(Sequence)
        end
    end

    local func = function ()
        for i,v in ipairs(allNode) do
            if not tolua.isnull(v) then
                local MoveTo3 = cc.MoveTo:create(0.8, v.toPos)
                local CallFunc = cc.CallFunc:create(function()
                    SoundUtils:Sound("金币")
                end)
                local Sequence = cc.Sequence:create(CallFunc, MoveTo3, cc.Hide:create())
                v:runAction(Sequence)
            end
        end
        self.chip_long.img_shine:stopAllActions()
        self.chip_long.img_shine:hide()
        self.chip_hu.img_shine:stopAllActions()
        self.chip_hu.img_shine:hide()
        self.chip_que.img_shine:stopAllActions()
        self.chip_que.img_shine:hide()
        self.chip_wu.img_shine:stopAllActions()
        self.chip_wu.img_shine:hide()
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
                "shenshou100/res/GameScene/bg_1.png",
                "shenshou100/res/GameScene/bg_2.png",
                "shenshou100/res/GameScene/bg_3.png",
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
                    path = "shenshou100/res/cards/1/short/26.png",
                },
                {
                    scale = 0.9,
                    txt = "牌型2",
                    path = "shenshou100/res/cards/2/short/26.png",
                },
                {
                    scale = 0.9,
                    txt = "牌型3",
                    path = "shenshou100/res/cards/3/short/26.png",
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
    if g_102.gameConfig.dis_agree == 3 then
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
        self.mostUid = mostUid
    elseif mostUid ~= 0 then
        local userInfo = g_102.userInfos(mostUid)
        self.player1:showFh()
        self.player1:setFh(dyjScore)
        self.mostUid = mostUid
    else
        self.player1:hideFh()
        self.mostUid = nil
    end
    if winUid == self.player2.uid then
        self.player2:showXyx()
        self.winUid = winUid
    elseif winUid ~= 0 then
        local userInfo = g_102.userInfos(winUid)
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
    for i,v in ipairs(g_102.allUser) do
        if v.uid == self.mostUid then
            table.insert(newUsers, v)
            break
        end
    end
    for i,v in ipairs(g_102.allUser) do
        if v.uid == self.winUid then
            table.insert(newUsers, v)
            break
        end
    end
    for i,v in ipairs(g_102.allUser) do
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
    local num = #(g_102.xiaZhuData)
    if g_102.gameStatus == 1 and num >= 1 then
        self.xiaZhuTime = self.xiaZhuTime + dt
        if self.xiaZhuTime >= 1/num  then
            local int = math.random(2)
            for i=1,int do
                local pack = table.remove(g_102.xiaZhuData, 1)
                if pack then
                    self:xiaZhu(pack)
                end
            end
            self.xiaZhuTime = 0
        end
    end
end
function GameSceneView:xiaZhu(pack)
    dump(pack, "--广播玩家下注")
    local betScore = pack.betScore
    local uid = pack.uid
    self:setXZScore(pack.totalLongScore, pack.totalHuScore, pack.totalQueScore, pack.totalGuiScore)
    self:setMaxKXZ(pack.surpMaxScore)
    self:playerXZ(uid, betScore, pack.betType)
    local userInfo = g_102.updateChips(uid)
    if userInfo then
        local chips = userInfo.chips - betScore * 100
        g_102.updateChips(uid, chips)
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
