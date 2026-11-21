
local VoiceRecordView = class("VoiceRecordView")

local recordPauseTimer
local canRecord
local recordWaitTime

local voiceCanClick = true

function VoiceRecordView:showView(x,y,o,img_path)

	local order = o or 500

	if SCENENOW["scene"] then

		voiceCanClick = true

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("VoiceRecordView")
        if s then
            s:removeSelf()
        end

        canRecord = true
        recordWaitTime = 0

		local button = ccui.Button:create()
	    button:setTouchEnabled(true)
	    button:setAnchorPoint(cc.p(0.5,0.5))
	    button:setSize(40.00, 57.00)
	    button:setPosition(x - 2, y - 10)

	    if img_path then
	    	button:loadTextures(img_path, nil, nil)
	    else
	    	button:loadTextures("hall/VoiceRecord/voice_bt.png", nil, nil)
		end

	    button:setName("VoiceRecordView")
	    button:setScale(1.2)

	    button:addTouchEventListener(
			function(sender,event)
	            --触摸开始
				if event == TOUCH_EVENT_BEGAN then
					if g_family_is_chat ~= true then
						viewMgr:showTip({text = "此联盟未开放！！"})
						return
					end
					if not voiceCanClick then
						dump(voiceCanClick, "-----voiceCanClick-----")
						require(CommonTips_filePath):showTips("提示", "", 3, "发送过于频繁，两秒后可以再发送~~")
						return
					end
					if self:getVoiceIsPlaying() > 0 then
						require(CommonTips_filePath):showTips("提示", "", 3, "正在播放语音，请稍后再录~~")
						return
					end
	            	sender:setScale(1.4)
	            	-- if canRecord == true and recordWaitTime == 0 then
	            		dump("触摸开始", "-----录音按钮-----")
	            		--暂停背景音乐
		            	audio.pauseMusic()
		            	-- ccexp.AudioEngine:stopAll()
		            	-- cc.SimpleAudioEngine:getInstance():pauseAllEffects()
		            	bm.isRecordingVoice = 1
		            	--呀呀发送录音
		            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), -1)
	            	-- end
	            end
	            --触摸取消
	            if event == TOUCH_EVENT_CANCELED then
	            	sender:setScale(1.2)
	            	-- if canRecord then
	            		dump("触摸取消", "-----录音按钮-----")
		            	--恢复背景音乐
		            	audio.resumeMusic()
		            	bm.isRecordingVoice = 0
		            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), -3)
		            	dump(voiceCanClick, "-----voiceCanClick-----")
		            	voiceCanClick = false
		            	bm.SchedulerPool:delayCall(function()
		                    voiceCanClick = true
		                end, 2)
		            -- 	--录音结束，设置不能录音
		            -- 	canRecord = false
		            -- 	--开始防狂按倒计时
		            -- 	recordWaitTime = 0
		            -- 	recordPauseTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
		            -- 		function()
		            -- 			recordWaitTime = recordWaitTime + 1
		            -- 			dump(recordWaitTime, "-----定时器计时-----")
		            -- 			if recordWaitTime == 2 then
		            -- 				canRecord = true
			           --  			recordWaitTime = 0
			           --  			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(recordPauseTimer)
			           --  			recordPauseTimer = nil
			           --  			dump(recordWaitTime, "-----定时器计时结束-----")
		            -- 			end
		            -- 		end, 
		            -- 	2, false)
	            	-- end
	            end

	            --触摸结束
	            if event == TOUCH_EVENT_ENDED then
	            	sender:setScale(1.2)
	            	-- if canRecord then
	            		dump("触摸结束", "-----录音按钮-----")
		            	--恢复背景音乐
		            	audio.resumeMusic()
		            	bm.isRecordingVoice = 0
		            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), -2)
		            	dump(voiceCanClick, "-----voiceCanClick-----")
		            	voiceCanClick = false
		            	bm.SchedulerPool:delayCall(function()
		                    voiceCanClick = true
		                end, 2)
		            -- 	--录音结束，设置不能录音
		            -- 	canRecord = false
		            -- 	--开始防狂按倒计时
		            -- 	recordWaitTime = 0
		            -- 	recordPauseTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
		            -- 		function()
		            -- 			recordWaitTime = recordWaitTime + 1
		            -- 			dump(recordWaitTime, "-----定时器计时-----")
		            -- 			if recordWaitTime == 2 then
		            -- 				canRecord = true
			           --  			recordWaitTime = 0
			           --  			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(recordPauseTimer)
			           --  			recordPauseTimer = nil
			           --  			dump(recordWaitTime, "-----定时器计时结束-----")
		            -- 			end
		            -- 		end, 
		            -- 	2, false)
	            	-- end
	            end
	        end
	    )

	    dump("添加按钮", "-----录音按钮-----")
	    if order == -1 then
	    	SCENENOW["scene"]:addChild(button)
	    else
	    	SCENENOW["scene"]:addChild(button,order)
	    end
	    return button
	end
