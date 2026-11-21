--[[
* author:   w
* date:     2018-12-26
* describe: 参与游戏分数界面
--]]

local ParticipationScore = class("ParticipationScore", function ()
	return cc.CSLoader:createNode("hall/view/clubView/ParticipationScore.csb")
end)

local clubSendData = require("hall.view.clubView.clubSendData")

function ParticipationScore:ctor()
	self:initGetValidNode()
	self:initOnTouchEvent()
end

function ParticipationScore:initGetValidNode()
	self.make1 = self:getChildByName("make1") --第一层遮板
	self.bg = self:getChildByName("bg")
	self.Img1 = self.bg:getChildByName("Img1")
	self.Fen1 = self.Img1:getChildByName("Fen1"):setPlaceHolder("请输入分数") --参与游戏分数
    self.Button_1 = self.bg:getChildByName("Button_1") --参与游戏分数修改按钮
    self.xuanzhong1 = self.bg:getChildByName("xuanzhong1") --不可负分
    self.gou1 = self.xuanzhong1:getChildByName("gou1") --不可负分确认
    self.xuanzhong2 = self.bg:getChildByName("xuanzhong2") --可负分
    self.gou2 = self.xuanzhong2:getChildByName("gou2"):setVisible(false) --可负分确认
    self.buttonOne = self.bg:getChildByName("buttonOne") --大赢家下拉按钮
    self.buttonOneText = self.buttonOne:getChildByName("buttonOneText"):setString("大赢家")
    self.buttonTwo = self.bg:getChildByName("buttonTwo") --固定分数下拉按钮
    self.buttonTwoText = self.buttonTwo:getChildByName("buttonTwoText"):setString("固定分数")
    self.Img3 = self.bg:getChildByName("Img3"):setVisible(true)
    self.Text_16 = self.Img3:getChildByName("Text_16"):setPlaceHolder("填分数"):setString("0")--赠送的分数
    self.Text_17 =self.Img3:getChildByName("Text_17"):setVisible(false):setPlaceHolder("分"):setString("0")
    self.Text_6 = self.Img3:getChildByName("Text_6"):setVisible(false)
    self.queDing = self.bg:getChildByName("queDing") --确认按钮
    -----------------------------------
    self.Panel_2 = self:getChildByName("Panel_2"):setVisible(false) --第2层遮板
    self.Sprite_14 = self:getChildByName("Sprite_14"):setVisible(false) --面板
    self.Text_12_0 = self:getChildByName("Text_12_0"):setVisible(false) 
    self.zuoxia = self.Text_12_0:getChildByName("zuoxia"):setVisible(false)  --选项按钮
    self.Text_12 = self:getChildByName("Text_12"):setVisible(false)
    self.zuoshang = self.Text_12:getChildByName("zuoshang"):setVisible(false)  --选项按钮
    -----------------------------------
    self.Panel_2_0 = self:getChildByName("Panel_2_0"):setVisible(false) --第3层遮板 以第2层为例
    self.Sprite_15 = self:getChildByName("Sprite_15"):setVisible(false)
    self.Text_12_1 = self:getChildByName("Text_12_1"):setVisible(false)
    self.youshang = self.Text_12_1:getChildByName("youshang"):setVisible(false) 
    self.Text_12_0_0 = self:getChildByName("Text_12_0_0"):setVisible(false)
    self.youxia = self.Text_12_0_0:getChildByName("youxia"):setVisible(false) 

end

function ParticipationScore:initOnTouchEvent()
	self.Button_1:addTouchEventListener(handler(self, self.OnTouchEvent))
	self.buttonOne:addTouchEventListener(handler(self, self.OnTouchEvent))
	self.buttonTwo:addTouchEventListener(handler(self, self.OnTouchEvent))
	self.zuoshang:addTouchEventListener(handler(self, self.OnTouchEvent))
	self.zuoxia:addTouchEventListener(handler(self, self.OnTouchEvent))
	self.youshang:addTouchEventListener(handler(self, self.OnTouchEvent))
	self.youxia:addTouchEventListener(handler(self, self.OnTouchEvent))
	self.xuanzhong1:addTouchEventListener(handler(self, self.OnTouchEvent))
	self.xuanzhong2:addTouchEventListener(handler(self, self.OnTouchEvent))
	self.queDing:addTouchEventListener(handler(self, self.OnTouchEvent))
end

