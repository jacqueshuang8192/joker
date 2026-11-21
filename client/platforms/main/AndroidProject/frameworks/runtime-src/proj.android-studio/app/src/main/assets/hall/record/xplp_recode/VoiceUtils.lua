
local musicManager = require("xplp_majiang.utils.music_manager.lua")

local VoiceUtils = class("VoiceUtils")

local SOUND_TYPE_CS_MAN = "changsha_man"

local SOUND_TYPE_CS_WOMEN = "changsha_woman"

local SOUND_HU_COUNT = 3
local SOUND_GANG_COUNT = 3
local SOUND_PENG_COUNT = 5
local SOUND_CHI_COUNT = 4

--出牌播放声音
function VoiceUtils:playCardSound(sex,card_value)
    local sex = USER_INFO["sex"]
    musicManager:playEffectCard(sex, card_value)    
end

function VoiceUtils:playControlSound(seatId, handle)
    local sex = USER_INFO["sex"]

    if bit.band(handle, HU_TYPE_H ) > 0 then
        musicManager:playEffectHu(sex)
    elseif bit.band(handle, CONTROL_TYPE_GANG) > 0 then
        musicManager:playEffectGang(sex)
    elseif bit.band(handle, CONTROL_TYPE_PENG) > 0 then
        musicManager:playEffectPeng(sex)
    elseif bit.band(handle,CONTROL_TYPE_CHI) >0 then
        musicManager:playEffectChi(sex) 
    elseif bit.band(handle,HU_TYPE_ZM) > 0 then
      musicManager:playEffectZm(sex)
    end
end

function VoiceUtils:playBackgroundMusic()
    audio.playMusic("xplp_majiang/res/voice/bgm.mp3",true)
end

function VoiceUtils:stopPlayBackgroundMusic()
    audio.stopMusic(true)
end

 

return VoiceUtils