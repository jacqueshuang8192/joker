local NinetySixUtils = class("NinetySixUtils")
local GameCommon = require("hall.GameCommon")

function NinetySixUtils:ctor(ctrl)
    self.ctrl = ctrl
    self.logic = ctrl.logic
end

function NinetySixUtils:playCardVoice(card_color, card_value, sex)
    local sound_path = ""
    if sex == 1 then --男
        if card_color == 1 then --黑色
            sound_path = string.format("96game/res/sound/cards/M_2_%d.mp3", card_value)
        else
            sound_path = string.format("96game/res/sound/cards/M_1_%d.mp3", card_value)
        end
    else
        if card_color == 1 then --黑色
            sound_path = string.format("96game/res/sound/cards/F_2_%d.mp3", card_value)
        else
            sound_path = string.format("96game/res/sound/cards/F_1_%d.mp3", card_value)
        end
    end

    GameCommon:playEffectSound(sound_path)
    -- audio.playSound(sound_path, false)
end

function NinetySixUtils:playOptionVoice(option, sex)
    local cfg = self.logic.tOptStr[option]
    if cfg == nil then
        print("playOptionVoice error:", option)
        return
    end

    if cfg.voice == nil or cfg.voice == "" then
        print("skip playOptionVoice:", option)
        return
    end

    local sound_path = ""
    if sex == 1 then --男
        sound_path = string.format("96game/res/sound/option/M_%s.mp3", cfg.voice)
    else
        sound_path = string.format("96game/res/sound/option/F_%s.mp3", cfg.voice)
    end

    GameCommon:playEffectSound(sound_path)
    -- audio.playSound(sound_path, false)
end

function NinetySixUtils:playBackgroundMusic()
    local index = cc.UserDefault:getInstance():getIntegerForKey("CheckBox_Index", 1)
    local sound_path = nil
    --HallBgm_filePath
    if GameBG_fillePath then
        sound_path = GameBG_fillePath[index]
    end

    if not sound_path then
        sound_path = "96game/res/sound/misc/zipai_bg.mp3"
    end

    audio.playMusic(sound_path, true)
    -- self.soundbg = audio.playSound(res, true)
    -- audio.stopAllSounds()
end

function NinetySixUtils:playMiscVoice(name)
    local str = string.format("96game/res/sound/misc/%s.mp3", name)
    GameCommon:playEffectSound(str)
end

function NinetySixUtils:playOptionAni(option, parent)
    local cfg = self.logic.tOptStr[option]
    if cfg == nil then
        print("playOptionAni error:", option)
        return
    end

    if cfg.ani == nil or cfg.ani == "" then
        print("skip playOptionAni:", option)
        return
    end

    local tbl_names = {'peng', 'hu', 'shao', 'chi', 'tie'}
    local json = "96game/res/ani/zhanshi.ExportJson"
    local png = "96game/res/ani/zhanshi0.png"
    local plist = "96game/res/ani/zhanshi0.plist"
    local ani_name = cfg.ani
    local armature_name = cfg.ani

    if table.keyof(tbl_names, ani_name) then
        armature_name = "zhanshi"
    else
        local json_fmt = "96game/res/ani/%s/%s.ExportJson"
        local png_fmt = "96game/res/ani/%s/%s.png"
        local plist_fmt = "96game/res/ani/%s/%s.plist"

        json = string.format(json_fmt, ani_name, ani_name)
        png = string.format(png_fmt, ani_name, ani_name)
        plist = string.format(plist_fmt, ani_name, ani_name)
    end

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(png, plist, json)
    local armature = ccs.Armature:create(armature_name)
    -- armature:getAnimation():setSpeedScale(1)
    armature:getAnimation():play(ani_name, -1, 0)
    parent:addChild(armature)

    local function afterFunction()
        armature:removeFromParent()
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(json)
    end
    armature:getAnimation():setMovementEventCallFunc(afterFunction)
end

return NinetySixUtils
