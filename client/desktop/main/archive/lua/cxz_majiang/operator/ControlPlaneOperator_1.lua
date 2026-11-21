local Card = require(TpackageName..".card.card")
local Card1 = require(TpackageName .. ".2DMahjongCard.Card")
local InhandCardMgr = require(TpackageName .. ".2DMahjongCard.InhandCardMgr")

local ControlPlaneOperator = class("ControlPlaneOperator")

local IMAGE_SHOW_TYPE_HU = "hu"
local IMAGE_SHOW_TYPE_GANG = "gang"
local IMAGE_SHOW_TYPE_PENG = "peng"
local IMAGE_SHOW_TYPE_CHI = "chi"
local IMAGE_SHOW_TYPE_ZIMO = "zimo"
local IMAGE_SHOW_TYPE_CHAOTIAN = "chaotian"
local IMAGE_SHOW_TYPE_LAI = "lai"

local CHILD_NAME_LEFT_CHI_BT = "left_chi_bt"
local CHILD_NAME_MIDDLE_CHI_BT = "middle_chi_bt"
local CHILD_NAME_RIGHT_CHI_BT = "right_chi_bt"

local CHILD_NAME_EFFECT_LIGHT = "light"
local CHILD_NAME_EFFECT_1 = "effect_1"
local CHILD_NAME_EFFECT_2 = "effect_2"
local CHILD_NAME_EFFECT_3 = "effect_3"

local CHILD_NAME_COMMIT_BT = "commit_bt"

local CONTROL_BT_SPLIT = 20

local boxscale = 1.2

function ControlPlaneOperator:init(playerType, img, plane, lgPlane, ting_hu_plane)
	img:setVisible(false)

	if plane then
		self.btn_hu = CXZMJ_SCENE.players.my_card_plane.control_plane.btn_hu
		self.btn_gang = CXZMJ_SCENE.players.my_card_plane.control_plane.btn_gang
		self.btn_peng = CXZMJ_SCENE.players.my_card_plane.control_plane.btn_peng
		self.btn_chaotian = CXZMJ_SCENE.players.my_card_plane.control_plane.btn_chaotian
		self.btn_hu:setVisible(false)
		self.btn_gang:setVisible(false)
		self.btn_peng:setVisible(false)
		self.btn_chaotian:setVisible(false)


		self.chi_bt = ccui.Button:create()
		self.chi_bt:loadTextureNormal(TpackageName.."/res/image/majong_chi_bt_p.png")
		self.chi_bt:setVisible(false)
		plane:addChild(self.chi_bt)

		self.guo_bt = ccui.Button:create()
		self.guo_bt:loadTextureNormal(TpackageName.."/res/image/majong_guo_bt_n.png")
		self.guo_bt:setVisible(false)
		plane:addChild(self.guo_bt)

		self.select_bx = plane:getChildByName("select_box")
		self.select_bx:setVisible(false)

		self.gang_select_box = plane:getChildByName("gang_select_box")
		self.gang_select_box:setVisible(false)

		self.left_chi_bt = self.select_bx:getChildByName(CHILD_NAME_LEFT_CHI_BT)
		self.middle_chi_bt = self.select_bx:getChildByName(CHILD_NAME_MIDDLE_CHI_BT)
		self.right_chi_bt = self.select_bx:getChildByName(CHILD_NAME_RIGHT_CHI_BT)

		plane:setVisible(false)
		local bt_callback = function(event)
			local sender = event.target
			local controlType = CXZMJ_CONTROL_TABLE["type"]
			local value = CXZMJ_CONTROL_TABLE["value"]
			local gangCards = CXZMJ_CONTROL_TABLE["gangCards"]

			if sender == self.btn_hu then
				--todo
				plane:setVisible(false)
				CXZMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_HU), value)
			elseif sender == self.btn_gang then
				if gangCards and table.getn(gangCards) == 1 then
					plane:setVisible(false)
					CXZMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), gangCards[1])
				end
			elseif sender == self.btn_peng then
				plane:setVisible(false)
				CXZMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_PENG), value)
			elseif sender == self.btn_chaotian then
				plane:setVisible(false)
				CXZMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_CHAOTIAN), CXZ_LAI_ZI_PI)
			elseif sender == self.left_chi_bt then
				plane:setVisible(false)
				CXZMJ_CONTROLLER:control(CHI_TYPE_LEFT, value)
			elseif sender == self.middle_chi_bt then
				plane:setVisible(false)
				CXZMJ_CONTROLLER:control(CHI_TYPE_MIDDLE, value)
			elseif sender == self.right_chi_bt then
				plane:setVisible(false)
				CXZMJ_CONTROLLER:control(CHI_TYPE_RIGHT, value)
			elseif sender == self.guo_bt then
				plane:setVisible(false)
				CXZMJ_CONTROLLER:control(0, value)
			elseif sender == self.chi_bt then
				local chiType
				local chiCount = 0

				--dump(controlType, "controlType chi test")
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

				--dump(chiCount, "chiCount chi test")
				if chiCount == 1 then
					--todo
					plane:setVisible(false)
					CXZMJ_CONTROLLER:control(chiType, value)
				end
				
			end
		end

		self.btn_hu:onClick(bt_callback)
		self.btn_gang:onClick(bt_callback)
		self.btn_peng:onClick(bt_callback)
		self.btn_chaotian:onClick(bt_callback)
		self.left_chi_bt:onClick(bt_callback)
		self.middle_chi_bt:onClick(bt_callback)
		self.right_chi_bt:onClick(bt_callback)
		self.guo_bt:onClick(bt_callback)
		self.chi_bt:onClick(bt_callback)
		--self.liang_bt:onClick(bt_callback)
	end

	if lgPlane then
		--todo
		lgPlane:setVisible(false)

		self.lg_select_box = lgPlane:getChildByName("select_box")
		self.commit_bt = lgPlane:getChildByName(CHILD_NAME_COMMIT_BT)

		self.commit_bt:addTouchEventListener(function(sender, event)
				if event == TOUCH_EVENT_ENDED then
					lgPlane:setVisible(false)

					CXZMJ_LG_CARDS = {}

					for k,v in pairs(self.lg_select_box:getChildren()) do
						if v:getTag() == 0 then
							--todo
							table.insert(CXZMJ_LG_CARDS, v.m_value)
						end
					end

					CXZMJ_CONTROLLER:requestLiangGang()
					-- for i=table.getn(CXZMJ_CONTROL_TABLE.tingSeq),1,-1 do
					-- 	for k,v in pairs(CXZMJ_LG_CARDS) do
					-- 		if v == CXZMJ_CONTROL_TABLE.tingSeq[i] then
					-- 			--todo
					-- 			table.remove(CXZMJ_CONTROL_TABLE.tingSeq, i)
					-- 			break
					-- 		end
					-- 	end
					-- end
				end
			end)
	end
	self:setTingNodeVisible(false)
	self:setHupaiVwVisible(false)
