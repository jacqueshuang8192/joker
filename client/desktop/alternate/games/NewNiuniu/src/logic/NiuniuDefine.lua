
--[[
* author:   zwm
* date:     2020-09-19
* describe: 牛牛全局变量定义
--]]

local NiuniuDefine = class("NiuniuDefine")

function NiuniuDefine:ctor()
    self.GAME_TYPE = 1
    g_mainScene.GAME_STATUS_STOP = 0 --牌局已结束
    g_mainScene.GAME_STATUS_WAIT_START = 1 --倒计时开始阶段
    g_mainScene.GAME_STATUS_GRAB = 2 --等待用户抢庄
    g_mainScene.GAME_STATUS_TIMES = 3 --等待用户选择倍数
    g_mainScene.GAME_STATUS_OUTCARD = 4 --牌局进行中
    g_mainScene.GAME_STATUS_BANKER_OPT = 5 --庄

    self.CARDKIND_TONGHUASHUN = 19
    self.CARDKIND_SISHIDA = 18
    self.CARDKIND_WUXIAONIU = 17
    self.CARDKIND_SIZHA = 16
    self.CARDKIND_HULUNIU = 15
    self.CARDKIND_TONGHUANIU = 14
    self.CARDKIND_WUHUA = 13
    self.CARDKIND_SHUNZI = 12

    self.CARDTYPE_IMAGE_PATH = {
        [-1] = TpackageName .. '/csb/CardType/kanpai.png', --完成
        [0] = TpackageName .. '/csb/CardType/kaipai.png', --盖牌
        [1] = TpackageName .. '/csb/CardType/result_1.png', --无牛
        [2] = TpackageName .. '/csb/CardType/result_2.png', --牛一
        [3] = TpackageName .. '/csb/CardType/result_3.png',
        [4] = TpackageName .. '/csb/CardType/result_4.png',
        [5] = TpackageName .. '/csb/CardType/result_5.png',
        [6] = TpackageName .. '/csb/CardType/result_6.png',
        [7] = TpackageName .. '/csb/CardType/result_7.png',
        [8] = TpackageName .. '/csb/CardType/result_8.png',
        [9] = TpackageName .. '/csb/CardType/result_9.png',
        [10] = TpackageName .. '/csb/CardType/result_10.png',
         --牛九
        [11] = TpackageName .. '/csb/CardType/result_11.png',
         --牛牛
        [self.CARDKIND_SHUNZI] = TpackageName .. '/csb/CardType/result_12.png',
         -- 顺子牛
        [self.CARDKIND_WUHUA] = TpackageName .. '/csb/CardType/result_13.png',
         -- 五花牛
        [self.CARDKIND_TONGHUANIU] = TpackageName .. '/csb/CardType/result_14.png',
         -- 同花牛
        [self.CARDKIND_HULUNIU] = TpackageName .. '/csb/CardType/result_15.png',
         -- 葫芦牛
        [self.CARDKIND_SIZHA] = TpackageName .. '/csb/CardType/result_16.png',
         -- 四炸牛
        [self.CARDKIND_WUXIAONIU] = TpackageName .. '/csb/CardType/result_17.png',
         -- 五小牛
        [self.CARDKIND_SISHIDA] = TpackageName .. '/csb/CardType/result_18.png',
         -- 五小牛
        [self.CARDKIND_TONGHUASHUN] = TpackageName .. '/csb/CardType/result_19.png'
     -- 同花顺
    }
end

function NiuniuDefine:initLoginInfo(pack)
    MY_SEAT_ID = pack.seat_id --玩家自己本身座位
    g_mainScene.GAME_TYPE = pack.gameType

    g_mainScene.GAME_STATE = pack.table_status
    g_mainScene.BANKER_UID = pack.bank_uid
    self.TOTAL_PLAYERNUM = pack.maxPlyaerNum or TOTAL_PLAYERNUM

    self.BASE_CHIP = pack.base
    g_mainScene.gameConfig = json.decode(pack.gameConfig)
    
    self.myUserState = pack.user_status
    g_mainScene.bankerOptState = pack.bankerOptState
    g_mainScene.m_nGuoCount = pack.m_nGuoCount
end

function NiuniuDefine:clearGlobalData()

end

return NiuniuDefine