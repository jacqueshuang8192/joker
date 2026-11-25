local table_list = class("table_list")
-- local room_list_tableView = require("hall.scene.group.join.room_list_tableView")
local gameTypeList = nil

table_list._curLevel = 10  --cc.UserDefault:getInstance():getIntegerForKey("gameTypeIndex",10) 
table_list._curBaseChip = 1
table_list._gameType = 1

local gameScoreIndex  = 1

local fenchangNameTable = {[1] = "新手场",[2] = "平民场",[3] = "小资场",[4] = "富豪场"}
local fenchangImgTable = {[1] = "hall/scene/res/" .. resFolder .."/image/group/join/table_list5.png",
[2] = "hall/scene/res/" .. resFolder .."/image/group/join/table_list7.png",
[3] = "hall/scene/res/" .. resFolder .."/image/group/join/table_list6.png",
[4] = "hall/scene/res/" .. resFolder .."/image/group/join/table_list20.png"}

local fenchangPlayerNumTable = {}
local fenchangMisCoinsGoldTable = {}
-- local maxShowRoomNum = 10   --一次能显示的房间数量 
local showAllrooms = false
-- local showRoomsFunc
local maxShowRoomNum = 20

local customScrollViewCreator = require("hall.scene.group.customScrollView.customScrollView")
local customScrollView

local function filterTablesData(tablesData, baseChip)

	-- dump(tablesData,"filterTablesData_tablesData")
	-- dump(baseChip,"filterTablesData_baseChip")

	if tablesData then

		local tables = {}
		for i,data in ipairs(tablesData) do
			if data.baseChip ==  baseChip then
				table.insert(tables, data)
			end
		end

		return tables
	end

end

local function removeTableData(tid)

	for i,v in ipairs(table_list.allTablesData) do
		if  v["tid"] == tid then                  
            table.remove(table_list.allTablesData, i)
            break                         
        end  
	end

	for i,v in ipairs(table_list.tablesData) do
		if  v["tid"] == tid then                    
            table.remove(table_list.tablesData, i)
            break                         
        end 
	end

end  


local function insertTableData(tableData, baseChip)

	table.insert(table_list.allTablesData, tableData)

	if table_list._curBaseChip == baseChip and table_list.tablesData then
		table.insert(table_list.tablesData, tableData)
	end

	return tables
end


local function initTablesContainer(item, container, itemHandler)     

    local scrollViewType = "tableView"
    if scrollViewType == "listView" then
	    item:setSwallowTouches(false)
	    item:setTouchEnabled(false)
	    container:setVisible(true)
	    container:setTouchEnabled(true)
	else
		item:setAnchorPoint(cc.p(0,1))   --tableView item的锚点最好为0，1
	    item:setSwallowTouches(false)
	    item:setTouchEnabled(false)
		container:setVisible(false)
	    container:setTouchEnabled(false)
	end

	customScrollView = customScrollViewCreator.new(scrollViewType)
    customScrollView:setMetaItem(item, 2)
    customScrollView:setScrollView(container) 
	customScrollView:setItemHandler(handler(table_list, itemHandler))

	customScrollView:init({})
end

