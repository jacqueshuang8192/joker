local SoundUtils = class("SoundUtils")
local CardUtils = require("xupuphz.src.CardUtils")
local Config = require("xupuphz.src.Config")

function SoundUtils:ctor()
end

function SoundUtils:SoundCard(poker, seat)
    local ziPaiCard = CardUtils:getZiPaiCard( poker )
    local sex = Config:getUsetInfoBySeatId(seat).sex
    if sex == 1 then
        sex = "nan"
    else
        sex = "nv"
    end
    require("hall.GameCommon"):playEffectSound("xupuphz/res/sound/"..sex.."/"..ziPaiCard..".mp3")
end

function SoundUtils:SoundCardType(value, seat)
    local sex = Config:getUsetInfoBySeatId(seat).sex
    if sex == 1 then
        sex = "nan"
    else
        sex = "nv"
    end
    require("hall.GameCommon"):playEffectSound("xupuphz/res/sound/"..sex.."/"..value..".mp3")
end

return SoundUtils