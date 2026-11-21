local SendHandle = require("zhajinhua_jb.src.handle.SendHandle")
local OprorateBtn = class("OprorateBtn")

function OprorateBtn:ctor(GameSceneView)
	self.GameSceneView = GameSceneView
	self.hall_1 = GameSceneView.hall_1
	self:initUI()
	self:initEvent()
end

function OprorateBtn:initUI()
    self.btn_kan = self.hall_1.btn_kan:hide()
    self.btn_qi = self.hall_1.btn_qi:hide()
    self.btn_bi = self.hall_1.btn_bi:hide()
    self.btn_jia = self.hall_1.btn_jia:hide()
    self.btn_gen = self.hall_1.btn_gen:hide()
	self.btn_xue = self.hall_1.btn_xue:hide()
	self.btn_cuo = self.hall_1.btn_cuo:hide()
    self.chips_vw = self.hall_1.chips_vw:hide()
    self.chips = self.hall_1.chips_vw.chips
	self.chip_btn1 = self.hall_1.chip_btn1:hide()
	self.chip_btn2 = self.hall_1.chip_btn2:hide()
	self.chip_btn3 = self.hall_1.chip_btn3:hide()
	self.chip_btn4 = self.hall_1.chip_btn4:hide()
	self.chip_btn5 = self.hall_1.chip_btn5:hide()
	self.chip_btn6 = self.hall_1.chip_btn6:hide()
	self.chip_btn7 = self.hall_1.chip_btn7:hide()
end

function OprorateBtn:initEvent()
    self.btn_qi:onClick(handler(self, self.onClick_qi), true)
    self.btn_bi:onClick(handler(self, self.onClick_bi), true)
    self.btn_jia:onClick(handler(self, self.onClick_jia), true)
    self.btn_gen:onClick(handler(self, self.onClick_gen), true)
    self.btn_xue:onClick(handler(self, self.onClick_xue), true)
    self.btn_cuo:onClick(handler(self, self.onClick_cuo), true)
    self.btn_kan:onClick(handler(self, self.onClick_kan), true)
    self.chips_vw:onClick(function(  )
        self.chips_vw:hide()
    end)
end

function OprorateBtn:clearData()
	self.btn_qi:hide()
    self.btn_bi:hide()
    self.btn_jia:hide()
    self.btn_gen:hide()
	self.btn_xue:hide()
	self.btn_cuo:hide()
    self.hall_1.chips_vw:hide()
    self.btn_kan:hide()

    for _, userInfo in pairs(g_317.userInfos) do
        local UserInfoView = self.GameSceneView:getPlayerBySeatId( userInfo.seat_id )
        if UserInfoView then
            UserInfoView.img_2:setTouchEnabled(false)
        end
    end
end

function OprorateBtn:onClick_kan(event)
    SendHandle:CLI_SEE_CARD()
end

function OprorateBtn:onClick_qi(event)
    SendHandle:CLI_DIU_CARD()
    self:clearData()
end

function OprorateBtn:onClick_bi(event)
    local peoplenum = 0
    local is_compare_seat_id = 0
    for i, userInfo in pairs(g_317.userInfos) do
        if g_317.isDiu[userInfo.uid] == nil and userInfo.if_ready == 1 then
            peoplenum = peoplenum + 1
            local seat_id = userInfo.seat_id
            if seat_id ~= g_317.my_seat_id then
                is_compare_seat_id = seat_id
            end
        end
    end
    if peoplenum == 2 then
        SendHandle:CLI_BI_CARD(is_compare_seat_id)
        self:clearData()
    else
       for _, userInfo in pairs(g_317.userInfos) do
            local uid = userInfo.uid
            local UserInfoView = self.GameSceneView:getPlayerBySeatId( userInfo.seat_id )
            if uid ~= USER_INFO.uid and g_317.isDiu[uid] ~= 1 then
                UserInfoView:isShowLight(true) 
                UserInfoView.img_2.seat_id = userInfo.seat_id
                dump(userInfo,"bipaisdfsdf")
                UserInfoView.img_2:onClick(function (event)
                    dump(event.target.seat_id)
                    SendHandle:CLI_BI_CARD(event.target.seat_id)
                    self:clearData()
                end)
            else
                UserInfoView:isShowLight(false) 
            end
        end
    end
end



function OprorateBtn:onClick_jia(event)
    self.chips_vw:show()
    self.chips:removeAllChildren()

    local size = self.chip_btn1:getContentSize()
    local cardWidth = size.width + 20
    local cardHeight = size.height
    local size = self.chips:getContentSize()
    local userCount = #g_317.zhus - 1
    local oriX = (size.width - cardWidth * userCount ) / 2 
    local oriY = size.height / 2
    for idx, chip in ipairs(g_317.zhus) do
        local item = self["chip_btn"..idx]:clone()
        item:show()
        GameUtils.setNodeNameBindObj(item)
        self.chips:addChild(item)
        local x = oriX + (idx - 1) * cardWidth
        item:setPosition(cc.p(x, oriY))
        item:onClick(function(event)
            local value = event.target.value
            SendHandle:CLI_JIA_CARD(value)    
            self:clearData()
        end, true)
        if chip < g_317.now_zhu then
            item:setOpacity(80)
		    item:setTouchEnabled(false)
        end
        local now_zhu = chip
        if g_317.isKan[USER_INFO.uid] == 1 then
            now_zhu = now_zhu * 2
        end
        item.value = now_zhu
        item.txt:setString(now_zhu / 100)
    end