function table_list:updateTableData(pack, typ)

	if  self._curLevel ~= pack.m_nLevel and typ ~= "allroom" then
		return
	end

	--所有房间数据
	if typ == "allroom" then

		self.allTablesData = pack.tableList
		-- dump(self.tablesData,"self.tablesData")

		dump(self.allTablesData, "updateTableData")
		--添加密码
		local passwordList = pack.tablePasswordList
	    if passwordList and next(passwordList) then
	        for i,password in ipairs(passwordList) do
	            if self.allTablesData[i] then
	                self.allTablesData[i]["password"] = type(password) == "table" and password.password or password
	            end
	        end
	    end

	    self:chooseBasechip()
	    -- self:show(typ)

	elseif typ == "insert" then

        dump("159添加桌子")
        local tmpTab = {}
        tmpTab["tid"] = pack["tid"]
        tmpTab["activity_id"] = pack["activity_id"]
        tmpTab["description"] = pack["description"]
        tmpTab["invity_code"] = pack["invity_code"]
        tmpTab["play_nums"] = pack["play_nums"]
        tmpTab["in_coin"] = pack["in_coin"]
        tmpTab["baseChip"] = pack["baseChip"]
        tmpTab["max_nums"] = pack["max_nums"]
        tmpTab["ower_uid"] = pack["ower_uid"]
        tmpTab["creator_nikename"] = pack["creator_nikename"]
        tmpTab["creator_portrait"] = pack["creator_portrait"]
        tmpTab["bonus_pool"] = pack["bonus_pool"]
        tmpTab["password"] = pack["password"]
        tmpTab["userMap"] = {}
        tmpTab["userMapSize"] = 0

        insertTableData(tmpTab, self._curBaseChip)
        self:show(typ)

   	elseif typ == "disband" then	
	
		removeTableData(pack["tid"])
        self:show(typ)

	end

	local tid = pack["tid"]

	local function conditionFunc(cell)
		-- dump(cell.tid,"cell.tid")
		if cell.tid == tid then
			return true
		end
	end

	if self.allTablesData == nil then
		return
	end

	--房间内行为
	if typ == "join" then

		local function updateTableData(tablesData)
	        for k,v in pairs(tablesData) do
	            if v["tid"] == pack["tid"] then
	                v["play_nums"] = pack["play_nums"]
	                tableData =  v  
	                break 
	            end    
	        end
	    end

        updateTableData(self.allTablesData)

		if  self._curBaseChip == pack.baseChip and customScrollView then
        	-- updateTableData(self.tablesData)
			customScrollView:updateItemContent(tableData, conditionFunc)
		end

    elseif typ == "sit" then

    	local function updateTableData(tablesData)
	        for k,v in pairs(tablesData) do
	            if v["tid"] == pack["tid"] then
	                v["play_nums"] = pack["play_nums"]
	                table.insert(v["userMap"], pack["seatId"])
	                tableData =  v  
	                break 
	            end    
	        end 
	    end  

        updateTableData(self.allTablesData)

		if  self._curBaseChip == pack.baseChip and customScrollView then
        	-- updateTableData(self.tablesData)
			customScrollView:updateItemContent(tableData, conditionFunc)
		end

   	elseif typ == "stand" then

   		local function updateTableData(tablesData)

	        for k,v in pairs(tablesData) do
	            if  v["tid"] == pack["tid"] then
	                for i,j in pairs(v["userMap"]) do
	                    if  j == pack["seatId"] then
	                        table.remove(v["userMap"],i)
	                        break
	                    end    
	                end 
	                v["play_nums"] =   pack["play_nums"] 

	                tableData =  v
	                break   
	            end    
	        end
        end    

        updateTableData(self.allTablesData)

		if  self._curBaseChip == pack.baseChip and customScrollView then
        	-- updateTableData(self.tablesData)
			customScrollView:updateItemContent(tableData, conditionFunc)
		end

   	elseif typ == "leave" then

   		local function updateTableData(tablesData)
	        for k,v in pairs(tablesData) do
	            if  v["tid"] == pack["tid"] then
	                v["play_nums"] =   pack["play_nums"]   

	                tableData =  v
	                break   
	            end 
	            
	        end 
	    end   

        updateTableData(self.allTablesData)

		if  self._curBaseChip == pack.baseChip and customScrollView then
        	-- updateTableData(self.tablesData)
			customScrollView:updateItemContent(tableData, conditionFunc)
		end

	end


end

