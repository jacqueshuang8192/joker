--
-- Author: Your Name
-- Date: 2017-09-05 19:21:38
--
local  PlayerPlaneOperator = class("PlayerPlaneOperator")

local  UserInfoPlaneOperator = require(TpackageName .. ".operator.UserInfoPlaneOperator")
local  CardPlaneOperator = require(TpackageName .. ".operator.CardPlaneOperator")

local promptCount = 0

function PlayerPlaneOperator:init(playerType, panel, uid)
    dump("---------------- PlayerPlaneOperator:init -----------")
	local headpanel = panel:getChildByName("head_panel")
    UserInfoPlaneOperator:init(playerType, headpanel, uid)
	local handCardPlane = panel:getChildByName("inhand_panel")
	CardPlaneOperator:init(playerType, handCardPlane)
	-- 下注
    -- self:initDao(panel)
    local img_left = panel:getChildByName("img_left")
    img_left:setVisible(false)
    local img_mid = panel:getChildByName("img_mid")
    img_mid:setVisible(false)
    if playerType == 1 then
        dump("aqaaaaaa")
        img_mid:setPositionX(handCardPlane:getPositionX())
    end
    local img_right = panel:getChildByName("img_right")
    img_right:setVisible(false)
    panel:getChildByName("txt_chips"):setVisible(false);
    UserInfoPlaneOperator:showkaipai(panel,false);
end

function PlayerPlaneOperator:relocate(panel)
    if panel then
	    local headpanel = panel:getChildByName("head_panel")
        UserInfoPlaneOperator:relocate(headpanel)
    end
end

function PlayerPlaneOperator:switchMode(panel, _type)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:switchMode(headpanel,_type)
end

function PlayerPlaneOperator:swtichCardBackImg(typeIndex)
	CardPlaneOperator:swtichCardBackImg(typeIndex)
end

function PlayerPlaneOperator:setBetChip(panel,value,flag)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:setBetChip(headpanel,value,flag)
end

function PlayerPlaneOperator:setTotalBetChip(panel,value,flag)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:setTotalBetChip(headpanel,value,flag)
end

function PlayerPlaneOperator:showBetEffect(panel,value)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:showBetEffect(headpanel,value)
end

function PlayerPlaneOperator:clearGameDatas(playerType,panel,stage)
	local headpanel = panel:getChildByName("head_panel")
    UserInfoPlaneOperator:clearGameDatas(playerType,headpanel,stage)
	local handCardPlane = panel:getChildByName("inhand_panel")
	CardPlaneOperator:clearGameDatas(playerType,handCardPlane,stage)
    -- 清抢庄头像框
    self:showGrabBankerFrame(panel, false)
    -- 清除玩家道杠数据
    self:initDaoPanel(panel,0)
    -- 牌型文本初始化
    local img_left = panel:getChildByName("img_left")
    img_left:setVisible(false)
    local img_mid = panel:getChildByName("img_mid")
    img_mid:setVisible(false)
    local img_right = panel:getChildByName("img_right")
    img_right:setVisible(false)
end

function PlayerPlaneOperator:showPlayerInfo(playerType, panel, userInfo, showBuyGoldButton)
	local headpanel = panel:getChildByName("head_panel")
   	return UserInfoPlaneOperator:showPlayerInfo(playerType,headpanel,userInfo,showBuyGoldButton)
end

function PlayerPlaneOperator:updateCoin(panel,value,orichip,uid)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:updateCoin(headpanel,value,orichip,uid)
end

function PlayerPlaneOperator:setCoin(panel,value)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:setCoin(headpanel,value)
end

