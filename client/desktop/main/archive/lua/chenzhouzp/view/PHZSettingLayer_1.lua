local phzServer = import("chenzhouzp.handle.PHZSendHandle")

local PHZSettingLayer = class("PHZSettingLayer", function ()
   return cc.CSLoader:createNode("chenzhouzp/res/PHZSettingLayer.csb")
end)

PHZSettingLayer.BTN_CLOSE = 1
PHZSettingLayer.BTN_JIESAN = 2
PHZSettingLayer.BTN_EXIT_ROOM = 3
PHZSettingLayer.SLIDER_MUSIC = 4
PHZSettingLayer.SLIDER_SOUND = 5

function PHZSettingLayer:ctor()
	self:setNodeEventEnabled(true)

	self:initUI()
    
    self.btn_bg:setScale(g_PHZMainScene:_getScaleParam2())
    g_PHZMainScene:setRootSize(self)
end


function PHZSettingLayer:onEnter()
end

function PHZSettingLayer:onExit()
end

function PHZSettingLayer:initUI()
	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.ended then
    			self:onCallBack(sender:getTag())
    		end
    	end
    end

    self.btn_bg = self:getChildByName("result_bg")
    self.btn_close = self:getChildByName("Button_2_0")
    self.btn_jiesan = self:getChildByName("Button_1")
    self.btn_exit = self:getChildByName("Button_2")

    self.btn_jiesan:setVisible(false)
    self.btn_exit:setVisible(false)

	self.btn_bg:setTag(PHZSettingLayer.BTN_CLOSE)
    self.btn_close:setTag(PHZSettingLayer.BTN_CLOSE)
    self.btn_jiesan:setTag(PHZSettingLayer.BTN_JIESAN)
    self.btn_exit:setTag(PHZSettingLayer.BTN_EXIT_ROOM)

	self.btn_bg:addTouchEventListener(onTouchButton)
    self.btn_close:addTouchEventListener(onTouchButton)
    self.btn_jiesan:addTouchEventListener(onTouchButton)
    self.btn_exit:addTouchEventListener(onTouchButton)

    --按钮滑块
    self.m_MusicSlider          = self:getChildByName("Slider_1")
    self.m_MusicSlider:setTag(PHZSettingLayer.SLIDER_MUSIC)
    self.m_MusicSlider:addEventListener(handler(self, self.onChangedSliderValue))

    self.m_SoundSlider          = self:getChildByName("Slider_2")
    self.m_SoundSlider:setTag(PHZSettingLayer.SLIDER_SOUND)
    self.m_SoundSlider:addEventListener(handler(self, self.onChangedSliderValue))

    local MusicVolume = cc.UserDefault:getInstance():getFloatForKey("MusicVolume")
    local EffectsVolume = cc.UserDefault:getInstance():getFloatForKey("EffectsVolume")

    self.m_MusicSlider:setPercent(MusicVolume)
    self.m_SoundSlider:setPercent(EffectsVolume)

    self.playHeadImg = self:getChildByName("playImg")
    self.playName = self:getChildByName("playName")
    self.playID = self:getChildByName("playID")

    self.playName:setString(require("hall.GameCommon"):formatNick(USER_INFO.nick, 3))
    self.playID:setString("ID:"..USER_INFO.uid)
    self:refreshPlayerInfo(USER_INFO.icon_url,USER_INFO.uid,USER_INFO.sex,USER_INFO.nick)
 
end

function PHZSettingLayer:refreshPlayerInfo(icon_url,uid,sex,name)
    require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.playHeadImg, 70, false, name)
end


function PHZSettingLayer:onChangedSliderValue(sender,eventType)
    print("eventType",eventType,ccui.SliderEventType.percentChanged)
    local audioEngine = cc.SimpleAudioEngine:getInstance()
    if eventType == ccui.SliderEventType.percentChanged then
        local value = sender:getPercent()
        if sender:getTag() == PHZSettingLayer.SLIDER_MUSIC then
            cc.SimpleAudioEngine:getInstance():setMusicVolume(value/100)
            cc.UserDefault:getInstance():setFloatForKey("MusicVolume",value)
        elseif sender:getTag() == PHZSettingLayer.SLIDER_SOUND then
            cc.SimpleAudioEngine:getInstance():setEffectsVolume(value/100)
            cc.UserDefault:getInstance():setFloatForKey("EffectsVolume",value)
        end
    end
end

function PHZSettingLayer:onCallBack(_tag)
	if _tag == PHZSettingLayer.BTN_CLOSE then
		self:clickBtnClose()
	elseif _tag == PHZSettingLayer.BTN_JIESAN then
		self:clickBtnJieSan()
	elseif _tag == PHZSettingLayer.BTN_EXIT_ROOM then
		self:clickBtnEixt()
	end
end

function PHZSettingLayer:clickBtnClose()
	print("关闭结算界面")
	self:removeFromParent()
end

function PHZSettingLayer:clickBtnJieSan()
    
    -- if g_PHZMainScene.m_bGameCount > 0 then
    --      --发送请求玩家全部游戏信息
    --     phzServer:CLI_BROADCAST_GROUP_RESULT()
    -- else
        g_PHZMainLayer:disbandGroup()
    -- end

    --暂时先打开全部游戏总结算界面 test
    -- g_PHZMainLayer:showAllResultLayer()

	self:removeFromParent()
end

function PHZSettingLayer:clickBtnEixt()
	print("退出房間")
	g_PHZMainLayer:quitRoom()
	self:removeFromParent()
end

return PHZSettingLayer