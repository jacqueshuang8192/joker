--玩家头像
local NinetySixPlayer = class("NinetySixPlayer")

function NinetySixPlayer:ctor(scene, parent, viewId)
    self.scene = scene
    self.ctrl = scene.ctrl
    self.logic = self.ctrl.logic

    self.viewId = viewId
    self.node = parent:getChildByName("player" .. viewId)

    self:initUI()
    self:playerExit()
end

function NinetySixPlayer:onEnter()
    self.tEvents = {
        GameEvent:addListen("NinetySixLoginRoomInfo", handler(self, self.playerExit)),
        GameEvent:addListen("NinetySixReconnection", handler(self, self.playerExit)),
        GameEvent:addListen("NinetySixPlayerInitialEnter", handler(self, self.setPlayer)),
        GameEvent:addListen("NinetySixAddPlayer", handler(self, self.setPlayer)),
        GameEvent:addListen("NinetySixDelPlayer", handler(self, self.delPlayerByUid)),
        GameEvent:addListen("NinetySixPlayerDisconnect", handler(self, self.playerDisconnect)),
        GameEvent:addListen("NinetySixChangeBankerSeat", handler(self, self.changeBanker)),
        GameEvent:addListen("NinetySixReadyStatus", handler(self, self.setReadyImageShow)),
        GameEvent:addListen("NinetySixDealCards", handler(self, self.hideReadyImage)),
        GameEvent:addListen("NinetySixUpdateHuXi", handler(self, self.updateHuXi)),
        GameEvent:addListen('NinetySixNextRoundClean', handler(self, self.nextRoundClean)),
        GameEvent:addListen("NinetySixUpdatePiao", handler(self, self.UpdatePiao)),
        GameEvent:addListen("NinetySixMoveHead", handler(self, self.MoveHead)),
    }
end

function NinetySixPlayer:onExit()
    for k, e in pairs(self.tEvents) do
        GameEvent:delListen(e)
    end
end

function NinetySixPlayer:initUI()
    self.Head = self.node:getChildByName("Head")
    self.Text_info1 = self.node:getChildByName("Text_info1")
    self.Text_info2 = self.node:getChildByName("Text_info2")
    self.Text_info3 = self.node:getChildByName("Text_info3")

    self.PiaoScore = self.node:getChildByName("PiaoScore")
    self.Piao_Txt = self.PiaoScore:getChildByName("Piao_Txt")

    self.PlayerScore = self.node:getChildByName("PlayerScore")
    self.ScoreTxt = self.PlayerScore:getChildByName("ScoreTxt")

    self.Image_sex = self.node:getChildByName("Image_sex")
    self.Image_offline = self.node:getChildByName("Image_offline")
    self.Image_banker = self.node:getChildByName("Image_banker")
    self.Image_ready = self.node:getChildByName("Image_ready")
    self.headWSPos = self.node:convertToWorldSpace(self.Head:getPosition())
    if self.viewId == 1 then
        self.HeadMoveNode = cc.CSLoader:createNode("96game/res/csb/96HeadMove.csb"):addTo(self.node)
        self.HeadMoveNode:setName("headLayer")
        self.HeadMoveNode:setLocalZOrder(15)
        self.HeadMoveNode:setPosition(cc.p(1090,300))
        self.HeadMoveNode:setVisible(false)
        local  action = cc.CSLoader:createTimeline("96game/res/csb/96HeadMove.csb")
        self.HeadMoveNode:runAction(action)
        action:gotoFrameAndPlay(0,true)
    end
end

function NinetySixPlayer:playerExit()
    self.data = nil
    self.Text_info1:setString("")
    self.Text_info2:setString("")
    self.Text_info3:setString("")
    self.Image_sex:setVisible(false)
    self.Image_banker:setVisible(false)
    self.Image_ready:setVisible(false)
    self.Image_offline:setVisible(false)

    self.Piao_Txt:setString("0")
    --self.PiaoScore:setVisible(false)

    self.ScoreTxt:setString("")
    self.PlayerScore:setVisible(false)

    self.Head:setVisible(false)
    self.node:setVisible(false)
end

function NinetySixPlayer:setPlayer(viewId, data)
    dump(self.viewId,"NinetySixPlayerInitialEnter"..viewId)
    if viewId ~= self.viewId then
        return
    end
    self:setData(data)
    self.node:setVisible(true)
end

function NinetySixPlayer:playerDisconnect(uid, disconnect)
    if self.data and self.data.uid == uid then
        self.Image_offline:setVisible(disconnect)
    end
end

function NinetySixPlayer:setReadyImageShow(uid, ready)
    if self.data and self.data.uid == uid then
        self.Image_ready:setVisible(ready == 1 and #self.logic.tPlayerCards == 0)
    end
end

function NinetySixPlayer:hideReadyImage()
    self.Image_ready:setVisible(false)
end

function NinetySixPlayer:delPlayerByUid(uid)
    if self.data and self.data.uid == uid then
        self:playerExit()
    end
end

function NinetySixPlayer:setData(data)
    local common = require("hall.GameCommon")
    self.data = data

    self.Text_info1:setString(common:formatNick(self.data.nickName))
    local num = (self.data.m_totalBlc or 0) / 100
    self.Text_info2:setString(tostring(num))

    local res = "ninetysix_poker_sex_1.png"
    if self.data.sex == 2 then
        res = "ninetysix_poker_sex_2.png"
    end

    self.Image_sex:setVisible(true)
    self.Image_sex:loadTexture(res, 1)
    self.Image_offline:setVisible(false)
    self:changeBanker()
    self.Image_ready:setVisible(self.data.ready == 1 and #self.logic.tPlayerCards == 0)
    if self.data.m_HuXi then
        self.Text_info3:setString("胡:" .. tostring(self.data.m_HuXi))
    else
        self.Text_info3:setString("胡:0")
    end
    self.Piao_Txt:setString(self.data.m_nPiao or "0")
    self.Head:setVisible(true)
    common:getUserHead(self.data.portrait, self.data.uid, self.data.sex, self.Head, 70, false, self.data.nickName)
    
    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(self.data.uid, self.headWSPos)
end

function NinetySixPlayer:changeBanker()
    self.Image_banker:setVisible(self.data and self.data.seatId == self.logic.bankerSeatId)
end

function NinetySixPlayer:updateHuXi(seatId, HuXi)
    if HuXi and self.data and self.data.seatId == seatId then
        self.Text_info3:setString("胡:" .. tostring(HuXi))
    end
end

function NinetySixPlayer:upatePoint()
    local num = (self.data and self.data.m_totalBlc or 0) / 100
    self.Text_info2:setString(tostring(num))
end

function NinetySixPlayer:nextRoundClean()
    self.Text_info3:setString("胡:0")
    self:upatePoint()
end
function NinetySixPlayer:UpdatePiao(seatId, piaoFeng)
    if self.data and self.data.seatId == seatId then
        self.Piao_Txt:setString(piaoFeng)
    end
end
function NinetySixPlayer:MoveHead(seatId)
    if self.data and self.data.seatId == seatId and self.viewId == 1 then
        self.HeadMoveNode:setVisible(true)
    else
        if self.HeadMoveNode then
            self.HeadMoveNode:setVisible(false)
        end

    end
end
return NinetySixPlayer
