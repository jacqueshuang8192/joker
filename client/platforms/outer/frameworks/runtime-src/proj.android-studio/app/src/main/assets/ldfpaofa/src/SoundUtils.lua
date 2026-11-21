local SoundUtils = class("SoundUtils")
local CardUtils = require("ldfpaofa.src.CardUtils")
local Config = require("ldfpaofa.src.Config")

function SoundUtils:ctor()
end

function SoundUtils:SoundCard(poker, seat)
    local sex = Config:getUsetInfoBySeatId(seat).sex
    if sex == 1 then
        sex = "nan/"
    else
        sex = "nv/"
    end
    sex = ""
    require("hall.GameCommon"):playEffectSound("ldfpaofa/res/sound/"..sex..poker..".mp3")
end

function SoundUtils:SoundCardType(value, seat)
    local sex = Config:getUsetInfoBySeatId(seat).sex
    if sex == 1 then
        sex = "nan/"
    else
        sex = "nv/"
    end
    sex = ""
    require("hall.GameCommon"):playEffectSound("ldfpaofa/res/sound/"..sex..value..".mp3")
end

return SoundUtils