function table_list:show(typ, level, gameName, gameType)
	
	-- dump(debug.traceback(), "table_list__show")
	self.fenchangTable = {}
   	self._curLevel = level or self._curLevel
   	self._curGameName = gameName or self._curGameName
   	dump(gameType, "table_list:showgameType")
   	self._gameType =  gameType or self._gameType

   	local levelExist = false
    gameTypeList = {}
    for _,v in pairs(bm.gameList) do
    	for _,singleGame in ipairs(v["gameArr"]) do
    		-- dump(singleGame["gameList"], "table_list:show")

    		if next(singleGame["gameList"]) then
	    		local level = singleGame["gameList"][1]["level"]

	    		dump(singleGame["gameList"], "singleGame[gameList]")
	    		if level then
	    			gameTypeList[level] = singleGame
	    		end
	    		-- print(self._curLevel, level, "table_list_show")
	    		if self._curLevel == level then
	    			levelExist = true
	    		end
	    	end

    	end
    end

    if levelExist == false then
    	self._curLevel = next(gameTypeList)
    end
    ------------------------------------------------

	if typ == "show" then   --从大厅点击对应游戏进入，先加载界面，后请求数据
		dump(self._curLevel,"self._curLevel")
		require(HallServer_filePath):loginAlloc(self._curLevel)
        -- self:chooseBasechip()
    end

    -- dump(self._curScene,"self._curScene")
    -- dump(self.tablesData,"self.tablesData")
    -- dump(self.allTablesData,"self.allTablesData")

    if self.tablesData and self._curScene == "table_list" then

		if typ == "insert" then  --创建房间
			self:queryRoomList("update")
		elseif typ == "disband" then  --房间解散
			self:queryRoomList("show")
		elseif typ == "allroom" then  --151登陆alloc返回
			self:queryRoomList("show")
		end	

	end

end	

function table_list:loadTableScene()    

	self._curScene = "table_list"

	--释放之前的
    local s = SCENENOW["scene"]:getChildByName("table_list")

    if  s then
        s:removeSelf()
    end
        
	local csbPath = "hall/res/csb/group/gold_table_list.csb"

    --添加新场景
    if device.platform == "ios" then
        if 	isiOSVerify then
            s = cc.CSLoader:createNode(csbPath)
        else
            s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. csbPath)
        end
    else       
        s = cc.CSLoader:createNode(csbPath)
    end

	s:setName("table_list"):setVisible(true):addTo(SCENENOW["scene"],500)

	local removeScene = function()  
		if tolua.isnull(s) == false then  
			s:removeFromParent()
		end
	end

    local table_list = s:getChildByName("table_list") 
    local table_item = s:getChildByName("table_item") 
    local random_join = s:getChildByName("random_join") 
    local back_btn = s:getChildByName("back_btn") 
    local create_btn = s:getChildByName("create_btn") 
    
	local _touchEvent = function(sender,event)

		local name = sender:getName()

		if  event == TOUCH_EVENT_BEGAN then
			require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
	        sender:setScale(0.9)
	    end

	    if  event == TOUCH_EVENT_CANCELED then
	        sender:setScale(1.0)
	    end

		if  event == TOUCH_EVENT_ENDED then
			sender:setScale(1.0)
			
			if name == "random_join" then--快速入局
	    		require(HallServer_filePath):loginGameNew(self._curLevel, 0, 0, self._curBaseChip)
	    		-- require(CreateGroup_filePath):CreateScene(currentPlayMode)
	    		-- require(CreateGroup_filePath):CreateScene(currentPlayMode)
	    		-- self:autoCreateTables(true)
	    		-- dump(self.allTablesData,"self.allTablesData_before")
	    		-- dump(self.tablesData,"self.tableData_before")

	    		-- removeTableData(self.allTablesData[1].tid)
	    		-- dump(self.allTablesData,"self.allTablesData")
	    		-- dump(self.tablesData,"self.tableData")
	    	elseif name == "back_btn" then--快速入局
	    		removeScene()
	    		self:chooseBasechip(self._curLevel)
	    	elseif name == "create_btn" then--创建房间
	    		print(self._gameType, self._curLevel, "loadTableScene")
				require(CreateGroup_filePath):CreateScene(0, nil)  -- {self._gameType, self._curLevel}
			end

		end	
	end

	random_join:addTouchEventListener(_touchEvent)
	back_btn:addTouchEventListener(_touchEvent)
	create_btn:addTouchEventListener(_touchEvent)
	initTablesContainer(table_item, table_list, self.setTableItem)
	--如果发现房间数没有8张，自动创建

