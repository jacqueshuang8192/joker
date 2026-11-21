--总结算

local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local NinetySixTotalSettle = class('NinetySixTotalSettle', NewViewBaseLayer)
local GameCommon = require("hall.GameCommon")

function NinetySixTotalSettle:ctor(scene)
    self.scene = scene
    self.ctrl = scene.ctrl
    self.logic = self.ctrl.logic

    NinetySixTotalSettle.super.ctor(self, "96game/res/csb/NinetySixTotalSettle.csb")
    self.scene:addChild(self)

    self:initData()
    self:initUI()
end

function NinetySixTotalSettle:initData()
    
end

function NinetySixTotalSettle:initUI()
    --[[
    self._csbNode = cc.CSLoader:createNode("96game/res/csb/NinetySixTotalSettle.csb")
    self.scene:addChild(self._csbNode)

    self.Panel_1 = self._csbNode:getChildByName("Panel_1")
    self.Panel_item = self._csbNode:getChildByName("Panel_item")
    self.Panel_bottom = self._csbNode:getChildByName("Panel_bottom")

    self.ScrollView_1 = self.Panel_1:getChildByName("ScrollView_1")
    self.Image_title = self.Panel_1:getChildByName("Image_title")

    self.Button_share = self.Panel_bottom:getChildByName("Button_share")
    self.Button_returnhall = self.Panel_bottom:getChildByName("Button_returnhall")
    --]]

    self.Button_share:addClickEventListener(handler(self, self.onClickShare))
    self.Button_returnhall:addClickEventListener(handler(self, self.onClickBack))
    self.Panel_item:setVisible(false)
end

function NinetySixTotalSettle:doTest(  )
    local test = {}
    for i = 1, math.random(2, 4) do
        local player = {}
        player.uid = 10190
        player.chips = math.random(2, 99)
        player.zhuazhu = math.random(2, 99)
        player.piao = math.random(2, 99)
        player.winCount = math.random(2, 99)
        player.bigWin = math.random(0, 1)
        table.insert(test, player)
    end

    self:updateScroll(test)
end

function NinetySixTotalSettle:setPackData(pack)
    if pack == nil then
        self:doTest()
        return
    end

    self:updateScroll(pack.playerlist)
end

function NinetySixTotalSettle:updateScroll(data)
    self.ScrollView_1:removeAllChildren()
    if data == nil then
        return
    end

    for k, v in ipairs(data) do
        local item = self.Panel_item:clone()
        self.ScrollView_1:addChild(item)
        self:updateItem(item, v)
        item:setPosition(5 + (k - 1) * 270, 0)
        item:setVisible(true)
    end

    local innerSize = cc.size(math.max(857, #data * 270), 468)
    self.ScrollView_1:setInnerContainerSize(innerSize)
end

function NinetySixTotalSettle:updateItem(item, data)
    local Image_bg1 = item:getChildByName("Image_bg1")
    local Image_headbg = item:getChildByName("Image_headbg")

    local res1 = "ninetysix_poker_settleItemb1.png"
    local res2 = "ninetysix_poker_avatarbg1.png"
    if data.bigWin == 1 then
        res1 = "ninetysix_poker_settleItemb2.png"
        res2 = "ninetysix_poker_avatarbg2.png"
    end
    Image_bg1:loadTexture(res1, 1)
    Image_headbg:loadTexture(res2, 1)

    local head = item:getChildByName("Image_head")
    local player = self.logic:getPlayerByUid(data.uid)
    if player then
        head:setVisible(true)    
        GameCommon:getUserHead(player.portrait, player.uid, player.sex, head, 70, false, player.nickName)
    else
        head:setVisible(false) 
    end

    local Image_dayinjia = item:getChildByName("Image_dayinjia")
    Image_dayinjia:setVisible(data.bigWin == 1)

    local Text_value4 = item:getChildByName("Text_value4")
    Text_value4:setString("+" .. data.chips)

    local Text_value1 = item:getChildByName("Text_value1")
    Text_value1:setString(data.zhuazhu or 0)

    local Text_value2 = item:getChildByName("Text_value2")
    Text_value2:setString(data.piao or 0)

    local Text_value3 = item:getChildByName("Text_value3")
    Text_value3:setString(data.winCount or 0)
end

function NinetySixTotalSettle:onClickBack(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl:returnToHall()
end

function NinetySixTotalSettle:onClickShare(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl:doShareScreen()
end

return NinetySixTotalSettle