local PHZMenuLayer = class("PHZMenuLayer", function ()
   return cc.CSLoader:createNode("byzp/res/PHZMenuLayer.csb")
end)

PHZMenuLayer.BTN_CLOSE = 1
PHZMenuLayer.BTN_SET = 2
PHZMenuLayer.BTN_EXIT = 3
PHZMenuLayer.BTN_JIESUAN = 4

function PHZMenuLayer:ctor()
	self:setNodeEventEnabled(true)
	self:initUI()
end

function PHZMenuLayer:onEnter()
end

function PHZMenuLayer:onExit()
end

function PHZMenuLayer:initUI()
	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.ended then
    			self:onCallBack(sender:getTag())
    		end
    	end
    end


    local MenuBg = self:getChildByName("menu_bg")
   	self:showMoveAct(MenuBg)

   	MenuBg:setScaleX(g_PHZMainScene:_getScaleParam2())
	-- g_PHZMainScene:setRootSize(self)

    self.btn_close = self:getChildByName("Bg")

    self.btn_close:setScale(g_PHZMainScene:_getScaleParam2())
    MenuBg:setPositionX(MenuBg:getPositionX()*g_PHZMainScene:_getScaleParam2())
    -- g_PHZMainScene:setRootSize(self)

    self.btn_close:setTag(PHZMenuLayer.BTN_CLOSE)
    self.btn_close:addTouchEventListener(onTouchButton)

    self.btn_set = MenuBg:getChildByName("btn_set")
    self.btn_set:setTag(PHZMenuLayer.BTN_SET)
    self.btn_set:addTouchEventListener(onTouchButton)

    self.btn_exit = MenuBg:getChildByName("btn_exit")
    self.btn_exit:setTag(PHZMenuLayer.BTN_EXIT)
    self.btn_exit:addTouchEventListener(onTouchButton)

    --self.btn_jiesuan = MenuBg:getChildByName("btn_jiesuan")
    --self.btn_jiesuan:setTag(PHZMenuLayer.BTN_JIESUAN)
    --self.btn_jiesuan:addTouchEventListener(onTouchButton)
    
end

function PHZMenuLayer:showMoveAct(node)
	if not node then return end
	node:stopAllActions()

	local move1 = cc.MoveBy:create(0.1,cc.p(-589*g_PHZMainScene:_getScaleParam2(),0))
	node:runAction(move1)
end


function PHZMenuLayer:onCallBack(_tag)
	if _tag == PHZMenuLayer.BTN_CLOSE then
		self:clickBtnClose()
	elseif _tag == PHZMenuLayer.BTN_EXIT then
		self:clickBtnReturn()
	elseif _tag == PHZMenuLayer.BTN_SET then
		self:clickBtnSet()
	elseif _tag == PHZMenuLayer.BTN_JIESUAN then
		self:clickBtnJieSan()
	end
end

function PHZMenuLayer:clickBtnJieSan()
	g_PHZMainLayer:disbandGroup()
	self:removeFromParent()
end

--发送查看战绩功能
function PHZMenuLayer:clickBtnSet()
	print("打开设置界面")
	g_PHZMainLayer:showSettingLayer()
end

function PHZMenuLayer:clickBtnClose()
	print("关闭结算界面")
	self:removeFromParent()
end

function PHZMenuLayer:clickBtnReturn()
	print("退出房间")
	require("hall.GameTips"):showTips("提示", "quitRoom", 1, "确定要退出房间么？",_,g_PHZMainLayer.quitRoom)
end


return PHZMenuLayer