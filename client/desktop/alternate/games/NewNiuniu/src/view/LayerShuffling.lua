--此模块由@Levan维护
local NiuNiuSendHandle = import("NewNiuniu.src.protocol.NiuNiuSendHandle")
local LayerShuffling = class('LayerShuffling')

-- if APPLE_APP_VERSION == 1 then
--     require(TpackageName .. '.DrawNodeEx')
-- end

local Shuffle_card_scale = 1
local Shuffling_card_path = 'NewNiuniu/res/csb/LayerShuffling/' --newcard
local VARIETY_DIAMOND = 0x00 -- 方块
local VARIETY_CLUB = 0x10 -- 梅花
local VARIETY_HEART = 0x20 -- 红桃
local VARIETY_SPADE = 0x30 -- 黑桃local 
local VARIETY_LAIZI = 0x40 -- 癞子

local CARD_VARIETY_TRANSFORM_PATH = {
    [VARIETY_DIAMOND] = Shuffling_card_path .. 'diamonds_',
    [VARIETY_CLUB] = Shuffling_card_path .. 'clubs_',
    [VARIETY_HEART] = Shuffling_card_path .. 'hearts_',
    [VARIETY_SPADE] = Shuffling_card_path .. 'spades_',
    [VARIETY_LAIZI] = Shuffling_card_path .. 'laizi_'
}

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)
    if value == 1 then
        value = 14
    end
    return value
end

