local FamilyData = class("FamilyData")
local clubSendData = require("hall.view.clubView.clubSendData")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")
local CommonTips = require("hall.tips.CommonTips")
local GetGameName = require("hall.familyCircle.GetGameName")

function FamilyData:Init()
    --消息数据
    --战绩数据
    --联盟成员数据    加减积分 查看战绩 改变积分
    --联盟ID .联盟创建人 创建时间
    --设置数据
    --玩法配置数据
    --桌子数据
    self.family_list = {}
    self.message_data = {}
    self.member_data = {}
    self.limit_data = ""
    self.family_id = 0
    self.table_data = {}

    self.FloorInfo = {}   --联盟配置信息
    self.FloorData = {} --联盟以楼层为key的数据
    self.LevelToFloorMap = {} --楼层对应的level信息

    for floorId = 1, 5 do
        self.FloorData[floorId] = {}
        self.FloorData[floorId].gameName = ""
        self.FloorData[floorId].gameLevel = 0
        self.FloorData[floorId].gameType = 0
        self.FloorData[floorId].floorNick = ""
        self.FloorData[floorId].gameConfig = ""  --用来创建游戏的楼层配置

        self.FloorData[floorId].tableData = {}
         
    end

end 

function FamilyData:SetFamilyData(index , data)
    self.family_list[index] = data
end

function FamilyData:GetFamilyData(index)
   return self.family_list[index]
end

function FamilyData:GetMessage(callFunc, tag)

    local typ = 0
	if 2 == tag then
		typ = 0
	elseif 4 == tag then 
	 	typ = 5
	end

    local data = {
        playerId = USER_INFO["uid"],
        status = typ
    }
    local function callback(returnCode , data)
        if returnCode == 0 then
           -- dump (data , "----GetMessage-----")
           callFunc(data)
        end
    end
 	clubSendData:requestJoinNews(data, callback)
end

function FamilyData:GetMemberData(callFunc , clubId)

    local data = { groupId = clubId }
    local function callback(returnCode, data)
        if returnCode == 0 then
            callFunc(data)
        end
    end
    clubSendData:requestClubMembers(data, callback)
end

function FamilyData:GetPlayerData(callFunc , clubId, userId)
    local data= {groupId = clubId,playerId = userId}
    local function callback(returnCode, datav)
        dump(datav,"datytytav")
        if 0 == tonumber(returnCode) then
            callFunc(datav)
        end
    end
    clubSendData:requestClubRecord(data, callback)
end

function FamilyData:ChangeStrength(family_id , userId , flag , sum_score ,_myowener, CallFunc)
    local data = { playerId = USER_INFO["uid"]}
    local myowener = _myowener
    local function callback(returnCode, data)
        dump(data,"======增加减少体力打印==77777777777====")
        -- local returnCode = tonumber(json.decode(data.netData).returnCode)
        print(returnCode)
        if 0 == returnCode then
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("添加成功!"))
            if CallFunc then CallFunc() end
        else
            CommonTips:showTips(FamilyUntils:SetCommTipLabel(data))
        end
    end
    clubSendData:requestChangeClubScore(family_id , myowener , userId , flag , sum_score , callback)
end

function FamilyData:ChangeLimitScore(family_id , strength_limit)
    local data = { playerId = USER_INFO["uid"]}
    local myowener = 0
    local function callback(returnCode, data)
        if 0 == returnCode then
           for k,v in pairs(data) do
                v = json.decode(v)
                if tonumber(family_id) == tonumber(k) then
                    myowener = v.owerId
                end
            end
            local function Func(Code , data)
                if 0 == Code then 
                    CommonTips:showTips(FamilyUntils:SetCommTipLabel("修改成功!"))
                end 
            end
            clubSendData:requestUpdateMinCoins(family_id , myowener , tonumber(strength_limit), Func)
        end
    end
    clubSendData:requestClubList(data, callback)
end

function FamilyData:SetGameLimitData(data)
    self.limit_data = data
end

function FamilyData:GetGameLimitData()
    return self.limit_data
end 

