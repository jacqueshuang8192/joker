local NiuNiuGameScene = class("NiuNiuGameScene",function()
    return display.newScene("NiuNiuGameScene")
end)
local NiuNiuProtocol = import(TpackageName .. ".handle.NiuNiuProtocol")
local NiuNiuReceiveHandle = import(TpackageName .. ".handle.NiuNiuReceiveHandle")
-- local dump = function ( ... )
--     -- body
-- end
function NiuNiuGameScene:initData(_type)

    if _type == "init" then
        -----------------------------------------游戏相关信息-------------------------------------
        -- if  device.platform == "windows" then
        --     isShowErrorScene = true
        -- end

        --牛牛包名
        TpackageName = "shuiyu"

        ControlType_WinPercent = 1
        ControlType_ChooseCard = 2

        CONTROLTYPE = ControlType_WinPercent

        MAX_PLAYERNUM = 12   --前端支持的最大人数
        TOTAL_PLAYERNUM = tonumber(USER_INFO["player_nums"]) or 12  --当前模式的最大人数（7，9，12）
        dump(tonumber(USER_INFO["player_nums"]),"TOTAL_PLAYERNUM")
        PLAYERNUM = 0    --当前在玩的游戏人数

        GAME_NAME = "三加一"
        GAME_VERSION = "1.1.0"

        GAME_TYPE = 1
        GAME_TYPE_NAME = "三加一"

        DESIGN_SCREEN_WIDTH  = 1920
        DESIGN_SCREEN_HEIGHT = 1080

        SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
        SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height

        GLOBAL_SCALE = DESIGN_SCREEN_WIDTH/SCREEN_WIDTH

        --add by zzy 2019-7-6
        GLOBAL_SCALE_Y = DESIGN_SCREEN_HEIGHT/SCREEN_HEIGHT

        HAS_OUTCARD = true   --是否带摊牌效果
        HAS_CUOPAI = true   --是否带搓牌效果

        --旧框架/金币场标记  1为旧框架，2为金币场
        GROUP_MODE = 2
        APPLE_APP_VERSION = 2   --1 为旧IOS包

        -- HAS_BET_MODE = true  --是否带外围模式

        BET_MODE = false  --是否为外围模式

        NiuNiuSendHandle = import(TpackageName .. ".handle.NiuNiuSendHandle")

        NiuNiuUtils = require(TpackageName..".NiuNiuUtils")

        -- TABLE_IMG = TpackageName .. "/images/pieces_card/card_back.png"

        CURRENTCARDBACKINDEX = cc.UserDefault:getInstance():getIntegerForKey("CBStyleIndex",1)
        -----------------------------------------房间相关信息--------------------------------------
        GAME_CONFIG = { ["五花牛"] = true,
                        ["五小牛"] = false,
                        ["四炸"] = false,
                        ["同花牛"] = false,
                        ["顺子牛"] = false,
                        ["葫芦牛"] = false,
                        ["允许搓牌"] = false,
                        ["买牛"] = false,
                        ["无花牛牛"] = false,
                    }

        NIUNIU_CARDTYPE_TABLE = {}
        -----------------------------------------玩家相关信息-------------------------------------
        -- --add by zzy 玩家当前选择的弃牌Index
        -- GAME_CURRENT_QIPAI_INDEX = 0

		--玩家头像
		PLAYER_HEADS_TABLE ={}
		--玩家头像位置
		PLAYER_HEADS_POSITION_TABLE ={}

        --座位表（服务器座位）
        NIUNIU_SEAT_TABLE = {}  --key = uid
        --add by zzy
        NIUNIU_OLD_SEAT_TABLE = {}

        --座位表（服务器座位）
        NIUNIU_UID_TABLE = {}  --key = seat_id

        --玩家类型表（前端座位）
        NIUNIU_PLAYERTYPE_TABLE = {}   --key = uid

        NIUNIU_PLAYERTYPE_TABLE_BYSEAT = {} --key = seatId
        --玩家信息表
        NIUNIU_USERINFO_TABLE = {} --key = uid

        -------------------------------------游戏过程相关信息-------------------------------------
        USERS_READY_STATE = {}

        HAS_RECEIVE_GROUP_RESULT = false

        LIANGCARDNUM = 0
        BETCOUNT = 1

        CHECK_WAIWEI_RESULT_ABLE = false

        Tid = -1
        WAIWEI_BET_LIMIT = 1000000
        WAIWEI_BET_CHIPS = {}

        SINGLE_BET_CHIP = {}   --押注者的下注总数

        MY_BET_CHIP =  {}   --我在每个座位上押的注 key是被押注者的UID
        TOTAL_BET_CHIP = {}  --每个座位上被押注的总量 key是被押注者的UID

        FIRSTSENDCARD = true
        GAME_PARTICIPANTS = {}
        MY_SEAT_ID = 0
        RELATIVE_SEAT_ID = 0
        BANKER_UID = 0
        MY_CARDS = {}
        BONUS_POOL_COINS = 0  --奖池

        BASE_CHIP = 5
        GAME_STATE = 1
		GROUP_RECORD = {}
        NIUNIUKIND = {}   --记录玩家牌型
        NIUNIU_OUTCARDS = {}   --记录玩家出牌
        isGoldGame = 0
        USED_CARDS = {}  --发过的牌

        GAME_ROUND = 1
        GAME_TOTAL_ROUND = 8

        RANDOM_BANKER = {}
        initialChip = 20000

        IS_AUTO_PLAY = 0

        CARD_DATAS = {} --记录发下来的所有牌

        HAS_OPEN_CARD_UIDS = {}  --已经开过牌的用户列表

        EMPTY_TABLE = {[1] = 0, [2] = 0, [3] = 0}
        ------------------------------------------宏定义-------------------------------------------
        CARDKIND_SISHIDA = 18
        CARDKIND_WUXIAONIU = 17
        CARDKIND_SIZHA = 16
        CARDKIND_HULUNIU = 15
        CARDKIND_TONGHUANIU = 14
        CARDKIND_WUHUA = 13
        CARDKIND_SHUNZI = 12

        CARDTYPE_IMAGE_PATH =
        {
            [-1] = TpackageName .. "/images/kanpai.png",  --完成
            [0] = TpackageName .. "/images/kaipai.png",   --盖牌
            [1] = TpackageName .. "/images/result_1.png", --无牛
            [2] = TpackageName .. "/images/result_2.png",  --牛一
            [3] = TpackageName .. "/images/result_3.png",
            [4] = TpackageName .. "/images/result_4.png",
            [5] = TpackageName .. "/images/result_5.png",
            [6] = TpackageName .. "/images/result_6.png",
            [7] = TpackageName .. "/images/result_7.png",
            [8] = TpackageName .. "/images/result_8.png",
            [9] = TpackageName .. "/images/result_9.png",
            [10] = TpackageName .. "/images/result_10.png",--牛九
            [11] = TpackageName .. "/images/result_11.png",--牛牛
            [CARDKIND_SHUNZI] = TpackageName .. "/images/result_12.png",-- 顺子牛
            [CARDKIND_WUHUA] = TpackageName .. "/images/result_13.png",-- 五花牛
            [CARDKIND_TONGHUANIU] = TpackageName .. "/images/result_14.png",-- 同花牛
            [CARDKIND_HULUNIU] = TpackageName .. "/images/result_15.png",-- 葫芦牛
            [CARDKIND_SIZHA] = TpackageName .. "/images/result_16.png",-- 四炸牛
            [CARDKIND_WUXIAONIU] = TpackageName .. "/images/result_17.png",-- 五小牛
            [CARDKIND_SISHIDA] = TpackageName .. "/images/result_19.png",-- 五小牛
        }


        GAME_STATUS_STOP = 0       --牌局已结束
        GAME_STATUS_WAIT_START = 1         --倒计时开始阶段
        GAME_STATUS_GRAB = 2      --等待用户抢庄
        GAME_STATUS_TIMES = 3      --等待用户选择倍数
        GAME_STATUS_OUTCARD = 4       --牌局进行中

        --顺时针排列
        CARD_PLAYERTYPE_MY = 1

        CARD_PLAYERTYPE_LEFT1 = 2
        CARD_PLAYERTYPE_LEFT2 = 3
        CARD_PLAYERTYPE_LEFT3 = 4

        CARD_PLAYERTYPE_TOP1 = 5
        CARD_PLAYERTYPE_TOP2 = 6
        CARD_PLAYERTYPE_TOP3 = 7

        CARD_PLAYERTYPE_RIGHT1 = 8
        CARD_PLAYERTYPE_RIGHT2 = 9
        CARD_PLAYERTYPE_RIGHT3 = 10

        SoundUtils = import(TpackageName .. ".SoundUtils")

    elseif _type == "clearGameData" then

        EMPTY_TABLE = {[1] = 0, [2] = 0, [3] = 0}
        NIUNIU_OUTCARDS = {}

        MY_BET_CHIP = {}
        SINGLE_BET_CHIP = {}
        TOTAL_BET_CHIP = {}

    elseif _type == "release" then

        GAME_TYPE = nil
        NiuNiuUtils = nil
        HAS_RECEIVE_GROUP_RESULT = nil
        NIUNIU_UID_TABLE = nil
        NIUNIU_CARDTYPE_TABLE = nil
        Tid = nil
        WAIWEI_BET_LIMIT = nil
        WAIWEI_BET_CHIPS = nil
        SINGLE_BET_CHIP = nil
        TOTAL_BET_CHIP = nil
        BET_MODE = nil
        EMPTY_TABLE = nil
        RELATIVE_SEAT_ID = nil
        TpackageName = nil
        TOTAL_PLAYERNUM = nil
        GAME_NAME = nil
        GAME_VERSION = nil
        GAME_TYPE_NAME = nil
        DESIGN_SCREEN_WIDTH = nil
        DESIGN_SCREEN_HEIGHT = nil
        SCREEN_WIDTH = nil
        SCREEN_HEIGHT = nil
        GLOBAL_SCALE = nil

        --add by zzy 2019-7-6
        GLOBAL_SCALE_Y = nil

        HAS_OUTCARD = nil
        HAS_CUOPAI = nil
        NiuNiuSendHandle = nil
        SoundUtils = nil
        GROUP_MODE = nil
        GAME_CONFIG = nil
        PLAYER_HEADS_TABLE = nil
        PLAYER_HEADS_POSITION_TABLE = nil
        NIUNIU_SEAT_TABLE = nil

        --add by zzy 
        NIUNIU_OLD_SEAT_TABLE = nil


        NIUNIU_PLAYERTYPE_TABLE = nil
        NIUNIU_PLAYERTYPE_TABLE_BYSEAT = nil
        NIUNIU_USERINFO_TABLE = nil
        USERS_READY_STATE = nil
        FIRSTSENDCARD = nil
        MY_SEAT_ID = nil
        BANKER_UID = nil
        MY_CARDS = nil
        GAME_STATE = nil
        GROUP_RECORD = nil
        NIUNIUKIND = nil
        NIUNIU_OUTCARDS = nil
        GAME_ROUND = nil
        GAME_TOTAL_ROUND = nil
        RANDOM_BANKER = nil
        GAME_PARTICIPANTS = nil
        IS_AUTO_PLAY = nil
        BONUS_POOL_COINS = nil
        BETCOUNT = nil
        initialChip = nil
        isGoldGame = nil

        CARDKIND_WUXIAONIU = nil
        CARDKIND_SIZHA = nil
        CARDKIND_HULUNIU = nil
        CARDKIND_TONGHUANIU = nil
        CARDKIND_WUHUA = nil
        CARDKIND_SHUNZI = nil

        CARD_PLAYERTYPE_MY  = nil
        CARD_PLAYERTYPE_LEFT1 = nil
        CARD_PLAYERTYPE_LEFT2 = nil
        CARD_PLAYERTYPE_LEFT3 = nil
        CARD_PLAYERTYPE_TOP1 = nil
        CARD_PLAYERTYPE_TOP2 = nil
        CARD_PLAYERTYPE_TOP3 = nil
        CARD_PLAYERTYPE_RIGHT1 = nil
        CARD_PLAYERTYPE_RIGHT2 = nil
        CARD_PLAYERTYPE_RIGHT3 = nil

        NIUNIU_GAME_SCENE = nil

        GAME_STATUS_STOP = nil       --牌局已结束
        GAME_STATUS_GRAB = nil       --等待用户抢庄
        GAME_STATUS_TIMES = nil      --等待用户选择倍数
        GAME_STATUS_OUTCARD = nil      --牌局进行中

        CARDTYPE_IMAGE_PATH = nil

        GamePlaneOperator = nil

        dump(collectgarbage("count"),"检测退出时内存占用")
        collectgarbage("collect")

    end