end

function OprorateBtn:onClick_gen(event)
	SendHandle:CLI_GEN_CARD()
    self:clearData()
end

function OprorateBtn:onClick_xue(event)
    if g_317.isAllin > 0 then
        SendHandle:CLI_BET_ALLIN(0)
        return
    end

    self.chips_vw:show()
    self.chips:removeAllChildren()
    local size = self.chip_btn1:getContentSize()
    local cardWidth = size.width + 20
    local cardHeight = size.height
    local size = self.chips:getContentSize()
    local userCount = #g_317.allZhus - 1
    local oriX = (size.width - cardWidth * userCount ) / 2 
    local oriY = size.height / 2

    local startIdx = 7 - #g_317.allZhus
    for idx, chip in ipairs(g_317.allZhus) do
        local item = self["chip_btn"..idx+startIdx]:clone()
        item:show()
        GameUtils.setNodeNameBindObj(item)
        self.chips:addChild(item)
        local x = oriX + (idx - 1) * cardWidth
        item:setPosition(cc.p(x, oriY))
        item:onClick(function(event)
            local value = event.target.value
            SendHandle:CLI_BET_ALLIN(value)    
            self:clearData()
        end, true)

        if g_317.isKan[USER_INFO.uid] then
            chip = chip * 2
        end
        item.txt:setString(chip / 100)
        item.value = idx
    end

end

function OprorateBtn:onClick_cuo(event)
    g_317.isCuoPai = true
    SendHandle:CLI_SEE_CARD()
end

function OprorateBtn:showButton(can_compare, isAllin)
	isAllin = isAllin or 0
    local isQi = true
	local isGen = false
    local isJia = false
	local isBi = true
    local isShowAllin = false  -- 是否显示火拼
    
    self.btn_qi:show()
    self.btn_jia:show()
    self.btn_gen:show()
    self.btn_bi:show()
    self.btn_xue:show()

    self.btn_qi:setTouchEnabled(true)
    self.btn_qi:setOpacity(255)
    self.btn_jia:setTouchEnabled(true)
    self.btn_jia:setOpacity(255)
    self.btn_gen:setTouchEnabled(true)
    self.btn_gen:setOpacity(255)
    self.btn_bi:setTouchEnabled(true)
    self.btn_bi:setOpacity(255)
    self.btn_xue:setTouchEnabled(true)
    self.btn_xue:setOpacity(255)
    if isAllin == 0 then
		isGen = true
		isJia = true
	end
    if g_317.isAllin > 0 then
		isGen = false
		isJia = false
		isBi = false
    end

    if can_compare == 1 then
		isBi = true
	elseif g_317.now_turns <= g_317.min_pk_round then
		isBi = false
    end

    if g_317.now_turns >= g_317.min_allin_round then
        local allZhus = g_317.allZhus[1]
        local userInfo = g_317.userInfos[USER_INFO.uid]
		if allZhus and allZhus <= userInfo.m_chips then
			isShowAllin = true
		end
    end
    -- 当玩家分数不够时，只能弃牌或全押
    local now_zhu = g_317.now_zhu
    if g_317.isKan[USER_INFO.uid] == 1 then
        now_zhu = now_zhu * 2
    end
    if (g_317.table_chips - now_zhu) <= 0 then
        isAllin = 1
    end

    if isAllin == 1 then-- allin不能比牌
		isBi = false
        isShowAllin = true
    end

    if g_317.isCanAllin == 1 and g_317.countUserAllin == 1 and isShowAllin then
        isShowAllin = true
	else
        isShowAllin = false
    end
    
    if isQi == false then
        self.btn_qi:setTouchEnabled(false)
        self.btn_qi:setOpacity(80)
    end
    if isGen == false then
        self.btn_gen:setTouchEnabled(false)
        self.btn_gen:setOpacity(80)
    end
    if isJia == false then
        self.btn_jia:setTouchEnabled(false)
        self.btn_jia:setOpacity(80)
    end
    if isBi == false then
        self.btn_bi:setTouchEnabled(false)
        self.btn_bi:setOpacity(80)
    end
    if isShowAllin == false then
        self.btn_xue:setTouchEnabled(false)
        self.btn_xue:setOpacity(80)
    end
    if g_317.isCanKan then
        self.btn_cuo:show()
        self.btn_kan:show()
    else
        self.btn_cuo:hide()
        self.btn_kan:hide()
    end
end


return OprorateBtn	