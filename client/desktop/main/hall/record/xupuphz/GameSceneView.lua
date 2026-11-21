local CardUtils = require("xupuphz.src.CardUtils")
local Card = require("xupuphz.src.Card")
local GameSceneView = class("GameSceneView", function()
    return cc.CSLoader:createNode("hall/res/record/xupuphz/GameScene.csb")
end)

function GameSceneView:ctor()
    GameUtils.setNodeNameBindObj(self)
    self:setNodeEventEnabled(true)
    self:initUI()
end

function GameSceneView:initUI()
    display.doLayout(self)
    self.sendCardNode = self.cards_vw.sendCardNode:hide()
    self.img_count = self.cards_vw.img_count
    self.txt_cardCount = self.cards_vw.img_count.txt_cardCount:setString("")
    self.player_1 = self.players.player_1:hide()
    self.player_2 = self.players.player_2:hide()
    self.player_3 = self.players.player_3:hide()
    self.player_1 = require("hall.record.xupuphz.UserInfoView").new(self.player_1)
    self.player_2 = require("hall.record.xupuphz.UserInfoView").new(self.player_2)
    self.player_3 = require("hall.record.xupuphz.UserInfoView").new(self.player_3)
end

function GameSceneView:clearData()
    self.sendCardNode:stopAllActions()
    self.sendCardNode:hide()
    self.player_1:clearData()
    self.player_2:clearData()
    self.player_3:clearData()
    self:isShowBackNodeCount(false)
    self:isShowChouVw( false )
end

function GameSceneView:setGameResult( data )
    -- local roomId = "房间号:"..self.roomId
    -- local round = self.hall.device_info_plane.txt_round:getString()
    -- self.baseChip = self.baseChip or 1
    -- local str = roomId.." "..round.." 底分:"..self.baseChip
    self.GameResult = GameResult.new(data, self.roomId, self):addTo(self)
    local size = self:getContentSize()
    self.GameResult:setAnchorPoint(0.5, 0.5)
    self.GameResult:setPosition(size.width / 2, size.height / 2)
end

function GameSceneView:hideAllPlayerOutCard(isActionHide)
    if isActionHide then
        self:stopAllActions()
        local Sequence = cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(
                function()
                    self.player_1:isShowOutCard(false)
                    self.player_2:isShowOutCard(false)
                    self.player_3:isShowOutCard(false)
                end)
        )
        self:runAction(Sequence)
    else
        self.sendCardNode:stopAllActions()
        self.sendCardNode:hide()
        self.player_1:isShowOutCard(false)
        self.player_2:isShowOutCard(false)
        self.player_3:isShowOutCard(false)
    end
end

function GameSceneView:hideAllPlayerLight()
    self.player_1:isShowLight(false)
    self.player_2:isShowLight(false)
    self.player_3:isShowLight(false)
end

function GameSceneView:starGame()
    self.player_1:isShowHuCount(true, 0)
    self.player_2:isShowHuCount(true, 0)
    self.player_3:isShowHuCount(true, 0)
end


function GameSceneView:isShowBackNodeCount( isShow, count )
    -- self.img_count:setVisible(isShow)
    self.img_count.txt_cardCount:setVisible(isShow)
    if count then
        self.img_count.txt_cardCount:setString(count)
        self.backCount = count
    end
end

function GameSceneView:sendCard( viewId, card )
    local posArr = {
        [1] = cc.p(657, 112),
        [2] = cc.p(1112, 570),
        [3] = cc.p(173, 570),
    }
    Card:changeImg(self.sendCardNode, card, "max")
    self.sendCardNode:stopAllActions()
    self.sendCardNode:setPosition(657.36, 570.19)
    self.sendCardNode:show()
    self.sendCardNode:setScale(1)
    local pos = posArr[viewId]
    local MoveTo = cc.MoveTo:create(0.38, pos)
    local ScaleTo = cc.ScaleTo:create(0.38, 0.1)
    local func = cc.CallFunc:create(function( fc )
        self.sendCardNode:hide()
    end)
    local Spawn = cc.Spawn:create(MoveTo,ScaleTo)
    self.sendCardNode:runAction(cc.Sequence:create(Spawn, func))
end


return GameSceneView
