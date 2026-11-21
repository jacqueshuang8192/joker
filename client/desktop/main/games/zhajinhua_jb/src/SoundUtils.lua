local SoundUtils = class("SoundUtils")
local rootSoundPath = "zhajinhua_jb/res/sounds/"
local card_kind_sound = {   
    [3] = "paiType1.mp3",--对子
    [4] = "paiType2.mp3",--顺子
    [5] = "paiType3.mp3",--同花
    [6] = "paiType4.mp3",--同花顺
    [7] = "paiType5.mp3",--豹子
    ["call"] = "call.mp3",--跟注
    ["cmp"] = "cmp.mp3",--比牌
    ["fold"] = "fold.mp3",--弃牌
    ["raise"] = "raise.mp3",--加注
    ["view"] = "view.mp3",--看牌
    ["yaman"] = "yaman.mp3",--看牌
}

local soundArr = {   
    ["send_card"] = "send_card.mp3",--发牌
    ["allin"] = "allin.mp3",--广播玩家allin
    ["login_gold"] = "login_gold.mp3",--回收筹码
    ["sound_jinbi"] = "sound_jinbi.mp3",--玩家扔出筹码
}

function SoundUtils:playCardKindEffect(cardKind, sex)
    local sex = sex or USER_INFO.sex
    sex = tonumber(sex)
    local sexPath = "man/" 
    if  sex == 1 then
        sexPath = "woman/" 
    end
    if (card_kind_sound[cardKind]) then
        local sound_path = rootSoundPath .. sexPath.. (card_kind_sound[cardKind] or "")
        print("sound_path",sound_path)
        require("hall.GameCommon"):playEffectSound(sound_path)
    end
end

function SoundUtils:playEffect(value)
    if soundArr[value] then
        local sound_path = rootSoundPath..soundArr[value]
        -- require("hall.GameCommon"):playEffectSound(sound_path)
        return audio.playSound(sound_path)
    end
end

function SoundUtils:playBackgroundMusic()
    local bgmPath = rootSoundPath .. "bg.mp3"
    audio.playMusic(bgmPath, true)
end

return SoundUtils