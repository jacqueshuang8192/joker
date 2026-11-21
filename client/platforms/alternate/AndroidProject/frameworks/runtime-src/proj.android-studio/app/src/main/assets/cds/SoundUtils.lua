--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local SoundUtils = class("SoundUtils")

local rootSoundPath = TpackageName.."/sound/"

local sound_path_arr = 
                {   
                    ["dengdaixiazhu"] =rootSoundPath.."dengdaixiazhu"..".mp3",
                    ["kaishixiazhu"] =rootSoundPath.."kaishixiazhu"..".mp3",
                    ["tingzhixiazhu"] =rootSoundPath.."tingzhixiazhu"..".mp3",
                    ["fangdan"] =rootSoundPath.."fangdan"..".mp3",
                    ["hongdan"] =rootSoundPath.."hongdan"..".mp3",
                    ["hongshuang"] =rootSoundPath.."hongshuang"..".mp3",
                    ["mashuang"] =rootSoundPath.."mashuang"..".mp3",
                    ["click"] = rootSoundPath.."on_turn"..".mp3",
                    ["coinfly_long"] = rootSoundPath.."coins_fly_in_long"..".mp3",
                }


function SoundUtils:playEffect(sound_type)
	local sound_type = sound_type or ""
    local sound_path = sound_path_arr[sound_type] 
	self:playEffectSound(sound_path)
end


function SoundUtils:playEffectSound(sound_path)
    require("hall.GameCommon"):playEffectSound(sound_path)
end

function SoundUtils:playShaziMusic()
    math.randomseed(os.time())
    local randomIndex = math.random(1,18)
    self:playEffectSound(rootSoundPath.."yaoshaizi/"..randomIndex..".mp3")
end

return  SoundUtils