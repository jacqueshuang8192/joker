-- module(..., package.seeall)
MusicManager = class("MusicManager")
local soundManPath = "mhxl_majiang_new/res/voice/man/"

function MusicManager:ctor()

end

function MusicManager:initialize()
	math.randomseed(os.time())
end

function MusicManager:playEffect(sound_path)
	require("hall.GameCommon"):playEffectSound(sound_path, false)
end

--碰的声音
function MusicManager:playEffectPeng( sex )
	local random = math.random(3)
	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = soundManPath.."male_guiZhou_peng.mp3"
	else
		sound_path = "hall/majiangsound/common_woman/".."peng"..tostring(random)..".mp3"
	
	end
	self:playEffect(sound_path)
end

--杆的声音
function MusicManager:playEffectGang( sex ,huType)
	local str = ""
	if huType== 3 then
		str = "male_guiZhou_dianGang.mp3"
	elseif huType== 2 then
		str = "male_guiZhou_anGang.mp3"
	else
		str = "male_guiZhou_gang.mp3"
	end

	local random = math.random(3)
	local sound_path = ""
	if tonumber(sex) == 1 then --男
		sound_path = soundManPath..str
	else
		sound_path = "hall/majiangsound/common_woman/".."gang"..tostring(random)..".mp3"
	end
	--print("playEffectGang-------random---",random,"sound_path----",sound_path)
	self:playEffect(sound_path)
end

--胡的声音
function MusicManager:playEffectHu( sex ,soundType) -- 1hupai 2zimo 3menhu 4tiantin
	-- body
	if soundType == 0 then
		return 
	end

	local str = ""
	if soundType == 1 then
		str = "c_hupai.mp3"
	elseif soundType == 2 then
		str = "c_zimo.mp3"
	elseif soundType == 3 then
		str = "male_guiZhou_men.mp3"
	end 

	local random = math.random(3)
	local sound_path = ""
	if tonumber(sex) == 1 then --男
		sound_path = soundManPath..str
	else
		sound_path = "hall/majiangsound/common_woman/".."hu"..tostring(random)..".mp3"
	end
	
	self:playEffect(sound_path)
end

function MusicManager:playEffectCard( sex,card_value )
	-- body
	
	if card_value < 0 then
		card_value = card_value + 256
	end
	
	--只有筒和条 贵州麻将
	local value_path_dict = {
	[0x01] = "1wan.mp3",
	[0x02] = "2wan.mp3",
	[0x03] = "3wan.mp3",
	[0x04] = "4wan.mp3",
	[0x05] = "5wan.mp3",
	[0x06] = "6wan.mp3",
	[0x07] = "7wan.mp3",
	[0x08] = "8wan.mp3",
	[0x09] = "9wan.mp3",

	[0x11] = "1tong.mp3",
	[0x12] = "2tong.mp3",
	[0x13] = "3tong.mp3",
	[0x14] = "4tong.mp3",
	[0x15] = "5tong.mp3",
	[0x16] = "6tong.mp3",
	[0x17] = "7tong.mp3",
	[0x18] = "8tong.mp3",
	[0x19] = "9tong.mp3",

	[0x21] = "1suo.mp3",
	[0x22] = "2suo.mp3",
	[0x23] = "3suo.mp3",
	[0x24] = "4suo.mp3",
	[0x25] = "5suo.mp3",
	[0x26] = "6suo.mp3",
	[0x27] = "7suo.mp3",
	[0x28] = "8suo.mp3",
	[0x29] = "9suo.mp3",

--[[	[0x43] = "mjt4_7.mp3",--//白
	[0x41] = "mjt4_5.mp3",--//中
	[0x42] = "mjt4_6.mp3",--//发

	[49] = "mjt4_1.mp3",--//东
	[50] = "mjt4_2.mp3",--//南
	[51] = "mjt4_3.mp3",--//西
	[52] = "mjt4_4.mp3",--//北--]]
	}

	local sound_path = ""
	local p = value_path_dict[card_value] or ""

	if tonumber(sex) == 1 then --男
		sound_path = "mhxl_majiang_new/res/voice/man/male_guiZhou_".. p
	else
		sound_path = "hall/majiangsound/common_woman/".. p
	end

	self:playEffect(sound_path)
end

function MusicManager:get_bg_music_path()
	-- body
	local sound_path = "mhxl_majiang_new/res/voice/bgm.mp3"
	return sound_path
end

--冲锋鸡的声音
function MusicManager:playEffectChongFengJi( sex )
	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = "mhxl_majiang_new/res/voice/man/c_chongfengji.mp3"
	else
		sound_path = "hall/majiangsound/common_woman/".."c_chongfengji"..".mp3"
	end
	self:playEffect(sound_path)
end


function MusicManager:playEffectTianTing( sex )
	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = "mhxl_majiang_new/res/voice/man/c_tianting.mp3"
	else
		sound_path = "hall/majiangsound/common_woman/".."c_tianting"..".mp3"
	end
	self:playEffect(sound_path)
end

return MusicManager