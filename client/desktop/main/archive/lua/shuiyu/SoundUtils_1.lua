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
                    [2]= rootSoundPath.."baccarat.mp3",
                    [3]= rootSoundPath.."bgroom.mp3",
                    [4]= rootSoundPath.."bg_hall.mp3",}

local  card_kind_sound = 
    {   
        [0] = "",
        [1] = "bull0.mp3", --无牛
        [2] = "bull1.mp3",
        [3] = "bull2.mp3",
        [4] = "bull3.mp3",
        [5] = "bull4.mp3",
        [6] = "bull5.mp3",
        [7] = "bull6.mp3",
        [8] = "bull7.mp3",
        [9] = "bull8.mp3",
        [10] = "bull9.mp3",  --牛九
        [11] = "bull10.mp3",  --牛牛
        [CARDKIND_SHUNZI] = "f1_nn11.mp3",  --顺子牛
        [CARDKIND_TONGHUANIU] = "f1_nn13.mp3",  --同花牛
        [CARDKIND_HULUNIU] = "f1_nn14.mp3",  --葫芦牛

        [CARDKIND_WUHUA] = "bull11.mp3",  --五花牛
        [CARDKIND_SIZHA] = "bull12.mp3",  --四炸
        [CARDKIND_WUXIAONIU] = "bull13.mp3",--五小牛
    }

function SoundUtils:playEffect(sound_type,Strength)
	local sound_type = sound_type or ""
    local sound_path = sound_path_arr[sound_type] 
	self:playEffectSound(sound_path)
end


function SoundUtils:playCardKindEffect(cardKind,sex)
    -- dump(debug.traceback(),"playCardKindEffect")

    local sex = sex or USER_INFO["sex"]
    -- dump(sex,"playCardKindEffectsex")
    
    local sexPath = "/girl/" 

    if  sex == 1 then
        sexPath = "/boy/" 
    end

    local sound_path = rootSoundPath .. sexPath.. (card_kind_sound[cardKind] or "")
    self:playEffectSound(sound_path)
end


function SoundUtils:playEffectSound(sound_path)
	-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
    require("hall.GameCommon"):playEffectSound(sound_path)
end



function SoundUtils:playBackgroundMusic()
    
    math.randomseed(os.time())
    local randomIndex = math.random(1,#bg_array)
    local sound_path = bg_array[randomIndex] 
    -- audio.playMusic(sound_path, true)
    cc.SimpleAudioEngine:getInstance():playMusic(sound_path,true)

end

return  SoundUtils