function ParticipationScore:OnTouchEvent(sender, event)
    if event == TOUCH_EVENT_BEGAN then
        sender:setScale(0.9)
   elseif event == TOUCH_EVENT_ENDED then
        sender:setScale(1)
        local touchName = sender:getName()
        local integralNumMode = 1
         if touchName == "Button_1" then
             self.Fen1:setString(self:getFen(self.Fen1))
             dump(self.club_Id,"999911111")
             dump(self.myowener,"111999")
             dump(self:getFen(self.Fen1),"10086999")
             clubSendData:requestUpdateMinCoins(self.club_Id, self.myowener, tonumber(self.Fen1:getString()), handler(self, self.callback))
         elseif touchName == "buttonOne" then
         	 self:showMake1()
         elseif touchName == "buttonTwo" then
         	 self:showMake2()
         elseif touchName == "zuoshang" then
         	 self.buttonOneText:setString("大赢家")
         	 self:closeMake1()
         elseif touchName == "zuoxia" then
         	 self.buttonOneText:setString("所有赢家")
         	 self:closeMake1()
         elseif touchName == "youshang" then
         	self.buttonTwoText:setString("固定分数")
         	self:closeMake2()
         	self.Text_16:setVisible(true)
         	self.Text_6:setVisible(false)
         	self.Text_17:setVisible(false)
            integralNumMode = 1
         elseif touchName == "youxia" then
         	self.buttonTwoText:setString("百分比分数")
         	self:closeMake2()
         	self.Text_16:setVisible(false)
         	self.Text_6:setVisible(true)
         	self.Text_17:setVisible(true)
             integralNumMode = 2
         elseif touchName == "xuanzhong1" then
         	self.gou1:setVisible(true)
         	if self.gou1:isVisible() then
         		self.gou2:setVisible(fasle)
         	end
         elseif touchName == "xuanzhong2" then
         	self.gou2:setVisible(true)
         	if self.gou2:isVisible() then
         		self.gou1:setVisible(fasle)
         	end
         elseif touchName == "queDing" then
            if USER_INFO.uid ~= self.myowener then
              require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "不是联盟群主，无权设置。")
            else
              dump(integralNumMode,"888666")
              print(self:getFen(self.Text_16))
              print(self:getFen(self.Text_17))
              if integralNumMode == 1 then
                 self.Text_16:setString(self:getFen(self.Text_16)) 
              elseif integralNumMode == 2 then
                 self.Text_17:setString(self:baiNum(self.Text_17))
              end
              if self.Text_16:getString() ~= "" or self.Text_17:getString() ~= "" then

                clubSendData:requestUpdatePattern(self.club_Id, self.myowener,integralNumMode,tonumber(self:getFen(self.Text_17)),tonumber(self:getFen(self.Text_16)),handler(self, self.callback))

                self:removeSelf()
              end
            end
            
         end
    end
end



function ParticipationScore:showMake1()
	self.Panel_2:setVisible(true)
    self.Sprite_14:setVisible(true)
    self.Text_12_0:setVisible(true)
    self.zuoxia:setVisible(true)
    self.Text_12:setVisible(true)
    self.zuoshang:setVisible(true)
end

function ParticipationScore:closeMake1()
	self.Panel_2:setVisible(false)
    self.Sprite_14:setVisible(false)
    self.Text_12_0:setVisible(false)
    self.zuoxia:setVisible(false)
    self.Text_12:setVisible(false)
    self.zuoshang:setVisible(false)
end

function ParticipationScore:showMake2()
	self.Panel_2_0:setVisible(true)
    self.Sprite_15:setVisible(true)
    self.Text_12_1:setVisible(true)
    self.youshang:setVisible(true)
    self.Text_12_0_0:setVisible(true)
    self.youxia:setVisible(true)
end

function ParticipationScore:closeMake2()
	self.Panel_2_0:setVisible(false)
    self.Sprite_15:setVisible(false)
    self.Text_12_1:setVisible(false)
    self.youshang:setVisible(false)
    self.Text_12_0_0:setVisible(false)
    self.youxia:setVisible(false)
end

function ParticipationScore:callback(returnCode, data)
      local clubListCache = nil
    if returnCode == 0 then
       clubListCache = data
    end
end
--修改最小入分场限制
--function clubSendData:requestUpdateMinCoins(clubId, owners, score, callback)
--设置联盟抽水方式和比例
--参数pattern: 1->表示固定抽水；2->表示比例抽水
--参数costUserType: 0->抽大赢家；1->抽嬴家
--参数precent: pattern为1时，表示固定抽水的量；pattern为2时，表示比例抽水（范围0~100）
--function clubSendData:requestUpdatePattern(clubId, owners, pattern, costUserType, precent, callback)

function ParticipationScore:longingData(clubData, clubId)
    dump(clubData,"111111")
    dump(clubId,"22222")
    self.club_Id = clubId
    for k,v in pairs(clubData) do
        if self.club_Id == tonumber(v.clubId) then
           self.myowener = v.owener
        end
    end
end

------输入框返回值方法--------------
function ParticipationScore:getFen(Nums)
	local Str = Nums:getString()
	local StrNum = tonumber(Nums:getString())

	if Str == "" then
	   require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "输入不能为空")
	   return ""
    elseif StrNum == nil then
       require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "请输入纯数字")
       return ""
    elseif (string.len(Str) > 1 and StrNum == 0) or (tonumber(string.sub(Str, 1, -2)) == 0) or (tostring(StrNum) ~= Str)  then
       require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "输入格式错误")
       return ""
    elseif StrNum < 0 then
       require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "不可输入负数")
       return ""
    else
       return StrNum
    end
end

function ParticipationScore:baiNum(Nums)
    local Str = Nums:getString()
    local StrNum = tonumber(Nums:getString())
    dump(StrNum,"19900906")
       if Str == "" then
          require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "输入不能为空")
          return ""
       elseif StrNum == nil then
          require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "请输入纯数字")
          return ""
       elseif (string.len(Str) > 1 and StrNum == 0) or (tonumber(string.sub(Str, 1, -2)) == 0) or (tostring(StrNum) ~= Str)  then
          require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "输入格式错误")
          return ""
       elseif StrNum < 0 then
          require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "不可输入负数")
          return ""
       elseif StrNum > 100 then
          require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "请输入100以内的正整数")
          return ""
       else
          return StrNum 
       end
end


return ParticipationScore
