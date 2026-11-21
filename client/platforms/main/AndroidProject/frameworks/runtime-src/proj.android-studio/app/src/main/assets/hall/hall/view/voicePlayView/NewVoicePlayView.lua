local NewVoicePlayView = class("NewVoicePlayView")
function NewVoicePlayView:showView(pos, time)
    if type(pos) ~= "table" then
        return
    end
    if time == nil or time == "" then
        time = 3
    end
    if SCENENOW["scene"] ~= nil then
        self:removeView()
        local s = nil
        if device.platform == "ios" then
            if isiOSVerify then
                s = cc.CSLoader:createNode("hall/view/voicePlayView/voicePlayViewLayer.csb")
            else
                s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/view/voicePlayView/voicePlayViewLayer.csb")
            end
        else
            s = cc.CSLoader:createNode("hall/view/voicePlayView/voicePlayViewLayer.csb")
        end
        s:setName("NewVoicePlayView")
        s:setAnchorPoint(-0.5, 0.5)
        s:setPosition(pos.x, pos.y)
        SCENENOW["scene"]:addChild(s)
        --暂停背景音乐
        audio.pauseMusic()
        --闪烁动画
        local voice_iv = s:getChildByName("voice_iv")
        voice_iv:setScale(1.4)
        local x = 0
        local speed = 0.2
        local nowtime = 0
        voice_iv:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.DelayTime:create(speed),
                    cc.CallFunc:create(
                        function()
                            if x == 0 then
                                voice_iv:loadTexture("hall/view/voicePlayView/image/hear_02.png")
                            elseif x == 1 then
                                voice_iv:loadTexture("hall/view/voicePlayView/image/hear_01.png")
                            end
                            x = x + 1
                            if x == 2 then
                                x = 0
                            end
                            nowtime = nowtime + speed
                            if nowtime >= tonumber(time) then
                                voice_iv:stopAllActions()
                                self:removeView()
                                --恢复背景音乐
                                audio.resumeMusic()
                            end
                        end
                    )
                )
            )
        )
    end
end

function NewVoicePlayView:removeView()
    local s = SCENENOW["scene"]:getChildByName("NewVoicePlayView")
    if s then
        s:removeSelf()
        --恢复背景音乐
        audio.resumeMusic()
    end
end

return NewVoicePlayView
