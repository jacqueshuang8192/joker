--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local SoundUtils = class("SoundUtils")

local rootSoundPath = "FanSanPi/sounds/"

local  card_kind_sound = 
    {   
        -- [0] = "",
        -- [1] = "f0_nn0.mp3", --无牛
        -- [2] = "f0_nn1.mp3",
        -- [3] = "f0_nn2.mp3",
        -- [4] = "f0_nn3.mp3",
        -- [5] = "f0_nn4.mp3",
        -- [6] = "f0_nn5.mp3",
        -- [7] = "f0_nn6.mp3",
        -- [8] = "f0_nn7.mp3",
        -- [9] = "f0_nn8.mp3",
        -- [10] = "f0_nn9.mp3",  --牛九
        -- [11] = "f0_nn10.mp3",  --牛牛
        ["bupiao"] = "piao_0.mp3",--跟注
        ["call"] = "call.mp3",--跟注
        ["call_money"] = "fen_",
        ["cmp"] = "cmp.mp3",--比牌
        ["fold"] = "fold.mp3",--弃牌
        ["raise"] = "raise.mp3",--加注
        ["view"] = "view.mp3",--看牌
        ["piao_value"] = "piao_",
    }

local  bg_array = { [1]= rootSoundPath.."Music_back.mp3",
                    [2]= rootSoundPath.."baccarat.mp3",
                    [3]= rootSoundPath.."bgroom.mp3",}

function SoundUtils:playEffect(sound_type,Strength)
	local sound_type = sound_type or ""
    local sound_path = sound_path_arr[sound_type] 
	self:playEffectSound(sound_path)
end


function SoundUtils:playCardKindEffect(cardKind,sex,value)
    -- dump(debug.traceback(),"playCardKindEffect")

    local sex = sex or USER_INFO["sex"]
    -- dump(sex,"playCardKindEffectsex")
    sex = tonumber(sex)
    local sexPath = "/woman/" 

    if  sex == 1 then
        sexPath = "/man/"
    end

    local sound_path = rootSoundPath .. sexPath.. (card_kind_sound[cardKind] or "")
    if value then
        sound_path = sound_path..value..".mp3"
    end
    self:playEffectSound(sound_path)
end


function SoundUtils:playEffectSound(sound_path)
	-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
    require("hall.GameCommon"):playEffectSound(sound_path)
end



function SoundUtils:playBackgroundMusic()
    
    math.randomseed(os.time())
    local randomIndex = math.random(1,#bg_array)
    local sound_path = "FanSanPi/sounds/bgm.mp3"--bg_array[1] 
    -- audio.playMusic(sound_path, true)
    cc.SimpleAudioEngine:getInstance():playMusic(sound_path,true)

end

return  SoundUtils