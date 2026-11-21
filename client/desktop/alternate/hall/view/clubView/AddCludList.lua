--[[
* author:   w
* date:     2018-12-17
* describe: 计算数据总分界面
--]]

local AddCludList = class("AddCludList", function ()
   return cc.CSLoader:createNode("hall/view/clubView/integral_scene.csb") 
end)

local clubSendData = require("hall.view.clubView.clubSendData")
----------增加一个能取出玩家数据的表----------
local player_Friends = {}

local indexTotalPointsTable = {}
function AddCludList:ctor()
   self:initGetValidNode()
end

function AddCludList:initGetValidNode()
	  self.bgContent = self:getChildByName("bgContent")
	  self.closeclue = self.bgContent:getChildByName("guanbi")
    self.zList = self:getChildByName("ListView_1") --:setScrollBarEnabled(true)
--------------------------
    self.panels = self:getChildByName("Panel_1")
-------------------------------------
    self.PaneNum = self:getChildByName("PanelNum"):setVisible(false)
    self.num1 = self.PaneNum:getChildByName("1")
    self.num2 = self.PaneNum:getChildByName("2")
    self.num3 = self.PaneNum:getChildByName("3")
    self.num4 = self.PaneNum:getChildByName("4")
    self.num5 = self.PaneNum:getChildByName("5")
    self.num6 = self.PaneNum:getChildByName("6")
    self.num7 = self.PaneNum:getChildByName("7")
    self.num8 = self.PaneNum:getChildByName("8")
    self.num9 = self.PaneNum:getChildByName("9")
    self.num0 = self.PaneNum:getChildByName("0")
    self.clearNum = self.PaneNum:getChildByName("qingchu")
    self.makeNum = self.PaneNum:getChildByName("queding")
    self.numImg = self.PaneNum:getChildByName("bgAddSub")
    self.closeSet = self.numImg:getChildByName("guanbi1")
    self.numText = self.PaneNum:getChildByName("outPutText")
    self.textBiaoYu = self.PaneNum:getChildByName("textBiaoYu")
    
--------------------------------------
    self.closeclue:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num1:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num2:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num3:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num4:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num5:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num6:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num7:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num8:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num9:addTouchEventListener(handler(self, self.onTouchEvent))
    self.clearNum:addTouchEventListener(handler(self, self.onTouchEvent))
    self.makeNum:addTouchEventListener(handler(self, self.onTouchEvent))
    self.num0:addTouchEventListener(handler(self, self.onTouchEvent))
    self.closeSet:addTouchEventListener(handler(self, self.onTouchEvent))
    -------------------------
end

function AddCludList:requestClubRecord(myOwener, clubId)

	local data= {groupId = clubId}
	local function callback(returnCode, data)
		if returnCode == 0 then
		--------------标签部------------------
                for k,v in pairs(data) do
                	table.insert(player_Friends, {nickName = v.nickName, userId = v.userId, dayingjiaCount = v.dayingjiaCount, pointCount = v.pointCount})
                end            	
            	self:longingPlayers(player_Friends, myOwener, clubId)
    --------------------------------------------
		end
	end
	clubSendData:requestClubRecord(data, callback)
end

function AddCludList:longingPlayers(playerFriends, myOwener, clubId)
  if  tolua.isnull(self.zList) or playerFriends == nil then
    return
  end
  self.zList:removeAllChildren()
	for k,v in pairs(playerFriends) do
            local Num = tostring(k)
            local panel_s = self.panels:clone():setName("panel_s"..Num)
            self.zList:pushBackCustomItem(panel_s)
            -----标签部-----
            local btnAdd = panel_s:getChildByName("btnAdd"):setName("btnAdd" .. Num)
            local btnSub = panel_s:getChildByName("btnSub"):setName("btnSub" .. Num)
            local subPlayer = panel_s:getChildByName("subPlayer"):setName("subPlayer" .. Num):setVisible(false)
           
            if USER_INFO["uid"] == myOwener then
               subPlayer:setVisible(true)
            end
            ---------------
            panel_s:getChildByName("name"):setName("name".. Num):setString(require("hall.GameCommon"):formatNick(v.nickName, 3))
            panel_s:getChildByName("id"):setName("id" .. Num):setString(v.userId)
            panel_s:getChildByName("dayingjia"):setName("dayingjia" .. Num):setString(v.dayingjiaCount)
            panel_s:getChildByName("zongfen"):setName("zongfen" .. Num):setString(v.pointCount)

            btnAdd:addTouchEventListener(handler(self, self.addSubOnTouchEvent))
            btnSub:addTouchEventListener(handler(self, self.addSubOnTouchEvent))
            subPlayer:addTouchEventListener(handler(self, self.addSubOnTouchEvent))
            table.insert(indexTotalPointsTable, panel_s)
    end