end

function table_list:autoCreateTables(forceOpen)   

	local po_times_table = {5000/self._curBaseChip, 10000/self._curBaseChip, 20000/self._curBaseChip}
	local _pot_chip_times = po_times_table[self._curRank]
	
	local _multiple_option = {1,2,10}

	if self._curBaseChip == 600 then
		_multiple_option = {500/600,1000/600,5000/60}
	end

	if self._curRank == 3 then
		_multiple_option[2] = 5000/self._curBaseChip
	end

	local configs = 
	{	
		--当官
		[142] = {discription = "当官：三轮切锅，锅底" .. _pot_chip_times * self._curBaseChip,
		         json = json.encode({multiple_option = _multiple_option, cut_pot_mode = 3, pot_mode = 2,
		         peopleNum = 6,bet_time = 15,pair_double = 2,card_mode= 2, pot_chip_option = {_pot_chip_times}}  --
		         	)},

		--跳跳
		[143] = {discription = "跳跳：三轮切锅，锅底" .. _pot_chip_times * self._curBaseChip ,
		         json = json.encode({multiple_option = _multiple_option, cut_pot_mode = 3, pot_mode = 2,
		         	peopleNum = 6,bet_time = 15,pair_double = 1,card_mode= 2, pot_chip_option = {_pot_chip_times}}
		         	)},

		--推筒子
		[144] = {discription = "推筒子：三轮切锅，锅底" .. _pot_chip_times * self._curBaseChip ,
		         json = json.encode({multiple_option = _multiple_option, cut_pot_mode = 3, pot_mode = 2,
		         	peopleNum = 6,bet_time = 15,pair_double = 0,card_mode= 1, pot_chip_option = {_pot_chip_times}}
		         	)}
	}

	local roomIsFull = true

	for i, data in ipairs(self.tablesData) do
		
		if data["play_nums"] ~= data["max_nums"] then
			roomIsFull = false
			break
		end

	end


	--房间满了
	if configs[self._curLevel] and (#self.tablesData < 1 or roomIsFull == true or forceOpen) then 
		-- for i = 1, 8 - #self.tablesData do
		local gameDefaultConfig = {}
		gameDefaultConfig["baseChip"]           = self._curBaseChip
		gameDefaultConfig["discription"]        = configs[self._curLevel]["discription"]
		gameDefaultConfig["discription2Server"] = configs[self._curLevel]["discription"]
		gameDefaultConfig["gameId"]             = tostring(self._curLevel)
		gameDefaultConfig["interfaceType"]      = "J"
		gameDefaultConfig["json"]               = configs[self._curLevel]["json"]
		gameDefaultConfig["level"]              = self._curLevel
		gameDefaultConfig["name"]               = ""
		gameDefaultConfig["others"]             = 0
		gameDefaultConfig["round"]              = 8
		gameDefaultConfig["userId"]             = USER_INFO["uid"]

		dump(gameDefaultConfig, "gameDefaultConfig")
		require("hall.groudgamemanager"):createAgentGame(gameDefaultConfig)
	else

	end


end

function table_list:chooseBasechip(level)   

	self._curScene = "chooseBasechip"

	local s 
	local csbPath = "hall/res/csb/group/gold_score_list.csb"

    if device.platform == "ios" then
        if 	isiOSVerify then
            s = cc.CSLoader:createNode(csbPath)
        else
            s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. csbPath)
        end
    else       
        s = cc.CSLoader:createNode(csbPath)
    end

	s:setName("chooseBasechip"):setVisible(true):addTo(SCENENOW["scene"],500)

    local gameName_txt = s:getChildByName("gameName_txt"):setVisible(false) 

    if self._curGameName then
    	gameName_txt:setString(self._curGameName):setVisible(true) 
    end

    --------------------------------------------------------------------------
	local removeScene = function()  
		if tolua.isnull(s) == false then  
			s:removeFromParent()
		end
	end

	local back_btn = s:getChildByName("back_btn")
	back_btn:addTouchEventListener(function(sender,event)
		
		if event == TOUCH_EVENT_BEGAN then

			sender:setScale(0.9)
    		require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
		end

		if event == TOUCH_EVENT_CANCELED then
			sender:setScale(1.0)
		end	

    	if event == TOUCH_EVENT_ENDED then
			sender:setScale(1.0)
       		removeScene()
		end  

	end)

	-----------------------------------------------------------------------------
	local Score_list = gameTypeList[self._curLevel]["gameList"][1]["fenchang"] 
	table.sort(Score_list,function(a,b) return tonumber(a.fenchang) < tonumber(b.fenchang) end)

	-- dump(Score_list,"Score_list")

	for i = 1,3 do

		local v = Score_list[i]
		
		local _level = s:getChildByName("level_" .. i)
		_level:setVisible(false)

		if v then

			_level:setVisible(true)

			local baseChip = v["fenchang"]
	       	local admittanceChip = v["misCoinsGold"] 
	       	local isQuickMatch = v["isQuickMatch"]

	 		local txt_basechip = _level:getChildByName("txt_basechip")
			local txt_needcoin = _level:getChildByName("txt_needcoin")
		     
		    txt_basechip:setString(baseChip)
		    txt_needcoin:setString(admittanceChip)

		    _level:addTouchEventListener(
	       		function(sender,event)
	        		
	        		if event == TOUCH_EVENT_BEGAN then
	        			sender:setScale(0.9)
	            		require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
	        		end

	        		if event == TOUCH_EVENT_CANCELED then
	        			sender:setScale(1.0)
	        		end	

	            	if event == TOUCH_EVENT_ENDED then
	        			sender:setScale(1.0)

	        			self._curBaseChip = baseChip
	        			self._curRank = i
						self.tablesData = filterTablesData(self.allTablesData, self._curBaseChip)  --["tableList"]

						self:autoCreateTables()

        				self:loadTableScene()
        				self:show("allroom")
        				removeScene()

					end    
	        end)

	    end


	end
