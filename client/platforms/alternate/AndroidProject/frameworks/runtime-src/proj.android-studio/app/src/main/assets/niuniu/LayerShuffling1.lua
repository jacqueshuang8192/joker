--此模块由@Levan维护

local LayerShuffling = class('LayerShuffling')

if APPLE_APP_VERSION == 1 then
    require(TpackageName .. '.DrawNodeEx')
end

-- local Shuffle_card_scale = 1.4
local Shuffle_card_scale = 1

function LayerShuffling:ctor(cardUint)
    local Card = require(TpackageName .. '.PokerCard')

    if LayerShuffling then
        self:removeScene()
    end

    local LayerShuffling =
    cc.CSLoader:createNode(TpackageName .. '/csb/LayerShuffling/LayerShuffling.csb'):addTo(NIUNIU_SCENE)
    -- LayerShuffling:setAnchorPoint(cc.p(0.5, 0.5))
    -- LayerShuffling:setPosition(LayerShuffling:getContentSize().width / 2 , LayerShuffling:getContentSize().height / 2 )
    LayerShuffling:setName('LayerShuffling')
    --   LayerShuffling:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
    Shuffle_card_scale = SCREEN_WIDTH / DESIGN_SCREEN_WIDTH
    local card_back_path, card_size = Card:getSingleCardBackPath()

    -- for k,v in pairs(LayerShuffling:getChildren()) do
    --     dump(v:getName())
    --     dump(v:isVisible())
    --     dump(v:getPosition())
    --     dump(v:getScale())
    --     dump(v:getContentSize())
    -- end

    -- local standardSize = {width =300 ,height =458}
    local standardSize = {width = 368, height = 552}
    card_back_path = TpackageName .. '/csb/LayerShuffling/card_back.png'
    card_size = standardSize
    self.poker_blank = LayerShuffling:getChildByName('poker_blank')
    self.poker_blank:loadTexture(card_back_path, 0)
    self.poker_blank:setSize(standardSize)
    --  dump(LayerShuffling:getName())
    -- dump(LayerShuffling:isVisible())
    -- dump(LayerShuffling:getPosition())
    -- dump(LayerShuffling:getScale())
    -- dump(LayerShuffling:getContentSize())
    self.poker_blank:setScale(Shuffle_card_scale)

    -- self.poker_blank:setScaleX(standardSize.width/card_size.width)
    -- self.poker_blank:setScaleY(standardSize.height/card_size.height)

    self.Updated = false

    self.s = cc.Director:getInstance():getWinSize()

    self.clipper = cc.ClippingNode:create()
    -- self.clipper:setContentSize(cc.size(410, 560))
    -- self.clipper:setContentSize(cc.size(300, 458))
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

    -- if  device.platform ~= "ios" then
    --     self.stencil:drawPolygon(rectangle)
    -- else
    --     self.stencil.drawPolygon(rectangle)
    -- end
    -- self.stencil = display.newPolygon(rectangle, params)

    -- self.stencil:drawPolygon(rectangle,cc.c4b(1, 1, 1, 1), 1, cc.c4b(1, 1, 1, 1))
    --self.stencil:drawRect(cc.p(0, 0),cc.p(self.clipper:getContentSize().width, self.clipper:getContentSize().height), white)

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

    -- self.back:setContentSize(cc.size(410, 560))

    self.back:setAnchorPoint(cc.p(0.5, 0.5))
    self.back:setPosition(self.clipper:getContentSize().width / 2, self.clipper:getContentSize().height / 2)
    self.clipper:addChild(self.back)

    -- if resource_path == nil or resource_path == "" then
    -- self.front = cc.Sprite:create(TpackageName .. "/images/pieces_card/card_back.png")
    -- else
    -- self.front = Card:new()
    -- self.front:setCard(cardUint)
    -- self.front:showFront()
    -- end
    self.clipper:setScale(Shuffle_card_scale)

    self.front = Card:createSingleCard(cardUint)
    --@Levan 牌正面
    -- self.front:setFlipX(true)
    self.front:setRotation(180)
    self.front:setAnchorPoint(cc.p(0.5, 0.5))
    self.front:setPosition(-self.front:getContentSize().width / 2 - 10, self.clipper:getContentSize().height / 2)
    self.clipper:addChild(self.front)

    -- self.front:setScale(Shuffle_card_scale)

    --@Levan 遮挡牌值左下角
    -- self.frontzhedang1=cc.LayerColor:create(cc.c4b(255, 255, 255, 255), 40, 280)
    -- self.frontzhedang1:setAnchorPoint(cc.p(0.5, 0.5))
    -- -- self.frontzhedang1:ignoreAnchorPointForPosition(false)
    -- self.front:addChild( self.frontzhedang1 )
    -- -- self.frontzhedang1:setPosition(50, 445) --(x表现为正比y轴,y表现为反比x轴)
    -- self.frontzhedang1:setPosition(10, 160)

    -- -- --@Levan 遮挡牌值右上角
    -- self.frontzhedang2=cc.LayerColor:create(cc.c4b(255, 255, 255, 255), 40, 280)
    -- self.frontzhedang2:setAnchorPoint(cc.p(0.5, 0.5))
    -- -- self.frontzhedang2:ignoreAnchorPointForPosition(false)
    -- self.front:addChild( self.frontzhedang2)
    -- -- self.frontzhedang2:setPosition(360, 115)  --(x表现为正比y轴,y表现为反比x轴)
    -- self.frontzhedang2:setPosition(240,155)

    --@Levan 产生过渡效果 欺骗视觉
    -- self.mask = cc.Sprite:create(TpackageName .. "/images/pieces_card/alpha_mask.png")
    -- self.mask:setAnchorPoint(cc.p(1, 0.5))
    -- -- self.mask:setPosition(-self.mask:getContentSize().width/2+190, self.clipper:getContentSize().height / 2)
    -- self.mask:setPosition(-self.mask:getContentSize().width/2+ 100, self.clipper:getContentSize().height / 2)
    -- self.mask:setScale(1.08)
    -- self.clipper:addChild(self.mask)

    --@Levan 发牌移动
    self.clipper:setVisible(true)

    self.poker_blank:setPosition(cc.p(self.s.width / 2, self.s.height / 2))
    self.poker_blank:setVisible(false)

    --[[
    local spawn_action =
        cc.Spawn:create(cc.MoveTo:create(0.5, cc.p(self.s.width / 2, self.s.height / 2)), cc.RotateBy:create(0.5, 450))

    local scaleBy = cc.ScaleBy:create(0.5, 1 + 0.3)
    self.poker_blank:runAction(
        cc.Sequence:create(
            spawn_action,
            scaleBy,
            cc.DelayTime:create(0.05),
            cc.CallFunc:create(
                function()
                    self.poker_blank:setVisible(false)
                    self.clipper:setVisible(true)
                end
            )
        )
    )
    --]]

    self._scrolling = false
    self._lastPoint = {}
    self:initEvent()

    -- bm.SchedulerPool:delayCall(function() self:removeScene() end, 8)    --@Levan n秒后自动移除

    -- dump(self.poker_blank:getContentSize())
    -- dump(LayerShuffling:getContentSize())
    -- dump(self.poker_blank:getScale())
    -- dump(LayerShuffling:getScale())
    -- dump(LayerShuffling:getScale())
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
            -- self.mask:setPositionX(self.mask:getPositionX()  + diff.x)
            self.front:setPositionX(self.front:getPositionX() + diff.x)
            -- NIUNIU_SCENE:performWithDelay(function()
            self.stencil:setPositionX(self.stencil:getPositionX() + diff.x / 2)
            -- end,0.1)
        end

        self._lastPoint = point
    end

    local function onTouchEnded(touch, event)
        if self._scrolling == false then
            return
        end

        self._scrolling = false

        if self.front:getPositionX() > 50 - self.front:getContentSize().width / 2 then
            self.front:runAction(cc.Sequence:create(cc.MoveTo:create(1, cc.p(self.clipper:getContentSize().width / 2, self.clipper:getContentSize().height / 2))))
            self.back:runAction(cc.Sequence:create(cc.MoveTo:create(1, cc.p(-self.back:getContentSize().width / 2 - 10, self.clipper:getContentSize().height / 2))))
            --@Levan 移动 裁剪模板
            ---------------------------------------------------------------------------------------------cca.moveTo
            --@Levan 移动 裁剪模板
            --self.stencil:runAction(cc.Sequence:create(cc.MoveTo:create(1,cc.p(0,0))))
            self.stencil:setPosition(cc.p(0, 0))
            -- local action = self.stencil:runAction(cc.MoveTo:create(1,cc.p(0,0)))
            -- self.stencil:runAction(cc.Sequence:create(action))
            -------------------------------------------------------------------------------------------

            -- self.mask:runAction(cc.Sequence:create(cc.FadeOut:create(1)))
            -- self.mask:runAction(cc.Sequence:create(cc.MoveTo:create(1,cc.p(404.3,self.mask:getPositionY()))))
            -- self.frontzhedang2:runAction(cc.Sequence:create( cc.DelayTime:create(0.5),cc.FadeOut:create(0.5)))
            -- self.frontzhedang1:runAction(cc.Sequence:create( cc.DelayTime:create(0.5),cc.FadeOut:create(0.5)))

            local GamePlaneOperator = require(TpackageName .. '.operator.GamePlaneOperator')
            GamePlaneOperator:turnCards()
            NiuNiuSendHandle:sendMycards({0, 0, 0})
            --self.clipper:runAction(
            --        cc.Sequence:create(
            --                cc.ScaleTo:create(0.5, Shuffle_card_scale + 0.2),
            --                cc.ScaleTo:create(0.5, Shuffle_card_scale),
            --                cc.DelayTime:create(1.5),
            --                cc.CallFunc:create(
            --                        function()
            --                            self:removeScene() --@Levan n秒后自动移除
            --                            -- GamePlaneOperator:showControlButtons(5)
            --                        end
            --                )
            --        )
            --)

            eventDispatcher:removeEventListener(listener)
        else
            -- --@Levan 放大 裁剪模板
            -- self.stencil:setScale(1.5)
            -- self.stencil:setPositionX(self.stencil:getPositionX() - diff.x / 2)
            -- self.stencil:setPositionX(stencilOriPos)
            ---------------------------------------------------------
            -- self.mask:runAction(cc.MoveTo:create(0.3,cc.p(-self.mask:getContentSize().width/2+100,self.mask:getPositionY())))
            self.front:runAction(
                    cc.MoveTo:create(
                            0.3,
                            cc.p(-self.front:getContentSize().width / 2 - 10, self.clipper:getContentSize().height / 2)
                    )
            )
            -- self.stencil:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(0, 0))))  --@Levan 实验

            -- self.clipper:setPositionX(self.clipper:getPositionX() + diff.x / 2)
            -- self.back:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(100, self.clipper:getContentSize().height / 2))))
            ---------------------------------------------------------
            NIUNIU_SCENE:performWithDelay(
                    function()
                        -- self.stencil:runAction(cc.MoveTo:create(0.1,stencilOriPos))
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
    local isExistLayerShuffling = NIUNIU_SCENE:getChildByName('LayerShuffling')
    if isExistLayerShuffling then
        isExistLayerShuffling:removeSelf()
    end
end

return LayerShuffling

--endregion
