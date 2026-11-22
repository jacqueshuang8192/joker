-- cc.Sprite.create = function(ccsp, filename)
--     return display.newSprite(filename)
-- end

-- cc.CSLoader.createNode = function(ccloader, filename)
--     local fileExist = cc.FileUtils:getInstance():isFileExist(filename)
--     if not fileExist then
--         local interfaceName = "/ReportingError"
--         local msg = "csb文件——>:" .. filename .. " not find" .. "  error --->>>>>>" .. debug.traceback()
--         local debug_data = {error_message =  msg}
--         cct.createHttRq({
--             url = HttpInterFace .. interfaceName,
--             date = debug_data,
--             type_= "POST",
--             callBack = function(data)
--         end})
--     end

--     return cc.uiloader:load(filename)
-- end


GameEvent = require("hall.GameEvent").new()
--初始化应用信息
require("hall.data.AppMessage"):ctor()

--初始化config
require("hall.data.Config"):ctor()

--初始化http请求
require(Request_filePath):ctor()

--初始化Socket协议调用
--bm的设置
bm.PACKET_DATA_TYPE = import("socket.PACKET_DATA_TYPE")
bm.Logger = import("socket.Logger")
import("socket.functions").exportMethods(bm)
local HallServer = import(HallServer_filePath)
bm.localGameList = {}
local hall_ip = "38.12.31.236"
local hall_port = 4701
local phpLogined = 0
local robot_test = true --机器人测试

local hallScene =
    class(
    "hallScene",
    function()
        return display.newScene("hallScene")
    end
)

--初始化
function hallScene:ctor()
    if HeadImgUpLoadOK then
        GameEvent:delListen(HeadImgUpLoadOK)
    end
    --协议数据全局缓存
    buf_cache = ""
    is_club_scene = false
    --重写错误信息输出方法
    __G__TRACKBACK__MAIN = function(msg)
        --上传错误信息
        if device.platform ~= "windows" then
            if msg~=nil then
                msg = debug.traceback(msg, 1)
            end
            require(Request_filePath):upLoadAppMessage(1, "当前level：" .. nowlevel .. ",当前最后接收的协议数据：" .. buf_cache .. ",当前错误信息：" .. msg)
            display_scene("app.scenes.MainScene")
            return
        end
        msg = debug.traceback(msg, 1)
        --print("hallScene========================", msg)

        local nowlevel = 0
        if USER_INFO["GroupLevel"] ~= nil then
            nowlevel = USER_INFO["GroupLevel"]
        end

        --上传错误信息
        if device.platform ~= "windows" then
            require(Request_filePath):upLoadAppMessage(1, "当前level：" .. nowlevel .. ",当前最后接收的协议数据：" .. buf_cache .. ",当前错误信息：" .. msg)
            display_scene("app.scenes.MainScene")
            return
        end

        if _G.display_scene and not isShowErrorScene then
            display_scene("app.scenes.MainScene")
        else

            if device.platform ~= "windows" then
                --display_scene("app.scenes.MainScene")
            --    local interfaceName = "/ReportingError"
            --    local msg_content = msg
            --    local debug_data = {error_message = msg_content}
            --    cct.createHttRq(
            --        {
            --            url = HttpInterFace .. interfaceName,
            --            date = debug_data,
            --            type_ = "POST",
            --            callBack = function(data)
            --            end
            --        }
            --    )
            --else
            --    local path = "error.lua"
            --    local fs = require("hall.tool.utils.fs")
            --    if fs.exists(path) then
            --        local str = "当前level：" .. nowlevel .. "\n\n当前最后接收的协议数据：\n" .. buf_cache .. "\n\n当前错误信息：\n" .. msg
            --        local content = fs.read(path)
            --        local tiem = os.date("%Y-%m-%d %H:%M:%S", os.time())
            --        str = "\n--" .. tiem .. "\n" .. str .. content .. "\n\n\n\n"
            --        fs.write(path, str)
            --    end
            end
            cct.runErrorScene("当前level：" .. nowlevel .. "\n\n当前最后接收的协议数据：\n" .. buf_cache .. "\n\n当前错误信息：\n" .. msg)
        end

        return msg
    end

    __G__TRACKBACK__ = __G__TRACKBACK__MAIN

    --初始化游戏数据
    require(GameData_filePath):InitData()

    --初始化游戏设置以及注册lua与原生交互方法
    require(GameSetting_filePath):InitData()

    --bm的设置
    bm.PACKET_DATA_TYPE = import("socket.PACKET_DATA_TYPE")
    bm.Logger = import("socket.Logger")
    --初始化当前Socket链接
    bm.SocketFirstConnectSuccess = false
    bm.netdisConnect = false
    bm.SchedulerPool = import("socket.SchedulerPool").new()
    bm.SocketService = require("socket.SocketService")
    bm.server = HallServer.new()

    --加载封装定时器(单例)
    require("hall.util.LMyTimer")

    --记录当前不在游戏中
    bm.isInGame = false
    STATUS_GAME = false
end