end


function VoiceRecordView:addVoiceRecordEvent(button,o)

	local order = o or 500

	if SCENENOW["scene"] then

		voiceCanClick = true

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("VoiceRecordView")
        if s then
            s:removeSelf()
        end

        canRecord = true
        recordWaitTime = 0

        -- if tolua.type(button) ~= "ccui.Button" then
        -- 	return
        -- end

	    button:onTouch(
			function(event)
	            --触摸开始
				if event.name == "began" then
					if g_family_is_chat ~= true then
						viewMgr:showTip({text = "此联盟未开放！！"})
						return
					end
					if not voiceCanClick then
						dump(voiceCanClick, "-----voiceCanClick-----")
						local paras ={}
						paras.type = 1
						paras.title = "提示"
						paras.content = "发送过于频繁，两秒后可以再发送~~"
						require("hall.tips.CommonTips"):showTips(paras)
						return
					end

	            		dump("触摸开始", "-----录音按钮-----")
	            		--暂停背景音乐
		            	audio.pauseMusic()
		            	bm.isRecordingVoice = 1
		            	--呀呀发送录音
		            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), -1)
	            elseif event.name == "cancelled" then
	            		dump("触摸取消", "-----录音按钮-----")
		            	--恢复背景音乐
		            	audio.resumeMusic()
		            	bm.isRecordingVoice = 0
		            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), -3)
		            	dump(voiceCanClick, "-----voiceCanClick-----")
		            	voiceCanClick = false
		            	bm.SchedulerPool:delayCall(function()
		                    voiceCanClick = true
		                end, 2)
		            -- 	--录音结束，设置不能录音
		            -- 	canRecord = false
	            elseif event.name == "ended" then
	            		dump("触摸结束", "-----录音按钮-----")
		            	--恢复背景音乐
		            	audio.resumeMusic()
		            	bm.isRecordingVoice = 0
		            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), -2)
		            	dump(voiceCanClick, "-----voiceCanClick-----")
		            	voiceCanClick = false
		            	bm.SchedulerPool:delayCall(function()
		                    voiceCanClick = true
		                end, 2)
	            end
	        end)
	    print("添加按钮", "-----录音按钮-----")
	end
end

function VoiceRecordView:removeView()

	if SCENENOW["scene"] then

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("VoiceRecordView")
        if s then
            s:removeSelf()
        end

	end
	-- if recordPauseTimer ~= nil then
	-- 	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(recordPauseTimer)
	-- 	recordPauseTimer = nil
	-- end
end

function VoiceRecordView:getVoiceIsPlaying()
	local isPlaying = 0
	if device.platform == "ios" then
		local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "CocosCaller"

        local ok, ret  = luaoc.callStaticMethod(className,"getVoiceIsPlaying")
        if not ok then
            
        else
            isPlaying = ret
        end
	elseif device.platform == "android" then
		local args = {}
        local sigs = "()I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        local ok,ret  = luaj.callStaticMethod(className, "getVoiceIsPlaying", args, sigs)
        if not ok then
            
        else
            isPlaying = ret
        end
    end

    return isPlaying
end

return VoiceRecordView
