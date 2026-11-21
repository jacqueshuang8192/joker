-- local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
-- local PROTOCOL = import(TpackageName..".handle.ZZMJProtocol")
-- local sendHandle = require(TpackageName..".handle.ZZMJSendHandle")
-- local receiveHandle = require(TpackageName..".handle.ZZMJReceiveHandle")

local SoundMJ = require("hall.record.SoundMJ")
local RecordBaseScene = require("hall.record.RecordBaseScene")
local Card = require("hall.2DMahjongCard.Card")

local USEFUL_MSG = {optMsg = {0x1031, 0x6008, 0x1101,0x1105,0x1103,0x1106},
                    userInfoMsg = 0x100D,
                    sendCardsMsg = 0x1100,
                }

local ZZMJVideoScene = class("ZZMJVideoScene", RecordBaseScene)

local IMAGE_SHOW_TYPE_HU = "hu"
local IMAGE_SHOW_TYPE_GANG = "gang"
local IMAGE_SHOW_TYPE_PENG = "peng"
local IMAGE_SHOW_TYPE_CHI = "chi"
local IMAGE_SHOW_TYPE_ZIMO = "zimo"
local IMAGE_SHOW_TYPE_TING = "ting"

--撮虾子的
local IMAGE_SHOW_TYPE_CHAOTIAN = "chaotian"
local IMAGE_SHOW_TYPE_LAI = "lai"

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


--撮虾子麻将的特殊处理 朝天牌 和 癞子皮
local CXZ_CHAOTIAN = 0
local CXZ_LAIZI = 0
local CXZ_OUT_CARD = 0 --本局麻将中 出到第几张牌  用来标识 癞子皮
local PLAYER_NUM = 0

    
function ZZMJVideoScene:setDefine(level)
    if level == 366 then
        GameName = "梅州红中宝" 
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

