--[[
* author:   zwm
* date:     2019-03-26
* describe: 总战绩cell
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local ViewBaseLayer = require("hall.ViewBaseLayer")
local RecordCell = class("RecordCell", ViewBaseLayer)

function RecordCell:ctor(data,parents)
    local csbPath = "hall/res/record/recordCell.csb"
    RecordCell.super.ctor(self, csbPath)

    self.data = data
    self.parents = parents
    self:initUIInfo(data)

    --add by zzy test    -- hide this btn 
    self.btnMore:setVisible(false)
end

function RecordCell:initUIInfo(data)
    print("--战绩数据--")
    dump(data)
    -- if data.gameTime then
    --     local time = string.split(os.date("%Y/%m/%d %H:%M:%S", data.gameTime), " ")
    --     local dateTimes = time[1]
    --     local times = time[2]
    --     self.dateTime:setString(dateTimes)
    --     self.clockTime:setString(times)
    -- end
    print("RecordCell:initUIInfo")
    --changed by zzy 2019-6-28
    if data.startDate then
        local time = string.split(os.date("%Y/%m/%d %H:%M:%S", data.startDate/1000), " ")
        -- dump(time)
        local dateTimes = time[1]
        local times = time[2]
        self.dateTime:setString(dateTimes)
        self.clockTime:setString(times)
    end

    -- self.roomNum:setString(string.format("房间号:%s", data.roomNum or ""))
    -- self.gameName:setString(data.gameName or "")
    -- local userInfo = self:getUserInfo(data.userinfos)
    -- if userInfo then
    --     require("hall.GameCommon"):getUserHead(userInfo.photoUrl, userInfo.uid, "", self.headImg, 64, false, userInfo.nickName)
    --     self.scoreTotal:setString(userInfo.score or "0")
    -- end
    --changed by zzy 
    local tempStr = self:getRoomNumber(data.roomNum)
    

    self.roomNum_0:setString(string.format("房间号:%s", tempStr or ""))
    self.roomNum:setString(string.format("房间号:%s", tempStr or ""))
    self.gameName:setString(data.activityName or "")

    require("hall.GameCommon"):getUserHead(data.photoUrl, data.userId, "", self.headImg, 64, false, data.nickName)
    self.scoreTotal:setString(data.score/100 or "0")

end

function RecordCell:getRoomNumber( _roomNum )
    if not _roomNum then return " " end
    local tempRoomNum = tonumber(_roomNum)
    if tonumber(_roomNum) <= 0 then return " " end
    local tempNum = 100000
    local tempStr = ""
    for i=1,6 do
        if tempRoomNum >= tempNum then return tempStr..tempRoomNum end
        local str1 = math.modf(tempRoomNum/tempNum)
        local tempRoomNum = tempRoomNum%tempNum
        if str1 < 1 then
            tempStr = "0"..tempStr
        end
        tempNum = tempNum / 10
    end
end


function RecordCell:getUserInfo(lst)
    for i, v in ipairs( lst or {} ) do
        if USER_INFO.uid == v.uid then
            return v
        end
    end
end

function RecordCell:onClickBtnMore(sender, event)
    print("=========Get more things!!!=======")
    self.parents:isShowXQList(true)
    self.parents:refreshXQListByIndex(nil,1)
end

return RecordCell