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
local EnterRoomLayer = class("EnterRoomLayer", ViewBaseLayer)

function EnterRoomLayer:ctor(gameData)
    local csbPath = "hall/res/createRoom/enterRoomLayer.csb"
    EnterRoomLayer.super.ctor(self, csbPath)
    self.saveEnterNum = {}
    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    
    self:setScale(SCREEN_WIDTH/1280,SCREEN_HEIGHT/720)

end

function EnterRoomLayer:SetFunc(func)
    self.func = func
end

function EnterRoomLayer:showRoomNum()
    for i = 1, ROOM_NUM_LEN do
        if self.saveEnterNum[i] then
            self["enterNum"..i]:setString(self.saveEnterNum[i])
        else
            self["enterNum"..i]:setString("")
        end
    end

    if #self.saveEnterNum == ROOM_NUM_LEN then
        -- send enter room msg
        local strCode = table.concat(self.saveEnterNum)
        if self.func then 
            self.func(strCode)
            return 
        end
        require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], strCode, "", false, 0, false)
    end
end

function EnterRoomLayer:onClickBtnNum1(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "1")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnNum2(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "2")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnNum3(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "3")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnNum4(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "4")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnNum5(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "5")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnNum6(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "6")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnNum7(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "7")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnNum8(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "8")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnNum9(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "9")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnNum0(sender, event)
    if #self.saveEnterNum < ROOM_NUM_LEN then
        table.insert(self.saveEnterNum, "0")
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnClear(sender, event)
    if #self.saveEnterNum > 0 then
        self.saveEnterNum = {}
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnDelete(sender, event)
    if #self.saveEnterNum > 0 then
        table.remove(self.saveEnterNum)
        self:showRoomNum()
    end
end

function EnterRoomLayer:onClickBtnClose(sender, event)
    self:removeSelf()
end

return EnterRoomLayer