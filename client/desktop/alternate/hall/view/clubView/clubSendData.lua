local clubSendData = class("clubSendData")

function clubSendData:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self._eventHandles = {}
end
------------------------------------------------------------
--[[
    @desc: 
    author:{author}
    time:2019-12-21 18:22:30
    --@eventNameAndFileName: 
    @return:
]]
function clubSendData:addHandle(eventNameAndFileName) --监听事件
    if self._eventHandles[eventNameAndFileName] then 
        return 
    end
    self._eventHandles[eventNameAndFileName] = self:addEventListener(eventNameAndFileName, handler(self, self.handleEvent))
end

function clubSendData:handleEvent(event) --接收事件
    local data = event.netData
    local callback = event.callback
    if data and callback then
        callback(event)
    end
end

function clubSendData:onExitHandle(eventNameAndFileName)   --删除事件
    local e = self._eventHandles[eventNameAndFileName]
    if not e then return end
    self:removeEventListener(e)
    self._eventHandles[eventNameAndFileName] = nil
end

function clubSendData:dispatchHandle(name, sData, callback, param) --发送事件
    self:dispatchEvent({ name = name, netData = sData, callback = callback , param = param })
end

function clubSendData:commonRequest(eventNameAndFileName, data, callback, httpType, param)
    self:addHandle(eventNameAndFileName)
    local interfaceName = string.split(eventNameAndFileName, "+")[2]
    local this = self
	cct.createHttRq({
        url = HttpAddr .. interfaceName,
        date = data,
        type_= httpType,
        callBack = function(data)
            this:dispatchHandle(eventNameAndFileName, data, callback, param)
        end 
    })
end
------------------------------------------------------------------------

local function commonRequest(interfaceName, data, callback, httpType, errorHandlen, param)

	-- dump(HttpAddr .. interfaceName, "commonRequest_____url")
	-- dump(data, "commonRequest_____data")
    -- dump(httpType, "commonRequest_____httpType")
    

	cct.createHttRq({
        url = HttpAddr .. interfaceName,
        date = data,
        type_= httpType,
        callBack = function(data)

	        local responseData = data.netData
	        if responseData then
	            responseData = json.decode(responseData)

	            if callback then
	            	print("commonRequest________excuteCallBack")
		            local returnCode = tonumber(responseData.returnCode)
		            local data = responseData.data
		            local error = responseData.error
                    callback(returnCode, data, error, param)
            	end

            else

            	if errorHandle and type(errorHandle) == "function" then
            		errorHandle()
            	end

            	-- dump(responseData,"netData不存在")
            end
    	end })
end

function clubSendData:requestDeleteMember(data, callback)

	local interfaceName = "/deletePlayer4GroupByOwerId"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:requestJoinNews(data, callback)

	local interfaceName = "/getMsgForplayerGroup"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:requestReplyInvite(data, callback)

	local interfaceName = "/updateApplyForStatusByInvite"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:requestReplyJoinClub(data, callback)
    print("=======777777777777777======")
    print("=======777777777777777======")
    print("=======777777777777777======")
    print("=======777777777777777======")
    print("=======777777777777777======")
    dump(data)
	local interfaceName = "/updateApplyForStatus"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:requestQuitClub(data, callback)

	local interfaceName = "/playerExitGroupByGroupId"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end
function clubSendData:addGameConfig(data,callback)  --新 创建玩法选择
    local interfaceName = "/addGameConfig"
    local httpType = "POST"

    dump(data,"创建新的玩法选择！！！")
    commonRequest(interfaceName, data, callback, httpType)
end

function clubSendData:createGamTable(data,callback)  --新 创建玩法选择
    local interfaceName = "/freeGame/A2IcreateFreeGame"
    local httpType = "POST"

    dump(data,"创建新的房间！！！")
    commonRequest(interfaceName, data, callback, httpType)
end

function clubSendData:requestUpdateGroupConfig(data, callback)

	local interfaceName = "/updateGroupConfig"
	local httpType = "POST"
    print("创建新的玩法选择！！！")
    print("创建新的玩法选择！！！")
    print("创建新的玩法选择！！！")
    print("创建新的玩法选择！！！")
    dump(data)
	commonRequest(interfaceName, data, callback, httpType)
end

function clubSendData:requestUpdateGroupNameByOwerId(data, callback)

	local interfaceName = "/updateGroupNameByOwerId"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:inviteForJoinPlayerGroup(data, callback)

	local interfaceName = "/inviteForJoinPlayerGroup"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end


function clubSendData:selectGameConfig(data, callback) --新查询联盟玩法

    local interfaceName = "/selectGameConfig"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)

end
function clubSendData:delGameConfig(data, callback) --新 删除玩法
    local interfaceName = "/delGameConfig"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)
end
function clubSendData:updateGameConfig(data, callback) --新 修改桌子名称

    local interfaceName = "/updateGameConfig"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:requestClubList(data, callback)

	local interfaceName = "/selectPlayerGroup"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:requestClubRecord(data, callback)

	local interfaceName = "/selectGroupPlayerBydayingjia"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end



function clubSendData:requestClubMembers(data, callback)

	local interfaceName = "/selectGroupPlayer"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:requestdissolveClub(data, callback)

	local interfaceName = "/deleteGroupByOwerId"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:requestCreateClub(data, callback)

	local interfaceName = "/createPlayerGroup"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end


