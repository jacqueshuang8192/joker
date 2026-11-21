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
		sound_path = TpackageName.."/res/voice/boy/operation/peng.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/peng.mp3"
	
	end
	self:playEffect(sound_path)
end

function MusicManager:playEffectChi( sex )

	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = TpackageName.."/res/voice/boy/operation/chi.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/chi.mp3"
	
	end
	self:playEffect(sound_path)
end
--普通杠的声音
function MusicManager:playEffectGang( sex )
	-- body

	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = TpackageName.."/res/voice/boy/operation/gang.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/gang.mp3"
	
	end
	--print("playEffectGang-------random---",random,"sound_path----",sound_path)
	self:playEffect(sound_path)
end

--暗杠
function MusicManager:playEffectAnGang( sex )
	-- body

	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = TpackageName.."/res/voice/boy/operation/angang.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/angang.mp3"
	
	end
	--print("playEffectGang-------random---",random,"sound_path----",sound_path)
	self:playEffect(sound_path)
end

--普通胡的声音
function MusicManager:playEffectHu( sex )
	-- body

	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = TpackageName.."/res/voice/boy/operation/hu.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/hu.mp3"
	
	end
	
	self:playEffect(sound_path)
end

--zimo
function MusicManager:playEffectZiMo( sex )
	-- body

	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = TpackageName.."/res/voice/boy/operation/zimo.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/zimo.mp3"
	
	end
	
	self:playEffect(sound_path)
end

--zimo
function MusicManager:playEffectGangKai( sex )
	-- body

	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = TpackageName.."/res/voice/boy/operation/gangkai.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/gangkai.mp3"
	
	end
	
	self:playEffect(sound_path)
end

--门清自摸
function MusicManager:playEffectMenQingZiMo( sex )
	-- body
	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = TpackageName.."/res/voice/boy/operation/menqingzimo.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/menqingzimo.mp3"
	
	end
	
	self:playEffect(sound_path)
end

function MusicManager:playEffectQingYiSeZiMo( sex,flag )
	-- body

	local sound_path = ""
	if flag then
	if tonumber(sex) == 1 then
		sound_path = TpackageName.."/res/voice/boy/operation/qingyisezimo.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/qingyisezimo.mp3"
	
	end
else
			if tonumber(sex) == 1 then
			sound_path = TpackageName.."/res/voice/boy/operation/qingyise.mp3"
			
		else
			sound_path = TpackageName.."/res/voice/girl/operation/qingyise.mp3"
		
		end
	end
	
	self:playEffect(sound_path)
end

function MusicManager:playEffectQiXiaoDuiZiMo( sex,flag )
	-- body

	local sound_path = ""
	if flag then
	if tonumber(sex) == 1 then
		sound_path = TpackageName.."/res/voice/boy/operation/qixiaoduizimo.mp3"
		
	else
		sound_path = TpackageName.."/res/voice/girl/operation/qixiaoduizimo.mp3"
	
	end
	else
		if tonumber(sex) == 1 then
			sound_path = TpackageName.."/res/voice/boy/operation/qixiaodui.mp3"
			
		else
			sound_path = TpackageName.."/res/voice/girl/operation/qixiaodui.mp3"
		
		end
	end
	
	self:playEffect(sound_path)
end

function MusicManager:playEffectQuanQiuRenZiMo( sex,flag )
	-- body

	local sound_path = ""
	if flag then
		if tonumber(sex) == 1 then
			sound_path = TpackageName.."/res/voice/boy/operation/quanqiurenzimo.mp3"
			
		else
			sound_path = TpackageName.."/res/voice/girl/operation/quanqiurenzimo.mp3"
		
		end
	else
		if tonumber(sex) == 1 then
			sound_path = TpackageName.."/res/voice/boy/operation/quanqiuren.mp3"
			
		else
			sound_path = TpackageName.."/res/voice/girl/operation/quanqiuren.mp3"
		
		end
	end
	self:playEffect(sound_path)
end

function MusicManager:playEffectPengPengHuZiMo( sex ,flag)
	-- body

	local sound_path = ""
	if flag then
		if tonumber(sex) == 1 then
			sound_path = TpackageName.."/res/voice/boy/operation/pengpenghuzimo.mp3"
			
		else
			sound_path = TpackageName.."/res/voice/girl/operation/pengpenghuzimo.mp3"
		
		end
	else
			if tonumber(sex) == 1 then
			sound_path = TpackageName.."/res/voice/boy/operation/pengpenghu.mp3"
			
		else
			sound_path = TpackageName.."/res/voice/girl/operation/pengpenghu.mp3"
		
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
	[0x01] = "mjt1_1.mp3",
	[0x02] = "mjt1_2.mp3",
	[0x03] = "mjt1_3.mp3",
	[0x04] = "mjt1_4.mp3",
	[0x05] = "mjt1_5.mp3",
	[0x06] = "mjt1_6.mp3",
	[0x07] = "mjt1_7.mp3",
	[0x08] = "mjt1_8.mp3",
	[0x09] = "mjt1_9.mp3",

	[0x11] = "mjt2_1.mp3",
	[0x12] = "mjt2_2.mp3",
	[0x13] = "mjt2_3.mp3",
	[0x14] = "mjt2_4.mp3",
	[0x15] = "mjt2_5.mp3",
	[0x16] = "mjt2_6.mp3",
	[0x17] = "mjt2_7.mp3",
	[0x18] = "mjt2_8.mp3",
	[0x19] = "mjt2_9.mp3",

	[0x21] = "mjt3_1.mp3",
	[0x22] = "mjt3_2.mp3",
	[0x23] = "mjt3_3.mp3",
	[0x24] = "mjt3_4.mp3",
	[0x25] = "mjt3_5.mp3",
	[0x26] = "mjt3_6.mp3",
	[0x27] = "mjt3_7.mp3",
	[0x28] = "mjt3_8.mp3",
	[0x29] = "mjt3_9.mp3",

	[0x43] = "mjt4_7.mp3",--//白
	[0x41] = "mjt4_5.mp3",--//中
	[0x42] = "mjt4_6.mp3",--//发

	[0x31] = "mjt4_1.mp3",--//东
	[0x32] = "mjt4_2.mp3",--//南
	[0x33] = "mjt4_3.mp3",--//西
	[0x34] = "mjt4_4.mp3",--//北
	}

	local sound_path = ""
	local p = value_path_dict[card_value] or ""

	if tonumber(sex) == 1 then --男
		sound_path = TpackageName.."/res/voice/boy/card/".. p
	else
		sound_path = TpackageName.."/res/voice/girl/card/".. p
	end

	self:playEffect(sound_path)
end

function MusicManager:get_bg_music_path()
	-- body
	local sound_path = "hall/majiangsound/bg.mp3"
	return sound_path
end

return MusicManager