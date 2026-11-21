
--此模块由@Levan维护

local LayerShuffling = class("LayerShuffling")

if  APPLE_APP_VERSION == 1 then
    require(TpackageName .. ".DrawNodeEx")
end

local Shuffle_card_scale = 1.4

function LayerShuffling:ctor(cardUint)
    
    local Card = require(TpackageName .. ".PokerCard")

    if  LayerShuffling then
        self:removeScene()
    end

    local LayerShuffling=cc.CSLoader:createNode(TpackageName .. "/csb/LayerShuffling.csb"):addTo(SCENENOW["scene"])
          LayerShuffling:setName("LayerShuffling")
          -- LayerShuffling:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)

    local card_back_path,card_size = Card:getSingleCardBackPath()

    local standardSize = {width =300 ,height =458} 

    self.poker_blank = LayerShuffling:getChildByName("poker_blank")
    self.poker_blank:loadTexture(card_back_path)
    self.poker_blank:setSize(standardSize)

    -- self.poker_blank:setScaleX(standardSize.width/card_size.width)
    -- self.poker_blank:setScaleY(standardSize.height/card_size.height)

    self.Updated=false
    
    self.s=cc.Director:getInstance():getWinSize()

    self.clipper = cc.ClippingNode:create()
	-- self.clipper:setContentSize(cc.size(410, 560))
    self.clipper:setContentSize(cc.size(300, 558))

	self.clipper:setAnchorPoint(cc.p(0.5, 0.5))
	self.clipper:setPosition(self.s.width / 2 , self.s.height / 2 +80)
    self.clipper:setRotation(-90)
    
	LayerShuffling:addChild(self.clipper)

    self.stencil =cc.DrawNode:create()

    local rectangle = {cc.p(0, 0),cc.p(400, 0),cc.p(400, 458+100),cc.p(0, 458+100)}             

    local params = {fillColor = cc.c4f(1,1,1,1),borderWidth  = 1,borderColor  = cc.c4f(0,0,0,1)}
    local fillColor = cc.c4f(1,1,1,1)
    local borderWidth  = 1
    local borderColor  = cc.c4f(0,0,0,1)

    -- if  device.platform ~= "ios" then
    --     self.stencil:drawPolygon(rectangle)
    -- else
    --     self.stencil.drawPolygon(rectangle)
    -- end
        -- self.stencil = display.newPolygon(rectangle, params)

    -- self.stencil:drawPolygon(rectangle,cc.c4b(1, 1, 1, 1), 1, cc.c4b(1, 1, 1, 1))
    --self.stencil:drawRect(cc.p(0, 0),cc.p(self.clipper:getContentSize().width, self.clipper:getContentSize().height), white)

    if  APPLE_APP_VERSION == 1 then
        if  device.platform == "android" then
            self.stencil:drawPolygon(rectangle,params)
        else
            self.stencil:drawPolygon(rectangle, #rectangle, fillColor, borderWidth, borderColor)
        end
    else
        self.stencil:drawPolygon(rectangle,params)
    end
    
	self.clipper:setStencil(self.stencil)

    self.back = ccui.ImageView:create(card_back_path)
    
    self.back:setScaleX(standardSize.width/card_size.width)
    self.back:setScaleY(standardSize.height/card_size.height)

    -- self.back = Card:createSingleCardBack()

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
	self.front:setPosition(-self.front:getContentSize().width / 2-10, self.clipper:getContentSize().height / 2)
	self.clipper:addChild(self.front)


    --@Levan 遮挡牌值左下角
    self.frontzhedang1=cc.LayerColor:create(cc.c4b(255, 255, 255, 255), 40, 280)
    self.frontzhedang1:setAnchorPoint(cc.p(0.5, 0.5))
    -- self.frontzhedang1:ignoreAnchorPointForPosition(false)
    self.front:addChild( self.frontzhedang1 )
    -- self.frontzhedang1:setPosition(50, 445) --(x表现为正比y轴,y表现为反比x轴)
    self.frontzhedang1:setPosition(10, 160)

    -- --@Levan 遮挡牌值右上角
    self.frontzhedang2=cc.LayerColor:create(cc.c4b(255, 255, 255, 255), 40, 280)
    self.frontzhedang2:setAnchorPoint(cc.p(0.5, 0.5))
    -- self.frontzhedang2:ignoreAnchorPointForPosition(false)
    self.front:addChild( self.frontzhedang2)
    -- self.frontzhedang2:setPosition(360, 115)  --(x表现为正比y轴,y表现为反比x轴)
    self.frontzhedang2:setPosition(240,155) 

    --@Levan 产生过渡效果 欺骗视觉
	self.mask = cc.Sprite:create(TpackageName .. "/images/pieces_card/alpha_mask.png")
	self.mask:setAnchorPoint(cc.p(1, 0.5))
    -- self.mask:setPosition(-self.mask:getContentSize().width/2+190, self.clipper:getContentSize().height / 2)
    self.mask:setPosition(-self.mask:getContentSize().width/2+ 100, self.clipper:getContentSize().height / 2)
    self.mask:setScale(1.08)
    self.mask:setVisible(false)
	self.clipper:addChild(self.mask)

    --@Levan 发牌移动
    self.clipper:setVisible(false) 
    local spawn_action = cc.Spawn:create(cc.MoveTo:create(0.5, cc.p(self.s.width / 2 ,self.s.height / 2)),cc.RotateBy:create(0.5,450))
    local scaleBy = cc.ScaleBy:create(0.5, Shuffle_card_scale + 0.3)
    self.poker_blank:runAction(cc.Sequence:create(spawn_action,scaleBy,cc.DelayTime:create(0.05), cc.CallFunc:create(function()
        self.poker_blank:setVisible(false)
        self.clipper:setVisible(true)
    end)))

    self._scrolling=false
    self._lastPoint={}
    self:initEvent()


    bm.SchedulerPool:delayCall(function() self:removeScene() end,8)    --@Levan n秒后自动移除
end


function LayerShuffling:shader()

-- Shader "Custom/mymat" {
-- Properties {
-- _Color ("Color", Color) = (1,1,1,1)
-- _MainTex ("Albedo (RGB)", 2D) = "white" {}
-- _Glossiness ("Smoothness", Range(0,1)) = 0.5
-- _Metallic ("Metallic", Range(0,1)) = 0.0
-- _MyDis("Dis",Range(0,20)) =0
-- }
-- SubShader {
-- Tags { "RenderType"="Opaque" }
-- LOD 200
-- cull off
-- CGPROGRAM
-- // Physically based Standard lighting model, and enable shadows on all light types
-- #pragma surface surf Standard fullforwardshadows vertex:vert

-- // Use shader model 3.0 target, to get nicer looking lighting
-- #pragma target 3.0

-- sampler2D _MainTex;

-- struct Input {
-- float2 uv_MainTex;
-- };

-- half _Glossiness;
-- half _Metallic;
-- float _MyDis;
-- fixed4 _Color;

-- void vert(inout appdata_full v) {
-- half x = v.vertex.x;
-- half y = v.vertex.y;
-- half z = v.vertex.z;
-- half3 p0 = half3(0, 0, z);
-- half3 p1 = half3(7.5, 0, z);
-- half3 p2 = half3(5-_MyDis*0.2, 0+ _MyDis*0.5, z);
-- if (v.vertex.x > 0) {
-- half t = (v.vertex.x) / 10;
-- t = clamp(t, 0, 1);
-- half3 end = (1 - t)*(1 - t)*p0 + 2 * t*(1 - t)*p1 + t*t*p2;
-- v.vertex = half4(end, 0);// mul(mt, v.vertex);
-- }
-- }
-- void surf (Input IN, inout SurfaceOutputStandard o) {
-- // Albedo comes from a texture tinted by color
-- fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
-- o.Albedo = c.rgb;
-- // Metallic and smoothness come from slider variables
-- o.Metallic = _Metallic;
-- o.Smoothness = _Glossiness;
-- o.Alpha = c.a;
-- }
-- ENDCG
-- }
-- FallBack "Diffuse"
-- }
-- /*

-- half4x4 mt = {
-- 1,0,0,end.x,
-- 0,1,0,end.y,
-- 0,0,1,end.z,
-- 0,0,0,1
-- };
-- */

end


function LayerShuffling:initEvent()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    local listener = cc.EventListenerTouchOneByOne:create()
    local diff
    local stencilOriPos = self.stencil:getPosition()

    local function onTouchBegan(touch, event)

        if  self.clipper:isVisible()==false then
            return
        end

        local point = self.clipper:convertToNodeSpace(cc.Director:getInstance():convertToGL(touch:getLocationInView()))
	    local rect = cc.rect(-200, -100, self.clipper:getContentSize().width+100, self.clipper:getContentSize().height+200)

	    self._scrolling = cc.rectContainsPoint(rect,point)
	    self._lastPoint = point

        if  self._scrolling then
            return true
        end
       
        return false
    end

    local function onTouchMoved(touch, event)
        
	    local point ={}
        point = self.clipper:convertToNodeSpace(cc.Director:getInstance():convertToGL(touch:getLocationInView()))
	    diff =cc.p(point.x - self._lastPoint.x,point.y - self._lastPoint.y)

	    local startfrontposx = -self.front:getContentSize().width / 2-10 
	    local endfrontposx = -self.front:getContentSize().width / 2  + self.clipper:getContentSize().width

	    if  self.front:getPositionX() + diff.x < startfrontposx or self.front:getPositionX() + diff.x > endfrontposx then             
	    
        else
		    self.front:setPositionX(self.front:getPositionX() + diff.x)
            -- SCENENOW["scene"]:performWithDelay(function() 
		      self.stencil:setPositionX(self.stencil:getPositionX() + diff.x / 2)
            -- end,0.1)
            dump("滑动牌")
		    self.mask:setPositionX(self.mask:getPositionX()  + diff.x)
	    end
	
	    self._lastPoint = point

    end

    local function onTouchEnded(touch, event)

        if  self._scrolling==false then
            return
        end

	    self._scrolling = false

        if  self.front:getPositionX()> self.clipper:getContentSize().width/2-50 then
            self.front:runAction(cc.Sequence:create(cc.MoveTo:create(1, cc.p(self.clipper:getContentSize().width/2, self.clipper:getContentSize().height / 2))))
	        self.back:runAction(cc.Sequence:create(cc.MoveTo:create(1, cc.p(-self.back:getContentSize().width / 2 - 10, self.clipper:getContentSize().height / 2))))
	        --@Levan 移动 裁剪模板
            dump(self.stencil,"self.stencil 是多少?")
---------------------------------------------------------------------------------------------cca.moveTo
             --@Levan 移动 裁剪模板
            --self.stencil:runAction(cc.Sequence:create(cc.MoveTo:create(1,cc.p(0,0))))
            self.stencil:setPosition(cc.p(0,0) )
            -- local action = self.stencil:runAction(cc.MoveTo:create(1,cc.p(0,0)))
            -- self.stencil:runAction(cc.Sequence:create(action))
-------------------------------------------------------------------------------------------
            dump(self.stencil,"self.stencil 之后是多少?")

	        self.mask:runAction(cc.Sequence:create(cc.FadeOut:create(1)))
            self.mask:runAction(cc.Sequence:create(cc.MoveTo:create(1,cc.p(404.3,self.mask:getPositionY()))))
            self.frontzhedang2:runAction(cc.Sequence:create( cc.DelayTime:create(0.5),cc.FadeOut:create(0.5)))
            self.frontzhedang1:runAction(cc.Sequence:create( cc.DelayTime:create(0.5),cc.FadeOut:create(0.5)))
            
            require(TpackageName .. ".operator.GamePlaneOperator"):turnCards()

	        self.clipper:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,Shuffle_card_scale + 0.2), cc.ScaleTo:create(0.5,Shuffle_card_scale),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                 self:removeScene()    --@Levan n秒后自动移除
                 -- NiuNiuSendHandle:sendMycards({0,0,0})
            end)))

            eventDispatcher:removeEventListener(listener)
        else

            self.front:runAction(cc.MoveTo:create(0.3, cc.p(-self.front:getContentSize().width / 2-10, self.clipper:getContentSize().height / 2)))
	        -- self.stencil:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(0, 0))))  --@Levan 实验

            -- self.clipper:setPositionX(self.clipper:getPositionX() + diff.x / 2)
            -- self.back:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(100, self.clipper:getContentSize().height / 2))))
            dump(self.stencil:getPosition(),"self.stencil 是多少?22222")
---------------------------------------------------------
            SCENENOW["scene"]:performWithDelay(function() 
                -- self.stencil:runAction(cc.MoveTo:create(0.1,stencilOriPos))
                if  not tolua.isnull(self.stencil) then
                    self.stencil:setPosition(stencilOriPos)
                end
            end,0.21)

            dump("滑动结束")
            -- --@Levan 放大 裁剪模板
            -- self.stencil:setScale(1.5)
            -- self.stencil:setPositionX(self.stencil:getPositionX() - diff.x / 2)
            -- self.stencil:setPositionX(stencilOriPos)
---------------------------------------------------------
            self.mask:runAction(cc.MoveTo:create(0.3,cc.p(-self.mask:getContentSize().width/2+100,self.mask:getPositionY())))    
        end
	    
    end

    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.clipper)

end

function LayerShuffling:removeScene()

    local isExistLayerShuffling = SCENENOW["scene"]:getChildByName("LayerShuffling")
    if isExistLayerShuffling then
        isExistLayerShuffling:removeSelf()
    end
end

return LayerShuffling

--endregion
