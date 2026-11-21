--[[
* author:   zwm
* date:     2020-09-16
* describe: 玩家信息节点绑定
--]]

local Card_Base = "NewNiuniu/res/image/card/"

local GameUserCell = class(
    'GameUserCell',
    function()
        return display.newNode()
    end
)

function GameUserCell:ctor(type, data)
	local csbPath = "NewNiuniu/res/csb/"
	if type == "my" then
		csbPath = csbPath.."userMyNode.csb"
	elseif type == "top" then
		csbPath = csbPath.."userTopNode.csb"
	elseif type == "left" then
		csbPath = csbPath.."userLeftCell.csb"
	elseif type == "right" then
		csbPath = csbPath.."userRightCell.csb"
	end
	self._headType = type
	if device.platform == 'ios' then
        if isiOSVerify then
            self.csbNode = cc.CSLoader:createNode(csbPath):addTo(self)
        else
            self.csbNode =
                cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() ..csbPath):addTo(self)
        end
    else
        self.csbNode = cc.CSLoader:createNode(csbPath):addTo(self)
    end
    DESIGN_SCREEN_WIDTH = 1920
    DESIGN_SCREEN_HEIGHT = 1080

    -- SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    -- SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    self.csbNode:setScale(128 / 192)--, 72 / 108

    self._userInfoData = data
    self:_toGetObj( self.csbNode )
    self:_init(data)

    if type == "my" then
    	self:setMustNodeToCenter()
    end
end

function GameUserCell:_toGetObj( node )
    if node == nil then return end

    if node.getName then
        --去掉csb命名的空格，加一层括号，只返回格式化后的字符串
        local name = (string.gsub(node:getName(), "^%s*(.-)%s*$", "%1")) 
        self[name] = node
    end

    local child = node:getChildren()
    if #child ~= 0 then
        for i, v in ipairs( child or {} ) do
            self:_toGetObj(v)
        end
    end
end

function GameUserCell:setMustNodeToCenter()
	local pos = self.player_plane:convertToNodeSpace(cc.p(640*self:_getScaleParam2(), 0))
	local offsetX = pos.x - self.inhand_plane:getPositionX()
	self._cardOffset = offsetX
	print("setMustNodeToCenter --------------------", offsetX)
	self.inhand_plane:setPositionX(pos.x)
	self.cardType:setPositionX(pos.x)
end

function GameUserCell:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    print("ViewBaseLayer _getScaleParam2-------", (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0)))
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function GameUserCell:_init(data)
	self:clearUserStatus()
	self:initUserInfo(data)
end

function GameUserCell:initUserInfo(data)
	self.name_txt:setString(require('hall.GameCommon'):formatNick(data.nick, 4) or "")
	self:setCoin(data.coins)
	self:setUserHeadImg(data)
	self:showGameingState(data.gameingData)

	self.cardType:ignoreContentAdaptWithSize(true)
	if self._headType ~= "my" then
		self.cardType:setScale(0.8)
	end
end

