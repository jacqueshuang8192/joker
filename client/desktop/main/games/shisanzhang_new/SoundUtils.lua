--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local SoundUtils = class("SoundUtils")
local CardUtils = require(TpackageName..".CardUtils")
local rootSoundPath = TpackageName.."/res/sound/"

local sound_path_arr = {   
    ["发牌"] = rootSoundPath.."poker"..".mp3",
}
-- cc.FileUtils:getInstance():getWritablePath()
local  bg_array = { 
    [1] = rootSoundPath.."bg_1.mp3",
    [2] = rootSoundPath.."bg_2.mp3",
    [3] = rootSoundPath.."bg_3.mp3",
    [4] = HallBgm_filePath,
}

local new_card_kind_sound = CardUtils.FILENAME
new_card_kind_sound["开始比牌"] = "start_compare"  --开始比牌
new_card_kind_sound["请出牌"] = "qingchupai"  --比牌
new_card_kind_sound["打枪"] = "daqiang"  --打枪
new_card_kind_sound["全垒打"] = "quanleida"  --全垒打


function SoundUtils:playEffect(sound_type,Strength)
	local sound_type = sound_type or ""
    local sound_path = sound_path_arr[sound_type] 
	self:playEffectSound(sound_path)
end


function SoundUtils:playCardKindEffect(cardKind, sex, type)
    local sex = sex or USER_INFO.sex
    local sexPath = "/man/"
    if sex == 1 then
        sexPath = "/woman/"
    end
    local sexPath = "2/"
    local sound_path = rootSoundPath .. sexPath .. new_card_kind_sound[cardKind] .. ".mp3"
    self:playEffectSound(sound_path)
end


function SoundUtils:playEffectSound(sound_path)
    require("hall.GameCommon"):play2d(sound_path)
end

function SoundUtils:playBackgroundMusic()
    -- math.randomseed(os.time())
    -- local randomIndex = math.random(1,4)
    -- local CURRENTCARDBACKINDEX = cc.UserDefault:getInstance():getIntegerForKey("CheckBox_Index",1)
    local sound_path = bg_array[2]
    -- if GameBG_fillePath then
    --     sound_path = GameBG_fillePath[CURRENTCARDBACKINDEX]
    -- end
    if sound_path then
        audio.playMusic(sound_path, true)
    else
        audio.playMusic(sound_path, true)
    end
end

return  SoundUtils