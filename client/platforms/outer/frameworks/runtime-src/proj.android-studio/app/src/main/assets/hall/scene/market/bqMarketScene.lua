local bqMarketScene = class("bqMarketScene")
local s

local cardList
local goldList
local bqCardList
local goldImgTable = {
[1] ="hall/res/images/market/markect_3.png",
[2] ="hall/res/images/market/markect_4.png",
[3] ="hall/res/images/market/markect_5.png",
[4] ="hall/res/images/market/markect_6.png",
[5] ="hall/res/images/market/markect_7.png",
[6] ="hall/res/images/market/markect_8.png",}

local roomCardImgTable = {
[1] ="hall/res/images/market/buy_fangka_small.png",
[2] ="hall/res/images/market/buy_fangka_small.png",
[3] ="hall/res/images/market/buy_fangka_middle.png",
[4] ="hall/res/images/market/buy_fangka_middle.png",
[5] ="hall/res/images/market/buy_fangka_big.png",
[6] ="hall/res/images/market/buy_fangka_big.png",}

function bqMarketScene:showScene(enterType)  --1是房卡，0是金币

	if shieldRecharging == true then
		dump("shieldRecharging")
		self:showShieldRechargingTips()
		return
	end

	-- local bqURL = "http://weixin.huanle507.com.cn/share/bq.html"
    s = cc.CSLoader:createNode("hall/res/csb/market/bqMarketScene.csb"):addTo(SCENENOW["scene"])
    if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 1920 then
        s:setScale(1280/1920)
    end

    --判断是否已经绑定代理
    if isCheckBindAgent then
        if USER_INFO["agentId"] ~= nil and USER_INFO["agentId"] ~= "" then
        else
            --绑定代理
            require("hall.BuyRoomCard.AgentScene"):showScene(0)

        end
    end

    local menu_lv = s:getChildByName("menu_lv")
    self.my_cars_plane = s:getChildByName("my_cars_plane"):removeAllChildren()
	self.goods_list_plane = s:getChildByName("goods_list_plane")

	local close_bt = s:getChildByName("close_bt")

	self.buy_gold_bt = menu_lv:getChildByName("buy_gold_bt")
	self.buy_card_bt = menu_lv:getChildByName("buy_card_bt")

	local btnFunc = function(sender,event)

		if  event == TOUCH_EVENT_BEGAN then
			sender:setScale(0.9)
		end

		if  event == TOUCH_EVENT_CANCELED then
			sender:setScale(1)
		end

		if 	event == TOUCH_EVENT_ENDED then

			sender:setScale(1.0)

			if sender == self.buy_gold_bt then

				self.buy_gold_bt:setEnabled(false)
				self.buy_card_bt:setEnabled(true)

				self:initGoodsData("diamond","show")

			elseif sender == self.buy_card_bt then

				self.buy_gold_bt:setEnabled(true)
				self.buy_card_bt:setEnabled(false)

				self:initGoodsData("roomCard","show")

			elseif sender == close_bt then
				self:removeScene()
			end

		end
	end

	close_bt:addTouchEventListener(btnFunc)
	self.buy_card_bt:addTouchEventListener(btnFunc)
	self.buy_gold_bt:addTouchEventListener(btnFunc)

    self.my_cars_plane:setVisible(false)
	self.goods_list_plane:setVisible(false)

	if 	onlyHasRoomCardMode == true then
		self.buy_gold_bt:removeFromParent()
		enterType = 1
	elseif onlyHasGoldMode == true then
		self.buy_card_bt:removeFromParent()
		enterType = 0
	end

	if 	enterType == 1 or  enterType == nil then
		self:initGoodsData("roomCard","show")
		self.buy_gold_bt:setEnabled(true)
		self.buy_card_bt:setEnabled(false)
	elseif enterType == 0 then
		self:initGoodsData("diamond","show")
		self.buy_gold_bt:setEnabled(false)
		self.buy_card_bt:setEnabled(true)
	end

end

function bqMarketScene:showShieldRechargingTips()
	local officialWechat = officialWechat or ""
	require("hall.GameTips"):showTips("提示", "", 3, "您可以联系微信客服" .. officialWechat .. "进行充值")
end

function bqMarketScene:initGoodsData(initGood,typ)

	if  cardList then

		if  typ ~= "init" then
			self.goods_list_plane:setVisible(true)
            self.my_cars_plane:setVisible(false)
		end

		self.goods_list_plane:removeAllChildren()

		if  initGood == "diamond" then
			self:showMerchandise(goldList)
		elseif  initGood == "roomCard" then
			self:showMerchandise(cardList)
		-- elseif  initGood == "bqCard" then
		-- 	self:showBqGoods(bqCardList)
		end
	else

	    local parm = {}
	    parm["device"] = "1"
	    parm["userId"] = USER_INFO["uid"]
	    parm["interfaceType"] = "J"

		cct.createHttRq({
	        url = HttpAddr .. "/goods/queryGoodsList",
	        date = parm,
	        type_= "GET",
	        callBack = function(data)

	            local responseData = data.netData
	            if responseData then
	                responseData = json.decode(responseData)
	                local data = responseData.data
	                if 	data then
	                	dump(data,"showGoods")

	                	if 	tolua.isnull(self.goods_list_plane) then
	                		return
	                	end

	                	local list = data.list

	                	cardList = {}
	                	goldList = {}
	                	bqCardList = {}

						table.sort(list,function(a,b) return a.price < b.price  end)

	        			for k,v in pairs(list) do
	    				    if tonumber(v.categoryType) == 0 then
	                            table.insert(cardList, v)
	                        elseif tonumber(v.categoryType) == 1 then
	                            table.insert(goldList, v)
	                        elseif tonumber(v.categoryType) == 2 then
	                        	table.insert(bqCardList, v)
	                        end

						end

						if  tolua.isnull(self.goods_list_plane) then
						    return
						end

						self.goods_list_plane:setVisible(true)
                        self.my_cars_plane:setVisible(false)

						if  initGood == "diamond" then
							self:showMerchandise(goldList)
						elseif  initGood == "roomCard" then
							self:showMerchandise(cardList)
						elseif  initGood == "bqCard" then
							-- self:showBqGoods(bqCardList)
						end

	                end
	            end

	        end})

	end