function FamilyData:ChangePump(family_id, ownerId , chouType ,winType,chouValue,pumplimit,strengthLimit,tempNode)

    --changed by zzy 2019-7-10
    local data = { playerId = USER_INFO["uid"]}
    local myowener = ownerId
    local function callback(returnCode, data)
        if 0 == returnCode then
            tempNode:removeFromParent()
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("修改成功!"))
        end
    end

    clubSendData:requestUpdatePattern(family_id,myowener,chouType,winType,chouValue,pumplimit,strengthLimit,callback)

    --设置联盟抽水方式和比例
    --参数pattern: 1->表示固定抽水；2->表示比例抽水
    --参数costUserType: 0->抽大赢家；1->抽嬴家
    --参数precent: pattern为1时，表示固定抽水的量；pattern为2时，表示比例抽水（范围0~100）
    
    -- local data = { playerId = USER_INFO["uid"]}
    -- local myowener = 0
    -- local function callback(returnCode, data)
    --     if 0 == returnCode then
    --        for k,v in pairs(data) do
    --             v = json.decode(v)
    --             if tonumber(family_id) == tonumber(k) then
    --                 myowener = v.owerId
    --             end
    --         end
    --         local function Func(Code , data)
    --             if 0 == Code then 
    --                 CommonTips:showTips(FamilyUntils:SetCommTipLabel("修改成功!"))
    --             end 
    --         end

            
    --     --设置联盟抽水方式和比例
    --     --参数pattern: 1->表示固定抽水；2->表示比例抽水
    --     --参数costUserType: 0->抽大赢家；1->抽嬴家
    --     --参数precent: pattern为1时，表示固定抽水的量；pattern为2时，表示比例抽水（范围0~100）
            
    --         -- Data:requestUpdatePattern(clubId, owners, pattern, costUserType, precent, callback)
            
    --         clubSendData:requestUpdatePattern(family_id , myowener , 1 , 1 , 5 , Func)
    --     end
    -- end
end 

function FamilyData:SetFamilyId(family_id)
    self.family_id = family_id
end

function FamilyData:GetFamilyId()
    return self.family_id
end

function FamilyData:SetPlayerTakeData(parameter_data , family_id ,type,_index,gameType,length, CallFunc)
   

    -- dump(data)
    --clubSendData:requestUpdateGroupConfig(data, callback)
    dump(parameter_data,"parameter_data=====>>>>>")

    if parameter_data["level"] and GetGameName:isBidTable( parameter_data["level"] ) then --碗碗自动创建房
         local data = {
                clubId = family_id or 1,
                level =  parameter_data["level"],
         }
        local function callback(returnCode, data)
            if returnCode == 0 then
                dump(data,"创建新的房间")
                CommonTips:showTips(FamilyUntils:SetCommTipLabel("创建房间成功!"))

                CallFunc("createRoom",data)
            end
        end

        clubSendData:createGamTable(data, callback)
    else
         local data = {
                groupId = family_id or 1,
                playerId = USER_INFO["uid"] or 1,
                level =  parameter_data["level"],

                name = parameter_data["name"],
                config = json.encode(parameter_data) or "",
         }
        local function callback(returnCode, data)
            if returnCode == 0 then
                dump(data,"创建新的玩法")
                CommonTips:showTips(FamilyUntils:SetCommTipLabel("创建玩法成功!"))
                CallFunc("create",data)
            end
        end
        clubSendData:addGameConfig(data, callback)
    end
    

end 
function FamilyData:delGameConfig(family_id,configId,CallFunc)
    local data = {
        groupId = tonumber(family_id),
        playerId = tonumber(USER_INFO["uid"]),
        configId = tonumber(configId),

    }
    local function callback(returnCode, data)
        if returnCode == 0 then
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("删除成功!"))
            CallFunc("del")
        end
    end

    -- dump(data)
    --clubSendData:requestUpdateGroupConfig(data, callback)
    clubSendData:delGameConfig(data, callback)
end

function FamilyData:updateGameConfig(parameter_data , family_id ,configId, CallFunc)
    local data = {
        groupId = tonumber(family_id),
        playerId = tonumber(USER_INFO["uid"]),
        configId = tonumber(configId),
        config = json.encode(parameter_data) or "",

    }
    local function callback(returnCode, data)
        if returnCode == 0 then
            dump(data,"新 修改玩法")
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("修改成功!"))
            CallFunc("update")
        end
    end

    -- dump(data)
    --clubSendData:requestUpdateGroupConfig(data, callback)
    clubSendData:updateGameConfig(data, callback)

end