function PlayerPlaneOperator:showHeadSymbol(panel, _type, flag)
    if panel then
	    local headpanel = panel:getChildByName("head_panel")
        UserInfoPlaneOperator:showHeadSymbol(headpanel,_type,flag)
        if _type=="banker" then
            if flag==true then
                local chips_panel=panel:getChildByName("chips_panel")
                local chips_pos=panel:convertToWorldSpace(chips_panel:getPosition())
                local guo_pos=(img_guo:getParent()):convertToWorldSpace(img_guo:getPosition())
                if guo_pos ~= chips_pos then
                    GUO_POS=chips_pos
                    local node_pos=img_guo:getPosition()
                    local new_guo_pos=(img_guo:getParent()):convertToNodeSpace(chips_pos)
                    new_guo_pos=cc.p(new_guo_pos.x,new_guo_pos.y-40)
                    local time=(math.sqrt((node_pos.x-new_guo_pos.x)*(node_pos.x-new_guo_pos.x)+(node_pos.y-new_guo_pos.y)*(node_pos.y-new_guo_pos.y)))/2500
                    local moveAction = cc.MoveTo:create(time,new_guo_pos)
                    img_guo:runAction(moveAction)
                end
            end
        end
    end
end

function PlayerPlaneOperator:setGrabBankerSymbol(panel,flag)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:setGrabBankerSymbol(headpanel,flag)
end

function PlayerPlaneOperator:setBetTimes(panel,times,flag)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:setBetTimes(headpanel,times,flag)
end

function PlayerPlaneOperator:setGrabBankerTimes(panel,times,flag)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:setGrabBankerTimes(headpanel,times,flag)
end

function PlayerPlaneOperator:setReadyStatus(panel, flag)
	local headpanel = panel:getChildByName("head_panel")
	UserInfoPlaneOperator:setReadyStatus(headpanel, flag)
end

function PlayerPlaneOperator:setEffectFrame(playerType,panel,_type,flag)
	if  panel then
		local headpanel = panel:getChildByName("head_panel")
		UserInfoPlaneOperator:setEffectFrame(playerType,headpanel,_type,flag)
	end
end

function PlayerPlaneOperator:beginPlayCard(panel,flag)
	local headpanel = panel:getChildByName("head_panel")
    UserInfoPlaneOperator:beginPlayCard(headpanel,flag)
end

function PlayerPlaneOperator:countFanAndShow(panel)
	local handCardPlane = panel:getChildByName("inhand_panel")
	CardPlaneOperator:countFanAndShow(handCardPlane)
end

function PlayerPlaneOperator:showCuoPai(cards,flag)
	CardPlaneOperator:showCuoPai(cards,flag)
end

function PlayerPlaneOperator:showCardKind(playerType,panel,cardKind)
	local handCardPlane = panel:getChildByName("inhand_panel")
	CardPlaneOperator:showCardKind(playerType,handCardPlane,cardKind)
end

function PlayerPlaneOperator:showCards(playerType, panel, cards,flag)
	local handCardPlane = panel:getChildByName("inhand_panel")
	CardPlaneOperator:showCards(playerType, handCardPlane, cards,flag)
end

function PlayerPlaneOperator:showDealCardsAnimation(playerType,panel,cards,cardEndIndex)
	local handCardPlane = panel:getChildByName("inhand_panel")
	CardPlaneOperator:showDealCardsAnimation(playerType,handCardPlane,cards,cardEndIndex)
end

function PlayerPlaneOperator:foldCard(playerType,panel,cards)
	local handCardPlane = panel:getChildByName("inhand_panel")
	CardPlaneOperator:foldCard(playerType,handCardPlane,cards)
end

function PlayerPlaneOperator:outCard(playerType,panel,cards)
	local handCardPlane = panel:getChildByName("inhand_panel")
	CardPlaneOperator:outCard(playerType,handCardPlane,cards)
end

--获取子控件table
function PlayerPlaneOperator:loadChildrenWidget(_node, _childrenTable)
    local function func(node, childrenTable)
        if node ~= nil and node:getChildrenCount() <= 0 then return end
        local cTable = node:getChildren()
        for i, v in ipairs(cTable) do
            childrenTable[v:getName()] = v
            func(v, childrenTable)
        end
    end
    if _childrenTable == nil then _childrenTable = {} end
    func(_node, _childrenTable)
    return _childrenTable
end

