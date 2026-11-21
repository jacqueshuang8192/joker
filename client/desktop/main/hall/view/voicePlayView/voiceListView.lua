local voiceListView = class("voiceListView")

local voicePlayView = require("hall.view.voicePlayView.voicePlayView")
-- local LIST_MAX_LEN = 30 --最多保存消息数量
local voice_msg_list = {}
local voice_played_list = {}
local playingIndex = -1
local NEW_MSG = 1
local OLD_MSG = 2
local playingType = 1

function voiceListView:clearList()
	voice_played_list = {}
end

function voiceListView:getList()
	return voice_played_list
end

function voiceListView:addVoiceMsg(url, uid, voiceTime)
	
	if 	url == nil or uid == nil then
		print("url或uid不存在")
		return
	end

	if 	url == "" or uid <= 0 then
		print("url或uid为非法值")
		return 
	end

	if 	voiceTime == nil or voiceTime == "" then
		voiceTime = 60
	end

	print("addVoiceMsg :: url == "..url..", uid == "..uid..", voiceTime == "..voiceTime)

	local item = {}
	item.url = url
	item.uid = uid
	item.time = voiceTime

	voice_msg_list[#voice_msg_list + 1] = item

	self:playNextVoice()
end

--播放下一条新消息
function voiceListView:playNextVoice()
	if #voice_msg_list > 0 then
		local isPlaying = self:getVoiceIsPlaying()
		local isRecording = self:getVoiceIsRecording()
		if isPlaying == 1 or isRecording == 1 then
			return
		end

		local first_item = voice_msg_list[1]
		self:playVoice(first_item.url, first_item.uid, 1, NEW_MSG)
	end
end

function voiceListView:playRecoredVoice(url, uid, index, type)

	local isPlaying = self:getVoiceIsPlaying()
	local isRecording = self:getVoiceIsRecording()
	if isPlaying == 1 or isRecording == 1 then
		return
	end

    self:playVoice(url, uid, index, type)
    
end

function voiceListView:playVoice(url, uid, index, type)
	if device.platform == "ios" then
		--通知本地播放录音
		local arr = {}
		arr["url"] = url
		arr["uid"] = uid
		cct.getDateForApp("playVoice", arr, "V")
	else
		--通知本地播放录音
		local data = {}
		data["url"] = url
		data["uid"] = uid

		local arr = {}
		table.insert(arr, json.encode(data))
		cct.getDateForApp("playVoice", arr, "V")
	end

	playingType = type
	playingIndex = index
    
    local voiceTime = voiceTime or 60
	voicePlayView:showView(uid, voiceTime)
end

-- function voiceListView:startPlayCallFunc(uid, time, index)
-- 	voicePlayView:showView(uid, time)
-- end

function voiceListView:finishPlayCallFunc()

	voicePlayView:removeView()

	print("finishPlayCallFunc :: playingType == "..playingType..", playingIndex == "..playingIndex)

	if playingType == NEW_MSG then
		if #voice_msg_list > 0 then
			voice_played_list[#voice_played_list + 1] = voice_msg_list[1]
			table.remove(voice_msg_list, 1)
			dump(voice_msg_list, "voice_msg_list")

			dump(voice_played_list, "voice_played_list")
		else
			print("finishPlayCallFunc error !!! voice_msg_list len == 0 !")
		end
	end

	self:playNextVoice()

end

function voiceListView:getVoiceIsRecording()
	local isRecording = 0
	if device.platform == "ios" then
		local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "CocosCaller"

        local ok, ret  = luaoc.callStaticMethod(className,"getVoiceIsRecording")
        if not ok then
            
        else
            isRecording = ret
        end
	elseif device.platform == "android" then
		local args = {}
        local sigs = "()I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        local ok,ret  = luaj.callStaticMethod(className, "getVoiceIsRecording", args, sigs)
        if not ok then
            
        else
            isRecording = ret
        end
    end

    return isRecording
end

function voiceListView:getVoiceIsPlaying()
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

return voiceListView