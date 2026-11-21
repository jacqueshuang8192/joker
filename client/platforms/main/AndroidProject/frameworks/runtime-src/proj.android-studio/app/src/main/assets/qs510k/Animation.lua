
local Animation  = class("Animation")

local frameTime = 0.8

function Animation:checkAnimation( par )
    -- body
    local sp = par:getChildByName("shunanim")
    if sp then
        sp:stopAllActions()
        par:removeChildByName("shunanim")
    end
end
--春天效果
--par 父节点
function Animation:animSpring(par)
end

--报警动画
function Animation:Alarm()
    -- body
    local  layer = cc.Layer:create()
    layer:setAnchorPoint(cc.p(0,0))

    local light = display.newSprite("qs510k/images/Game/hall_ui/effects/baojing/alarm_back.png")
    if light then
        layer:setContentSize(light:getContentSize())
        layer:addChild(light)
        -- light:setVisible(false)
        light:setPosition(cc.p(0,25))
        local dl = cc.DelayTime:create(0.1)
        local sq = cc.Sequence:create(dl,cc.Show:create(),dl,cc.Hide:create())
        light:runAction(cc.RepeatForever:create(sq))
    end

    local sp = display.newSprite("qs510k/images/Game/hall_ui/effects/baojing/alarm_fore.png")
    if sp then
        layer:addChild(sp)
    end

    return layer
end


--火箭
--par 父节点
function Animation:animRocket(par)
end

--顺子动画
--par 父节点
--seat 位置
function Animation:animShun(par, playerType)
end

--顺对
--par 父节点
--seat 位置
function Animation:animDoubleLine(par)
end

--飞机
--par 父节点
--seat 位置
function Animation:animPlane(par)
end


--炸弹
--par 父节点
--seat 位置
function Animation:animBoom(par)
    -- body
    self:checkAnimation(par)

    local lay = display.newNode():addTo(par)
    lay:setName("shunanim")
    require("hall.GameCommon"):playEffectSound("qs510k/audio/new/CardType_Bomb.mp3")

    display.addSpriteFrames("qs510k/images/Game/hall_ui/effects/boom.plist", "qs510k/images/Game/hall_ui/effects/boom.png")

    local pos = {SCREEN_WIDTH/2,SCREEN_HEIGHT/2}


    local plane = display.newSprite("#boom0.png",pos[1], pos[2]):addTo(lay)
    -- plane:scale(0.5)
    if seat==1 then
        plane:setFlippedX(true)
    end
    local frames = display.newFrames("boom%d.png", 0, 0)
    local animation = display.newAnimation(frames, 0.3)
    local function complete(sender,table)
        par:removeChildByName("shunanim")
    end
    transition.playAnimationOnce(plane,animation,true,complete, 0.3)

    --光
    local light = display.newSprite("#boom4.png",pos[1], pos[2]):addTo(lay)
    local txt = display.newSprite("#boom0.png",pos[1], pos[2]):addTo(lay)
end
return Animation