function GameUserCell:showGameingState(data)
	print("GameUserCell:showGameingState ------------------", debug.traceback())
	dump(data, "showGameingState == ")
	if data.user_status == nil then 
		if self._headType == "my" then
			g_mainScene.gameOptLayer.btnReady:setVisible(true)
		end
		return 
	end

	if self._headType == "my" then
		if data.user_status == 0 or data.user_status == nil then -- 玩家没准备
			g_mainScene.gameOptLayer.btnReady:setVisible(true)
		elseif data.user_status == 1 then -- 玩家已经准备
			self.ready_img:setVisible(true)
		elseif data.user_status == 2 then -- 等待用户抢庄
			local grabLst = {}
			for i,v in ipairs(g_mainScene.grab_times or {}) do
				table.insert(grabLst, v)
			end
			g_mainScene.gameOptLayer:showGrabBankerBtn(grabLst)
			if data.keTuizhu > 0 then
				self.max_tuizhu:setString(string.format("可推注%d倍",data.keTuizhu))
			end
		elseif data.user_status == 3 then -- 用户放弃抢庄
			self.grab_not_banker_img:setVisible(true)
			if data.keTuizhu > 0 then
				self.max_tuizhu:setString(string.format("可推注%d倍",data.keTuizhu))
			end
		elseif data.user_status == 4 then -- 玩家已经抢庄
			self.grab_banker_img:setVisible(true)
			self.grab_banker_times_txt:setVisible(true)
			self.grab_banker_times_txt:setString(data.user_base_calltime or 1)
			if data.keTuizhu > 0 then
				self.max_tuizhu:setString(string.format("可推注%d倍",data.keTuizhu))
			end
		elseif data.user_status == 5 then -- 等待玩家下注
			if USER_INFO.uid == g_mainScene.BANKER_UID then
				return
			end

			local betLst = string.split(g_mainScene.gameConfig.times, ",")
			if data.keTuizhu > 0 then
				table.insert(betLst, data.keTuizhu)
			end
			g_mainScene.gameOptLayer:showBetBtn(betLst)
		elseif data.user_status >= 6 and data.user_status <= 8 then -- 玩家已经下注
			if g_mainScene.BANKER_UID ~= USER_INFO.uid then
				self.chip_img:setVisible(true)
				self.bet_times_txt:setString(data.user_base_calltime or "1")
			else
				self.chip_img:setVisible(true)
			end

			if data.user_status == 7 then -- 等待玩家出牌
				g_mainScene.gameOptLayer:setOptCardsVisible(true)
			end

		elseif data.user_status == 9 then -- 玩家还没开始玩(处理中途加入的玩家)

		elseif data.user_status == 10 then -- 公牛庄家升庄等操作
			if g_isWatch > 0 then
				g_mainScene.gameGongNiuOptLayer:setOptCardsVisible(true, g_mainScene.bankerOptState)
			end
		end
	else
		dump(data, "showGameingState data == ")
		if data.user_status == 0 or data.user_status == nil then -- 玩家没准备
			-- g_mainScene.gameOptLayer.btnReady:setVisible(true)
		elseif data.user_status == 1 then -- 玩家已经准备
			self.ready_img:setVisible(true)
		elseif data.user_status == 2 then -- 等待用户抢庄
			if data.keTuizhu > 0 then
				self.max_tuizhu:setString(string.format("可推注%d倍",data.keTuizhu))
			end
		elseif data.user_status == 3 then -- 用户放弃抢庄
			self:showQiangZhuangStatus(0)
			if data.keTuizhu > 0 then
				self.max_tuizhu:setString(string.format("可推注%d倍",data.keTuizhu))
			end
		elseif data.user_status == 4 then -- 玩家已经抢庄
			self:showQiangZhuangStatus(data.user_base_calltime)
			if data.keTuizhu > 0 then
				self.max_tuizhu:setString(string.format("可推注%d倍",data.keTuizhu))
			end
		elseif data.user_status >= 6 and data.user_status <= 8 then -- 玩家已经下注
			if g_mainScene.BANKER_UID ~= USER_INFO.uid then
				self.chip_img:setVisible(true)
				self.bet_times_txt:setString(data.user_base_calltime or "1")
			end
		end
	end

	if (data.user_status >= 2 and data.user_status <= 6) or data.user_status == 8 then
		for i,v in ipairs(data.user_base_out_cards or {}) do
			self:setCardsValue(data.user_base_out_cards, i)
		end
	elseif data.user_status == 7 then
		for i,v in ipairs(data.user_base_out_cards or {}) do
			self:setCardsValue(data.user_base_out_cards, i)
		end
	end
end

function GameUserCell:setCoin(value)
    local goldStr = ''
    value = value / 100
    if value > 99999 then
        local finalChipTxt = tostring(value / 10000)
        if string.len(finalChipTxt) <= 4 then
            goldStr = string.format('%.1f', finalChipTxt) .. '万'
        else
            goldStr = string.format('%.2f', finalChipTxt) .. '万'
        end
    else
        goldStr = tostring(value)
    end

    self.chip_txt:setString(goldStr)
end

function GameUserCell:setUserHeadImg(data)
	local headSize = 118
    -- self.head_img:loadTexture(defaultHead) --先加载默认头像，解决头像请求超时会显示错的问题
    headSize = self.head_img_bg:getContentSize().width - 20
    local otherInfo = json.decode(data.otherInfo) or {}
    local addres = otherInfo.addres
    local ip = otherInfo.ip
    require('hall.GameCommon'):getUserHead(
        data.icon_url,
        data['uid'],
        data['sex'],
        self.head_img,
        headSize,
        false,
        data.nick,
        false,
        ip,
        addres
    )
