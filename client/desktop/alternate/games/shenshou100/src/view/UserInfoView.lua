local UserInfoView = class("UserInfoView")
local Card = require("shenshou100.src.Card")
function UserInfoView:ctor(player, isZhuang)
    self.player = player
    self.isZhuang = isZhuang
    self.uid = -1
    self:initUI(self.player)
end

function UserInfoView:initUI(player)
    self.player = self.player
    self.player.oriPos = self.player:getPosition() 
    self.txt = player.txt:setString("")
    self.txt.oriPos = self.txt:getPosition() 
    self.img_fh = player.img_fh
    self.img_xyx = player.img_xyx
    self.worldpoint = (self.player:getParent()):convertToWorldSpace(self.player:getPosition()) --这样写是为了贴近函数的原始用法
    if self.isZhuang then
        self:resetFenE()
    end
    self:clearData()
end

function UserInfoView:refreshPlayerInfo(icon_url, uid, sex, name, ip, addres)
    self.uid = uid
	local size = self.player:getContentSize()
	require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.player.head, size.width, false, name, true, ip, addres)
	name = require("hall.GameCommon"):formatNick(name, 3)
end

function UserInfoView:resetPlayer()
    self.player:setTexture("bg14.png")
end

function UserInfoView:showFh()
    if tolua.isnull(self.img_fh) then
        return
    end
    if self.img_fh then
        self.img_fh:show()
    end
end
function UserInfoView:setFh(score)
    self.img_fh.txt:setString(score)
end

function UserInfoView:showXyx()
    if tolua.isnull(self.img_xyx) then
        return
    end
    if self.img_xyx then
        self.img_xyx:show()
    end
end

function UserInfoView:hideXyx()
    if tolua.isnull(self.img_xyx) then
        return
    end
    if self.img_xyx then
        self.img_xyx:hide()
    end
end

function UserInfoView:hideFh()
    if tolua.isnull(self.img_fh) then
        return
    end
    if self.img_fh then
        self.img_fh:hide()
    end
end

function UserInfoView:clearData()
    self:hideXyx()
    self:hideFh()
end

--拼庄玩家的百分比份额
function UserInfoView:setFenE(value)
    self.txt:setString(value.."%")
end
--拼庄玩家的百分比份额
function UserInfoView:resetFenE()
    self.txt:setString("00.00%")
    self.player.head:removeAllChildren()
end

function UserInfoView:setScore(score, isjs)
    local str = ""
    if score > 0 then
        if isjs then
            str = "+"..tostring(score)
        else
            str = tostring(score)
        end
        dump(tolua.isnull(self.txt))
        self.txt:setFntFile("shenshou100/res/GameScene/win_num_60.fnt")
    else
        str = tostring(score)
        self.txt:setFntFile("shenshou100/res/GameScene/lose_num_60.fnt")
    end
    self.txt:stopAllActions()
    self.player:stopAllActions()

    self.txt:show()
    self.txt:setString(str)
    self.txt:setPositionX(self.txt.oriPos.x - 200)
    local time = 0.02
    local pos1 = {x = self.txt.oriPos.x + 10, y = self.txt.oriPos.y}
    local pos2 = {x = self.txt.oriPos.x - 10, y = self.txt.oriPos.y}
    local MoveTo1 = cc.MoveTo:create(0.05, pos1)
    local MoveTo2 = cc.MoveTo:create(time, pos2)
    local MoveTo3 = cc.MoveTo:create(time, self.txt.oriPos)
    local DelayTime = cc.DelayTime:create(1)
    local CallFunc = cc.CallFunc:create(function()
        self.txt:hide()
    end)
    local Sequence = cc.Sequence:create(MoveTo1, MoveTo2, MoveTo3, DelayTime, CallFunc)
    self.txt:runAction(Sequence)


    local pos1 = {x = self.player.oriPos.x + 10, y = self.player.oriPos.y}
    local pos2 = {x = self.player.oriPos.x - 10, y = self.player.oriPos.y}
    local DelayTime = cc.DelayTime:create(0.1 - time)
    local MoveTo1 = cc.MoveTo:create(time, pos1)
    local MoveTo2 = cc.MoveTo:create(time, pos2)
    local MoveTo3 = cc.MoveTo:create(time, self.player.oriPos)
    local Sequence = cc.Sequence:create(DelayTime, MoveTo1, MoveTo2, MoveTo3)
    self.player:runAction(Sequence)
end

function UserInfoView:getWorldpoint()
    return self.worldpoint
end

function UserInfoView:show( )
    self.player:setVisible(true)
end

function UserInfoView:hide( )
    self.uid = -1
    self.player:setVisible(false)
    self:clearData()
end
function UserInfoView:getPosition( )
    return self.player:getPosition()
end
function UserInfoView:getName( )
    return self.player:getName()
end

return UserInfoView
