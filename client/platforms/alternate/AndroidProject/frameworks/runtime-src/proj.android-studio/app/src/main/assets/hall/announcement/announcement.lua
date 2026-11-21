--[[
	公告弹出框
]]
local ViewBaseLayer = require("hall.NewViewBaseLayer")
local disclaimer_content = cc.FileUtils:getInstance():getStringFromFile("hall/announcement/disclaimer_config.json")
local disclaimer_config = json.decode(disclaimer_content)
local AnnouncementView = class("AnnouncementView", ViewBaseLayer)

function AnnouncementView:ctor()
    local csbPath = "hall/res/announcement/announcement.csb"
	AnnouncementView.super.ctor(self, csbPath)
	-- self:enableMask(true)
    self:initUI()
end

--[[
	初始化UI
]]
function AnnouncementView:initUI()
	self.tabTb = self.tabs:getChildren()
	self.contents = self.vws:getChildren()
    self:initTab()
    self:showInstructionByGameID(self.content_3, disclaimer_config.content)
    self:showInstructionByGameID(self.content_4, disclaimer_config.content_1)
    -- self.tabs:setScrollBarEnabled(false)
    self.content_3:setScrollBarEnabled(false)
    self.content_4:setScrollBarEnabled(false)
end

--[[
	初始化tab标签
]]
function AnnouncementView:initTab()
    for k, v in ipairs(self.tabTb) do
        v:onTouch(function(event)
            if event.name == "ended" then
                dump(k)
                self:select(k)
            end
        end)
    end
    self:select(1)
end

function AnnouncementView:select(index)
    if self._selectIndex == index then
        return
    end
    self._selectIndex = index
    for i, node in ipairs(self.tabTb) do
        node:setTouchEnabled(not (index == i))
        node:setBright(not (index == i))
    end
    if index == self.tabIndex then return end
    local tabItem = self.tabTb[index]
    self.tabIndex = index
    for i, node in ipairs(self.contents) do
        node:setVisible(index == i)
    end
end

--[[
	更新内容
]]
function AnnouncementView:updateContent(data)

end

function AnnouncementView:showInstructionByGameID(node, content)
    node:removeAllChildren()
    local txtWidth = 740
    local txtCount = string.len(content)
    local lineCount = (txtCount * 10) / txtWidth

    local label = display.newTTFLabel({
        text = content,
        font = "hall/res/font/FZY3JW.TTF",
        size = 26,
        color = cc.c3b(103, 113, 150),
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(txtWidth, 0)
    })
    -- label:setLineHeight(40) 
    label:setAnchorPoint(cc.p(0,0))
    local groupLY = ccui.Layout:create()
    groupLY:setAnchorPoint(cc.p(0,0))
    groupLY:setTouchEnabled(false)
    groupLY:setContentSize(cc.size(750, label:getContentSize().height))
    groupLY:addChild(label)
    node:pushBackCustomItem(groupLY)
end
-- 关闭界面
function AnnouncementView:onClickBtnClose(sender, event)
    self:removeSelf()
end

return AnnouncementView

