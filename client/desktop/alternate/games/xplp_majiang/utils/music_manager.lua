-- module(..., package.seeall)
MusicManager = class("MusicManager")

function MusicManager:ctor()

end

function MusicManager:initialize()
	math.randomseed(os.time())
end

function MusicManager:playEffect(sound_path)
	--cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
	require("hall.GameCommon"):playEffectSound(sound_path, false)
end

--碰的声音
function MusicManager:playEffectPeng( sex )
	-- body

	
	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = "xplp_majiang/res/voice/boy/PENG.mp3"
		
	else
		sound_path = "xplp_majiang/res/voice/girl/PENG.mp3"
	
	end
	self:playEffect(sound_path)
end

function MusicManager:playEffectChi(sex)
	local sound_path = ""
		if tonumber(sex) == 1 then
		sound_path = "xplp_majiang/res/voice/boy/CHI.mp3"
		
	else
		sound_path = "xplp_majiang/res/voice/girl/CHI.mp3"
	
	end
	self:playEffect(sound_path)
end

--杆的声音
function MusicManager:playEffectGang( sex )
	-- body

	local random = math.random(3)
	local sound_path = ""
	if tonumber(sex) == 1 then --男
		sound_path = "hall/majiangsound/common_man/".."gang"..tostring(random)..".mp3"

	else
		sound_path = "hall/majiangsound/common_woman/".."gang"..tostring(random)..".mp3"

	end
	--print("playEffectGang-------random---",random,"sound_path----",sound_path)
	self:playEffect(sound_path)
end

--胡的声音
function MusicManager:playEffectHu( sex )
	-- body

	
	local sound_path = ""
	if tonumber(sex) == 1 then --男
		sound_path = "xplp_majiang/res/voice/girl/xplp_hu.mp3"

	else
		sound_path = "xplp_majiang/res/voice/girl/xplp_hu.mp3"
	end
	
	self:playEffect(sound_path)
end

function MusicManager:playEffectZm( sex )
	-- body

	
	local sound_path = ""
	if tonumber(sex) == 1 then --男
		sound_path = "xplp_majiang/res/voice/girl/ZIMO.mp3"

	else
		sound_path = "xplp_majiang/res/voice/girl/ZIMO.mp3"
	end
	
	self:playEffect(sound_path)
end

function MusicManager:playEffectChong(sex,chongTyp)
	local sound_path=""
	if tonumber(sex==1) then
		if chongTyp==0 then
			sound_path = "xplp_majiang/res/voice/boy/jia_ma_0.mp3"
		elseif chongTyp ==1 then
			sound_path = "xplp_majiang/res/voice/boy/jia_ma_1.mp3"
		elseif chongTyp ==2 then
			sound_path = "xplp_majiang/res/voice/boy/jia_ma_2.mp3"
		else  
			sound_path = "xplp_majiang/res/voice/boy/jia_ma_3.mp3"
		end
	else
		if chongTyp==0 then
			sound_path = "xplp_majiang/res/voice/girl/jia_ma_0.mp3"
		elseif chongTyp ==1 then
			sound_path = "xplp_majiang/res/voice/girl/jia_ma_1.mp3"
		elseif chongTyp ==2 then
			sound_path = "xplp_majiang/res/voice/girl/jia_ma_2.mp3"
		else  
			sound_path = "xplp_majiang/res/voice/girl/jia_ma_3.mp3"
		end
	end
	self:playEffect(sound_path)
end

function MusicManager:playEffectCard( sex,card_value )
	-- body
	
	if card_value < 0 then
		card_value = card_value + 256
	end
	
	local value_path_dict = {
	[0x01] = "0_1",
	[0x02] = "0_2",
	[0x03] = "0_3",
	[0x04] = "0_4",
	[0x05] = "0_5",
	[0x06] = "0_6",
	[0x07] = "0_7",
	[0x08] = "0_8",
	[0x09] = "0_9",

	[0x11] = "1_1",
	[0x12] = "1_2",
	[0x13] = "1_3",
	[0x14] = "1_4",
	[0x15] = "1_5",
	[0x16] = "1_6",
	[0x17] = "1_7",
	[0x18] = "1_8",
	[0x19] = "1_9",

	[0x21] = "2_1",
	[0x22] = "2_2",
	[0x23] = "2_3",
	[0x24] = "2_4",
	[0x25] = "2_5",
	[0x26] = "2_6",
	[0x27] = "2_7",
	[0x28] = "2_8",
	[0x29] = "2_9",

	[0x31] = "3_3",--林冲
	[0x32] = "3_2",--州公
	[0x33] = "3_1",--万千
	[0x41] = "4_1",--红中
	}

	local sound_path = ""
	local p = value_path_dict[card_value] or ""

	if tonumber(sex) == 1 then --男
		sound_path = "xplp_majiang/res/voice/boy/".. p..".mp3"
	else
		sound_path = "xplp_majiang/res/voice/girl/".. p..".mp3"
	end

	self:playEffect(sound_path)
end

function MusicManager:get_bg_music_path()
	-- body
	local sound_path = "hall/majiangsound/bg.mp3"
	return sound_path
end

return MusicManager