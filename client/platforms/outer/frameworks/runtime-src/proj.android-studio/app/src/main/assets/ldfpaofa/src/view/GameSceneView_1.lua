local SendHandle = require("ldfpaofa.src.handle.SendHandle")
local OprorateBtn = require("ldfpaofa.src.view.OprorateBtn")
local HandCardView = require("ldfpaofa.src.view.HandCardView")
local GameResult = require("ldfpaofa.src.view.GameResult")
local ZiPaiTest = require("ldfpaofa.src.view.ZiPaiTest")
local TingView = require("ldfpaofa.src.view.TingView")
local faceUI = require("hall.FaceUI.faceUI")
local CardUtils = require("ldfpaofa.src.CardUtils")
local Card = require("ldfpaofa.src.Card")
local GPSShowLayer = require("hall.GPSShowLayer")
local GameSceneView = class("GameSceneView", function()
    if device.platform == "ios" then
        if isiOSVerify then
            return cc.CSLoader:createNode("ldfpaofa/res/GameScene/GameScene.csb")
        else
            return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "ldfpaofa/res/GameScene/GameScene.csb")
        end
    else
        return cc.CSLoader:createNode("ldfpaofa/res/GameScene/GameScene.csb")
    end
    -- return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."ldfpaofa/res/GameScene/GameScene.csb")
end)

function GameSceneView:ctor()
    GameUtils.setNodeNameBindObj(self)
    self:setNodeEventEnabled(true)
    self:initUI()
    self:initEvent()
    require("hall.util.GameMenu"):getDeviceInfo(self.hall.device_info_plane)
    self:setRoomId("000000")
    self:setRound(0, 0)

    self.faceUI = faceUI.new()
    self.faceUI:setHandle(SendHandle)
    self:addChild(self.faceUI, 9999)
    self.faceUI:setName("faceUI")
    self.TingView = TingView.new(self)
    self.HandCardView = HandCardView.new(self)
    self.OprorateBtn = OprorateBtn.new(self.hall, self.HandCardView)
    self:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
end

function GameSceneView:initUI()
    display.doLayout(self)
    self.bg = self.bg
    self.btn_chat = self.hall.btn_chat
    self.take_bg = self.take_bg:hide()
    self.sishou_vw = self.sishou_vw:hide()
    self.btn_voice = self.hall.btn_voice
    self.btn_menu = self.hall.btn_menu
    self.btn_share = self.hall.btn_share
    self.btn_sishou = self.hall.btn_sishou:hide()
    self.btn_copyRoom = self.hall.btn_copyRoom
    self.btn_cancelTuoGuan = self.take_bg.btn_cancelTuoGuan
    self.btn_ready = self.hall.btn_ready
    self.btn_start = self.hall.btn_start
    self.btn_gameConfig = self.hall.btn_gameConfig
    self.btn_tuoGuan = self.hall.btn_tuoGuan
    self.btn_gps = self.hall.btn_gps:show()
    self.img_huang = self.hall.img_huang:hide()
    self.img_line = self.cards_vw.img_line:hide()
    self.sendCardNode = self.players.sendCardNode:hide()
    self.remainCard_vw = self.players.remainCard_vw
    self.sendCardNode.orlPos = self.players.sendCardNode:getPosition()
    self.txt_gameConfig = self.players.txt_gameConfig:setString("")
    self.img_count = self.cards_vw.img_count
    self.txt_cardCount = self.cards_vw.img_count.txt_cardCount:setString("")
    self.player_1 = self.players.player_1:hide()
    self.player_2 = self.players.player_2:hide()
    self.player_3 = self.players.player_3:hide()
    self.player_1 = require("ldfpaofa.src.view.UserInfoView").new(self.player_1)
    self.player_2 = require("ldfpaofa.src.view.UserInfoView").new(self.player_2)
    self.player_3 = require("ldfpaofa.src.view.UserInfoView").new(self.player_3)
    self.btn_piao0 = self.hall.btn_piao0
    self.btn_piao1 = self.hall.btn_piao1
    self.btn_piao2 = self.hall.btn_piao2
    self.btn_piao3 = self.hall.btn_piao3
    
    self:isShowBtnPiao( false )
    self:isShowBtnReady( false )
    self:isShowBtnStart( false )
    self:isShowBtnShare( false )
    self:isShowBtnCopy( false )
    self.HeadMoveNode = self.hall.HeadMoveNode:hide()
    local action = cc.CSLoader:createTimeline("ldfpaofa/res/GameScene/GameScene.csb")
    action:gotoFrameAndPlay(0,true)
    self.HeadMoveNode:runAction(action)
