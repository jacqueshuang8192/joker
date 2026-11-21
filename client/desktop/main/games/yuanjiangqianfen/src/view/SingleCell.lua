--[[
* author:   zwm
* date:     2020-06-23
* describe: 玩家小结算节点绑定
--]]

local SingleCell = class("SingleCell", function ( ... )
    return display.newNode()
end)

function SingleCell:ctor(data, isBigWin)
    -- local path = "xinyu510k/res/SingleCell.csb"
    -- local node = nil
    -- if device.platform == "ios" then
    --     if isiOSVerify then
    --         node = cc.CSLoader:createNode(path):addTo(self)
    --     else
    --         node = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. path):addTo(self)
    --     end
    -- else
    --     node = cc.CSLoader:createNode(path):addTo(self)
    -- end
    -- self.node = node
    -- self:initItem(self.node, data, isBigWin)
end

function SingleCell:_init(data)
    self:initItem(data)
end

function SingleCell:initItem(info)
    self.rank:setString(string.format("第%d名", info.rank))
    self.rankScore:setString(self:getRankScore(info.rank) or "0")
    self.jScore:setString(info.singlePickScore or "0")
    self.rScore:setString(info.singleBombScore or "0")
    self.sScore:setString(info.totalPickScore or "0")
    self.tScore:setString(info.totalBombScore or "0")
    local userInfo = g_mainScene.userInfoByViewId[info.uid]--g_mainScene.userInfoByViewId:getUserInfoByUserId(info.uid)--DDZ_USERINFO_TABLE[info.uid]
    print("init SingleCell -------------------", info.uid)
    dump(userInfo, "userInfo == ")
    self:setUserInfo(userInfo)
end

function SingleCell:getRankScore(rank)
    local result = 0
    local data = json.decode(g_mainScene._roomConfigStr)
    if data.rankType == 1 then
        if data.maxSeatCount == 2 then
            if rank == 1 then
                result = 60
            else
                result = -60
            end
        else
            if rank == 1 then
                result = 100
            elseif rank == 2 then
                result = -40
            else
                result = -60
            end
        end
    else
        if data.maxSeatCount == 2 then
            if rank == 1 then
                result = 70
            else
                result = -70
            end
        else
            if rank == 1 then
                result = 100
            elseif rank == 2 then
                result = -30
            else
                result = -70
            end
        end
    end

    return result
end

function SingleCell:getUnformatPic(url)
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

function SingleCell:setUserInfo(info)
    self.name:setString(require("hall.GameCommon"):formatNick(info.nickName, 4))

    local strHead = self:getUnformatPic(info.icon_url)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        local headImg = self.headImg
        -- headImg:setPositionX(89)
        headImg:loadTexture(imgFullPath)
        headImg:setContentSize(cc.size(71, 71))
    end
end

return SingleCell