local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local PlayerView = class("PlayerView", NewViewBaseLayer)
local Server = require("longhu100.src.handle.Server")
function PlayerView:ctor(data)
    PlayerView.super.ctor(self, "longhu100/res/View/PlayerView.csb", false)
    self:enableMask(true)
    GameUtils.setNodeNameBindObj(self)
    self:setNodeEventEnabled(true)
    self:initUI()
    self:initEvent()
    self:setData(data)
end

function PlayerView:initUI()
    self.btnClose = self._csbNode.root.bg.btnClose
    self.item = self._csbNode.root.item:hide()
    self.ListView = self._csbNode.root.ListView
    self.ListView:setScrollBarEnabled(false)
    self.ListView:removeAllItems()
   
end

function PlayerView:initEvent()
    self.btnClose:onClick(handler(self, self.onClickClose), true)
end

function PlayerView:onClickClose(event)
    self:removeSelf()
end

function PlayerView:setData(data)
    local newUserInfo = {}
    for i,v in ipairs(data) do
        newUserInfo[v.uid] = v
    end
    local userInfos = {}
    for i,userInfo in ipairs(g_101.allUser) do
        if userInfo.seat_id >= 0 and userInfo.isBanker ~= 1 and newUserInfo[userInfo.uid] then
            userInfo.totalScore = newUserInfo[userInfo.uid].totalScore or 0
            userInfo.times = newUserInfo[userInfo.uid].times or 0
            table.insert( userInfos, userInfo )
        end
    end
    table.sort(userInfos, function(a, b)
        return a.totalScore > b.totalScore
    end)
    for i,v in ipairs(userInfos) do
        local item = self.item:clone():show()
        GameUtils.setNodeNameBindObj(item)
        self.ListView:pushBackCustomItem(item)
        require("hall.GameCommon"):getUserHead(v.portrait, nil, nil, item.head, item.head:getWidth(), false, nil, true, nil, nil)
        local nickName = require("hall.GameCommon"):formatNick(v.nickName, 3)
        item.txt_rank:setString("")
        item.txt_name:setString(nickName)

        item.txt_xiazhu:setString(v.totalScore)
        item.txt_huosheng:setString(v.times)
        item.txt_chip:setString(v.chips / 100)
        if i <= 5 then
            item.img_rank:loadTexture(string.format("longhu100/res/View/%d.png", i))
            item.img_rank:ignoreContentAdaptWithSize(true)
        end
    end

	
end

function PlayerView:onExit()

end

return PlayerView