function PlayerPlaneOperator:showZhuangAttitude(panel, flag)
    local headpanel = panel:getChildByName("head_panel")
    UserInfoPlaneOperator:showZhuangAttitude(headpanel, flag)
end

function PlayerPlaneOperator:initPlayerDao(panel, value)
    self:initDao(panel)
    for i=1, DAO_COUNT do
        self:setDao(panel, i, value)
    end
end

function PlayerPlaneOperator:initDaoPanel(panel, value)
    local dao_panel = panel:getChildByName("dao_panel")
    local img_dao = panel:getChildByName("img_dao")
    -- 动态生成
    dao_panel:removeAllChildren()
    -- local dao_panel_width = dao_panel:getContentSize().width
    local dao_panel_height = dao_panel:getContentSize().height
    local img_dao_width = img_dao:getContentSize().width
    -- local img_dao_height = img_dao:getContentSize().height
    --local ori_x = (dao_panel_width - (DAO_COUNT*img_dao_width + (DAO_COUNT-1)*10)) / 2 + img_dao_width / 2
    --local ori_x = (dao_panel_width - (DAO_COUNT*img_dao_width + (DAO_COUNT-1)*10)) / 2 + img_dao_width / 2
    local ori_x = img_dao_width/2
    local ori_y = dao_panel_height / 2
    dump(DAO_COUNT,"DAO_COUNT---->>>>")
    for i=1, DAO_COUNT do
        local new_img_dao = img_dao:clone()
        new_img_dao:setAnchorPoint(cc.p(0.5, 0.5))
        new_img_dao:setName("dao_"..tostring(i))
        dao_panel:addChild(new_img_dao)
        new_img_dao:setPosition(ori_x, ori_y)
        local dao_fen = new_img_dao:getChildByName("txt_dao")
        dao_fen:setString("0")
        ori_x = ori_x + img_dao_width + 10
    end
    dao_panel:setVisible(false)
end

function PlayerPlaneOperator:showDaoPanel(panel, flag)
    local dao_panel = panel:getChildByName("dao_panel")
    dao_panel:setVisible(flag)
end

function PlayerPlaneOperator:setDao(panel, order, value,pos)
    local dao_panel = panel:getChildByName("dao_panel")
    if order <= 3 then
        local img_dao = dao_panel:getChildByName("dao_"..tostring(order))
        if img_dao then
            local dao_fen = img_dao:getChildByName("txt_dao")
            dao_fen:setString(tostring(value))
        end     
    end




    --飘金币效果
    -- if isGoldGame==0 then
    --     self:joinchip(panel, order, value,pos)
    -- end
end

function PlayerPlaneOperator:showResultSymbol(panel, flag, tag)
    local headpanel = panel:getChildByName("head_panel")
    UserInfoPlaneOperator:showResultSymbol(headpanel, flag, tag)
end

function PlayerPlaneOperator:openCards(playerType, panel, cardGroups)
	local handCardPlane = panel:getChildByName("inhand_panel")

	if handCardPlane then
		--todo
		CardPlaneOperator:openCards(playerType, handCardPlane, cardGroups)
	end

--[[	local left = panel:getChildByName("txt_left")
	local mid = panel:getChildByName("txt_mid")
	local right = panel:getChildByName("txt_right")

	if left and mid and right then
		--todo
		left:setVisible(false)
		mid:setVisible(false)
		right:setVisible(false)

		if #cardGroups == 1 then
			--todo
			mid:setVisible(true)

			local group = cardGroups[1]

			if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
	            --todo
	            mid:setString(PJ_GROUP_TYPE[group.type])
	        else
	            mid:setString(PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point])
	        end
		elseif #cardGroups == 2 then
			left:setVisible(true)
			right:setVisible(true)

			local group = cardGroups[2]

			if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
	            --todo
	            left:setString(PJ_GROUP_TYPE[group.type])
	        else
	            left:setString(PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point])
	        end

	        group = cardGroups[1]

			if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
	            --todo
	            right:setString(PJ_GROUP_TYPE[group.type])
	        else
	            right:setString(PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point])
	        end
		end
	end]]
end

