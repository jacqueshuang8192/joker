local SoundUtils = class("SoundUtils")
local CardUtils = require("byzp.src.CardUtils")
local Config = require("byzp.src.Config")

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
    require("hall.GameCommon"):playEffectSound("byzp/res/sound/"..sex..poker..".mp3")
    dump("SoundUtils:poker  "..poker)
end

function SoundUtils:SoundCardType(value, seat)
    local sex = Config:getUsetInfoBySeatId(seat).sex
    if sex == 1 then
        sex = "nan/"
    else
        sex = "nv/"
    end
    sex = ""
    require("hall.GameCommon"):playEffectSound("byzp/res/sound/"..sex..value..".mp3")
    dump("SoundUtils:value  "..value)
end

return SoundUtils