end

local myClubId = 0
local myowener = 0

function AddCludList:loadlist(clubData, clubId) 
    myClubId = clubId
    for k,v in pairs(clubData or {}) do
    	if myClubId == tonumber(v.clubId) then
    		myowener = v.owener
    	end
    end
    self:requestClubRecord(myowener, clubId)
end

function AddCludList:callback(returnCode, data)
      local clubListCache = nil
    if returnCode == 0 then
       clubListCache = data
    end
end

function AddCludList:resultAddFen(returnCode,data)
    -- self:callback(returnCode,data)
    -- self:setTotalPoints(TotalPoints, PlaceNum)
end

--(clubId, owners, pId, moudle, score, callback)
--clubSendData:requestChangeClubScore(100805, 15031, 15031, 1, 100, handler(self, self.callback))


 --增减总分
function AddCludList:setTotalPoints(zongFen, places)
   if -tonumber(indexTotalPointsTable[places]:getChildByName("zongfen"..tostring(places)):getString()) > tonumber(zongFen) and tonumber(zongFen) < 0  then
       require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 3, "您的积分修改失败")
       return
   else
      local num = indexTotalPointsTable[places]:getChildByName("zongfen"..tostring(places)):getString()
      local zongFenNum = tonumber(num) + tonumber(zongFen)
      indexTotalPointsTable[places]:getChildByName("zongfen"..tostring(places)):setString(tostring(zongFenNum))
   end
end

function AddCludList:addFen(points, places)
	local playerId = tonumber(indexTotalPointsTable[places]:getChildByName("id"..tostring(places)):getString())
  print("====66666666666====")
  print("====66666666666====")
  print("====66666666666====")
  print("====66666666666====")
  print("====66666666666====")
  print("======playerId=====",playerId)
	clubSendData:requestChangeClubScore(myClubId, myowener, playerId, 1, points, handler(self, self.callback))
end

function AddCludList:subFen(points, places)
	local playerId2 = tonumber(indexTotalPointsTable[places]:getChildByName("id"..tostring(places)):getString())
  print("====77777777777====")
  print("====77777777777====")
  print("====77777777777====")
  print("====77777777777====")
  print("====77777777777====")
  print("====77777777777====")
  print("====77777777777====")
  print("====77777777777====")
  print("======playerId=====",playerId2)
	clubSendData:requestChangeClubScore(myClubId, myowener, playerId2, 0, points, handler(self, self.callback))
end

function AddCludList:requestDeleteMember(userId, clubId)

  if  type(clubId) ~= "number" then
    require("hall.GameTips"):showTips("提示", "", 3, "请选择"..group_name.."!")
    return
  end

  dump(userId,"requestDeleteMember_userId")
  dump(clubId,"requestDeleteMember_clubId")

  local data = {
    playerId = userId;
        owerId = USER_INFO["uid"];
        groupId  = clubId;
    }

    local function callback(returnCode, data)
      if returnCode == 0 then
        require("hall.GameTips"):showTips("提示", "", 3, "删除玩家成功！")
        --self:requestClubMembers(clubId, "refresh")
      end
    end

    clubSendData:requestDeleteMember(data, callback) 
end


local PlaceNum = 0

function AddCludList:addSubOnTouchEvent(sender, event)
   if event == TOUCH_EVENT_BEGAN then
        sender:setScale(0.9)      
   elseif event == TOUCH_EVENT_ENDED then
        sender:setScale(1)
        local touchName = sender:getName()
     for i = 1, table.maxn(indexTotalPointsTable) do
        local Num = tostring(i)
        if myowener == USER_INFO["uid"] then
            if touchName == "btnAdd"..Num then
               self.PaneNum:setVisible(true)
               PlaceNum = tonumber(Num)
            elseif touchName == "btnSub"..Num then
               self.PaneNum:setVisible(true)
               PlaceNum = -tonumber(Num)
            elseif touchName == "subPlayer"..Num then
               dump(myClubId,"456123")
               local player_id = tonumber(indexTotalPointsTable[i]:getChildByName("id"..Num):getString())
               dump(player_id,"520123")
               self:requestDeleteMember(player_id, myClubId)
               indexTotalPointsTable[i]:removeFromParent()
               --self.zList:removeChildByName(indexTotalPointsTable[i])
            end
        end
     end
   end