function PlayerPlaneOperator:showCardsOnResultCsb(playerType, panel, cardGroups)
    local cards_panel = panel:getChildByName("cards_panel")
    dump(playerType, "showCardsOnResultCsb_playerType")
    dump(cardGroups, "showCardsOnResultCsb_cardGroups")
    if cards_panel then
        --todo
        CardPlaneOperator:showCardsOnResultCsb(playerType, cards_panel, cardGroups)
    end
    local txt_first = panel:getChildByName("txt_first")
    local txt_second = panel:getChildByName("txt_second")
    if txt_first and txt_second then
        --todo
        txt_first:setVisible(false)
        txt_second:setVisible(false)

        if #cardGroups == 1 then
            --todo
            txt_first:setVisible(true)

            local group = cardGroups[1]

            if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
                --todo
                txt_first:setString(PJ_GROUP_TYPE[group.type])
            else
                txt_first:setString(PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point])
            end
        elseif #cardGroups == 2 then
            txt_first:setVisible(true)
            txt_second:setVisible(true)

            local group = cardGroups[2]

            if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
                --todo
                txt_first:setString(PJ_GROUP_TYPE[group.type])
            else
                txt_first:setString(PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point])
            end

            group = cardGroups[1]

            if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
                --todo
                txt_second:setString(PJ_GROUP_TYPE[group.type])
            else
                txt_second:setString(PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point])
            end
        end
    end
end

function PlayerPlaneOperator:showGrabBankerFrame(panel, flag)
    local headpanel = panel:getChildByName("head_panel")
    UserInfoPlaneOperator:showGrabBankerFrame(headpanel, flag)
end

function PlayerPlaneOperator:showBankerFrame(panel, flag)
    local headpanel = panel:getChildByName("head_panel")
    UserInfoPlaneOperator:showGrabBankerFrame(headpanel, flag)
end

function PlayerPlaneOperator:openAllcall(playerType, panel, cardGroups, index)

    local handCardPlane = panel:getChildByName("inhand_panel")

    if handCardPlane then
        --todo
        CardPlaneOperator:openAllcall(playerType, handCardPlane, cardGroups, index)
    end

    local img_left = panel:getChildByName("img_left")
    local img_mid = panel:getChildByName("img_mid")
    local img_right = panel:getChildByName("img_right")

    if img_left and img_mid and img_right then
        --todo
        img_left:setVisible(false)
        img_mid:setVisible(false)
        img_right:setVisible(false)

        if #cardGroups == 1 then
            --todo
            img_mid:setVisible(true)

            local group = cardGroups[1]
            local mid_str = ""
            if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
                --todo
                mid_str = PJ_GROUP_TYPE[group.type]
            else
                mid_str = PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point]
            end
            local _, count = string.gsub(tostring(mid_str), "[^\128-\193]", "")
            img_mid:setScaleX(count/2)
            img_mid:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(mid_str)]..".png")
            -- 播放牌型音效

        elseif #cardGroups == 2 then
            img_left:setVisible(true)
            img_right:setVisible(true)
            if index == 2 then
                local group = cardGroups[2]
                local left_str = ""
                if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
                    --todo
                    left_str = PJ_GROUP_TYPE[group.type]
                else
                    left_str = PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point]
                end
                local _, count = string.gsub(tostring(left_str), "[^\128-\193]", "")
                img_left:setScaleX(count/2)
                img_left:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(left_str)]..".png")
                -- 牌型音效

            elseif index == 1 then
                local group = cardGroups[1]
                local right_str = ""
                if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
                    --todo
                    right_str = PJ_GROUP_TYPE[group.type]
                else
                    right_str = PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point]
                end
                local _, count = string.gsub(tostring(right_str), "[^\128-\193]", "")
                img_right:setScaleX(count/2)
                img_right:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(left_str)]..".png")
                -- 牌型音效

            end
        end
    end
end

function PlayerPlaneOperator:showAni4Big(playerType, panel, cardsGroup)
    local inhandPanel = panel:getChildByName("inhand_panel")
    if inhandPanel then
        CardPlaneOperator:showAni4Big(playerType, panel, inhandPanel, cardsGroup)
    end
