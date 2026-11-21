
    -- 0x7C, 0x7C,
    -- 0x62, 0x62,
    -- 0x58, 0x58,
    -- 0x44, 0x44,
    -- 0x34, 0x34, 0x36, 0x36, 0x3A, 0x3A,
    -- 0x26, 0x26, 0x27, 0x27, 0x2A, 0x2A, 0x2B, 0x2B,
    -- 0x13, 0x15, 0x16, 0x17, 0x18, 0x19,
    -- 0x05, 0x07, 0x08, 0x09

local Card = class("Card", function ()
    return ccui.Button:create()
end)

function Card:ctor(this, value)

    self.body = display.newSprite():addTo(self)
    self:setCard(value)

end

function Card:setCard(value)
    self.m_value = value
    self.m_isSelected = false
    self:initView()
end

function Card:initView()
--[[    if self.m_value ~= 0 then
        self:setScale(-1)
        self:loadTextureNormal("paijiu/images/cards/" .. self.m_value .. ".png")
        local turn_action = cc.ScaleTo:create(0.2, 1)
        self:runAction(cc.Sequence:create(turn_action))
    else
        self:loadTextureNormal("paijiu/images/cards/" .. self.m_value .. ".png")
    end]]
    --self:loadTextureNormal("paijiu/images/cards/" .. self.m_value .. ".png")
    self:loadTextures("paijiu/images/cards/" .. self.m_value .. ".png", nil, nil)
    --local size = self:getContentSize()
    --self:setContentSize(size.width * 2, size.height * 2)
end


return Card