
local voicePlayView = class("voicePlayView")

local userPosition_arr = {}

function voicePlayView:showView(uid, time)

    if uid == nil or uid == "" then
        return
    end

    if time == nil or time == "" then
        time = "3"
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

        s:setName("voicePlayView")
        s:setAnchorPoint(0, 1)

        if userPosition_arr[uid] then
            s:setPosition(userPosition_arr[uid].x, userPosition_arr[uid].y)
        elseif PLAYER_HEADS_TABLE[uid] then
            local node_head = PLAYER_HEADS_TABLE[uid]
            local pos = (node_head:getParent()):convertToWorldSpace(node_head:getPosition()) --这样写是为了贴近函数的原始用法
            s:setPosition(pos)
        end
        SCENENOW["scene"]:addChild(s)

        --暂停背景音乐
        audio.pauseMusic()

        --闪烁动画
        local voice_iv = s:getChildByName("voice_iv")
              voice_iv:setScale(1.4)
        local x = 0
        local speed = 0.2
        local nowtime = 0
        voice_iv:runAction(cc.RepeatForever:create(

            cc.Sequence:create(cc.DelayTime:create(speed),cc.CallFunc:create(function()

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

            end))

        ))


    end

end

--更新用户说话标志显示位置
function voicePlayView:updateUserPosition(uid, position)
    userPosition_arr[uid] = position
end

function voicePlayView:removeView()

	local s = SCENENOW["scene"]:getChildByName("voicePlayView")
    if s then
        s:removeSelf()

        --恢复背景音乐
        audio.resumeMusic()
    end

end

return voicePlayView