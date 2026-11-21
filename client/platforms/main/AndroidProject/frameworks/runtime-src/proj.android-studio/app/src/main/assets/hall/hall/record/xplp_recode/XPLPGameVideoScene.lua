local VoiceUtils = require("hall.record.xplp_recode.VoiceUtils")
local RecordBaseScene = require("hall.record.RecordBaseScene")

local Card = require("hall.record.xplp_recode.Card")

local USEFUL_MSG = {optMsg = {0x1031, 0x6008, 0x1101,0x1105,0x1103,0x1106},
                    userInfoMsg = 0x100D,
                    sendCardsMsg = 0x1100,
                }

local XPLPVideoScene = class("XPLPVideoScene", RecordBaseScene)

local IMAGE_SHOW_TYPE_HU = "hu"
local IMAGE_SHOW_TYPE_GANG = "gang"
local IMAGE_SHOW_TYPE_PENG = "peng"
local IMAGE_SHOW_TYPE_CHI = "chi"
local IMAGE_SHOW_TYPE_ZIMO = "zimo"
local IMAGE_SHOW_TYPE_TING = "ting"

--下面是针对闷胡血流的  协议的
local IMAG_SHOW_TYPE_MENHU = 500
local IMAG_SHOW_TYPE_CHONGFENG_JI = 300
local IMAG_SHOW_TYPE_CHONGFENG_WUGU_JI = 400
local IMAG_SHOW_TYPE_ZHEREN_JI = 100
local IMAG_SHOW_TYPE_ZHEREN_WUGU_JI = 200

--鸡牌数据 显示是什么鸡
local CHILD_NAME_CHONG_JI = "chong_jin"
local CHILD_NAME_CHONG_WU = "chong_wu"
local CHILD_NAME_ZE_WU = "ze_wu"
local CHILD_NAME_ZE_JI = "ze_jin"


local CHILD_NAME_LEFT_CHI_BT = "left_chi_bt"
local CHILD_NAME_MIDDLE_CHI_BT = "middle_chi_bt"
local CHILD_NAME_RIGHT_CHI_BT = "right_chi_bt"

CARD_PLAYERTYPE_MY = 1
CARD_PLAYERTYPE_LEFT = 2
CARD_PLAYERTYPE_RIGHT = 3
CARD_PLAYERTYPE_TOP = 4


local CHILD_NAME_EFFECT_LIGHT = "light"
local CHILD_NAME_EFFECT_1 = "effect_1"
local CHILD_NAME_EFFECT_2 = "effect_2"
local CHILD_NAME_EFFECT_3 = "effect_3"
    
function XPLPVideoScene:setDefine(level)
    if level == 391 then
        GameName = "溆浦老牌" 
    end
    G_game = {} --游戏内的全局变量 当游戏场景销毁时跟着销毁
    G_game.isLaiZi = function (m_value)--是否是癞子
        if G_game and type(G_game.laiziCount) == "number" and m_value then
            local tabs = {
                [1] = {65},
                [2] = {65,67},
            }
            local tab = tabs[G_game.laiziCount] or {}
            for i,v in ipairs(tab) do
                if m_value == v then
                    return true
                end
            end
        end
        return false
    end
end