end

function GameSceneView:initEvent()
    self.btn_chat:onClick(handler(self, self.onClick_chat), true)
    self.btn_menu:onClick(handler(self, self.onClick_menu), true)
    self.btn_voice:onClick(handler(self, self.onClick_voice), true)
    self.btn_share:onClick(handler(self, self.onClick_share), true)
    self.btn_ready:onClick(handler(self, self.onClick_ready), true)
    self.btn_start:onClick(handler(self, self.onClick_start), true)
    self.btn_cancelTuoGuan:onClick(handler(self, self.onClick_cancelTuoGuan), true)
    self.btn_tuoGuan:onClick(handler(self, self.onClick_tuoGuan), true)
    self.btn_gps:onClick(handler(self, self.onClick_gps), true)
    self.btn_gameConfig:onClick(handler(self, self.onClick_gameConfig), true)
    self.btn_piao0:onClick(handler(self, self.onClick_piao), true)
    self.btn_piao1:onClick(handler(self, self.onClick_piao), true)
    self.btn_piao2:onClick(handler(self, self.onClick_piao), true)
    self.btn_piao3:onClick(handler(self, self.onClick_piao), true)
    self.btn_sishou:onClick(handler(self, self.onClick_sishou), true)
    require("hall.util.GameMenu"):registCopyRoomIdFunc(self.btn_copyRoom, self.roomId)
    
end

function GameSceneView:clearData()
    self.sendCardNode:stopAllActions()
    self.sendCardNode:hide()
    self.remainCard_vw:removeAllChildren()
    self.HandCardView:clearData()
    self.OprorateBtn:clearData()
    self.player_1:clearData()
    self.player_2:clearData()
    self.player_3:clearData()
    self:isShowBackNodeCount(false)
    self:isShowChuPai(false)
    -- self:isShowTuoGuan( false )
    self.img_huang:hide()
    self:isShowBtnPiao( false )
    self:isShowBtnReady( false )
    if not tolua.isnull(self.GameResult) then
        self.GameResult:removeSelf()
    end
    self:isShowSiShou( false )
end

function GameSceneView:setGameResult( data, UserInfoView, actionName )

    self.GameResult = GameResult.new(data, self.roomId, self):addTo(self)
    local size = self:getContentSize()
    self.GameResult:setAnchorPoint(0.5, 0.5)
    self.GameResult:setPosition(size.width / 2, size.height / 2)
    self.GameResult:hide()

    if UserInfoView then
        UserInfoView:showZiMoOrHu(actionName)
        self.img_huang:stopAllActions()
        local Sequence = cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(
                function()
                    if not tolua.isnull(self.GameResult) then
                        self.GameResult:show()
                    end
                    -- self:isShowBtnReady( true )
            end)
        )
        self.img_huang:runAction(Sequence)
    else
        self.img_huang:show()
        self.img_huang:stopAllActions()
        local Sequence = cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(
                function()
                if not tolua.isnull(self.GameResult) then
                    self.GameResult:show()
                end
                self.img_huang:hide()
                -- self:isShowBtnReady( true )
            end)
        )
        self.img_huang:runAction(Sequence)
    end
end

function GameSceneView:setRemainCards(cards)
    self.remainCard_vw:removeAllChildren()
    local scale = 0.35
    local size = Card:getLongCardSize( )
    local cardWidth = size.width * scale + 1
    local cardHeight = size.height * scale + 1
    local row = 30
    local initY = cardHeight / 2
    local size = self.remainCard_vw:getSize()
    local initX = (size.width - cardWidth * (row - 1)) / 2 
    for idx, card in ipairs(cards) do
        local Sequence = cc.Sequence:create(
            cc.DelayTime:create(idx*0.01),
            cc.CallFunc:create(
            function()
                local rowIdx = idx % row
                rowIdx = rowIdx == 0 and row or rowIdx
                local colIdx = math.ceil(idx / row)
                local x = initX + (rowIdx - 1) * cardWidth
                local y = initY - (colIdx - 1) * cardHeight
                local cardNode = Card.new(card, "long")
                cardNode:setPosition(x, y)
                cardNode:setScale(scale)
                cardNode:addTo(self.remainCard_vw)
            end)
        )
        self:runAction(Sequence)
    end
