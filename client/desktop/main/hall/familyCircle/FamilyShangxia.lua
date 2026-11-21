--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local ROOM_NUM_LEN = 6
local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyShangxia = class("FamilyShangxia", ViewBaseLayer)
local FamilyData = require("hall.familyCircle.FamilyData")


function FamilyShangxia:ctor(flag , family_id , userId ,ownerId, parents)
    local csbPath = "hall/res/createRoom/shangxia.csb"
    FamilyShangxia.super.ctor(self, csbPath)
    self.saveEnterNum = {}
    self.family_id = family_id
    self.userId = userId
    self.flag = flag
    self.ownerId = ownerId
    self.parents = parents
end

function FamilyShangxia:SetFunc(func)
    self.func = func
end

function FamilyShangxia:showRoomNum()
    for i = 1, ROOM_NUM_LEN do
        if self.saveEnterNum[i] then
            self["enterNum"..i]:setString(self.saveEnterNum[i])
        else
            self["enterNum"..i]:setString("")
        end
    end
end

function FamilyShangxia:onClickBtnNum1(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "1")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnNum2(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "2")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnNum3(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "3")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnNum4(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "4")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnNum5(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "5")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnNum6(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "6")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnNum7(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "7")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnNum8(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "8")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnNum9(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "9")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnNum0(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "0")
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnFinish(sender, event)
    print("===onClickBtnFinish==点击完成=====")
    print("===onClickBtnFinish==点击完成=====")
    local sum_score = tonumber(table.concat(self.saveEnterNum))*100
    print(self.family_id , self.userId , self.flag , sum_score)
	FamilyData:ChangeStrength(self.family_id , self.userId , self.flag , sum_score ,self.ownerId, handler(self , self.ReFushData))
    self:setVisible(false)

end

--changed by zzy 2019-7-9
-- function FamilyShangxia:changedScore(self.family_id , self.userId , self.flag , sum_score)
--     print("======DelectJLB======")
--     local this = self
--     local interfaceName = "/deletePlayerGroup"
--     local httpType = "POST"

--     local data = {
--             playerId1 = USER_INFO.uid,
--             playerId2 = _userId,
--             groupId = self.parents.family_id,
--     }

--     local function callback(returnCode, data)
     
--     end

--     cct.createHttRq({
--         url = HttpAddr .. interfaceName,
--         date = data,
--         type_= httpType,

--         callBack = function(data)
--             local returnCode = tonumber(json.decode(data.netData).returnCode)
--             if 0 == returnCode then 
--                 print("======删除成员成功！=====")
--                 ReFushData
--             elseif 1 == returnCode then 
--                 print("======删除成员失败！=====")
--             end 
--         end})
-- end

function FamilyShangxia:ReFushData()
    self.parents:InitGame(self.family_id)
    self:removeSelf() 
end

function FamilyShangxia:onClickBtnDelete(sender, event)
    if #self.saveEnterNum > 0 then
        table.remove(self.saveEnterNum)
        self:showRoomNum()
    end
end

function FamilyShangxia:onClickBtnClose(sender, event)
    self:removeSelf()
end

return FamilyShangxia