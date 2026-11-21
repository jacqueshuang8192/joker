--[[
* author:   zwm
* date:     2019-04-20
* describe: 游戏里房间信息的界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local RoomCommonZXDDLayer = class("RoomCommonZXDDLayer", ViewBaseLayer)

--参数 data里要加解散房间的回调
--  quitRoomHandler 点击里面退出房间的回调
--  disbandRoomHandler 点击里面解散房间的回调
--  rejectDisbandRoomHandler 拒绝解散的回调
--  agreeDisbandRoomHandler 同意解散的回调
--  showMoreFuncHandler 显示功能按钮
--  showGameMsgLayerHandler 显示消息界面
function RoomCommonZXDDLayer:ctor(data)
    RoomCommonZXDDLayer.super.ctor(self, "zixidadun/res/roomCommonZXDDLayer.csb")
    self.data = data
    g_roomCommonLayer = self
        GameUtils.setNodeNameBindObj(self._csbNode)
    display.doLayout(self._csbNode)
    self:setPower()
    self:StartTimer()
    self.Node_notOpen:setVisible(false)
end

function RoomCommonZXDDLayer:setSignal(level)
    -- body
end

function RoomCommonZXDDLayer:setPower(percent)
    require("hall.util.GameMenu"):getDeviceElectricity(self.Node_open:getChildByName("powerBar"))
    -- self.powerBar:setPercent(percent or 100)
end

function RoomCommonZXDDLayer:setRoomRound(count, total)
    self.curRound = count or 0
    self.Node_open:getChildByName("Text_tround"):setString(string.format("%d/%d", (count or 0), (total or 0)))
end

--没有总局数的时候调用
function RoomCommonZXDDLayer:setRoomRoundToSingle(count)
    self.curRound = count or 0
    self.jushuTTF:setString(string.format("第%d局", (count or 0)))
end

function RoomCommonZXDDLayer:setRoomNum(numStr)
    self.Node_open:getChildByName("Text_roomcard"):setString(string.format("房间号:%s", numStr))
end

function RoomCommonZXDDLayer:showMoreBtnLayer()
    g_mainScene:loadLayerByName("hall.roomCommonUI.GameMoreFuncLayer", 4)
    -- if self.data.showMoreBtnLayer then
    --     self.data.showMoreBtnLayer()
    -- end
end

function RoomCommonZXDDLayer:showSendMsg()
    self.sendMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new()
    if tolua.isnull(self.sendMsgLayer) then
        self.sendMsgLayer:addTo(SCENENOW["scene"])
    end
end

function RoomCommonZXDDLayer:registerQuitRoomFunc( func )
    self.quitRoomHandler = func
end

function RoomCommonZXDDLayer:registerDisbandRoomFunc( func )
    self.disbandRoomHandler = func
end

function RoomCommonZXDDLayer:quitRoom()
    print("======quitRoom===9999999====")
    print("======quitRoom===9999999====")
    print("======quitRoom===9999999====")
    if self.data.quitRoomHandler then
        self.data.quitRoomHandler()
    end
end

function RoomCommonZXDDLayer:disbandRoom()
    if self.data.disbandRoomHandler then
        self.data.disbandRoomHandler()
    end
end

--参数 playerLst:牌桌里所以玩家 单个玩家数据结构{state = 1,userId = 12345, userName = "asdf", userUrl = "" }, --state 0,拒绝 1,同意 2,未选择 3,申请人
--参数 applyId:申请者ID
function RoomCommonZXDDLayer:processRevcRequestDisband(playerLst,times, applyId)
    local info = {}
    info.userLst = clone(playerLst)
    info.callBackReject = handler(self, self.toRejectDisbandRoom)
    info.callBackSure = handler(self, self.toAgreeDisbandRoom)
    self.disbandLayer = require("hall.tips.DisbandLayer"):showDisbandLayer(info)
    self.disbandLayer:setTimes(times or dissolutionTime)
end

--state 0,拒绝 1,同意 2,未选择 3,申请人
function RoomCommonZXDDLayer:exchangeStateBySel(uId,state)
    local info = {userId = uId, state = state}
    -- if self.disbandLayer == nil then
    --     print("sadfsdfgsdfg-------------------")
    -- else
        self.disbandLayer:exChangeState(info)
    -- end
end

function RoomCommonZXDDLayer:toRejectDisbandRoom()
    if self.data.rejectDisbandRoomHandler then
        self.data.rejectDisbandRoomHandler()
    end
end

function RoomCommonZXDDLayer:toAgreeDisbandRoom()
    if self.data.agreeDisbandRoomHandler then
        self.data.agreeDisbandRoomHandler()
    end
end

function RoomCommonZXDDLayer:sendTxtByIdx(idx)
    if self.data.sendTxtHand then
        self.data.sendTxtHand()
    end
end

function RoomCommonZXDDLayer:sendFaceByIdx(idx)
    if self.data.sendFaceHand then
        self.data.sendFaceHand(idx)
    end
end

function RoomCommonZXDDLayer:sendEditTxt(msg)
    if self.data.sendEditHand then
        self.data.sendEditHand(msg)
    end
end

function RoomCommonZXDDLayer:onClickBtnChange(sender, event)
    print("换桌布")
    g_mainScene.tableLayer:LoadBg()
end

function RoomCommonZXDDLayer:onClickBtnMoreClick(sender, event)
    if self.data.showMoreFuncHandler then
        self.data.showMoreFuncHandler()
    end
    -- g_mainScene:loadMoreFuncLayer()
end

--[[function RoomCommonZXDDLayer:onClickBtnVoice(sender, event)

    if self.data.voiceRecordHandler then
        self.data.voiceRecordHandler(sender)
    end
end

function RoomCommonZXDDLayer:onClickBtnMsg(sender, event)
    if self.data.showGameMsgLayerHandler then
        self.data.showGameMsgLayerHandler()
    end
    -- g_mainScene:loadGameMsgLayer()
end--]]

function RoomCommonZXDDLayer:clearDisbandLayer()
    if self.disbandLayer ~= nil then
        self.disbandLayer:clearState()
        self.disbandLayer:removeFromParent()
        self.disbandLayer = nil
    end
end

function RoomCommonZXDDLayer:processRevcRejectDisband( info )
    self:clearDisbandLayer()
    -- local userLst = self:getUserInfoLstToDisband(0)
    -- local name = ""
    -- for i, v in ipairs( userLst ) do
    --     if info.rejectId == v.userId then
    --         name = v.userName
    --     end
    -- end
    local paras = {}
    paras.type = 1
    paras.title = "提示"
    paras.content = string.format("解散房间失败,玩家[%s]拒绝解散!", info.rejectId)
    require("hall.tips.CommonTips"):showTips(paras)
    --g_mainScene.roomCommonLayer:exchangeStateBySel(info.rejectId, 0)
end

function RoomCommonZXDDLayer:processRevcDisbandRoomSucc()
    -- 清理桌面数据
    bm.isDisbandSuccess = true
    self:clearDisbandLayer()
    -- require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
end

--跑得快时钟定时器
function RoomCommonZXDDLayer:StartTimer( ... )
    -- body
    local date = os.date("*t", os.time())
    if date.min < 10 then
        date.min = "0" .. date.min
    end
    if tolua.isnull(self.Node_open:getChildByName("Text_times")) == false then
        self.Node_open:getChildByName("Text_times"):setString(date.hour .. ":" .. date.min)
        self:DeleteTimer()
        self.clock_key = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.StartClock), 10, false)
    end

end


function RoomCommonZXDDLayer:DeleteTimer( ... )
    -- body
    if self.clock_key then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.clock_key)
        self.clock_key = nil
    end
end

function RoomCommonZXDDLayer:StartClock( ... )
    -- body
    if tolua.isnull(self.Node_open:getChildByName("Text_times")) == false then
        local date = os.date("*t", os.time())
        if date.min < 10 then
            date.min = "0" .. date.min
        end
        self.Node_open:getChildByName("Text_times"):setString(date.hour .. ":" .. date.min)
    end

end

function RoomCommonZXDDLayer:onExit()
    --g_roomCommonLayer = nil
end

return RoomCommonZXDDLayer
