--
-- Author: zhanghongpeng
-- Date: 2017-06-06 15:40:10
--
local SoundUtils = class('SoundUtils')

local rootSoundPath = TpackageName .. '/sound/'

local sound_path_arr = {
    ['下注'] = rootSoundPath .. 'jiazhuchouma' .. '.mp3',
    ['发牌'] = rootSoundPath .. 'poker.mp3',
    ['翻牌'] = rootSoundPath .. 'fapai' .. math.random(1, 6) .. '.mp3',
    ['翻两张'] = rootSoundPath .. 'fapai_long.mp3',
    ['输'] = rootSoundPath .. 'lose_effect.mp3', --"compare_failure #1"..".mp3",
    ['赢'] = rootSoundPath .. 'win_effect.mp3', --"compare_victory #1"..".mp3",
    ['倒计时'] = rootSoundPath .. 'time' .. '.mp3',
    [8] = rootSoundPath .. 'dscj_arrive' .. '.mp3', --选庄声音
    ['随机特效'] = rootSoundPath .. 'dscj_zd' .. '.mp3',
    ['定庄特效'] = rootSoundPath .. 'dscj_win' .. '.mp3',
    ['gameStart'] = rootSoundPath .. 'game_start.mp3', --游戏开始声音
    ['click'] = rootSoundPath .. 'on_turn.mp3',
    ['dealCards'] = rootSoundPath .. 'poker.mp3',
    ['dealCards_short'] = rootSoundPath .. 'fapai1.mp3',
    ['coinfly_long'] = rootSoundPath .. 'coins_fly_in_long.mp3',
    ['coinfly_short'] = rootSoundPath .. 'coins_fly_in_short.mp3'
}
-- cc.FileUtils:getInstance():getWritablePath()
local bg_array = {
    [1] = rootSoundPath .. 'gamebg.mp3',
    [2] = rootSoundPath .. 'baccarat.mp3',
    [3] = rootSoundPath .. 'bgroom.mp3',
    [4] = rootSoundPath .. 'bg_hall.mp3'
}

local card_kind_sound = {
    [0] = '',
    [1] = 'f0_nn0.mp3', --无牛
    [2] = 'f0_nn1.mp3',
    [3] = 'f0_nn2.mp3',
    [4] = 'f0_nn3.mp3',
    [5] = 'f0_nn4.mp3',
    [6] = 'f0_nn5.mp3',
    [7] = 'f0_nn6.mp3',
    [8] = 'f0_nn7.mp3',
    [9] = 'f0_nn8.mp3',
    [10] = 'f0_nn9.mp3', --牛九
    [11] = 'f0_nn10.mp3', --牛牛
    [CARDKIND_SHUNZI] = 'f0_nn12.mp3', --顺子牛
    [CARDKIND_WUHUA] = 'f0_nn13.mp3', --五花牛
    [CARDKIND_TONGHUANIU] = 'f0_nn14.mp3', --同花牛
    [CARDKIND_HULUNIU] = 'f0_nn15.mp3', --葫芦牛
    [CARDKIND_SIZHA] = 'f0_nn16.mp3', --四炸
    [CARDKIND_WUXIAONIU] = 'f0_nn17.mp3',
     --五小牛
    ['qiangzhuang'] = 'qiangzhuang.mp3',
     --抢庄
    ['buqiang'] = 'buqiang.mp3',
     --不抢
    ['tuizhu'] = 'tuizhu.mp3'
 --推注
}

function SoundUtils:playEffect(sound_type, Strength)
    local sound_type = sound_type or ''
    local sound_path = sound_path_arr[sound_type]
    self:playEffectSound(sound_path)
end

function SoundUtils:playCardKindEffect(cardKind, sex)
    -- dump(debug.traceback(),"playCardKindEffect")

    local sex = sex or USER_INFO['sex']
    -- dump(sex,"playCardKindEffectsex")

    local sexPath = '/girl/'

    if sex == 1 then
        sexPath = '/boy/'
    end

    local sound_path = rootSoundPath .. sexPath .. (card_kind_sound[cardKind] or '')
    self:playEffectSound(sound_path)
end

function SoundUtils:playEffectSound(sound_path)
    -- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
    require('hall.GameCommon'):playEffectSound(sound_path)
end

function SoundUtils:playBackgroundMusic()
    math.randomseed(os.time())
    local randomIndex = math.random(1, #bg_array)
    local sound_path = bg_array[randomIndex]
    -- audio.playMusic(sound_path, true)
    cc.SimpleAudioEngine:getInstance():playMusic(sound_path, true)
end

function SoundUtils:playBgmByType()
    local musicPath = cc.UserDefault:getInstance():getIntegerForKey("bgMusicType_"..USER_INFO.level, 1)

    local sound_path = "hall/scene/res/common/music/AllBgMusic/pdk_"..musicPath..".mp3"

    cc.SimpleAudioEngine:getInstance():playMusic(sound_path, true)
end

return SoundUtils
