local PHZSetBgLayer = class("PHZSetBgLayer", function ()
   return cc.CSLoader:createNode("chenzhouzp/res/PHZSetBgLayer.csb")
end)

PHZSetBgLayer.BTN_BG_1 = 1
PHZSetBgLayer.BTN_BG_2 = 2
PHZSetBgLayer.BTN_BG_3 = 3
PHZSetBgLayer.BTN_BG_4 = 4

PHZSetBgLayer.BTN_CLOSE = 5
PHZSetBgLayer.BTN_SURE = 6

function PHZSetBgLayer:ctor()
	self:setNodeEventEnabled(true)
	self:initUI()

    self.btn_bg:setScale(g_PHZMainScene:_getScaleParam2())
    g_PHZMainScene:setRootSize(self)
end


function PHZSetBgLayer:onEnter()
end

function PHZSetBgLayer:onExit()
end

function PHZSetBgLayer:initUI()
	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.ended then
    			self:onCallBack(sender:getTag())
    		end
    	end
    end

    self.btn_bg = self:getChildByName("result_bg")
    self.btn_close = self:getChildByName("Button_2_0")
    self.btn_sure = self:getChildByName("Button_1")

	self.btn_bg:setTag(PHZSetBgLayer.BTN_CLOSE)
    self.btn_close:setTag(PHZSetBgLayer.BTN_CLOSE)
    self.btn_sure:setTag(PHZSetBgLayer.BTN_SURE)

	self.btn_bg:addTouchEventListener(onTouchButton)
    self.btn_close:addTouchEventListener(onTouchButton)
    self.btn_sure:addTouchEventListener(onTouchButton)

    self.m_btn_Bg_List = {}
    self.m_img_select_list = {}

    for i=1,4 do
        local tempItem = self:getChildByName("btn_bg_"..i)
        tempItem:setTag(i)
        tempItem:addTouchEventListener(onTouchButton)
        table.insert(self.m_btn_Bg_List,tempItem)
    end

    for i=1,4 do
        local tempItem = self:getChildByName("img_set_"..i)
        table.insert(self.m_img_select_list,tempItem)
    end

    self:refreshBgSelect()

end

function PHZSetBgLayer:showSelectBgByIndex(_index)
    local tempIndex = _index
    for k,v in pairs(self.m_img_select_list) do
        if k == tempIndex then
            v:setVisible(true)
        else 
            v:setVisible(false)
        end
    end
end

function PHZSetBgLayer:refreshBgSelect()
    local tempIndex = cc.UserDefault:getInstance():getIntegerForKey("curentBGIndex",1)
    self.m_BGIndex = tempIndex
    --print("====refreshBgSelect==tempIndex=====",tempIndex)
    self:showSelectBgByIndex(tempIndex)
end

function PHZSetBgLayer:onCallBack(_tag)
	if _tag == PHZSetBgLayer.BTN_CLOSE then
		self:clickBtnClose()
	elseif _tag == PHZSetBgLayer.BTN_SURE then
        --print("=BTN_SURE=_tag==",_tag)
		self:clickBtnSure()
	elseif _tag >= 1 and _tag <= 4 then
        --print("==_tag==",_tag)
        self:clickBtnBg(_tag)
	end
end

function PHZSetBgLayer:clickBtnClose()
    print("关闭结算界面")
    self:removeFromParent()
end

function PHZSetBgLayer:clickBtnBg(_index)
    self.m_BGIndex = _index
    self:showSelectBgByIndex(_index)
end

function PHZSetBgLayer:clickBtnSure()
    --print("=====clickBtnSure(_index)====",self.m_BGIndex)
    cc.UserDefault:getInstance():setIntegerForKey("curentBGIndex",self.m_BGIndex)

    g_PHZMainLayer:setBGImg(self.m_BGIndex)

    self:removeFromParent()
end

return PHZSetBgLayer