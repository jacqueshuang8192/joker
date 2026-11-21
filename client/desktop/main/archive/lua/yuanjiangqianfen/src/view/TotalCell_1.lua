--[[
* author:   zwm
* date:     2020-06-23
--]]


local TotalCell = class("TotalCell", function ( ... )
    return display.newNode()
end)

function TotalCell:ctor(data, winUid)
    local path = "yuanjiangqianfen/res/TotalCell.csb"
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
    self:initItem(self.node, data, winUid)
end

function TotalCell:initItem(obj, info, winUid)
    dump(info, "info == ")
    local isBigWin = info.uid == winUid
    local cell = obj:getChildByName("cell")
    cell:getChildByName("tScore"):setString(info.finalScore/100)
    cell:getChildByName("winFlag"):setVisible(isBigWin)
    if info.finalScore < 0 then
        local sp = display.newSprite("yuanjiangqianfen/res/image/total/lose_bg.png")
        if sp then
            cell:getChildByName("winOrLossBg"):loadTexture("yuanjiangqianfen/res/image/total/lose_bg.png")
        end
    end
    -- local userInfo = DDZ_USERINFO_TABLE[info.uid]
    self:setUserInfo(cell, info)
    cell:getChildByName("bombScore"):setString(info.bombScore or "0")
    cell:getChildByName("pickScore"):setString(info.pickScore or "0")
    cell:getChildByName("effectiveScore"):setString(self:getEffectPickScore(info.pickScore))
    local data = json.decode(g_mainScene._roomConfigStr)
    if info.uid == winUid then
        cell:getChildByName("winRewardScore"):setString(data.winReward or "0")
    else
        cell:getChildByName("winRewardScore"):setString("0")
    end
    -- local finalScore = info.finalScore/(data.diFen*data.baseChip)
    -- cell:getChildByName("tScore"):setString(finalScore or "0")
end

function TotalCell:getEffectPickScore(score)
    local surScore = (score%100)
    return surScore >= 50 and (score + (100 - surScore)) or (score -surScore)
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

return TotalCell