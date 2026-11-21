local clubData = class("clubData")

local function filter()
end

function clubData:ctor()

	self.tableData = {}  --联盟总桌子数据

	dump("FloorDataFloorDataFloorDataFloorData")
	---------------------------------------------------
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

	self.curFloor = 1  --当前楼层数据
	-----------------------------------------------------

	self.FloorInfo = {}   --联盟配置信息
	self.clubSettingData = {}  --联盟设置数据

	-----------------------------------------------------

	self.clubMemberData = {}  --联盟玩家数据
	self.clubNews = {}   --联盟消息
	 
	-----------------------------------------------------

	self.clubId = 0   --联盟属性：ID
	self.clubName = 0   --联盟属性：名称

	self.clubOwnerUid = 0  --联盟属性：联盟群主UID
	self.clubOwnerName = ""  --联盟属性：联盟群主昵称

	---------------------------------------------------------

	local clubAttriName = {
		"clubMemberData","clubNews", "clubId", "clubName", "clubOwnerUid"
	}

	-- --这里可能会导致指针问题
	-- for i, attriName in pairs(clubAttriName) do
	-- 	self["set" .. attriName] = function(_self, data) _self[attriName] = data end
	-- 	self["get" .. attriName] = function(_self) return _self[attriName] end
	-- end

end

function clubData:ClearData( ... )
	
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

function clubData:getclubOwnerName() 
	return self.clubOwnerName
end

function clubData:setclubOwnerName(name) 
	self.clubOwnerName = name
end


function clubData:getFloorData(floor) 
	if floor then
		return self.FloorData[floor] or {}
	else
		return self.FloorData[self.curFloor] or {}
	end
end


function clubData:setFloorInfo(data) 
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

function clubData:getFloorInfo() 
	return self.FloorInfo or {} 
end

function clubData:setclubId(data)
	self.clubId = data
end

function clubData:getclubId()
	return self.clubId
end

function clubData:setclubName(data)
	self.clubName = data
end

function clubData:getclubName()
	return self.clubName
end

function clubData:setclubOwnerUid(data)
	self.clubOwnerUid = data
end

function clubData:getclubOwnerUid()
	return self.clubOwnerUid
end

function clubData:ClearClubOwnerUid()
	self.clubOwnerUid = 0
end

function clubData:setclubMemberData(data)
	self.clubMemberData = data
end

function clubData:getclubMemberData()
	return self.clubMemberData
end

function clubData:setclubNews(data, typ)
	
	if typ == "clear" then
		self.clubNews = {}
	else
		-- self.clubNews[typ] = self.clubNews[typ] or {}
		-- table.insert(self.clubNews[typ], data)
		self.clubNews[typ] = data
	end

end

function clubData:getclubNews(typ)
	dump(self.clubNews, "getclubNews")
	return self.clubNews[typ] or {}
end

function clubData:setCurFloor(floor)
	self.curFloor = floor or 0
	-- cc.UserDefault:getInstance():setIntegerForKey("curFloor_clubId", self.curFloor * 1000000 + clubId)
end

function clubData:getCurFloor(floor)
	return self.curFloor
end

-- function clubData:setCurFloorInfo(key, value)
-- 	if type(key) == "string" then
-- 		self.CurFloorInfo[key] = value
-- 	elseif type(key) == "table" then
-- 		self.CurFloorInfo = key
-- 	end
-- end

-- function clubData:getCurFloorInfo(key)
-- 	if type(key) == "string" then
-- 		return self.CurFloorInfo[key]
-- 	else
-- 		return self.CurFloorInfo
-- 	end
-- end

function clubData:setclubSettingData(key, value)
	if type(key) == "string" then
		self.clubSettingData[key] = value
	elseif type(key) == "table" then
		self.clubSettingData = key
	end
end

function clubData:getclubSettingData(key)
	if type(key) == "string" then
		return self.clubSettingData[key]
	else
		return self.clubSettingData
	end
end

function clubData:settableData(data)

	self.tableData = data
	-- dump(data, "settableData")

	if data and next(data) and data[1]["level"] then

		dump(self.LevelToFloorMap, "inserttableData___LevelToFloorMap")

		local floorId = self.LevelToFloorMap[data[1]["level"]]
		if not floorId then return end 
		self.FloorData[floorId].tableData = {}

		dump(floorId, "inserttableData___floorId")

		if floorId then
			for i, v in ipairs(data) do
		 		table.insert(self.FloorData[floorId].tableData, v)
			end
		end

	end

	return self.tableData
end

function clubData:inserttableData(data)
	
	print("inserttableData")
	-- dump(self.tableData, "inserttableData___tableData")
	-- dump(self.LevelToFloorMap, "inserttableData___LevelToFloorMap")
	-- dump(data.level, "inserttableData___data.level")
	-- dump(data, "inserttableData___data")

	for i, v in ipairs(data) do
		table.insert(self.tableData, v)
		local floorId = self.LevelToFloorMap[v.level] 
		if floorId then 
			table.insert(self.FloorData[floorId].tableData, v)
		end

	end

	return self.tableData
end

function clubData:GetFloorTotalData()
	return self.FloorData
end 

function clubData:removeTableData(table_id)

	for floorId = 1, 5 do

		local array = self.FloorData[floorId].tableData

		for i, v in ipairs(array) do

			if v["table_id"] == table_id then
				table.remove(array, i)
				break
			end
		end

	end

	local array = self.tableData

	for i, v in ipairs(array) do

		if v["table_id"] == table_id then
			table.remove(array, i)
			break
		end

	end

end


function clubData:getTableData()

	-- dump(self.tableData, "self.tableData")
	-- dump(debug.traceback(), "self.tableData")

	if self.curFloor then
		-- dump(self.FloorData[self.curFloor].tableData, "self.FloorData")
		return self.FloorData[self.curFloor].tableData
	else
		return self.tableData
	end

end


function clubData:updateTable(data, typ)

	local array = self.tableData

	for i, v in pairs(array) do

		if v.table_id == data.table_id then

			dump(data, "updateTable")

			if typ == 1 or typ == 2 then   --游戏开始
				array[i].is_start = data.is_start
			elseif typ == 5 or typ == 6 then   --用户退出
				local data2 = json.decode(data.userinfo)

				if data2 == nil then
					dump(data, "出问题的用户数据")
					break
				end

				for m, n in pairs(v.user_list) do
					local data = json.decode(n)
					if data and data.uid == data2.uid then
						table.remove(array[i].user_list, m)
						break
					end
				end
			elseif typ == 4 or typ == 3 then  --用户加入桌子
				table.insert(array[i].user_list, data.userinfo)
			end

			return i, array[i]   
		end

	end

end


return clubData