end

function GameUserCell:setReadVisible(b)
	self.ready_img:setVisible(b)
end

function GameUserCell:setZhuangVisible(b)
	self.zhuang_flag:setVisible(b)
end

function GameUserCell:setRoomOwnVisible(b)
	self.fangzhutip_img:setVisible(b)
end

function GameUserCell:setEffectKuangVisible(b)
	self.effect_frame:setVisible(b)
end

function GameUserCell:showBetScore(value)
	self.chip_img:setVisible(true)
	self.bet_times_txt:setString(value or "0")
end

function GameUserCell:showQiangZhuangStatus(state)
	if state == 0 then
		self.grab_not_banker_img:setVisible(true)
	else
		self.grab_not_banker_img:setVisible(false)
		self.grab_banker_img:setVisible(true)
		self.grab_banker_times_txt:setVisible(true)
		self.grab_banker_times_txt:setString(string.format("x%d", state))
	end
end

function GameUserCell:clearQiangZhuangStatus()
	self.grab_not_banker_img:setVisible(false)
	self.grab_banker_img:setVisible(false)
	self.grab_banker_times_txt:setVisible(false)
end

function GameUserCell:showTuizhuValue(value)
	if value > 0 then
		self.max_tuizhu:setString(string.format("可推注%d倍", value))
	end
end

function GameUserCell:hideTuizhuValue()
	self.max_tuizhu:setString("")
end

function GameUserCell:clearAllCards()
	local minY = 300
	for i = 1, 5 do
		self["card"..i]:loadTexture("NewNiuniu/res/image/card_back.png")
		self["card"..i]:setVisible(false)
		local posY = self["card"..i]:getPositionY()
		if posY < minY then
			minY = posY
		end
	end
	for i = 1, 5 do
		self["card"..i]:setPositionY(minY)
	end
end

function GameUserCell:showCardsValue(cards, idxs)
	if idxs ~= nil and type(idxs) == "table" then
		dump(idxs, "showCardsValue == ")
		for i,v in ipairs(idxs or {}) do
			self:cardFilpAni(self["card"..v], cards[v])
		end
		
	elseif idxs == nil then
		for i, v in ipairs(cards or {}) do
			print("showCardsValue ---------------- ", i, cards[i])
			if cards[i] > 0 then
				self:cardFilpAni(self["card"..i], cards[i])
			end
		end
	end
end

function GameUserCell:cardFilpAni(cardNode, cardValue)
	cardNode:setVisible(true)
	local to_a = cc.ScaleTo:create(0.1, 0.1, 1)
	local path = self:getCardPath(cardValue)
    local call_f =
        cc.CallFunc:create(
        function()
        	print("cardFilpAni ------------------- path = ", path)
			cardNode:loadTexture(path)
        end
    )
    local to_b = cc.ScaleTo:create(0.1, 1, 1)
    local seqP2 = cc.Sequence:create(to_a, call_f, to_b)
    cardNode:runAction(seqP2)
end

function GameUserCell:setCardsValue(cards, idx)
	if idx ~= nil then
		local path = self:getCardPath(cards[idx])
		self["card"..idx]:setVisible(true)
		self["card"..idx]:loadTexture(path)
	else
		for i, v in ipairs(cards or {}) do
			local path = self:getCardPath(card)
			self["card"..i]:setVisible(true)
			self["card"..i]:loadTexture(path)
		end
	end
end


function GameUserCell:getCardPath(card)
	print("getCardPath -------------------------", card)
	local color = self:getVariety(card)
	local value = self:getValue(card)
	
	local colorExchange = {[0x00] = "diamonds", [0x10] = "clubs", [0x20] = "hearts", [0x30] = "spades", [0x40] = "laizi"}
	return Card_Base..string.format("%s_%02d.png", colorExchange[color], value)
end

function GameUserCell:getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
function GameUserCell:getValue(card)
    local value = bit.band(card, 0x0F)
    -- if value == 1 then
    --     value = 14
    -- end

    return value
end

function GameUserCell:showCardBack(size)
	if size == nil or size <= 1 then return end

	for i = 1, size do
		self["card"..i]:setVisible(true)
	end
end

function GameUserCell:showCardBackByIdx(idx)
	if idx == nil or idx > 5 then return end

	self["card"..idx]:setVisible(true)