--进入
function hallScene:onEnter()
    if not USER_INFO or not tonumber(USER_INFO.uid) or tonumber(USER_INFO.uid) <= 0
        or type(USER_INFO.token) ~= "string" or USER_INFO.token == "" then
        require(LoginScene_filePath):show()
        return
    end
    require("hall.GameCommon"):landLoading(true)
    require("hall.GameCommon"):setLoadingProgress(10)
    self:initFinished()
end

function hallScene:initFinished()
    --快速登录标志
    -- bm.isQuickLogin = "1"

    --获取用户数据
    require("hall.GameCommon"):showLoadingTips("获取用户信息")
    if USER_INFO.token and USER_INFO.token ~= "" then
        UID, token = tonumber(USER_INFO.uid), USER_INFO.token
    else
        -- Native WeChat sign-in delivers its identity through the platform bridge.
        require(GameData_filePath):getUserInfo()
        if not tonumber(UID) or tonumber(UID) <= 0 or type(token) ~= "string" or token == "" then
            require(LoginScene_filePath):show()
            return
        end
        USER_INFO.uid, USER_INFO.token = tonumber(UID), token
    end

    --开启心跳检测,这里他们要求loginLayer隐藏的时候开始检测心跳。
    --loginLayer显示的时候不检测心跳包
    bm.checknetworking = true

    --检查当前是否存在登录界面，有则移除
    if SCENENOW["scene"] then
        local loginScene = SCENENOW["scene"]:getChildByName("loginLayer")
        if loginScene ~= nil then
            --todo
            loginScene:removeFromParent()
        end
    end

    if firstLoginBonus == true then
        cct.createHttRq(
            {
                url = HttpAddr .. "/baseData/queryConfig",
                date = {
                    type = "firstBlood"
                },
                type_ = "POST",
                callBack = function(data)
                    local responseData = data.netData
                    if responseData then
                        responseData = json.decode(responseData)
                        dump(responseData, "-----获取渠道配置返回-----")

                        local returnCode = responseData.returnCode
                        local data = responseData.data
                        dump(returnCode, "-----获取渠道配置返回returnCode-----")
                        dump(data, "-----获取渠道配置返回data-----")

                        if returnCode == "0" and data == "1" then
                            dump("-----有首登奖励-----")
                        else
                            firstLoginBonus = false
                        end
                    end
                end
            }
        )

        cct.createHttRq(
            {
                url = HttpAddr .. "/baseData/queryConfig",
                date = {
                    type = "giftOfPlayerFirstLogin2Gold"
                },
                type_ = "POST",
                callBack = function(data)
                    local responseData = data.netData
                    if responseData then
                        responseData = json.decode(responseData)

                        local returnCode = responseData.returnCode
                        local data = responseData.data
                        dump(data, "-----获取渠道配置返回firstLoginBonusGold-----")

                        if returnCode == "0" then
                            firstLoginBonusGold = tonumber(data)
                        end
                    end
                end
            }
        )

        cct.createHttRq(
            {
                url = HttpAddr .. "/baseData/queryConfig",
                date = {
                    type = "giftOfPlayerFirstLogin"
                },
                type_ = "POST",
                callBack = function(data)
                    local responseData = data.netData
                    if responseData then
                        responseData = json.decode(responseData)

                        local returnCode = responseData.returnCode
                        local data = responseData.data
                        dump(data, "-----获取渠道配置返回firstLoginBonusRoomCard-----")

                        if returnCode == "0" then
                            firstLoginBonusRoomCard = tonumber(data)
                        end
                    end
                end
            }
        )
    end

    -- self:getIpByUrl()
    require(Request_filePath):userLogin(USER_INFO["uid"])
end

function hallScene:getIpByUrl()
    local strIp = ""
    local ipUrl = "http://pv.sohu.com/cityjson?ie=utf-8"
    cct.createHttRq(
        {
            url = ipUrl,
            type_ = "GET",
            interfaceName = "getUserIp",
            callBack = function(data)
                local responseData = data.netData
                if responseData then
                    local str = string.split(responseData, "=")[2]
                    if str then
                        str = string.sub(str, 1, -2)
                        if str then
                            local jsonStr = json.decode(str)
                            print("hallScene:getIpByUrl [ip]:" .. jsonStr.cip)
                            USER_INFO["ip"] = jsonStr.cip
                        end
                    end
                end
            end
        }
    )
end

--Socket登录游戏大厅
function hallScene:enterNormal()
    require("hall.GameCommon"):showLoadingTips("连接游戏服务器")
    require("hall.GameCommon"):setLoadingProgress(20)

    --进行大厅服务器Socket连接
    require(HallServer_filePath):connectSocket()
end

--游戏更新完成
function hallScene:gameUpdateFinished()
    dump("", "-----游戏更新完成-----")

    if require("hall.GameList"):isLastUpdate() then
        self:enterNormal()
    else
        local data = require("hall.GameList"):getCurrentUpdateGame()
        dump(data, "gameUpdateFinished")
        if data then
            self:checkGameVersion(data)
        else
        end
    end
end

--登录大厅成功
function hallScene:onNetLoginOK(pack)
end

function hallScene:onExit()
end

return hallScene
