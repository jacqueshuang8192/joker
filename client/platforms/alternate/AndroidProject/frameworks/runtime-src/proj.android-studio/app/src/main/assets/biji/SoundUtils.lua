--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local SoundUtils = class("SoundUtils")

local rootSoundPath = TpackageName.."/sound/"

local sound_path_arr = 
                {   
                    ["下注"] =rootSoundPath.."jiazhuchouma"..".mp3",
                    ["发牌"] =rootSoundPath.."poker"..".mp3",
                    ["sendCard"] =rootSoundPath.."fapai1"..".mp3",
                    ["翻牌"] =rootSoundPath.."fapai"..math.random(1,6)..".mp3",
                    ["翻两张"] =rootSoundPath.."fapai_long.mp3",
                    ["输"] =rootSoundPath.. "lose_effect.mp3", --"compare_failure #1"..".mp3",
                    ["赢"] =rootSoundPath.."win_effect.mp3", --"compare_victory #1"..".mp3",
                    ["倒计时"] =rootSoundPath.."time"..".mp3",
                    [8] = rootSoundPath.."dscj_arrive"..".mp3",  --选庄声音
                    ["随机特效"] = rootSoundPath.."dscj_zd" ..".mp3",
                    ["定庄特效"] = rootSoundPath.."dscj_win" ..".mp3",
                    ["gameStart"] = rootSoundPath .. "game_start.mp3",  --游戏开始声音
                    ["click"] = rootSoundPath .. "on_turn.mp3",
                    ["dealCards"] = rootSoundPath .. "poker.mp3", 
                    ["dealCards_short"] = rootSoundPath .. "fapai1.mp3", 
                    ["coinfly_long"] = rootSoundPath.."coins_fly_in_long.mp3",
                    ["coinfly_short"] = rootSoundPath.."coins_fly_in_short.mp3",
                }
-- cc.FileUtils:getInstance():getWritablePath()
local  bg_array = { [1]= rootSoundPath.."gamebg.mp3",
                    [2]= rootSoundPath.."baccarat #1.mp3",
                    [3]= rootSoundPath.."bg-room.mp3",
                    [4]= HallBgm_filePath,}

local  card_kind_sound =
    {
        [0] = "0.mp3",
        [1] = "1.mp3", --无牛
        [2] = "2.mp3",
        [3] = "3.mp3",
        [4] = "4.mp3",
        [5] = "5.mp3",
        [6] = "6.mp3",
        [7] = "7.mp3",
        [8] = "8.mp3",
        [9] = "9.mp3",
        [10] ="ssg.mp3",  --牛九
        [11] = "hsg.mp3",  --牛牛
        [12] = "dsg.mp3",  --牛牛
    }

function SoundUtils:playEffect(sound_type,Strength)
	local sound_type = sound_type or ""
    local sound_path = sound_path_arr[sound_type] 
	self:playEffectSound(sound_path)
end


function SoundUtils:playCardKindEffect(cardKind,sex,type)
    -- dump(debug.traceback(),"playCardKindEffect")

    local sex = sex or USER_INFO["sex"]
    -- dump(sex,"playCardKindEffectsex")
    
    local sexPath = "/man/"

    if  sex == 1 then
        sexPath = "/woman/"
    end

    local sound_path = rootSoundPath .. sexPath..card_kind_sound[cardKind]
    if type == 1 then
        sound_path = rootSoundPath .. sexPath..card_kind_sound[11]
    end
    if type == 2 then
        sound_path = rootSoundPath .. sexPath..card_kind_sound[10]
    end
    if type == 3 then
        sound_path = rootSoundPath .. sexPath..card_kind_sound[12]
    end
    self:playEffectSound(sound_path)
end


function SoundUtils:playEffectSound(sound_path)
	-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
    require("hall.GameCommon"):playEffectSound(sound_path)
end



function SoundUtils:playBackgroundMusic()
    
    math.randomseed(os.time())
    local randomIndex = math.random(1,4)
    local CURRENTCARDBACKINDEX = cc.UserDefault:getInstance():getIntegerForKey("CheckBox_Index",1)
    local sound_path = bg_array[3]
    if GameBG_fillePath then
        sound_path = GameBG_fillePath[CURRENTCARDBACKINDEX]
    end

    if sound_path then
        audio.playMusic(sound_path, true)
    else
        audio.playMusic(sound_path, true)
    end

    --cc.SimpleAudioEngine:getInstance():playMusic(GameBG_fillePath[CURRENTCARDBACKINDEX], true)

end

return  SoundUtils