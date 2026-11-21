local CSMJDefine = class("CSMJDefine")
dump("CSMJDefine888888888")
function CSMJDefine:ctor()
    dump("CSMJDefine")
    CARD_PLAYERTYPE_MY = 1
    CARD_PLAYERTYPE_LEFT = 2
    CARD_PLAYERTYPE_RIGHT = 3
    CARD_PLAYERTYPE_TOP = 4

    CARD_TYPE_INHAND = 1
    CARD_TYPE_OUTHAND = 2
    CARD_TYPE_LEFTHAND = 3

    CARD_DISPLAY_TYPE_OPPOSIVE = 1
    CARD_DISPLAY_TYPE_SHOW = 2
    CARD_DISPLAY_TYPE_HIDE = 3

    --胡类型
    HU_TYPE_H = 0x040
    HU_TYPE_GH = 0x080
    HU_TYPE_HH = 0x100
    HU_TYPE_ZM = 0x800
    HU_TYPE_QS = 0x2000



    --杠类型
    GANG_TYPE_PG = 0x010
    GANG_TYPE_HUA = 0x020
    GANG_TYPE_AN = 0x200
    GANG_TYPE_BU = 0x400

    --碰类型
    PENG_TYPE_P = 0x008

    --吃类型
    CHI_TYPE_RIGHT = 0x001
    CHI_TYPE_MIDDLE = 0x002
    CHI_TYPE_LEFT = 0x004

    --听
    TING_TYPE_T = 0x1000

    --界面操作类型

    --CONTROL_TYPE_HU = bit.bor(bit.bor(HU_TYPE_H,HU_TYPE_GH,HU_TYPE_HH,HU_TYPE_ZM),HU_TYPE_QS)  --其实这个没卵用 bit.bor

    CONTROL_TYPE_HU = bit.bor(bit.bor(bit.bor(HU_TYPE_H, HU_TYPE_GH), HU_TYPE_HH), HU_TYPE_ZM)
    
    CONTROL_TYPE_GANG = bit.bor(bit.bor(bit.bor(GANG_TYPE_PG, GANG_TYPE_HUA), GANG_TYPE_AN), GANG_TYPE_BU)
    CONTROL_TYPE_PENG = PENG_TYPE_P
    CONTROL_TYPE_CHI = bit.bor(bit.bor(CHI_TYPE_RIGHT, CHI_TYPE_MIDDLE), CHI_TYPE_LEFT)
    CONTROL_TYPE_TING = TING_TYPE_T
    CONTROL_TYPE_NONE = 0


    --撒杠的时候 吃牌用
    OPE_CHI_TYPE_TB = {CHI_TYPE_RIGHT, CHI_TYPE_MIDDLE, CHI_TYPE_LEFT}


    --胡牌类型
    CSMJ_HU_TYPE_TABLE = {"四喜",
                            "板板胡",
                            "三同", 
                            "节节高", 
                            "一枝花",
                            "缺一色", 
                            "六六顺",
                            "金童玉女",
                            "平胡", 
                            "天胡", 
                            "地胡",
                            "碰碰胡",
                            "将将胡", 
                            "清一色", 
                            "海底捞月", 
                            "海底炮",
                            "杠上开花",
                            "抢杠胡",
                            "杠上炮", 
                            "小七对",
                            "豪华七对",
                            "双豪华七对",
                            "全求人",
                            }


end

return CSMJDefine