end

function table_list:removeScene()
	local s = SCENENOW["scene"]:getChildByName("table_list")
	if 	tolua.isnull(s) == false then
		s:removeFromParent()
	end
end

--创建房间更新tab
function table_list:updateTab(index1,index2)
	-- --dump(index1 .. index2 .. "updateTab")
	self._curLevel = index1
	gameScoreIndex = index2
	self:setGameList(self._curLevel)
end


function table_list:setGameList(level)

	-- --按钮对应的业务事件
 --    local function touchButtonEvent(level) 

	--     if  self._curLevel ~= level then
 --    		require(NetworkLoadingView_filePath):showLoading("加载游戏列表中")
	--     	print(self._curLevel,level,"当前level","登陆level")
	--         require(HallServer_filePath):logoutAlloc(self._curLevel)
	--         require(HallServer_filePath):loginAlloc(level)
 --    	    SCENENOW["scene"]:performWithDelay(function()
	-- 	    	require(NetworkLoadingView_filePath):removeView()
	--     	end,5)
	--     end

	--     self._curLevel = level

 --    end

	-- local GameList = require("hall.GameList")

	-- if tolua.isnull(self.game_list) then
	-- 	self:show("show")
	-- end

	-- GameList:addGamesToListView(self.game_list, 0, touchButtonEvent, nil, 1.5, level) 
	
end

function table_list:refreshData(level)
	require(HallServer_filePath):loginAlloc(level)
end

function table_list:getEnterMisCoins(baseChip)
		
	local fenchangIndex = self.fenchangTable[baseChip]

	if 	fenchangIndex then
		return fenchangMisCoinsGoldTable[fenchangIndex]
	end

end

