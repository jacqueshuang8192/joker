--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyLimit = class("FamilyLimit", ViewBaseLayer)
local FamilyData = require("hall.familyCircle.FamilyData")

function FamilyLimit:ctor(family_id,parents)
 	local csbPath = "hall/res/FriendScircle/limit.csb"
 	FamilyLimit.super.ctor(self, csbPath)
 	self.family_id = family_id

 	--changed by zzy 2019-7-10
 	self.ownerId = parents:getFamilyOwnID()

    self.setSelectedIndex = 3       --固定抽水类型 3  大赢家 2 赢家：1

 	self.GuDingCS = 2               --固定抽水类型
 	self.isChouBigWin = 0           --是否抽赢家
 	self.ChouValue = 0              --抽水数值

 	self:InitData()
	self:InitGame()

	self:getLimitInfo()
end

function FamilyLimit:setLimitInfo(data)
	print("开始刷新所有的信息！！！")
    dump(data)
    self.btnSure:setVisible(false)
    self.strength_txt:setString(data.strengthLimit/100 or "0")
    self.pump_txt:setString(data.costLimit/100 or "")
    self.checkBoxWin:setTouchEnabled(false)
    self.checkBoxBigWin:setTouchEnabled(false)
    self.checkBoxFixed:setTouchEnabled(false)

    self.ChouValue = data.commission


    if data.cost_pattern == 1  then
        self.win_txt:setString("")
        self.bigwin_txt:setString("")
        self.fixed_txt:setString(data.commission/100 or "")
        self.fixed_txt:setVisible(true)

        self.checkBoxBigWin:setSelected(false)
        self.checkBoxFixed:setSelected(true)
        self.checkBoxWin:setSelected(false)

        self.GuDingCS = 1
        self.setSelectedIndex = 3
        self.isChouBigWin = 1

    elseif data.cost_pattern == 2 and data.cost_user_type == 1 then
        self.win_txt:setString("")
        self.bigwin_txt:setString(data.commission or "")
        self.fixed_txt:setString("")
        self.bigwin_txt:setVisible(true)

         self.checkBoxBigWin:setSelected(true)
        self.checkBoxFixed:setSelected(false)
        self.checkBoxWin:setSelected(false)

        self.GuDingCS = 2
        self.isChouBigWin = 1
         self.setSelectedIndex = 2

    elseif data.cost_pattern == 2 and data.cost_user_type == 0 then
        self.win_txt:setString(data.commission or "")
        self.bigwin_txt:setString("")
        self.fixed_txt:setString("")
        self.win_txt:setVisible(true)

        self.checkBoxBigWin:setSelected(false)
        self.checkBoxFixed:setSelected(false)
        self.checkBoxWin:setSelected(true)

        self.GuDingCS = 2
        self.isChouBigWin = 0
        self.setSelectedIndex = 1
    end

    if data.updateCostCount == 0 then
        self.btnSure:setVisible(true)
        self.checkBoxWin:setTouchEnabled(true)
        self.checkBoxBigWin:setTouchEnabled(true)
        self.checkBoxFixed:setTouchEnabled(true)
    end
end

function FamilyLimit:getLimitInfo()
    local this = self
    local interfaceName = "/selectCluConfigCostPattern "
    local httpType = "POST"

     local data = {
            groupId = self.family_id,
     }
    local function callback(returnCode, data)
     
    end
    cct.createHttRq({
        url = HttpAddr .. interfaceName,
        date = data,
        type_= httpType,

        callBack = function(data)
        	print("====获取限制信息====")
            local returnCode = tonumber(json.decode(data.netData).returnCode)
            if 0 == returnCode then 
                if this and this.setLimitInfo then 
            	   this:setLimitInfo(json.decode(data.netData).data)
                end
            end 
        end})
end

function FamilyLimit:InitData()

end 	

function FamilyLimit:InitGame()
	local strength_limit = FamilyData:GetGameLimitData() 
    strength_limit = tonumber(strength_limit) or 0
	self.strength_txt:setString(strength_limit/100)

	self.bigwin_txt:setVisible(false)
	self.fixed_txt:setVisible(false)
    self.checkBoxWin:addEventListenerCheckBox(handler(self , self.OnClickCheckBoxWin))
    self.checkBoxBigWin:addEventListenerCheckBox(handler(self , self.OnClickCheckBoxBigWin))
 	self.checkBoxFixed:addEventListenerCheckBox(handler(self , self.OnClickCheckBoxFixed))

end

function FamilyLimit:OnClickCheckBoxWin(sender , eventType)
    require("hall.GameCommon"):playEffectSound("hall/scene/res/common/music/Audio_Button_Click.mp3")

    if eventType == CHECKBOX_STATE_EVENT_SELECTED then
        self.checkBoxBigWin:setSelected(false)
        self.checkBoxFixed:setSelected(false)
        self.checkBoxWin:setTouchEnabled(false)

        self.checkBoxBigWin:setTouchEnabled(true)
        self.checkBoxFixed:setTouchEnabled(true)

        self.bigwin_txt:setString("")
        self.fixed_txt:setString("")
        self.bigwin_txt:setVisible(false)
        self.win_txt:setVisible(true)
        self.fixed_txt:setVisible(false)
        self.GuDingCS = 2
        self.isChouBigWin = 0
        self.setSelectedIndex = 1
    end

