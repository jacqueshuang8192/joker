--此模块由@Levan维护
local LayerShuffling = class('LayerShuffling')

local Shuffle_card_scale = 1

function LayerShuffling:ctor(cardUint)
    if g_isWatch == 0 then
        return
    end
    local Card = require(TpackageName .. '.PokerCard')
    if LayerShuffling then
        self:removeScene()
    end
    local LayerShuffling =
        cc.CSLoader:createNode(TpackageName .. '/csb/LayerShuffling/LayerShuffling.csb'):addTo(SCENENOW.scene, 99)
    LayerShuffling:setName('LayerShuffling')
    Shuffle_card_scale = SCREEN_WIDTH / DESIGN_SCREEN_WIDTH
    local card_back_path, card_size = Card:getSingleCardBackPath()
    local standardSize = {width = 369, height = 554}
    card_back_path = TpackageName .. '/csb/LayerShuffling/card_back.png'
    card_size = standardSize
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
    self.stencil:drawPolygon(rectangle, params)
    self.clipper:setStencil(self.stencil)
    self.back = ccui.ImageView:create(card_back_path, 0)
    self.back:setScaleX(standardSize.width / card_size.width)
    self.back:setScaleY(standardSize.height / card_size.height)
    self.back:setAnchorPoint(cc.p(0.5, 0.5))
    self.back:setPosition(self.clipper:getContentSize().width / 2, self.clipper:getContentSize().height / 2)
    self.clipper:addChild(self.back)
    self.clipper:setScale(Shuffle_card_scale)

    self.front = Card:createSingleCard(cardUint)
    --@Levan 牌正面
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
            cc.rect(
            -1000,
            -1000,
            self.clipper:getContentSize().width + 2000,
            self.clipper:getContentSize().height + 2000
        )
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
            self.front:setPosition(
                cc.p(self.clipper:getContentSize().width / 2, self.clipper:getContentSize().height / 2)
            )
            self.back:setPosition(
                cc.p(-self.back:getContentSize().width / 2 - 10, self.clipper:getContentSize().height / 2)
            )
            self.stencil:setPosition(cc.p(0, 0))
            local GamePlaneOperator = require(TpackageName .. '.operator.GamePlaneOperator')
            GamePlaneOperator:turnCards()
            self.clipper:runAction(
                cc.Sequence:create(
                    cc.ScaleTo:create(0.2, Shuffle_card_scale + 0.2),
                    cc.ScaleTo:create(0.2, Shuffle_card_scale),
                    cc.DelayTime:create(0.5),
                    cc.CallFunc:create(
                        function()
                            self:removeScene() --@Levan n秒后自动移除
                            -- GamePlaneOperator:showControlButtons(5)
                            local Mychoice = {0, 0, 0}
                            SanGongSendHandle:sendMycards(Mychoice)
                        end
                    )
                )
            )
            eventDispatcher:removeEventListener(listener)
        else
            self.front:setPosition(
                cc.p(-self.front:getContentSize().width / 2 - 10, self.clipper:getContentSize().height / 2)
            )
            SCENENOW.scene:performWithDelay(
                function()
                    if not tolua.isnull(self.stencil) then
                        self.stencil:setPosition(stencilOriPos)
                    end
                end,
                0.21
            )
        end
    end
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.clipper)
end

function LayerShuffling:removeScene()
    local isExistLayerShuffling = SCENENOW.scene:getChildByName('LayerShuffling')
    if isExistLayerShuffling then
        isExistLayerShuffling:removeSelf()
    end
end

return LayerShuffling
