local ReqMgr = class("RequestMgr")

function ReqMgr:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self._eventHandles = {}
end

------------------------------------------------------------

function ReqMgr:addHandle(key, eventNames) --监听事件
    if not eventNames or not key then return end
    for k,eventName in pairs(eventNames) do
        local name = key..eventName
        local eventHandle = self._eventHandles[name]
        if not eventHandle then
            self._eventHandles[key..eventName] = self:addEventListener(eventName, handler(self, self.handleEvent))
        else
            self._eventHandles[key..eventName] = self:addEventListener(eventName, handler(self, self.handleEvent))

        end
    end
    dump(self._eventHandles, "当前事件-------------")
end

function ReqMgr:delHandle(key, eventNames)   --删除事件
    if not eventNames or not key then return end
    for k,eventName in pairs(eventNames) do
        local name = key..eventName
        local eventHandle = self._eventHandles[name]
        if eventHandle then
            self:removeEventListener(eventHandle)
            self._eventHandles[name] = nil
        end
    end
    dump(eventNames, "删除事件当前文件夹:"..key.."---------")
end

function ReqMgr:addOneHandle(key, eventName) --监听事件
end

function ReqMgr:delOneHandle(key, eventName)   --删除事件
end

function ReqMgr:handleEvent(event) --接收事件
    local callback = event.callback

    if callback then
        callback(event)
    end
end

function ReqMgr:dispatchHandle(name, sData, callback, param) --发送事件

    local netData = json.decode(sData.netData)
    local net = sData.net
    netData.returnCode = tonumber(netData.returnCode)
    param = param or {}
    self:dispatchEvent({ name = name, netData = netData, callback = callback , param = param , net = net })

end

function ReqMgr:request(interfaceName, data, callback, param, httpType, isLoading, http)
    if isLoading == nil then
        isLoading = true
    end
    if http == nil then
        http = HttpAddr
    end
    local this = self
    if not httpType then httpType = "POST" end
    if isLoading == true then
        require(NetworkLoadingView_filePath):showLoading("...")
    end
    local interfaceName1 = string.split(interfaceName, "__")
    interfaceName1 = interfaceName1[1]
	cct.createHttRq({
        url = http .. interfaceName1,
        date = data,
        type_= httpType,
        callBack = function(data)
            if isLoading == true then
                require(NetworkLoadingView_filePath):removeView(11)
            end
            this:dispatchHandle(interfaceName, data, callback, param)
        end 
    })
end

function ReqMgr:getAddress( latitude, longitude, uid )
    if latitude and latitude and uid and not g_hall_addresss[uid] then
        local tab = {}
        tab.ak = BAIDU_AK
        tab.output = "json"
        tab.coordtype = "wgs84ll"
        tab.location = latitude..","..longitude
        local http = "http://api.map.baidu.com/reverse_geocoding/v3/"
        cct.createHttRq({
            url = http,
            date = tab,
            callBack = function(data)
                local decodeData = json.decode(data.netData)
                if decodeData and decodeData.status == 0 then
                    local result = decodeData.result
                    local address = result.addressComponent.country .. result.formatted_address
                    g_hall_addresss[uid] = address
                    print(latitude,longitude)
                end
            end 
        })
    end
end

return ReqMgr