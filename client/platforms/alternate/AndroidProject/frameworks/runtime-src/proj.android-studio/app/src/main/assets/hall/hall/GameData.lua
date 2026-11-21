
local GameData  = class("GameData")

--初始化游戏数据
function GameData:InitData()

    --获取当前系统平台
    targetPlatform = cc.Application:getInstance():getTargetPlatform()

    --判断应用是否第一次打开
    isFirstBegin = cc.UserDefault:getInstance():getBoolForKey("isFirstBegin", true)
    if isFirstBegin then
        cc.UserDefault:getInstance():setBoolForKey("isFirstBegin", false)
    end

    ------------
    self:getUidForFile()
    dump("selfUid = "..UID)
    --设置音量开关
    MUSIC_ON = cc.UserDefault:getInstance():getBoolForKey("music_on", true)
    SOUND_ON = cc.UserDefault:getInstance():getBoolForKey("sound_on", true)
    SHOCK_ON = cc.UserDefault:getInstance():getBoolForKey("shock_on", true)

    --设置音量大小和音效大小
    if isFirstBegin then
        cc.UserDefault:getInstance():setFloatForKey("MusicVolume", 1.0)
        cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", 1.0)
    end
    self:setVolume()

end
-----------------标签------连续多开---------
function GameData:getUidForFile()
    if USER_INFO and USER_INFO["uid"] then
        UID = USER_INFO["uid"]
        return
    end

    if device.platform == "windows" then
        local fs = require("hall.tool.utils.fs")
        if fs.exists("accout.lua") and fs.exists("count.lua") then
            local accoutArr = require("accout")
            local count = require("count")
            count = tonumber(count) or 0
            local uid = accoutArr[count]
            if uid then
                UID = uid
                count = count + 1
                local content = "return " .. count
                fs.write("count.lua", content)
            end
        end
        local uid = cc.UserDefault:getInstance():getIntegerForKey("uid")
        if uid ~= 0 then
            UID = uid
            cc.UserDefault:getInstance():setIntegerForKey("uid", 0)
        end
    end
    
    if not UID then
        UID = 0  -- 未登录状态，由登录接口返回真实UID
    end
end