end

-- function NiuNiuGameScene:ctor()

--[[void GameScene::SaveFiles()
{
    //加载plist文件到缓存
    SpriteFrameCache::getInstance():addSpriteFrames("fish.plist");

    std::stringstream ss;
    std::string filename;

    //遍历序列帧图片
    for (int i=0; i<10; i++)
    {
        ss.clear();
        ss.str("");
        ss << "fish_" << (i + 1) << ".png";
        filename = ss.str();

        //获取精灵
        local sprite = Sprite::createWithSpriteFrameName(filename);
        sprite:setAnchorPoint(Vec2::ZERO);
        local width = sprite:getContentSize().width;
        local height = sprite:getContentSize().height;

        //创建渲染纹理
        local render = RenderTexture::create(width, height, Texture2D::PixelFormat::RGBA8888)
        render:setSprite(sprite)

        //填充纹理
        render:beginWithClear(0, 0, 0, 0)
        sprite:visit()
        render:end()

        //文件被保存在类似于C:\Users\Administrator\AppData\Local\ProjectName的路径中
        render:saveToFile(filename, Image::Format::PNG);
    end

    //从缓存移除plist文件
    SpriteFrameCache::getInstance():removeSpriteFramesFromFile("fish.plist");
end
]]

-- end

function NiuNiuGameScene:ctor()

	-- cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1920, 1080, cc.ResolutionPolicy.SHOW_ALL)
    self:initData("init")

    -- local _insepect = require(TpackageName .. '.inspect_lua_master.inspect')

    -- print(_insepect.inspect({1,2,3,4}))


    --设置协议和协议处理
    bm.server:setProtocol(NiuNiuProtocol)
    bm.server:setHandle(NiuNiuReceiveHandle.new())

    self._scene = cc.CSLoader:createNode(TpackageName.."/csb/GameSixPlusOne.csb"):addTo(self)

    NIUNIU_GAME_SCENE = self._scene:getChildByName("game_plane")

    self._scene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
    -- self._scene:setScaleX(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)

    -- local allChildren = NIUNIU_GAME_SCENE:getChildren() 
    -- for k,v in pairs(allChildren) do
    --     local posY = v:getPositionY()
    --     v:setPositionY(posY*SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
    -- end

    GamePlaneOperator = require(TpackageName .. ".operator.GamePlaneOperator")
    GamePlaneOperator:init()

    --添加牛牛版本号显示
    local lbVersion = cc.Label:createWithTTF(GAME_VERSION,TpackageName.."/font/fzcs.ttf",22)
    lbVersion:setColor(cc.c3b(125, 125, 125))
    lbVersion:setPosition(cc.p(DESIGN_SCREEN_WIDTH - lbVersion:getContentSize().width / 2 -10, lbVersion:getContentSize().height/2))
    self._scene:addChild(lbVersion, 1000)

    --文字聊天界面
    local faceUI_node = require("hall.FaceUI.faceUI").new()
    faceUI_node:setHandle(NiuNiuSendHandle)
    self:addChild(faceUI_node, 9999)
    faceUI_node:setName("faceUI")
    
    local hall_plane = self._scene:getChildByName("hall_plane")
    local btn_gameConfigMsg = hall_plane:getChildByName("btn_gameConfigMsg"):setVisible(false)
    local btn_gameRecord = hall_plane:getChildByName("gameRecord")

    if  btn_gameRecord then
        btn_gameRecord:setVisible(true)

        btn_gameRecord:addTouchEventListener(function(sender,event)

            if event == TOUCH_EVENT_ENDED then
                require("hall.scene.result.GameRecord"):addView(SCENENOW["scene"],GROUP_RECORD,"poker",GAME_ROUND)
            end
        end)

    end

    local control_plane = NIUNIU_GAME_SCENE:getChildByName("control_plane")
    local btn_copy_room_id = control_plane:getChildByName("btn_copy_room_id"):setVisible(false)


    local this = self

    --设置
    local btn_setting = hall_plane:getChildByName("btn_setting")
    btn_setting:addTouchEventListener(
        function(sender,event)

            --触摸结束
            if event == TOUCH_EVENT_ENDED then

                local quitRoom_action = function(sender,event)

                    --触摸开始
                    if event == TOUCH_EVENT_BEGAN then
                        sender:setScale(0.9)
                    end

                    --触摸取消
                    if event == TOUCH_EVENT_CANCELED then
                        sender:setScale(1.0)
                    end

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then
                        sender:setScale(1.0)

                        --by add zzy 2019-7-6
                        -- this:showGameSetting()


                        require("hall.GameCommon"):showSettings(false)
                        self:quitRoom()
                    end

                end


                if  isGoldGame == 0 or isGoldGame == 2 then

                    -- local CardBackSwitchFunc = GamePlaneOperator.swtichCardBackImg
                    -- local BGSwitchFunc = self.switchBackGroundImg

                    -- if  require("hall.scene.setting.settingScene").showSceneForCustom then
                    --     local CardBackImages = require(TpackageName .. ".PokerCard"):getCardBackAndSizeTable()

                    --     local BGImages = {
                    --                 TpackageName .. "/images/background_img.png",
                    --                 TpackageName .. "/images/background_img_1.png",
                    --                 TpackageName .. "/images/background_img_2.png",
                    --             }

                    --     -- if isControl then
                    --     --     BGImages = {
                    --     --             TpackageName .. "/images/background_img_old.png",
                    --     --             TpackageName .. "/images/background_img_1_old.png",
                    --     --         }
                    --     -- end

                    --     require("hall.scene.setting.settingScene"):showSceneForCustom(true, false, true, true, quitRoom_action,"退出房间",nil,nil,
                    --         CardBackSwitchFunc,BGSwitchFunc,CardBackImages,BGImages)
                    -- else

                        --add by zzy
                        this:showGameSetting()

                        -- require("hall.GameCommon"):showSettings(true, false, true, true, quitRoom_action,"退出房间")
                    -- end


                else

                    local disband_action = function(sender,event)

                        --触摸开始
                        if event == TOUCH_EVENT_BEGAN then
                            sender:setScale(0.9)
                        end

                        --触摸取消
                        if event == TOUCH_EVENT_CANCELED then
                            sender:setScale(1.0)
                        end

                        --触摸结束
                        if event == TOUCH_EVENT_ENDED then
                            sender:setScale(1.0)

                            -- this:showGameSetting()
                            require("hall.GameCommon"):showSettings(false)

                            self:disbandGroup()

                        end

                    end

                    -- local CardBackSwitchFunc = GamePlaneOperator.swtichCardBackImg
                    -- local BGSwitchFunc = self.switchBackGroundImg

                    -- if  require("hall.scene.setting.settingScene").showSceneForCustom then
                    --     local CardBackImages = require(TpackageName .. ".PokerCard"):getCardBackAndSizeTable()

                    --     local BGImages = {
                    --                 TpackageName .. "/images/background_img.png",
                    --                 TpackageName .. "/images/background_img_1.png",
                    --                 TpackageName .. "/images/background_img_2.png",
                    --             }

                    --     -- if isControl then
                    --     --     BGImages = {
                    --     --             TpackageName .. "/images/background_img_old.png",
                    --     --             TpackageName .. "/images/background_img_1_old.png",
                    --     --         }
                    --     -- end

                    --     require("hall.scene.setting.settingScene"):showSceneForCustom(true, false, true, true, disband_action,"解散房间",quitRoom_action,"退出房间",
                    --         CardBackSwitchFunc,BGSwitchFunc,CardBackImages,BGImages)
                    -- else

                        --add by zzy 
                        this:showGameSetting()
                        -- require("hall.GameCommon"):showSettings(true, false, true, true, disband_action,"解散房间",quitRoom_action,"退出房间")
                    -- end


                end

            end
        end)


    -- local   gameConfigMsg_plane  = hall_plane:getChildByName("gameConfigMsg_plane")
    --         gameConfigMsg_plane:setVisible(false)
    --         gameConfigMsg_plane:setTouchEnabled(true)

    local   btn_rule = hall_plane:getChildByName("btn_rule")
            btn_rule:setVisible(false)
            btn_rule:addTouchEventListener(function(sender,event)
                                --触摸结束
                if  event == TOUCH_EVENT_ENDED then
                    GamePlaneOperator:loadRulePlane()
                end

            end)


    local   btn_exit = hall_plane:getChildByName("btn_exit")
            btn_exit:addTouchEventListener(function(sender,event)

                --触摸开始
                if event == TOUCH_EVENT_BEGAN then
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then
                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                    local quitRoom_action = function()
                        self:quitRoom()
                    end

                    require("hall.GameTips"):showTips("提示", "", 1, "确定退出房间？",nil,quitRoom_action)

                end

            end)

    --解散房间按钮
    local btn_disband = hall_plane:getChildByName("btn_disband")
    btn_disband:setTouchEnabled(true)
    btn_disband:addTouchEventListener(function(sender,event)

            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)

                local disband_action = function(sender,event)

                    --触摸开始
                    if event == TOUCH_EVENT_BEGAN then
                        sender:setScale(0.9)
                    end

                    --触摸取消
                    if event == TOUCH_EVENT_CANCELED then
                        sender:setScale(1.0)
                    end

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then
                        sender:setScale(1.0)

                        require("hall.GameCommon"):showSettings(false)

                        self:disbandGroup()

                    end
                end

                require("hall.GameCommon"):showSettings(true, false, true, true, disband_action)

            end
        end)


    --聊天按钮
    local btn_msg = hall_plane:getChildByName("btn_msg")
    local ori_btn_msg_scale = btn_msg:getScale()
    btn_msg:addTouchEventListener(function(sender,event)

            --触摸开始
            if  event == TOUCH_EVENT_BEGAN then
                sender:setScale(ori_btn_msg_scale + 0.1)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(ori_btn_msg_scale)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(ori_btn_msg_scale)

                -- local pos = sender:getPosition()
                -- faceUI_node:showTxtPanle(pos,1)

                -- add by zzy 2019-7-6
                self:loadGameMsgLayer()

            end

        end)

    local room_info =  NIUNIU_GAME_SCENE:getChildByName("room_info")

    --回看按钮
    local btn_auto_play = hall_plane:getChildByName("btn_auto_play")
    btn_auto_play:setVisible(true)
    btn_auto_play:addTouchEventListener(function(sender,event)      
        if event == TOUCH_EVENT_ENDED then
            self:StartPlayBack()
        end
  end)


    --获取设备信息
    local  device_info_plane = hall_plane:getChildByName("device_info_plane")
    if  device_info_plane then
        require("hall.util.GameMenu"):getDeviceInfo(device_info_plane)
    end

    local  room_info = NIUNIU_GAME_SCENE:getChildByName("room_info")
           room_info:setVisible(false)

    local BGStyleIndex = cc.UserDefault:getInstance():getIntegerForKey("BGStyleIndex",1)

    self:switchBackGroundImg(BGStyleIndex)

    self:showButtonAfterSitDown(false)

    self:setGameSetting()

end

--点击回放按钮
function NiuNiuGameScene:StartPlayBack( ... )
    -- body
    NiuNiuSendHandle:CLIENT_PlAY_BACK()
    print ("StartPlayBack")
 


    --   local     headSize =  118
    --         nickname = require("hall.GameCommon"):formatNick(nickname, 4)
    --         nick_txt:setString(nickname)
    --         head:loadTexture(defaultHead)   --先加载默认头像，解决头像请求超时会显示错的问题

    -- require("hall.GameCommon"):getUserHead(photoUrl, userInfo["uid"], userInfo["sex"], head, headSize, false,nickname)
end

function NiuNiuGameScene:ShowPlayBack( info )
    -- body
    local layout = cc.CSLoader:createNode(TpackageName .. "/csb/playback.csb")
    layout:setName("PlayBackLayer")
    layout:addTo(SCENENOW["scene"],9999)
    layout:setScale(1280/1920)

    local list_view = layout:getChildByName("ListView_1")
    local list_layout = layout:getChildByName("layout")
    local page_txt = layout:getChildByName("page_txt")
    local turn_left = layout:getChildByName("turn_left")
    local turn_right = layout:getChildByName("turn_right")
    turn_left.noScale = true
    turn_right.noScale = true
    local CocosUtil = require("hall.util.CocosUtil")
    self.cur_index = 1
    turn_left:onClick(CocosUtil:Bind(self.TurnDirection , self , info , 1 , list_view, list_layout , page_txt))
    turn_right:onClick(CocosUtil:Bind(self.TurnDirection , self, info, 2 , list_view, list_layout , page_txt))
    page_txt:setString("1")
    for k , v in pairs(info.game_info[1].player_info) do 
        local clone_list = list_layout:clone()
        local head_img = clone_list:getChildByName("head_img")
        local nickname = require("hall.GameCommon"):formatNick(v.m_nickname, 4)
        require("hall.GameCommon"):getUserHead(v.m_portrait, v.user_id, v.sex, head_img, 118, false, nickname)
        local name_txt = clone_list:getChildByName("name_txt")
        name_txt:setString(nickname)
        local bet_txt = clone_list:getChildByName("bet_txt")
        local zhuang_img = clone_list:getChildByName("zhuang_img")
        local qiang_txt = clone_list:getChildByName("qiang_txt")
        -- qiang_txt:setString(v.bet_value == -1 and "抢" or "不抢")
        for i = 1 , 2 do 
            local card = clone_list:getChildByName("head_" .. i)
            local final_card = clone_list:getChildByName("final_" .. i)
            local card_image_path = require(TpackageName .. ".PokerCard"):getCardPath(v.head_card[i] , true)
            card:loadTexture(card_image_path)
            local final_path = require(TpackageName .. ".PokerCard"):getCardPath(v.final_card[i] , true)
            final_card:loadTexture(final_path)
        end
        local win_score = clone_list:getChildByName("win_score")
        local loss_score = clone_list:getChildByName("loss_score")
        win_score:setVisible(v.turn_money >= 0)
        loss_score:setVisible(v.turn_money < 0)
        win_score:setString(v.turn_money)
        loss_score:setString(v.turn_money)    
        zhuang_img:setVisible(v.bet_value == -1)
        bet_txt:setString(-1 == v.bet_value and "" or v.bet_value)
        local bg = clone_list:getChildByName("bg")
        local bg_path = TpackageName .. "/images/list_"
        bg_path = v.turn_money >= 0 and bg_path .. "2.png" or bg_path .. "1.png"
        bg:loadTexture(bg_path)
        list_view:pushBackCustomItem(clone_list)
    end

    local mask = layout:getChildByName("mask")
    mask.noScale = true
    mask:onClick(handler(self , self.ClosePlayBack))
end

function NiuNiuGameScene:ClosePlayBack( ... )
    -- body
    local scene = SCENENOW["scene"]:getChildByName("PlayBackLayer")
    if scene then 
        scene:removeFromParent()
        scene = nil
    end
end

--index 为1 代表向左转
--index 为2 代表向右转
function NiuNiuGameScene:TurnDirection( info , index , list_view , list_layout , page_txt)
    -- body
    --代表不能往左转了
    if 1 == index then 

        if 1 == self.cur_index then return end
        self.cur_index = self.cur_index - 1
        list_view:removeAllChildren()
        self:RerushItem(info.game_info[self.cur_index].player_info, list_view , list_layout)

    else

        if not info.game_info[self.cur_index + 1] then return end
        self.cur_index = self.cur_index + 1
        list_view:removeAllChildren()
        self:RerushItem(info.game_info[self.cur_index].player_info, list_view , list_layout)

    end

    page_txt:setString(tostring(self.cur_index))
end

function NiuNiuGameScene:RerushItem( info , list_view , list_layout)
    -- body
     for k , v in pairs(info) do 
        local clone_list = list_layout:clone()
        local head_img = clone_list:getChildByName("head_img")
        local nickname = require("hall.GameCommon"):formatNick(v.m_nickname, 4)
        require("hall.GameCommon"):getUserHead(v.m_portrait, v.user_id, v.sex, head_img, 118, false, nickname)
        local name_txt = clone_list:getChildByName("name_txt")
        name_txt:setString(nickname)
        local bet_txt = clone_list:getChildByName("bet_txt")
        local zhuang_img = clone_list:getChildByName("zhuang_img")
        local qiang_txt = clone_list:getChildByName("qiang_txt")
        for i = 1 , 2 do 
            local card = clone_list:getChildByName("head_" .. i)
            local final_card = clone_list:getChildByName("final_" .. i)
            local card_image_path = require(TpackageName .. ".PokerCard"):getCardPath(v.head_card[i] , true)
            card:loadTexture(card_image_path)
            local final_path = require(TpackageName .. ".PokerCard"):getCardPath(v.final_card[i] , true)
            final_card:loadTexture(final_path)
        end
        local win_score = clone_list:getChildByName("win_score")
        local loss_score = clone_list:getChildByName("loss_score")
        win_score:setVisible(v.turn_money >= 0)
        loss_score:setVisible(v.turn_money < 0)
        win_score:setString(v.turn_money)
        loss_score:setString(v.turn_money)    
        zhuang_img:setVisible(v.bet_value == -1)
        bet_txt:setString(-1 == v.bet_value and "" or v.bet_value)
        local bg = clone_list:getChildByName("bg")
        local bg_path = TpackageName .. "/images/list_"
        bg_path = v.turn_money >= 0 and bg_path .. "2.png" or bg_path .. "1.png"
        bg:loadTexture(bg_path)
        list_view:pushBackCustomItem(clone_list)
    end
end

function NiuNiuGameScene:setGameSetting()
    self.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
    self:addChild(self.roomCommonLayer, 15)
    self.roomCommonLayer:setTouchSwallowEnabled(false)
    self.roomCommonLayer:setVisible(false)
end

function NiuNiuGameScene:showGameSetting()
    print("=====NiuNiuGameScene:showGameSetting=====")
    print("=====NiuNiuGameScene:showGameSetting=====")
    -- self:showChooseCard()
    self:setGameSetting()

    self:loadMoreFuncLayer()

end

function NiuNiuGameScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end

function NiuNiuGameScene:getToDisbandFuncs()
    local data = {} 
    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandRoom)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
    data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
    data.showGameMsgLayerHandler = handler(self, self.loadGameMsgLayer)
    data.voiceRecordHandler = handler(self,self.addVoiceRecordEvent)
    return data