end

function PlayerPlaneOperator:showCardsInResult(cards, panel, tag)
    local inhandPanel = panel:getChildByName("inhand_panel")
    CardPlaneOperator:showCardsInResult(cards, inhandPanel, tag)
end

function PlayerPlaneOperator:showCardsType(panel, _type, tag,cards)
    dump(tag,tostring(_type), "----- showCardsType -----")
    
    UserInfoPlaneOperator:showkaipai(panel,false)
    dump("比牌--------------------------------------------------------------------")

    local img_left = panel:getChildByName("img_left")
    local img_mid = panel:getChildByName("img_mid")
    local img_right = panel:getChildByName("img_right")
    local _, count = string.gsub(tostring(_type), "[^\128-\193]", "")
    if img_left and img_mid and img_right then
        if tag == "right" then
            img_right:setScaleX(count/2)
            img_right:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(_type)]..".png")
            --img_right:setString(LoadCard.changeCardsString(cards[1],cards[2]))
            img_right:setVisible(true)
        elseif tag == "mid" then
            img_mid:setScaleX(count/2)
            img_mid:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(_type)]..".png")
            --img_mid:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(_type)]..".png")
            img_mid:setVisible(true)
        elseif tag == "left" then
            img_left:setScaleX(count/2)
            img_left:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(_type)]..".png")
            --img_left:setString(LoadCard.changeCardsString(cards[1],cards[2]))
            img_left:setVisible(true)
        end
    end
end

function PlayerPlaneOperator:showPromptCards(panel)
    print(debug.traceback())
    local count = #PJ_AVAI_CARD_GROUPS
    promptCount = promptCount % count + 1
    local nowCardsGroup = PJ_AVAI_CARD_GROUPS[promptCount]
    if nowCardsGroup.cardsCount == 2 then
        local cardsGroup = nowCardsGroup.cards
        local handCardPlane = panel:getChildByName("inhand_panel")
        CardPlaneOperator:showPromptCards(handCardPlane, cardsGroup)
    end
end

function PlayerPlaneOperator:showTestCards(cards)
    CardPlaneOperator:showTestCards(cards)
end

function PlayerPlaneOperator:showend(plane,chip)
    if not plane then
        return
    end
    local txt_roundResult = plane:getChildByName("txt_chips")

    if chip >= 0 then
        txt_roundResult:setFntFile(TpackageName .. "/font/num_add.fnt")
        txt_roundResult:setString("+" .. chip)
    else
        txt_roundResult:setFntFile(TpackageName .. "/font/num_sub.fnt")
        txt_roundResult:setString(chip)
    end
    txt_roundResult:setVisible(true)
    local pos=txt_roundResult:getPosition()
    txt_roundResult:setPosition(cc.p(pos.x,pos.y-120))
    pos=txt_roundResult:getPosition()
    --local scaleAction1 = cc.ScaleTo:create(0.2, 2.0)
    --local scaleAction2 = cc.ScaleTo:create(0.2, 1.5)
    --local seq = cc.Sequence:create(scaleAction1, scaleAction2)
    local moveAction = cc.MoveTo:create(0.1,cc.p(pos.x,pos.y+120))
    txt_roundResult:runAction(moveAction)
end

function PlayerPlaneOperator:showchip(panel,falg)
    local txt_chips = panel:getChildByName("txt_chips")
    if txt_chips then
        txt_chips:setVisible(falg)
    end
end

function PlayerPlaneOperator:joinchip(panel,order,txt_chips,pos)
    if txt_chips<=0 then
        return
    end

    local chips_panel = panel:getChildByName("chips_panel")
    local chips=chips_panel:getChildren();
    if order<#chips+1 then
        return
    end
    local img_chips = panel:getParent():getChildByName("img_chips")
    local new_img_chips=img_chips:clone()
    new_img_chips:getChildByName("txt_chip"):setString(txt_chips)
    pos=chips_panel:convertToNodeSpace(pos)
    new_img_chips:setPosition(pos)
    chips_panel:addChild(new_img_chips)
    local moveAction = cc.MoveTo:create(0.1,cc.p(math.random(50,100),math.random(50,100)))
    new_img_chips:runAction(moveAction)
