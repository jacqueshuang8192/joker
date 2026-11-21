    --组合类型
    g_379 = {
        t_null = 0x00,--空
        t_sao_ex = 0x01,--扫穿 提
        t_wai = 0x02,--歪 起手2张或歪后摸同牌
        t_sao_bad = 0x03,--臭扫
        t_piao = 0x04,--飘 碰后摸同牌
        t_peng = 0x05,--碰
        t_chi = 0x06,--吃
        t_kan = 0x07,--坎
        t_liu = 0x08,--溜 起手四张或歪后摸同牌
    }
    g_379.OUT_CARD_LINE = 380 --出牌边界线      
    g_379.INVALID_WORD = 0xffff --无效数值
    g_379.INVALID_TABLE = 0xffff --无效桌子
    g_379.INVALID_CHAIR = 0xffff --无效椅子
    g_379.GAME_PLAYER = 3 --游戏人数
    g_379.GAME_NAME = "沅江鬼胡子" --游戏名字
    g_379.myViewId = 0
    g_379.leftViewId = 0
    g_379.rightViewId = 0
    g_379.NotChiCombuf = {}