end

function NiuNiuGameScene:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(self.moreFuncLayer, 15)
        -- g_roomCommonLayer = self.moreFuncLayer
    else
        if 0 == SCENENOW["scene"].GameRound then
            self.moreFuncLayer.btnDisbandRoom:setVisible(false)
        else
            self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        end
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
end

function NiuNiuGameScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(self.gameMsgLayer, 15)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function NiuNiuGameScene:getToSendFaceAndTxtFuncs()
    local data = {}
    -- data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function NiuNiuGameScene:sendFaceByIdx(id)
    print("sendFaceMsg --------------------------", id)
    NiuNiuSendHandle:CLI_MSG_FACE(id)
end

function NiuNiuGameScene:sendEditTxt(str)
    print("sendEditMsg --------------------------", id)
end

function NiuNiuGameScene:disbandRoom()
    NiuNiuSendHandle:C2G_CMD_DISSOLVE_ROOM()
end

function NiuNiuGameScene:rejectDisband()
    NiuNiuSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function NiuNiuGameScene:agreeDisband()
    NiuNiuSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end


function NiuNiuGameScene:onEnter()

    -- NiuNiuUtils:showResult({playerlist = {}})

    --播放背景音乐
    SoundUtils:playBackgroundMusic()

    --房间信息
    dump(USER_INFO["GroupLevel"], "传到服务器的游戏level")
    dump(USER_INFO["activity_id"], "传到服务器的activity_id")

    local hall_plane = self._scene:getChildByName("hall_plane")
    --添加录音按钮
    local btn_voice = hall_plane:getChildByName("btn_voice")
    local voice_bt_worldpoint = (btn_voice:getParent()):convertToWorldSpace(btn_voice:getPosition())

    --发送113
    if  GROUP_MODE == 2 then

        local groupId = nil
        if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
            groupId = USER_INFO["club_id"]["groupId"]
        end

        NiuNiuSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat_id"],USER_INFO["activity_id"], groupId)
        HEART_BEAT_TID = USER_INFO["tid"]
        dump(HEART_BEAT_TID,"发送登陆房间")
    else
        self:updateRoomInfo(nil,nil,USER_INFO["invote_code"])
        NiuNiuSendHandle:enterGroupRoom(USER_INFO["GroupLevel"], 1, 36, USER_INFO["activity_id"])
    end


    --报错了，因为原来的大厅的改动，删掉的东西导致的   标注：zzy 2019-7-6

    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    else
        VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
    end

    -- zzy end

    -- SCENENOW["scene"]:performWithDelay(function()
    --     SoundUtils:playCardKindEffect(CARDKIND_HULUNIU)
    -- end,1)


    if  device.platform == "windows" then

        isShowErrorScene = true

        -- MY_CARDS ={0x15,0x14,0x25,0x21,0x23}

        -- local isshunzi = require(TpackageName .. ".cardLogic"):has_shunziniu(MY_CARDS)
        -- local isshunzi = require(TpackageName .. ".cardLogic"):getallfans(MY_CARDS)

        -- self:shaderTest()

        -- local gameresultScene = require("hall.scene.gameresult.gameresultScene")
        -- gameresultScene:test()

        MY_SEAT_ID = 2
        RELATIVE_SEAT_ID = 0

        -- for seat_id = 0,9 do
        --     dump(NiuNiuUtils:getPlayerTypeBySeatId(seat_id),"NiuNiuGameScene_getPlayerTypeBySeatId")
        -- end


        hall_plane:getChildByName("btn_rule"):addTouchEventListener(function(sender,event)
                            --触摸结束
            if  event == TOUCH_EVENT_ENDED then
                -- self:testPageEffect()
                -- GamePlaneOperator:setReadyStatus(CARD_PLAYERTYPE_MY,"action")
                -- GamePlaneOperator:setBetTimes(CARD_PLAYERTYPE_MY,2)
                GamePlaneOperator:clearGameDatas()
                -- LIANGCARDNUM = 4
                GAME_STATE = GAME_STATUS_OUTCARD

                local outcards,fan = require(TpackageName .. ".cardLogic"):getallfans(MY_CARDS)
                dump(outcards,"测试顺子牛判断")
        
                GamePlaneOperator:showCards(CARD_PLAYERTYPE_MY,MY_CARDS,true)
                -- SCENENOW["scene"]:performWithDelay(function()
                    -- GamePlaneOperator:showControlButtons(5)
                -- end,2)
                GamePlaneOperator:showCardKind(CARD_PLAYERTYPE_MY,fan)  --显示盖牌文字

                -- SCENENOW["scene"]:performWithDelay(function()
                    GamePlaneOperator:outCard(CARD_PLAYERTYPE_MY,MY_CARDS)
                -- end,2)


                -- if  device.platform == "windows" then

                --     GamePlaneOperator:showControlButtons(5)
                --     for playerType  =1,TOTAL_PLAYERNUM do
                --         GAME_STATE = GAME_STATUS_OUTCARD
                --         if  playerType == CARD_PLAYERTYPE_MY then
                --             GamePlaneOperator:showCards(playerType,{0x07,0x17,0x27,0x16,0x16},true)
                --         else
                --             GamePlaneOperator:showDealCardsAnimation(playerType,nil,5)
                --         end

                --         GamePlaneOperator:setBetTimes(playerType,1)
                --         GamePlaneOperator:showCardKind(playerType,11)  --显示盖牌文字

                --     end


                --     for seat_id = 0,TOTAL_PLAYERNUM-1 do
                --         NiuNiuUtils:showPlayer(USER_INFO["uid"],seat_id,NIUNIU_USERINFO_TABLE[USER_INFO["uid"]],1)
                --     end

                -- end


                -- local coin_img_path = TpackageName .. "/images/effect_gold_2.png"
                -- local sceneNow = SCENENOW["scene"]

                -- local coinfly = function(oriPos,targetPos,i)

                --     local delaytime = i*0.05 + math.random(-3,3)/100

                --     -- math.randomseed(string.reverse(os.time()))

                --     sceneNow:performWithDelay(function()

                --     oriPos = cc.pAdd(oriPos,cc.p(math.random(-50,50),0 ) )

                --     local coin_sp = display.newSprite(coin_img_path)
                --     coin_sp:setPosition(oriPos)
                --     -- coin_sp:setScale(0.6)
                --     sceneNow:addChild(coin_sp, 100)
                --     targetPos = cc.pAdd(targetPos,cc.p(math.random(-50,50),math.random(-8,8) ) )
                --     local random = i

                --     if  random > 20 then
                --         random = 20
                --     end

                --     -- local height = math.random(130,160)
                --     local middleY = (targetPos.y + oriPos.y)/2

                --     -- local linerLength = math.sqrt((targetPos.x - oriPos.x)^2 + (targetPos.y - oriPos.y)^2)
                --     local q1 = cc.p((targetPos.x - oriPos.x)*(0.22 + math.random(-9,9)/100) + oriPos.x,(targetPos.y - oriPos.y)*(0.52+ math.random(-9,9)/100) + oriPos.y)
                --     local q2 = cc.p((targetPos.x - oriPos.x)*(0.81 + math.random(-9,9)/100) + oriPos.x,(targetPos.y - oriPos.y)*(0.53+ math.random(-9,9)/100)+ oriPos.y)
                --     local mb = cc.BezierTo:create(0.4,{q1, q2,targetPos})

                --     local fo = cc.FadeOut:create(0.3)
                --     local remove_action = cc.CallFunc:create(function()
                --         coin_sp:removeSelf()
                --     end)

                --     local seq = cc.Sequence:create(mb,fo,cc.RemoveSelf:create()) --cc.DelayTime:create(0.4),
                --     coin_sp:runAction(seq)

                --     end,delaytime)

                -- end

                -- for i = 1,10 do
                --     coinfly(cc.p(100,200),cc.p(800,700),i)
                -- end

            end

        end)

    else
        function dump()
        end
    end
    -- require(TpackageName .. ".LayerShuffling").new(8)

    -- require(TpackageName .. ".PokerCard"):swtichCardBackImg(2)

    -- self:modifyConfig()
    -- require(TpackageName .. ".handle.NiuNiuReceiveHandle"):showWaiWeiResult()

    -- local pack = {}
    -- pack.playercount = 1
    -- local item = {uid = 991,
    -- user_info = json.encode( {
    --     add_chips = 10000000,
    --     chips = 10000000,
    --     oriChips= 10000000,
    --     photo_url = "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/u=1896009994,3333925118&fm=21&gp=0.jpg",
    --     x=1,
    --     table_id=190119945,
    --     user_name="用户101015"}
    --     )
    -- }

    -- pack.playerlist = {}

    -- for i = 1,9 do
    --     table.insert(pack.playerlist,item)
    -- end

    --     local item = {uid = 992,
    -- user_info = json.encode( {
    --     add_chips = 10000000,
    --     chips = 10000001,
    --     oriChips= 10000000,
    --     photo_url = "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/u=1896009994,3333925118&fm=21&gp=0.jpg",
    --     x=1,
    --     table_id=190119945,
    --     user_name="用户101015"}
    --     )
    -- }
    -- table.insert(pack.playerlist,item)

    -- pack.game_amount = 10

    -- require(TpackageName .. ".handle.NiuNiuReceiveHandle"):showResult(pack)