end

function ControlPlaneOperator:clearGameDatas(plane, lgPlane, ting_hu_plane)
	if plane then
		--todo
		plane:setVisible(false)
	end

	if lgPlane then
		--todo
		lgPlane:setVisible(false)
	end
	self:setTingNodeVisible(false)
	self:setHupaiVwVisible(false)
	
end

function ControlPlaneOperator:showImage(control_img, type)
	local img_type = ""
	if bit.band(type, CONTROL_TYPE_HU) > 0 then
		img_type = IMAGE_SHOW_TYPE_HU
		if bit.band(type, HU_TYPE_ZM) > 0 then
			img_type = IMAGE_SHOW_TYPE_ZIMO
		end
	elseif bit.band(type, CONTROL_TYPE_GANG) > 0 then
		img_type = IMAGE_SHOW_TYPE_GANG
	elseif bit.band(type, CONTROL_TYPE_PENG) > 0 then
		img_type = IMAGE_SHOW_TYPE_PENG
	elseif bit.band(type, CONTROL_TYPE_CHI) > 0 then
		img_type = IMAGE_SHOW_TYPE_CHI
	elseif bit.band(type, CONTROL_TYPE_TING) > 0 then
		--img_type = IMAGE_SHOW_TYPE_LIANG
	elseif bit.band(type, CONTROL_TYPE_CHAOTIAN) > 0 then
		img_type = IMAGE_SHOW_TYPE_CHAOTIAN
	elseif bit.band(type, CONTROL_TYPE_LAI) > 0 then
		img_type = IMAGE_SHOW_TYPE_LAI
	end

	control_img:removeAllChildren()
	local position = cc.p(control_img:getSize().width / 2, control_img:getSize().height / 2)
    control_img:show()
	
	local effectManage = ccs.ArmatureDataManager:getInstance() 
	local name = "gang"
    local path = TpackageName .. "/res/GameScene/"..name
	display.addSpriteFrames(path.."0.png", path.."0.plist")
	effectManage:addArmatureFileInfo(path.."0.png", path.."0.plist", path..".ExportJson");
    local Armature = ccs.Armature:create(name)
    Armature:addTo(control_img):setPosition(position)
    local anim = Armature:getAnimation()

	dump(img_type, 'img_type--------------')
	dump(type, 'img_type--------------')
    anim:playWithNames({img_type}, 0, false);
    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            Armature:removeSelf()
			dump(os.time(),"动画结束-----------")
        end
    end
	anim:setMovementEventCallFunc(handler1)
