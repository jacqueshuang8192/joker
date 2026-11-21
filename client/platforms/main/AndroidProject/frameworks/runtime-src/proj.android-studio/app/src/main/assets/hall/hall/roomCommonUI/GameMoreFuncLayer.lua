--[[
* author:   zwm
* date:     2019-04-20
* describe: 游戏里解散房间等功能的界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local GameMoreFuncLayer = class("GameMoreFuncLayer", ViewBaseLayer)
local EVENTNAME = {
	QUERY_GROUP_GAME_STATUS = "/freeGame/queryGroupGameStatus",
}

function GameMoreFuncLayer:onExit()
    ReqMgr:delHandle("GameMoreFuncLayer", EVENTNAME)
end
    
function GameMoreFuncLayer:ctor(bgData)
    self.bgData = bgData
    ReqMgr:addHandle("GameMoreFuncLayer", EVENTNAME)
    GameMoreFuncLayer.super.ctor(self, "hall/res/roomCommonUI/gameMoreFuncLayer.csb")
    self:showAni()
    local IsShowbtnDisbandRoom=false   --所有游戏显示解散按钮开关
    
    --add by zzy 
    if 0 == SCENENOW["scene"].GameRound then
        self.btnDisbandRoom:setVisible(false)
    else
        self.btnDisbandRoom:setVisible(true)
    end
    if not IsShowbtnDisbandRoom then
        self.btnDisbandRoom:setEnabled(false)
        self.btnDisbandRoom:setOpacity(0)
    end
end

function GameMoreFuncLayer:registerDisbandFuncs(data)
    self._quitRoom = data.quitRoom
    self._disbandRoom = data.disbandRoom--------
end

function GameMoreFuncLayer:set_btnDisbandRoom_visible(flag)
    self.btnDisbandRoom:setVisible(flag)
end

function GameMoreFuncLayer:showAni()
    local precent = ViewBaseLayer._getScaleParam2()
    self.moreBtnBg:setPositionX(1600)
    self.moreBtnNode:setPositionX(1600)

    local posY1 = self.moreBtnBg:getPositionY()
    local posY2 = self.moreBtnNode:getPositionY()

    local ani1 = cc.MoveTo:create(0.3, cc.p(1280*precent, posY1))
    local ani2 = cc.MoveTo:create(0.5, cc.p(1280*precent, posY2))

    self.moreBtnBg:runAction(ani1)
    self.moreBtnNode:runAction(ani2)
end

function GameMoreFuncLayer:onClickBtnSetting(sender, event)
    require("hall.setting.SettingLayer"):showSetting(false, self.bgData)
    self:removeSelf()
end

function GameMoreFuncLayer:onClickBtnQuitRoom(sender, event)
    local paras = {}
    paras.type = 2
    paras.title = "退出房间"
    paras.content = "确定要退出房间?"
    if self._quitRoom ~= nil then
        paras.callBackSure = self._quitRoom
    elseif g_roomCommonLayer then
        paras.callBackSure = handler(g_roomCommonLayer, g_roomCommonLayer.quitRoom)
    end
    -- paras.callBackSure = self._quitRoom ~= nil and self._quitRoom or handler(g_roomCommonLayer, g_roomCommonLayer.quitRoom)
    require("hall.tips.CommonTips"):showTips(paras)
    self:removeSelf()

end

function GameMoreFuncLayer:onClickBtnDisbandRoom(sender, event)
    local this = self
    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    local data = {
        activityId = USER_INFO["activity_id"],
        interfaceType = "j"
    }
    ReqMgr:request(EVENTNAME.QUERY_GROUP_GAME_STATUS, data, handler(self , self.QUERY_GROUP_GAME_STATUS))
end

function GameMoreFuncLayer:QUERY_GROUP_GAME_STATUS( event )
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if netData.returnCode == 0 and self then
        dump(data, "检查当前组局状态")
        if data == 1 then
            local paras = {}
            paras.type = 2
            paras.title = "解散房间"
            paras.content = "提前解散房间不扣钻石，是否确定解散?"
            -- paras.callBackSure = this._disbandRoom ~= nil and this._disbandRoom or handler(g_roomCommonLayer, g_roomCommonLayer.disbandRoom)
            if self._disbandRoom ~= nil then
                print("QUERY_GROUP_GAME_STATUS ----------------- 1")
                paras.callBackSure = self._disbandRoom
            elseif g_roomCommonLayer then
                print("QUERY_GROUP_GAME_STATUS ----------------- 2")
                paras.callBackSure = handler(g_roomCommonLayer, g_roomCommonLayer.disbandRoom)
            end
            require("hall.tips.CommonTips"):showTips(paras)
        elseif data == 2 then
            local paras = {}
            paras.type = 2
            paras.title = "解散房间"
            paras.content = "牌局已开始，确定要申请解散房间？?"
            -- paras.callBackSure = this._disbandRoom ~= nil and this._disbandRoom or handler(g_roomCommonLayer, g_roomCommonLayer.disbandRoom)
            if self._disbandRoom ~= nil then
                paras.callBackSure = self._disbandRoom
            elseif g_roomCommonLayer then
                paras.callBackSure = handler(g_roomCommonLayer, g_roomCommonLayer.disbandRoom)
            end
            require("hall.tips.CommonTips"):showTips(paras)
        elseif data == 0 then
            --结束组局
            local paras = {}
            paras.type = 2
            paras.title = "提示"
            paras.content = "牌局已结束，是否返回大厅？"
            require("hall.tips.CommonTips"):showTipsAndToHall(paras)
        end
        self:removeSelf()
    end
end


function GameMoreFuncLayer:onClickBtnClose(sender, event)
    self:setVisible(false)
end

return GameMoreFuncLayer
