local SoundUtils = class("SoundUtils")
function SoundUtils:ctor()
end
local data = {
    ["停止下注"] = "tingzhixiazhu",
    ["开始下注"] = "kaishixiazhu",
    ["金币"] = "jinbi",
}
function SoundUtils:Sound(_type, seat)
    local d = data[_type]
    require("hall.GameCommon"):play2d("longhu100/res/mp3/"..d..".mp3")
end

return SoundUtils