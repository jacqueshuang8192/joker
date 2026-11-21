--[[
* author:   zwm
* date:     2050-04-28
* describe: 回放操作界面
* explain:  
--]]


local ViewBaseLayer = require("hall.ViewBaseLayer")
local RecordOptLayer = class("RecordOptLayer", ViewBaseLayer)

local SPEED_ARR = {"1/3", "1/2", "1", "2", "3"}

function RecordOptLayer:ctor(RecordBaseLayer)
    self.RecordBaseLayer = RecordBaseLayer
    local csbPath = "hall/res/record/recordOptLayer.csb"
    RecordOptLayer.super.ctor(self, csbPath)
    self._curSpeed = 3
    self:showPlayingState("请播放")
end

function RecordOptLayer:onExit()

end

function RecordOptLayer:showPlayingState(str)
    self.speedDes:setString(str or "")
end

function RecordOptLayer:onClickBtnReturn(sender, event)
    self.RecordBaseLayer:closeSelf()
end

function RecordOptLayer:onClickBtnStop(sender, event)
    self:showPlayingState("暂停")
    self.btnPlayer:setVisible(true)
    self.btnStop:setVisible(false)
    self.RecordBaseLayer:stopUserOpt()
end

function RecordOptLayer:onClickBtnPlayer(sender, event)
    self:showPlayingState("播放")
    self.btnPlayer:setVisible(false)
    self.btnStop:setVisible(true)
    self.RecordBaseLayer:playUserOptVideo(tonumber(SPEED_ARR[self._curSpeed]))
end

function RecordOptLayer:onClickBtnFastForward(sender, event)
    if self._curSpeed >= 5 then return end
    self.btnPlayer:setVisible(false)
    self.btnStop:setVisible(true)
    self._curSpeed = (self._curSpeed + 1)
    local times = SPEED_ARR[self._curSpeed]
    self:showPlayingState(string.format("%s倍", times))
    self.RecordBaseLayer:playUserOptVideo(tonumber(times))
end

function RecordOptLayer:onClickBtnSlow(sender, event)
    if self._curSpeed <= 1 then return end
    self.btnPlayer:setVisible(false)
    self.btnStop:setVisible(true)
    self._curSpeed = (self._curSpeed - 1)
    local times = SPEED_ARR[self._curSpeed]
    self:showPlayingState(string.format("%s倍", times))
    self.RecordBaseLayer:playUserOptVideo(tonumber(times))
end

function RecordOptLayer:resetOptPositionY(posY)
    if posY == nil then return end
    self.content:setPositionY(posY)
end

return RecordOptLayer