end

function GameSceneView:showOutCard()
    local perOutCard = g_345.curOutCard
    local perOutSeat = g_345.curOutSeat
    if perOutSeat and perOutCard then
        local UserInfoView = self:getPlayerBySeatId( perOutSeat )
        UserInfoView:showOutCard(perOutCard, nil, true)
    end
    g_345.curOutCard = nil
    g_345.curOutSeat = nil
end

function GameSceneView:hideAllPlayerOutCard(isActionHide)
    self:stopAllActions()
    self.HeadMoveNode:hide()
    if isActionHide then
        local Sequence = cc.Sequence:create(
            cc.DelayTime:create(2),
            cc.CallFunc:create(
                function()
                    self.player_1:isShowOutIngCard(false)
                    self.player_2:isShowOutIngCard(false)
                    self.player_3:isShowOutIngCard(false)
                end)
        )
        self:runAction(Sequence)
    else
        self.sendCardNode:stopAllActions()
        self.sendCardNode:hide()
        self.player_1:isShowOutIngCard(false)
        self.player_2:isShowOutIngCard(false)
        self.player_3:isShowOutIngCard(false)
    end
end

function GameSceneView:hideAllPlayerLight(isShowTime)
    if isShowTime == nil then
        isShowTime = false
    end
    self.player_1:isShowLight(false, isShowTime)
    self.player_2:isShowLight(false, isShowTime)
    self.player_3:isShowLight(false, isShowTime)
    self:isShowBtnSiShou(false)
end
function GameSceneView:isShowBtnSiShou(isShow)
    if g_345.isSiShou then
        isShow = false
    end
    self.btn_sishou:setVisible(isShow)
end
function GameSceneView:starGame()
    self.player_1:isShowHuCount(true, 0)
    self.player_2:isShowHuCount(true, 0)
    self.player_3:isShowHuCount(true, 0)
end

function GameSceneView:isShowBtnPiao( isShow, pack )
    self.btn_piao0:setVisible(isShow)
    self.btn_piao1:setVisible(isShow)
    self.btn_piao2:setVisible(isShow)
    self.btn_piao3:setVisible(isShow)
    if isShow then
        self.btn_piao0.value = 0
        self.btn_piao1.value = pack.piaoValueOne
        self.btn_piao2.value = pack.piaoValueTwo
        self.btn_piao3.value = pack.piaoValueThree
        self.btn_piao1.txt:setString("飘  "..pack.piaoValueOne)
        self.btn_piao2.txt:setString("飘  "..pack.piaoValueTwo)
        self.btn_piao3.txt:setString("飘  "..pack.piaoValueThree)
    end
end

function GameSceneView:isShowPiaoCount( isShow )
    self.player_1:isShowPiaoCount(false)
    self.player_2:isShowPiaoCount(false)
    self.player_3:isShowPiaoCount(false)
end

function GameSceneView:isShowBtnReady( isShow )
    self.btn_ready:setVisible(isShow)
end

function GameSceneView:isShowTuoGuan( isShow )
    self.take_bg:setVisible(isShow)
end

function GameSceneView:isShowSiShou( isShow )
    self.sishou_vw:setVisible(isShow)
    g_345.isSiShou = isShow
    if isShow then
        self.btn_sishou:hide()
    end
end

function GameSceneView:isShowBtnStart( isShow )
    self.btn_start:setVisible(isShow)
end

function GameSceneView:isShowBtnShare( isShow )
    self.btn_share:setVisible(isShow)
end

function GameSceneView:isShowBtnCopy( isShow )
    self.btn_copyRoom:setVisible(isShow)
end

function GameSceneView:isShowBackNodeCount( isShow, count )
    -- self.img_count:setVisible(isShow)
    self.img_count.txt_cardCount:setVisible(isShow)
    if count then
        self.img_count.txt_cardCount:setString("剩余底牌:"..count)
        self.backCount = count
    end
end

--显示玩家开始出牌动画操作
function GameSceneView:isShowChuPai(isShow)
	g_345.isCanChuCard = isShow
    self.HeadMoveNode:setVisible(isShow)
    self.HandCardView:setClickMask(false)
    if not isShow then
        self.img_line:setVisible(isShow)
    end
end

function GameSceneView:isShowLine(isShow)
    self.img_line:setVisible(isShow)
