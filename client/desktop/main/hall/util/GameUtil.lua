local GameUtil = class("GameUtil")

-- The native bridge uses a positional argument on Android and a keyed table on iOS.
function GameUtil:LoginRoom(roomId)
    if mediaSendMode ~= 1 then return end
    if device.platform == "android" then
        dump("Android进入房间", "-----GameUtil-----")
        cct.getDateForApp("LoginRoom", {roomId}, "V")
    elseif device.platform == "ios" then
        dump("ios进入房间", "-----GameUtil-----")
        cct.getDateForApp("LoginRoom", {roomId = roomId, uid = tostring(USER_INFO.uid)}, "V")
    else
        dump("进入房间", "-----GameUtil-----")
    end
end

function GameUtil:LogoutRoom()
    if mediaSendMode ~= 1 then return end
    if device.platform == "android" then
        dump("Android退出房间", "-----GameUtil-----")
    elseif device.platform == "ios" then
        dump("iOS退出房间", "-----GameUtil-----")
    else
        dump("退出房间", "-----GameUtil-----")
        return
    end
    cct.getDateForApp("LogoutRoom", {}, "V")
end

local function versionParts(version)
    local parts = string.split(version, ".")
    for i = 1, #parts do
        parts[i] = tonumber(parts[i])
    end
    return parts
end

--检查输入版本号是否大于指定版本号
function GameUtil:compareVersion(nowVersion, tagVersion)

    print("nowVersion:", nowVersion, "tagVersion:", tagVersion)
    strKey = nowVersion
    local tbLocal = strKey == "" and {0} or versionParts(nowVersion)
    dump(tbLocal,"tbLocal")
    local tbRemote = versionParts(tagVersion)
    dump(tbRemote,"tbRemote")

    for i = 1, #tbLocal do
    
        if tbLocal[i] > tbRemote[i] then
            return true
        end
        
        if i == #tbRemote then
            if tbLocal[i] == tbRemote[i] then
                return true
            end
        end

    end

    return false

end

return GameUtil