function XPLPVideoScene:ctor(data, level)
    XPLPVideoScene.super.ctor(self, data, USEFUL_MSG, level, true)
    self.level = level
    self:setDefine(level)
    self:setNodeEventEnabled(true)
    self:_initMacroDefinition()
    --VoiceUtils:playBackgroundMusic()

    print("===========麻将的level打印！！！==============")


    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height

    self:bindMsgProc()
    self.bg_select_index = 1
    self._scene = cc.CSLoader:createNode("hall/res/record/xplp_record/XPLPGameVideoScene.csb"):addTo(self)
    GameUtils.setNodeNameBindObj(self._scene)
    display.doLayout(nil, self._scene.bg)

    local size = self._scene:getContentSize()
    DESIGN_SCREEN_WIDTH = size.width
    DESIGN_SCREEN_HEIGHT = size.height


    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getFrameSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getFrameSize().height

    local scaleY=SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT
    cc.Director:getInstance():getOpenGLView():setFrameSize(SCREEN_WIDTH, SCREEN_HEIGHT)
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(SCREEN_WIDTH/scaleY, DESIGN_SCREEN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc

	XPLP_SCENE = self._scene
    
    --设置背景的
    self:_initUI()

    --无操作
    self:setGameSetting()

    self:showBtnByUserStatus(false)
end

function XPLPVideoScene:_initMacroDefinition()
    dump("XPLPDefine")
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
    HU_TYPE_MEN_HU = 0x2000 --闷胡

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
    --CONTROL_TYPE_HU = bit.bor(bit.bor(bit.bor(HU_TYPE_H, HU_TYPE_GH), HU_TYPE_HH), HU_TYPE_ZM)
    
    CONTROL_TYPE_HU = bit.bor(bit.bor(bit.bor(HU_TYPE_H, HU_TYPE_GH), bit.bor(HU_TYPE_H, HU_TYPE_MEN_HU)), bit.bor(HU_TYPE_ZM, HU_TYPE_MEN_HU))
    CONTROL_TYPE_GANG = bit.bor(bit.bor(bit.bor(GANG_TYPE_PG, GANG_TYPE_HUA), GANG_TYPE_AN), GANG_TYPE_BU)
    CONTROL_TYPE_PENG = PENG_TYPE_P
    CONTROL_TYPE_CHI = bit.bor(bit.bor(CHI_TYPE_RIGHT, CHI_TYPE_MIDDLE), CHI_TYPE_LEFT)
    CONTROL_TYPE_TING = TING_TYPE_T
    CONTROL_TYPE_NONE = 0


    --胡牌类型
    XPLP_HU_TYPE_TABLE = {"胡牌", "天胡", "地胡", "混一色", "门清","清一色", "七对", "豪华七对", "双豪华七对", "三豪华七对", "杂幺九", "全幺九", "全风头", "坎坎", "十三幺", "十八罗汉", "碰碰", "海底"}


end

function XPLPVideoScene:bindMsgProc()
        self.func_ = {
            --展示所有用户
            [1001] = {handler(self, self.showAllUserInfo)},  --初始化玩家数据
            --发牌
            [1002] = {handler(self, self.showHandlerCards)}, --回放的发牌定义为 1001
            --当前抓牌用户广播
            [4354] = {handler(self, self.showCatchCard)},
            --广播用户出牌
            [4355] = {handler(self, self.showOutCard)},
            --广播用户进行了什么操作
            [4357] = {handler(self, self.showOptCard)}, 
        }

end

function XPLPVideoScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end
function XPLPVideoScene:_getScaleParam()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT

    return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function XPLPVideoScene:changeBgImg()
    if self.bg_select_index == 3 then
        self.bg_select_index = 1
    else
        self.bg_select_index = self.bg_select_index + 1
    end
    local bg = self._scene:getChildByName("bg")
    bg:setTexture(TpackageName.."/res/image/bg_"..self.bg_select_index..".png")
end

function XPLPVideoScene:_initUI()
    if self._scene then
        local bg = self._scene:getChildByName("Image_1")
        local precent = self:_getScaleParam2()
        if bg then
            bg:setScaleX(bg:getScale()*precent)
        end

        local root = self._scene
        if root then
            local child = root:getChildren()
            for i, v in ipairs( child or {} ) do
                local x = v:getPositionX()
                v:setPositionX(x*precent)
                if v:getDescription() == "ListView" then --容器按照比率重新设置大小
                    local size = v:getContentSize()
                    v:setContentSize(cc.size(size.width * precent, size.height))
                end
            end
        end

    end
end

function XPLPVideoScene:onEnter()
    self:initUIForVideo()
    self:loadVideoLayer()
    self:showInviteCode()
    self:initVideoScene()
end

function XPLPVideoScene:initUIForVideo()
    -- self._scene:getChildByName("hupai_vw"):setVisible(false)
    -- self._scene:getChildByName("hall"):setVisible(false)
    self._scene:getChildByName("zhama_vw"):setVisible(false)
    self._scene:getChildByName("players"):getChildByName("center_image"):setVisible(false)

    self:initPlayers()
end

function XPLPVideoScene:initPlayers()
    self._scene.my_card_plane = self._scene:getChildByName("players"):getChildByName("my_card_plane")
    self._scene.my_card_plane:setVisible(false)

    self._scene.right_card_plane = self._scene:getChildByName("players"):getChildByName("right_card_plane")
    self._scene.right_card_plane:setVisible(false)

    self._scene.top_card_plane = self._scene:getChildByName("players"):getChildByName("top_card_plane")
    self._scene.top_card_plane:setVisible(false)

    self._scene.left_card_plane = self._scene:getChildByName("players"):getChildByName("left_card_plane")
    self._scene.left_card_plane:setVisible(false)

    self._scene.my_card_plane:getChildByName("outhand_plane"):removeAllChildren()
    self._scene.right_card_plane:getChildByName("outhand_plane"):removeAllChildren()
    self._scene.top_card_plane:getChildByName("outhand_plane"):removeAllChildren()
    self._scene.left_card_plane:getChildByName("outhand_plane"):removeAllChildren()
end

function XPLPVideoScene:initPlayerPlane(playerPlane)
    playerPlane:setVisible(true)
    if playerPlane:getChildByName("ting_hu_plane") then
        playerPlane:getChildByName("ting_hu_plane"):setVisible(false)
    end
    if playerPlane:getChildByName("distance") then
        playerPlane:getChildByName("distance"):setVisible(false)
    end
    if playerPlane:getChildByName("jiapiao_plane") then
        playerPlane:getChildByName("jiapiao_plane"):setVisible(false)
    end
    playerPlane:getChildByName("player_plane"):getChildByName("zhuang_signal"):setVisible(false)
    playerPlane:getChildByName("ready_bar"):setVisible(false)
    playerPlane:getChildByName("piao_img"):setVisible(false)

    playerPlane:getChildByName("hua_plane"):setVisible(false)

    ---闷胡血流的鸡牌
    local player_plane = playerPlane:getChildByName("player_plane")
    player_plane:getChildByName("chong_jin"):setVisible(false)
    player_plane:getChildByName("chong_wu"):setVisible(false)
    player_plane:getChildByName("ze_jin"):setVisible(false)
    player_plane:getChildByName("ze_wu"):setVisible(false)   
end

function XPLPVideoScene:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
    self._videoOptLayer:setZOrder(10000)
    self._videoOptLayer:addTo(self._scene)
end

function XPLPVideoScene:initVideoScene()

    self:showAllUserInfo()
    self:showHandlerCards()
end

function XPLPVideoScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = XPLP_SEAT_TABLE[uid ]

    if seatId then
        --todo

        if XPLP_USERINFO_TABLE[seatId ] and XPLP_USERINFO_TABLE[seatId ].ip then
            --todo
            ip_ = XPLP_USERINFO_TABLE[seatId ].ip
        end
    end

    return ip_
end

function XPLPVideoScene:showLeaderLayer()

end

function XPLPVideoScene:ShowChatButton()

end

function XPLPVideoScene:showVoice()
end

function XPLPVideoScene:ShowRecordButton(flag)
    -- self._hall.btn_record:setVisible(flag)

    -- self._hall.btn_chat:setVisible(flag)

end

--获取用户播放录音位置
function XPLPVideoScene:getPosforSeat(uid)
    return XPLP_ROOM.positionTable[uid ]
end

--显示设置按钮（弃用）
function XPLPVideoScene:ShowSettingButton()

end


-------------------------游戏未开始前的解散房间和分享按钮------------------------
function XPLPVideoScene:hideCloseRoomButton()
end

function XPLPVideoScene:hideShareButton()
	-- local btn_share = self._hall:getChildByName("btn_share")
	-- btn_share:setVisible(false)
    -- 复制房间号按钮
    -- local btn_copyRoom = self._hall:getChildByName("btn_copyRoom")
    -- btn_copyRoom:setVisible(false)
end
----------------------------------------------------------------------------------
--解散房间
function XPLPVideoScene:disbandGroup()

end

--聊天
function XPLPVideoScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
end

function XPLPVideoScene:reConnect()
end

function XPLPVideoScene:showInviteCode()
    local invote_code = USER_INFO.invote_code or ""
    -- self._hall.room_lb:setString("房间号："..invote_code)
end

function XPLPVideoScene:hideInviteCode()
    -- self._hall.room_lb:setVisible(false)
end

function XPLPVideoScene:showCopyInviteBtn(isShow)
    -- if XPLP_ROUND and XPLP_ROUND >= 1 then
        isShow = false
    -- end
    -- 复制房间号按钮
    -- local btn_copyRoom = self._hall:getChildByName("btn_copyRoom")
    -- btn_copyRoom:setVisible(isShow)

    --邀请微信好友
    -- local btn_share = self._hall:getChildByName("btn_share")
    -- btn_share:setVisible(isShow)
    -- if isiOSVerify then
    --     btn_share:setVisible(false)
    --     btn_copyRoom:setVisible(false)
    -- end
end


function XPLPVideoScene:showBtnByUserStatus(_type)

    -- 准备按钮
    -- local btn_ready = self._hall:getChildByName("btn_ready")
    -- btn_ready:setVisible(false)
end

function XPLPVideoScene:showGameConfig(gameConfigtbl)
    local gameConfigStr = ""
	for k, v in pairs(gameConfigtbl) do
        if k == "pay_type" then
            if v == "fangka" then
                gameConfigStr = gameConfigStr .. "房主开房 "
            elseif v == "AA" then
                gameConfigStr = gameConfigStr .. "AA开房 "
            end
        -- elseif k == "hufa" then
        --     if v == 0 then
        --         gameConfigStr = gameConfigStr .. "可抢杠胡 "
        --     elseif v == 1 then
        --         gameConfigStr = gameConfigStr .. "自摸胡 "
        --     end
        elseif k == "laiziCount" then
            if v == 0 then
                gameConfigStr = gameConfigStr .. "无宝 "
            elseif v == 1 then
                gameConfigStr = gameConfigStr .. "红中做宝 "
            elseif v == 3 then
                gameConfigStr = gameConfigStr .. "双宝 "
            end
        elseif k == "zhuaniao" then
            if v == 2 then
                gameConfigStr = gameConfigStr .. "2码 "
            elseif v == 4 then
                gameConfigStr = gameConfigStr .. "4码 "
            elseif v == 6 then
				gameConfigStr = gameConfigStr .. "6码 "
			elseif v == 8 then
                gameConfigStr = gameConfigStr .. "8码 "
            elseif v == 999 then
				gameConfigStr = gameConfigStr .. "一码全中 "
			elseif v == 0 then
                gameConfigStr = gameConfigStr .. "无码 "
			end
		elseif k == "huPaiScore" then
            if v == 2 then
				gameConfigStr = gameConfigStr .. "2分起胡 "
			elseif v == 3 then
                gameConfigStr = gameConfigStr .. "3分起胡 "
            end
        elseif k == "tgTime" then
            if v == 0 then
                gameConfigStr = gameConfigStr .. "无托管 "
			end
        -- elseif k == "canPick" then
        --     local canPickStr= string.split(v, ",")
        --     for _, x in pairs(canPickStr) do
        --         if x == '0' then
        --             gameConfigStr = gameConfigStr .. "庄闲(算分) "
        --         elseif x == '1' then
        --             gameConfigStr = gameConfigStr .. "可胡七对 "
        --         elseif x == '2' then
        --             gameConfigStr = gameConfigStr .. "红中癞子 "
        --         end
        --     end
        end
	end
    USER_INFO["gameConfig"] = "玩法: "..gameConfigStr
    
    gameConfigTable = {{["游戏名"]=GameName, ["底分"] = BASE_CHIP}, {["特殊玩法"] = gameConfigStr}}
end


function XPLPVideoScene:setGameSetting()
end


function XPLPVideoScene:showGameSetting()

end
function XPLPVideoScene:addVoiceRecordEvent(btn_voice)
end
function XPLPVideoScene:disbandRoom()

end

function XPLPVideoScene:rejectDisband()

end

function XPLPVideoScene:agreeDisband()

end

function XPLPVideoScene:getToDisbandFuncs()

end

function XPLPVideoScene:loadMoreFuncLayer()

end

function XPLPVideoScene:loadGameMsgLayer()

end

function XPLPVideoScene:getToSendFaceAndTxtFuncs()
    local data = {}
    -- data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end
function XPLPVideoScene:quitRoom()
end

function XPLPVideoScene:sendFaceByIdx(id)
end

function XPLPVideoScene:sendEditTxt(str)
    print("sendEditMsg --------------------------", id)
end

function XPLPVideoScene:testJson()
    return "{\"base\":2,\"cards\":[\"49,1,6,25,52,9,1,41,51,50,33,1,2\",\"33,7,3,41,66,9,49,1,33,5,4,52,67\"],\"frame\":[{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":52,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":17,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":52,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":41,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":51,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":65,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":49,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":8,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":49,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":65,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":41,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":41,\"opeType\":0,\"operationBitset\":8,\"type\":4356,\"uid\":10030},{\"card\":41,\"opeType\":8,\"operationBitset\":0,\"type\":4357,\"uid\":10030},{\"card\":33,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":33,\"opeType\":0,\"operationBitset\":8,\"type\":4356,\"uid\":10031},{\"card\":33,\"opeType\":8,\"operationBitset\":0,\"type\":4357,\"uid\":10031},{\"card\":66,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":9,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":50,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":2,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":7,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":25,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":49,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":17,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":5,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":65,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":2,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":25,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":1,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":1,\"opeType\":0,\"operationBitset\":24,\"type\":4356,\"uid\":10030},{\"card\":1,\"opeType\":16,\"operationBitset\":0,\"type\":4357,\"uid\":10030},{\"card\":5,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":65,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":65,\"opeType\":0,\"operationBitset\":8,\"type\":4356,\"uid\":10031},{\"card\":65,\"opeType\":8,\"operationBitset\":0,\"type\":4357,\"uid\":10031},{\"card\":25,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":5,\"opeType\":0,\"operationBitset\":2048,\"type\":4354,\"uid\":10030},{\"card\":5,\"opeType\":2048,\"operationBitset\":0,\"type\":4357,\"uid\":10030}],\"gameTime\":\"1587784093\",\"niao_card\":\"25193281\",\"settlements\":[{\"anGangCount\":0,\"hu\":{\"huType\":2,\"winMoney\":3600,\"ziMo\":{\"card\":5,\"isGangShangHua\":0}},\"isFangPao\":0,\"isHu\":1,\"mingGangCount\":1,\"uid\":10030},{\"anGangCount\":0,\"isFangPao\":0,\"isHu\":0,\"mingGangCount\":0,\"uid\":10031}],\"userinfos\":[{\"nickName\":\"测试1号\",\"photoUrl\":\"http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132\",\"remainCoins\":2217600,\"score\":3600,\"uid\":10030},{\"nickName\":\"测试2号\",\"photoUrl\":\"http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132\",\"remainCoins\":5502300,\"score\":-3600,\"uid\":10031}],\"zhuang_id\":0}"
end

------------------------------------------------------------------------------------------------------------------------------------
-- proc msg begin
function XPLPVideoScene:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function XPLPVideoScene:getMySeatId(userLst)
    dump(USER_INFO, "USER_INFO == ")
    for i,v in ipairs(userLst or {}) do
        if USER_INFO["uid"] == v.uid then
            return i
        end
    end

    if #userLst > 0 then
        --local num = math.random(1,#userLst)
        --dump(num, 'num-----')
        return 1
    end

    return nil
end

function XPLPVideoScene:getViewIdBySeatId(sId)
    local mySeatId = self:getMySeatId(self._allUserInfoMsgs)
    if mySeatId == nil then return end

    if self._userSize == 2 then
        if sId == mySeatId then
            return 1
        else
            return 3
        end
    else
        if sId == mySeatId then
            return 1
        else
            return (sId - mySeatId + 4 )%4 + 1
        end
    end
end

function XPLPVideoScene:getPlayerPlaneByViewId(vId)
    if vId == 1 then
        return self._scene.my_card_plane:getChildByName("player_plane")
    elseif vId == 2 then
        return self._scene.right_card_plane:getChildByName("player_plane")
    elseif vId == 3 then
        return self._scene.top_card_plane:getChildByName("player_plane")
    elseif vId == 4 then
        return self._scene.left_card_plane:getChildByName("player_plane")
    end
    return nil
end

function XPLPVideoScene:getUserPlaneByViewId(vId)
    if vId == 1 then
        return self._scene.my_card_plane
    elseif vId == 2 then
        return self._scene.right_card_plane
    elseif vId == 3 then
        return self._scene.top_card_plane
    elseif vId == 4 then
        return self._scene.left_card_plane
    end
    return nil
end

function XPLPVideoScene:initUidToViewId(userLst)
    self._uidToViewId = {}
    self._viewIdHandCards = {}
    self._viewIdToCard = {[1] = 1, [2] = 3, [3] = 4, [4] = 2}
    self._optCards = {[1] = {}, [2] = {}, [3] = {}, [4] = {}} --
    self._optGroup  = {[1] = {}, [2] = {}, [3] = {}, [4] = {}} -- 操作后（吃、碰、杠）显示在外面的牌
    for i,v in ipairs(userLst or {}) do
        if v.uid then
            self._uidToViewId[v.uid] = self:getViewIdBySeatId(i)
        end
    end
end

--展示所有用户
function XPLPVideoScene:showAllUserInfo(msg)
    dump(msg,"showAllUserInfo->>>msg = ")
    self:initUidToViewId(self._allUserInfoMsgs)

    for i,v in ipairs(self._allUserInfoMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        local playerPlane = self:getPlayerPlaneByViewId(viewPos)
        local plane = self:getUserPlaneByViewId(viewPos)
        self:initPlayerPlane(plane)
        if playerPlane then
            local userInfo = clone(v)
            userInfo.coins = tonumber(v.remainCoins or "0")
            userInfo.sex = 0
            self:showInfo(userInfo, playerPlane)
        end
    end
end

function XPLPVideoScene:showInfo(userInfo, plane)
    print("showInfo ===================== ", plane == nil)
    if not plane then
        --todo
        return
    end

    plane:setVisible(true)

    local photoUrl = userInfo["photoUrl"]
    local nickname = userInfo["nick"]
    local coins = userInfo["coins"]

    local portrait = plane:getChildByName("portrait")
    local nick_lb = plane:getChildByName("nick_lb")
    local coins_lb = plane:getChildByName("coins_lb")

    local infos = {}
    infos["icon_url"] = photoUrl
    infos["uid"] = userInfo["uid"]
    infos["sex"] = userInfo["sex"]
    -- require("hall.GameCommon"):setPlayerHead(infos, portrait, 46)
    require("hall.GameCommon"):getUserHead(photoUrl, userInfo["uid"], userInfo["sex"], portrait, 64, false, nickname)
    

    nick_lb:setString(require("hall.GameCommon"):formatNick(nickname))

    -- require("hall.GameCommon"):formatLabelStr(nickname, nick_lb, nick_lb:getSize().width)
    -- coins_lb:setString(coins)
    self:updateUserCoins(plane, userInfo.coins)
    self:showNetworkImg(plane, false)
    return portrait
end

function XPLPVideoScene:updateUserCoins(plane, coins)
    if not plane then
        return
    end
    dump("------------------------1111")
    local coins_lb = plane:getChildByName("coins_lb")
    local coins_str = coins/100
    if coins_str > 100000 then
        --coins = math.floor(coins / 10000)
        dump(coins_str, "-------------2222")
        coins_str = string.format("%.1f", coins_str / 10000) .. "万"
    end
    dump(coins_str, "----------3333")
    coins_lb:setString(coins_str)
end

function XPLPVideoScene:showNetworkImg(plane, flag)
    local network_img = plane:getChildByName("network_img")

    if network_img then
        network_img:setVisible(flag)
    end
end

--发牌
function XPLPVideoScene:showHandlerCards(msg)
    for i,v in ipairs(self._allHandCardsMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        self:showHandCardsForView(viewPos, v)
    end
end

function XPLPVideoScene:showHandCardsForView(viewPos, cards)
    local sortCards = clone(cards)
    table.sort(sortCards)
    if viewPos == 1 then
        self:showMyHandCards(sortCards)
    elseif viewPos == 2 then
        self:showRightHandCards(sortCards)
    elseif viewPos == 3 then
        self:showTopHandCards(sortCards)
    elseif viewPos == 4 then
        self:showLeftHandCards(sortCards)
    end
end

function XPLPVideoScene:showMyHandCards(cards)
    dump(cards,"showMyHandCards==>>>")
    local cardContent = self._scene.my_card_plane:getChildByName("inhand_plane")
    cardContent:removeAllChildren()
    local panelSize = cardContent:getSize()
    self._viewIdHandCards[1] = cards

    local card = Card.new("")
    card:setCardForAll(1, 1)
    local scale = 0.6
    local cardWidth = card:getContentSize().width
    local cardHeight = card:getContentSize().height
    cardWidth = scale*cardWidth
    cardHeight = scale*cardHeight

    local oriX = panelSize.width - cardWidth
    local oriY = cardHeight*0.5

    if #cards > 17 then
        local interver = panelSize.width/#cards 

        for i,v in ipairs(cards) do
            local Card = Card.new("")
            Card:setCardForAll(1, cards[i])
            Card:setScale(scale)

            if Card then
                Card:setPosition(cc.p(interver*0.5 + (i-1)*interver, oriY))
                cardContent:addChild(Card)
            end    
        end

    else
        for i=#cards,1,-1 do
            local Card = Card.new("")
            Card:setCardForAll(1, cards[i])
            Card:setScale(scale)

            if Card then
                Card:setPosition(cc.p(oriX - (i-1)*cardWidth, oriY))
                cardContent:addChild(Card)
            end
        end

    end

    
end

function XPLPVideoScene:showRightHandCards(cards)
    local cardContent = self._scene.right_card_plane:getChildByName("inhand_plane")
    cardContent:removeAllChildren()

    self._viewIdHandCards[2] = cards
    local panelSize = cardContent:getSize()

    local card = Card.new("")
    card:setCardForAll(1, 1)
    local scale = 0.48

    local cardWidth = card:getContentSize().width
    local cardHeight = card:getContentSize().height
    cardWidth = scale*cardWidth
    cardHeight = scale*cardHeight

    local oriX = cardHeight*0.5
    local oriY = panelSize.height - cardWidth*0.5

    local offset = self:getHandCardsOffset(2)
    local cardNodes = {}


    if #cards > 17 then
        local interver = panelSize.height/#cards 

        for i,v in ipairs(cards or {}) do
            local Card = Card.new("")
            Card:setCardForAll(3, v)
            Card:setRotation(-90)
            Card:setScale(scale)
            if Card then
                Card:setPosition(cc.p(oriX, oriY - (i-1)*interver ))
                table.insert(cardNodes, Card)
                cardContent:addChild(Card)
            end
        end
    else
        for i,v in ipairs(cards or {}) do
            local Card = Card.new("")
            Card:setCardForAll(3, v)
            Card:setRotation(-90)
            Card:setScale(scale)
            if Card then
                Card:setPosition(cc.p(oriX, oriY - (i-1)*cardWidth ))
                table.insert(cardNodes, Card)
                cardContent:addChild(Card)
            end
        end
    end

end

function XPLPVideoScene:showTopHandCards(cards)
    local cardContent = self._scene.top_card_plane:getChildByName("inhand_plane")
    cardContent:removeAllChildren()
    local panelSize = cardContent:getSize()

    self._viewIdHandCards[3] = cards

    local card = Card.new("")
    card:setCardForAll(1, 1)
    local scale = 0.54

    local cardWidth = card:getContentSize().width
    local cardHeight = card:getContentSize().height
    cardWidth = scale*cardWidth
    cardHeight = scale*cardHeight

    local oriX = panelSize.width - cardWidth
    local oriY = cardHeight*0.5


    if #cards > 17 then
        local oriX = panelSize.width
        local interver = panelSize.width/#cards 
        for i=#cards,1,-1 do
            local Card = Card.new("")
            Card:setCardForAll(1, cards[i])
            Card:setScale(scale)

            if Card then
                Card:setPosition(cc.p(oriX - (i-1)*interver, oriY))
                cardContent:addChild(Card)
            end
        end

    else
        for i=#cards,1,-1 do
            local Card = Card.new("")
            Card:setCardForAll(1, cards[i])
            Card:setScale(scale)

            if Card then
                Card:setPosition(cc.p(oriX - (i-1)*cardWidth, oriY))
                cardContent:addChild(Card)
            end
        end    

    end


end

function XPLPVideoScene:showLeftHandCards(cards)
    local cardContent = self._scene.left_card_plane:getChildByName("inhand_plane")
    cardContent:removeAllChildren()
    local panelSize = cardContent:getSize()
    self._viewIdHandCards[4] = cards
    local offset = self:getHandCardsOffset(4)

    local card = Card.new("")
    card:setCardForAll(1, 1)
    local scale = 0.48

    local cardWidth = card:getContentSize().width
    local cardHeight = card:getContentSize().height
    cardWidth = scale*cardWidth
    cardHeight = scale*cardHeight

    local oriX = cardHeight*0.5
    local oriY = cardWidth*0.5

    if #cards > 17 then
        local interver = panelSize.height/#cards
        for i,v in ipairs(cards or {}) do
            local Card = Card.new("")
            Card:setCardForAll(2, v)
            Card:setRotation(90)
            Card:setScale(scale)
            if Card then
                Card:setPosition(cc.p(oriX, oriY+(i-1)*interver))
                cardContent:addChild(Card)
            end
        end
    else
        for i,v in ipairs(cards or {}) do
            local Card = Card.new("")
            Card:setCardForAll(2, v)
            Card:setRotation(90)
            Card:setScale(scale)
            if Card then
                Card:setPosition(cc.p(oriX, oriY+(i-1)*cardWidth))
                cardContent:addChild(Card)
            end
        end

    end
end

function XPLPVideoScene:getInhandPlane(viewPos)
    if viewPos == 1 then
        return self._scene.my_card_plane:getChildByName("inhand_plane")
    elseif viewPos == 2 then
        return self._scene.right_card_plane:getChildByName("inhand_plane")
    elseif viewPos == 3 then
        return self._scene.top_card_plane:getChildByName("inhand_plane")
    elseif viewPos == 4 then
        return self._scene.left_card_plane:getChildByName("inhand_plane")
    end
end

--当前抓牌用户广播
function XPLPVideoScene:showCatchCard(msg)

    dump(msg,"showCatchCard==>>>>")    
    local viewPos = self._uidToViewId[msg.uid]
    local pos = {754, 563.00, 578.00, 0}
    if viewPos then
        local Card = Card.new("")--Card:newOutCard(self._viewIdToCard[viewPos], msg.card)
        Card:setCardForAll(self._viewIdToCard[viewPos], msg.card, viewPos == 3)

        local cardContent = self:getInhandPlane(viewPos)

        local width = Card:getContentSize().width
        local height = Card:getContentSize().height
        local scale = 1

        if Card and cardContent then
            table.insert(self._viewIdHandCards[viewPos], msg.card)

            if #self._viewIdHandCards[viewPos] > 17 then
                --这里是guchou的数据了
                cardContent:addChild(Card)

                local tempCards = self._viewIdHandCards[viewPos]
                table.sort(tempCards)

                if viewPos == 1 then
                    self:showMyHandCards(tempCards)
                elseif viewPos == 2 then
                    self:showRightHandCards(tempCards)
                elseif viewPos == 3 then
                    self:showTopHandCards(tempCards)
                elseif viewPos == 4 then
                    self:showLeftHandCards(tempCards)
                end

            else
                if viewPos == 1 or viewPos == 3 then
                    if viewPos == 1 then
                        scale = 0.6
                        Card:setScale(scale)
                        Card:setPosition(cc.p(pos[viewPos] + 20, height*0.5*scale))
                    else
                        scale = 0.54
                        Card:setScale(scale)
                        Card:setPosition(cc.p(pos[viewPos] + 40, height*0.5*scale))
                    end
                else
                    scale = 0.48
                    Card:setScale(scale)
                    if viewPos == 2 then
                        Card:setRotation(-90)
                        Card:setPosition(cc.p(height*0.5*scale, pos[viewPos] + 40))
                    else
                        Card:setRotation(90)
                        Card:setPosition(cc.p(height*0.5*scale, pos[viewPos] - 40))
                    end
                end
                cardContent:addChild(Card)   
            end

        end
    end
end

--广播用户出牌
function XPLPVideoScene:showOutCard(msg)
    dump(msg,"msg===>>>>>")
    local viewPos = self._uidToViewId[msg.uid]
    self:showCardForOutPlane(viewPos, msg.card)

    for i,v in ipairs(self._viewIdHandCards[viewPos]) do
        if v == msg.card then
            table.remove(self._viewIdHandCards[viewPos], i)
            break
        end
    end

    self:reShowHandCards(viewPos)
end

function XPLPVideoScene:showCardForOutPlane(viewPos, card)

    local Card = Card:newOutCard(self._viewIdToCard[viewPos], card, viewPos == 3)
    if Card then
        --SoundMJ:playEffectCard(USER_INFO["sex"] or 1 ,card)
        VoiceUtils:playCardSound(USER_INFO["sex"] or 1, card) 
        if viewPos == 1 then
            self:showMyOutCards(Card)
        elseif viewPos == 2 then
            self:showRightOutCards(Card)
        elseif viewPos == 3 then
            self:showTopOutCards(Card)
        elseif viewPos == 4 then
            self:showLeftOutCards(Card)
        end
        self._lastOutCard = Card
    end
end

function XPLPVideoScene:showMyOutCards( Card )
    local outPlane = self._scene.my_card_plane:getChildByName("outhand_plane")
    local size = outPlane:getChildrenCount()

    local scale = 0.64
    local cardHeight = scale * 226
    local cardWidth = scale * 66

    local oriX = cardHeight / 2
    local oriY = cardWidth / 2

    local line = math.ceil((size+1)/20)
    local idx = math.mod(size, 20)

    local interver = 42

    Card:setRotation(-90)
    Card:setScale(scale)

    Card:setPosition(cc.p(idx*interver + oriX, (line-1)*cardWidth + oriY))

    outPlane:addChild(Card)
end

function XPLPVideoScene:showRightOutCards( Card )
    local outPlane = self._scene.right_card_plane:getChildByName("outhand_plane")
    local size = outPlane:getChildrenCount()
    local panelSize = outPlane:getSize()

    local scale = 0.5
    local cardHeight = scale * 226
    local cardWidth = scale * 66

    local oriX = panelSize.width - cardWidth / 2
    local oriY = panelSize.height - cardHeight / 2

    local interver = 42

    local line =  math.ceil((size+1)/10)
    local idx = math.mod(size, 10)

    Card:setPosition(cc.p(oriX - (line-1)*cardWidth, oriY - idx * interver))
    Card:setScale(scale)
    outPlane:addChild(Card)
end

function XPLPVideoScene:showTopOutCards( Card )
    local outPlane = self._scene.top_card_plane:getChildByName("outhand_plane")
    local size = outPlane:getChildrenCount()
    local panelSize = outPlane:getSize()

    local scale = 0.5
    local cardHeight = scale * 226
    local cardWidth = scale * 66

    local oriX = cardHeight / 2
    local oriY = panelSize.height - cardWidth / 2

    local interver = 42

    local line =  math.ceil((size+1)/10)
    local idx = math.mod(size, 10)
    Card:setPosition(cc.p(idx*interver + oriX,  oriY - (line-1)*cardWidth))
    Card:setRotation(-90)
    Card:setScale(scale)

    outPlane:addChild(Card)
end

function XPLPVideoScene:showLeftOutCards( Card )
    local outPlane = self._scene.left_card_plane:getChildByName("outhand_plane")
    local size = outPlane:getChildrenCount()
    local panelSize = outPlane:getSize()

    local scale = 0.5
    local cardHeight = scale * 226
    local cardWidth = scale * 66

    local oriX = cardWidth / 2
    local oriY = panelSize.height - cardHeight / 2

    local interver = 42

    local line =  math.ceil((size+1)/10)
    local idx = math.mod(size, 10)
    Card:setPosition(cc.p(oriX + (line-1)*cardWidth, oriY - idx * interver))
    Card:setScale(scale)
    outPlane:addChild(Card)
end

function XPLPVideoScene:reShowHandCards(viewPos)
    self:showHandCardsForView(viewPos, self._viewIdHandCards[viewPos])
end

--广播用户进行了什么操作
function XPLPVideoScene:showOptCard(msg)
    self:showOptAni(msg)
    if msg.opeType == 0x010 or msg.opeType == 0x020 or msg.opeType == 0x400 then -- 明 杠牌
        --[[SoundMJ:playEffectGang(USER_INFO["sex"] or 1)
        self:showMingGangCard(msg)--]]
    elseif msg.opeType == 0x200 then -- 暗杆
       --[[SoundMJ:playEffectGang(USER_INFO["sex"] or 1)
        self:showAnGangCard(msg)--]]
    elseif msg.opeType == 0x008 then -- 碰牌
        --SoundMJ:playEffectPeng(USER_INFO["sex"] or 1)
        --播放音效
        VoiceUtils:playControlSound(seatId, msg.opeType)
        self:showPenCard(msg)
    elseif msg.opeType == CHI_TYPE_RIGHT or msg.opeType == CHI_TYPE_MIDDLE or msg.opeType == CHI_TYPE_LEFT then -- 吃牌
        --SoundMJ:playEffectChi(USER_INFO["sex"] or 1)
        VoiceUtils:playControlSound(seatId, msg.opeType)
        self:showChiCard(msg)
    elseif msg.opeType == 0x800 then
        --SoundMJ:playEffectHu(USER_INFO["sex"] or 1)
        VoiceUtils:playControlSound(seatId, msg.opeType)
        self:showHuPai(msg)
   --[[ elseif msg.opeType == 0x2000 then
        --如果uid 和 fromuid 一样 就是自摸闷胡
        SoundMJ:playEffectMENHu(USER_INFO["sex"] or 1)
        self:showMenHu(msg)--]]
    end
end

--广播用户打了什么鸡
function XPLPVideoScene:showMHXLJI(msg)
    
    --头像边上显示标志
    dump(msg,"showMHXLJI")
    if msg.type > 0 then

        local viewPos = self._uidToViewId[msg.uid]
        local control_img = self:getUserPlaneByViewId(viewPos):getChildByName("control_img")
        control_img:removeAllChildren()

        local player_plane = self:getUserPlaneByViewId(viewPos):getChildByName("player_plane")

        if msg.type == 4368 then
            
            if msg.card == 24 then  --  冲锋乌骨鸡
                self:showImgByType(control_img,IMAG_SHOW_TYPE_CHONGFENG_WUGU_JI)
                player_plane:getChildByName(CHILD_NAME_CHONG_WU):setVisible(true)
            elseif msg.card == 33 then --冲锋鸡
                self:showImgByType(control_img,IMAG_SHOW_TYPE_CHONGFENG_JI)
                player_plane:getChildByName(CHILD_NAME_CHONG_JI):setVisible(true)
            end

        elseif msg.type == 4369 then

            if msg.card == 24 then  --  责任乌骨鸡
                self:showImgByType(control_img,IMAG_SHOW_TYPE_ZHEREN_WUGU_JI)
                player_plane:getChildByName(CHILD_NAME_ZE_WU):setVisible(true)
            elseif msg.card == 33 then --责任鸡
                self:showImgByType(control_img,IMAG_SHOW_TYPE_ZHEREN_JI)
                player_plane:getChildByName(CHILD_NAME_ZE_JI):setVisible(true)
            end

        end
    end

end

--广播闷胡
function XPLPVideoScene:showMenHu(msg)
    if not msg.fromUId or msg.fromUId < 0 then
        return
    end

    --显示闷胡的牌 
    local viewPos = self._uidToViewId[msg.uid]
    local plane = self:getUserPlaneByViewId(viewPos)
    local huaPlane = plane:getChildByName("hua_plane")
    self:playHuaCard(huaPlane,msg.card)


    --自摸的话  删掉摸到的牌
    if msg.fromUId == msg.uid then  --这是自摸
        for i,v in ipairs(self._viewIdHandCards[viewPos]) do
            if v == msg.card then
                table.remove(self._viewIdHandCards[viewPos], i)
                break
            end
        end
        self:reShowHandCards(viewPos)
    else
        --接炮的话  删掉fromid方位出的牌
        if self._lastOutCard then
            self._lastOutCard:removeFromParent()
        end
    end

end



function XPLPVideoScene:playHuaCard(plane,cardValue)

    plane:setVisible(true)

    local cardNode = Card.new("")
    cardNode:setCardForAll(1, cardValue, 1 == 3)

    local size = cardNode:getSize()

    local scale = (plane:getSize().height - 15) / size.height 

    local cardCount = plane:getChildrenCount()

    plane:addChild(cardNode)

    local x = 10 + (cardCount + 0.5) * (size.width * scale)
    local y = plane:getSize().height / 2 - 3
    
    cardNode:setScale(scale)
    cardNode:setPosition(cc.p(x, y))

    plane:setSize(cc.size((cardCount + 1) * size.width * scale + 20, plane:getSize().height))

    plane:setScale(1.5)
end


function XPLPVideoScene:showMingGangCard(msg)
    local viewPos = self._uidToViewId[msg.uid]
    local subHandlerCards = {}
    local surpCards = {}
    local cards = self._viewIdHandCards[viewPos]
    for i, v in ipairs(cards or {}) do
        if v == msg.card then
            table.insert(subHandlerCards, v)
        else
            table.insert(surpCards, v)
        end
    end

    if self._optCards[viewPos][msg.card] then --表示对这个对象操作过
        self:showBuGangGroup(viewPos, msg.card)
    else
        self._optCards[viewPos][msg.card] = true
        self._lastOutCard:removeFromParent()
        self:showGangGroup(viewPos, msg.card)

    end

    if #surpCards ~= #cards then
        self._viewIdHandCards[viewPos] = surpCards
        self:reShowHandCards(viewPos)
    end
end

-- 杠牌 最上面牌的偏移值
function XPLPVideoScene:getGangUpCardOffset(viewPos)
    local offsetX, offsetY = 0, 0
    if viewPos == 1 then
        offsetY = 10
    elseif viewPos == 2 then
        offsetX = -3
        offsetY = 5
    elseif viewPos == 3 then
        offsetY = -5
    elseif viewPos == 4 then
        offsetX = 3
        offsetY = 5
    end

    return offsetX, offsetY
end

function XPLPVideoScene:getOptGroupSize(viewPos)
    local result = 0
    for k,v in pairs(self._optGroup[viewPos]) do
        result = result + 1
    end

    return result
end

function XPLPVideoScene:getGroupPositionS(viewPos)
    --这是统计次数的
    local index = self:getOptGroupSize(viewPos)
    local posAr = {[1] = 0, [2] = 0, [3] = 0, [4] = 0}
    local result = {}

    local scale = 0.42
    local cardWidth = 66 * scale
    local cardHeight = 226 * scale
    index = index * 3

    for i = 1, 3 do
        local pos = {}
        if viewPos == 1 then
            pos.x = index*(cardWidth+5) + cardWidth*0.5 + (i-1)*cardWidth
            pos.y = cardHeight*0.5
        elseif viewPos == 2 then
            pos.x = cardHeight*0.5
            pos.y = index*(cardWidth+5) + cardWidth*0.5 + (i-1)*cardWidth
        elseif viewPos == 4 then
            pos.x = cardHeight*0.5
            pos.y = 100.00 - cardWidth*0.5 - (i-1)*cardWidth - (cardWidth+5)*index
        elseif viewPos == 3 then
            pos.x =index*(cardWidth+5) + cardWidth*0.5 + (i-1)*cardWidth
            pos.y = cardHeight*0.5
        end
        table.insert(result, pos)
    end

    return result
end

function XPLPVideoScene:getHandCardsOffset(viewPos)
    local size = self:getOptGroupSize(viewPos)
    local posAr = {[1] = 45, [2] = 27, [3] = 32, [4] = 27}
    local pos = {}

    if viewPos == 1 then
        pos.x = (posAr[viewPos]*3)*size + 20
        pos.y = 0
    elseif viewPos == 3 then
        pos.x = -1*((posAr[viewPos]*3)*size + 20)
        pos.y = 0
    elseif viewPos == 2 then
        pos.x = -21*size
        pos.y = (posAr[viewPos]*3)*size + 20
    elseif viewPos == 4 then
        pos.x = -21*size
        pos.y = -1*((posAr[viewPos]*3)*size + 20)
    end

    return pos
end

function XPLPVideoScene:getGroupPlane(viewPos)
    if viewPos == 1 then
        return self._scene.my_card_plane:getChildByName("lefthand_plane")
    elseif viewPos == 2 then
        return self._scene.right_card_plane:getChildByName("lefthand_plane")
    elseif viewPos == 3 then
        return self._scene.top_card_plane:getChildByName("lefthand_plane")
    elseif viewPos == 4 then
        return self._scene.left_card_plane:getChildByName("lefthand_plane")
    end
end

function XPLPVideoScene:showBuGangGroup(viewPos, card)
    local cardNode = self._optGroup[viewPos][card]
    if cardNode and (not tolua.isnull(cardNode)) then
        local groupPlane = self:getGroupPlane(viewPos)
        local Card = Card:newOutCard(self._viewIdToCard[viewPos], card)
        local position = cardNode:getPosition()
        local offsetX, offsetY = self:getGangUpCardOffset(viewPos)

        if Card then
            Card:setPosition(cc.p(position.x + offsetX, position.y + offsetY))
            groupPlane:addChild(Card)
        end
    end
end

function XPLPVideoScene:showGangGroup(viewPos, card)
    local posAr = self:getGroupPositionS(viewPos)
    local groupPlane = self:getGroupPlane(viewPos)
    for i, v in ipairs(posAr or {}) do
        local Card = Card:newPengOrGangCard(self._viewIdToCard[viewPos], card, viewPos == 3)
        if Card then
            Card:setPosition(cc.p(v.x, v.y))
            groupPlane:addChild(Card)
            if self._optGroup[viewPos][card] == nil then
                self._optGroup[viewPos][card] = Card
            end
            if viewPos == 2 then
                Card:setLocalZOrder(1000 - i)
            end
        end
    end

    local Card = Card:newPengOrGangCard(self._viewIdToCard[viewPos], card, viewPos == 3)--Card:newOutCard(self._viewIdToCard[viewPos], card)
    local offsetX, offsetY = self:getGangUpCardOffset(viewPos)
    if Card then
        Card:setPosition(cc.p(posAr[2].x + offsetX, posAr[2].y + offsetY))
        groupPlane:addChild(Card)
        if viewPos == 2 then
            Card:setLocalZOrder(1000)
        end
    end

end

function XPLPVideoScene:showAnGangCard(msg)
    local viewPos = self._uidToViewId[msg.uid]
    local subHandlerCards = {}
    local surpCards = {}
    local cards = self._viewIdHandCards[viewPos]
    for i, v in ipairs(cards or {}) do
        if v == msg.card then
            table.insert(subHandlerCards, v)
        else
            table.insert(surpCards, v)
        end
    end

    self._optCards[viewPos][msg.card] = true
    self:showAnGangGroup(viewPos, msg.card)

    if #surpCards ~= #cards then
        self._viewIdHandCards[viewPos] = surpCards
        self:reShowHandCards(viewPos)
    end
end

function XPLPVideoScene:showAnGangGroup(viewPos, card)
    local posAr = self:getGroupPositionS(viewPos)
    local groupPlane = self:getGroupPlane(viewPos)
    for i, v in ipairs(posAr or {}) do
        local Card = Card:newPengOrGangCard(self._viewIdToCard[viewPos], card, viewPos == 3)--Card:newOutCard(self._viewIdToCard[viewPos], card)
        if Card then
            local offset = 0
            if viewPos == 2 then
                offset = -2*i
                Card:setLocalZOrder(100-i)
            end
            Card:setPosition(cc.p(v.x + offset, v.y))
            
            groupPlane:addChild(Card)
            if self._optGroup[viewPos][card] == nil then
                self._optGroup[viewPos][card] = Card
            end
        end
    end

    local exchangeFor = {[1] = "down", [2] = "right", [3] = "up", [4] = "left"}
    local Card = Card:newPengOrGangCard(self._viewIdToCard[viewPos], card)
    Card:setAnGangCard(viewPos == 3)
    local offsetX, offsetY = self:getGangUpCardOffset(viewPos)
    if Card then
        Card:setPosition(cc.p(posAr[2].x + offsetX, posAr[2].y + offsetY))
        groupPlane:addChild(Card)

    end
end

function XPLPVideoScene:showPenCard(msg)
    local viewPos = self._uidToViewId[msg.uid]
    local subHandlerCards = {}
    local surpCards = {}
    local cards = self._viewIdHandCards[viewPos]

    --碰的话 只有两个 进入碰行列
    local index = 0
    for i, v in ipairs(cards or {}) do
        if v ~= msg.card or index >= 2 then
            table.insert(surpCards, v)
        else
            index = index + 1
        end
    end

    self._optCards[viewPos][msg.card] = true
    self:showPenGroup(viewPos, msg.card)

    if #surpCards ~= #cards then
        self._viewIdHandCards[viewPos] = surpCards
        self._lastOutCard:removeFromParent()

        self:reShowHandCards(viewPos)
    end
end

function XPLPVideoScene:showPenGroup(viewPos, card)
    local posAr = self:getGroupPositionS(viewPos)
    local groupPlane = self:getGroupPlane(viewPos)

    dump(posAr,"posAr===>>>")
    for i, v in ipairs(posAr or {}) do
        local Card = Card:newPengOrGangCard(self._viewIdToCard[viewPos], card, viewPos == 3)
        if Card then
            Card:setPosition(cc.p(v.x, v.y))
            Card:setScale(0.4)

            if viewPos == 2  then
                Card:setRotation(-90)
            elseif viewPos == 4 then
                Card:setRotation(90)
            end

            groupPlane:addChild(Card)

            if i == 2 then
                self._optGroup[viewPos][card] = Card
            end
        end
    end
end

function XPLPVideoScene:showChiCard(msg)
    local viewPos = self._uidToViewId[msg.uid]
    local subHandlerCards = {}
    local surpCards = {}
    local cards = self._viewIdHandCards[viewPos]
    local delCards = {[CHI_TYPE_RIGHT] = {[msg.card - 2] = true, [msg.card - 1] = true},
                        [CHI_TYPE_MIDDLE] = {[msg.card - 1] = true, [msg.card + 1] = true},
                        [CHI_TYPE_LEFT] = {[msg.card + 1] = true, [msg.card + 2] = true}
                    }
    for i, v in ipairs(cards or {}) do
        if msg.opeType == CHI_TYPE_RIGHT then
            if (v == (msg.card - 2) and delCards[CHI_TYPE_RIGHT][v])
              or (v == (msg.card - 1) and delCards[CHI_TYPE_RIGHT][v]) then
                delCards[CHI_TYPE_RIGHT][v] = false
                table.insert(subHandlerCards, v)
            else
                table.insert(surpCards, v)
            end

        elseif msg.opeType == CHI_TYPE_MIDDLE then
            if (v == (msg.card + 1) and delCards[CHI_TYPE_MIDDLE][v])
              or (v == (msg.card - 1) and delCards[CHI_TYPE_MIDDLE][v]) then
                delCards[CHI_TYPE_MIDDLE][v] = false
                table.insert(subHandlerCards, v)
            else
                table.insert(surpCards, v)
            end
        elseif msg.opeType == CHI_TYPE_LEFT then
            if (v == (msg.card + 2) and delCards[CHI_TYPE_LEFT][v])
              or (v == (msg.card + 1) and delCards[CHI_TYPE_LEFT][v]) then
                delCards[CHI_TYPE_LEFT][v] = false
                table.insert(subHandlerCards, v)
            else
                table.insert(surpCards, v)
            end
        end
    end

    self._optCards[viewPos][msg.card] = true
    self:showChiGroup(viewPos, msg.card, subHandlerCards)

    if #surpCards ~= #cards then
        self._viewIdHandCards[viewPos] = surpCards
        self._lastOutCard:removeFromParent()
        self:reShowHandCards(viewPos)
    end
end

function XPLPVideoScene:showChiGroup(viewPos, card, subHandCards)
    local cards = clone(subHandCards)
    table.insert(cards, card)
    table.sort(cards)

    local posAr = self:getGroupPositionS(viewPos)
    local groupPlane = self:getGroupPlane(viewPos)

    dump(viewPos,"viewPos==>>>>>")
    dump(posAr,"posAr===>>>>")

    for i, v in ipairs(posAr or {}) do
        local Card = Card:newPengOrGangCard(self._viewIdToCard[viewPos], cards[i], viewPos == 3)
        if Card then
            Card:setPosition(cc.p(v.x, v.y))
            Card:setScale(0.4)

            if viewPos == 2  then
                Card:setRotation(-90)
            elseif viewPos == 4 then
                Card:setRotation(90)
            end

            groupPlane:addChild(Card)

            if i == 2 then
                self._optGroup[viewPos][card] = Card
            end
        end
    end
end

function XPLPVideoScene:showHuPai(msg)
    --self:showOptAni(msg)
end

function XPLPVideoScene:showOptAni(msg)
    -- do return end
    local viewPos = self._uidToViewId[msg.uid]
    if not viewPos then
        return
    end
    local control_img = self:getUserPlaneByViewId(viewPos):getChildByName("control_img")
    self:showImage(control_img, msg.opeType)
end

function XPLPVideoScene:showImage(control_img, type)
    local img_type = ""
    print("showImage ------------------------- ", type)
    if bit.band(type, CONTROL_TYPE_HU) > 0 then
        img_type = IMAGE_SHOW_TYPE_HU
        if bit.band(type, HU_TYPE_ZM) > 0 then
            img_type = IMAGE_SHOW_TYPE_ZIMO     
        end

        if bit.band(type, HU_TYPE_MEN_HU) > 0 then
            img_type = IMAG_SHOW_TYPE_MENHU     
        end

    elseif bit.band(type, CONTROL_TYPE_TING) > 0 then
        --img_type = IMAGE_SHOW_TYPE_TING
    elseif bit.band(type, CONTROL_TYPE_GANG) > 0 then
        img_type = IMAGE_SHOW_TYPE_GANG
    elseif bit.band(type, CONTROL_TYPE_PENG) > 0 then
        img_type = IMAGE_SHOW_TYPE_PENG
    elseif bit.band(type, CONTROL_TYPE_CHI) > 0 then
        img_type = IMAGE_SHOW_TYPE_CHI
    end

    if img_type ~= "" then
        if img_type == IMAG_SHOW_TYPE_MENHU then  --针对闷胡的
            control_img:removeAllChildren()
            self:showImgByType(control_img,img_type)

        else
            control_img:removeAllChildren()
            local position = cc.p(control_img:getSize().width / 2, control_img:getSize().height / 2)
            control_img:show()

            local effectManage = ccs.ArmatureDataManager:getInstance()
            local name = "gang"
            local path = "hall/res/record/mjOptAni/"..name
            display.addSpriteFrames(path.."0.png", path.."0.plist")
            effectManage:addArmatureFileInfo(path.."0.png", path.."0.plist", path..".ExportJson");
            local Armature = ccs.Armature:create(name)
            Armature:addTo(control_img):setPosition(position)
            local anim = Armature:getAnimation()
            anim:playWithNames({img_type}, 0, false);
            local function handler1(Armature, MovementEventType, handlerName)
                if MovementEventType == ccs.MovementEventType.complete then
                    Armature:removeSelf()
                    dump(os.time(),"动画结束-----------")
                end
            end
            anim:setMovementEventCallFunc(handler1)

        end
        
    end

end


--为了不和打牌得动画混淆，重新加一个方法来播放冲锋鸡，冲锋乌骨鸡，责任鸡，责任乌骨鸡
function XPLPVideoScene:showImgByType(img,type)
    dump("showImgByType===")
    local img_type = type..""
    self:createImgByType(img,img_type)

    local light_img = img:getChildByName(CHILD_NAME_EFFECT_LIGHT)
    local effect_1_img = img:getChildByName(CHILD_NAME_EFFECT_1)
    local effect_2_img = img:getChildByName(CHILD_NAME_EFFECT_2)
    local effect_3_img = img:getChildByName(CHILD_NAME_EFFECT_3)

    img:setVisible(true)
    light_img:setVisible(true)
    effect_1_img:setVisible(false)
    effect_2_img:setVisible(false) 
    effect_3_img:setVisible(true)

    light_img:setOpacity(255 * 0.2)
    effect_3_img:setOpacity(255 * 0.3)
    light_img:setScale(0.8)
    effect_3_img:setScale(1)

    local scale_light = cc.ScaleTo:create(0.2, 1.1, 1.1, 1)
    local opacity_light = cc.FadeTo:create(0.2, 255 * 0.7)
    local scale_light_1 = cc.ScaleTo:create(0.1, 1, 1, 1)
    local opacity_light_1 = cc.FadeTo:create(0.1, 255 * 0.3)
    light_img:runAction(cc.Sequence:create(scale_light, cc.DelayTime:create(0.2), scale_light_1, cc.DelayTime:create(0.0), cc.FadeTo:create(1.2, 0)))
    light_img:runAction(cc.Sequence:create(opacity_light, cc.DelayTime:create(0.2), opacity_light_1, cc.DelayTime:create(0.0), cc.ScaleTo:create(1.2, 0.7, 0.7, 1)))

    local scale_3 = cc.ScaleTo:create(0.2, 1.2, 1.2, 1)
    local opacity_3 = cc.FadeTo:create(0.2, 255)
    local scale_3_1 = cc.ScaleTo:create(0.1, 1, 1, 1)
    local opacity_3_1 = cc.FadeTo:create(0.1, 255 * 0.3)
    effect_3_img:runAction(cc.Sequence:create(scale_3, cc.DelayTime:create(0.2), scale_3_1, cc.DelayTime:create(0.0), cc.FadeTo:create(1.2, 0)))
    effect_3_img:runAction(cc.Sequence:create(opacity_3, cc.DelayTime:create(0.2), opacity_3_1, cc.DelayTime:create(0.0), cc.ScaleTo:create(1.2, 0.7, 0.7, 1)))

    local callFunc_2 = cc.CallFunc:create(function()
            effect_2_img:setVisible(true)
            effect_2_img:setScale(0.8)
            effect_2_img:setOpacity(0)
        end)
    effect_2_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), callFunc_2, cc.FadeTo:create(0.1, 255 * 0.5), cc.FadeTo:create(1.2, 0)))
    effect_2_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.ScaleTo:create(1.2, 0.7, 0.7, 1)))

    local callFunc_1 = cc.CallFunc:create(function()
            effect_1_img:setVisible(true)
            effect_1_img:setScale(0.7)
            effect_1_img:setOpacity(0)
        end)

    effect_1_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), callFunc_1, cc.FadeTo:create(0.3, 255), cc.DelayTime:create(0.5), cc.FadeTo:create(0.5, 0)))