end

function GameSceneView:showGPSButton()
    local temptab = {}
    for k,v in pairs(g_345.userInfos) do
        table.insert(temptab,v)
    end
    local isWarning = 0
    for i=1,#temptab do
        for j=i+1,#temptab do
            if temptab[i].latitude and temptab[j].latitude and temptab[i].longitude and temptab[j].longitude and calculateDistance(temptab[i].latitude, temptab[j].latitude, temptab[i].longitude,temptab[j].longitude) <= 100 then
                isWarning = isWarning + 1
                break
            end
        end
    end
    if isWarning > 0 then
        self.btn_gps.img_safe:setVisible(false)
        self.btn_gps.img_warnning:setVisible(true)
    else
        self.btn_gps.img_safe:setVisible(true)
        self.btn_gps.img_warnning:setVisible(false)
    end
    self.btn_gps:setVisible(true)
end

function GameSceneView:onClick_gps(event)
    local gpsLayer = GPSShowLayer.new()
    self:addChild(gpsLayer,1000)
    local temptab = {}
    for k,v in pairs(g_345.userInfos) do
        table.insert(temptab,v)
    end
    gpsLayer:setInfo(temptab)
end

function GameSceneView:onClick_gameConfig(event)
    if isOpenControl then
        SendHandle:CLI_REQ_TEST_CARDS()
    else
        require("hall.util.GameMenu"):showConfigPanel(g_345.gameConfigTable)
    end
end

function GameSceneView:onClick_chat(event)
    self:loadGameMsgLayer()
end

function GameSceneView:onClick_menu(event)
    self:loadMoreFuncLayer()
end

function GameSceneView:onClick_voice(event)
    local voice_bt_worldpoint = (self.btn_voice:getParent()):convertToWorldSpace(self.btn_voice:getPosition())
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(self.btn_voice,999)
    else
        self.btn_voice:setVisible(false)
        VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
    end
end

function GameSceneView:onClick_share(event)
    local paras = {}
    paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
    paras["imagePath"] = "url"
    paras["name"] =  g_345.GameName.."房号：" .. self.roomId
    paras["showType"] = 2;
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"], 9999999)
    end
end

function GameSceneView:onClick_ready(event)
    SendHandle:CLI_READY_GAME(1)
    self:clearData()
    
end

function GameSceneView:onClick_start(event)
end

function GameSceneView:onClick_piao(event)
    local target = event.target
    local value = target.value
    SendHandle:CLI_PIAO(value)
    self:isShowBtnPiao( false )
end

function GameSceneView:onClick_sishou(event)
    SendHandle:CLI_SISHOU()
end

function GameSceneView:onClick_cancelTuoGuan(event)
    SendHandle:CLI_PLAYER_CANCELAUTO(0)
end

function GameSceneView:onClick_tuoGuan(event)--点击托管
    SendHandle:CLI_PLAYER_CANCELAUTO(1)
end

function GameSceneView:setRoomId( roomId )
    self.roomId = roomId
    self.hall.device_info_plane.txt_room:setString("房间号:"..roomId)
end

function GameSceneView:setRound( round, totalRound )
    self.round = round
    self.totalRound = totalRound
    -- self.hall.device_info_plane.txt_round:setString(round.."/"..totalRound)
    self.hall.device_info_plane.txt_round:setString("第"..round.."局")
    if g_345.gameConfig.modetype == 1 then --1 100胡息结算 2 单局结算
        self.hall.device_info_plane.txt_round:show()
    else
        self.hall.device_info_plane.txt_round:hide()
    end

    local isShow = round <= 0
    self:isShowBtnCopy(isShow)
    self:isShowBtnShare(isShow)
end

function GameSceneView:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(self.gameMsgLayer)
    else
        self.gameMsgLayer:showContentByType(1)
    end
    self.gameMsgLayer:setVisible(true)
end

