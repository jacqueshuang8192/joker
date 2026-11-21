local SoundUtils = class("SoundUtils")
local Config = require("jchuapai.src.Config")

function SoundUtils:ctor()
end

function SoundUtils:SoundCard(poker, seat)
    local sex = Config:getUsetInfoBySeatId(seat).sex
    if sex == 1 then
        sex = "man/"
    else
        sex = "women/"
    end
    require("hall.GameCommon"):playEffectSound("jchuapai/res/sound/poker/"..sex..poker..".wav")
end

function SoundUtils:SoundCardType(value, seat)
    local sex = Config:getUsetInfoBySeatId(seat).sex
    if sex == 1 then
        sex = "nan/"
    else
        sex = "nv/"
    end
    require("hall.GameCommon"):playEffectSound("jchuapai/res/sound/effect/"..sex..value..".mp3")
end

return SoundUtils