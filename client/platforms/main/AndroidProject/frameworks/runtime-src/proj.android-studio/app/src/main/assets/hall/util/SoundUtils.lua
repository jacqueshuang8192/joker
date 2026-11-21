local SoundUtil = class("SoundUtil")


function SoundUtil:playHallBG()
--    for i = 1, 5 do 
--     local index = math.random(1,2)
--     dump(index)
--    end
    local index = math.random(1,2)
    HallBgm_filePath = select(index,"hall/scene/res/common/music/hall_1.mp3","hall/scene/res/common/music/hall_1.mp3")
    dump(index)
    audio.playMusic(HallBgm_filePath, true)
end


function SoundUtil:playBgmByType()
    local musicPath = cc.UserDefault:getInstance():getIntegerForKey("bgMusicType_0", 1)

    HallBgm_filePath = "hall/scene/res/common/music/AllBgMusic/hall_"..musicPath..".mp3"

    audio.playMusic(HallBgm_filePath, true)
end


return SoundUtil