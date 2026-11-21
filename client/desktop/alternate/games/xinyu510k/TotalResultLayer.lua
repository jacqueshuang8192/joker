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
local CardPlaneOperator = require("xinyu510k.operator.CardPlaneOperator")
local ControlPlaneOperator = require("xinyu510k.operator.ControlPlaneOperator")

local CELL_POS_X = 35
local CELL_POS_Y_BEGIN = 493
local CELL_POS_Y_INTERVAL = 124

function TotalResultLayer:ctor(data)
    TotalResultLayer.super.ctor(self, "xinyu510k/res/TotalResultLayer.csb")
    self._data = data
    self:__initUI()
    self:showResult(self._data)
end

function TotalResultLayer:__initUI()    
    -- self.cell1:setVisible(false)
    -- self.cell2:setVisible(false)
    -- self.cell3:setVisible(false)
    -- self.cell4:setVisible(false)
end

function TotalResultLayer:showResult(data)
    --print("TotalResultLayer:showResult ------------------", data == nil)
    if data == nil then return end
    --dump(data, "TotalResultLayer:showResult(data) == ")
    local bigWinUid = self:getBigWinUid()
    for i, v in ipairs(data or {}) do
        local item = require("xinyu510k.TotalCell").new(v, v.uid == bigWinUid)
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
        if v.totalchips > maxSocre then
            maxSocre = v.totalchips
            uid = v.uid
        end
    end
    
    return uid
end

function TotalResultLayer:initItem(obj, info, isBigWin)
    dump(obj, "obj == ")
    local cell = obj:getChildByName("cell")
    cell:getChildByName("tScore"):setString(info.totalchips/100)
    cell:getChildByName("winFlag"):setVisible(isBigWin)
    if info.totalchips < 0 then
        local sp = display.newSprite("xinyu510k/images/total/lose_bg.png")
        if sp then
            cell:getChildByName("winOrLossBg"):setTexture("xinyu510k/images/total/lose_bg.png")
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
    local btnRecord = obj:getChildByName("subScore")
    btnRecord._clickIdx = idx
    btnRecord:addTouchEventListener(handler(self, self.playingVideo))
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
    --require("hall.tips.CommonTips"):_gameToHall()
	require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
end

function TotalResultLayer:onClickBtnAgain(sender, event)
	--CardPlaneOperator:clearGameDatas()
    --ControlPlaneOperator:showControlButtons(1, false)
    --self:removeSelf()
	
	print('---x--x----',debug.traceback())
	dump(USER_INFO)
	print('xxx ',USER_INFO["activity_id"],TpackageName)

    --再来一局
    if USER_INFO["activity_id"] then
        require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"],TpackageName .. ".gameScene")
    end
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

function TotalResultLayer:playingVideo(sender, event)
    if event == TOUCH_EVENT_ENDED then
        print("playing video ----------------------------")
    end
end

function TotalResultLayer:onExit()
    -- body
end

return TotalResultLayer