end

function ControlPlaneOperator:showPlane(plane, controlType)

	if controlType == 0 then
		--todo
		return
	end	

	plane:setVisible(true)

	self.btn_hu:setVisible(false)
	self.btn_gang:setVisible(false)
	self.btn_peng:setVisible(false)
	self.btn_chaotian:setVisible(false)
	self.chi_bt:setVisible(false)
	--self.liang_bt:setVisible(false)

	self.select_bx:setVisible(false)
	self.gang_select_box:setVisible(false)
	self.guo_bt:setVisible(false)
	local oriX = 20
	local gang_select_box_height = 67   --self.gang_select_box:getSize().height

	if bit.band(controlType, CONTROL_TYPE_HU) > 0 then
		--todo
		self.btn_hu:setVisible(true)
		local size = self.btn_hu:getSize()
		self.btn_hu:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT*boxscale
	end

	if bit.band(controlType, CONTROL_TYPE_GANG) > 0 then
		--todo
		self.btn_gang:setVisible(true)
		-- local anim = zhizhenAnin:getAnimation()
		-- anim:playWithNames({type}, 0, true);
		self.gang_select_box:setVisible(true)
		local size = self.btn_gang:getSize()
		self.btn_gang:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width*boxscale

		local box_width = self:showGangSelectBox(plane, controlType)

		self.gang_select_box:setPosition(cc.p(oriX + box_width / 2, self.btn_gang:getPositionY()))
		self.gang_select_box:setSize(cc.size(box_width, gang_select_box_height*boxscale))

		oriX = oriX + box_width
	end

	if bit.band(controlType, CONTROL_TYPE_PENG) > 0 then
		
		-- if bit.band(controlType, CONTROL_TYPE_GANG) > 0 then     --可以杠的时候延迟碰的显示
		-- 	self.btn_peng:performWithDelay(function()
		--     self.btn_peng:setVisible(true)
		-- 	end,1) 
		-- else                                                     --单独碰的时候不延迟
			self.btn_peng:setVisible(true)
		-- end

		local size = self.btn_peng:getSize()
		self.btn_peng:setPosition(cc.p(oriX + size.width / 2*1.5, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT * boxscale
	end

	if bit.band(controlType, CONTROL_TYPE_CHAOTIAN) > 0 then

		self.btn_chaotian:setVisible(true)
		local size = self.btn_chaotian:getSize()
		self.btn_chaotian:setPosition(cc.p(oriX + size.width / 2*1.5, size.height / 2))
		self.gang_select_box:setVisible(false)
		oriX = oriX + size.width + CONTROL_BT_SPLIT * boxscale
	end

	if bit.band(controlType, CONTROL_TYPE_CHI) > 0 then
		--todo
		self.chi_bt:setVisible(true)
		self.select_bx:setVisible(true)

		local size = self.chi_bt:getSize()
		self.chi_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width

		local box_width = self:showSelectBox(controlType)

		self.select_bx:setPosition(cc.p(oriX + box_width / 2, self.select_bx:getSize().height / 2))
		self.select_bx:setSize(cc.size(box_width, self.select_bx:getSize().height))

		oriX = oriX + box_width
	end

	if bit.band(controlType, CONTROL_TYPE_TING) > 0 then
		-- self.liang_bt:setVisible(true)
		-- local size = self.liang_bt:getSize()
		-- self.liang_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		-- oriX = oriX + size.width + CONTROL_BT_SPLIT
		
		-- plane:setVisible(false)
		-- local value = HNMJ_CONTROL_TABLE["value"]
		-- CXZMJ_CONTROLLER:control(0, value)
	end

	local size = self.guo_bt:getSize()
	
	-- self.guo_bt:performWithDelay(function()
	-- self.guo_bt:setVisible(true)
	-- 	end,1) 
	self.guo_bt:setPosition(cc.p(oriX + size.width / 2*boxscale, size.height / 2))
	self.guo_bt:setVisible(true)

	local width = oriX + size.width

	plane:setSize(cc.size(width, plane:getSize().height))
	dump(plane:getPosition(), "PlayerPlaneOperator:controlType")
end

function ControlPlaneOperator:showSelectBox(controlType)
	self.select_bx:setVisible(true)

	self.left_chi_bt:setVisible(false)
	self.middle_chi_bt:setVisible(false)
	self.right_chi_bt:setVisible(false)

	local value = CXZMJ_CONTROL_TABLE["value"]

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
	self.gang_select_box:removeAllChildren()
	local gangCards = CXZMJ_CONTROL_TABLE["gangCards"]
    local cardScale = 1.5
	local bx_width = 20

	local my_card_plane = CXZMJ_SCENE.players:getChildByName("my_card_plane")
	local inhand_plane = my_card_plane:getChildByName("inhand_plane")
	local childs = inhand_plane:getChildren()
	local handCard = {}
	for k,v in pairs(childs) do
		if v.m_value > 0 then
			table.insert(handCard,v.m_value)
		end
	end

	local tempTab = {}
	for i,v in pairs(handCard) do
		if not tempTab[v] then
			tempTab[v] = 1
		else
			tempTab[v] = tempTab[v] + 1
		end
	end


	for k,v in pairs(gangCards) do
		local bt = ccui.Button:create()
		local bt_width = 0
		local bt_height = 38.55
		for i=1,4 do
			local card = Card1:newMyInHandCard(v)
			local size = card:getSize()
			local scale = bt_height / size.height * cardScale
			card:setScale(scale)
			card:setPosition(cc.p((i - 1) * (size.width+2) * scale-2 + size.width * scale / 2, bt_height / 2+7))
			card:setTouchEnabled(true)
			card.noScale = true
			card:onClick(function(event)
				local sender = event.target
				plane:setVisible(false)


				if gangCards and table.getn(gangCards) == 1 then
					CXZMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), gangCards[1])
				else
					if sender.m_value > 0 and tempTab[sender.m_value] and tempTab[sender.m_value] >0 then
						if tempTab[sender.m_value] <= 1 then --手上只有一个 补杠啦
							controlType = GANG_TYPE_BU
						--手上有大于三个以上 就是暗杠   因为碰杠不可能和其他两种杠同时存在
						elseif tempTab[sender.m_value] >= 3 then 
							controlType = GANG_TYPE_AN
						end
					else
						--补杠的时候 手牌中没有这个牌
						if not tempTab[sender.m_value] then
							controlType = GANG_TYPE_BU
						end
					end
					CXZMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), sender.m_value)
				end
				
			end)

			bt:addChild(card)
			bt_width = bt_width + size.width * scale
		end
		local bt_y = 14  --(self.gang_select_box:getSize().height - bt_height) / 2
		dump(bt_y, "杠选择框的Y坐标")
		bt:setPosition(cc.p(bx_width, bt_y))
		bt:setSize(cc.size(bt_width, bt_height))
		self.gang_select_box:addChild(bt)
		bt:setTag(k)

		bx_width = bx_width + bt_width + 20
	end

	return bx_width
