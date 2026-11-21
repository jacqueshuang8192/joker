local Card = require("gxlz_majiang.card.card")

local ControlPlaneOperator = class("ControlPlaneOperator")

IMAGE_SHOW_TYPE_HU = "hu0"
IMAGE_SHOW_TYPE_ZIMO = "zimo0"
IMAGE_SHOW_TYPE_GANG = "gang0"
IMAGE_SHOW_TYPE_PENG = "peng0"
IMAGE_SHOW_TYPE_CHI = "chi0"
IMAGE_SHOW_TYPE_GUO = "majong_guo_bt_n"
IMAGE_SHOW_TYPE_LIANG = "liang0"
IMAGE_SHOW_TYPE_BUHUA = "buhua0"

CHILD_NAME_SELECT_BOX = "select_box"
CHILD_NAME_GANG_SELECT_BOX = "gang_select_box"
CHILD_NAME_LEFT_CHI_BT = "left_chi_bt"
CHILD_NAME_MIDDLE_CHI_BT = "middle_chi_bt"
CHILD_NAME_RIGHT_CHI_BT = "right_chi_bt"

local CHILD_NAME_EFFECT_LIGHT = "light"
local CHILD_NAME_EFFECT_1 = "effect_1"
local CHILD_NAME_EFFECT_2 = "effect_2"
local CHILD_NAME_EFFECT_3 = "effect_3"

local CHILD_NAME_COMMIT_BT = "commit_bt"
local CHILD_NAME_LG_CANCEL_BT = "cancel_bt"

local CONTROL_BT_SPLIT = 0

local controlPlaneScale=1.1

local componentIndexs = {}
local outCard

