
local GameUtil = class("GameUtil")

--通知进入房间
function GameUtil:LoginRoom(roomId)

	if mediaSendMode ~= 1 then
		return
	end

	if device.platform == "android" then

		dump("Android进入房间", "-----GameUtil-----")

		local arr = {}
		table.insert(arr, roomId)
		cct.getDateForApp("LoginRoom", arr, "V")

	elseif device.platform == "ios" then

		dump("ios进入房间", "-----GameUtil-----")

		local arr = {}
		arr["roomId"] = roomId
		arr["uid"] = tostring(USER_INFO["uid"])
		cct.getDateForApp("LoginRoom", arr, "V")

	else

		dump("进入房间", "-----GameUtil-----")
	
	end

end

--通知退出房间
function GameUtil:LogoutRoom()

	if mediaSendMode ~= 1 then
		return
	end

	if device.platform == "android" then

		dump("Android退出房间", "-----GameUtil-----")

		local arr = {}
		cct.getDateForApp("LogoutRoom", arr, "V")

	elseif device.platform == "ios" then

		dump("iOS退出房间", "-----GameUtil-----")

		local arr = {}
		cct.getDateForApp("LogoutRoom", arr, "V")

	else

		dump("退出房间", "-----GameUtil-----")
	
	end

end

--检查输入版本号是否大于指定版本号
function GameUtil:compareVersion(nowVersion, tagVersion)

    local tbRemote = {}
    local tbLocal = {}

    print("nowVersion:", nowVersion, "tagVersion:", tagVersion)

    strKey = nowVersion
    if strKey == "" then
        tbLocal[1] = 0
    else
        tbLocal = string.split(nowVersion, ".")
        for i = 1, #tbLocal do
            tbLocal[i] = tonumber(tbLocal[i])
        end
    end
    dump(tbLocal,"tbLocal")


    tbRemote = string.split(tagVersion, ".")
    for i = 1, #tbRemote do
        tbRemote[i] = tonumber(tbRemote[i])
    end
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