end

function NiuNiuGameScene:registShareButtons(invote_code)

    local invote_code = invote_code or ""
    -- local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
    local share_content = ""

    local gameConfigTable = self:getGameConfig()

    -- for k,v in pairs(config_arr) do
    --     if v ~= "" then
    --         share_content = share_content .. v .. ","
    --     end
    -- end

    for k,v in pairs(gameConfigTable) do
        if type(v) == "string" then
            share_content = share_content .. k .. "：" .. v .. "   "
        elseif type(v) == "table" then
            for i,x in pairs(v) do
                share_content = share_content .. i .. "：" .. x .. "   "
            end
        end
    end

    -- dump(share_content,"share_content")

    local control_plane = NIUNIU_GAME_SCENE:getChildByName("control_plane")
    --邀请微信好友
    local btn_invite = control_plane:getChildByName("btn_invite")
    local btn_copy_room_id = control_plane:getChildByName("btn_copy_room_id")

    require("hall.util.GameMenu"):registCopyRoomIdFunc(btn_copy_room_id,invote_code,GAME_NAME)

    if  quickEnterRoom == true then
        btn_copy_room_id:setVisible(true)
    else
        btn_copy_room_id:setVisible(false)
    end

    if  isiOSVerify then
        btn_copy_room_id:setVisible(false)
        btn_invite:setVisible(false)
    end

    self.btn_copy_room_id = btn_copy_room_id
    self.btn_invite = btn_invite

    local shareButtonFuc =  function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)

                if  sender == btn_invite then
                    local paras = {}
                    paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
                    paras["imagePath"] = "url"
                    paras["name"] = "超级三加一，房号：" .. USER_INFO["invote_code"]
                    paras["showType"] = 2;
                    paras["url"] = appDownLoadAddress

                    dump(paras,"=======554545454545454545=======")

                    local shareLayer = require("hall.share.ShareLayer").new(paras)
                    if shareLayer then
                        shareLayer:addTo(SCENENOW["scene"],9999999)
                    end
                    -- share_content = string.sub(share_content, 1, string.len(share_content) - 1)
                    -- require("hall.common.ShareLayer"):showShareLayer(GAME_NAME .. "，房号：" .. invote_code, "https://fir.im/rnbk ", "url", share_content)
                end

            end
        end

    btn_invite:addTouchEventListener(shareButtonFuc)

