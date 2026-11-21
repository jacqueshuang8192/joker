local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local PartnerInfo = class("PartnerInfo", NewViewBaseLayer)
local AddNumber = require("hall.familyCircle.addNumber")

function PartnerInfo:ctor(family_id,data,parent)
    local time = os.now()
     self.EVENTNAME = {
        SET_BONUS = "/setBonus",
        SELECT_MY_SON_CONFIG_DIST = "/selectMySonConfigDistSpe".."__"..time,
    }
    ReqMgr:addHandle("PartnerInfo", self.EVENTNAME)
    self.parent = parent
    self.data = data
    dump(data,"PartnerInfo")
    local csbPath = "hall/res/FriendScircle/PartnerInfo/PartnerInfo.csb"
    PartnerInfo.super.ctor(self, csbPath)
    self:enableMask(true)
    self.family_id = family_id
    self:setData(data)
    self.btn_sure:onClick(handler(self, self.onClickSure), true)
    if self.btn_spe_set then
        if HallIsShowSpecialRatio then
            self.btn_spe_set:setVisible(true)
            self.btn_spe_set:onClick(handler(self, self.onClickSpeSet), true)
        else
            self.btn_spe_set:setVisible(false)
        end
    end

end

function PartnerInfo:onClickSure()
    dump(self.bonus,"self.bonus=====>>>>>")
    local data = {
        playerId1 = USER_INFO.uid,
        playerId2 = self.data.playerId,
        groupId = self.data.groupId,
        bonus = self.bonus
    }
    ReqMgr:request(self.EVENTNAME.SET_BONUS, data, handler(self, self.SET_BONUS))
end

function PartnerInfo:onClickSpeSet()

    local newdata = {}
    newdata.groupId = self.data.groupId
    newdata.XYUid = USER_INFO.uid
    newdata.searchUid = self.data.playerId
    self.curPlayerId = self.data.playerId
    ReqMgr:request(self.EVENTNAME.SELECT_MY_SON_CONFIG_DIST, newdata, handler(self, self.SELECT_MY_SON_CONFIG_DIST))

end

function PartnerInfo:SELECT_MY_SON_CONFIG_DIST(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data.distMap or {}
    local roleType = netData.data.roleType or 3
    local error = netData.error
    local PointSetView = require("hall.familyCircle.PointSetViewSpe")
    local newData = {}
    for k,v in pairs(data) do
        newData[tonumber(k)] = v
    end
    local view = PointSetView.new(self.data.groupId, self.curPlayerId, newData, roleType)
    view:addTo(self)
end


function PartnerInfo:SET_BONUS(event )
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if netData.returnCode == 0 and self then
        self.def_text:setString(self.bonus.."%")
        self.parent:InitGame()
        viewMgr:showTip({text = "操作成功！"})
    else
        viewMgr:showTip({text = error})
    end
end

function PartnerInfo:setData(data)
    self.bonus = data.bonus or 0
    self.def_text:setString(self.bonus.."%")
    self.id:setString(data.playerId)
    local strName = require("hall.GameCommon"):formatNick(data.nickName or "0")
    self.name:setString(strName)
    
    local xiaohaoToday = string.format("%0.2f", data.xiaohaoToday/100)--今日积分
	local xiaohaoYesterday = string.format("%0.2f", data.xiaohaoYesterday/100)--昨日积分
    self.z_jifen:setString(xiaohaoYesterday)
    self.j_jifen:setString( xiaohaoToday)
    require("hall.GameCommon"):getUserHead(data.photo, "", "", self.head, 70 , false, "", true)
end

function PartnerInfo:onClickBtnUpdate()
    local minNum_error = "必须设置大于当前点位！"
    --local minNum = self.bonus or 0
    local minNum = 0
    local maxNum_error = "最大点位为100%！"
    local maxNum = 100
    local tip = "当前点位："..self.bonus.."%   注:降低点位将会重置所有下级的点位为0"
    local param = {
        tip = tip, 
        minNum_error = minNum_error, 
        minNum = minNum, 
        maxNum = maxNum, 
        maxNum_error = maxNum_error
    }
    local addNumber = AddNumber.new(handler(self, self.setBonus), param)
    self:addChild(addNumber)
end

function PartnerInfo:setBonus( callData )
    local number = callData.number or ""
    self.bonus = number
    self.def_text:setString(self.bonus.."%")
end

function PartnerInfo:onClickBtnReturn()
    self:removeSelf()
end

function PartnerInfo:onExit()
    ReqMgr:delHandle("PartnerInfo", self.EVENTNAME)
end

return PartnerInfo