function table_list:addEnterRoomEvent(node, idx, data)
	
	local invity_code = data["invity_code"]
	local gameConfig = data["description"]
	local baseChip = data["baseChip"]
	local max_nums = data["max_nums"]
	local activity_id = data["activity_id"]
	local password = data["password"]
	local ower_uid = data["ower_uid"]

	local function onTouch(sender,event)

		if 	event == TOUCH_EVENT_BEGAN then
			require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
			sender:setScale(1)
		end	

		if 	event == TOUCH_EVENT_CANCELED then
			sender:setScale(1)
		end

		if 	event == TOUCH_EVENT_ENDED then

			sender:setScale(1)

			local selected_flag = sender:getChildByName("selected_flag")

			if selected_flag:isVisible() then

				local tid = sender.tid

				USER_INFO["invote_code"] = invity_code--房间号，点击后获得

				USER_INFO["player_nums"] = max_nums

				USER_INFO["gameConfig"] = gameConfig or ""
				
				USER_INFO["baseChip"] = baseChip

				if password and password ~= "" and USER_INFO["uid"] ~= ower_uid then  --密码存在

					dump(password,"addEnterRoomEvent_password")
					local joinFunc = function(password)
						require(HallServer_filePath):loginEncryptGame(self._curLevel, tid, activity_id, nil, password)
					end
					
					require(JoinGroup_filePath):showInputPasswordScene("join",joinFunc)

				else
					if tonumber(self._curLevel) == 302 and PURE_JAVA_HALL then
                        require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], invity_code, activity_id, false, self._curLevel, false)
                    else
                        require(HallServer_filePath):loginGameNew(self._curLevel, tid, activity_id, self._curBaseChip)
                    end
				end

			else

				if tolua.isnull(self.selectedTable) == false then
					self.selectedTable:getChildByName("selected_flag"):setVisible(false)
				end

				dump("选中桌子")
				selected_flag:setVisible(true)

				self.selectedTable = sender

			end



		end

	end

	node:addTouchEventListener(onTouch)
end

function table_list:queryRoomList(typ)
 	
	require(NetworkLoadingView_filePath):removeView(13)

	-- if typ == "show" then
 		customScrollView:reload(self.tablesData)
 	-- else
 		-- local oriOffset = self.m_tableView:getContentOffset()
		-- customScrollView:reload(self.tablesData)
 		-- self.m_tableView:setContentOffset(cc.p(oriOffset.x,oriOffset.y - itemHeight))
 	-- end
end


function table_list:updateFenchangPlayerNum(fenchangPlayerNumTable)

	for index,playerNum in pairs(fenchangPlayerNumTable) do
		local itemLayout = self.score_list:getChildByTag(index)
		if itemLayout then
			local playerNum_txt = itemLayout:getChildByName("playerNum_txt")
			playerNum_txt:setString(playerNum) 
		end
	end

end


