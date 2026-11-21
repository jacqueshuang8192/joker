local RoundEnding = class('RoundEnding')
local Card = require(TpackageName .. '.PokerCard')

function RoundEnding:showroundending(data)
    -- local MyGold = 0  --我的输赢

    -- self:removeView()

    -- local view = cc.CSLoader:createNode(TpackageName .. "/csb/RoundEnding.csb")

    -- self._scene  = view

    -- local DESIGN_SCREEN_WIDTH = 960
    -- self._scene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)

    --   	self._scene:setName("RoundEnding")

    -- NIUNIU_SCENE:addChild(self._scene, 699)

    -- local Panel_1 =  self._scene:getChildByName("Panel_1")
    --    local winbox = Panel_1:getChildByName("winbox")---赢的背景框
    --    local light = Panel_1:getChildByName("winlight")---背景光线
    --    local fin_text = Panel_1:getChildByName("fin_text")---胜利或者失败
    --    local btn = Panel_1:getChildByName("btn")
    --    local btn_txt = btn:getChildByName("btn_txt")----按钮显示的文字

    --    local GameResult = NIUNIU_SCENE:getChildByName("GameResult")
    -- if GameResult then
    -- 	btn_txt:loadTexture(TpackageName .. "/newimage/text_chakanzongjiesuan.png")
    -- else
    -- 	btn_txt:loadTexture(TpackageName .. "/newimage/text_jixuyouxi.png")
    -- end

    -- --压注文字
    -- local txt_yazhu = Panel_1:getChildByName("txt_yazhu")
    -- if USER_INFO["GroupLevel"] == 16 then
    -- 	txt_yazhu:setString("底分")
    -- end

    local banker_uid = data.banker_uid
     ----庄家id

    local banker_win_times = data.banker_win_times ---庄家输赢倍数

    local banker_win_chip = data.banker_win_chip -----庄家输赢数

    local banker_chips = data.banker_chips ----庄家金币

    local round = data.round ----当前结算时的局数

    local brank_handCards = data.handCards

    if next(brank_handCards) == nil then
        brank_handCards = NIUNIU_OUTCARDS[banker_uid] or {}
    end

    if not GROUP_RECORD[GAME_ROUND] then
        GROUP_RECORD[GAME_ROUND] = {}
    end

    GROUP_RECORD[GAME_ROUND].banker_uid = banker_uid

    -- local player = Panel_1:getChildByName("player0")
    -- player:setVisible(true)

    -- local zuang = player:getChildByName("zuang")
    -- zuang:setVisible(true)
    -- local playername = player:getChildByName("playername")

    -- playername:setString(require("hall.GameCommon"):formatNick(NIUNIU_USERINFO_TABLE[banker_uid].nick, 8))

    -- local yazhu = player:getChildByName("yazhu")
    -- if USER_INFO["GroupLevel"] == 16 then
    -- 	yazhu:setString(tostring(USER_INFO["base_chip"]))
    -- 	yazhu:setVisible(true)
    -- else
    -- 	yazhu:setString(banker_win_times)
    -- 	yazhu:setVisible(false)
    -- end

    -- local niu = player:getChildByName("niu")

    -- --牌显示区域
    -- local showcard_ly = player:getChildByName("showcard_ly")
    -- showcard_ly:removeAllChildren()

    --显示牛几
    if not GROUP_RECORD[GAME_ROUND][banker_uid] then
        GROUP_RECORD[GAME_ROUND][banker_uid] = {}
    end

    if not GROUP_RECORD[GAME_ROUND][banker_uid].cards then
        GROUP_RECORD[GAME_ROUND][banker_uid].cards = {}
    end

    GROUP_RECORD[GAME_ROUND][banker_uid].desc_pic =
        TpackageName .. '/images/result_' .. tostring(NIUNIUKIND[banker_uid]) .. '.png'

    -- niu:loadTexture(TpackageName .. "/images/result_" .. tostring(NIUNIUKIND[banker_uid]) .. ".png")

    --显示手牌
    -- self:drawCards(brank_handCards,_,banker_uid)

    -- local resultcore  = player:getChildByName("resultcore")
    -- resultcore:setString(banker_win_chip)

    --    if  banker_uid == USER_INFO["uid"]  then
    -- 	MyGold = banker_win_chip
    -- end

    --其他玩家相关
    for k, v in pairs(data.o_userinfo) do
        -- local txt = "player" .. k
        -- local player = Panel_1:getChildByName(txt)
        -- player:setVisible(true)

        -- local playername =  player:getChildByName("playername")

        -- local namenick = require("hall.GameCommon"):formatNick(NIUNIU_USERINFO_TABLE[v.uid].nick, 8)
        -- playername:setString(namenick)

        -- local yazhu = player:getChildByName("yazhu")

        -- if USER_INFO["GroupLevel"] == 16 then
        -- 	yazhu:setString(tostring(USER_INFO["base_chip"]))
        -- 	yazhu:setVisible(true)

        -- else
        -- 	local ff
        --  if v.win_times < 0 then
        --  	 ff = -v.win_times
        --  else
        --  	 ff = v.win_times
        --  end
        --  yazhu:setString(ff)

        -- end

        -- local niu  = player:getChildByName("niu")

        -- --牌显示区域
        -- local showcard_ly = player:getChildByName("showcard_ly")
        -- showcard_ly:removeAllChildren()

        if not GROUP_RECORD[GAME_ROUND][v.uid] then
            GROUP_RECORD[GAME_ROUND][v.uid] = {}
        end
        if not GROUP_RECORD[GAME_ROUND][v.uid].cards then
            GROUP_RECORD[GAME_ROUND][v.uid].cards = {}
        end

        GROUP_RECORD[GAME_ROUND][v.uid].desc_pic =
            TpackageName .. '/images/result_' .. tostring(NIUNIUKIND[v.uid]) .. '.png'

        --显示牛几
        -- niu:loadTexture(TpackageName .. "/images/result_" .. tostring(NIUNIUKIND[v.uid]) .. ".png")

        -- self:drawCards(v.handCards,_,v.uid)

        -- end
        -- end

        -- local resultcore  = player:getChildByName("resultcore")
        -- resultcore:setString(v.win_chip)

        -- if v.uid == USER_INFO["uid"] then
        --          MyGold = v.win_chip
        -- end
    end

    -- if MyGold < 0  then
    --    	winbox:loadTexture(TpackageName .. "/newimage/fin_lose_box01.png")
    --    	light:loadTexture(TpackageName .. "/newimage/fin_lose_effect_light.png")
    --    	fin_text:loadTexture(TpackageName .. "/newimage/fin_text_lose.png")
    --    end

    -- btn:addTouchEventListener(

    --     function(sender,event)
    --         --触摸开始
    --         if event == TOUCH_EVENT_BEGAN then
    --             sender:setScale(0.8)
    --         end

    --         --触摸取消
    --         if event == TOUCH_EVENT_CANCELED then
    --             sender:setScale(1.0)
    --         end

    --         --触摸结束
    --         if event == TOUCH_EVENT_ENDED then
    --             sender:setScale(1.0)

    -- self:removeView()

    -- local GameResult = NIUNIU_SCENE:getChildByName("GameResult")
    -- if GameResult then
    -- 	GameResult:setVisible(true)
    -- else

    -- 	--发送准备
    -- 	NiuNiuSendHanle:readyNow(1)

    -- end

    --         end
    --     end)

    -- return view
end

function RoundEnding:drawCards(handCards, container, uid)
    for _, cardValue in pairs(handCards) do
        local card = Card.new()
        card:setCard(cardValue)
        card:setPosition(60 * (k1 - 1) + 50, 0)
        card:setScale(0.5)
        card:retain()
        table.insert(GROUP_RECORD[GAME_ROUND][uid].cards, card)
    end

    return container
end

-- function RoundEnding:getVariety(card)
--     return bit.band(card, 0xF0)
-- end

-- function RoundEnding:getValue(card)
--     local value = bit.band(card, 0x0F)
--     if value == 1 then
--         value = 14
--     end
--     return value
-- end

function RoundEnding:removeView()
    local s = NIUNIU_SCENE:getChildByName('RoundEnding')
    if s then
        s:removeSelf()
    end
end

return RoundEnding