end

function GameUserCell:showSinglerResult(score)
	self.score_txt:setVisible(true)
    score = score / 100
    if score > 0 then
        str = '+' .. tostring(score)
        self.score_txt:setFntFile(TpackageName .. '/res/image/userUI/win_num.fnt')
    else
        str = tostring(score)
        self.score_txt:setFntFile(TpackageName .. '/res/image/userUI/lose_num.fnt')
    end

    self.score_txt:setString(str)
end

function GameUserCell:showCardType(type, time)
	local cardType = self.cardType
	local fnt = TpackageName .. 'res/font/cardType_yellow.fnt'
    if type >= 11 then
        fnt = TpackageName .. 'res/font/cardType_red.fnt'
    end
    self.cardType:removeChildByName("times")

	self.cardType:setVisible(true)
	self.cardType:loadTexture(string.format("NewNiuniu/res/image/CardType/result_%d.png", type), 0)
	local scale = self.cardType:getScale()
	local to_a = cc.ScaleTo:create(0.1, scale*1.8)
	-- local path = self:getCardPath(cardValue)
    local call_f =
        cc.CallFunc:create(
        function()
        	if time > 1 then
	        	local size = cardType:getContentSize()
			    local card_type_times_txt = ccui.TextBMFont:create('x' .. time, fnt)
			    card_type_times_txt:setAnchorPoint(1, 0)
			    card_type_times_txt:setPosition(size.width, 0)
			    card_type_times_txt:addTo(cardType)
			    card_type_times_txt:setName("times")
			end
        end
    )
    local to_b = cc.ScaleTo:create(0.3, scale)
    local seqP2 = cc.Sequence:create(to_a,  to_b)--call_f,
    self.cardType:runAction(seqP2)

    -- local size = cardType:getContentSize()
    -- local card_type_times_txt = ccui.TextBMFont:create('x' .. time, fnt)
    -- card_type_times_txt:setAnchorPoint(1, 0)
    -- card_type_times_txt:setPosition(size.width, 0)
    -- card_type_times_txt:addTo(cardType)
end

--亮牌
function GameUserCell:showOpenCards(cards, lastCard)
	self:showCardsValue(cards)
	for i, v in ipairs(cards) do
		if v == lastCard then
			self["card"..i]:runAction(cc.moveBy(0.2, cc.p(0, 50)))
		end
	end
end

function GameUserCell:upLastCard(cards, lastCard)
	for i,v in ipairs(cards) do
		if v == lastCard then
			self["card"..i]:setPositionY(self["card"..i]:getPositionY() + 30)
		end
	end
end

-- function GameUserCell:showGrabOpt(opt)
-- 	if opt == nil then return end

-- 	if opt == 0 then
-- 		self.grab_not_banker_img:setVisible(true)
-- 	else
-- 		self.grab_banker_img:setVisible(true)
-- 		self.grab_banker_times_txt:setVisible(true)
-- 		self.grab_banker_times_txt:setString("X"..opt)
-- 	end
-- end

function GameUserCell:clearUserStatus()
	self.effect_frame:setVisible(false)
	self.grab_banker_img:setVisible(false)
	self.grab_banker_times_txt:setVisible(false)
	self.grab_not_banker_img:setVisible(false)
	self.max_tuizhu:setString("")
	self.fangzhutip_img:setVisible(false)
	self.chip_img:setVisible(false)
	self.zhuang_flag:setVisible(false)
	self.ready_img:setVisible(false)
	self.network_img:setVisible(false)
	self.score_txt:setVisible(false)
	self.cardType:setVisible(false)
	self:clearAllCards()
end

function GameUserCell:clearUserForClickReady()
	self.effect_frame:setVisible(false)
	self.grab_banker_img:setVisible(false)
	self.grab_banker_times_txt:setVisible(false)
	self.grab_not_banker_img:setVisible(false)
	self.max_tuizhu:setString("")
	self.fangzhutip_img:setVisible(false)
	self.chip_img:setVisible(false)
	self.zhuang_flag:setVisible(false)
	self.network_img:setVisible(false)
	self.score_txt:setVisible(false)
	self.cardType:setVisible(false)
	self:clearAllCards()
end

function GameUserCell:setNetworkState(flag)
	self.network_img:setVisible(flag)
end

return GameUserCell