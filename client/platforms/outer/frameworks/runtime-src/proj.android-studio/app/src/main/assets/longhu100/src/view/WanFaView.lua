
local disclaimer_content = cc.FileUtils:getInstance():getStringFromFile("longhu100/src/view/WanFaView.json")
local disclaimer_config = json.decode(disclaimer_content)
-- 游戏ID和游戏名字的对应表 
local GAME_ID_TO_NAME = 
{
    [1] = "游戏介绍",
    [2] = "点数大小",
    [3] = "游戏玩法",
}
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local WanFaView = class("WanFaView", NewViewBaseLayer)
function WanFaView:ctor()
    WanFaView.super.ctor(self, "longhu100/res/View/WanFaView.csb", false)
    GameUtils.setNodeNameBindObj(self)
    self:enableMask(true)
    self:initUI()
    self:initEvent()
    self:loadAllGameLst()
end

function WanFaView:initUI()
    self.btnClose = self._csbNode.root.bg.btnClose
    self.item = self._csbNode.root.item:hide()
    self.gameListView = self._csbNode.root.gameListView
    self.contentListView = self._csbNode.root.contentListView
    self.gameListView:setBounceEnabled(false)
    self.gameListView:setScrollBarEnabled(false)
    self.contentListView:setScrollBarEnabled(false)
    self.gameListView:removeAllItems()
    self.contentListView:removeAllItems()
end

function WanFaView:initEvent()
    self.btnClose:onClick(handler(self, self.onClickClose), true)
end

function WanFaView:loadAllGameLst()
   for i,v in ipairs(GAME_ID_TO_NAME) do
        local item = self.item:clone()
        GameUtils.setNodeNameBindObj(item)
        item.txt:setString(v)
        item:show()
        item:onClick(handler(self, self.touchCallBack), true)
        item.idx = v
        self.gameListView:pushBackCustomItem(item)
   end
   self:touchCallBack({target = self.gameListView:getChildren()[1]})
end

function WanFaView:touchCallBack(event)
    local target = event.target
    local child = target:getParent():getChildren()
    for i,v in ipairs(child) do
        v:setTouchEnabled(true)
        v:setBright(true)
    end
    target:setTouchEnabled(false)
    target:setBright(false)
    self:showInstructionByGameID(target.idx)
end

function WanFaView:showInstructionByGameID(idx)
    self.contentListView:removeAllChildren()
    self.contentListView:jumpToTop()
    local content = disclaimer_config[idx] or ""
    local txtWidth = self.contentListView:getContentSize().width
    local txtCount = string.len(content)
    local lineCount = (txtCount * 10) / txtWidth
    local label = display.newTTFLabel({
        text = content,
        font = "hall/res/font/FZY3JW.TTF",
        size = 26,
        color = cc.c3b(77, 77, 77),
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(txtWidth, 0)
    })
    label:setAnchorPoint(cc.p(0,0))
    local groupLY = ccui.Layout:create()
    groupLY:setAnchorPoint(cc.p(0,0))
    groupLY:setTouchEnabled(false)
    groupLY:setContentSize(cc.size(750, label:getContentSize().height))
    groupLY:addChild(label)
    self.contentListView:pushBackCustomItem(groupLY)
end

function WanFaView:onClickClose(event)
    self:removeSelf()
end

return WanFaView