function ControlPlaneOperator:init(playerType, img, plane, lgPlane, tingHuPlane)
	img:setVisible(false)

	local position = cc.p(img:getSize().width / 2, img:getSize().height / 2)

	local light_img = ccui.ImageView:create()
    light_img:loadTexture("gxlz_majiang/image/effect/effect_guang.png")
    light_img:setPosition(position)
    light_img:setName(CHILD_NAME_EFFECT_LIGHT)
    img:addChild(light_img)

    local effect_3_img = ccui.ImageView:create()
    effect_3_img:loadTexture("gxlz_majiang/image/effect/effect_hu03.png")
    effect_3_img:setPosition(position)
    effect_3_img:setName(CHILD_NAME_EFFECT_3)
    img:addChild(effect_3_img)

    local effect_2_img = ccui.ImageView:create()
    effect_2_img:loadTexture("gxlz_majiang/image/effect/effect_hu02.png")
    effect_2_img:setPosition(position)
    effect_2_img:setName(CHILD_NAME_EFFECT_2)
    img:addChild(effect_2_img)

    local effect_1_img = ccui.ImageView:create()
    effect_1_img:loadTexture("gxlz_majiang/image/effect/effect_hu01.png")
    effect_1_img:setPosition(position)
    effect_1_img:setName(CHILD_NAME_EFFECT_1)
    img:addChild(effect_1_img)

	if plane then
		-- plane:setScale(controlPlaneScale)
		--todo
		self.hu_bt = ccui.Button:create()
		self.hu_bt:loadTextureNormal("gxlz_majiang/image/majong_hu_bt_p.png")
		self.hu_bt:setVisible(false)
		self.hu_bt:setScale(controlPlaneScale)
		plane:addChild(self.hu_bt)

		self.gang_bt = ccui.Button:create()
		self.gang_bt:loadTextureNormal("gxlz_majiang/image/majong_gang_bt_p.png")
		self.gang_bt:setVisible(false)
		self.gang_bt:setScale(controlPlaneScale)
		plane:addChild(self.gang_bt)

		self.peng_bt = ccui.Button:create()
		self.peng_bt:loadTextureNormal("gxlz_majiang/image/majong_peng_bt_p.png")
		self.peng_bt:setVisible(false)
		self.peng_bt:setScale(controlPlaneScale)
		plane:addChild(self.peng_bt)

		self.chi_bt = ccui.Button:create()
		self.chi_bt:loadTextureNormal("gxlz_majiang/image/majong_chi_bt_p.png")
		self.chi_bt:setVisible(false)
		self.chi_bt:setScale(controlPlaneScale)
		plane:addChild(self.chi_bt)

		self.guo_bt = ccui.Button:create()
		self.guo_bt:loadTextureNormal("gxlz_majiang/image/majong_guo_bt_n.png")
		self.guo_bt:setVisible(true)
		self.guo_bt:setScale(controlPlaneScale)
		plane:addChild(self.guo_bt)

		self.select_bx = plane:getChildByName(CHILD_NAME_SELECT_BOX)
		self.select_bx:setVisible(false)

		self.gang_select_bx = plane:getChildByName(CHILD_NAME_GANG_SELECT_BOX)
		self.gang_select_bx:setVisible(false)

		self.left_chi_bt = self.select_bx:getChildByName(CHILD_NAME_LEFT_CHI_BT)
		self.middle_chi_bt = self.select_bx:getChildByName(CHILD_NAME_MIDDLE_CHI_BT)
		self.right_chi_bt = self.select_bx:getChildByName(CHILD_NAME_RIGHT_CHI_BT)

		self.liang_bt = ccui.Button:create()
		self.liang_bt:loadTextureNormal("gxlz_majiang/image/majong_liang_bt_p.png")
		self.liang_bt:setVisible(true)
		self.liang_bt:setScale(controlPlaneScale)
		plane:addChild(self.liang_bt)

		plane:setVisible(false)

		local bt_callback = function(sender, event)
			if event == TOUCH_EVENT_ENDED then

				local controlType = GXLZ_CONTROL_TABLE["type"]
				local value = GXLZ_CONTROL_TABLE["value"]
				local gangCards = GXLZ_CONTROL_TABLE["gangCards"]

				if sender == self.hu_bt then
					--todo
					plane:setVisible(false)
					GXLZ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_HU), value)
				elseif sender == self.gang_bt then
					if gangCards and table.getn(gangCards) == 1 then
						--todo
						plane:setVisible(false)
						GXLZ_CONTROLLER:control(gangCards[1].type, gangCards[1].value)
					end
				elseif sender == self.peng_bt then
					plane:setVisible(false)
					GXLZ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_PENG), value)
				elseif sender == self.left_chi_bt then
					plane:setVisible(false)
					GXLZ_CONTROLLER:control(CHI_TYPE_LEFT, value)
				elseif sender == self.middle_chi_bt then
					plane:setVisible(false)
					GXLZ_CONTROLLER:control(CHI_TYPE_MIDDLE, value)
				elseif sender == self.right_chi_bt then
					plane:setVisible(false)
					GXLZ_CONTROLLER:control(CHI_TYPE_RIGHT, value)
				elseif sender == self.guo_bt then
					plane:setVisible(false)
					GXLZ_CONTROLLER:control(0, value)
				elseif sender == self.chi_bt then
					local chiType
					local chiCount = 0

					dump(controlType, "controlType chi test")
					if bit.band(controlType, CHI_TYPE_LEFT) > 0 then
						--todo
						chiType = CHI_TYPE_LEFT
						chiCount = chiCount + 1
					end
					if bit.band(controlType, CHI_TYPE_MIDDLE) > 0 then
						--todo
						chiType = CHI_TYPE_MIDDLE
						chiCount = chiCount + 1
					end
					if bit.band(controlType, CHI_TYPE_RIGHT) > 0 then
						--todo
						chiType = CHI_TYPE_RIGHT
						chiCount = chiCount + 1
					end

					dump(chiCount, "chiCount chi test")
					if chiCount == 1 then
						--todo
						plane:setVisible(false)
						GXLZ_CONTROLLER:control(chiType, value)
					end
				elseif sender == self.liang_bt then
					plane:setVisible(false)
					
					-- D3_CHUPAI = 2

					-- if table.getn(GXLZ_CONTROL_TABLE.gangSeq) > 0 then
					-- 	--todo
					-- 	GXLZ_CONTROLLER:showLgSelectBox(GXLZ_CONTROL_TABLE.gangSeq)
					-- else
					-- 	-- GXLZ_CONTROLLER:showTingCards(GXLZ_CONTROL_TABLE.tingSeq)
					-- 	GXLZ_LG_CARDS = {}
					-- 	GXLZ_CONTROLLER:requestLiangGang()
					-- end
					
					GXLZ_CONTROLLER:showTingCards(GXLZ_CONTROL_TABLE.tingSeq)

					GXLZ_CONTROLLER:showComponentSelectBox(nil)
				end
			end
		end

		self.hu_bt:addTouchEventListener(bt_callback)
		self.gang_bt:addTouchEventListener(bt_callback)
		self.peng_bt:addTouchEventListener(bt_callback)
		self.left_chi_bt:addTouchEventListener(bt_callback)
		self.middle_chi_bt:addTouchEventListener(bt_callback)
		self.right_chi_bt:addTouchEventListener(bt_callback)
		self.guo_bt:addTouchEventListener(bt_callback)
		self.chi_bt:addTouchEventListener(bt_callback)
		self.liang_bt:addTouchEventListener(bt_callback)
	end

	if tingHuPlane then
		--todo
		tingHuPlane:setVisible(false)
	end