end

function PlayerPlaneOperator:getIntPart(x)
    if x <= 0 then
       return math.ceil(x);
    end
    
    if math.ceil(x) == x then
       x = math.ceil(x);
    else
       x = math.ceil(x) - 1;
    end
    return x;
end

function PlayerPlaneOperator:deletechip(panel,chips,pos)
    if not panel then
        return
    end

    if not pos then
        return
    end

    local chips_panel = panel:getChildByName("chips_panel")
    local chip_s=chips_panel:getChildren();
    if chips==0 then
        chips_panel:removeAllChildren()
        return
    end
    if #chip_s>0 then
        local pos1=chips_panel:convertToNodeSpace(pos)
        dump("随机数",pos1.x,pos1.y)
        for i,chip in pairs(chip_s) do
            local ondelayAction = cc.DelayTime:create(0.1*i)
            local chip_pos=chip:getPosition()
            local time=(math.sqrt((chip_pos.x-pos1.x)*(chip_pos.x-pos1.x)+(chip_pos.y-pos1.y)*(chip_pos.y-pos1.y)))/2000
            local moveAction = cc.MoveTo:create(time,pos1)
            local delayAction = cc.DelayTime:create(0.2)
            local seq = cc.Sequence:create(ondelayAction,moveAction,delayAction,cc.RemoveSelf:create())
            chip:runAction(seq)
        end
    end
    
    local chushu
    if isGoldGame==0 then
        chushu=100
    else
        chushu=10
    end
    local chipCount=self:getIntPart((math.sqrt(chips*chips))/chushu)
    local chipRemainder=(math.sqrt(chips*chips))%chushu
    local pos2
    local guo_pos
    if chips<0 then
        pos2=panel:getParent():convertToNodeSpace(pos)
        guo_pos=panel:getParent():convertToNodeSpace(GUO_POS)
    elseif chips>0 then
        guo_pos=panel:getParent():convertToNodeSpace(pos)
        pos2=panel:getParent():convertToNodeSpace(GUO_POS)
    else
        return
    end
    SCENENOW["scene"]:performWithDelay(function()
        local img_chips = panel:getParent():getChildByName("img_chips")
        if chipCount>10 then
            chipCount=10
        end
        for i=0,chipCount+1 do
            if i==chipCount and chipRemainder==0 then
                break;
            end
            local new_img_chips=img_chips:clone()
            if i==chipCount then
                new_img_chips:getChildByName("txt_chip"):setString(chipRemainder)
            else
                if isGoldGame==0 then
                    new_img_chips:getChildByName("txt_chip"):setString("")
                else
                    new_img_chips:getChildByName("txt_chip"):setString(10)
                end
            end
            new_img_chips:setPosition(pos2)
            panel:getParent():addChild(new_img_chips)
            local time=(math.sqrt((guo_pos.x-pos2.x)*(guo_pos.x-pos2.x)+(guo_pos.y-pos2.y)*(guo_pos.y-pos2.y)))/2000
            local ondelayAction = cc.DelayTime:create(0.02*i)
            local moveAction = cc.MoveTo:create(time,guo_pos)
            local delayAction = cc.DelayTime:create(0.2)
            local seq = cc.Sequence:create(ondelayAction,moveAction,delayAction,cc.RemoveSelf:create())
            new_img_chips:runAction(seq)
        end
    end,0.7)
end

function PlayerPlaneOperator:joinCards(plane,flag)
    CardPlaneOperator:joinCards(plane:getChildByName("inhand_panel"),flag)
end

function PlayerPlaneOperator:showkaipai(plane,flag)
    UserInfoPlaneOperator:showkaipai(plane,flag)
end

function PlayerPlaneOperator:setCardRecover()
    CardPlaneOperator:setCardRecover()
end

return PlayerPlaneOperator