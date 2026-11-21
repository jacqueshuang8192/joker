--[[
* author:   zwm
* date:     2020-05-29
--]]


local TotalCell = class("TotalCell", function ( ... )
    return display.newNode()
end)

function TotalCell:ctor(data, isBigWin)
    local path = "qs510k/res/TotalCell.csb"
    local node = nil
    if device.platform == "ios" then
        if isiOSVerify then
            node = cc.CSLoader:createNode(path):addTo(self)
        else
            node = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. path):addTo(self)
        end
    else
        node = cc.CSLoader:createNode(path):addTo(self)
    end
    self.node = node
    self:initItem(self.node, data, isBigWin)
end

function TotalCell:initItem(obj, info, isBigWin)
    dump(obj, "obj == ")
    local cell = obj:getChildByName("cell")
    cell:getChildByName("tScore"):setString(info.totalchips/100)
    cell:getChildByName("winFlag"):setVisible(isBigWin)
    if info.totalchips < 0 then
        local sp = display.newSprite("qs510k/images/total/lose_bg.png")
        if sp then
            cell:getChildByName("winOrLossBg"):loadTexture("qs510k/images/total/lose_bg.png")
        end
    end
    -- local userInfo = DDZ_USERINFO_TABLE[info.uid]
    self:setUserInfo(cell, info)
    local subCell = cell:getChildByName("subCell")
    subCell:setVisible(false)
    for i,v in ipairs(info.turnchip) do
        local subItem = subCell:clone()
        subItem:setVisible(true)
        self:initSubItem(subItem, v, i)
        cell:getChildByName("subRecordList"):pushBackCustomItem(subItem)
    end
end

function TotalCell:getUnformatPic(url)
    if url == nil then return end
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

function TotalCell:setUserInfo(obj, info)
    obj:getChildByName("name"):setString(require("hall.GameCommon"):formatNick(info.nickName, 4))

    local strHead = self:getUnformatPic(info.portrait)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        local headImg = obj:getChildByName("headImg")
        headImg:loadTexture(imgFullPath)
        headImg:setContentSize(cc.size(71, 71))
    end
    -- body
end

function TotalCell:initSubItem(obj, v, idx)
    obj:getChildByName("subIdx"):setString(string.format("第%d局", idx))
    obj:getChildByName("subScore"):setString(tonumber(v or "0"))--/100
    local btnRecord = obj:getChildByName("subScore")
    btnRecord._clickIdx = idx
    btnRecord:addTouchEventListener(handler(self, self.playingVideo))
end

function TotalCell:playingVideo(sender, event)
    if event == TOUCH_EVENT_ENDED then
        print("playing video ----------------------------")
    end
end

return TotalCell