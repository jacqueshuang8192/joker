
local settingScene = class("settingScene")

local SettingCsb_filePath = "hall/res/csb/settings/LayerSetting.csb"

function settingScene:showScene(flag, bChangeUser, bDismiss, sDisband, disbandCallback, buttonShowName,additionalFunc,additionalShowName)

	dump(bDismiss, "-----settingScene-----")

	local dismiss = bDismiss or false
    local change_user = bChangeUser or false
    local showDisband = sDisband or false
    local buttonName = buttonShowName or "解散房间"

    if SCENENOW["scene"] ~= nil then

    	if flag == false then
		    self:removeScene()
		    return
		end

    	local layout = cc.CSLoader:createNode(SettingCsb_filePath):addTo(SCENENOW["scene"])
	    layout:setName("layout_settings")

	    action = cc.CSLoader:createTimeline(SettingCsb_filePath)
        action:retain()
        layout:runAction(action)
        action:gotoFrameAndPlay(0,25,false)
	    if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
            layout:setScale(0.75)
        end

        local Panel_3 = layout:getChildByName("Panel_3")

	    local floor = layout:getChildByName("floor")

	    --关闭按钮
	    local close_bt = floor:getChildByName("close_bt")

	    --音效滑条
	    local sound_slide = floor:getChildByName("sound_slide")

	    --音效开关
	    --local sound_bt = floor:getChildByName("sound_bt")

	    --音量滑条
	    local music_slide = floor:getChildByName("music_slide")
	    --音量开关
	    --local music_bt = floor:getChildByName("music_bt")

	    --退出登录按钮
	    local logout_bt = floor:getChildByName("logout_bt")

	    --控制按钮
	    local verify_bt = floor:getChildByName("verify_bt")
	    if verify_bt ~= nil then

	    	if isSettingShowAppName then
	    	--	verify_bt:setString(appName)
	    	end

	    	verify_bt:setTouchEnabled(isShowVerifyBt)
	    	verify_bt:addTouchEventListener(

	            function(sender,event)

	                if event == TOUCH_EVENT_BEGAN then
	                    sender:setScale(0.9)
	                end

	                --触摸取消
	                if event == TOUCH_EVENT_CANCELED then
	                    sender:setScale(1.0)
	                end

	                --触摸结束
	                if event == TOUCH_EVENT_ENDED then
	                    sender:setScale(1.0)

	                    --移除自身
	                    self:removeScene()

	                    if isOpenControl then

	                    	isOpenControl = false

	                    else

	                    	--显示检验界面
	                    	require(Verify_filePath):showScene()

	                    end

	                end
	                
	            end
	        )

	    else

	    	--定义一个按钮
            local button = ccui.Button:create()
            button:setTouchEnabled(true)
            button:setAnchorPoint(cc.p(0.5, 0.5))
            button:setPosition(508.11, 420.46)
            button:loadTextures("hall/scene/res/" .. resFolder .. "/image/hall/logo.png", nil, nil)
            floor:addChild(button)
            button:setTouchEnabled(isShowVerifyBt)
	    	button:addTouchEventListener(

	            function(sender,event)

	                if event == TOUCH_EVENT_BEGAN then
	                    sender:setScale(0.9)
	                end

	                --触摸取消
	                if event == TOUCH_EVENT_CANCELED then
	                    sender:setScale(1.0)
	                end

	                --触摸结束
	                if event == TOUCH_EVENT_ENDED then
	                    sender:setScale(1.0)

	                    --移除自身
	                    self:removeScene()

	                    if isOpenControl then

	                    	isOpenControl = false

	                    else

	                    	--显示检验界面
	                    	require(Verify_filePath):showScene()

	                    end

	                end
	                
	            end
	        )

	    end

	    --用户头像
	    local user_inf = {}
        user_inf["uid"] = USER_INFO["uid"]
        user_inf["icon_url"] = USER_INFO["icon_url"]
        user_inf["sex"] = USER_INFO["sex"]
        user_inf["nick"] = USER_INFO["nick"]
	    local userhead_iv = floor:getChildByName("userhead_iv")
	    require("hall.GameCommon"):getUserHead(user_inf["icon_url"], user_inf["uid"], user_inf["sex"], userhead_iv, 80, false, USER_INFO["nick"])
	    	
	                dump("open control ")
		-- dump(isShowVerifyBt, "can open control")

	    if onlyHasRoomCardMode == true or isControl == true then
		    userhead_iv:setTouchEnabled(isShowVerifyBt)
		    userhead_iv:addTouchEventListener(function(sender,event)

		    	if event == TOUCH_EVENT_ENDED then

	                --移除自身
	                self:removeScene()
	                if 	isOpenControl then
	                	isOpenControl = false
	                else
	                	--显示检验界面
	                	require(Verify_filePath):showScene()

	                end
		    	end

		    end)
		end

	    --解散组局按钮
	    if 	showDisband then
	       	local name_tt = logout_bt:getChildByName("name_tt")
			name_tt:setFontName("hall/res/font/FZY3JW.TTF")
	       	name_tt:setString(buttonName)
	        logout_bt:addTouchEventListener(disbandCallback)
	    end

    	dump(additionalFunc,"添加额外按钮")

	    if  additionalFunc and  device.platform ~= "ios" then
	       	local logout_bt_pos = logout_bt:getPosition()
	    	local addtion_bt = logout_bt:clone()
	       	local name_tt = addtion_bt:getChildByName("name_tt")
			name_tt:setFontName("hall/res/font/FZY3JW.TTF")
	       	name_tt:setString(additionalShowName)
	    	addtion_bt:addTouchEventListener(additionalFunc)
	       	addtion_bt:setPositionX(logout_bt_pos.x + 120)

	       	logout_bt:getParent():addChild(addtion_bt)
	       	logout_bt:setPositionX(logout_bt_pos.x - 120)
	    end
	    
	    local audioEngine = cc.SimpleAudioEngine:getInstance()

	    local Music = cc.UserDefault:getInstance():getIntegerForKey("Music")  
        local Sound= cc.UserDefault:getInstance():getIntegerForKey("Sound")    
        music_slide:setPercent(Music)   
	    sound_slide:setPercent(Sound)
	          	      
	    --按钮事件
	    local function touchButtonEvent(sender, event)

	        if event == TOUCH_EVENT_ENDED then

	            if sender == close_bt then                    
	                local MusicVolume=audioEngine:getMusicVolume()
	                local EffectsVolume=audioEngine:getEffectsVolume()
	                cc.UserDefault:getInstance():setFloatForKey("MusicVolume", MusicVolume)
	                cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", EffectsVolume)
	                cc.UserDefault:getInstance():flush()
                    local Music=music_slide:getPercent()
                    local Sound=sound_slide:getPercent()
                    cc.UserDefault:getInstance():setIntegerForKey("Music", Music)
	                cc.UserDefault:getInstance():setIntegerForKey("Sound", Sound)
                    layout:removeFromParent()    
		    		cc.UserDefault:getInstance():setBoolForKey("music_on", MUSIC_ON)
	                cc.UserDefault:getInstance():setBoolForKey("sound_on", SOUND_ON)
                     
	            end

	            --打开音乐
	            if sender == music_bt then
	            
	                if audioEngine:getMusicVolume() == 0 then          
	                    audioEngine:setMusicVolume(1.0)
	                    music_slide:setPercent(100)   

	                    MUSIC_ON = true

	                else
	                	print("dazhaohuang",event)
	                    audioEngine:setMusicVolume(0.0)
	                    music_slide:setPercent(5)

	                    MUSIC_ON = false
	     
	                end 

	            elseif sender == sound_bt then
                   
	                if audioEngine:getEffectsVolume() == 0.0 then
	                    --todo

	                    audioEngine:setEffectsVolume(1.0)
	                    sound_slide:setPercent(100)	  

	                    SOUND_ON = true                   
	                    
	                else
	                    audioEngine:setEffectsVolume(0.0)
	                    sound_slide:setPercent(5)

	                    SOUND_ON = false
	                   
	                end

	            elseif sender == logout_bt then
                        
	                require(LoginScene_filePath):show()

	                self:removeScene()

	            end

	        end

	    end
	    close_bt:addTouchEventListener(touchButtonEvent)
	    if not showDisband then
	    	logout_bt:addTouchEventListener(touchButtonEvent)
	    end

	    --滑条
	    local function sliderChanged(sender,eventType)
	        if eventType == ccui.SliderEventType.percentChanged then
	            local amount = sender:getPercent()
	            local audioEngine = cc.SimpleAudioEngine:getInstance()
	            -- amount = math.modf(amount/20)*20
	            if sender == music_slide then
	                --todo
	                audioEngine:setMusicVolume(amount / 100)
	                if amount == 0 then
	                    --todo
	                 
	                    -- music_bt:setColor(cc.c3b(125,125,125))

	                    MUSIC_ON = false

	                else
	                    -- music_bt:setColor(cc.c3b(255,255,255))

	                    MUSIC_ON = true

	                end

	            elseif sender == sound_slide then
	                audioEngine:setEffectsVolume(amount / 100)

	                if amount == 0 then
	                    --todo
	                    -- sound_bt:setColor(cc.c3b(125,125,125))

	                    SOUND_ON = false

	                else
	                    -- sound_bt:setColor(cc.c3b(255,255,255))

	                    SOUND_ON = true

	                end
	                
	            end
	           
	        end
	    end
 
	    -- if device.platform ~= "windows" then

	        -- sound_slide:setPercent(audioEngine:getEffectsVolume() * 100)
	      

	        -- if audioEngine:getMusicVolume() == 0.0 then
	        --     --todo
	        --     music_bt:setColor(cc.c3b(125,125,125))
	        -- else
	        --     music_bt:setColor(cc.c3b(255,255,255))
	        -- end

	        -- if audioEngine:getEffectsVolume() == 0.0 then
	        --     --todo
	        --     sound_bt:setColor(cc.c3b(125,125,125))
	        -- else
	        --     sound_bt:setColor(cc.c3b(255,255,255))
	        -- end
	    
	        -- music_bt:addTouchEventListener(touchButtonEvent)
	        -- sound_bt:addTouchEventListener(touchButtonEvent)
	        sound_slide:addEventListener(sliderChanged)
	        music_slide:addEventListener(sliderChanged)

	    -- end

	    Panel_3:setTouchEnabled(true)
        Panel_3:addTouchEventListener(
            function(sender,event)

                --触摸开始
                if event == TOUCH_EVENT_BEGAN then
                    sender:setScale(1.0)
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then
                    sender:setScale(1.0)
                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    sender:setScale(1.0)

                    local MusicVolume=audioEngine:getMusicVolume()
	                local EffectsVolume=audioEngine:getEffectsVolume()
	                cc.UserDefault:getInstance():setFloatForKey("MusicVolume", MusicVolume)
	                cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", EffectsVolume)
	                cc.UserDefault:getInstance():flush()

	                local Music=music_slide:getPercent()
	                local Sound=sound_slide:getPercent()
	                cc.UserDefault:getInstance():setIntegerForKey("Music", Music)
	                cc.UserDefault:getInstance():setIntegerForKey("Sound", Sound)
	                   
		    		cc.UserDefault:getInstance():setBoolForKey("music_on", MUSIC_ON)
	                cc.UserDefault:getInstance():setBoolForKey("sound_on", SOUND_ON)

		            layout:removeFromParent()

                end

            end
        )

		--取消按钮
        local cancel_bt = floor:getChildByName("cancel_bt")
        cancel_bt:setTouchEnabled(true)
        cancel_bt:addTouchEventListener(

            function(sender,event)

                if event == TOUCH_EVENT_BEGAN then
                    sender:setScale(0.9)
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then
                    sender:setScale(1.0)
                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    sender:setScale(1.0)

                    local MusicVolume=audioEngine:getMusicVolume()
	                local EffectsVolume=audioEngine:getEffectsVolume()
	                cc.UserDefault:getInstance():setFloatForKey("MusicVolume", MusicVolume)
	                cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", EffectsVolume)
	                cc.UserDefault:getInstance():flush()

	                local Music=music_slide:getPercent()
	                local Sound=sound_slide:getPercent()
	                cc.UserDefault:getInstance():setIntegerForKey("Music", Music)
	                cc.UserDefault:getInstance():setIntegerForKey("Sound", Sound)
	                   
		    		cc.UserDefault:getInstance():setBoolForKey("music_on", MUSIC_ON)
	                cc.UserDefault:getInstance():setBoolForKey("sound_on", SOUND_ON)

		            layout:removeFromParent()

                end

            end
        )

    end