end

function FamilyLimit:OnClickCheckBoxBigWin(sender , eventType)

  	require("hall.GameCommon"):playEffectSound("hall/scene/res/common/music/Audio_Button_Click.mp3")

    if eventType == CHECKBOX_STATE_EVENT_SELECTED then

       	   self.checkBoxWin:setSelected(false)
    	   self.checkBoxWin:setTouchEnabled(true)

    	   self.checkBoxFixed:setSelected(false)
    	   self.checkBoxFixed:setTouchEnabled(true)

    	   self.checkBoxBigWin:setTouchEnabled(false)

    	   self.win_txt:setString("")
    	   self.fixed_txt:setString("")
    	   self.win_txt:setVisible(false)
    	   self.fixed_txt:setVisible(false)
    	   self.bigwin_txt:setVisible(true)
    	   self.GuDingCS = 2
    	   self.isChouBigWin = 1
           self.setSelectedIndex = 2
    end
end

function FamilyLimit:OnClickCheckBoxFixed(sender , eventType)

	require("hall.GameCommon"):playEffectSound("hall/scene/res/common/music/Audio_Button_Click.mp3")
    if eventType == CHECKBOX_STATE_EVENT_SELECTED then
 		
 	

		   self.checkBoxWin:setSelected(false)
    	   self.checkBoxWin:setTouchEnabled(true)

    	   self.checkBoxBigWin:setSelected(false)
    	   self.checkBoxBigWin:setTouchEnabled(true)

    	   self.checkBoxFixed:setTouchEnabled(false)
    	   self.win_txt:setString("")
    	   self.bigwin_txt:setString("")
    	   self.fixed_txt:setVisible(true)
    	   self.win_txt:setVisible(false)
    	   self.bigwin_txt:setVisible(false)
    	   self.GuDingCS = 1
    	   self.isChouBigWin = 1
           self.setSelectedIndex = 3
    end
end 


function FamilyLimit:onClickBtnSure()

    -- if tonumber(self.win_txt:getString()) ~= nil then

    local num1 = tonumber(self.strength_txt:getString()) or 0
    local num2 = tonumber(self.pump_txt:getString()) or 0
    local num3 = tonumber(self.win_txt:getString()) or 0
    local num4 = tonumber(self.bigwin_txt:getString()) or 0
    local num5 = tonumber(self.fixed_txt:getString()) or 0


	local strength_limit = num1*100 -- 体力限制
	local pump_txt = num2*100 -- 抽水限制

	local win_txt = num3 --赢家分数
	local bigwin_txt = num4 --大赢家分数
	local fixed_txt = num5*100 --固定分数

    print("==strength_limit===pump_txt==win_txt==bigwin_txt===fixed_txt==",strength_limit,pump_txt,win_txt,bigwin_txt,fixed_txt)
    if self.setSelectedIndex == 1 then
        self.ChouValue = win_txt
    elseif self.setSelectedIndex == 2 then
        self.ChouValue = bigwin_txt
    elseif self.setSelectedIndex == 3 then
        self.ChouValue = fixed_txt
    end

    if self.setSelectedIndex ~= 3 then
        if self.ChouValue <= 0 or self.ChouValue >= 100 then
            -- require("hall.GameTips"):showTips("提示", "", 2, "积分不足,请添加积分！")
            viewMgr:showTip({text = "积分不足,请添加积分！"})

            return
        end
    end

    -- print(self.family_id,self.ownerId,self.GuDingCS,self.isChouBigWin,self.ChouValue)
	-- self.ChouValue = win_txt or bigwin_txt or fixed_txt or 0   GuDingCS

	FamilyData:ChangePump(self.family_id,self.ownerId,self.GuDingCS,self.isChouBigWin,self.ChouValue,pump_txt,strength_limit,self)

end

function FamilyLimit:onClickBtn2()
	self.fixed_txt:setString("20")
end

function FamilyLimit:onClickBtn3()
	-- body
	if not (self.fixed_txt:isVisible()) then 
		return 
	end 
	self.fixed_txt:setString("30")
end

function FamilyLimit:onClickBtn5( ... )
	if not (self.fixed_txt:isVisible()) then 
		return 
	end 
	self.fixed_txt:setString("50")
end

function FamilyLimit:onClickBtn10( ... )
	if not (self.fixed_txt:isVisible()) then 
		return 
	end 
	self.fixed_txt:setString("100")
end

function FamilyLimit:onClickBtnClose() 
	self:removeSelf()
end 

return FamilyLimit