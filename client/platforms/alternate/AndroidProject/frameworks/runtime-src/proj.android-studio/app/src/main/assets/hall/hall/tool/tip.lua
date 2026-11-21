-- local HTMLLabel = _V("component.html_label")

local Tip = class("Tip", ccui.Layout)


local TIP_BG = "hall/scene/res/singlered/image/tip/niukind_bottom.png"
local MAX_WIDTH = display.width
local MIN_WIDTH = 381
local MIN_HEIGHT = 56
local TIP_CAP_INSETS = cc.rect(150, 25, 2, 2)

local DEFAULT_SHADOW_COLOR = cc.c4b(0, 0, 0, 127)
local DEFAULT_SHADOW_OFFSET = cc.size(2, -3)
local DEFAULT_SHADOW_BLUR_RADIUS = 2
local DEFAULT_OUTLINE_COLOR = cc.c3b(0, 0, 0)
local DEFAULT_OUTLINE_WIDTH = 1

function Tip:ctor(params)
    self._text = params.text or ""
    self:_createText()
    self:_createBg()
    self:_createAction()
    self:setCascadeOpacityEnabled(true)
end

function Tip:close()
    viewMgr:closeTip(self)
end

function Tip:getHeight()
    return self._labelSize.height
end

function Tip:_createBg()
    self._bg = ccui.ImageView:create(TIP_BG)
    self._bg:setTouchEnabled(false)
    self._bg:setAnchorPoint(cc.p(0.5, 0.5))
    self._bg:setOpacity(180)
    self._bg:setScale9Enabled(true)
    self._bg:setCapInsets(TIP_CAP_INSETS)
    local width = self._labelSize.width + 200
    if width < MIN_WIDTH then
        width = MIN_WIDTH
    end
    local height = self._labelSize.height + 10
    if height < MIN_HEIGHT then
        height = MIN_HEIGHT
    end
    self._bg:setContentSize(cc.size(width, height))
    self:addChild(self._bg, 0)
end

function Tip:_createText()
    local htmlLabel = ccui.Text:create()
    htmlLabel:setString(self._text)
    htmlLabel:setCascadeOpacityEnabled(true)
    self._htmlLabel = htmlLabel

    htmlLabel:setFontName("hall/res/font/FZY3JW.TTF")
    htmlLabel:setFontSize(28)
    self._labelSize = htmlLabel:getContentSize()
    if self._labelSize.width > MAX_WIDTH then
        -- htmlLabel:setWidth(MAX_WIDTH)
        htmlLabel:setContentSize(MAX_WIDTH, self._labelSize.height)
        self._labelSize = htmlLabel:getContentSize()
    end
    self:addChild(htmlLabel, 2)
end

function Tip:_createAction()
    transition.fadeOut(self, {time = 0.5, delay = 1, onComplete = function ()
        -- viewMgr:closeTip(self)
        self:removeSelf()
    end})
end


return Tip