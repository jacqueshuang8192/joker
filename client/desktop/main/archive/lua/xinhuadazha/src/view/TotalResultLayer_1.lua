--[[
* author:   zwm
* date:     2020-05-28
* describe: 510k大结算界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local ViewBaseLayer = require("hall.ViewBaseLayer")
local TotalResultLayer = class("TotalResultLayer", ViewBaseLayer)

local CELL_POS_X = 35
local CELL_POS_Y_BEGIN = 493
local CELL_POS_Y_INTERVAL = 124

function TotalResultLayer:ctor(data)
    TotalResultLayer.super.ctor(self, "xinhuadazha/res/TotalResultLayer.csb")
    self._data = data
    self:__initUI()
    self:showResult(self._data)
end

function TotalResultLayer:__initUI()    
    self.btnShare:setVisible(false)
    -- self.cell1:setVisible(false)
    -- self.cell2:setVisible(false)
    -- self.cell3:setVisible(false)
    -- self.cell4:setVisible(false)
end

function TotalResultLayer:showResult(data)
    print("xhdz TotalResultLayer:showResult ------------------", data == nil)
    if data == nil then return end
    dump(data, "TotalResultLayer:showResult(data) == ")
    local bigWinUid = self:getBigWinUid()
    for i, v in ipairs(data or {}) do
        local item = require("xinhuadazha.src.view.TotalCell").new(v, v.uid == bigWinUid)
        item:setVisible(true)
        item:setPosition(cc.p(90 + (i-1)*280, 130))
        self.content:addChild(item)
        -- self:initItem(item, v, v.uid == bigWinUid)
    end
end

function TotalResultLayer:getBigWinUid()
    local uid = 0
    local maxSocre = 0
    for i, v in ipairs(self._data or {}) do
        if v.chips > maxSocre then
            maxSocre = v.chips
            uid = v.uid
        end
    end
    
    return uid
end

function TotalResultLayer:initItem(obj, info, isBigWin)
    dump(obj, "obj == ")
    local cell = obj:getChildByName("cell")
    cell:getChildByName("tScore"):setString(info.chips)
    cell:getChildByName("winFlag"):setVisible(isBigWin)
    if info.chips < 0 then
        local sp = display.newSprite("xinhuadazha/res/image/total/lose_bg.png")
        if sp then
            cell:getChildByName("winOrLossBg"):setTexture("xinhuadazha/res/image/total/lose_bg.png")
        end
    end
    self:setUserInfo(cell, info)
    local subCell = cell:getChildByName("subCell")
    subCell:setVisible(false)
    for i,v in ipairs(info.turnchip) do
        local subItem = subCell:clone()
        subItem:setVisible(true)
        self:initSubItem(subItem, v/100, i)
        cell:getChildByName("subRecordList"):pushBackCustomItem(subItem)
    end
end

function TotalResultLayer:initSubItem(obj, v, idx)
    obj:getChildByName("subIdx"):setString(string.format("第%d局", idx))
    obj:getChildByName("subScore"):setString(v or "0")

end

function TotalResultLayer:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    strUrl = string.sub(strUrl,nPos+1,string.len(strUrl))
    nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    return strPic..".jpg"
end

function TotalResultLayer:setUserInfo(obj, info)
    obj:getChildByName("name"):setString(require("hall.GameCommon"):formatNick(info.nickName, 4))

    local strHead = self:getUnformatPic(info.portrait)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        obj:getChildByName("headImg"):loadTexture(imgFullPath)
    end
    -- body
end

function TotalResultLayer:onClickBtnToHall(sender, event)
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], USER_INFO["family_id"])
    -- require("hall.tips.CommonTips"):_gameToHall()
end

function TotalResultLayer:onClickBtnShare(sender, event)
    local paras = {}
    paras["showType"] = 2;
    paras["desc"] = " "
    paras["imagePath"] = "screen"
    paras["name"] = "分享结果"
    paras["url"] = appDownLoadAddress
    local ShareLayer = require("hall.share.ShareLayer").new(paras)
    if ShareLayer then
        ShareLayer:onClickBtnToFriend()
        ShareLayer:removeSelf()
    end
end

function TotalResultLayer:onClickBtnAgain(sender, event)
    -- body
    dump("TotalResultLayer:onClickBtnAgain")
    require('hall.groudgamemanager'):extend_freegame(USER_INFO['uid'], USER_INFO['activity_id'])
end


function TotalResultLayer:playingVideo(sender, event)
    if event == TOUCH_EVENT_ENDED then
        print("playing video ----------------------------")
    end
end

function TotalResultLayer:onExit()
    -- body
end

return TotalResultLayer