end

function settingScene:showSceneForCustom(flag, bChangeUser, bDismiss, sDisband, disbandCallback,buttonShowName,additionalFunc,additionalShowName,CardBackSwitchFunc,BGSwitchFunc,CardBackImages,BGImages)

	local dismiss = bDismiss or false
    local change_user = bChangeUser or false
    local showDisband = sDisband or false
    local buttonName = buttonShowName or "解散房间"

    if SCENENOW["scene"] ~= nil then

    	if flag == false then
		    self:removeScene()
		    return
		end

    	local layout = cc.CSLoader:createNode("hall/scene/res/"..resFolder .. "/setting/LayerSettingExtend.csb"):addTo(SCENENOW["scene"])
	    layout:setName("layout_settings")

	    action = cc.CSLoader:createTimeline("hall/scene/res/"..resFolder .. "/setting/LayerSettingExtend.csb")
        action:retain()
        layout:runAction(action)
        action:gotoFrameAndPlay(0,25,false)
	    if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
            layout:setScale(0.75)
        end

        local Panel_3 = layout:getChildByName("Panel_3")

	    local floor = layout:getChildByName("floor")

	    --关闭按钮
	    local close_bt = floor:getChildByName("close_bt")

	    --音效滑条
	    local sound_slide = floor:getChildByName("sound_slide")

	    --音效开关
	    --local sound_bt = floor:getChildByName("sound_bt")

	    --音量滑条
	    local music_slide = floor:getChildByName("music_slide")
	    --音量开关
	    --local music_bt = floor:getChildByName("music_bt")

	    --退出登录按钮
	    local logout_bt = floor:getChildByName("logout_bt")

	    --控制按钮
	    local verify_bt = floor:getChildByName("verify_bt")
	    if verify_bt ~= nil then

	    	if isSettingShowAppName then
	    	--	verify_bt:setString(appName)
	    	end

	    	verify_bt:setTouchEnabled(isShowVerifyBt)
	    	verify_bt:addTouchEventListener(

	            function(sender,event)

	                if event == TOUCH_EVENT_BEGAN then
	                    sender:setScale(0.9)
	                end

	                --触摸取消
	                if event == TOUCH_EVENT_CANCELED then
	                    sender:setScale(1.0)
	                end

	                --触摸结束
	                if event == TOUCH_EVENT_ENDED then
	                    sender:setScale(1.0)

	                    --移除自身
	                    self:removeScene()

	                    if isOpenControl then

	                    	isOpenControl = false

	                    else

	                    	--显示检验界面
	                    	require(Verify_filePath):showScene()

	                    end

	                end
	                
	            end
	        )

	    else

	    	--定义一个按钮
            local button = ccui.Button:create()
            button:setTouchEnabled(true)
            button:setAnchorPoint(cc.p(0.5, 0.5))
            button:setPosition(508.11, 420.46)
            button:loadTextures("hall/scene/res/" .. resFolder .. "/image/hall/logo.png", nil, nil)
            floor:addChild(button)
            button:setTouchEnabled(isShowVerifyBt)
	    	button:addTouchEventListener(

	            function(sender,event)

	                if event == TOUCH_EVENT_BEGAN then
	                    sender:setScale(0.9)
	                end

	                --触摸取消
	                if event == TOUCH_EVENT_CANCELED then
	                    sender:setScale(1.0)
	                end

	                --触摸结束
	                if event == TOUCH_EVENT_ENDED then
	                    sender:setScale(1.0)

	                    --移除自身
	                    self:removeScene()

	                    if isOpenControl then

	                    	isOpenControl = false

	                    else

	                    	--显示检验界面
	                    	require(Verify_filePath):showScene()

	                    end

	                end
	                
	            end
	        )

	    end

	    --用户头像
	    local user_inf = {}
        user_inf["uid"] = USER_INFO["uid"]
        user_inf["icon_url"] = USER_INFO["icon_url"]
        user_inf["sex"] = USER_INFO["sex"]
        user_inf["nick"] = USER_INFO["nick"]
	    local userhead_iv = floor:getChildByName("userhead_iv")
	    require("hall.GameCommon"):getUserHead(user_inf["icon_url"], user_inf["uid"], user_inf["sex"], userhead_iv, 80, false, USER_INFO["nick"])
	    
		dump(isShowVerifyBt, "can open control")

	    if onlyHasRoomCardMode == true or isControl == true then
		    userhead_iv:setTouchEnabled(isShowVerifyBt)
		    userhead_iv:addTouchEventListener(function(sender,event)

		    	if event == TOUCH_EVENT_ENDED then

	    			dump("open control")

	                --移除自身
	                self:removeScene()

	                if 	isOpenControl then
	                	isOpenControl = false
	                else
	                	--显示检验界面
	                	require(Verify_filePath):showScene()

	                end
		    	end

		    end)
		end
	    
	    --解散组局按钮
	    if 	showDisband then
	       	local name_tt = logout_bt:getChildByName("name_tt")
	       	name_tt:setString(buttonName)
			name_tt:setFontName("hall/res/font/FZY3JW.TTF")
	        logout_bt:addTouchEventListener(disbandCallback)
	    end


		local CBStyleIndex = cc.UserDefault:getInstance():getIntegerForKey("CBStyleIndex",1)
		local BGStyleIndex = cc.UserDefault:getInstance():getIntegerForKey("BGStyleIndex",1)

	    local cardBack_switch_plane = floor:getChildByName("cardBack_switch_plane")

	  	dump(CardBackSwitchFunc,"CardBackSwitchFunc")

	  	local addChangeCardBack = function(item,i) 

	  	    local changeCardBack = function(sender,event) 

		    	if 	event == TOUCH_EVENT_BEGAN then

				    for i = 1,5 do 
				    	local item = cardBack_switch_plane:getChildByName("cardback_"..i)
				    	local choose_box = item:getChildByName("choose_box") 
				    	choose_box:setVisible(false)
			    	end

			    	local choose_box = sender:getChildByName("choose_box")
			    	choose_box:setVisible(true) 

	    		    cc.UserDefault:getInstance():setIntegerForKey("CBStyleIndex",i)
			    	CardBackSwitchFunc(self,i)
		    	end
		    	
			end

	    	item:addTouchEventListener(changeCardBack)

		end

	    for i = 1,5 do 
	    	local item = cardBack_switch_plane:getChildByName("cardback_"..i)
	    	      item:loadTexture(CardBackImages[i])
	    	      -- dump(CardBackImages[i],"可更换牌背的路径")
	    	local choose_box = item:getChildByName("choose_box") 
	    	if  CBStyleIndex == i then
	    		choose_box:setVisible(true)
	    	else
	    		choose_box:setVisible(false)
	    	end

	    	addChangeCardBack(item,i)
    	end

	    local backGround_switch_plane = floor:getChildByName("backGround_switch_plane")

	    local addChangeBG = function(item,i) 

		    local changeBG = function(sender,event) 

		    	if event == TOUCH_EVENT_BEGAN then

				    for i = 1,3 do 
				    	local item = backGround_switch_plane:getChildByName("backGround_"..i)
				    	local choose_box = item:getChildByName("choose_box") 
				    	choose_box:setVisible(false)
			    	end

	    			cc.UserDefault:getInstance():setIntegerForKey("BGStyleIndex",i)

			    	local choose_box = sender:getChildByName("choose_box")
			    	choose_box:setVisible(true) 

			    	BGSwitchFunc(self,i)
		    	end

			end

			item:addTouchEventListener(changeBG)

		end

	    for i = 1,3 do 
	    	local item = backGround_switch_plane:getChildByName("backGround_"..i)

	    	if BGImages[i] then
	 		    item:loadTexture(BGImages[i])	 
 		  	else
 		  		item:setVisible(false)
 		  	end

	    	local choose_box = item:getChildByName("choose_box") 
	    	if  BGStyleIndex == i then
	    		choose_box:setVisible(true)
	    	else
	    		choose_box:setVisible(false)
	    	end
	    	addChangeBG(item,i)
    	end

    	dump(additionalFunc,"添加额外按钮")

	    if  additionalFunc then
	       	local logout_bt_pos = logout_bt:getPosition()
	    	local addtion_bt = logout_bt:clone()
	       	local name_tt = addtion_bt:getChildByName("name_tt")
			name_tt:setFontName("hall/res/font/FZY3JW.TTF")
	       	name_tt:setString(additionalShowName)
	    	addtion_bt:addTouchEventListener(additionalFunc)
	       	addtion_bt:setPosition(logout_bt_pos.x,logout_bt_pos.y - 50 )

	       	logout_bt:getParent():addChild(addtion_bt)
	       	logout_bt:setPositionY(logout_bt_pos.y + 20)
	    end
	    
	    local audioEngine = cc.SimpleAudioEngine:getInstance()

	    local Music = cc.UserDefault:getInstance():getIntegerForKey("Music")  
        local Sound= cc.UserDefault:getInstance():getIntegerForKey("Sound")    
        music_slide:setPercent(Music)   
	    sound_slide:setPercent(Sound)
	          	      
	    --按钮事件
	    local function touchButtonEvent(sender, event)

	        if event == TOUCH_EVENT_ENDED then

	            if sender == close_bt then                    
	                local MusicVolume=audioEngine:getMusicVolume()
	                local EffectsVolume=audioEngine:getEffectsVolume()
	                cc.UserDefault:getInstance():setFloatForKey("MusicVolume", MusicVolume)
	                cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", EffectsVolume)
	                cc.UserDefault:getInstance():flush()
                    local Music=music_slide:getPercent()
                    local Sound=sound_slide:getPercent()
                    cc.UserDefault:getInstance():setIntegerForKey("Music", Music)
	                cc.UserDefault:getInstance():setIntegerForKey("Sound", Sound)
                    layout:removeFromParent()    
		    		cc.UserDefault:getInstance():setBoolForKey("music_on", MUSIC_ON)
	                cc.UserDefault:getInstance():setBoolForKey("sound_on", SOUND_ON)
                     
	            end

	            --打开音乐
	            if sender == music_bt then
	            
	                if audioEngine:getMusicVolume() == 0 then          
	                    audioEngine:setMusicVolume(1.0)
	                    music_slide:setPercent(100)   

	                    MUSIC_ON = true

	                else
	                	print("dazhaohuang",event)
	                    audioEngine:setMusicVolume(0.0)
	                    music_slide:setPercent(5)

	                    MUSIC_ON = false
	     
	                end 

	            elseif sender == sound_bt then
                   
	                if audioEngine:getEffectsVolume() == 0.0 then
	                    --todo

	                    audioEngine:setEffectsVolume(1.0)
	                    sound_slide:setPercent(100)	  

	                    SOUND_ON = true                   
	                    
	                else
	                    audioEngine:setEffectsVolume(0.0)
	                    sound_slide:setPercent(5)

	                    SOUND_ON = false
	                   
	                end

	            elseif sender == logout_bt then
                        
	                require(LoginScene_filePath):show()

	                self:removeScene()

	            end

	        end

	    end
	    close_bt:addTouchEventListener(touchButtonEvent)
	    if not showDisband then
	    	logout_bt:addTouchEventListener(touchButtonEvent)
	    end

	    --滑条
	    local function sliderChanged(sender,eventType)
	        if eventType == ccui.SliderEventType.percentChanged then
	            local amount = sender:getPercent()
	            local audioEngine = cc.SimpleAudioEngine:getInstance()
	            -- amount = math.modf(amount/20)*20
	            if sender == music_slide then
	                --todo
	                audioEngine:setMusicVolume(amount / 100)
	                if amount == 0 then
	                    --todo
	                 
	                    -- music_bt:setColor(cc.c3b(125,125,125))

	                    MUSIC_ON = false

	                else
	                    -- music_bt:setColor(cc.c3b(255,255,255))

	                    MUSIC_ON = true

	                end

	            elseif sender == sound_slide then
	                audioEngine:setEffectsVolume(amount / 100)

	                if amount == 0 then
	                    --todo
	                    -- sound_bt:setColor(cc.c3b(125,125,125))

	                    SOUND_ON = false

	                else
	                    -- sound_bt:setColor(cc.c3b(255,255,255))

	                    SOUND_ON = true

	                end
	                
	            end
	           
	        end
	    end


	        sound_slide:addEventListener(sliderChanged)
	        music_slide:addEventListener(sliderChanged)

	    -- end

	    Panel_3:setTouchEnabled(true)
        Panel_3:addTouchEventListener(
            function(sender,event)

                --触摸开始
                if event == TOUCH_EVENT_BEGAN then
                    sender:setScale(1.0)
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then
                    sender:setScale(1.0)
                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    sender:setScale(1.0)

                    local MusicVolume=audioEngine:getMusicVolume()
	                local EffectsVolume=audioEngine:getEffectsVolume()
	                cc.UserDefault:getInstance():setFloatForKey("MusicVolume", MusicVolume)
	                cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", EffectsVolume)
	                cc.UserDefault:getInstance():flush()

	                local Music=music_slide:getPercent()
	                local Sound=sound_slide:getPercent()
	                cc.UserDefault:getInstance():setIntegerForKey("Music", Music)
	                cc.UserDefault:getInstance():setIntegerForKey("Sound", Sound)
	                   
		    		cc.UserDefault:getInstance():setBoolForKey("music_on", MUSIC_ON)
	                cc.UserDefault:getInstance():setBoolForKey("sound_on", SOUND_ON)

		            layout:removeFromParent()

                end

            end
        )

		--取消按钮
        local cancel_bt = floor:getChildByName("cancel_bt")
        cancel_bt:setTouchEnabled(true)
        cancel_bt:addTouchEventListener(

            function(sender,event)

                if event == TOUCH_EVENT_BEGAN then
                    sender:setScale(0.9)
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then
                    sender:setScale(1.0)
                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    sender:setScale(1.0)

                    local MusicVolume=audioEngine:getMusicVolume()
	                local EffectsVolume=audioEngine:getEffectsVolume()
	                cc.UserDefault:getInstance():setFloatForKey("MusicVolume", MusicVolume)
	                cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", EffectsVolume)
	                cc.UserDefault:getInstance():flush()

	                local Music=music_slide:getPercent()
	                local Sound=sound_slide:getPercent()
	                cc.UserDefault:getInstance():setIntegerForKey("Music", Music)
	                cc.UserDefault:getInstance():setIntegerForKey("Sound", Sound)
	                   
		    		cc.UserDefault:getInstance():setBoolForKey("music_on", MUSIC_ON)
	                cc.UserDefault:getInstance():setBoolForKey("sound_on", SOUND_ON)

		            layout:removeFromParent()

                end

            end
        )

    end

end

function settingScene:removeScene()

	local s = SCENENOW["scene"]:getChildByName("layout_settings")
    if s then
        s:removeSelf()
    end
	
end

return settingScene