end

function ControlPlaneOperator:clearGameDatas(plane, lgPlane, tingHuPlane)
	if plane then
		--todo
		plane:setVisible(false)
	end

	if lgPlane then
		--todo
		lgPlane:setVisible(false)
	end

	if tingHuPlane then
		--todo
		tingHuPlane:setVisible(false)
	end
end

function ControlPlaneOperator:showImage(img, type)
	local img_type = ""
	if bit.band(type, CONTROL_TYPE_HU) > 0 then
		if bit.band(type, HU_TYPE_ZM) > 0 then
			 img_type = IMAGE_SHOW_TYPE_ZIMO
	    else img_type = IMAGE_SHOW_TYPE_HU
	    end
	elseif bit.band(type, CONTROL_TYPE_GANG) > 0 then
		img_type = IMAGE_SHOW_TYPE_GANG
	elseif bit.band(type, CONTROL_TYPE_PENG) > 0 then
		img_type = IMAGE_SHOW_TYPE_PENG
	elseif bit.band(type, CONTROL_TYPE_CHI) > 0 then
		img_type = IMAGE_SHOW_TYPE_CHI
	elseif bit.band(type, CONTROL_TYPE_TING) > 0 then
		img_type = IMAGE_SHOW_TYPE_LIANG
	elseif bit.band(type, CONTROL_TYPE_BUHUA) > 0 then
		img_type = IMAGE_SHOW_TYPE_BUHUA
	end

	local light_img = img:getChildByName(CHILD_NAME_EFFECT_LIGHT)
	local effect_1_img = img:getChildByName(CHILD_NAME_EFFECT_1)
	local effect_2_img = img:getChildByName(CHILD_NAME_EFFECT_2)
	local effect_3_img = img:getChildByName(CHILD_NAME_EFFECT_3)

	effect_1_img:loadTexture("gxlz_majiang/image/effect/effect_" .. img_type .. "3.png")
	effect_2_img:loadTexture("gxlz_majiang/image/effect/effect_" .. img_type .. "2.png")
	effect_3_img:loadTexture("gxlz_majiang/image/effect/effect_" .. img_type .. "1.png")

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

