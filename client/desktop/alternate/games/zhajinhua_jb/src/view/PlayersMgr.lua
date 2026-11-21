local PlayersMgr = class("PlayersMgr")

function PlayersMgr:ctor(players)
    self.players = players:hide()
end

function PlayersMgr:initUI()
    -- local GameSceneView = self.players:getParent()
    -- for k, UserInfoView in pairs(GameSceneView.UserInfoViews) do
    --     UserInfoView.player:hide()
    --     UserInfoView:initUI(UserInfoView.player, true)
    -- end
end

function PlayersMgr:setPlayerNum(TOTAL_PLAYERNUM)
    self.players:show()
    if TOTAL_PLAYERNUM == 6 then
        local player_right = self.players.player_right:setName("player_2")
        local player_top = self.players.player_top:setName("player_3")
        local player_left = self.players.player_left:setName("player_6")
        local player_2 = self.players:addChild(player_right:clone():setName("player_2"))
        self.players:addChild(player_top:clone():setName("player_3"))
        self.players:addChild(player_left:clone():setName("player_6"))

        self.players:addChild(player_top:clone():setName("player_5"))
        self.players:addChild(player_top:clone():setName("player_4"))

        player_2.isLeft = false
    elseif TOTAL_PLAYERNUM == 8 then
        local player_right = self.players.player_right:setName("player_2")
        local player_top = self.players.player_top:setName("player_4")
        local player_left = self.players.player_left:setName("player_7")

        local player_2 = self.players:addChild(player_right:clone():setName("player_2"))
        self.players:addChild(player_top:clone():setName("player_4"))
        self.players:addChild(player_left:clone():setName("player_7"))

        local player_3 = self.players:addChild(player_right:clone():setName("player_3"))
        self.players:addChild(player_top:clone():setName("player_5"))
        self.players:addChild(player_top:clone():setName("player_6"))
        self.players:addChild(player_left:clone():setName("player_8"))
        player_3.isLeft = false
        player_2.isLeft = false
    elseif TOTAL_PLAYERNUM == 9 then
        local player_right = self.players.player_right:setName("player_2")
        local player_top = self.players.player_top:setName("player_4")
        local player_left = self.players.player_left:setName("player_8")

        local player_2 = self.players:addChild(player_right:clone():setName("player_2"))
        self.players:addChild(player_top:clone():setName("player_4"))
        self.players:addChild(player_left:clone():setName("player_8"))

        local player_3 = self.players:addChild(player_right:clone():setName("player_3"))
        self.players:addChild(player_top:clone():setName("player_5"))
        self.players:addChild(player_top:clone():setName("player_6"))
        self.players:addChild(player_top:clone():setName("player_7"))
        self.players:addChild(player_left:clone():setName("player_9"))
        player_3.isLeft = false
        player_2.isLeft = false
    else
        local player_right = self.players.player_right:setName("player_2")
        local player_top = self.players.player_top:setName("player_4")
        local player_left = self.players.player_left:setName("player_10")

        local player_2 = self.players:addChild(player_right:clone():setName("player_2"))
        self.players:addChild(player_top:clone():setName("player_4"))
        self.players:addChild(player_left:clone():setName("player_10"))

        local player_3 = self.players:addChild(player_right:clone():setName("player_3"))
        self.players:addChild(player_top:clone():setName("player_5"))
        self.players:addChild(player_top:clone():setName("player_6"))
        self.players:addChild(player_top:clone():setName("player_7"))
        self.players:addChild(player_top:clone():setName("player_8"))
        self.players:addChild(player_left:clone():setName("player_9"))
        TOTAL_PLAYERNUM = 10
        player_3.isLeft = false
        player_2.isLeft = false
    end
    self.players.player_right:removeSelf()
    self.players.player_top:removeSelf()
    self.players.player_left:removeSelf()
    self.players.player_right = nil
    self.players.player_top = nil
    self.players.player_left = nil
    local GameSceneView = self.players:getParent()
    local players = GameSceneView["players_"..TOTAL_PLAYERNUM]
    local childs = self.players:getChildren()
    for idx, node in ipairs(childs) do
        node:hide()
        local name = node:getName()
        if name ~= "player_1" then
            local pos = players[name]:getPosition()
            node:setPosition(pos)
            GameUtils.setNodeNameBindObj(node)
        end
        self.players[name] = node
        local UserInfoView = require("zhajinhua_jb.src.view.UserInfoView").new(node)
        UserInfoView.isLeft = node.isLeft == false and false or true
        GameSceneView.UserInfoViews[name] = UserInfoView
    end
end

return PlayersMgr
