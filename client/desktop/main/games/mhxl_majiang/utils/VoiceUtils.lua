local musicManager = require("mhxl_majiang.utils.music_manager.lua")

local VoiceUtils = class("VoiceUtils")

local SOUND_TYPE_CS_MAN = "changsha_man"
local SOUND_TYPE_CS_WOMEN = "changsha_woman"

local SOUND_HU_COUNT = 3
local SOUND_GANG_COUNT = 3
local SOUND_PENG_COUNT = 5
local SOUND_CHI_COUNT = 4

-- function VoiceUtils:GET_CARD_SOUND(sex, card_value)
--     -- body
--     local sound_path = ""
--     if sex == 1 or sex == "1" then
--         sound_path = "mhxl_majiang/voice/" .. SOUND_TYPE_CS_MAN .. "/mj" .. card_value .. ".mp3"
--     else
--         sound_path = "mhxl_majiang/voice/" .. SOUND_TYPE_CS_WOMEN .. "/mj" .. card_value .. ".mp3"
--     end
--     return sound_path
-- end

-- function VoiceUtils:GET_CONTROL_SOUND(sex, handle)
--     -- body
--     local sound_path = ""

--     local sexPath
--     if sex == 1 or sex == "1" then
--         sexPath = SOUND_TYPE_CS_MAN
--     else
--         sexPath = SOUND_TYPE_CS_WOMEN
--     end

--     local controlType
--     local index
--     if bit.band(handle, CONTROL_TYPE_HU) > 0 then
--         --todo
--         controlType = "hu"
--         index = math.random(1, SOUND_HU_COUNT)
--     elseif bit.band(handle, CONTROL_TYPE_GANG) > 0 then
--         controlType = "gang"
--         index = math.random(1, SOUND_GANG_COUNT)
--     elseif bit.band(handle, CONTROL_TYPE_PENG) > 0 then
--         controlType = "peng"
--         index = math.random(1, SOUND_PENG_COUNT)
--     else
--         controlType = "chi"
--         index = math.random(1, SOUND_CHI_COUNT)
--     end

--     sound_path = "mhxl_majiang/voice/" .. sexPath .. "/" .. controlType .. index .. ".mp3"

--     return sound_path
-- end

--出牌播放声音
function VoiceUtils:playCardSound(seatId,card_value)

    local sex = XLMH_USERINFO_TABLE[seatId .. ""].sex

    musicManager:playEffectCard(sex, card_value)    
end

function VoiceUtils:playControlSound(seatId, handle)
    -- body
    local sex = XLMH_USERINFO_TABLE[seatId .. ""].sex

    if bit.band(handle, CONTROL_TYPE_HU) > 0 then
        --todo
        musicManager:playEffectHu(sex)
    elseif bit.band(handle, CONTROL_TYPE_GANG) > 0 then
        musicManager:playEffectGang(sex)
    elseif bit.band(handle, CONTROL_TYPE_PENG) > 0 then
        musicManager:playEffectPeng(sex)        
    elseif bit.band(handle, CONTROL_TYPE_CHI) > 0 then
        musicManager:playEffectChi(sex)
    elseif  bit.band(handle, BUHUA_TYPE_B) > 0 then
        musicManager:playEffectBuhua(sex)   
    end
end

--add by zzy 
function VoiceUtils:playChongFengJi( seatId )
    local sex = XLMH_USERINFO_TABLE[seatId .. ""].sex
    musicManager:playEffectChongFengJi(sex)
end

function VoiceUtils:playDianPao( seatId )
    local sex = XLMH_USERINFO_TABLE[seatId .. ""].sex
    musicManager:playEffectDianPao(sex)
end

function VoiceUtils:playEffectMenHu( seatId )
    local sex = XLMH_USERINFO_TABLE[seatId .. ""].sex
    musicManager:playEffectMenHu(sex)
end

function VoiceUtils:playEffectTianTing( seatId )
    local sex = XLMH_USERINFO_TABLE[seatId .. ""].sex
    musicManager:playEffectTianTing(sex)
end

function VoiceUtils:playBackgroundMusic()
    audio.playMusic("mhxl_majiang/voice/bgm.mp3",true)
end

return VoiceUtils