end

function AddCludList:onTouchEvent(sender, event)
	if event == TOUCH_EVENT_BEGAN then
        sender:setScale(0.9)
    elseif event == TOUCH_EVENT_ENDED then
        sender:setScale(1)
        local touchName = sender:getName()
        if touchName == "guanbi" then
          self:removeSelf()
          indexTotalPointsTable = {}
          player_Friends = {}
        elseif touchName == "guanbi1" then
           self.PaneNum:setVisible(false)
        elseif touchName == "1" then
           self:addNum("1")
           self:showNum()
        elseif touchName == "2" then
           self:addNum("2")
           self:showNum()
        elseif touchName == "3" then
           self:addNum("3")
           self:showNum()  
        elseif touchName == "4" then
           self:addNum("4")
           self:showNum()
        elseif touchName == "5" then
           self:addNum("5")
           self:showNum()
        elseif touchName == "6" then
           self:addNum("6")
           self:showNum()
        elseif touchName == "7" then
           self:addNum("7")
           self:showNum()
        elseif touchName == "8" then
           self:addNum("8")
           self:showNum()
        elseif touchName == "9" then
           self:addNum("9")
           self:showNum()
        elseif touchName == "0" then
           self:addNum("0")
           self:showNum()
        elseif touchName == "qingchu" then
           self:subNum()
        elseif touchName == "queding" then
           self:showNum()
           if PlaceNum > 0 then
               self:setTotalPoints(TotalPoints, PlaceNum)
               self:addFen(TotalPoints, PlaceNum)
           else
               PlaceNum = -PlaceNum
               local TotalPointsHou = tonumber(indexTotalPointsTable[PlaceNum]:getChildByName("zongfen"..tostring(PlaceNum)):getString())
               if TotalPointsHou >= tonumber(TotalPoints) then
               self:subFen(TotalPoints, PlaceNum)
               end
               self:setTotalPoints(-TotalPoints, PlaceNum)
           end
           TotalPoints = "0"
           self:showNum()
           self.PaneNum:setVisible(false)
        end
    end
end

--增加减少的分数
TotalPoints = "0"

--增加积分数字
function AddCludList:addNum(num)
  if self.numText == nil or string.len(self.numText:getString()) == 0 or tonumber(TotalPoints) == 0 then
      TotalPoints = num
  elseif tonumber(TotalPoints) == 0 and string.len(self.numText:getString()) > 0 then
      TotalPoints = "0"
  elseif string.len(self.numText:getString()) >= 1 and string.len(self.numText:getString()) < 6 then
      TotalPoints = TotalPoints .. num
  end
end 

--减少
function AddCludList:subNum()
  if string.len(self.numText:getString()) == nil or string.len(self.numText:getString()) == 1 then
        TotalPoints = "0"
         self:showNum()
  else
      TotalPoints = string.sub(TotalPoints, 1, -2)
         self:showNum() 
  end
end

--显示数字
function AddCludList:showNum()
  self.numText:setString(TotalPoints)
end

function AddCludList:TotalScoreChanges(id, fen)
  if id == nil or fen == nil then return end
  local zongfen = tonumber(fen)
  if zongfen == nil then return end

    if zongfen == 0 then
      return
    elseif zongfen > 0 then 
      clubSendData:requestChangeClubScore(myClubId, myowener, id, 1, zongfen, handler(self, self.callback))
      clubSendData:requestUpdatePattern(myClubId, myowener,0,1,10,handler(self, self.callback))
       return
    elseif zongfen < 0 then
     local zongfen2 = -zongfen
      clubSendData:requestChangeClubScore(myClubId, myowener, id, 0, zongfen2, handler(self, self.callback))
       return
    end
end

return AddCludList

--设置联盟抽水方式和比例
--参数pattern: 1->表示固定抽水；2->表示比例抽水
--参数costUserType: 0->抽大赢家；1->抽嬴家
--参数precent: pattern为1时，表示固定抽水的量；pattern为2时，表示比例抽水（范围0~100）
--function clubSendData:requestUpdatePattern(clubId, owners, pattern, costUserType, precent, callback)