end


function bqMarketScene:showMerchandise(list)

    local oneLineCount = 3
    local addX = 200
    local beginX = 90
    local y = 58.5  --470 - math.floor(k/5.01) * 310

    -- local addY = 220

    local goodPlaneTable = {}

    self.my_cars_plane:removeAllChildren()
    self.my_cars_plane:setVisible(true)

    for i = 1, math.ceil(#list/oneLineCount) do
    	goodPlaneTable[i] = self.goods_list_plane:clone()
    	-- goodPlaneTable[i]:setVisible(true)
        self.my_cars_plane:pushBackCustomItem(goodPlaneTable[i])
    end

    for k,v in ipairs(list) do

        local buycardLayer
        if device.platform == "ios" then
            if isiOSVerify then
                buycardLayer = cc.CSLoader:createNode("hall/BuyRoomCard/buycardLayer_new.csb")
            else
                buycardLayer = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/BuyRoomCard/buycardLayer_new.csb")
            end
        else
            buycardLayer = cc.CSLoader:createNode("hall/BuyRoomCard/buycardLayer_new.csb")
        end

        local goods_list_plane = goodPlaneTable[math.ceil(k/oneLineCount-0.01)]
        local x = beginX + (k% (oneLineCount+0.01) - 1) * addX
        local cell_content_ly = buycardLayer:getChildByName("content_ly")
        cell_content_ly:removeFromParent():addTo(goods_list_plane)
        cell_content_ly:setPosition(cc.p(x,y))

        -- cell_content_ly:setScale(1.5)
        cell_content_ly:addTouchEventListener(

            function(sender,event)

                if event == TOUCH_EVENT_BEGAN then
                    cell_content_ly:setScale(0.9)
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then
                    cell_content_ly:setScale(1)
                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    cell_content_ly:setScale(1)

                    EnterAgentPayPage = false
                    self:openPayPage(v.goodsId,v.amount)
                end

            end)


        --商品名
        local goodName_tt = cell_content_ly:getChildByName("goodName_tt")

        --背景
        local bg_iv = cell_content_ly:getChildByName("bg_iv")
        -- local good_iv = cell_content_ly:getChildByName("good_iv")
       	-- 	  good_iv:ignoreContentAdaptWithSize(true)

        if 	v.categoryType == "0" then
	        if 	v.name then
	            goodName_tt:setString(require(NumberUtil_filePath):toWan(tonumber(v.name), 99999).."张")
	        end

       		-- good_iv:loadTexture(roomCardImgTable[k] or roomCardImgTable[6])
            -- bg_iv:loadTexture("hall/BuyRoomCard/image/coujiao/card_bg.png")
            bg_iv:loadTexture(roomCardImgTable[k] or roomCardImgTable[6])
        elseif 	v.categoryType == "1" then
	        if 	v.name then
	            goodName_tt:setString(require(NumberUtil_filePath):toWan(tonumber(v.name), 99999).."钻石")
	        end

	        -- good_iv:loadTexture(goldImgTable[k] or goldImgTable[6])
            bg_iv:loadTexture(goldImgTable[k] or goldImgTable[6])
        end

        --折扣
        local discount_ly = cell_content_ly:getChildByName("discount_ly")
        local discount_tt = discount_ly:getChildByName("discount_tt")
        -- if v.remark ~= nil and v.remark ~= "" and tonumber(v.remark) > 0 then
        --     discount_ly:setVisible(true)
        --     discount_tt:setString(v.remark)
        -- else
            discount_ly:setVisible(false)
        -- end

        -- local good_iv = cell_content_ly:getChildByName("good_iv")

        local buy_ly = cell_content_ly:getChildByName("buy_ly")
        buy_ly:setTouchEnabled(false)
        local goodPrice_tt = buy_ly:getChildByName("goodPrice_tt")
        if v.price then
            local price = v.price * 0.01
            goodPrice_tt:setString(tostring(price).."元")
        end

    end

end

function bqMarketScene:openPayPage(goodsId,amount)

    if isCheckBindAgentBeforeBuyCard then

        if USER_INFO["agentId"] ~= nil and USER_INFO["agentId"] ~= "" then
            require("hall.BuyRoomCard.PayChannelScene"):showScene(USER_INFO["uid"], goodsId, amount)
        else
            require("hall.BuyRoomCard.AgentScene"):showScene(bindAgentSendCard)
        end

    else
        require("hall.BuyRoomCard.PayChannelScene"):showScene(USER_INFO["uid"], goodsId, amount)
    end

end


function bqMarketScene:removeScene()

	if 	tolua.isnull(s) == false then
		s:removeFromParent()
	end

end

return bqMarketScene
