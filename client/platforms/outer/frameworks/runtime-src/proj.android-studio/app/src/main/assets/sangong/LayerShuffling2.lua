--此模块由@Levan维护

local LayerShuffling = class("LayerShuffling")

if APPLE_APP_VERSION == 1 then
    require(TpackageName .. '.DrawNodeEx')
end

-- local Shuffle_card_scale = 1.4
local Shuffle_card_scale = 1

function LayerShuffling:ctor(cardUint)

    dump("LayerShuffling:ctor2")
    local LayerPath = TpackageName.."/csb/Layer.csb"
    local imgPath = TpackageName.."/csb/img"
    -- -- 0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x01,   --方块
    -- -- 0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x11,   --樱花
    -- -- 0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x21,   --红桃
    -- -- 0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x31,   --黑桃
    -- -- 0x40 -- 小王
    -- -- 0x50 -- 大王
    self._cardInfo = {
        ["_card"] = 0x1D,
        ["number"]=nil,
        ["huase"]=nil,
        ["centre"]=nil,
        ["color"]=nil,
        [1]={0},
        [2]={1,10},
        [3]={0,1,10},
        [4]={1,2,9,10},
        [5]={0,1,2,9,10},
        [6]={1,2,5,6,9,10},
        [7]={1,2,5,6,9,10,11},
        [8]={1,2,3,4,7,8,9,10},
        [9]={0,1,2,3,4,7,8,9,10},
        [10]={1,2,3,4,7,8,9,10,11,12}
    }
    --local size = SCENENOW["scene"]:getContentSize()
    local layer = cc.CSLoader:createNode(LayerPath):addTo(SCENENOW.scene)
    layer:setName("cuopai")
    layer:setAnchorPoint(0.5,0.5)
    layer:setScale(0.5)

    layer:setPosition(SCREEN_WIDTH/2,SCREEN_HEIGHT/2)
    local crad = layer:getChildByName("crad")
    local front_crad = crad:getChildByName("front")
    local back_crad = crad:getChildByName("back")
    local left=front_crad:getChildByName("left")
    local right=front_crad:getChildByName("right")
    local centre=front_crad:getChildByName("centre")
    self._cardInfo._card=cardUint
    if(self._cardInfo._card==nil) then
        layer:removeAllChildren();
        return;
    end
    dump(self._cardInfo,"self._cardInfo._card")
    self._cardInfo.number=self._cardInfo._card%16
    if math.floor(self._cardInfo._card/16)==0 then
        self._cardInfo.huase="diamonds"
        self._cardInfo.color="red"
    elseif math.floor(self._cardInfo._card/16)==1 then
        self._cardInfo.huase="clubs"
        self._cardInfo.color="black"
    elseif math.floor(self._cardInfo._card/16)==2 then
        self._cardInfo.huase="hearts"
        self._cardInfo.color="red"
    elseif math.floor(self._cardInfo._card/16)==3 then
        self._cardInfo.huase="spades"
        self._cardInfo.color="black"
    elseif math.floor(self._cardInfo._card/16)==4 then
        self._cardInfo.huase="small"
        self._cardInfo.color="black"
    elseif math.floor(self._cardInfo._card/16)==5 then
        self._cardInfo.huase="big"
        self._cardInfo.color="red"
    end
    dump(self._cardInfo,"huase")
    if self._cardInfo.number>10 then
        self._cardInfo.centre=self._cardInfo.huase.."_"..self._cardInfo.number
    elseif self._cardInfo.number == 0 then
        self._cardInfo.centre=self._cardInfo.huase.."_king"
    else
        self._cardInfo.centre=self._cardInfo[math.ceil(self._cardInfo.number)]
    end

    local cuoPaiSceneHasRemoved=false
    local endTime =SCENENOW.scene:getChildByName("Scene"):getChildByName("hall_plane"):getChildByName("stage_img"):getChildByName("stage_txt"):getString();
    local time=tonumber(string.sub(endTime,-2));
    dump(endTime,"endTime")
    local function mouseDownEvent(node)

        if node~=centre then
            node:setVisible(false);
            node:setScale(0.1);
            node:setOpacity(0);
            local number =node:getChildByName("number");
            local huase =node:getChildByName("huase");
            if self._cardInfo.number == 0 then
                node:setBackGroundImage(imgPath.."/"..self._cardInfo.color.."_king.png");
                number:setVisible(false);
                huase:setVisible(false);
            elseif self._cardInfo.number~=0 then
                number:loadTexture(imgPath.."/"..self._cardInfo.color.."_"..self._cardInfo.number..".png"):setVisible(true);
                huase:loadTexture(imgPath.."/"..self._cardInfo.huase..".png"):setVisible(true);
            end
        else
            if self._cardInfo.number>10 or self._cardInfo.number==0 then
                --启用九宫格设置
                --node:setBackGroundImageScale9Enabled (true);
                node:setBackGroundImage(imgPath.."/"..self._cardInfo.centre..".png");
            else
                for i = 1,self._cardInfo.number do
                    local huase=node:getChildByName("huase_"..self._cardInfo[self._cardInfo.number][i])
                    huase:setVisible(true);
                    --huase:setBackGroundImageScale9Enabled (true);
                    --切换sprite的图片
                    --huase:setSpriteFrame( cc.Sprite:create("2.png"):getSpriteFrame());
                    --切换imageView的图片
                    huase:loadTexture(imgPath.."/"..self._cardInfo.huase..".png");
                end
            end
        end
    end
    local function runCardAction(node)
        if node~=centre then
            node:setVisible(true);
            local ScaleBy = cc.ScaleBy:create(0.2,10);
            local FadeIn = cc.FadeIn:create(0.2);
            node:runAction(ScaleBy);
            node:runAction(FadeIn);
        end
    end
    local function onTouchBegin(event)
        event.target:setScale(1)
        mouseDownEvent(left);
        mouseDownEvent(right);
        mouseDownEvent(centre);
        self.orx=event.x;
        self.ory=event.y;
        return true
    end
    local function onTouchEnder(event)
        if cuoPaiSceneHasRemoved == true then
            return
        end
        cuoPaiSceneHasRemoved = true
        dump(event.."cuopai")
        back_crad:setVisible(false);
        runCardAction(left);
        runCardAction(right);
        local GamePlaneOperator = require(TpackageName .. '.operator.GamePlaneOperator')

        GamePlaneOperator:turnCards()
        --GamePlaneOperator:countFanAndShow()
        SanGongSendHandle:sendMycards({0, 0, 0})
        local scheduler = require("framework.scheduler")
        scheduler.performWithDelayGlobal(
            function()
                --self:turnCards()
                --self:countFanAndShow()
                layer:removeFromParent();
            end,1) -- 调用间隔
        --SanGongSendHandle:sendMycards({0, 0, 0})
        --self.clipper:runAction(
        --    cc.Sequence:create(
        --        cc.ScaleTo:create(0.5, Shuffle_card_scale + 0.2),
        --        cc.ScaleTo:create(0.5, Shuffle_card_scale),
        --        cc.DelayTime:create(1.5),
        --        cc.CallFunc:create(
        --            function()
        --                self:removeScene() --@Levan n秒后自动移除
        --                -- GamePlaneOperator:showControlButtons(5)
        --            end
        --        )
        --    )
        --)
    end
    back_crad:onTouch( function(event)
        if event.name == "began" then
            onTouchBegin(event);
            SCENENOW["scene"]:performWithDelay(
                    function()
                        onTouchEnder("触摸超时注销");
                    end,
                    time
            )
        elseif event.name == "moved" then
            local x,y=event.x,event.y;
            back_crad:setPosition(cc.p((y-self.ory)*2+event.target:getWidth()/2,(self.orx-x)*2+event.target:getHeight()/2))
            if math.abs((y-self.ory)*2)>(event.target:getWidth()+10)/2 then
                dump(math.abs((y-self.ory)*2)..":"..(event.target:getWidth()+10)/2)
                onTouchEnder("移动时注销");
            end
            if math.abs((self.orx-x)*2)>(event.target:getHeight()+10)/2 then
                dump(math.abs((self.orx-x)*2)..":"..(event.target:getHeight()+10)/2)
                onTouchEnder("移动时注销");
            end
        elseif event.name == "ended" then
            local x,y=event.target:getWidth()/2,event.target:getHeight()/2;
            back_crad:setPosition(cc.p(x,y));
            --onTouchEnder("触摸结束时注销");
        end
    end)
    SCENENOW["scene"]:performWithDelay(
            function()
                if cuoPaiSceneHasRemoved == true then
                    return
                end
                cuoPaiSceneHasRemoved = true
                layer:removeFromParent();
            end,
            time
    )
end

function LayerShuffling:shader()
end

function LayerShuffling:initEvent()
end

function LayerShuffling:removeScene()

    local isExistLayerShuffling = SCENENOW["scene"]:getChildByName("LayerShuffling")
    if isExistLayerShuffling then
        isExistLayerShuffling:removeSelf()
    end
end

return LayerShuffling

--endregion