function GameSceneView:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function GameSceneView:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        local bgData = {
            bg = {
                "ldfpaofa/res/GameScene/bg_1.png",
                "ldfpaofa/res/GameScene/bg_2.png",
                "ldfpaofa/res/GameScene/bg_3.png",
            },
            str = {
                "背景1",
                "背景2",
                "背景3",
            },
            cardDatas = {
                {
                    scale = 0.9,
                    txt = "牌型1",
                    path = "ldfpaofa/res/cards/1/short/26.png",
                },
                {
                    scale = 0.9,
                    txt = "牌型2",
                    path = "ldfpaofa/res/cards/2/short/26.png",
                },
                {
                    scale = 0.9,
                    txt = "牌型3",
                    path = "ldfpaofa/res/cards/3/short/26.png",
                }

            }
        }
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new(bgData)
        self:addChild(self.moreFuncLayer, 99999)
        local data = {}
        data.quitRoom = handler(self, self.quitRoom)
        data.disbandRoom = handler(self, self.disbandRoom)
        self.moreFuncLayer:registerDisbandFuncs(data)
    else
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
    if g_345.gameConfig.dis_agree == 3 then
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    else
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    end
end

function GameSceneView:sendFaceByIdx(id, msgType, to_uid)
    SendHandle:CLI_MSG_FACE(id, msgType, to_uid)
end

function GameSceneView:disbandRoom()
    SendHandle:C2G_CMD_DISSOLVE_ROOM()
end

function GameSceneView:rejectDisband()
    SendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function GameSceneView:agreeDisband()
    SendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function GameSceneView:quitRoom()
    SendHandle:quitRoom()
end

function GameSceneView:get_all_out_cardArr()
    local cards = {}
    local childs = self.HandCardView.hand_vw:getChildren()
    for idx, cardNode in ipairs(childs) do
        table.insert(cards, cardNode._pokerCard)
    end
    local players = {
        self.player_1,
        self.player_3,
        self.player_2
    }
    for i, UserInfoView in ipairs(players) do
        local childs = UserInfoView.out_vw:getChildren()
        for idx,cardNode in ipairs(childs) do
            table.insert(cards, cardNode._pokerCard)
        end
        for _, card in ipairs(UserInfoView:getChiPengCards()) do
            table.insert(cards, card)
        end
    end
    if g_345.curOutCard then
        table.insert(cards, g_345.curOutCard)
    end
    return cards
end

function GameSceneView:sendCard( viewId, card )
    Card:changeImg(self.sendCardNode, card, "long")
    self.sendCardNode:stopAllActions()
    self.sendCardNode:setPosition(self.sendCardNode.orlPos)
    self.sendCardNode:show()
    self.sendCardNode:setScale(0.1)
    local UserInfoView = self["player_"..viewId]
    local pos = UserInfoView:getOutCardPos()
    -- if viewId == 1 then
    --     pos.y = pos.y - 200
    -- end
    local time1 = 0.3
    local time2 = 1
    local time3 = 0.1
    local MoveTo = cc.MoveTo:create(time1, pos)
    local ScaleTo = cc.ScaleTo:create(time1, 0.8)
    local func = cc.CallFunc:create(function( fc )
        self.sendCardNode:hide()
    end)
    local Spawn = cc.Spawn:create(MoveTo, ScaleTo)
    local DelayTime = cc.DelayTime:create(time2)
    if viewId == 1 then
        pos.y = pos.y - 200
    end
    local MoveTo = cc.MoveTo:create(time3, pos)
    local ScaleTo = cc.ScaleTo:create(time3, 0.3)
    local Spawn2 = cc.Spawn:create(MoveTo, ScaleTo)
    local Sequence = cc.Sequence:create(Spawn, DelayTime, Spawn2, func)
    self.sendCardNode:runAction(Sequence)
    return time1 + time2 + time3
end

function GameSceneView:showActionOutIngCard( seat_id, card, isShouKuang)
    local isChu = not isShouKuang--玩家手动出牌 不是系统发牌
    local orlPos = self.sendCardNode.orlPos
    if seat_id == g_345.my_seat_id and g_345.chuPos and isChu then
        orlPos = g_345.chuPos
    end
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    if not isShouKuang then
        orlPos = UserInfoView:getWorldpoint()
    end
    Card:changeImg(self.sendCardNode, card, "long")
    self.sendCardNode:stopAllActions()
    self.sendCardNode:setPosition(orlPos)
    self.sendCardNode:show()
    self.sendCardNode:setScale(0.1)
    local pos = UserInfoView:getOutCardPos()
    local time = 0.18
    local MoveTo = cc.MoveTo:create(time, pos)
    local ScaleTo = cc.ScaleTo:create(time, 0.8)
    local Spawn2 = cc.Spawn:create(MoveTo, ScaleTo)

    local func = cc.CallFunc:create(function( fc )
        self.sendCardNode:hide()
        UserInfoView:isShowOutIngCard(true, card, isShouKuang)
    end)
    -- local Spawn = cc.Spawn:create(MoveTo)
    self.sendCardNode:runAction(cc.Sequence:create(Spawn2, func))