--获取用户数据
function GameData:getUserInfo()

    USER_INFO.addres = ""
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

        local args = {}
        local sigs = "()I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        local ok,ret  = luaj.callStaticMethod(className,"getUserID",args,sigs)
        if not ok then
            print("luaj error:", ret)
            return
        else
            USER_INFO["uid"] = ret
            print("getUserInfo uid:"..ret)
            UID = USER_INFO["uid"]
        end

        sigs = "()Ljava/lang/String;"
        ok,ret  = luaj.callStaticMethod(className,"getNickName",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["nick"] = ret
        end

        ok,ret  = luaj.callStaticMethod(className,"getToken",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            token = ret
            print("getUserInfo getToken:"..ret)
        end

        --用户类型
        sigs = "()Ljava/lang/String;"
        ok,ret  = luaj.callStaticMethod(className,"getUserType",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["type"] = ret
        end

        --所在城市
        sigs = "()Ljava/lang/String;"
        ok,ret  = luaj.callStaticMethod(className,"getCity",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["LocalCity"] = ret
        end
        if isShowAddress == true then
            local sigs = "()Ljava/lang/String;"
            local  ok,ret  = luaj.callStaticMethod(className,"getAddrStr",args,sigs)
            if not ok then
                print("luaj error:", ret)
            else
                print()
                USER_INFO.addres = ret
            end
        end


    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then

        --iOS平台
        if bm.isQuickLogin == "1" then

            local uid_arr = {}
            table.insert(uid_arr, 17488)
            table.insert(uid_arr, 17489)
            table.insert(uid_arr, 17490)
            table.insert(uid_arr, 17491)
            table.insert(uid_arr, 17492)
            table.insert(uid_arr, 17493)
            table.insert(uid_arr, 17494)
            table.insert(uid_arr, 17495)
            table.insert(uid_arr, 17496)
            table.insert(uid_arr, 17497)

            table.insert(uid_arr, 17498)
            table.insert(uid_arr, 17499)
            table.insert(uid_arr, 17500)
            table.insert(uid_arr, 17501)
            table.insert(uid_arr, 17502)
            table.insert(uid_arr, 17503)
            table.insert(uid_arr, 17504)
            table.insert(uid_arr, 17505)
            table.insert(uid_arr, 17506)
            table.insert(uid_arr, 17507)

            math.randomseed(tostring(os.time()):reverse():sub(1, 6))
            local num = math.random(20)

            UID = uid_arr[num]

            USER_INFO["uid"] = UID
            USER_INFO["nick"] = tostring(UID)
            USER_INFO["type"] = "P"

        else

            local args = {}
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "CocosCaller"

            local ok,ret  = luaoc.callStaticMethod(className,"getUserID")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["uid"] = ret
                UID = USER_INFO["uid"]
            end

            ok,ret  = luaoc.callStaticMethod(className,"getNickName")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["nick"] = ret
            end

            ok,ret  = luaoc.callStaticMethod(className,"getToken")
            if not ok then
                cc.Director:getInstance():resume()
            else
                token = ret
            end

            --用户类型
            ok,ret  = luaoc.callStaticMethod(className,"getUserType")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["type"] = ret
            end

            --所在城市
            ok,ret  = luaoc.callStaticMethod(className,"getCity")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["LocalCity"] = ret
            end

        end

    else

        --其他平台
        if bm.isQuickLogin == "1" then

            local uid_arr = {}
            table.insert(uid_arr, 17488)
            table.insert(uid_arr, 17489)
            table.insert(uid_arr, 17490)
            table.insert(uid_arr, 17491)
            table.insert(uid_arr, 17492)
            table.insert(uid_arr, 17493)
            table.insert(uid_arr, 17494)
            table.insert(uid_arr, 17495)
            table.insert(uid_arr, 17496)
            table.insert(uid_arr, 17497)

            table.insert(uid_arr, 17498)
            table.insert(uid_arr, 17499)
            table.insert(uid_arr, 17500)
            table.insert(uid_arr, 17501)
            table.insert(uid_arr, 17502)
            table.insert(uid_arr, 17503)
            table.insert(uid_arr, 17504)
            table.insert(uid_arr, 17505)
            table.insert(uid_arr, 17506)
            table.insert(uid_arr, 17507)

            math.randomseed(tostring(os.time()):reverse():sub(1, 6))
            local num = math.random(20)

            UID = uid_arr[num]

            USER_INFO["uid"] = UID
            USER_INFO["nick"] = tostring(UID)
            USER_INFO["type"] = "P"

        else

            USER_INFO["uid"] = UID
            USER_INFO["nick"] = tostring(UID)
            USER_INFO["type"] = "P"

        end

    end

end

--获取用户地理位置信息
function GameData:getLocation()

    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        ok,ret  = luaj.callStaticMethod(className,"getLongitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["Longitude"] = ret
        end

        ok,ret  = luaj.callStaticMethod(className,"getLatitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["Latitude"] = ret
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then

        USER_INFO["Latitude"] = cct.getDataForApp("getLatitude", {}, "string")
        USER_INFO["Longitude"] = cct.getDataForApp("getLongitude", {}, "string")

    else

        USER_INFO["Longitude"] = "113"
        USER_INFO["Latitude"] = "23"

    end

end

--设置音量大小和音效大小
function GameData:setVolume()

    local audioEngine = cc.SimpleAudioEngine:getInstance()
    local MusicVolume = cc.UserDefault:getInstance():getFloatForKey("MusicVolume")
    local EffectsVolume = cc.UserDefault:getInstance():getFloatForKey("EffectsVolume")
    audioEngine:setMusicVolume(MusicVolume)
    audioEngine:setEffectsVolume(EffectsVolume)

end

--获取本地游戏版本号
function GameData:getGameVersion(game)

    local strKey = game .. "_current-version"
    local strVersion = cc.UserDefault:getInstance():getStringForKey(strKey,"")
    return strVersion

end

--比较本地版本
function GameData:compareLocalVersion(version,game)
    -- body

    dump(version,"compareLocalVersion_version")
    dump(game,"compareLocalVersion_game")

    if version == nil then
        return 0
    end

    local lVersion = self:getGameVersion(game)
    local tbLocal = {}
    local tbRemote = {}

    local tem,nPos = string.find(lVersion,"%.")
    for i = 1, string.len(lVersion) do
        local strPic = string.sub(lVersion,1,nPos-1)
        table.insert(tbLocal,strPic)
        lVersion = string.sub(lVersion,nPos+1,string.len(lVersion))
        tem,nPos = string.find(lVersion,"%.")
        if tem == nil then
            table.insert(tbLocal,lVersion)
            break
        end
    end

    lVersion = version
    local tem,nPos = string.find(lVersion,"%.")
    for i = 1, string.len(lVersion) do
        local strPic = string.sub(lVersion,1,nPos-1)
        table.insert(tbRemote,strPic)
        lVersion = string.sub(lVersion,nPos+1,string.len(lVersion))
        tem,nPos = string.find(lVersion,"%.")
        if tem == nil then
            table.insert(tbRemote,lVersion)
            break
        end
    end

    if #tbLocal == 0 then
        return 1
    end

    for i = 1,#tbRemote do
        local subLocal = tonumber(tbLocal[i])
        local subRemote = tonumber(tbRemote[i])
        print("subLocal:"..subLocal.."   subRemote:"..subRemote)
        if subRemote > subLocal then
            print("new version["..game.."]")
            return 1
        end
    end

    return 0
end

return GameData