end

--function NiuNiuGameScene:reConnect()
--    NiuNiuSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat_id"],USER_INFO["activity_id"])
--end
function NiuNiuGameScene:reConnect()
    --SanGongSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat"],USER_INFO["activity_id"])
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function NiuNiuGameScene:LoginRoom()


    --设置协议和协议处理
    bm.server:setProtocol(NiuNiuProtocol)
    bm.server:setHandle(NiuNiuReceiveHandle.new())
    NiuNiuSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat"],USER_INFO["activity_id"])
    --require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function NiuNiuGameScene:switchBackGroundImg(index)

    -- local background = NIUNIU_GAME_SCENE:getParent():getChildByName("background")

    -- if index == 1 then
    --     background:loadTexture(TpackageName .. "/images/background_img.png")
    --     dump("成功更换桌布")
    -- elseif index == 2 then
    --     background:loadTexture(TpackageName .. "/images/background_img_1.png")
    -- elseif index == 3 then
    --     background:loadTexture(TpackageName .. "/images/background_img_2.png")
    -- end

    -- NiuNiuGameScene:switchBackGroundGrid(TOTAL_PLAYERNUM)
end

function NiuNiuGameScene:switchBackGroundGrid(total_playernum)

    -- local BGStyleIndex = cc.UserDefault:getInstance():getIntegerForKey("BGStyleIndex",1)

    -- local additiontxt = ""
    -- if  BGStyleIndex == 1 then
    --     additiontxt = ""
    -- elseif   BGStyleIndex == 2 then
    --     additiontxt = "_1"
    -- elseif   BGStyleIndex == 3 then
    --     additiontxt = "_2"
    -- end


    -- local backgroundgrid = NIUNIU_GAME_SCENE:getParent():getChildByName("backgroundgrid")
    -- if  total_playernum == 6 then
    --     backgroundgrid:setVisible(true)
    --     backgroundgrid:loadTexture(TpackageName .. "/images/backgroundgrid_6"..additiontxt..".png")
    -- elseif  total_playernum == 8 then
    --     backgroundgrid:setVisible(true)
    --     backgroundgrid:loadTexture(TpackageName .. "/images/backgroundgrid_8"..additiontxt..".png")
    -- else
    --     backgroundgrid:setVisible(false)
    -- end