end

function GameSceneView:setZiPaiTest( pokers )
    if not tolua.isnull(self.ZiPaiTest) then
        self.ZiPaiTest:removeSelf()
    end
    self.ZiPaiTest = ZiPaiTest.new(pokers):addTo(self)
    local size = self:getContentSize()
    self.ZiPaiTest:setAnchorPoint(0.5, 0.5)
    self.ZiPaiTest:setPosition(size.width / 2, size.height / 2)
end

function GameSceneView:getPlayerBySeatId( seatId )
    local viewId = g_345.viewIds[seatId] or 0 
    return self["player_"..viewId]
end

function GameSceneView:showGameConfig(gameConfigtbl)
    local gameConfigStr = ""
    local hallMsg = ""
    local maxSeatCount = gameConfigtbl.maxSeatCount
    local jiesan = ""
	for k, v in pairs(gameConfigtbl) do
        if k == "pay_type" then
            if v == "fangka" then
                gameConfigStr = gameConfigStr .. "房主开房 "
            elseif v == "AA" then
                gameConfigStr = gameConfigStr .. "AA开房 "
            end
        elseif k == "piao" then
            if v == 0 then
                g_345.isPiao = false
            elseif v then
                g_345.isPiao = true
                gameConfigStr = gameConfigStr .. "飘 "
            end
        elseif k == "fending" then
            if v == 200 then
                gameConfigStr = gameConfigStr .. "200胡息 "
            elseif v == 400 then
                gameConfigStr = gameConfigStr .. "400胡息 "
            elseif v == 800 then
                gameConfigStr = gameConfigStr .. "800胡息 "
            end
        elseif k == "huxi_score" then
            if v == 15 then
                gameConfigStr = gameConfigStr .. "十五胡起胡 "
            end
        elseif k == "autoai_round" then
            if v == 1 then
                jiesan = jiesan .. "托管1局解散 "
            elseif v == 2 then
                jiesan = jiesan .. "托管2局解散 "
            elseif v == 3 then
                jiesan = jiesan .. "托管3局解散 "
            end
        elseif k == "back_score" then
            if v == 1 then
                gameConfigStr = gameConfigStr .. "底分:0.1 "
            elseif v == 2 then
                gameConfigStr = gameConfigStr .. "底分:0.2 "
            elseif v == 3 then
                gameConfigStr = gameConfigStr .. "底分:0.3 "
            elseif v == 5 then
                gameConfigStr = gameConfigStr .. "底分:0.5 "
            elseif v == 10 then
                gameConfigStr = gameConfigStr .. "底分:1 "
			end
        elseif k == "modetype" then
            if v == 1 then
                gameConfigStr = gameConfigStr .. "100胡息结算 "
            elseif v == 2 then
                gameConfigStr = gameConfigStr .. "单局结算 "
            end
        elseif k == "choupai" then
            if v == 5 then
                gameConfigStr = gameConfigStr .. "抽5张 "
            elseif v == 10 then
                gameConfigStr = gameConfigStr .. "抽10张 "
            elseif v == 15 then
                gameConfigStr = gameConfigStr .. "抽15张 "
            end
        elseif k == "mingtang" then
            local canPickStr= string.split(v, ",")
            for _, x in pairs(canPickStr) do
                if x == '27' then
                    gameConfigStr = gameConfigStr .. "一点红 "
                elseif x == '28' then
                    gameConfigStr = gameConfigStr .. "全求人 "
                elseif x == '29' then
                    gameConfigStr = gameConfigStr .. "门前清 "
                elseif x == '30' then
                    gameConfigStr = gameConfigStr .. "碰碰胡 "
                elseif x == '31' then
                    gameConfigStr = gameConfigStr .. "全油 "
                elseif x == '32' then
                    gameConfigStr = gameConfigStr .. "无油 "
                end
            end
        end
    end
    local baseChip =  " 倍率:"..gameConfigtbl.baseChip .." "
    jiesan = gameConfigtbl.auto_ai == 0 and "无托管 " or jiesan
	g_345.gameConfigTable = {
        {
            ["游戏名"] = gameConfigtbl.name, 
            ["人数"] = maxSeatCount,
        }, 
        {["特殊玩法"] = gameConfigStr},
        {["其它"] = baseChip..jiesan,},
    }
    self.txt_gameConfig:setString(gameConfigtbl.name..baseChip..jiesan..gameConfigStr)
    USER_INFO.gameConfig = "玩法: "..gameConfigStr
    ..baseChip.." 人数 "..maxSeatCount.." 游戏名 "..g_345.GameName
    print(USER_INFO.gameConfig)