function table_list:setTableItem(newPanel, data)  

    if data then

        -- dump(data["description"],"setTableItem")

        local selected_flag = newPanel:getChildByName("selected_flag"):setVisible(false)
        local player_nums = newPanel:getChildByName("player_nums"):setString(data["play_nums"] .. "/" .. data["max_nums"] .. "人")

		newPanel.tid = data["tid"] 
        newPanel:setTouchEnabled(true)
        newPanel:setSwallowTouches(false)

    	for i = 1, 12 do
    		local player = newPanel:getChildByName("player_item_".. i)
    		if player then
    			local playerhead = player:getChildByName("playerhead"):setVisible(false)
    		end
    	end

        for i, seatId in ipairs(data["userMap"]) do

        	-- local seatId = v.seatId
            seatId = type(seatId) == "table" and seatId.seatId or seatId
            local player = newPanel:getChildByName("player_item_".. (seatId+1)):setVisible(true)
            local playerhead = player:getChildByName("playerhead"):setVisible(true)
            -- local playerhead = player:getChildByName("playerhead"):setVisible(true)
            -- require("hall.GameCommon"):getUserHead(v["portrait"], "", "", playerhead, 90, true, v["nickname"], true):setTouchEnabled(false)

        end

        -- for i= 1,max_nums do   --max_nums+1,10 
        --     local player = newPanel:getChildByName("player_"..i)
        --     player:setVisible(true)

        --     local playerhead = player:getChildByName("playerhead")
        --     playerhead:setVisible(false)
        -- end

        local txt_room_id = newPanel:getChildByName("txt_room_id")
        txt_room_id:setString(data["invity_code"])

        -- local game_mode = newPanel:getChildByName("game_mode")
        -- local description = LuaSplit(data["description"]," ")
    
        -- local allStrs = {}

    	-- local encrypt_flag = newPanel:getChildByName("encrypt_flag")
    	-- if encrypt_flag then

	    --     if password and password ~= "" then
	    --     	encrypt_flag:setVisible(true)
	    --     else
	    --     	encrypt_flag:setVisible(false)
	    --     end
	    -- end

        -- for k,str in pairs(description) do
        --     local optionPos = string.find(str,":")
        --     if  optionPos then
        --         local strTable = {}
        --         strTable["content"] = string.sub(str,1,optionPos) 
        --         strTable["color"] = cc.c3b(255,255,255)
        --         table.insert(allStrs,strTable)

        --         local strTable = {}
        --         strTable["content"] = string.sub(str,optionPos+1) 
        --         strTable["color"] = cc.c3b(255,255,0)
        --         table.insert(allStrs,strTable)

        --         local strTable = {}
        --         strTable["content"] = "  "
        --         strTable["color"] = cc.c3b(255,255,255)
        --         table.insert(allStrs,strTable)
        --     end
        -- end

        local richLabel = newPanel:getChildByName("richLabel")
        richLabel:setString(data["description"])
        -- if richLabel then
        --     richLabel:removeSelf()
        -- end
        
        -- richLabel =require("hall.GameCommon"):LabelToRich(game_mode,allStrs,20)
        -- richLabel:setName("richLabel")
        
        -- local in_coin  -- = tonumber(data["in_coin"])
        -- local player_nums = data.play_nums 
        -- local baseChip = data.baseChip
        -- local fenchangIndex = table_list.fenchangTable[baseChip]

        -- if fenchangIndex then
        --     -- fenchangPlayerNumTable[fenchangIndex] = (fenchangPlayerNumTable[fenchangIndex] or 0) + player_nums
        --     in_coin = fenchangMisCoinsGoldTable[fenchangIndex] 
        -- else
        --     in_coin =  tonumber(data["in_coin"])
        -- end

        -- if  in_coin >= 10000 then
        --     in_coin = in_coin/10000 .."万"
        -- end 

        -- local player_nums_txt = newPanel:getChildByName("player_nums")
        -- player_nums_txt:setString(player_nums.."人")

        -- local baseChip_txt = newPanel:getChildByName("baseChip_txt")
        -- baseChip_txt:setString(baseChip)

        -- local join_coin = newPanel:getChildByName("join_coin")
        -- join_coin:setString(in_coin.."准入")

        -- local room_owner_head = newPanel:getChildByName("player_0"):getChildByName("playerhead") 

        -- require("hall.GameCommon"):getUserHead(data["creator_portrait"], "", "",room_owner_head, 160, false, data["creator_nikename"], true)

        -- for k, seatId in ipairs(data["userMap"]) do

        --     local player = newPanel:getChildByName("player_".. (seatId+1)):setVisible(true)
        --     local playerhead = player:getChildByName("playerhead"):setVisible(true)
        --     require("hall.GameCommon"):getUserHead(v["portrait"], "", "", playerhead, 90, true, v["nickname"], true):setTouchEnabled(false)
        	
        -- end

        -- local enter_room = newPanel:getChildByName("enter_room")
              -- enter_room:setSwallowTouches(false)
              -- enter_room:setTag(data["tid"])

        self:addEnterRoomEvent(newPanel, index, data)
    
    end
end  
  

return table_list