end

function ControlPlaneOperator:showLgSelectBox(plane, lgCards)
	self.lg_select_box:removeAllChildren()
	plane:setVisible(true)

	local oriX = 30
	for k,v in pairs(lgCards) do
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v)
		local size = card:getSize()
		local scale = 45.0 / size.height
		card:setScale(scale)
		card:setPosition(cc.p(oriX + size.width * scale / 2, self.lg_select_box:getSize().height / 2))

		self.lg_select_box:addChild(card)

		card:setTag(0)
		card:setEnabled(true)

		card:addTouchEventListener(function(sender, event)
				if event == TOUCH_EVENT_ENDED then
					if sender:getTag() == 999 then
						--todo
						sender:setTag(0)
						sender:setColor(cc.c3b(255, 255, 255))
					else
						sender:setTag(999)
						sender:setColor(cc.c3b(140, 140, 140))
					end
				end
			end)

		oriX = oriX + size.width * scale + 30
	end

	plane:setSize(cc.size(oriX + self.commit_bt:getSize().width, plane:getSize().height))
	self.lg_select_box:setSize(cc.size(oriX, self.lg_select_box:getSize().height))
	self.lg_select_box:setPosition(cc.p(self.lg_select_box:getSize().width / 2, self.lg_select_box:getPosition().y))
	self.commit_bt:setPosition(cc.p(self.lg_select_box:getSize().width + self.commit_bt:getSize().width / 2, self.commit_bt:getPosition().y))
