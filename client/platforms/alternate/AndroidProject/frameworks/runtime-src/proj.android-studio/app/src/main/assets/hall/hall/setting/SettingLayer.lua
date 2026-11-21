--[[
* author:   zwm
* date:     2019-03-21
* describe: 设置界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.NewViewBaseLayer")
-- local ViewBaseLayer = require("hall.ViewBaseLayer")
local SettingLayer = class("SettingLayer", ViewBaseLayer)

function SettingLayer:showSetting(isShow, bgData)
    if SCENENOW["scene"]:getChildByTag(1000) ~= nil then
        SCENENOW["scene"]:removeChildByTag(1000)
    end
    self.new(isShow, bgData):addTo(SCENENOW["scene"], 1000)
end

function SettingLayer:ctor(showBtn, bgData)
    self.parentLayer = self:getParent()
    self.bgData = bgData or {}
    local csbPath = "hall/res/setting/hallSettingLayer.csb"
    SettingLayer.super.ctor(self, csbPath)
    GameUtils.setNodeNameBindObj(self._csbNode)
    self:enableMask(true)
    -- self.versionTxt:hide()
    self:initInfo(showBtn)
    self:initCardNode()
    self:initCuopaiNode()
    self:setTag(1000)

    self:initBgMusicNode()
    -- self:initChoseBg(showBtn)
    -- self:initTableNode()
    self.panel_chosebg:hide()
    self.tableNode:hide()
   
    --[[local SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    self.settingBg:setPositionX(SCREEN_WIDTH/2)--]]

    
end

function SettingLayer:initCuopaiNode( )
    local cuopaiDatas = self.bgData.cuopaiDatas
    local cuopaiPath = cc.UserDefault:getInstance():getIntegerForKey("cuopaiType_"..USER_INFO.level, 1)

    for idx = 1, 3 do
        local cuopaiVw = self.cuopaiNode["cuopai"..idx]:hide()
        cuopaiVw.index = idx
        cuopaiVw:onClick(handler(self, self.onClickCuopai))
        cuopaiVw.btn_cuopai:setEnabled(cuopaiPath ~= idx)
    end

    if cuopaiDatas then
        self.cuopaiNode:show()
        for idx, cuopaiData in ipairs(cuopaiDatas) do
            local cuopaiVw = self.cuopaiNode["cuopai"..idx]:show()
            cuopaiVw.txt_cuopai:setString(cuopaiData.txt)
        end
    else
        self.cuopaiNode:hide()
    end
end

function SettingLayer:initCardNode( )
    local cardDatas = self.bgData.cardDatas
    local cardPath = cc.UserDefault:getInstance():getIntegerForKey("cardType_"..USER_INFO.level, 1)

    for idx = 1, 3 do
        local cardVw = self.cardNode["card"..idx]:hide()
        cardVw.index = idx
        cardVw:onClick(handler(self, self.onClickCard))
        cardVw.btn_card:setEnabled(cardPath ~= idx)
    end

    if cardDatas then
        self.cardNode:show()
        for idx, cardData in ipairs(cardDatas) do
            local cardVw = self.cardNode["card"..idx]:show()
            cardVw.txt_card:setString(cardData.txt)
            cardVw.img_card:loadTexture(cardData.path)
            cardVw.img_card:setScale(cardData.scale)
            cardVw.img_card:ignoreContentAdaptWithSize(true)
        end
    else
        self.cardNode:hide()
    end
end

function SettingLayer:initTableNode()
    if USER_INFO.level == 0 then  --大厅
        local tablePath = cc.UserDefault:getInstance():getIntegerForKey("tablePath", 1)
        for idx = 1, 2 do
            local tableVw = self.tableNode:getChildByName("table"..idx)
            tableVw.index = idx
            tableVw:onClick(handler(self, self.onClickTable))
            tableVw.btn_table:setEnabled(tablePath ~= idx)
        end
    else
        self.tableNode:setVisible(false)
    end
end

function SettingLayer:onClickTable(event)
    local target = event.target

    for idx = 1, 2 do
        local tableVw = self.tableNode:getChildByName("table"..idx)
        tableVw:setEnabled(true)
        tableVw.btn_table:setEnabled(true)
    end

    target:setEnabled(false)
    target.btn_table:setEnabled(false)
    cc.UserDefault:getInstance():setIntegerForKey("tablePath", target.index)

    if SCENENOW["scene"].hallMainLayer and SCENENOW["scene"].hallMainLayer.familyMainlayer and SCENENOW["scene"].hallMainLayer.familyMainlayer.onChangeTableBg then
        SCENENOW["scene"].hallMainLayer.familyMainlayer:onChangeTableBg()
    end 
        
end


function SettingLayer:initBgMusicNode( )
	if HasThreeBgm and  HasThreeBgm > 0  then
		local musicPath = cc.UserDefault:getInstance():getIntegerForKey("bgMusicType_"..USER_INFO.level, 1)

		for idx = 1, 3 do
	        local musicVw = self.bgMusicNode:getChildByName("music"..idx)
	        musicVw.index = idx
	        musicVw:onClick(handler(self, self.onClickMusic))
	        musicVw.btn_music:setEnabled(musicPath ~= idx)
    	end
	else
		self.bgMusicNode:setVisible(false)
	end
end

function SettingLayer:onClickMusic(event)
    local target = event.target

    for idx = 1, 3 do
        local musicVw = self.bgMusicNode:getChildByName("music"..idx)
        musicVw:setEnabled(true)
        musicVw.btn_music:setEnabled(true)
    end

    target:setEnabled(false)
    target.btn_music:setEnabled(false)
    cc.UserDefault:getInstance():setIntegerForKey("bgMusicType_"..USER_INFO.level, target.index)
    if SCENENOW.scene.ChoseBgMusic then
    	SCENENOW.scene:ChoseBgMusic()
    end
    
end

function SettingLayer:onClickCard(event)
    local target = event.target
    for idx = 1, 3 do
        local cardVw = self.cardNode["card"..idx]:show()
        cardVw:setEnabled(true)
        cardVw.btn_card:setEnabled(true)
    end
    target:setEnabled(false)
    target.btn_card:setEnabled(false)
    dump(target.index,"target.index")
    cc.UserDefault:getInstance():setIntegerForKey("cardType_"..USER_INFO.level, target.index)

    local cardType = cc.UserDefault:getInstance():getIntegerForKey("cardType_"..USER_INFO.level)
    dump(cardType,"cardType")
    SCENENOW.scene:changeCard()
end

function SettingLayer:onClickCuopai(event)
    local target = event.target
    for idx = 1, 3 do
        local cuopaiVw = self.cuopaiNode["cuopai"..idx]:show()
        cuopaiVw:setEnabled(true)
        cuopaiVw.btn_cuopai:setEnabled(true)
    end
    target:setEnabled(false)
    target.btn_cuopai:setEnabled(false)
    dump(target.index,"target.index")
    dump("cuopaiType_"..USER_INFO.level,"\"cuopaiType_\"..USER_INFO.level")
    cc.UserDefault:getInstance():setIntegerForKey("cuopaiType_"..USER_INFO.level, target.index)
    local cuopaiType = cc.UserDefault:getInstance():getIntegerForKey("cuopaiType_"..USER_INFO.level)

    dump(cuopaiType,"cuopaiType")
    if SCENENOW.scene.ChoseBgMusic then
        SCENENOW.scene:ChoseBgMusic()
    end
end

function SettingLayer:initInfo(showBtn)
    self.btnQuitGame:setVisible(false)
    self.btnExchange:setVisible(showBtn)
    self.btnExchange:onClick(handler(self, self.onClickBtnExchange), true)

    self.musicImg:addTouchEventListener(handler(self, self.onClickBtnVoice))
    self.effectImg:addTouchEventListener(handler(self, self.onClickBtnVoice))

    self:setUserInfo()
    self:initSliders()
    self:setBtnPos()

    self.versionTxt:setString(self:getVersion())
    self.versionTxt:setTouchEnabled(isShowVerifyBt)
    self.versionTxt:onClick(
            function(event)
                if isShowVerifyBt then
                    --移除自身
                    if isOpenControl then
                        isOpenControl = false
                    else
                        --显示检验界面
                        require(Verify_filePath):showScene()
                    end
                end
            end)
end

function SettingLayer:setUserInfo()
    -- self.userID:setString("ID: "..(USER_INFO["uid"] or "0"))

    -- local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"], 3)
    -- self.name:setString(strNick or "")

    -- require("hall.GameCommon"):getUserHead(USER_INFO["icon_url"], USER_INFO["uid"], USER_INFO["sex"], self.headImg, 69, false, USER_INFO["nick"])
end

function SettingLayer:initSliders()
    local musicPrecent = cc.UserDefault:getInstance():getFloatForKey("MusicVolume")*100
    local effectPrecent = cc.UserDefault:getInstance():getFloatForKey("EffectsVolume")*100
    self.sliderMusic:setPercent(musicPrecent)
    self.sliderEffect:setPercent(effectPrecent)
    self.sliderMusic:addEventListener(handler(self, self.callbackSlider))
    self.sliderEffect:addEventListener(handler(self, self.callbackSlider))

    if musicPrecent == 0 then
        MUSIC_ON = false
        self.musicImg:setColor(cc.c3b(127,127,127))
    else
        MUSIC_ON = true
        self.musicImg:setColor(cc.c3b(255,255,255))
    end

    if effectPrecent == 0 then
        SOUND_ON = false
        self.sliderEffect:setColor(cc.c3b(127,127,127))
    else
        SOUND_ON = true
        self.sliderEffect:setColor(cc.c3b(255,255,255))
    end
end

function SettingLayer:callbackSlider(sender, eventType)
    if eventType == ccui.SliderEventType.percentChanged then
        local amount = sender:getPercent()
        local audioEngine = cc.SimpleAudioEngine:getInstance()
        if sender == self.sliderMusic then
            audioEngine:setMusicVolume(amount / 100)
            cc.UserDefault:getInstance():setFloatForKey("MusicVolume", amount / 100)
            if amount == 0 then
                MUSIC_ON = false
                self.musicImg:setColor(cc.c3b(127,127,127))
            else
                MUSIC_ON = true
                self.musicImg:setColor(cc.c3b(255,255,255))
            end

        elseif sender == self.sliderEffect then
            audioEngine:setEffectsVolume(amount / 100)
            cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", amount / 100)
            if amount == 0 then
                SOUND_ON = false
                self.sliderEffect:setColor(cc.c3b(127,127,127))
            else
                SOUND_ON = true
                self.sliderEffect:setColor(cc.c3b(255,255,255))
            end
        end
    end
end

function SettingLayer:initChoseBg(showBtn)
    self.choseBgBtns = {}
    local selectIdx = 1
    if USER_INFO["level"] == 376 or USER_INFO["level"] == 612 or self.bgData.bg or USER_INFO["level"] == 0 then
        selectIdx = cc.UserDefault:getInstance():getIntegerForKey("GameBgType" .. USER_INFO["level"],1)
    elseif USER_INFO["level"] == 395 then
        selectIdx = cc.UserDefault:getInstance():getIntegerForKey("GameBgType" .. USER_INFO["level"],2)
    else
        selectIdx = cc.UserDefault:getInstance():getIntegerForKey("GameBgType",1)
    end
    for i=1,3 do
        table.insert(self.choseBgBtns,self.panel_chosebg:getChildByName("btnChoseBg_"..i))
        self.choseBgBtns[i]:setEnabled(selectIdx ~= i)
        self.choseBgBtns[i]:setTag(i)
        self.choseBgBtns[i]:addTouchEventListener(handler(self , self.onClickChoseBg))
        local image = self.panel_chosebg:getChildByName("Image_bg"..i)
        image:setTag(i)
        image:setTouchEnabled(true)
        image:addTouchEventListener(handler(self , self.onClickChoseBg))

        --换小桌布背景
        if USER_INFO["level"] == 376 or USER_INFO["level"] == 612 then
            self.panel_chosebg:getChildByName("Image_bg"..i):loadTexture("hall/res/setting/image/bg_small"..i.."_376.png")
        elseif USER_INFO["level"] == 391  then
            self.panel_chosebg:getChildByName("Image_bg"..i):loadTexture("xplp_majiang/res/GameScene/show_bg_"..i.."_small.png")
        elseif USER_INFO["level"] == 395 then
            self.panel_chosebg:getChildByName("Image_bg"..i):loadTexture("hall/res/setting/image/bg_small"..i.."_"..USER_INFO["level"]..".png")
        elseif USER_INFO["level"] == 0  then
            --有大厅的 和俱乐部大厅的
            if not showBtn then
                self.panel_chosebg:getChildByName("Image_bg"..i):loadTexture("hall/res/setting/image/friend_bg_small"..i.."_0.png")
            else
                self.panel_chosebg:getChildByName("Image_bg"..i):loadTexture("hall/res/setting/image/bg_small"..i.."_0.png")
            end
        else
            self.panel_chosebg:getChildByName("Image_bg"..i):loadTexture("hall/res/setting/image/bg_small"..i..".png")
        end


        if self.bgData.bg then
            self.panel_chosebg:getChildByName("Image_bg"..i):ignoreContentAdaptWithSize(false)
            self.panel_chosebg:getChildByName("Image_bg"..i):loadTexture(self.bgData.bg[i])
        end
    end

    if USER_INFO["level"] == 376 or USER_INFO["level"] == 612 or USER_INFO["level"] == 391  or USER_INFO["level"] == 395 then
        self.panel_chosebg:getChildByName("Text_zi"):setString("健康绿")
        self.panel_chosebg:getChildByName("Text_lv"):setString("好运蓝")
        self.panel_chosebg:getChildByName("Text_n"):setString("幸运灰")
    end
    if self.bgData.str then
        self.panel_chosebg:getChildByName("Text_zi"):setString(self.bgData.str[1] or "")
        self.panel_chosebg:getChildByName("Text_lv"):setString(self.bgData.str[2] or "")
        self.panel_chosebg:getChildByName("Text_n"):setString(self.bgData.str[3] or "")
    end
end

function SettingLayer:setBtnPos()
    local nameTab = {"musicTxt","effectTxt","musicImg","effectImg","sliderMusic","sliderEffect"}

    if USER_INFO["level"] == 376 or USER_INFO["level"] == 612  
        or USER_INFO["level"] == 391  or self.bgData.bg or USER_INFO["level"] == 0 or USER_INFO["level"] == 395
    then
         self.sound:setPositionY(442)
         self.panel_chosebg:setVisible(true)
    else
        self.panel_chosebg:setVisible(false)
    end

end


function SettingLayer:onClickChoseBg(sender, event)
    local tag = sender:getTag()
    if event == TOUCH_EVENT_BEGAN then
        
    elseif  event == TOUCH_EVENT_CANCELED then
        
    elseif event == TOUCH_EVENT_ENDED then
        for i=1,#self.choseBgBtns do
            if i == tag then
                self.choseBgBtns[i]:setEnabled(false)
                --换背景逻辑
                if USER_INFO["level"] == 376 or USER_INFO["level"] == 612 or USER_INFO["level"] == 391  or self.bgData.bg or USER_INFO["level"] == 0 or USER_INFO["level"] == 395 then
                    cc.UserDefault:getInstance():setIntegerForKey("GameBgType" .. USER_INFO["level"] ,i)
                else
                    cc.UserDefault:getInstance():setIntegerForKey("GameBgType",i)
                end

                if SCENENOW["scene"].onChangeBg then
                    SCENENOW["scene"]:onChangeBg()
                end
            else
                self.choseBgBtns[i]:setEnabled(true)
            end
        end
    end
end


function SettingLayer:getVersion()
    return "版本号: 000001"
end

function SettingLayer:onClickBtnQuitGame(sender, event)
end

function SettingLayer:onClickBtnExchange(sender, event)
    require("hall.GameCommon"):gExitGame()
    dump("onClickBtnExchange")
end

function SettingLayer:onClickBtnVoice(sender, event)

    if event == TOUCH_EVENT_ENDED then
        local name = sender:getName()
        local audioEngine = cc.SimpleAudioEngine:getInstance()

        if name == "musicImg" then
            if MUSIC_ON == true then
                MUSIC_ON = false
                audioEngine:setMusicVolume(0)
                cc.UserDefault:getInstance():setFloatForKey("MusicVolume", 0)
                sender:setColor(cc.c3b(127,127,127))
            else
                MUSIC_ON = true
                local amount = 50
                audioEngine:setMusicVolume(amount / 100)
                cc.UserDefault:getInstance():setFloatForKey("MusicVolume", amount / 100)
                sender:setColor(cc.c3b(255,255,255))
            end

            local musicPrecent = cc.UserDefault:getInstance():getFloatForKey("MusicVolume")*100
            self.sliderMusic:setPercent(musicPrecent)
        elseif name == "effectImg" then

            if SOUND_ON == true then
                SOUND_ON = false
                audioEngine:setEffectsVolume(0)
                cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", 0)
                sender:setColor(cc.c3b(127,127,127))
            else
                SOUND_ON = true
                local amount = 50
                audioEngine:setEffectsVolume(amount / 100)
                cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", amount / 100)
                sender:setColor(cc.c3b(255,255,255))
            end
            local effectPrecent = cc.UserDefault:getInstance():getFloatForKey("EffectsVolume")*100
            self.sliderEffect:setPercent(effectPrecent)
        end
    end
end

function SettingLayer:onClickBtnClose(sender, event)
    self:removeSelf()
end

return SettingLayer