end


function NiuNiuGameScene:testPageEffect()
    cc.Director:getInstance():setDepthTest(false)
    local card = require(TpackageName .. ".PokerCard").new()
    local NodeGrid = cc.NodeGrid:create()
    card:setCard(0x09)
    NodeGrid:setRotation(0)
    NodeGrid:addChild(card)
    -- Rect gridRect = cc.Rect(visibleSize.width * 0.2,
    --                  visibleSize.height * 0.2,
    --                  visibleSize.width * 0.6,
    --                  visibleSize.height * 0.6);

    SCENENOW["scene"]:addChild(NodeGrid)
    NodeGrid:setPosition(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
    local effect = cc.PageTurn3D:create(4, cc.size(32, 24))
    -- local effect = cc.FlipY3D:create(2)
    -- local effect = cc.FadeOutUpTiles:create(2, cc.size(15, 10))
    -- local effect = cc.Shaky3D:create(6, cc.size(2, 1), 5, false)
    local pageTurn3D = cc.Sequence:create(effect,cc.CallFunc:create(function() NodeGrid:setPosition(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2)) end) )

    -- dump(cc.PageTurn3D:getGrid(),"pageTurn3D")
    NodeGrid:runAction(pageTurn3D)

end

function NiuNiuGameScene:modifyConfig()
    local file, msg = io.open("niuniu/gameConfig.txt")
    local s = file:read("*all")
    dump(s,"modifyConfig")
    local gameConfig = json.decode(s)
    gameConfig["level"] = 42
    gameConfig["gameId"] = 42

    local news = json.encode(gameConfig)
    file:close()

    local newfile = io.open("D:/work/hellouniverse/gameClient/trunk/niuniu/gameConfig1.txt","w")
    newfile:write(news)
    newfile:close()