end

function ControlPlaneOperator:showTingHuPlane(ting_hu_plane, tingHuCards)

	for k,v in pairs(ting_hu_plane:getChildren()) do
		if not(v:getName() == "title" or v:getName() =="renyipai") then
			v:removeFromParent()
		end
	end

	local tag = 0
	self:setTingNodeVisible(true)
	local title = ting_hu_plane:getChildByName("title")
	local renyipai = ting_hu_plane:getChildByName("renyipai")
	      renyipai:setVisible(false)
	local oriX = title:getPosition().x + title:getSize().width / 2
	local cardHeight = ting_hu_plane:getSize().height - 15
	local oriY = ting_hu_plane:getSize().height / 2
    
    local renyipaiFlag

    if #tingHuCards>25 then --胡任意牌
    	 renyipai:setVisible(true)
         local size = renyipai:getSize()
         renyipaiFlag = true

         oriX = oriX + size.width
	elseif  #tingHuCards==0  then  --重连没给我发胡的牌的时候
		self:setTingNodeVisible(false)
    else	--不胡任意牌，胡特定牌
	renyipai:setVisible(false)

	for k,v in pairs(tingHuCards) do	
		-- local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v)
		local card = Card1:newMyInHandCard(v)
		local size = card:getSize()
		local scale = cardHeight / size.height
		card:setScale(scale)
		card:setPosition(cc.p(oriX + size.width * scale / 2, oriY))

		ting_hu_plane:addChild(card)
     
		card:setTag(0)
		card:setEnabled(true)

		oriX = oriX + size.width * scale
	end

	end
    
	title:addTouchEventListener(
    function(sender,event)

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                local width = (ting_hu_plane:getChildByName("title")):getSize().width + 16
                local height = ting_hu_plane:getSize().height
                if tag == 0 then
                   ting_hu_plane:setSize(cc.size(width,height))
					for k,v in pairs(ting_hu_plane:getChildren()) do
						if v:getName() ~= "title"  then
							v:setVisible(false)
						end
					end
					tag =  1

                elseif tag == 1 then

                   ting_hu_plane:setSize(cc.size(oriX+20,height))
                   	for k,v in pairs(ting_hu_plane:getChildren()) do
                   		if v:getName() ~= "renyipai" then
							v:setVisible(true)
						elseif renyipaiFlag==true then
						    v:setVisible(true)
						end
					end
					tag = 0 

                end

            end

        end
    )


	ting_hu_plane:setSize(cc.size(oriX + 20, ting_hu_plane:getSize().height))
end

function ControlPlaneOperator:didSelectOutCard(plane, card)
	if not (type(TINGSEQ) == "table" and D3_CHUPAI == 1) then
		return
	end
    local tingHuCards
	for k,v in pairs(TINGSEQ) do
		if v.card == card then
			tingHuCards = v.tingHuCards
		break
		end
	end
	if tingHuCards == nil  then
		plane:setVisible(false)
		return
	end
	for k,v in pairs(plane:getChildren()) do
		if not (v:getName() == "title" or v:getName() =="renyipai") then
			v:removeFromParent()
		end
	end
    local tag = 0 
    local title = plane:getChildByName("title")
	plane:setVisible(true)
	local renyipai = plane:getChildByName("renyipai")
	renyipai:setVisible(false)

	local oriX = title:getPosition().x + title:getSize().width / 2
	local cardHeight = plane:getSize().height
	local oriY = plane:getSize().height / 2
    local renyipaiFlag
    if #tingHuCards>25 then --胡任意牌
    	 renyipai:setVisible(true)
         local size = renyipai:getSize()
         renyipaiFlag = true

         oriX = oriX + size.width

    elseif  #tingHuCards==0  then  --重连没给我发胡的牌的时候
    	 plane:setVisible(false)
    else	--不胡任意牌，胡特定牌
		renyipai:setVisible(false)
	
		local tingHuCards_1 = {}
		for i1,v1 in ipairs(tingHuCards) do
			if not v1.huCards or table.getn(v1.huCards) == 0 then
				renyipai:setVisible(true)
				local size = renyipai:getSize()
				renyipaiFlag = true
				oriX = oriX + size.width
				return
			end
			
			for i2,v2 in ipairs(v1.huCards) do
				local isExist = false
				for i3,v3 in ipairs(tingHuCards_1) do
					if v3 == v2 then
						isExist = true
						break
					end
				end
				if not isExist then
					table.insert(tingHuCards_1, v2)
				end
			end
		end

		table.sort(tingHuCards_1)
		for k,v in pairs(tingHuCards_1) do	
			local card = Card1:newMyInHandCard(v)
			local size = card:getSize()
			local scale = cardHeight / size.height
			card:setScale(scale)
			card:setPosition(cc.p(oriX + size.width * scale / 2, oriY))
			plane:addChild(card)
			card:setTag(0)
			card:setEnabled(true)
			oriX = oriX + size.width * scale
		end

	end
     
	plane:setSize(cc.size(oriX + 20, plane:getSize().height))
	title:addTouchEventListener(
        function(sender,event)
            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                local width = (plane:getChildByName("title")):getSize().width + 16
                local height = plane:getSize().height
                if tag == 0 then
                   plane:setSize(cc.size(width,height))
					for k,v in pairs(plane:getChildren()) do
						if not (v:getName() == "title") then
							v:setVisible(false)
						end
					end
					tag =  1
                elseif tag == 1 then
                   plane:setSize(cc.size(oriX + 20,height))
                   	for k,v in pairs(plane:getChildren()) do
                   		if not (v:getName() == "renyipai") then
							v:setVisible(true)
						elseif renyipaiFlag==true then
						    v:setVisible(true)
						end
					end
					tag = 0 
                end
            end
        end
    )
