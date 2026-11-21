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
                    ["输"] =rootSoundPath.. "lose.mp3", --"compare_failure #1"..".mp3",
                    ["赢"] =rootSoundPath.."win.mp3", --"compare_victory #1"..".mp3",
                    ["倒计时"] =rootSoundPath.."time"..".mp3",
                    ["超时"] = rootSoundPath .. "time_out"..".mp3",
                    [8] = rootSoundPath.."dscj_arrive"..".mp3",  --选庄声音
                    ["随机特效"] = rootSoundPath.."dscj_zd" ..".mp3",
                    ["定庄特效"] = rootSoundPath.."dscj_arrive2" ..".mp3",
                    ["gameStart"] = rootSoundPath .. "game_start.mp3",  --游戏开始声音
                    ["click"] = rootSoundPath .. "on_turn.mp3",
                    ["dealCards"] = rootSoundPath .. "poker.mp3", 
                    ["coinfly_long"] = rootSoundPath.."coins_fly_in_long.mp3",
                    ["coinfly_short"] = rootSoundPath.."coins_fly_in_short.mp3",
                    ["选中牌"] = rootSoundPath .. "select_card.mp3",
                    ["取消牌"] = rootSoundPath .. "unselect_card.mp3",
                    ["色子"] = rootSoundPath .. "rock_sezi.mp3"
}
-- cc.FileUtils:getInstance():getWritablePath()
local  bg_array = { [1]= rootSoundPath.."gamebg.mp3",
                    [2]= rootSoundPath.."baccarat #1.mp3",
                    [3]= rootSoundPath.."bg-room.mp3"
                  }


local  card_kind_sound_2 = 
    {   
        ["炸弹"] = 1, ["鬼子"] = 2, ["皇上"] = 4, ["天王九"] = 5, ["地九娘娘"] = 6, ["对天"] = 7, ["对地"] = 8, ["对人"] = 9,
        ["对娥"] = 10, ["对长"] = 11, ["对短"] = 14, ["对杂九"] = 18, ["对杂八"] = 19, ["对杂七"] = 20, ["对杂五"] = 21,
        ["天杠"] = 22, ["地杠"] = 23, ["天九"] = 24, ["地九"] = 25, ["人九"] = 26, ["娥九"] = 27, ["长九"] = 28, ["短九"] = 29,
        ["天八"] = 30, ["地八"] = 31, ["人八"] = 32, ["娥八"] = 33, ["长八"] = 34, ["短八"] = 35, ["天七"] = 37, ["地七"] = 38,
        ["人七"] = 39, ["娥七"] = 40, ["长七"] = 41, ["短七"] = 42, ["杂七"] = 43, ["天六"] = 44, ["地六"] = 45, ["人六"] = 46,
        ["长六"] = 47, ["短六"] = 48, ["杂六"] = 49, ["天五"] = 50, ["地五"] = 51, ["人五"] = 52, ["娥五"] = 53, ["长五"] = 54,
        ["短五"] = 55, ["杂五"] = 56, ["天四"] = 57, ["人四"] = 58, ["娥四"] = 59, ["长四"] = 60, ["短四"] = 61, ["杂四"] = 62,
        ["天三"] = 63, ["地三"] = 64, ["人三"] = 65, ["娥三"] = 66, ["长三"] = 67, ["短三"] = 68, ["杂三"] = 69, ["天二"] = 70,
        ["地二"] = 71, ["人二"] = 72, ["娥二"] = 73, ["长二"] = 74, ["短二"] = 75, ["杂二"] = 76, ["地一"] = 78, ["人一"] = 79,
        ["娥一"] = 80, ["长一"] = 81, ["短一"] = 82, ["杂一"] = 83, ["毕十"] = 84,

    }

local  card_kind_sound =
{
    [270] = 1, [260] = 2, [250] = 4, [240] = 5, [230] = 6, [220] = 7, [210] = 8, [200] = 9,
    [190] = 10, [180] = 11, [170] = 14, [160] = 18, [150] = 19, [140] = 20, [130] = 21,
    [120] = 22, [110] = 23, [79] = 24, [69] = 25, [59] = 26, [49] = 27, [39] = 28, [29] = 29,
    [78] = 30, [68] = 31, [58] = 32, [48] = 33, [38] = 34, [28] = 35, [77] = 37, [67] = 38,
    [57] = 39, [47] = 40, [37] = 41, [27] = 42, [17] = 43, [76] = 44, [66] = 45, [56] = 46,
    [36] = 47, [26] = 48, [16] = 49, [75] = 50, [65] = 51, [55] = 52, [45] = 53, [35] = 54,
    [25] = 55, [15] = 56, [74] = 57, [54] = 58, [44] = 59, [34] = 60, [24] = 61, [14] = 62,
    [73] = 63, [63] = 64, [53] = 65, [43] = 66, [33] = 67, [23] = 68, [13] = 69, [72] = 70,
    [62] = 71, [52] = 72, [42] = 73, [32] = 74, [22] = 75, [12] = 76, [61] = 78, [51] = 79,
    [41] = 80, [31] = 81, [21] = 82, [11] = 83, [0] = 84,

}


-------------------------------------------------------------

function SoundUtils:playEffect(sound_type,Strength)
	local sound_type = sound_type or ""
    local sound_path = sound_path_arr[sound_type] 
	self:playEffectSound(sound_path)
end

local LoadCard = require(TpackageName .. ".operator.LoadCard")
------标签0------------------------------添加一个cards参数---
function SoundUtils:playCardKindEffect(uid, cardKind, newcardtype, cards)
    
    local sex_sound = ""
    if PAIJIU_USERINFO_TABLE[uid] then
        local sex =  PAIJIU_USERINFO_TABLE[uid].sex
        if sex then
            -- if tonumber(sex) == 1 then
            --     --sex_sound = "girl"
            --     sex_sound = "newgirl"
            -- else
            --     sex_sound = "boy"
            -- end
            sex_sound = "newgirl"
            local type_id = card_kind_sound[cardKind]
            
            local type_id = LoadCard.card_new_sound[LoadCard.changeCardsString(cards[1],cards[2])]
            if type_id ~= nil then
                --local sound_path = rootSoundPath .. sex_sound .. "/dtj_" .. tostring(type_id) ..".mp3"
                local sound_path = rootSoundPath .. sex_sound .. "/".. type_id .. ".mp3"
                dump(sound_path,"yin yue--------------------")
                self:playEffectSound(sound_path)
            end
        end
    end
end


function SoundUtils:playEffectSound(sound_path)
    --cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
    require("hall.GameCommon"):playEffectSound(sound_path, false)
end

function SoundUtils:playBackgroundMusic()

    math.randomseed(os.time())

    local sound_path = bg_array[1]

    dump(sound_path,"sound_path")
    -- audio.playMusic(sound_path, true)

    dump(cc.SimpleAudioEngine:getInstance(),"cc.SimpleAudioEngine:getInstance()")
    cc.SimpleAudioEngine:getInstance():playMusic(sound_path, true)

end

return  SoundUtils