function ControlPlaneOperator:showPlane(plane, controlType)
	if controlType == 0 then
		--todo
		return
	end

	plane:setVisible(true)

	self.hu_bt:setVisible(false)
	self.gang_bt:setVisible(false)
	self.peng_bt:setVisible(false)
	self.chi_bt:setVisible(false)
	self.liang_bt:setVisible(false)

	self.select_bx:setVisible(false)
	self.gang_select_bx:setVisible(false)

	local oriX = 0

	dump(controlType, "controlType test")

	if bit.band(controlType, CONTROL_TYPE_HU) > 0 then
		--todo
		self.hu_bt:setVisible(true)
		local size = self.hu_bt:getSize()
		self.hu_bt:setPosition(cc.p(oriX + size.width / 2, plane:getSize().height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	if bit.band(controlType, CONTROL_TYPE_GANG) > 0 then
		--todo
		self.gang_bt:setVisible(true)
		self.gang_select_bx:setVisible(true)
		local size = self.gang_bt:getSize()
		self.gang_bt:setPosition(cc.p(oriX + size.width / 2, plane:getSize().height / 2))

		--oriX = oriX + size.width
        --
		local box_width = self:showGangSelectBox(plane, controlType)

		self.gang_select_bx:setPosition(cc.p(oriX + box_width / 2, self.gang_bt:getSize().height * 1.1))
		self.gang_select_bx:setSize(cc.size(box_width, self.gang_select_bx:getSize().height))
        --
		--oriX = oriX + box_width
		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	if bit.band(controlType, CONTROL_TYPE_PENG) > 0 then
		--todo
		self.peng_bt:setVisible(true)
		local size = self.peng_bt:getSize()
		self.peng_bt:setPosition(cc.p(oriX + size.width / 2, plane:getSize().height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	if bit.band(controlType, CONTROL_TYPE_CHI) > 0 then
		--todo
		self.chi_bt:setVisible(true)
		self.select_bx:setVisible(true)

		local size = self.chi_bt:getSize()
		self.chi_bt:setPosition(cc.p(oriX + size.width / 2, plane:getSize().height / 2))

		--oriX = oriX + size.width
        --
		local box_width = self:showSelectBox(controlType)

		self.select_bx:setPosition(cc.p(oriX + box_width/2, self.chi_bt:getSize().height * 1.1))
		self.select_bx:setSize(cc.size(box_width, self.select_bx:getSize().height))
        --
		--oriX = oriX + box_width
		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	if bit.band(controlType, CONTROL_TYPE_TING) > 0 then
		--todo
		self.liang_bt:setVisible(true)
		local size = self.liang_bt:getSize()
		self.liang_bt:setPosition(cc.p(oriX + size.width / 2, plane:getSize().height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	local size = self.guo_bt:getSize()
	self.guo_bt:setPosition(cc.p(oriX + size.width / 2, plane:getSize().height / 2))

	local width = oriX + size.width

	plane:setSize(cc.size(width, plane:getSize().height))
end

function ControlPlaneOperator:showSelectBox(controlType)
	self.select_bx:setVisible(true)

	self.left_chi_bt:setVisible(false)
	self.middle_chi_bt:setVisible(false)
	self.right_chi_bt:setVisible(false)

	local value = GXLZ_CONTROL_TABLE["value"]

	local bx_width = 20
	if bit.band(controlType, CHI_TYPE_LEFT) > 0 then
		--todo
		self.left_chi_bt:setVisible(true)
		self.left_chi_bt:removeAllChildren()

		local bt_width = 0
		for i=value,value + 2 do
			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, i)
			local size = card:getSize()
			local scale = self.left_chi_bt:getSize().height / size.height
			card:setScale(scale)
			card:setPosition(cc.p((i - value) * size.width * scale + size.width * scale / 2, self.left_chi_bt:getSize().height / 2))

			if value == i then
				--todo
				card:setColor(cc.c3b(140, 140, 140))
			end

			card:setEnabled(false)
			self.left_chi_bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end

		local position = self.left_chi_bt:getPosition()
		self.left_chi_bt:setPosition(cc.p(bx_width + bt_width / 2, position.y))
		local size = self.left_chi_bt:getSize()
		self.left_chi_bt:setSize(cc.size(bt_width, size.height))

		bx_width = bx_width + bt_width + 20
	end

	if bit.band(controlType, CHI_TYPE_MIDDLE) > 0 then
		self.middle_chi_bt:setVisible(true)
		self.middle_chi_bt:removeAllChildren()

		local bt_width = 0
		for i=value - 1,value + 1 do
			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, i)
			local size = card:getSize()
			local scale = self.middle_chi_bt:getSize().height / size.height
			card:setScale(scale)
			card:setPosition(cc.p((i - value + 1) * size.width * scale + size.width * scale / 2, self.middle_chi_bt:getSize().height / 2))

			if value == i then
				--todo
				card:setColor(cc.c3b(140, 140, 140))
			end

			card:setEnabled(false)
			self.middle_chi_bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end

		local position = self.middle_chi_bt:getPosition()
		self.middle_chi_bt:setPosition(cc.p(bx_width + bt_width / 2, position.y))
		local size = self.middle_chi_bt:getSize()
		self.middle_chi_bt:setSize(cc.size(bt_width, size.height))

		bx_width = bx_width + bt_width + 20
	end

	if bit.band(controlType, CHI_TYPE_RIGHT) > 0 then
		self.right_chi_bt:setVisible(true)
		self.right_chi_bt:removeAllChildren()

		local bt_width = 0
		for i=value - 2,value do
			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, i)
			local size = card:getSize()
			local scale = self.right_chi_bt:getSize().height / size.height
			card:setScale(scale)
			card:setPosition(cc.p((i - value + 2) * size.width * scale + size.width * scale / 2, self.right_chi_bt:getSize().height / 2))

			if value == i then
				--todo
				card:setColor(cc.c3b(140, 140, 140))
			end
			
			card:setEnabled(false)
			self.right_chi_bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end

		local position = self.right_chi_bt:getPosition()
		self.right_chi_bt:setPosition(cc.p(bx_width + bt_width / 2, position.y))
		local size = self.right_chi_bt:getSize()
		self.right_chi_bt:setSize(cc.size(bt_width, size.height))

		bx_width = bx_width + bt_width + 20
	end

	return bx_width
end

function ControlPlaneOperator:showGangSelectBox(plane, controlType)
	self.gang_select_bx:removeAllChildren()
	local gangCards = GXLZ_CONTROL_TABLE["gangCards"]

	local bx_width = 20
	for k,v in pairs(gangCards) do
		local bt = ccui.Button:create()
		local bt_width = 0
		local bt_height = 38.55
		if v.value < 80 then
			for i=1,4 do
				local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v.value)
				local size = card:getSize()
				local scale = bt_height / size.height
				card:setScale(scale)
				card:setPosition(cc.p((i - 1) * size.width * scale + size.width * scale / 2, bt_height / 2))

				-- card:setEnabled(false)
				card:setTouchEnabled(true)
				card.noScale = true
				card:addTouchEventListener(function(sender, event)
					if event == TOUCH_EVENT_ENDED then
						-- local value = gangCards[sender:getTag()]

						plane:setVisible(false)
						GXLZ_CONTROLLER:control(v.type, sender.m_value)
					end
				end)

				bt:addChild(card)

				bt_width = bt_width + size.width * scale
			end
		else
			--花杠
			for i=1,4 do
				local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v.value + i - 1)
				local size = card:getSize()
				local scale = bt_height / size.height
				card:setScale(scale)
				card:setPosition(cc.p((i - 1) * size.width * scale + size.width * scale / 2, bt_height / 2))

				-- card:setEnabled(false)
				card:setTouchEnabled(true)
				card.noScale = true
				card:addTouchEventListener(function(sender, event)
					if event == TOUCH_EVENT_ENDED then
						-- local value = gangCards[sender:getTag()]

						plane:setVisible(false)
						GXLZ_CONTROLLER:control(v.type, v.value)
					end
				end)

				bt:addChild(card)

				bt_width = bt_width + size.width * scale
			end
		end
		print("bt_width, bt_height-------------------",bt_width, bt_height)
		bt:setPosition(cc.p(bx_width, (self.gang_select_bx:getSize().height - bt_height) / 2))
		bt:setSize(cc.size(bt_width, bt_height))
        -- bt:setScale(1.2)
		self.gang_select_bx:addChild(bt)
		-- bt:setEnabled(true)
		-- bt:setTouchEnabled(true)
		bt:setTag(k)

		

		bx_width = bx_width + bt_width + 20
	end

	return bx_width
end

function ControlPlaneOperator:showTingHuPlane(playerType, plane, tingHuCards)
	if not tingHuCards then
		return
	end

	for k,v in pairs(plane:getChildren()) do
		if v:getName() ~= "title" and v:getName() ~= "renyipai" then
			--todo
			v:removeFromParent()
		end
	end

	plane:setVisible(true)

	local renyipai = plane:getChildByName("renyipai")
	if table.getn(tingHuCards) == 0 then
		renyipai:setVisible(true)
		return
	end

	renyipai:setVisible(false)

	table.sort(tingHuCards)

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local title = plane:getChildByName("title")
		local oriX = title:getPosition().x + title:getSize().width / 2
		local cardHeight = plane:getSize().height - 15
		local oriY = plane:getSize().height / 2

		for k,v in pairs(tingHuCards) do
			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v)
			local size = card:getSize()
			local scale = cardHeight / size.height
			card:setScale(scale)
			card:setPosition(cc.p(oriX + size.width * scale / 2, oriY))

			plane:addChild(card)

			card:setTag(0)

			oriX = oriX + size.width * scale
		end

		plane:setSize(cc.size(oriX + 20, plane:getSize().height))
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local title = plane:getChildByName("title")
		local cardWidth = plane:getSize().width - 15
		local scale = (cardWidth / 77)
		local totalHeight = plane:getSize().height - title:getPosition().y + title:getSize().height / 2 + 20 + (table.getn(tingHuCards) - 1) * 48 * scale + 68 * scale
		local oriX = plane:getSize().width / 2

		title:setPosition(cc.p(title:getPosition().x, totalHeight - (plane:getSize().height - title:getPosition().y)))

		for k,v in pairs(tingHuCards) do
			local card = Card:new(CARD_PLAYERTYPE_LEFT, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, v)
			card:setScale(scale)
			card:setPosition(cc.p(oriX, 20 + (k - 1) * 48 * scale + 34 * scale))

			card:setLocalZOrder(100 - k)

			plane:addChild(card)

			card:setTag(0)
		end

		plane:setSize(cc.size(plane:getSize().width, totalHeight))
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local title = plane:getChildByName("title")
		local cardWidth = plane:getSize().width - 15
		local scale = (cardWidth / 77)
		local totalHeight = plane:getSize().height - title:getPosition().y + title:getSize().height / 2 + 20 + (table.getn(tingHuCards) - 1) * 48 * scale + 68 * scale
		local oriX = plane:getSize().width / 2

		title:setPosition(cc.p(title:getPosition().x, totalHeight - (plane:getSize().height - title:getPosition().y)))
		
		for k,v in pairs(tingHuCards) do
			local card = Card:new(CARD_PLAYERTYPE_RIGHT, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, v)
			card:setScale(scale)
			card:setPosition(cc.p(oriX, 20 + (k - 1) * 48 * scale + 34 * scale))

			card:setLocalZOrder(100 - k)

			plane:addChild(card)

			card:setTag(0)
		end

		plane:setSize(cc.size(plane:getSize().width, totalHeight))
	end

	
end

return ControlPlaneOperator