end

function ControlPlaneOperator:showHupai_vw(card)
	if not (type(TINGSEQ) == "table" and D3_CHUPAI == 1) then
		return
	end
	local plane = CXZMJ_SCENE.hupai_vw
    local tingHuCards
	for k,v in pairs(TINGSEQ) do
		if v.card == card then
			tingHuCards = v.tingHuCards
			break
		end
	end
	if tingHuCards == nil  then
		plane:setVisible(false)
		return
	end
	local card = Card1:newMyInHandCard({m_value = 1})
	local cardSize = card:getSize()
	local scale = 0.5
	plane:setVisible(true)
	plane.cards_vw:removeAllChildren()
	local inhand_plane = CXZMJ_SCENE.players.my_card_plane.inhand_plane
	local remainCardValues = InhandCardMgr:getCardsValueByOutNodesAndMyNodes( inhand_plane )
	local count = 0 --剩余张数

	local oriX = 0
	local oriY = 65

	local tingHuCards_1 = {}
	if #tingHuCards>25 then --胡任意牌
    elseif  #tingHuCards==0  then  --重连没给我发胡的牌的时候
    	 plane:setVisible(false)
    else	--不胡任意牌，胡特定牌
		for i1,v1 in ipairs(tingHuCards) do
			if not v1.huCards or table.getn(v1.huCards) == 0 then
				plane:hide()
				return
			end

			for i2,v2 in ipairs(v1.huCards) do
				local isExist = false
				for i3,v3 in ipairs(tingHuCards_1) do
					if v3 == v2 then
						isExist = true
						break
					end
				end
				if not isExist then
					table.insert(tingHuCards_1, v2)
				end
			end
		end
		table.sort(tingHuCards_1)
		for idx,v in ipairs(tingHuCards_1) do	
			local card = Card1:newMyInHandCard(v)
			local remainCard = 0
			if remainCardValues[v] then
				remainCard = remainCardValues[v]
			else
				remainCard = 4
			end
			count = count + remainCard
			local size = card:getSize()
			card:setScale(scale)
			card:setPosition(cc.p(oriX + cardSize.width * scale * (idx-1) + 10, oriY))
			plane.cards_vw:addChild(card)
			card:showTxtHuRemainCards(remainCard.."张")
		end
	end
	local number = #tingHuCards_1

	local width = 200 + number * cardSize.width * scale + 10
	plane:setSize(cc.size(width, plane:getSize().height))
	plane.txt_cardnum:setString("共"..count.."张")
	if count == 0 then
		plane:hide()
	end
end



function ControlPlaneOperator:setTingNodeVisible(flag)
	if not CXZMJ_SCENE then
		return
	end
	if flag == nil then
		flag = false
	end
	if flag == false then
		self:setHupaiVwVisible(flag)
	end
	CXZMJ_SCENE.players.my_card_plane.ting_hu_plane:setVisible(flag)
end

function ControlPlaneOperator:setHupaiVwVisible(flag)
	if not CXZMJ_SCENE then
		return
	end
	if flag == nil then
		flag = false
	end
	CXZMJ_SCENE.hupai_vw:setVisible(flag)
end

function ControlPlaneOperator:setBtnTheAnim()
end

return ControlPlaneOperator