end


function NiuNiuGameScene:quitRoom()

    print("=====解散房间 NIUNIU=====")
    print("=====解散房间 NIUNIU=====")
    print("=====解散房间 NIUNIU=====")
    print("=====解散房间 NIUNIU=====")
    print("=====解散房间 NIUNIU==Tid===",Tid)

    --add by zzy 2019-7-8 在游戏中是不能退出房间的
    if GAME_ROUND ~= 0 then
        local paras = {type = 1, title = "提示", content = "游戏中不能退出！！！"}
        local tempNode =  require("hall.tips.CommonTips").new(paras)
        self:addChild(tempNode,9999999)
        return 
    end

    if  GROUP_MODE == 2 then
        NiuNiuSendHandle:quitRoom()
    else

        if  Tid == -1 then
            return
        end

        --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
        cct.createHttRq({
            url = HttpAddr .. "/exitFreeGameByDbDateAndGame",
            date = {
                userId = USER_INFO["uid"],
                table_id = Tid,
                activityId = USER_INFO["activity_id"],
                interfaceType = "j"
            },

            type_= "POST",
            callBack = function(data)
                dump(data,"====quitRoom  222333======")
                local responseData = data.netData
                responseData = json.decode(responseData)
                local returnCode = responseData.returnCode
                dump(returnCode,"退出房間返回returnCode")
                if returnCode == "0" then
                    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                end
        end})

    end

end

function NiuNiuGameScene:showShareButton(flag)

    if NiuNiuUtils:getPlayerNum() >= TOTAL_PLAYERNUM then  --人满之后不显示分享按钮
        flag = false
    end

    local control_plane = NIUNIU_GAME_SCENE:getChildByName("control_plane")
    --邀请微信好友
    local btn_invite = control_plane:getChildByName("btn_invite")
    btn_invite:setVisible(flag)

    local btn_copy_room_id = control_plane:getChildByName("btn_copy_room_id")
    local btn_invite = control_plane:getChildByName("btn_invite")

    if  quickEnterRoom == true and GAME_ROUND == 1 then
        btn_copy_room_id:setVisible(flag)
        btn_invite:setVisible(flag)

    else
        btn_copy_room_id:setVisible(false)
        btn_invite:setVisible(false)
    end


end

function NiuNiuGameScene:showDisbandButton(flag)
    --邀请微信好友
    local hall_plane = self._scene:getChildByName("hall_plane")
    local btn_disband = hall_plane:getChildByName("btn_disband")
    btn_disband:setVisible(flag)

end

function NiuNiuGameScene:showButtonAfterSitDown(flag)
    local hall_plane = self._scene:getChildByName("hall_plane")

    -- local btn_auto_play = hall_plane:getChildByName("btn_auto_play")
    local btn_msg = hall_plane:getChildByName("btn_msg")
    local btn_voice = hall_plane:getChildByName("btn_voice")
    btn_msg:setVisible(flag)
    btn_voice:setVisible(flag)
    --btn_auto_play:setVisible(flag)
    --by zzy chanded
     -- btn_auto_play:setVisible(false)

end

--请求充值
function NiuNiuGameScene:requestCharge()
    if isBuyCardMode then
        -- require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
        require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
    end
end


function NiuNiuGameScene:getGameConfig()


    local gameConfigTable =
    {
      {["最大人数"] = "最大人数:  " .. USER_INFO["gameConfig"].maxSeatCount},
      {["底分"] = "底分:  " .. USER_INFO["gameConfig"].baseChip or ""},
      {["局数"] = "局数:  " .. USER_INFO["gameConfig"].round},
    }

    return gameConfigTable

end


function NiuNiuGameScene:updateRoomInfo(baseScore,gameModeName,inviteCode,round,total_round,gameConfig)

    print (debug.traceback())
    -- local hall_plane = self._scene:getChildByName("hall_plane")
    local room_info =  NIUNIU_GAME_SCENE:getChildByName("room_info")

    if  baseScore then
        local text_difeng = room_info:getChildByName("text_difeng")
        text_difeng:setString("底注："..baseScore)
    end

    local hall_plane = NIUNIU_GAME_SCENE:getParent():getChildByName("hall_plane")
    -- local btn_gameConfigMsg = hall_plane:getChildByName("btn_gameConfigMsg"):setVisible(false)
    -- local btn_gameConfigMsg = hall_plane:getChildByName("btn_gameConfigMsg")
    -- btn_gameConfigMsg:addTouchEventListener(function(sender,event)
    --     if event == TOUCH_EVENT_ENDED then
    --         if isOpenControl == true then 
    --              require(TpackageName..".ChoiceCard"):init()
    --         else
    --             local gameConfigTable = self:getGameConfig()
    --             require("hall.util.GameMenu"):showConfigPanel(gameConfigTable)
    --         end
    --     end
    -- end)

    if  gameModeName then
        local game_mode = room_info:getChildByName("game_mode")
        game_mode:setString("玩法：".. "水鱼")
    end

    if  inviteCode then
        room_info:setVisible(true)
        local room_id = room_info:getChildByName("room_id")
        room_id:setString(inviteCode)
        local room_id_title = room_info:getChildByName("room_id_title")
    end

    if  round then
        local round_info = room_info:getChildByName("round_info")

        if  isGoldGame == 0 then
            local round_info_title = room_info:getChildByName("round_info_title")
            round_info_title:setString("分场：")
            round_info:setString(BASE_CHIP)
        else
            if  total_round == 999 then
                round_info:setString(round)
            else
                round_info:setString(round.."/"..total_round)
            end
        end
    end
end

