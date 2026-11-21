local musicManager = require(TpackageName..".utils.music_manager.lua")

local VoiceUtils = class("VoiceUtils")

local SOUND_TYPE_CS_MAN = "changsha_man"
local SOUND_TYPE_CS_WOMEN = "changsha_woman"

local SOUND_HU_COUNT = 3
local SOUND_GANG_COUNT = 3
local SOUND_PENG_COUNT = 5
local SOUND_CHI_COUNT = 4

--出牌播放声音
function VoiceUtils:playCardSound(seatId,card_value)
    if CSMJ_USERINFO_TABLE[seatId] then
        local sex = CSMJ_USERINFO_TABLE[seatId].sex
        musicManager:playEffectCard(sex, card_value)    
    end
end

--出牌的背景声音
function VoiceUtils:playChuPaiSound()
    if CSMJ_USERINFO_TABLE[seatId] then
        local sex = CSMJ_USERINFO_TABLE[seatId].sex
        musicManager:playEffectChuPai()    
    end
end

function VoiceUtils:playControlSound(seatId, handle)
    -- body
    local sex = CSMJ_USERINFO_TABLE[seatId ].sex

    if bit.band(handle, CONTROL_TYPE_HU) > 0 then
        --todo
        musicManager:playEffectHu(sex)
    elseif bit.band(handle, CONTROL_TYPE_GANG) > 0 then
        musicManager:playEffectGang(sex)
    elseif bit.band(handle, CONTROL_TYPE_PENG) > 0 then
        musicManager:playEffectPeng(sex)
    elseif bit.band(handle,CONTROL_TYPE_CHI) >0 then
        musicManager:playEffectChi(sex)          
    end
end

function VoiceUtils:playBackgroundMusic()
    audio.playMusic(TpackageName.."/res/voice/bgm.mp3",true)
end

return VoiceUtils