function LayerShuffling:ctor(cardUint)
    if LayerShuffling then
        self:removeScene()
    end

    local LayerShuffling = cc.CSLoader:createNode('NewNiuniu/res/csb/LayerShuffling/LayerShuffling.csb'):addTo(g_mainScene)
    LayerShuffling:setName('LayerShuffling')
    Shuffle_card_scale = SCREEN_WIDTH / DESIGN_SCREEN_WIDTH

    local standardSize = {width = 369, height = 554}
    local card_back_path = 'NewNiuniu/res/csb/LayerShuffling/card_back.png'
    local card_size = standardSize
    self.poker_blank = LayerShuffling:getChildByName('poker_blank')
    self.poker_blank:loadTexture(card_back_path, 0)
    self.poker_blank:setSize(standardSize)
    self.poker_blank:setScale(Shuffle_card_scale)

    self.Updated = false

    self.s = cc.Director:getInstance():getWinSize()

    self.clipper = cc.ClippingNode:create()
    self.clipper:setContentSize(standardSize)

    self.clipper:setAnchorPoint(cc.p(0.5, 0.5))
    self.clipper:setPosition(self.s.width / 2, self.s.height / 2)
    self.clipper:setRotation(-90)

    LayerShuffling:addChild(self.clipper)

    self.stencil = cc.DrawNode:create()

    local rectangle = {cc.p(0, 0), cc.p(400, 0), cc.p(400, 458 + 100), cc.p(0, 458 + 100)}

    local params = {fillColor = cc.c4f(1, 1, 1, 1), borderWidth = 1, borderColor = cc.c4f(0, 0, 0, 1)}
    local fillColor = cc.c4f(1, 1, 1, 1)
    local borderWidth = 1
    local borderColor = cc.c4f(0, 0, 0, 1)


    if APPLE_APP_VERSION == 1 then
        if device.platform == 'android' then
            self.stencil:drawPolygon(rectangle, params)
        else
            self.stencil:drawPolygon(rectangle, #rectangle, fillColor, borderWidth, borderColor)
        end
    else
        self.stencil:drawPolygon(rectangle, params)
    end

    self.clipper:setStencil(self.stencil)

    self.back = ccui.ImageView:create(card_back_path, 0)

    self.back:setScaleX(standardSize.width / card_size.width)
    self.back:setScaleY(standardSize.height / card_size.height)
    self.back:setAnchorPoint(cc.p(0.5, 0.5))
    self.back:setPosition(self.clipper:getContentSize().width / 2, self.clipper:getContentSize().height / 2)
    self.clipper:addChild(self.back)
    self.clipper:setScale(Shuffle_card_scale)

    self.front = self:createSingleCard(cardUint)

    self.front:setRotation(180)
    self.front:setAnchorPoint(cc.p(0.5, 0.5))
    self.front:setPosition(-self.front:getContentSize().width / 2 - 10, self.clipper:getContentSize().height / 2)
    self.clipper:addChild(self.front)

    --@Levan 发牌移动
    self.clipper:setVisible(true)

    self.poker_blank:setPosition(cc.p(self.s.width / 2, self.s.height / 2))
    self.poker_blank:setVisible(false)


    self._scrolling = false
    self._lastPoint = {}
    self:initEvent()

end

function LayerShuffling:createSingleCard(cardUint)
    local cardUint_ = cardUint or 1
    local cardPath = ''
    if cardUint == 0x4e or cardUint == 0x4f then
        if cardUint == 0x4e then
            cardPath = Shuffling_card_path .. 'small_king.png'
        else
            cardPath = Shuffling_card_path .. 'big_king.png'
        end
    else
        local cardValue_ = getValue(cardUint)
        local cardVariety_ = getVariety(cardUint)
        print("createSingleCard ----------------- ", cardValue_, cardVariety_)
        if cardValue_ >= 2 and cardValue_ < 10 then
            cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. '0' .. cardValue_ .. '.png'
        else
            cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. cardValue_ .. '.png'
        end
    end
    print("createSingleCard -----------------11  ", cardPath)
    local ImageView = ccui.ImageView:create(cardPath, 0)
    return ImageView
end

function LayerShuffling:shader()
end

function LayerShuffling:initEvent()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    local listener = cc.EventListenerTouchOneByOne:create()
    local diff
    local stencilOriPos = self.stencil:getPosition()

    local function onTouchBegan(touch, event)
        if self.clipper:isVisible() == false then
            return
        end

        local point = self.clipper:convertToNodeSpace(cc.Director:getInstance():convertToGL(touch:getLocationInView()))
        local rect =
            cc.rect(-1000, -1000, self.clipper:getContentSize().width + 2000, self.clipper:getContentSize().height + 2000)

        self._scrolling = cc.rectContainsPoint(rect, point)
        self._lastPoint = point

        if self._scrolling then
            return true
        end

        return false
    end

    local function onTouchMoved(touch, event)
        local point = {}
        point = self.clipper:convertToNodeSpace(cc.Director:getInstance():convertToGL(touch:getLocationInView()))
        diff = cc.p(point.x - self._lastPoint.x, point.y - self._lastPoint.y)

        local startfrontposx = -self.front:getContentSize().width / 2 - 10
        local endfrontposx = -self.front:getContentSize().width / 2 + self.clipper:getContentSize().width

        if self.front:getPositionX() + diff.x < startfrontposx or self.front:getPositionX() + diff.x > endfrontposx then
        else
            self.front:setPositionX(self.front:getPositionX() + diff.x)
            self.stencil:setPositionX(self.stencil:getPositionX() + diff.x / 2)
        end

        self._lastPoint = point
    end

    local function onTouchEnded(touch, event)
        if self._scrolling == false then
            return
        end

        self._scrolling = false

        if self.front:getPositionX() > 50 - self.front:getContentSize().width / 2 then
            self.front:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(
                        1,
                        cc.p(self.clipper:getContentSize().width / 2, self.clipper:getContentSize().height / 2)
                    )
                )
            )
            self.back:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(
                        1,
                        cc.p(-self.back:getContentSize().width / 2 - 10, self.clipper:getContentSize().height / 2)
                    )
                )
            )
            --@Levan 移动 裁剪模板
            ---------------------------------------------------------------------------------------------cca.moveTo
            --@Levan 移动 裁剪模板
            self.stencil:setPosition(cc.p(0, 0))
            
            g_mainScene.gameUserInfoLayer:turnMyLastCards()
            NiuNiuSendHandle:sendMycards({0, 0, 0})
            self.clipper:runAction(
                cc.Sequence:create(
                    cc.ScaleTo:create(0.5, Shuffle_card_scale + 0.2),
                    cc.ScaleTo:create(0.5, Shuffle_card_scale),
                    cc.DelayTime:create(1.5),
                    cc.CallFunc:create(
                        function()
                            self:removeScene() --@Levan n秒后自动移除
                        end
                    )
                )
            )

            eventDispatcher:removeEventListener(listener)
        else
            -- --@Levan 放大 裁剪模板
            self.front:runAction(
                cc.MoveTo:create(
                    0.3,
                    cc.p(-self.front:getContentSize().width / 2 - 10, self.clipper:getContentSize().height / 2)
                )
            )

            ---------------------------------------------------------
            g_mainScene:performWithDelay(
                function()
                    if not tolua.isnull(self.stencil) then
                        self.stencil:setPosition(stencilOriPos)
                    end
                end,
                0.21
            )

        end
    end

    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.clipper)
end

function LayerShuffling:removeScene()
    local isExistLayerShuffling = g_mainScene:getChildByName('LayerShuffling')
    if isExistLayerShuffling then
        isExistLayerShuffling:removeSelf()
    end
end

return LayerShuffling
