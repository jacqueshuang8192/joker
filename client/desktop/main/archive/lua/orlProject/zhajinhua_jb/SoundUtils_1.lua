--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local SoundUtils = class("SoundUtils")

local rootSoundPath = TpackageName.."/sounds/"

local  card_kind_sound = 
    {   
        -- [0] = "",
        -- [6] = "f0_nn5.mp3",
        -- [7] = "f0_nn6.mp3",
        -- [8] = "f0_nn7.mp3",
        -- [9] = "f0_nn8.mp3",
        -- [10] = "f0_nn9.mp3",  --牛九
        -- [11] = "f0_nn10.mp3",  --牛牛

         [3] = "paiType3.mp3",--对子
         [4] = "paiType4.mp3",--顺子
         [5] = "paiType5.mp3",--同花
         [6] = "paiType6.mp3",--同花顺
         [7] = "paiType7.mp3",--豹子
        ["call"] = "call.mp3",--跟注
        ["cmp"] = "cmp.mp3",--比牌
        ["fold"] = "fold.mp3",--弃牌
        ["raise"] = "raise.mp3",--加注
        ["view"] = "view.mp3",--看牌
    }

function SoundUtils:playEffect(sound_type,Strength)
	local sound_type = sound_type or ""
    local sound_path = sound_path_arr[sound_type] 
	self:playEffectSound(sound_path)
end


function SoundUtils:playCardKindEffect(cardKind,sex)
    local sex = sex or USER_INFO["sex"]
    -- dump(sex,"playCardKindEffectsex")
    sex = tonumber(sex)
    local sexPath = "man/" 

    if  sex == 1 then
        sexPath = "woman/" 
    end
    if (card_kind_sound[cardKind]) then
        local sound_path = rootSoundPath .. sexPath.. (card_kind_sound[cardKind] or "")
        print("sound_path",sound_path)
        require("hall.GameCommon"):playEffectSound(sound_path)
        --local test = rootSoundPath.."55555.mp3"
        --require("hall.GameCommon"):playEffectSound(test)
    end


    --self:playEffectSound(sound_path)
end

function SoundUtils:playCardKindEffectType(cardKind,sex)
    if (card_kind_sound[cardKind]) then
        local sound_path = rootSoundPath .."soud/".. (card_kind_sound[cardKind] or "")
        print("sound_path",sound_path)
        require("hall.GameCommon"):playEffectSound(sound_path)
        --local test = rootSoundPath.."55555.mp3"
        --require("hall.GameCommon"):playEffectSound(test)
    end


    --self:playEffectSound(sound_path)
end
function SoundUtils:playEffectSound(sound_path)
	-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
    require("hall.GameCommon"):play2d(sound_path)
end



function SoundUtils:playBackgroundMusic()
    local bgmPath = rootSoundPath .. "bg.mp3"
    --cc.SimpleAudioEngine:getInstance():playMusic(bgmPath,true)
    audio.playMusic(bgmPath,true)
end

return  SoundUtils