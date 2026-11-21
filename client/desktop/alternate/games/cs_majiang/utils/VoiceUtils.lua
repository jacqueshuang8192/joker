local musicManager = require("cs_majiang.utils.music_manager.lua")

local VoiceUtils = class("VoiceUtils")

local SOUND_TYPE_CS_MAN = "changsha_man"
local SOUND_TYPE_CS_WOMEN = "changsha_woman"

local SOUND_HU_COUNT = 3
local SOUND_GANG_COUNT = 3
local SOUND_PENG_COUNT = 5
local SOUND_CHI_COUNT = 4

--出牌播放声音
function VoiceUtils:playCardSound(seatId,card_value)
    
    local sex = CSMJ_USERINFO_TABLE[seatId .. ""].sex

    musicManager:playEffectCard(sex, card_value)    
end

function VoiceUtils:playControlSound(seatId, handle, bonus)
    -- body
    local sex = CSMJ_USERINFO_TABLE[seatId .. ""].sex

    if bit.band(handle, HU_TYPE_ZM) > 0 then
        musicManager:playEffectZimo(sex)
    elseif bit.band(handle, CONTROL_TYPE_HU) > 0 then
        --todo
        musicManager:playEffectHu(sex)
    elseif bit.band(handle, CONTROL_TYPE_GANG) > 0 then
        if bonus == 1 then
            musicManager:playEffectGang(sex)
        else
            musicManager:playEffectBuzhang(sex)
        end
        
    elseif bit.band(handle, CONTROL_TYPE_PENG) > 0 then
        musicManager:playEffectPeng(sex)        
    elseif bit.band(handle, CONTROL_TYPE_CHI) > 0 then
        musicManager:playEffectChi(sex)
    end
end

function VoiceUtils:playBackgroundMusic()
    audio.playMusic("cs_majiang/voice/BG_283.mp3",true)
end

return VoiceUtils