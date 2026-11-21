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
    if XLCHMJ_USERINFO_TABLE[seatId] then
        --local sex = XLCHMJ_USERINFO_TABLE[seatId].sex
        --次平台只需要男音
        local sex = 1
        musicManager:playEffectCard(sex, card_value)    
    end
end

function VoiceUtils:playControlSound(seatId, handle)

    --local sex = XLCHMJ_USERINFO_TABLE[seatId ].sex

    --次平台只需要男音
    local sex = 1

    if bit.band(handle, CONTROL_TYPE_HU) > 0 then
        local huType = 0
        if bit.band(handle, HU_TYPE_H) > 0 then
            huType = 1
        elseif bit.band(handle, HU_TYPE_ZM) > 0 then
            huType = 2
        elseif bit.band(handle, HU_TYPE_MEN_HU) > 0 then
            huType = 3
        end
        musicManager:playEffectHu(sex,huType)
    elseif bit.band(handle, CONTROL_TYPE_GANG) > 0 then
        local huType = 1

        if bit.band(handle, GANG_TYPE_AN) > 0 then
            huType = 2
        elseif bit.band(handle, GANG_TYPE_BU) > 0 then
             huType = 3    
        end

        musicManager:playEffectGang(sex,huType)
    elseif bit.band(handle, CONTROL_TYPE_PENG) > 0 then
        musicManager:playEffectPeng(sex)
    elseif bit.band(handle, BAO_JIAO_TYPE) > 0 then
        musicManager:playEffectTianTing(sex)
    elseif bit.band(handle, HU_TYPE_MEN_HU) > 0 then
        musicManager:playEffectHu(sex,3)
    end
end

function VoiceUtils:playBackgroundMusic()
    audio.playMusic(TpackageName.."/res/voice/bgm.mp3",true)
end

--add by zzy 
function VoiceUtils:playChongFengJi( seatId )
    local sex = 1
    musicManager:playEffectChongFengJi(sex)
end

return VoiceUtils