end


function XPLPVideoScene:createImgByType(img,img_type)
    img:setVisible(false)
    img:removeAllChildren()

    local position = cc.p(img:getSize().width / 2, img:getSize().height / 2)

    local light_img = ccui.ImageView:create()
    light_img:setPosition(position)
    light_img:setName(CHILD_NAME_EFFECT_LIGHT)
    img:addChild(light_img)

    local effect_3_img = ccui.ImageView:create()
    effect_3_img:setPosition(position)
    effect_3_img:setName(CHILD_NAME_EFFECT_3)
    img:addChild(effect_3_img)

    local effect_2_img = ccui.ImageView:create()
    effect_2_img:setPosition(position)
    effect_2_img:setName(CHILD_NAME_EFFECT_2)
    img:addChild(effect_2_img)

    local effect_1_img = ccui.ImageView:create()
    effect_1_img:setPosition(position)
    effect_1_img:setName(CHILD_NAME_EFFECT_1)
    img:addChild(effect_1_img)


    effect_1_img:loadTexture("hall/res/record/MJRecordImage/effect/effect_" .. img_type .. "3.png")
    effect_2_img:loadTexture("hall/res/record/MJRecordImage/effect/effect_" .. img_type .. "2.png")
    effect_3_img:loadTexture("hall/res/record/MJRecordImage/effect/effect_" .. img_type .. "1.png")
end

-------------------------------------------------------------------------------------------------------------------------------------

function XPLPVideoScene:onExit()
    dump("---------------退出快乐麻将")
    -- GamePlaneOperator:clearGameDatas()

    G_game = nil
    TpackageName = nil

end

return XPLPVideoScene