
local Animation  = class("Animation")

--报警动画
function Animation:Alarm()
    -- body
    local  layer = cc.Layer:create()
    layer:setAnchorPoint(cc.p(0,0))

    local light = display.newSprite("pengpengzp/res/other/baojing/alarm_back.png")
    if light then
        layer:setContentSize(light:getContentSize())
        layer:addChild(light)
        -- light:setVisible(false)
        light:setPosition(cc.p(0,25))
        local dl = cc.DelayTime:create(0.1)
        local sq = cc.Sequence:create(dl,cc.Show:create(),dl,cc.Hide:create())
        light:runAction(cc.RepeatForever:create(sq))
    end

    local sp = display.newSprite("pengpengzp/res/other/baojing/alarm_fore.png")
    if sp then
        layer:addChild(sp)
    end

    return layer
end

return Animation