function ZZMJVideoScene:ctor(data, level)
    -- local data = self:testJson()
    ZZMJVideoScene.super.ctor(self, data, USEFUL_MSG, level, true)
    self.level = level
    self:setDefine(level)
    self:setNodeEventEnabled(true)
    self:_initMacroDefinition()
    -- D3_OPERATOR = require("hall.3DMahjongCard.ShowOperator")

    print("===========麻将的level打印！！！==============")


    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	-- bm.server:setProtocol(PROTOCOL)
 --    bm.server:setHandle(receiveHandle.new())
    self:bindMsgProc()
    self.bg_select_index = 1
    self._scene = cc.CSLoader:createNode("hall/res/record/MJGameVideoScene.csb"):addTo(self)
    GameUtils.setNodeNameBindObj(self._scene)
    display.doLayout(nil, self._scene.bg)
    -- display.doLayout(self._scene.players)
    -- display.doLayout(self._scene.hall)

    local size = self._scene:getContentSize()
    DESIGN_SCREEN_WIDTH = size.width
    DESIGN_SCREEN_HEIGHT = size.height
    -- SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    -- SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    -- self._scene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)

    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getFrameSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getFrameSize().height
    local scaleY=SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT
    cc.Director:getInstance():getOpenGLView():setFrameSize(SCREEN_WIDTH, SCREEN_HEIGHT)
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(SCREEN_WIDTH/scaleY, DESIGN_SCREEN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc

	ZZMJ_SCENE = self._scene
    -- self._hall = self._scene.hall
    
    self:_initUI()
    self:setGameSetting()


	-- ZZMJ_CONTROLLER = require(TpackageName..".GameController")
    
    -- D3_OPERATOR:init(ZZMJ_CONTROLLER,nil,nil,nil,ZZMJ_SCENE.players)
	-- GamePlaneOperator:init()
-- 
    -- local device_info_plane = self._hall:getChildByName("device_info_plane")


    -- local btn_gameConfigMsg = self._hall:getChildByName("btn_gameConfigMsg")

    -- btn_gameConfigMsg:onClick(function(sender,event)
        -- if isOpenControl then
        --     sendHandle:CLI_REQ_TEST_CARDS()
        -- else
            -- 玩法介绍同意风格
            -- require("hall.util.GameMenu"):showConfigPanel(gameConfigTable)
        -- end
    -- end)

    -- btn_ready:setVisible(false)
    self:showBtnByUserStatus(false)
end

function ZZMJVideoScene:_initMacroDefinition()
    dump("ZZMJDefine")
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


    -- local CARD_TRANSARRAY=
    -- {
    -- [1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,  --万
    -- [17]=17,[18]=18,[19]=19,[20]=20,[21]=21,[22]=22,[23]=23,[24]=24,[25]=25, --筒
    -- [33]=33,[34]=34,[35]=35,[36]=36,[37]=37,[38]=38,[39]=39,[40]=40,[41]=41, --条

    -- [49] = 67,[50] = 67,[65] = 65,[81] = 66,   --箭牌
    -- [97] = 49,[113] = 50,[129] = 51,[145] = 52} --风牌


    --界面操作类型
    --CONTROL_TYPE_HU = bit.bor(bit.bor(bit.bor(HU_TYPE_H, HU_TYPE_GH), HU_TYPE_HH), HU_TYPE_ZM)
    
    CONTROL_TYPE_HU = bit.bor(bit.bor(bit.bor(HU_TYPE_H, HU_TYPE_GH), bit.bor(HU_TYPE_H, HU_TYPE_MEN_HU)), bit.bor(HU_TYPE_ZM, HU_TYPE_MEN_HU))
    CONTROL_TYPE_GANG = bit.bor(bit.bor(bit.bor(GANG_TYPE_PG, GANG_TYPE_HUA), GANG_TYPE_AN), GANG_TYPE_BU)
    CONTROL_TYPE_PENG = PENG_TYPE_P
    CONTROL_TYPE_CHI = bit.bor(bit.bor(CHI_TYPE_RIGHT, CHI_TYPE_MIDDLE), CHI_TYPE_LEFT)
    CONTROL_TYPE_TING = TING_TYPE_T
    CONTROL_TYPE_NONE = 0


    --胡牌类型
    ZZMJ_HU_TYPE_TABLE = {"胡牌", "天胡", "地胡", "混一色", "门清","清一色", "七对", "豪华七对", "双豪华七对", "三豪华七对", "杂幺九", "全幺九", "全风头", "坎坎", "十三幺", "十八罗汉", "碰碰", "海底"}


end

function ZZMJVideoScene:bindMsgProc()
    if self.level == 308 or self.level == 387 or self.level == 329 or self.level == 370 or self.level == 399
        or self.level == 390 or self.level == 393  or self.level == 394 or self.level == 400 then
        self.func_ = {
            --展示所有用户
            [1001] = {handler(self, self.showAllUserInfo)},
            --发牌
            [1002] = {handler(self, self.showHandlerCards)}, --回放的发牌定义为 1001
            --当前抓牌用户广播
            [4354] = {handler(self, self.showCatchCard)},
            --广播用户出牌
            [4355] = {handler(self, self.showOutCard)},
            --广播用户进行了什么操作
            [4357] = {handler(self, self.showOptCard)}, 

            --结算界面
            [24584] = {handler(self, self.showResultInfo)}, 
        }
    elseif self.level == 348 then
        self.func_ = {
             --展示所有用户
            [1001] = {handler(self, self.showAllUserInfo)},
            --发牌
            [1002] = {handler(self, self.showHandlerCards)}, --回放的发牌定义为 1001
            --当前抓牌用户广播
            [4354] = {handler(self, self.showCatchCard)},
            --广播用户出牌
            [4355] = {handler(self, self.showOutCard)},  --玩家出牌
            --广播用户进行了什么操作
            [4357] = {handler(self, self.showOptCard)}, 

            --广播冲锋鸡 
            [4368] = {handler(self, self.showMHXLJI)}, 
            --广播责任鸡
            [4369] = {handler(self, self.showMHXLJI)},     
        }
        
    elseif self.level == 320 then
        self.func_ = {
            --展示所有用户
            [1001] = {handler(self, self.showAllUserInfo)},
            --发牌
            [1002] = {handler(self, self.showHandlerCards)}, --回放的发牌定义为 1001
            --当前抓牌用户广播
            [4357] = {handler(self, self.showCatchCard)},
            --广播用户出牌
            [4354] = {handler(self, self.showOutCard)},
            --广播用户进行了什么操作
            [4356] = {handler(self, self.showOptCard)},  
        }
    elseif self.level == 366 or self.level == 376 or self.level == 612 or self.level == 386 or self.level == 371 or self.level == 358 then
        self.func_ = {
           --展示所有用户
            [1001] = {handler(self, self.showAllUserInfo)},
            --发牌
            [1002] = {handler(self, self.showHandlerCards)}, --回放的发牌定义为 1001
            --当前抓牌用户广播
            [4354] = {handler(self, self.showCatchCard)},
            --广播用户出牌
            [4355] = {handler(self, self.showOutCard)},
            --广播用户进行了什么操作
            [4357] = {handler(self, self.showOptCard)},  
        }
    elseif self.level == 389 then   --戳虾子麻将
        self.func_ = {
            --展示所有用户
            [1001] = {handler(self, self.showAllUserInfo)},
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
    -- table.merge(self.func_, func_)
end

function ZZMJVideoScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end
function ZZMJVideoScene:_getScaleParam()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT

    return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function ZZMJVideoScene:changeBgImg()
    if self.bg_select_index == 3 then
        self.bg_select_index = 1
    else
        self.bg_select_index = self.bg_select_index + 1
    end
    local bg = self._scene:getChildByName("bg")
    bg:setTexture(TpackageName.."/res/image/bg_"..self.bg_select_index..".png")
    -- self.BG:setVisible(false)
end

function ZZMJVideoScene:_initUI()
    if self._scene then
        local bg = self._scene:getChildByName("Image_1")
        local precent = self:_getScaleParam2()
        if bg then
            bg:setScaleX(bg:getScale()*precent)
            -- local x = bg:getPositionX()
            -- bg:setPositionX(x*precent)
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

        local imgBg = self._scene:getChildByName("bg");
        if imgBg and (self.level == 376 or self.level == 612) then
            imgBg:loadTexture("hall/res/record/MJRecordImage/bg_2.png")
        end
    end
end

function ZZMJVideoScene:onEnter()
    -- local device_info_plane = self._hall:getChildByName("device_info_plane") 
    -- require("hall.util.GameMenu"):addMenu(nil,device_info_plane,GameName)
    self:initUIForVideo()
    self:loadVideoLayer()
    self:showInviteCode()
    self:initVideoScene()
end

function ZZMJVideoScene:initUIForVideo()
    -- self._scene:getChildByName("hupai_vw"):setVisible(false)
    -- self._scene:getChildByName("hall"):setVisible(false)
    self._scene:getChildByName("zhama_vw"):setVisible(false)
    
    self:initPlayers()
end

function ZZMJVideoScene:initPlayers()
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

function ZZMJVideoScene:initPlayerPlane(playerPlane)
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

function ZZMJVideoScene:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
    self._videoOptLayer:setZOrder(10000)
    self._videoOptLayer:addTo(self._scene)
end

function ZZMJVideoScene:initVideoScene()

    self:showAllUserInfo()
    self:showHandlerCards()
end

function ZZMJVideoScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = ZZMJ_SEAT_TABLE[uid ]

    if seatId then
        --todo

        if ZZMJ_USERINFO_TABLE[seatId ] and ZZMJ_USERINFO_TABLE[seatId ].ip then
            --todo
            ip_ = ZZMJ_USERINFO_TABLE[seatId ].ip
        end
    end

    return ip_
end

function ZZMJVideoScene:showLeaderLayer()

end

function ZZMJVideoScene:ShowChatButton()

end

function ZZMJVideoScene:showVoice()
end

function ZZMJVideoScene:ShowRecordButton(flag)
    -- self._hall.btn_record:setVisible(flag)

    -- self._hall.btn_chat:setVisible(flag)

end

--获取用户播放录音位置
function ZZMJVideoScene:getPosforSeat(uid)
    return ZZMJ_ROOM.positionTable[uid ]
end

--显示设置按钮（弃用）
function ZZMJVideoScene:ShowSettingButton()

end


-------------------------游戏未开始前的解散房间和分享按钮------------------------
function ZZMJVideoScene:hideCloseRoomButton()
end

function ZZMJVideoScene:hideShareButton()
	-- local btn_share = self._hall:getChildByName("btn_share")
	-- btn_share:setVisible(false)
    -- 复制房间号按钮
    -- local btn_copyRoom = self._hall:getChildByName("btn_copyRoom")
    -- btn_copyRoom:setVisible(false)
end
----------------------------------------------------------------------------------
--解散房间
function ZZMJVideoScene:disbandGroup()

end

--聊天
function ZZMJVideoScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
end

function ZZMJVideoScene:reConnect()
end

function ZZMJVideoScene:showInviteCode()
    local invote_code = USER_INFO.invote_code or ""
    -- self._hall.room_lb:setString("房间号："..invote_code)
end

function ZZMJVideoScene:hideInviteCode()
    -- self._hall.room_lb:setVisible(false)
end

function ZZMJVideoScene:showCopyInviteBtn(isShow)
    -- if ZZMJ_ROUND and ZZMJ_ROUND >= 1 then
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


function ZZMJVideoScene:showBtnByUserStatus(_type)

    -- 准备按钮
    -- local btn_ready = self._hall:getChildByName("btn_ready")
    -- btn_ready:setVisible(false)
end

function ZZMJVideoScene:showGameConfig(gameConfigtbl)
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


function ZZMJVideoScene:setGameSetting()
end


function ZZMJVideoScene:showGameSetting()

end
function ZZMJVideoScene:addVoiceRecordEvent(btn_voice)
end
function ZZMJVideoScene:disbandRoom()

end

function ZZMJVideoScene:rejectDisband()

end

function ZZMJVideoScene:agreeDisband()

end

function ZZMJVideoScene:getToDisbandFuncs()

end

function ZZMJVideoScene:loadMoreFuncLayer()

end

function ZZMJVideoScene:loadGameMsgLayer()

end

function ZZMJVideoScene:getToSendFaceAndTxtFuncs()
    local data = {}
    -- data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end
function ZZMJVideoScene:quitRoom()
end

function ZZMJVideoScene:sendFaceByIdx(id)
end

function ZZMJVideoScene:sendEditTxt(str)
    print("sendEditMsg --------------------------", id)
end

function ZZMJVideoScene:testJson()
    return "{\"base\":2,\"cards\":[\"49,1,6,25,52,9,1,41,51,50,33,1,2\",\"33,7,3,41,66,9,49,1,33,5,4,52,67\"],\"frame\":[{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":52,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":17,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":52,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":41,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":51,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":65,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":49,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":8,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":49,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":65,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":41,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":41,\"opeType\":0,\"operationBitset\":8,\"type\":4356,\"uid\":10030},{\"card\":41,\"opeType\":8,\"operationBitset\":0,\"type\":4357,\"uid\":10030},{\"card\":33,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":33,\"opeType\":0,\"operationBitset\":8,\"type\":4356,\"uid\":10031},{\"card\":33,\"opeType\":8,\"operationBitset\":0,\"type\":4357,\"uid\":10031},{\"card\":66,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":9,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":50,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":2,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":7,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":25,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":49,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":17,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":5,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":67,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":65,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":2,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":25,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10031},{\"card\":1,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":1,\"opeType\":0,\"operationBitset\":24,\"type\":4356,\"uid\":10030},{\"card\":1,\"opeType\":16,\"operationBitset\":0,\"type\":4357,\"uid\":10030},{\"card\":5,\"opeType\":0,\"operationBitset\":0,\"type\":4354,\"uid\":10030},{\"card\":65,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10030},{\"card\":65,\"opeType\":0,\"operationBitset\":8,\"type\":4356,\"uid\":10031},{\"card\":65,\"opeType\":8,\"operationBitset\":0,\"type\":4357,\"uid\":10031},{\"card\":25,\"opeType\":0,\"operationBitset\":0,\"type\":4355,\"uid\":10031},{\"card\":5,\"opeType\":0,\"operationBitset\":2048,\"type\":4354,\"uid\":10030},{\"card\":5,\"opeType\":2048,\"operationBitset\":0,\"type\":4357,\"uid\":10030}],\"gameTime\":\"1587784093\",\"niao_card\":\"25193281\",\"settlements\":[{\"anGangCount\":0,\"hu\":{\"huType\":2,\"winMoney\":3600,\"ziMo\":{\"card\":5,\"isGangShangHua\":0}},\"isFangPao\":0,\"isHu\":1,\"mingGangCount\":1,\"uid\":10030},{\"anGangCount\":0,\"isFangPao\":0,\"isHu\":0,\"mingGangCount\":0,\"uid\":10031}],\"userinfos\":[{\"nickName\":\"测试1号\",\"photoUrl\":\"http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132\",\"remainCoins\":2217600,\"score\":3600,\"uid\":10030},{\"nickName\":\"测试2号\",\"photoUrl\":\"http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132\",\"remainCoins\":5502300,\"score\":-3600,\"uid\":10031}],\"zhuang_id\":0}"
end

------------------------------------------------------------------------------------------------------------------------------------
-- proc msg begin
function ZZMJVideoScene:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function ZZMJVideoScene:getMySeatId(userLst)
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

function ZZMJVideoScene:getViewIdBySeatId(sId)
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

function ZZMJVideoScene:getPlayerPlaneByViewId(vId)
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

function ZZMJVideoScene:getUserPlaneByViewId(vId)
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

function ZZMJVideoScene:initUidToViewId(userLst)
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
function ZZMJVideoScene:showAllUserInfo(msg)

dump(msg, "showAllUserInfo msg== ")

    self:initUidToViewId(self._allUserInfoMsgs)
    PLAYER_NUM = #self._allUserInfoMsgs
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

function ZZMJVideoScene:showInfo(userInfo, plane)
    if not plane then
        --todo
        return
    end

    plane:setVisible(true)

    local photoUrl = userInfo["photoUrl"]
    local nickname = userInfo["nickName"]
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

function ZZMJVideoScene:updateUserCoins(plane, coins)
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

function ZZMJVideoScene:showNetworkImg(plane, flag)
    local network_img = plane:getChildByName("network_img")

    if network_img then
        network_img:setVisible(flag)
    end
end

--发牌
function ZZMJVideoScene:showHandlerCards(msg)
    for i,v in ipairs(self._allHandCardsMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        self:showHandCardsForView(viewPos, v)
    end
end

function ZZMJVideoScene:showHandCardsForView(viewPos, cards)
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

function ZZMJVideoScene:showMyHandCards(cards)
    local cardContent = self._scene.my_card_plane:getChildByName("inhand_plane")
    cardContent:removeAllChildren()
    self._viewIdHandCards[1] = cards
    local offset = self:getHandCardsOffset(1)
    for i,v in ipairs(cards or {}) do
        local Card = Card.new("")
        Card:setCardForAll(1, v)--Card:newOutCard(2, v)
        if Card then
            Card:setPosition(cc.p((i-1)*52 + 230 + offset.x , 30))
            cardContent:addChild(Card)

            if CXZ_CHAOTIAN > 0 and CXZ_LAIZI>0 then
                if v == CXZ_CHAOTIAN then
                    Card:showChaoTian()
                elseif v == CXZ_LAIZI  then
                    Card:showLaiZi()
                end
            end

        end
    end
end

function ZZMJVideoScene:showRightHandCards(cards)
    local cardContent = self._scene.right_card_plane:getChildByName("inhand_plane")
    cardContent:removeAllChildren()
    self._viewIdHandCards[2] = cards
    local offset = self:getHandCardsOffset(2)
    local cardNodes = {}
    for i,v in ipairs(cards or {}) do
        local Card = Card.new("")
        Card:setCardForAll(3, v)
        if Card then
            Card:setPosition(cc.p(80 - i*7 + offset.x, (i-1)*27 + offset.y))
            table.insert(cardNodes, Card)
            Card:setLocalZOrder(1000 - i)
            cardContent:addChild(Card)
            if CXZ_CHAOTIAN > 0 and CXZ_LAIZI>0 then
                if v == CXZ_CHAOTIAN then
                    Card:showChaoTian()
                elseif v == CXZ_LAIZI  then
                    Card:showLaiZi()
                end
            end

        end
    end
end

function ZZMJVideoScene:showTopHandCards(cards)
    local cardContent = self._scene.top_card_plane:getChildByName("inhand_plane")
    cardContent:removeAllChildren()
    self._viewIdHandCards[3] = cards
    local offset = self:getHandCardsOffset(3)
    for i,v in ipairs(cards or {}) do
        local Card = Card.new("")
        Card:setCardForAll(4, v, true)
        if Card then
            Card:setPosition(cc.p(510 - (i-1)*32 + offset.x, 20))
            cardContent:addChild(Card)
            if CXZ_CHAOTIAN > 0 and CXZ_LAIZI>0 then
                if v == CXZ_CHAOTIAN then
                    Card:showChaoTian()
                elseif v == CXZ_LAIZI  then
                    Card:showLaiZi()
                end
            end
        end
    end
end

function ZZMJVideoScene:showLeftHandCards(cards)
    local cardContent = self._scene.left_card_plane:getChildByName("inhand_plane")
    cardContent:removeAllChildren()
    self._viewIdHandCards[4] = cards
    local offset = self:getHandCardsOffset(4)
    for i,v in ipairs(cards or {}) do
        local card = Card.new("")
        card:setCardForAll(2, v)--Card:newOutCard(2, v)
        if card then
            card:setPosition(cc.p(120 - i*7 + offset.x, 400 - (i-1)*27 + offset.y))
            cardContent:addChild(card)
            if CXZ_CHAOTIAN > 0 and CXZ_LAIZI>0 then
                if v == CXZ_CHAOTIAN then
                    card:showChaoTian()
                elseif v == CXZ_LAIZI  then
                    card:showLaiZi()
                end
            end
        end
    end
end

function ZZMJVideoScene:getInhandPlane(viewPos)
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
function ZZMJVideoScene:showCatchCard(msg)
    local viewPos = self._uidToViewId[msg.uid]
    local pos = {980, 410, 30, 5}
    if viewPos then
        local Card = Card.new("")--Card:newOutCard(self._viewIdToCard[viewPos], msg.card)
        Card:setCardForAll(self._viewIdToCard[viewPos], msg.card, viewPos == 3)
        local cardContent = self:getInhandPlane(viewPos)
        if Card and cardContent then
            table.insert(self._viewIdHandCards[viewPos], msg.card)
            if viewPos == 1 or viewPos == 3 then
                if viewPos == 1 then
                    Card:setPosition(cc.p(pos[viewPos], 30))
                else
                    Card:setPosition(cc.p(pos[viewPos], 20))
                end
            else
                if viewPos == 2 then
                    Card:setPosition(cc.p(-25, (pos[viewPos])))
                else
                    Card:setPosition(cc.p(18, (pos[viewPos])))
                end
            end
            cardContent:addChild(Card)
        end
    end
end

--广播用户出牌
function ZZMJVideoScene:showOutCard(msg)
    local viewPos = self._uidToViewId[msg.uid]
    self:showCardForOutPlane(viewPos, msg.card)
    for i,v in ipairs(self._viewIdHandCards[viewPos]) do
        if v == msg.card then
            table.remove(self._viewIdHandCards[viewPos], i)
            break
        end
    end
    self:reShowHandCards(viewPos)

    CXZ_OUT_CARD = CXZ_OUT_CARD + 1

    if  CXZ_OUT_CARD == 1 and self.level == 389 then  --只有撮虾子有这个操作
        if msg.card > 0 then
            CXZ_CHAOTIAN = msg.card
            local value = bit.band(msg.card, 0xFF)
            if value == 9 then
                CXZ_LAIZI = msg.card - 8
            else
                CXZ_LAIZI = msg.card + 1
            end 
        end

        if CXZ_CHAOTIAN == 0 or CXZ_LAIZI == 0 then
            return
        end

        --刷新手牌样式
        if PLAYER_NUM >0 then
            for i=1,PLAYER_NUM do
                local cardContent = self:getInhandPlane(i)
                local childs = cardContent:getChildren()
                for i,v in ipairs(childs) do
                    dump(v,"v====")
                    if v.m_value == CXZ_CHAOTIAN then
                        v:showChaoTian()
                    elseif v.m_value == CXZ_LAIZI  then
                        v:showLaiZi()
                    end
                end
            end
        end


        --第一次还得刷新 第一个出牌的人的牌
        dump(self._lastOutCard.m_value,"self._lastOutCard.m_value ==>>")
        if self._lastOutCard.m_value == CXZ_CHAOTIAN then
            self._lastOutCard:showChaoTian()
        elseif self._lastOutCard.m_value == CXZ_LAIZI  then
            self._lastOutCard:showLaiZi()
        end
    end

end

function ZZMJVideoScene:showCardForOutPlane(viewPos, card)
    local Card = Card:newOutCard(self._viewIdToCard[viewPos], card, viewPos == 3)

    if Card then
        SoundMJ:playEffectCard(USER_INFO["sex"] or 1 ,card)
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

        if CXZ_CHAOTIAN > 0 and CXZ_LAIZI > 0 then
            if self._lastOutCard.m_value == CXZ_CHAOTIAN then
                self._lastOutCard:showChaoTian()
            elseif self._lastOutCard.m_value == CXZ_LAIZI  then
                self._lastOutCard:showLaiZi()
            end
        end
    end
end

function ZZMJVideoScene:showMyOutCards( Card )
    local outPlane = self._scene.my_card_plane:getChildByName("outhand_plane")
    local size = outPlane:getChildrenCount()
    local beginPos =  {x = 0, y = -15}
    local height = 40
    local width = 40
    local line = math.ceil((size+1)/8)
    local idx = math.mod(size, 8)
    Card:setPosition(cc.p((idx+1)*width + beginPos.x, (3-line + 1)*height + beginPos.y))
    outPlane:addChild(Card)
end

function ZZMJVideoScene:showRightOutCards( Card )
    local outPlane = self._scene.right_card_plane:getChildByName("outhand_plane")
    local size = outPlane:getChildrenCount()
    local beginPos =  {x = 20, y = 0}
    local height = 27
    local width = 46
    local line =  math.ceil((size+1)/7)
    local idx = math.mod(size, 7)
    Card:setPosition(cc.p((line-1)*width + beginPos.x - (idx*2), (idx+1)*height + beginPos.y))
    Card:setLocalZOrder(1000 - size)
    outPlane:addChild(Card)
end

function ZZMJVideoScene:showTopOutCards( Card )
    local outPlane = self._scene.top_card_plane:getChildByName("outhand_plane")
    local size = outPlane:getChildrenCount()
    local beginPos =  {x = 330, y = 18}
    local height = 35
    local width = 32
    local line =  math.ceil((size+1)/10)
    local idx = math.mod(size, 10)
    Card:setPosition(cc.p((idx+1)*(-1)*width + beginPos.x, (line-1)*height + beginPos.y))
    Card:setLocalZOrder(1000 - size)
    outPlane:addChild(Card)
end

function ZZMJVideoScene:showLeftOutCards( Card )
    local outPlane = self._scene.left_card_plane:getChildByName("outhand_plane")
    local size = outPlane:getChildrenCount()
    local beginPos =  {x = 190, y = 280}
    local height = 27
    local width = 46
    local line =  math.ceil((size+1)/7)
    local idx = math.mod(size, 7)
    Card:setPosition(cc.p((line-1)*(-1)*width + beginPos.x - idx*2, (idx+1)*(-1)*height + beginPos.y))
    outPlane:addChild(Card)
end

function ZZMJVideoScene:reShowHandCards(viewPos)
    self:showHandCardsForView(viewPos, self._viewIdHandCards[viewPos])
end

--广播用户进行了什么操作
function ZZMJVideoScene:showOptCard(msg)
    self:showOptAni(msg)
    if msg.opeType == 0x010 or msg.opeType == 0x020 or msg.opeType == 0x400 then -- 明 杠牌
        SoundMJ:playEffectGang(USER_INFO["sex"] or 1)
        self:showMingGangCard(msg)
    elseif msg.opeType == 0x200 then -- 暗杆
        SoundMJ:playEffectGang(USER_INFO["sex"] or 1)
        self:showAnGangCard(msg)
    elseif msg.opeType == 0x008 then -- 碰牌
        SoundMJ:playEffectPeng(USER_INFO["sex"] or 1)
        self:showPenCard(msg)
    elseif msg.opeType == CHI_TYPE_RIGHT or msg.opeType == CHI_TYPE_MIDDLE or msg.opeType == CHI_TYPE_LEFT then -- 吃牌
        SoundMJ:playEffectChi(USER_INFO["sex"] or 1)
        self:showChiCard(msg)
    elseif msg.opeType == 0x800 then
        SoundMJ:playEffectHu(USER_INFO["sex"] or 1)
        self:showHuPai(msg)
    elseif msg.opeType == 0x2000 then
        if self.level == 348 then
             --如果uid 和 fromuid 一样 就是自摸闷胡
            SoundMJ:playEffectMENHu(USER_INFO["sex"] or 1)
            self:showMenHu(msg)
        elseif self.level == 389 then  --戳瞎的 朝天碰
            self:showPenCard(msg)
        end
    elseif msg.opeType == 0x4000 then
        if self.level == 389 then  --戳瞎的 朝天杠
            self:showAnGangCard(msg)
        end
    end
end


--显示结算数据
function ZZMJVideoScene:showResultInfo(msg)
    dump(msg,"showResultInfo")
    if self.level == 329 then  --用自己的结算界面 因为每个游戏的结算数据不一样
        local pack = msg[1]
        if not pack then
            return
        end

        TpackageName = "gxlz_majiang_new"
        local GameResult = require("gxlz_majiang_new.view.GameResult").new(pack)
        GameResult:setName("GameResult")
        GameResult.btn_xipai:setVisible(false)
        GameResult.btn_jixu.id_0:setString("关闭")
        GameResult.btn_jixu:onClick(function()
            GameResult:hide()
            GameResult:removeSelf()
        end)

        self:addChild(GameResult)
    elseif  self.level == 394  then
        local pack = msg[1]
        if not pack then
            return
        end

        TpackageName = "gxhc_majiang"
        local GameResult = require("gxhc_majiang.view.GameResult").new(pack)
        GameResult:setName("GameResult")
        GameResult.btn_xipai:setVisible(false)
        GameResult.btn_jixu.id_0:setString("关闭")
        GameResult.btn_jixu:onClick(function()
            GameResult:hide()
            GameResult:removeSelf()
        end)

        self:addChild(GameResult)
    end
end

--广播用户打了什么鸡
function ZZMJVideoScene:showMHXLJI(msg)
    
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
function ZZMJVideoScene:showMenHu(msg)
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



function ZZMJVideoScene:playHuaCard(plane,cardValue)

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


function ZZMJVideoScene:showMingGangCard(msg)
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
function ZZMJVideoScene:getGangUpCardOffset(viewPos)
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

function ZZMJVideoScene:getOptGroupSize(viewPos)
    local result = 0
    for k,v in pairs(self._optGroup[viewPos]) do
        result = result + 1
    end

    return result
end

function ZZMJVideoScene:getGroupPositionS(viewPos)
    local size = self:getOptGroupSize(viewPos)
    local posAr = {[1] = 42, [2] = 27, [3] = 25, [4] = 24}
    local result = {}
    for i = 1, 3 do
        local pos = {}
        if viewPos == 1 then
            pos.x = (posAr[viewPos]*3 + 12)*size + (i - 1)*posAr[viewPos] + 25
            pos.y = 0
        elseif viewPos == 3 then
            pos.x = -1*((posAr[viewPos]*3 + 10)*size + (i - 1)*posAr[viewPos]) + 80
            pos.y = 30
        elseif viewPos == 2 then
            pos.x = - i*5 - size * (24) + 24
            pos.y = (posAr[viewPos]*3 + 24)*size + (i - 1)*posAr[viewPos]
        elseif viewPos == 4 then
            pos.x = 50 - i*6 - size * (24)
            pos.y = -1*((posAr[viewPos]*3 + 24)*size + (i - 1)*posAr[viewPos])+100
        end
        table.insert(result, pos)
    end

    return result
end

function ZZMJVideoScene:getHandCardsOffset(viewPos)
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

function ZZMJVideoScene:getGroupPlane(viewPos)
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

function ZZMJVideoScene:showBuGangGroup(viewPos, card)
    local cardNode = self._optGroup[viewPos][card]
    if cardNode and (not tolua.isnull(cardNode)) then
        local groupPlane = self:getGroupPlane(viewPos)
        local Card = Card:newOutCard(self._viewIdToCard[viewPos], card)
        local position = cardNode:getPosition()
        local offsetX, offsetY = self:getGangUpCardOffset(viewPos)

        if Card then
            Card:setPosition(cc.p(position.x + offsetX, position.y + offsetY))
            groupPlane:addChild(Card)

            if CXZ_CHAOTIAN > 0 and CXZ_LAIZI > 0 then
                if Card.m_value == CXZ_CHAOTIAN then
                    Card:showChaoTian()
                elseif Card.m_value == CXZ_LAIZI  then
                    Card:showLaiZi()
                end
            end
        end
    end
end

function ZZMJVideoScene:showGangGroup(viewPos, card)
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

        if CXZ_CHAOTIAN > 0 and CXZ_LAIZI > 0 then
            if Card.m_value == CXZ_CHAOTIAN then
                Card:showChaoTian()
            elseif Card.m_value == CXZ_LAIZI  then
                Card:showLaiZi()
            end
        end

        groupPlane:addChild(Card)
        if viewPos == 2 then
            Card:setLocalZOrder(1000)
        end
    end

end

function ZZMJVideoScene:showAnGangCard(msg)
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

function ZZMJVideoScene:showAnGangGroup(viewPos, card)
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
                
            if CXZ_CHAOTIAN > 0 and CXZ_LAIZI > 0 then
                if Card.m_value == CXZ_CHAOTIAN then
                    Card:showChaoTian()
                elseif Card.m_value == CXZ_LAIZI  then
                    Card:showLaiZi()
                end
            end

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

        if CXZ_CHAOTIAN > 0 and CXZ_LAIZI > 0 then
            if Card.m_value == CXZ_CHAOTIAN then
                Card:showChaoTian()
            elseif Card.m_value == CXZ_LAIZI  then
                Card:showLaiZi()
            end
        end

        Card:setPosition(cc.p(posAr[2].x + offsetX, posAr[2].y + offsetY))
        groupPlane:addChild(Card)

    end
end

function ZZMJVideoScene:showPenCard(msg)
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

function ZZMJVideoScene:showPenGroup(viewPos, card)
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

            if CXZ_CHAOTIAN > 0 and CXZ_LAIZI > 0 then
                if Card.m_value == CXZ_CHAOTIAN then
                    Card:showChaoTian()
                elseif Card.m_value == CXZ_LAIZI  then
                    Card:showLaiZi()
                end
            end

            Card:setPosition(cc.p(v.x + offset, v.y))
            groupPlane:addChild(Card)
            if i == 2 then
                self._optGroup[viewPos][card] = Card
            end
        end
    end
end

function ZZMJVideoScene:showChiCard(msg)
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

function ZZMJVideoScene:showChiGroup(viewPos, card, subHandCards)
    local cards = clone(subHandCards)
    table.insert(cards, card)
    table.sort(cards)

    local posAr = self:getGroupPositionS(viewPos)
    local groupPlane = self:getGroupPlane(viewPos)
    for i, v in ipairs(posAr or {}) do
        local Card = Card:newPengOrGangCard(self._viewIdToCard[viewPos], cards[i], viewPos == 3)
        if Card then

            if CXZ_CHAOTIAN > 0 and CXZ_LAIZI > 0 then
                if Card.m_value == CXZ_CHAOTIAN then
                    Card:showChaoTian()
                elseif Card.m_value == CXZ_LAIZI  then
                    Card:showLaiZi()
                end
            end

            Card:setPosition(cc.p(v.x, v.y))
            groupPlane:addChild(Card)
            if i == 2 then
                self._optGroup[viewPos][card] = Card
            end
        end
    end
end

function ZZMJVideoScene:showHuPai(msg)
    --self:showOptAni(msg)
end

function ZZMJVideoScene:showOptAni(msg)
    -- do return end
    local viewPos = self._uidToViewId[msg.uid]
    local control_img = self:getUserPlaneByViewId(viewPos):getChildByName("control_img")
    self:showImage(control_img, msg.opeType)
end

function ZZMJVideoScene:showImage(control_img, type)
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


    if self.level == 389 then
        --戳虾子的特殊处理
        if type  == 0x2000  then
            img_type = IMAGE_SHOW_TYPE_CHAOTIAN
        elseif type  == 0x4000 then
            img_type = IMAGE_SHOW_TYPE_CHAOTIAN
        end
    end


    if img_type ~= "" then
        if img_type == IMAG_SHOW_TYPE_MENHU and self.level == 348 then  --针对闷胡的
            control_img:removeAllChildren()
            self:showImgByType(control_img,img_type)

        else
            control_img:removeAllChildren()
            local position = cc.p(control_img:getSize().width / 2, control_img:getSize().height / 2)
            control_img:show()

            local effectManage = ccs.ArmatureDataManager:getInstance()
            local name = "gang"
            local path = "hall/res/record/mjOptAni/"..name

            if self.level == 389 then
                path = "hall/res/record/mjOptAni/cxz/"..name
            end

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
function ZZMJVideoScene:showImgByType(img,type)
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


function ZZMJVideoScene:createImgByType(img,img_type)
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

function ZZMJVideoScene:onExit()
    dump("---------------退出快乐麻将")
    -- GamePlaneOperator:clearGameDatas()
    G_game = nil
    TpackageName = nil


    --撮虾子麻将的特殊处理 朝天牌 和 癞子皮
    CXZ_CHAOTIAN = 0
    CXZ_LAIZI = 0
    CXZ_OUT_CARD = 0 --本局麻将中 出到第几张牌  用来标识 癞子皮
    PLAYER_NUM = 0

end

return ZZMJVideoScene