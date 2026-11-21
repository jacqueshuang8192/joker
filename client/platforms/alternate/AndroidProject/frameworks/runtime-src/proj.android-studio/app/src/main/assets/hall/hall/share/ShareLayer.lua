--[[
* author:   zwm
* date:     2019-03-29
* describe: 分享按钮界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

-- local ViewBaseLayer = require("hall.ViewBaseLayer")
local ShareLayer = class("ShareLayer", NewViewBaseLayer)

function ShareLayer:ctor(data)
    local csbPath = "hall/res/share/shareLayer.csb"
    ShareLayer.super.ctor(self, csbPath)
    self:enableMask(true)
    --add by zzy 2019-7-30
    USER_INFO.activity_id = USER_INFO.activity_id or  0
    USER_INFO.GroupLevel =  USER_INFO.GroupLevel or 0
    USER_INFO.invote_code = USER_INFO.invote_code or 0

    self.shareData = data
end

function ShareLayer:onClickBtnToFriend(sender, event)

    if self.shareData.imagePath == "screen" and device.platform=="ios" then
        self:shareGroupResultForIOS("wx")
    else
        local args = self:getToShareData("wx")
        cct.getDateForApp("share", args, "V")
    end
    if tolua.isnull(self) == false then
        self:removeSelf()
    end
end

function ShareLayer:onClickBtnToQuan(sender, event)
    if self.shareData.imagePath == "screen" and device.platform=="ios" then
        self:shareGroupResultForIOS("pyq")
    else
        local args = self:getToShareData("pyq")
        cct.getDateForApp("share", args, "V")
    end

    self:removeSelf()
end

function ShareLayer:onClickBtnClose(sender, event)
    self:removeSelf()
end

function ShareLayer:getToShareData(type)
    if device.platform=="android" then
        return self:getDateToAndroid(type, self.shareData)
    else
        return self:getDateToIOS(type, self.shareData)
    end
end

function ShareLayer:getDateToAndroid(type, data)
    local share_content = {}
    table.insert(share_content, type)
    table.insert(share_content,data.name)
    --if data.url ~= nil then
    --    if data.showType == 1 then
    --        table.insert(share_content, appDownLoadAddress)
    --    elseif data.showType == 2 then
    --        table.insert(share_content, moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"])
    --    end
    --
    --else
    --    table.insert(share_content,"")
    --end
    table.insert(share_content, moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"])
    if data.imagePath ~= nil then
        table.insert(share_content,data.imagePath)
    else
        table.insert(share_content,"")
    end
    table.insert(share_content,data.desc)

    print("getDateToAndroid")
    return share_content
end

function ShareLayer:getDateToIOS(type, data)
    local args = {}
    args["channel"] = type
    args["title"] = data.name
    if data.url ~= nil then
        if data.showType == 1 then
            args["url"] = appDownLoadAddress
        elseif data.showType == 2 then
            args["url"] = moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"]
        end

    end
    args["url"] = moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"]
    args["imagePath"] = device.writablePath .. iOSShareIcon_filePath--data.imagePath
    args["desc"] = data.desc

    print("getDateToIOS")
    return args
end
function ShareLayer:shareGroupResultForIOS(type)
    local args = {}
    args["channel"] = type
    args["title"] = "我的战果"
    if url ~= nil then
        --todo
        args["url"] = url
    end

    args["desc"] = "快来一起玩吧"

    print("luaCall 截屏",png_name)
    local function afterCaptured(succeed,sp_png)
        if succeed then
            print("截屏success",sp_png)
            args["imagePath"] = sp_png
            cct.getDateForApp("shareGroupResult", args, "V")
        end
    end
    cc.utils:captureScreen(afterCaptured,"gameScreen.png")
end
return ShareLayer