end

function GameSceneView:settlement(pack)
    --去掉提示弹框
    local DisbandLayer_tips = SCENENOW.scene:getChildByName("DisbandLayer_tips")
    if DisbandLayer_tips then
        DisbandLayer_tips:removeSelf()
    end
    local data = {}
    data.resultSceneType = 1      --战绩界面展示选择，1为长条形，2为方块形
    data.invote_code = self.roomId      --房间号
    data.fenchang = BASE_CHIP            --分场
    data.round = self.round.."/"..self.totalRound --.."/"..GROUP_TOTAL_ROUND                  --局数
    data.date = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data.activity_id = USER_INFO.activity_id;
    data.resultData = {}
    for idx, user_info in ipairs(pack.player_info) do
        local uid = user_info.uid
        local user_result = {}             --玩家数据实体
        user_result.uid = uid
        user_result.nick = g_345.userInfos[uid].nickName        --昵称
        user_result.icon_url = g_345.userInfos[uid].portrait        --头像链接
        user_result.sex = g_345.userInfos[uid].sex               --性别
        user_result.isRoomOwer = g_345.OwnerID == uid and 1 or 0        --是否为房主，1是，非1或不填不是
        user_result.total = user_info.m_totalBlc        --总输赢分
        user_result.gameDetail = {}       --游戏详情数组

        local tstrHuXi = 0
        for k,v in pairs(user_info.huxilist) do
            local strHuXi =v
            strHuXi = strHuXi/100
            if strHuXi > 0 then
                strHuXi = "+"..strHuXi
            end
            local gameDetail = {}
            gameDetail.showName = "第"..k.."局"
            gameDetail.value = strHuXi
            table.insert(user_result.gameDetail, gameDetail)
            tstrHuXi = tstrHuXi + strHuXi
        end
        
        if g_345.isPiao then
            local seat_id = g_345.userInfos[uid].seat_id or 0
            local piao = g_345.piaoPoints[seat_id] or 0
            local gameDetail = {}
            gameDetail.showName = "飘："
            gameDetail.value = piao
            table.insert(user_result.gameDetail, 1, gameDetail)
        end
        if g_345.gameConfig.modetype == 1 then--1 100胡息结算 2 单局结算
            local gameDetail = {}
            gameDetail.showName = "总胡息"
            gameDetail.value = tstrHuXi
            table.insert(user_result.gameDetail, 1, gameDetail)
        end
        
        table.insert(data.resultData, user_result)
    end

    local share_action = function(event)
        local paras = {}
        paras.showType = 2;
        paras.desc =  USER_INFO.gameConfigMsg or " "
        paras.imagePath = "screen"
        paras.name = "分享结果"
        paras.url = appDownLoadAddress
        local shareLayer = require("hall.share.ShareLayer").new(paras)
        if shareLayer then
            shareLayer:addTo(SCENENOW["scene"],9999999)
        end
    end

    --再来一局
    local extend_action = function(event)
        require("hall.groudgamemanager"):extend_freegame(USER_INFO.uid, USER_INFO.activity_id, "ldfpaofa.gameScene")
    end
    local backHall_action = function(event)
        USER_INFO.gameConfig = ""
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
    end
    require("hall.settlement.settlement").new(data, backHall_action, share_action, nil, extend_action)
end

function GameSceneView:update( dt )
    if self.timing and #self.timing >= 1 then
        for idx, timing in ipairs(self.timing) do
            timing.time = timing.time - dt
            self.timing[idx].time = timing.time
            if timing.time <= 0 then
                timing.func()
                table.remove(self.timing, idx)
            end
        end
    end
end

function GameSceneView:setTimingFun( func, time )
    if not self.timing then
        self.timing = {}
    end
    table.insert(self.timing, {func = func, time = time})
end

function GameSceneView:onExit( )
    self.sendCardNode:stopAllActions()
    self.img_huang:stopAllActions()
    self:stopAllActions()
end

return GameSceneView