function clubSendData:requestJoinClub(data, callback)

	local interfaceName = "/applyForJoinPlayerGroup"
	local httpType = "POST"

	commonRequest(interfaceName, data, callback, httpType)

end

function clubSendData:GetClubUserInfo(data, callback)

    local interfaceName = "/playerUser/getUserInfo4GameServer"
    local httpType = "POST"

    commonRequest(interfaceName, data, callback, httpType)
end


--增减联盟的积分
--moudle:1->表示加；0->表示减
function clubSendData:requestChangeClubScore(clubId, owners, pId, moudle, score, callback)
    print("clubId, owners, pId, moudle, score,",clubId, owners, pId, moudle, score)
    local interfaceName = "/cluCoinsHandle"
    local httpType = "POST"
    if clubId == nil or owners == nil or pId == nil or moudle == nil or score == nil then
        print("requestChangeClubScore para is error !")
        return
    end
    local signStr = crypto.md5(string.format("addCoins%d_%d&%dtype%d%d", clubId, owners, pId, moudle, score), false)

    local data = {groupId = clubId, ownerId = owners, playerId = pId, type = moudle, coins = score, sign = signStr}
    commonRequest(interfaceName, data, callback, httpType)

end

--修改最小入分场限制
function clubSendData:requestUpdateMinCoins(clubId, owners, score, callback)

    local interfaceName = "/updatCluConfigMinCoins"
    local httpType = "POST"
    if clubId == nil or owners == nil or score == nil or score < 0 then
        print("requestUpdateMinCoins para is error !")
        return
    end
    local data = {groupId = clubId, ownerId = owners, coins = score} 
    commonRequest(interfaceName, data, callback, httpType)
end

--设置联盟抽水方式和比例
--参数pattern: 1->表示固定抽水；2->表示比例抽水
--参数costUserType: 0->抽赢家；1->抽大嬴家
--参数precent: pattern为1时，表示固定抽水的量；pattern为2时，表示比例抽水（范围0~100）
function clubSendData:requestUpdatePattern(clubId, owners, pattern, costUserType, precent,_costLimit,_strengthLimit, callback)

    local interfaceName = "/updatCluConfigCostPattern"
    local httpType = "POST"
    if clubId == nil or owners == nil or pattern == nil or costUserType == nil or precent == nil then
        print("requestUpdatePattern para is error !")
        return
    end
    local data = {groupId = clubId, ownerId = owners, cost_pattern = pattern, cost_user_type = costUserType, commission = precent, costLimit = _costLimit, strengthLimit = _strengthLimit} 
    commonRequest(interfaceName, data, callback, httpType)
end

--添加联盟合伙人
function clubSendData:requestAddClubPartner(clubId, otherClubId, owners, callback)

    local interfaceName = "/addClu2myClu"
    local httpType = "POST"
    if clubId == nil or owners == nil or otherClubId == nil then
        print("requestUpdatePattern para is error !")
        return
    end
    local data = {groupId = clubId, otherGroupid = otherClubId, ownerId = owners} 
    commonRequest(interfaceName, data, callback, httpType)
end

--获取合伙人列表
function clubSendData:requestGetPartnerLst(clubId, owners, page, pageSize, callback)

    local interfaceName = "/selectHehuoren"
    local httpType = "POST"
    if clubId == nil or owners == nil then
        print("requestUpdatePattern para is error !")
        return
    end
    page = page == nil and 1 or page
    pageSize = pageSize == nil and 30 or pageSize
    local data = {groupId = clubId, ownerId = owners, pageSize = pageSize, currentPage = page} 
    commonRequest(interfaceName, data, callback, httpType)
end

--获取联盟公告
function clubSendData:GetClubNoticeInfo(data , callback)

    local interfaceName = "/updateNotice"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)
    
end

--获取联盟公告
function clubSendData:ShowClubNoticeWord(data , callback)

    local interfaceName = "/getNotice"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)
end

--添加合伙人

function clubSendData:AddHhr(data , callback)
    print("8989898989898989898")
    print("8989898989898989898")
    print("8989898989898989898")
    print("8989898989898989898")
    dump(data)
    local interfaceName = "/addHhr"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)
    
end

--获取合伙人列表
function clubSendData:RequestPartnerInfo( data, callback, param)
    dump(data, "发送合伙人列表请求-----------------------")
    local interfaceName = "/selectHhrListBydayingjia"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType, nil, param)

end

--获取我的玩家普通人列表
function clubSendData:RequestSelectMemberListBydayingjia( data, callback, param)
    dump(data, "发送我的玩家普通人列表请求-----------------------")
    local interfaceName = "/selectMemberListBydayingjia"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType, nil, param)

end
--获取上下分记录
function clubSendData:selectCluHistory( data, callback)
 dump(data,"获取上下分记录")
    local interfaceName = "/selectCluHistory"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)

end
--获取合伙人列表
function clubSendData:RequestDeleteWF( data, callback)
    print("删除玩法！！！")
    local interfaceName = "/deleteGroupConfig"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)

end
--获取联盟积分
function clubSendData:RequestCludScore(data, callback)

    local interfaceName = "/gotoClub"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)

end
--获取个人信息 用于判断创建联盟权限
function clubSendData:RequestGetRoleInfo(data, callback)
    local interfaceName = "/playerUser/getUserInfo4GameServer"
    local httpType = "POST"
    commonRequest(interfaceName, data, callback, httpType)
end

return clubSendData