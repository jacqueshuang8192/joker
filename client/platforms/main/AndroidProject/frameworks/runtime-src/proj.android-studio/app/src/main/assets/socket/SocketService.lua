--[[
    网络模块的绝对父级
]]


local PacketBuilder = import("socket.PacketBuilder")
local PacketParser = import("socket.PacketParser")

local SocketService = class("SocketService")

SocketService.EVT_PACKET_RECEIVED     = "SocketService.EVT_PACKET_RECEIVED"
SocketService.EVT_CONN_SUCCESS         = "SocketService.EVT_CONN_SUCCESS"
SocketService.EVT_CONN_FAIL         = "SocketService.EVT_CONN_FAIL"
SocketService.EVT_ERROR             = "SocketService.EVT_ERROR"
SocketService.EVT_CLOSED             = "SocketService.EVT_CLOSED"
SocketService.EVT_CLOSE             = "SocketService.EVT_CLOSE"

local SOCKET_ID = 1

function SocketService:ctor(name, protocol,isChat_Msg)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self.name_ = name
    self.protocol_ = protocol
    self.parser_ = PacketParser.new(protocol.CONFIG.SERVER, self.name_,self.isChat_Msg)
    self.log = bm.Logger.new(name)
    self.isChat_Msg=isChat_Msg
end

function SocketService:setProtocol(protocol)
    self.protocol_ = protocol
    self.parser_ = PacketParser.new(protocol.CONFIG.SERVER, self.name_,self.isChat_Msg)
end
function SocketService:setParserClass(ParserClass)
    self.parser_ = ParserClass.new(self.protocol_, self.name_,self.isChat_Msg)
end

function SocketService:createPacketBuilder(cmd)
    return PacketBuilder.new(cmd, self.protocol_.CONFIG.CLIENT[cmd], self.name_,self.isChat_Msg)
end

function SocketService:getSocketTCP()
    return self.socket_
end

function SocketService:isConnected()
    if self.socket_ then
        --todo
        return self.socket_.isConnected
    end
    return false
end

function SocketService:connect(host, port, retryConnectWhenFailure)

    --self:disconnect()
    if not self.socket_ then
        SOCKET_ID = SOCKET_ID + 1
        self.socket_ = cc.net.SocketTCP.new(host, port, retryConnectWhenFailure or false)
        self.socket_.socketId_ = SOCKET_ID
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onData))
    end
 
    self.socket_:setName(self.name_):connect()
end

function SocketService:send(data)
    print("===== [TRACE] SocketService:send 入口 type=" .. type(data) .. " socket_=" .. tostring(self.socket_ ~= nil) .. " isConnected=" .. tostring(self.socket_ and self.socket_.isConnected) .. " =====")
    if self.socket_ then
        local rawData
        if type(data) == "string" then
            rawData = data
        else
            rawData = data:getPack()
        end
        print("===== [TRACE] SocketService:send 发送数据，长度=" .. tostring(#rawData) .. " hex前20字节: [" .. string.sub(cc.utils.ByteArray.toString(rawData, 16) or "ERR", 1, 60) .. "] =====")
        self.socket_:send(rawData)
        print("===== [TRACE] SocketService:send 发送完成 =====")
    else
        print("===== [TRACE] SocketService:send 失败: socket_ 为 nil =====")
    end
end

function SocketService:disconnect(noEvent)

    print("disconnect")
    if self.socket_ then
        local socket = self.socket_
        self.socket_ = nil

        if noEvent then
            socket:removeAllEventListeners()
            socket:disconnect()
        else
            socket:disconnect()
            socket:removeAllEventListeners()
        end
    end
end


function SocketService:reConnect()
    self.socket_:_disconnect()
    self.socket_:_reconnect()
end

function SocketService:onConnected(evt)
    --self.log:debugf("[%d] onConnected. %s", evt.target.socketId_, evt.name)
    print("NEO [%d] onConnected. %s", evt.target.socketId_, evt.name)
    self.parser_:reset()
    self:dispatchEvent({name=SocketService.EVT_CONN_SUCCESS})
end

function SocketService:onClose(evt)
    --self.log:debugf("[%d] onClose. %s", evt.target.socketId_, evt.name)
    print("[%d] onClose. %s", evt.target.socketId_, evt.name)
    self:dispatchEvent({name=SocketService.EVT_CLOSE})
end

function SocketService:onClosed(evt)
    --self.log:debugf("[%d] onClosed. %s", evt.target.socketId_, evt.name)
    print("[%d] onClosed. %s", evt.target.socketId_, evt.name)
    self:dispatchEvent({name=SocketService.EVT_CLOSED})
end

function SocketService:onConnectFailure(evt)
    --self.log:debugf("[%d] onConnectFailure. %s", evt.target.socketId_, evt.name)
    print("[%d] onConnectFailure. %s", evt.target.socketId_, evt.name)
    self:dispatchEvent({name=SocketService.EVT_CONN_FAIL})
end

function SocketService:onData(evt)
    print("===== SocketService:onData 收到原始数据 =====")
    -- 始终打印原始数据，不管 isShowNetLog 的值
    print("socket receive raw data:", cc.utils.ByteArray.toString(evt.data, 16))
   
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    buf:writeBuf(evt.data)
    buf:setPos(1)
    print("===== 开始解析数据包 =====")
    local success, packets = self.parser_:read(buf)
    if not success then
        print("===== 数据包解析失败！=====")
        self:dispatchEvent({name=SocketService.EVT_ERROR})
    else
        print("===== 解析成功，得到", #packets, "个数据包 =====")
        for i, v in ipairs(packets) do
            --self.log:debugf("[====PACK====][%x][%s]\n==>%s", v.cmd, table.keyof(self.protocol_, v.cmd), json.encode(v))
            -- 始终打印数据包，不管 cmd 的值
            print("NEO[====PACK====][%x][%s]\n==>%s", v.cmd, table.keyof(self.protocol_, v.cmd), json.encode(v))
            
            print("===== 准备分发数据包 =====")
            self:dispatchEvent({name=SocketService.EVT_PACKET_RECEIVED, data=v})
            print("===== 数据包分发完成 =====")
        end
    end
end

return SocketService