function FamilyData:setFloorInfo(data) 
    print (data , "-----查看设置进来的数据-----")
    print_lua_table (data)
    self.FloorInfo = data or {} 
    local LevelToType = require("hall.GameList"):getLevelToTypeTable() 

    for floorId = 1, 5 do
        local v = self.FloorInfo[floorId]
        -- dump(v, "单个楼层的游戏配置数据")
        if v then
            self.LevelToFloorMap[v.level] = floorId
            self.FloorData[floorId].gameName = v.gameName
            self.FloorData[floorId].gameLevel = v.level
            self.FloorData[floorId].gameType = LevelToType[v.level]
            -- self.FloorData[floorId].floorNick = ""
            self.FloorData[floorId].gameConfig = v  --用来创建游戏的楼层配置
        end
    end
end

function FamilyData:getFloorInfo() 
    return self.FloorInfo or {} 
end

function FamilyData:AddPartner(my_uid , uid , family_id , callback)
    print ("------------" , my_uid  , uid , family_id , "------family_data--")
    clubSendData:AddClubPartners(my_uid  , uid ,  family_id , callback)
end

function FamilyData:RequestPartnerInfo(clubId, page , page_num ,userId,  callback, param)
    local data = {groupId = clubId, playerId = userId, currentPage = page, pageSize = page_num}
    --add by zzy 2019-6-25
    clubSendData:RequestPartnerInfo(data, callback, param)

    -- clubSendData:RequestPartnerInfo(clubId , page , page_num , callback)
end
function FamilyData:selectCluHistory(groupId,pageSize,currentPage,callback)
    local data = {groupId = groupId, ownerId = USER_INFO.uid,pageSize =pageSize,currentPage =currentPage}
    --add by zzy 2019-6-25
    clubSendData:selectCluHistory(data, callback)
end
function FamilyData:RequestDeleteWF(tempFamilyID , UserID , tempIndex ,  callFunc)
    local data = {groupId = tempFamilyID,playerId = UserID,SelectGameConfigIndex = tempIndex}
    local function callback(returnCode, data)
        print("删除玩法返回！！！")
        -- dump(data)
        if 0 == returnCode then           
            callFunc(data)
        else
            print("玩法删除失败！")
        end
    end
    clubSendData:RequestDeleteWF(data, callback)
end

function FamilyData:GetClubUserInfo(uid , callFunc , nick_name)
    local data= {userId = uid}
    local function callback(returnCode, data)
        if 0 == returnCode then           
            callFunc(data , nick_name)
        end
    end
    clubSendData:GetClubUserInfo(data, callback)
end

function FamilyData:GetClubNoticeInfo(group_id , uid , notice_word , callFunc)
    local data = {groupId = group_id , ownerId = uid , notice = notice_word}
    local function callback(returnCode, data)
        if 0 == returnCode then           
            callFunc(data)
        end
    end
    clubSendData:GetClubNoticeInfo(data, callback)
end


function FamilyData:ShowClubNoticeWord(group_id , uid , callFunc)
    local data = {groupId = group_id , playerId = uid}
    local function callback(returnCode, data)
        if 0 == returnCode then           
            callFunc(data)
        end
    end
    clubSendData:ShowClubNoticeWord(data, callback)
end

function FamilyData:RequestSelectMemberListBydayingjia(group_id, uid, page, page_num, callFunc, param)
    local data = {groupId = group_id , playerId = uid, pageSize = page, pageSize = page_num}
    local function callback(returnCode, datav, error, param)
        if 0 == returnCode then           
            callFunc(datav, param)
        else
            viewMgr:showTip({text = "错误代码："..error})
        end
    end
    clubSendData:RequestSelectMemberListBydayingjia(data, callback, param)
end

function FamilyData:AddHhr(add_id , back_add , family_id , bonus_data ,  callFunc)
    local data = {
        playerId1 = add_id , 
        playerId2 = back_add , 
        groupId = family_id ,
        bonus = bonus_data , 
    }
    
    local function callback(returnCode, data)
        print("=====添加合伙人CallBack=====")
        print("=====添加合伙人CallBack=====")
        print("=====添加合伙人CallBack=====")
        print("=====添加合伙人CallBack=====",returnCode)
        if 0 == returnCode then           
            callFunc(data)
        else
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("添加合伙人失败！！！"))
        end
    end
    clubSendData:AddHhr(data, callback)
    -- clubSendData:ShowClubNoticeWord(data, callback)
end

function FamilyData:RequestCludScore(groupId, callFunc)
    local data = {
        uid = USER_INFO["uid"] ,
        groupId = groupId ,
    }
    dump(data,"RequestCludScore")
    local function callback(returnCode, data)
        if 0 == tonumber(returnCode) then
            callFunc(data)
        end
    end
    clubSendData:RequestCludScore(data, callback)
end
return FamilyData
