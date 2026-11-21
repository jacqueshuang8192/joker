local SoundUtils = class("SoundUtils")

function SoundUtils:ctor()
end

function SoundUtils:playEffect(sound_path)
    require("hall.GameCommon"):playEffectSound(sound_path, false)
end


function SoundUtils:handCards(_type, sex)
    if bit.band(_type, g_308.t_peng) > 0 then --碰
        self:playEffectPeng(sex)
    elseif bit.band(_type, g_308.t_gang) > 0 then
        self:playEffectGang(sex)
    elseif bit.band(_type, g_308.t_chi) > 0 then
    elseif bit.band(_type, g_308.t_hu) > 0 then
        self:playEffectHu(sex)
    end
end

--碰的声音
function SoundUtils:playEffectPeng(sex)
    local random = math.random(5)
    local sound_path = ""
    if tonumber(sex) == 1 then
        sound_path = "hz_majiang/res/sound/man/" .. "peng" .. tostring(random) .. ".mp3"
    else
        sound_path = "hz_majiang/res/sound/woman/" .. "peng" .. tostring(random) .. ".mp3"
    end
    self:playEffect(sound_path)
end

--杆的声音
function SoundUtils:playEffectGang(sex)
    local random = math.random(3)
    local sound_path = ""
    if tonumber(sex) == 1 then --男
        sound_path = "hz_majiang/res/sound/man/" .. "gang" .. tostring(random) .. ".mp3"
    else
        sound_path = "hz_majiang/res/sound/woman/" .. "gang" .. tostring(random) .. ".mp3"
    end
    self:playEffect(sound_path)
end

--胡的声音
function SoundUtils:playEffectHu(sex)
    local random = math.random(3)
    local sound_path = ""
    if tonumber(sex) == 1 then --男
        sound_path = "hz_majiang/res/sound/man/" .. "hu" .. tostring(random) .. ".mp3"
    else
        sound_path = "hz_majiang/res/sound/woman/" .. "hu" .. tostring(random) .. ".mp3"
    end
    self:playEffect(sound_path)
end

function SoundUtils:playCardSound(sex, card_value)
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
        [49] = "mjt4_1.mp3",--//东
        [50] = "mjt4_2.mp3",--//南
        [51] = "mjt4_3.mp3",--//西
        [52] = "mjt4_4.mp3"--//北
    }

    local sound_path = ""
    local p = value_path_dict[card_value] or ""
    if tonumber(sex) == 1 then --男
        sound_path = "hz_majiang/res/sound/man/" .. p
    else
        sound_path = "hz_majiang/res/sound/woman/" .. p
    end

    self:playEffect(sound_path)
end

function SoundUtils:playBackgroundMusic()
    audio.playMusic("hz_majiang/res/sound/bgm.mp3",true)
end

function SoundUtils:playBgmByType( ... )
    local musicPath = cc.UserDefault:getInstance():getIntegerForKey("bgMusicType_"..USER_INFO.level, 1)
    -- local sound_path = "hall/scene/res/common/music/AllBgMusic/mj_"..musicPath..".mp3"
    -- audio.playMusic(sound_path, true)
end

return SoundUtils
