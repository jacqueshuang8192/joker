--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local SoundUtils = class("SoundUtils")
local CardUtils = require(TpackageName..".CardUtils")
local ShiSanZhangConfig = require(TpackageName..".config.ShiSanZhangConfig")

local rootSoundPath = TpackageName.."/res/sound/"

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
local  bg_array = { 
    [1]= rootSoundPath.."gamebg.mp3",
    [2]= rootSoundPath.."baccarat #1.mp3",
    [3]= rootSoundPath.."bg-room.mp3",
    [4]= HallBgm_filePath,
}

local new_card_kind_sound = CardUtils.FILENAME
new_card_kind_sound["开始比牌"] = "Other/start_compare"  --开始比牌
new_card_kind_sound["比牌"] = "Other/start_poker"  --比牌
new_card_kind_sound["打枪"] = "Other/daqiang"  --打枪
new_card_kind_sound["全垒打"] = "Other/quanleida"  --全垒打

local card_kind_sound =
    {
        [1] = "common1.mp3",
        [2] = "common2.mp3",
        [3] = "common3.mp3",
        [4] = "common4.mp3",
        [5] = "common5.mp3",
        [6] = "common6.mp3",
        [7] = "common7.mp3",
        [8] = "common8.mp3",
        [9] = "common9.mp3",
        [10] = "common10.mp3",
       
        [11] = "special4010.mp3",  --三同花
        [12] = "special4020.mp3",  --三顺子
        [13] = "special4030.mp3",  --六对半
        [21] = "special4040.mp3",  --三同花顺
        [23] = "special4050.mp3",  --一条龙
        [24] = "special4060.mp3",  --至尊清龙
        ["冲三"] = "common11.mp3", --冲三
        ["中墩葫芦"] = "common12.mp3",  --中墩葫芦
        ["开始比牌"] = "start_compare.mp3",  --开始比牌
        ["比牌"] = "start_poker.mp3",  --比牌
        ["打枪"] = "daqiang1.mp3",  --打枪
        ["全垒打"] = "quanleida.mp3",  --全垒打
        
        -- [10] ="ssg.mp3",  --牛九
        -- [11] = "hsg.mp3",  --牛牛
        -- [12] = "dsg.mp3",  --牛牛
        -- WL = 1,//乌龙
        --  YD = 2,//1对
        --  ED = 3,//2对
        --  ST = 4,//三条
        --  SZ = 5,//顺子
        --  TH = 6,//同花
        --  HL = 7,//葫芦
        --  TZ = 8,//铁支
        --  THS = 9,//同花顺
        --  WT = 10,//五同
        --  STH = 11,//三同花
        --  SSZ = 12,//三顺子
        --  LDB = 13,//六对半
        --  WDST = 14,//五对三条
        --  STST = 15,//四套三条
        --  SGCS = 16,//双怪冲三
        --  QX = 17,//全小
        --  QD = 18,//全大
        --  CYS = 19,//凑一色
        --  SFTX = 20,//三套炸弹、三分天下
        --  STHS = 21,//三同花顺
        --  SEHZ = 22,//十二皇族
        --  YTL = 23,//一条龙
        --  ZZQL = 24,//至尊清龙
        --  TZP = 25,//铁子牌
        --  THSBD = 26,//同花顺报道
        --  WTZ = 27//五同钻
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
    
    local sound_path
 
    if ShiSanZhangConfig:getVersion() then
        sexPath = "/2/"
        sound_path = rootSoundPath .. sexPath .. new_card_kind_sound[cardKind] .. ".mp3"
    else
        sound_path = rootSoundPath .. sexPath .. card_kind_sound[cardKind]
        if type == 1 then
            sound_path = rootSoundPath .. sexPath .. card_kind_sound[11]
        end
        if type == 2 then
            sound_path = rootSoundPath .. sexPath .. card_kind_sound[10]
        end
        if type == 3 then
            sound_path = rootSoundPath .. sexPath .. card_kind_sound[12]
        end
    end

    self:playEffectSound(sound_path)
end


function SoundUtils:playEffectSound(sound_path)
    require("hall.GameCommon"):play2d(sound_path)

	-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
    -- require("hall.GameCommon"):playEffectSound(sound_path)
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