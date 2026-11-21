local GameSceneView = class("GameSceneView", function()
    if device.platform == "ios" then
        if isiOSVerify then
            return cc.CSLoader:createNode("jchuapai/res/record/GameScene.csb")
        else
            return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "jchuapai/res/record/GameScene.csb")
        end
    else
        return cc.CSLoader:createNode("jchuapai/res/record/GameScene.csb")
    end
    -- return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."jchuapai/res/record/GameScene.csb")
end)

function GameSceneView:ctor()
    GameUtils.setNodeNameBindObj(self)
    self:setNodeEventEnabled(true)
    self:initUI()
end

function GameSceneView:initUI()
    display.doLayout(self)
    self.player_1 = self.players.player_1:hide()
    self.player_2 = self.players.player_2:hide()
    self.player_3 = self.players.player_3:hide()
    self.img_count = self.cards_vw.img_count
    self.img_count.txt_cardCount:setString("0")
    self.player_1 = require("jchuapai.src.record.UserInfoView").new(self.player_1)
    self.player_2 = require("jchuapai.src.record.UserInfoView").new(self.player_2)
    self.player_3 = require("jchuapai.src.record.UserInfoView").new(self.player_3)

end

function GameSceneView:hideAllPlayerOutCard()
    self.player_1:isShowOutCard(false)
    self.player_2:isShowOutCard(false)
    self.player_3:isShowOutCard(false)
end

function GameSceneView:hideAllPlayerLight()
    self.player_1:isShowLight(false)
    self.player_2:isShowLight(false)
    self.player_3:isShowLight(false)
end

function GameSceneView:starGame()
    self.player_1:isShowTongCountd(true, 0)
    self.player_2:isShowTongCountd(true, 0)
    self.player_3:isShowTongCountd(true, 0)
    self.player_1:isShowHuCountd(true, 0)
    self.player_2:isShowHuCountd(true, 0)
    self.player_3:isShowHuCountd(true, 0)
end

function GameSceneView:isShowBackNodeCount( isShow, count )
    self.img_count:setVisible(isShow)
    if count then
        self.img_count.txt_cardCount:setString(count)
        self.backCount = count
    end
end

return GameSceneView
