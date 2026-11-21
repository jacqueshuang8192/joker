--[[
* author:   zwm
* date:     2019-04-02
* describe: 结束解散房间消息打开的界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local DisbandLayer = class("DisbandLayer", ViewBaseLayer)

local USER_POS = {
                    cc.p(437, 56), cc.p(587, 56), cc.p(737, 56), cc.p(887, 56),
                    cc.p(437, -70), cc.p(587, -70), cc.p(737, -70), cc.p(887, -70)
                }

--打开共用提示框 data里面的
-- userLst 桌子里玩家的信息{state = 1,userId = 12345, userName = "asdf", userUrl = "" }, --state 0,拒绝 1,同意 2,未选择 3,申请人
-- callBackReject 点击拒绝的回调函数
-- callBackSure   点击同意的回调函数(type 为2时)
function DisbandLayer:showDisbandLayer(data)
    local disbandLayer = self.new(data)
    disbandLayer:addTo(SCENENOW["scene"], 99997)
    disbandLayer:setTag(99997)
    disbandLayer:setName("DisbandLayer_tips")

    local director = cc.Director:getInstance()
    local size = director:getWinSize()
    local size1 = disbandLayer:getContentSize()
    -- local size = disbandLayer:getContentSize()
    -- disbandLayer:setAnchorPoint(cc.p(0.5, 0.5))
    -- disbandLayer:setPosition(cc.p(size.width / 2, size.height / 2))
    disbandLayer:setPosition(cc.p((size.width - size1.width )/ 4, 0))
    dump(disbandLayer:getPosition())
    return disbandLayer
end

function DisbandLayer:ctor(data)
    local csbPath = "hall/res/tips/disbandLayer.csb"
    DisbandLayer.super.ctor(self, csbPath)
    -- self:enableMask(true)
    self.userData = data

    self:setTimes(data.times or dissolutionTime)
    self:setAllUserInfo(data.userLst)
end

function DisbandLayer:setTimes(times)
    self.secondTxt:setString(times or 300)
    if self.secondSchedulerID then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.secondSchedulerID)
        self.secondSchedulerID = nil
    end
    self.secondSchedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.schedulerCallBack), 1, false)
end

function DisbandLayer:schedulerCallBack()
    if tolua.isnull(self.secondTxt) then  return end
    local times = tonumber(self.secondTxt:getString()) or 0
    if times == 0 then
        if self.userData.CallBackSure then
            self.userData.CallBackSure()
        else
            print("CallBackSure is nil, not define CallBackSure function ...")
        end
        if tolua.isnull(self.secondSchedulerID) then return  print("CallBackSure is nil, not define CallBackSure function ... nil") end
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.secondSchedulerID)
        self.secondSchedulerID = nil
    else
        self.secondTxt:setString(times - 1)
    end
end

function DisbandLayer:setAllUserInfo(userLst)
    print("DisbandLayer setAllUserInfo ----------------------------")
    local state = 0 
    for i, v in ipairs( userLst or {} ) do
        if v.userId == USER_INFO.uid then
            state = v.state
        end
        if i == 1 then
            self["user"..i]:setPosition(USER_POS[i])
            self:setUserInfo(self["user"..i], v)
        else
            self["user"..i] = self.user1:clone()
            self["user"..i]:setPosition(USER_POS[i])
            self["user"..i]:addTo(self.content)
            self:setUserInfo(self["user"..i], v)
        end
    end

    local b = state == 2 and 1 or 0 
    print("enter setSelectBtnVisible ----------------------------")
    self:setSelectBtnVisible(b == 1)
end

function DisbandLayer:setUserInfo(node, userInfo)
    dump(userInfo,"userInfo=====>>>>")

    local headImg = node:getChildByName("headImg")
    require("hall.GameCommon"):getUserHead(userInfo.userUrl, userInfo.userId, 1, headImg, 100, false, "")
    local userName = node:getChildByName("userName")
    if userName then
        userName:setString(userInfo.userName or "")
    end

    self:setStateTxt(node:getChildByName("stateTxt"), userInfo)
end

function DisbandLayer:exChangeState(info)
    for i, v in ipairs( self.userData.userLst or {} ) do
        if info.userId == v.userId then
            self:setStateTxt(self["user"..i]:getChildByName("stateTxt"), info)
        end
    end
    if info.userId == USER_INFO.uid then
        self:setSelectBtnVisible(false)
    end
end

function DisbandLayer:setStateTxt(ttf, info)
    if ttf == nil then return end
    local state = info.state 
    if state == 0 then
        ttf:setString("拒绝")
        ttf:setTextColor(cc.c3b(255, 0, 0))
    elseif state == 1 then
        ttf:setString("同意")
        ttf:setTextColor(cc.c3b(0, 222, 52))
    elseif state == 2 then
        ttf:setString("正在选择")
        ttf:setTextColor(cc.c3b(255, 217, 67))
    elseif state == 3 then
        ttf:setString("申请人")
        ttf:setTextColor(cc.c3b(255, 255, 255))
    end
end

function DisbandLayer:setSelectBtnVisible(b)
    --print("setSelectBtnVisible --------------------", b, debug.traceback())
    self.btnReject:setVisible(b)
    self.btnAgree:setVisible(b)
end

function DisbandLayer:onClickBtnReject(sender, event)
    if self.userData.callBackReject then
        self.userData.callBackReject()
    else
        print("CallBackReject is nil, not define CallBackReject function ...")
    end
end

function DisbandLayer:onClickBtnAgree(sender, event)
    if self.userData.callBackSure then
        self.userData.callBackSure()
    else
        print("CallBackSure is nil, not define CallBackSure function ...")
    end
end

function DisbandLayer:clearState()
    if self.secondSchedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.secondSchedulerID)
        self.secondSchedulerID = nil
    end
end

function DisbandLayer:onExit()
    self:clearState()
end

return DisbandLayer