--解散组局相关
--解散组局
function NiuNiuGameScene:disbandGroup()

    local function disband()
        NiuNiuSendHandle:C2G_CMD_DISSOLVE_ROOM()
    end

    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameStatus",
        date = {
            activityId = USER_INFO["activity_id"],
            interfaceType = "j"
        },
        type_= "POST",
        callBack = function(data)
            local responseData = data.netData
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
            if returnCode == "0" then
                local data = tonumber(responseData.data)
                dump(data, "-----检查当前组局状态-----")
                if data == 1 then
                    --创建组局
                    if isiOSVerify then
                        require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "是否解散房间？",_,disband)
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？",_,disband)
                    end

                elseif data == 2 then
                    --开始组局
                    if isiOSVerify then
                        require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "是否解散房间？",_,disband)
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？",_,disband)
                    end

                elseif data == 0 then
                    --结束组局
                    require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

                end
            else

            end

        end
    })

end

function NiuNiuGameScene:shaderTest()

    -- 顶点着色器
    local strVertSource =
    [[
    attribute vec4 a_position;
    attribute vec2 a_texCoord;
    attribute vec4 a_color;

    uniform float ratio; //牌初始状态到搓牌最终位置的完成度比例
    uniform float radius; //搓牌类似于绕圆柱滚起，其圆柱的半径
    uniform float width;
    uniform float finish; //是否完成搓牌

    uniform float offx;
    uniform float offy;

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;

    void main()
    {
        //注意OpenGL-ES中：1.attribute修饰的变量是常量。2.没有自动转类型float a = 1;或者5.0/3都是错误的
        //这两个问题改了两天，可以通过修改CPP代码，打印log来调试cocos2dx程序
        vec4 tmp_pos = a_position;

        //顺时针旋转90度
        tmp_pos = vec4(tmp_pos.y, -tmp_pos.x, tmp_pos.z, tmp_pos.w);

        if(finish > 0.5) {
            tmp_pos = vec4(tmp_pos.x, -width - tmp_pos.y, tmp_pos.z, tmp_pos.w);

        }else {
            //计算卡牌弯曲的位置，类似于卡牌绕圆柱卷起的原理
            float halfPeri = radius * 3.14159; //半周长
            float hr = halfPeri * ratio;
            if(tmp_pos.y < -width + hr) {
                float dy = -tmp_pos.y - (width - hr);
                float arc = dy/radius;
                tmp_pos.y = -width + hr - sin(arc)*radius;
                tmp_pos.z = radius * (1.0-cos(arc)); //注意之前这里是1，是错误的，opengles不自动类型转换
            }
        }



        tmp_pos += vec4(offx, offy, 0.0, 0.0);

        gl_Position = CC_MVPMatrix * tmp_pos;
        v_fragmentColor = a_color;
        v_texCoord = a_texCoord;
    }
    ]]

    -- 片段着色器
    local strFragSource =
    [[
    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;

    void main()
    {
        //TODO, 这里可以做些片段着色特效

        gl_FragColor = texture2D(CC_Texture0, v_texCoord);
    }
    ]]

    -- 1.创建glProgram
    local glProgram = cc.GLProgram:createWithByteArrays(strVertSource, strFragSource)
    -- 2.获取glProgramState
    local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glProgram)
    -- 3.设置属性值
    local card = require(TpackageName .. ".PokerCard").new():addTo(SCENENOW["scene"])
          card:setCard(0x09)
          card:setPosition(cc.p(640,360))

    -- local size = card:getTexture():getContentSizeInPixels()
    glProgramState:setUniformVec2("my_size", cc.p(400, 400))
    card:setGLProgram(glProgram)
    card:setGLProgramState(glProgramState)

    dump("shaderTest执行成功")
end


--按照传入的分隔符，切割字符串
function LuaSplit(str, split_char)
    if str == "" or str == nil then
        return {};
    end
    local split_len = string.len(split_char)
    local sub_str_tab = {};
    local i = 0;
    local j = 0;
    while true do
        j = string.find(str, split_char,i+split_len);--从目标串str第i+split_len个字符开始搜索指定串
        if string.len(str) == i then
            break;
        end


        if j == nil then
            table.insert(sub_str_tab,string.sub(str,i));
            break;
        end;


        table.insert(sub_str_tab,string.sub(str,i,j-1));
        i = j+split_len;
    end
    return sub_str_tab;
end



function NiuNiuGameScene:showChooseCardPanel(remainCards, usedCards, test_func)

    local layout = cc.CSLoader:createNode(TpackageName .. "/csb/chooseTestCard.csb")
    layout:setName("testConfigScene")
    layout:addTo(SCENENOW["scene"],9999)
    layout:setScale(1280/1920)

    local mask = layout:getChildByName("mask")
    local card_plane = layout:getChildByName("card_plane")
    local card_line_container = layout:getChildByName("card_line_container")

    local CardCreator = require(TpackageName .. ".PokerCard")

    -- local removeSceneFunc = function()
    --     layout:removeFromParent()
    -- end

    mask:addTouchEventListener(function(sender,event)

            --触摸开始
            if  event == TOUCH_EVENT_BEGAN then
                -- removeSceneFunc()
                layout:removeFromParent()
            end

        end)

    if  cards_tbl == nil or next(cards_tbl) == nil then

        cards_tbl =   {
        0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,
        0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
        0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,
        0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,
        }

        for _,value in pairs(usedCards) do
            table.removebyvalue(cards_tbl, value, false)
        end

    end

    local oneLineCardNum = 8
    local lineCount = math.ceil(52/oneLineCardNum)
    local card_line_containers = {}

    for i = 1,lineCount do
        local line_container = card_line_container:clone()
        line_container:setScrollBarEnabled(false)
        card_plane:pushBackCustomItem(line_container)
        card_line_containers[i] = line_container
    end

    local drawCardNum = 0

    local function createCardList(_cards_tbl,isDark)

        for i,card_value in ipairs(_cards_tbl) do

            local card = CardCreator.new()
            card:setScale(0.5)
            card:setCard(card_value)
            card:showFront()

            local iarasiticItem = ccui.Layout:create()
            iarasiticItem:addChild(card)
            iarasiticItem:setContentSize(cc.size(150,180))
            card:setPosition(cc.p(150/2,0))
            iarasiticItem:setAnchorPoint(cc.p(0.5,0.5))
            iarasiticItem:setTouchEnabled(true)
            drawCardNum = drawCardNum + 1

            local container_index =  math.ceil(drawCardNum/oneLineCardNum)
            dump(container_index,"container_index")
            local card_line_container = card_line_containers[container_index]
            card_line_container:pushBackCustomItem(iarasiticItem)

            -- card:setTouchEnabled(true)

            if isDark == true then
                card.font_pai_:setColor(cc.c3b(130,130,130))
                card.font_pai_:setColor(cc.c3b(130,130,130))
                iarasiticItem:setTouchEnabled(false)
            end

            iarasiticItem:addTouchEventListener(function(sender,event)
            -- card:addNodeEventListener(function(sender,event)

                -- dump(event,"点击牌")
                --触摸开始
                -- if  event.name == "began" then
                if  event == TOUCH_EVENT_BEGAN then
                    dump("点击牌")
                    sender:setScale(0.9)
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then
                    sender:setScale(1.0)
                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                -- if event.name == "ended" then
                    sender:setScale(1.0)

                    local txts = {}
                    txts["title"] = "提示"
                    txts["sureBt_txt"] = "确定"
                    txts["cancelBt_txt"] = "取消"
                    txts["msg"] = "是否选择此牌?"

                    local customfunc = {}
                    customfunc["sure_func"] = function()
                        test_func(card_value)
                    end

                    require("hall.GameTips"):showCustomTips(txts,customfunc,1)

                end

            end)


        end

    end

    createCardList(cards_tbl,false)
    createCardList(usedCards,true)

end

return  NiuNiuGameScene
