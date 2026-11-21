local VoiceUtil = class("VoiceUtil")

function VoiceUtil:playEffect(sound_path,a)

	-- if bm.isRecordingVoice == 1 then
	-- 	return
	-- end

	if sound_path == nil then
		return
	end

	-- dump(sound_path, "-----sound_path-----")

	if device.platform == "ios" then

		if isIosUseAppPlayEffect then
			
			local args = {}
			args["url"] = cc.FileUtils:getInstance():getWritablePath() ..  sound_path
			cct.getDateForApp("playEffect", args, "V")

		else
			cc.SimpleAudioEngine:getInstance():playEffect(sound_path, a)

		end
    	
    else
    	cc.SimpleAudioEngine:getInstance():playEffect(sound_path, a)

    end

	-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,a)
	
end

return VoiceUtil