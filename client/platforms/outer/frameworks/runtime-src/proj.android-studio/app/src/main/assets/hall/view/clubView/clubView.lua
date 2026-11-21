local clubView = class("clubView")

local clubData = require("hall.view.clubView.clubData")
local clubSendData = require("hall.view.clubView.clubSendData")
--local Language = require("hall.Language")
------------------------------------------------

---------------------------------------------------
------------------------------------------------------
local oneLineCount = 3
local oneColCount = 2
local group_name = "联盟"
-----------------------------------------------------
local forbitfrequentRequests_friendRoom = false
local friendRoomListCache = {}

local forbitfrequentRequests_clubRoom = false
local clubRoomsCache = {}
------------------------------------------------------
local my_club_scene

local allClubsData = {}   --key是clubId, value是数据对象
local curClubData = nil --当前联盟的数据
local clubListCache   --联盟列表缓存

local clubMemberCache = {}   --联盟成员缓存
local curSelectedClubId

-- local curSceneTableNum = 0

local is_config = 0
local is_invitation = 1
local is_agree = 1

local invitation_news = nil
-- local _tableData_index = 1

local function getSuitTabledItem(maxSeatCount)
	if maxSeatCount <= 3 then
		return clubView.Table3:clone()
	elseif maxSeatCount == 4 then
		return clubView.Table:clone()
	else
		return clubView.Table2:clone()
	end
end

local getTablePos = function(i)  end 
local updateSwitchState = function(i)  end 

function clubView:showView()

	allClubsData = {}
	curClubData = nil
	clubListCache = nil
	clubMemberCache = {}

	my_club_scene = cc.CSLoader:createNode("hall/view/clubView/my_club.csb"):addTo(SCENENOW["scene"]):setName("clubView")

	local menu_plane = my_club_scene:getChildByName("menu_plane")
	local club_info_plane = my_club_scene:getChildByName("club_info_plane")

    --群名
	self.clubname_txt = club_info_plane:getChildByName("clubname_txt"):setString("")
	self.clubfloorinfo_txt = club_info_plane:getChildByName("clubfloorinfo_txt"):setString("")
	--self.clubId_txt = club_info_plane:getChildByName("clubId_txt"):setString("")
	self.club_Name = club_info_plane:getChildByName("Text_17"):setString(""):setVisible(false)
	self.club_Img1 = club_info_plane:getChildByName("jingman2"):setVisible(false)
	self.club_Id_One = self.club_Img1:getChildByName("Text_9"):setString("")
	self.club_Img2 = club_info_plane:getChildByName("jingman2_0"):setVisible(false)
	self.club_Fk_One = self.club_Img2:getChildByName("Text_11"):setString("")
	self.Anim = club_info_plane:getChildByName("Anim"):setVisible(false)
    self.background = club_info_plane:getChildByName("background"):setVisible(false)
	self.jingman2_0_0 = club_info_plane:getChildByName("jingman2_0_0"):setVisible(false)

	self.game_config_text = club_info_plane:getChildByName("game_config_text")

    --创建房间列表
	self.create_bt  = menu_plane:getChildByName("create_bt"):setVisible(false)
	self.join_bt = menu_plane:getChildByName("join_bt")
	local notice_bt = menu_plane:getChildByName("notice_bt")
	self.share_btn = menu_plane:getChildByName("share_btn")

    --群设置
	self.setting_bt  = menu_plane:getChildByName("setting_bt")

	--显示隐藏联盟的按钮
	local cube_btn  = menu_plane:getChildByName("cube_btn")

    --群成员列表
	self.friends_bt  = menu_plane:getChildByName("friends_bt")
		self.friends_plane  = my_club_scene:getChildByName("friends_plane")
		self.friends_lv  = self.friends_plane:getChildByName("friends_lv")
		self.friends_item = self.friends_plane:getChildByName("friends_item")

    ---比赛限制
    self.biSaiXianZhi = menu_plane:getChildByName("biSaiXianZhi"):setVisible(false)
    --联盟列表 
	local my_club_plane  = cc.CSLoader:createNode("hall/view/clubView/club_list_scene.csb"):addTo(my_club_scene):setName("clubView"):setVisible(false)
	self.my_club_plane = my_club_plane

		self.club_game_record_plane = my_club_plane:getChildByName("club_game_record_plane"):setVisible(false)
		self.input_club_scene = my_club_plane:getChildByName("input_club_scene"):setVisible(true)

			local addClubTypeTitle = self.input_club_scene:getChildByName("addClubTypeTitle")
			self.club_name_input = self.input_club_scene:getChildByName("club_name_input")
			local sure_bt = self.input_club_scene:getChildByName("sure_bt")

        ---------标签加号按钮和加号下隐藏的2个选项--------
		--local add_club_bt = my_club_plane:getChildByName("add_club_bt")
		--local add_club_plane = my_club_plane:getChildByName("add_club_plane")

			--local create_club_txt = add_club_plane:getChildByName("create_club_txt"):setString("创建"..group_name)
			--local join_club_txt = add_club_plane:getChildByName("join_club_txt"):setString("加入"..group_name)
             
            local create_club_txt = my_club_plane:getChildByName("create_club_txt")
            local join_club_txt = my_club_plane:getChildByName("join_club_txt")

		local exit_bt = my_club_plane:getChildByName("exit_bt")
		local back_bt = my_club_plane:getChildByName("back_bt")

		self.clubs_plane = my_club_plane:getChildByName("clubs_plane")
		self.clubs_item = my_club_plane:getChildByName("clubs_item")


    self.applyer_list_plane = my_club_scene:getChildByName("applyer_list_plane")
    	self.applyer_list_plane:getChildByName("applyer_list_mask"):onClick(function() self.applyer_list_plane:setVisible(false) end)

	--设置界面和邀请界面以及设置按钮以及等等等
	self.setting_plane = my_club_scene:getChildByName("setting")
	self.invitation_plane = my_club_scene:getChildByName("invitation_plane")

	self.delete_bt = menu_plane:getChildByName("delete_bt")
	self.invitationList_bt = menu_plane:getChildByName("invitationList_bt")
	self.apply_bt = menu_plane:getChildByName("apply_bt")
	self.invitation_bt = menu_plane:getChildByName("invitation_bt")
	self.back_btn = menu_plane:getChildByName("back_btn")


	local floorConfig_bt = menu_plane:getChildByName("floorConfig_bt")
	local prescene_bt = menu_plane:getChildByName("prescene_bt")
	local nextscene_bt = menu_plane:getChildByName("nextscene_bt")

    --房间列表
	self.room_list_plane = my_club_scene:getChildByName("room_list_PageView"):setVisible(true)

	self.room_list_item  = my_club_scene:getChildByName("room_list_item")

	self.Table = my_club_scene:getChildByName("Table")
	self.Table2 = my_club_scene:getChildByName("Table2")
	self.Table3 = my_club_scene:getChildByName("Table3")

	self.TableListView = my_club_scene:getChildByName("ListView")

	--游戏列表
	self.Game_mode = my_club_scene:getChildByName("Game_mode")

	-- dump(tolua.type(self.room_list_plane), "room_list_planeroom_list_planeroom_list_plane")
	updateSwitchState = function(forceSwitch)

		local curPageIndex = self.room_list_plane:getIndex(self.room_list_plane:getCenterItemInCurrentView())
		local itemsCount = #self.room_list_plane:getItems()

		dump(forceSwitch, "forceSwitch")
		if forceSwitch == "next" then
			prescene_bt:setVisible(false)
			nextscene_bt:setVisible(true)
			return
		elseif forceSwitch == "pre" then
			prescene_bt:setVisible(true)
			nextscene_bt:setVisible(false)
			return
		end

		if itemsCount == 0  then
			prescene_bt:setVisible(false)
			nextscene_bt:setVisible(false)
		elseif curPageIndex <= 0 then
			prescene_bt:setVisible(false)
			nextscene_bt:setVisible(true)
		elseif curPageIndex <=  itemsCount - 1 then
			prescene_bt:setVisible(true)
			nextscene_bt:setVisible(false)
		else
			prescene_bt:setVisible(true)
			nextscene_bt:setVisible(true)
		end
	end

	local function switchRoomScene(direction)
		local curPageIndex = self.room_list_plane:getIndex(self.room_list_plane:getCenterItemInCurrentView())

		if direction == "next" then
			self.room_list_plane:scrollToPage(curPageIndex + 1)
		elseif direction == "pre" then
			self.room_list_plane:scrollToPage(curPageIndex - 1)
		end

		SCENENOW["scene"]:performWithDelay(function()
			updateSwitchState()
		end,0.2)
	end

	updateSwitchState()
    
    local addClubMode = 1
    local clubBtnsEvent = function(sender,event)
    


        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
        	if sender ~= self.friends_plane then
        		sender:setScale(0.9)
        	end
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
        	sender:setScale(1)
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then

        	sender:setScale(1)

        	require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
            --退出联盟界面
			if  sender == exit_bt then
				my_club_plane:setVisible(false)
				--请求群成员列表
			elseif sender == self.friends_bt then
				self.friends_plane:setVisible(not self.friends_plane:isVisible())
				--self.setting_plane:setVisible(false)

				self:requestClubMembers(curSelectedClubId,"refresh")
                
                -- local MoreGameslayer = require("hall.myNewHall.MoreGameslayer")
                -- local moreGameslayer = MoreGameslayer.new()
                -- moreGameslayer:addTo(SCENENOW["scene"]):setName("moreGameslayer")
             
                ---------打开新的添加的场景--------标签------------------
                local AddCludList = require("hall.view.clubView.AddCludList") 
                local addClubList = AddCludList.new()
                addClubList:addTo(SCENENOW["scene"]):setName("AddCludList")
                addClubList:setScale(2/3)
                dump(self.toAddSubInfo,"10000")
  
                addClubList:loadlist(self.toAddSubInfo, self.clubBuId)
                 ------------------------------------------------------------- 
                 
				--打开联盟设置界面
			elseif sender == self.setting_bt then
				self:clubSetting()
				self.setting_plane:setVisible(true)

			--elseif sender == add_club_bt then
				--add_club_plane:setVisible(not add_club_plane:isVisible())

				--请求创建联盟
			elseif sender == create_club_txt then
				if  USER_INFO["gold"] >= 0 then
					addClubMode = 1
					--add_club_plane:setVisible(false)
					self.club_name_input:setPlaceHolder("请输入"..group_name.."名")
					addClubTypeTitle:setString("创建"..group_name)
				else
					local txts = {}
					txts["title"] = "提示"
					txts["sureBt_txt"]  = "确认"
					txts["cancelBt_txt"] =  nil

					local customfunc = {}
					customfunc["cancel_func"] = function() end
					txts["msg"] = "金币不足无法创建"
					--customfunc["sure_func"]  = self.requestdissolveClub
					require("hall.GameTips"):showCustomTips(txts,customfunc,3)
				end
				self.club_game_record_plane:setVisible(false)
				self.input_club_scene:setVisible(true)
				--请求加入联盟
			elseif sender == join_club_txt then
				addClubMode = 2
				--add_club_plane:setVisible(false)
				self.club_name_input:setPlaceHolder("请输入"..group_name.."ID")
				addClubTypeTitle:setString("加入"..group_name)
				self.club_game_record_plane:setVisible(false)
				self.input_club_scene:setVisible(true)
				--确认添加联盟
			elseif sender == sure_bt then
				self:requestJoinOrCreateClub(addClubMode)

				--返回联盟主界面
			elseif sender == back_bt then
				self.club_name_input:setString("")
				--请求创建房间
			elseif sender == self.create_bt then
				if  curSelectedClubId == nil then
					require("hall.GameTips"):showTips("提示", "", 3, "请选择一个"..group_name.."！")
					return
				end

				local defaultConfig = curClubData:getFloorData().gameConfig

				if defaultConfig then

				else

					local gameType = curClubData:getFloorData().gameType
					local gameLevel = curClubData:getFloorData().gameLevel
					require(CreateGroup_filePath):CreateScene(2,curSelectedClubId, {gameType, gameLevel})

				end

				--请求退出联盟
			elseif sender == self.delete_bt then
                self.club_Name:setVisible(false)
	            self.club_Img1:setVisible(false)
	            self.club_Img2:setVisible(false)
                self.background:setVisible(false)
	            self.jingman2_0_0:setVisible(false)

				if  curSelectedClubId == nil then
					require("hall.GameTips"):showTips("提示", "", 3, "请选择一个"..group_name.."！")
					return
				end

				local txts = {}
				txts["title"] = "提示"
				txts["sureBt_txt"]  = "同意"
				txts["cancelBt_txt"] =  "取消"

				local customfunc = {}
				customfunc["cancel_func"] = function() end

				if 	curClubData:getclubOwnerUid() == USER_INFO["uid"] then
					txts["msg"] = "确认解散群?"
					customfunc["sure_func"]  = self.requestdissolveClub
				else
					txts["msg"] = "确认退出群?"
					customfunc["sure_func"]  = self.requestQuitClub
				end

				require("hall.GameTips"):showCustomTips(txts,customfunc,1)

			elseif sender == notice_bt then --搜索游戏类型房间

				require("hall.GameTips"):showTips("提示", "", 3, "敬请期待")

			elseif sender == cube_btn then
				my_club_plane:setVisible(not my_club_plane:isVisible())
				-- self.biSaiXianZhi:setVisible(false)
			elseif sender == self.invitationList_bt then

				if self.applyer_list_plane:isVisible() then
					self.applyer_list_plane:setVisible(false)
				else
					self.applyer_list_plane:setVisible(true)
					self:showNews(5)
				end

			elseif sender == self.apply_bt then

				if self.applyer_list_plane:isVisible() then
					self.applyer_list_plane:setVisible(false)
				else
					self.applyer_list_plane:setVisible(true)
					self:showNews(0)
				end

			elseif sender == self.invitation_bt then
				if  curSelectedClubId == nil then
					require("hall.GameTips"):showTips("提示", "", 3, "请选择一个"..group_name.."！")
					return
				end
				self.invitation_plane:setVisible(true)
				self:invitation()
			elseif sender == self.back_btn then
				self:removeScene()
			elseif sender == self.friends_plane then
				self.friends_plane:setVisible(false)
			elseif sender == self.join_bt then
			elseif sender == floorConfig_bt then
				self:showFloorSettingView()
			elseif sender == prescene_bt then
				switchRoomScene("pre")
			elseif sender == nextscene_bt then
				switchRoomScene("next")

		    elseif sender == self.biSaiXianZhi then
		        --------标签-----内容------
		        local ParticipationScore = require("hall.view.clubView.ParticipationScore") 
                local participationScore = ParticipationScore.new()
                participationScore:addTo(SCENENOW["scene"]):setName("participationScore")
                participationScore:longingData(self.toAddSubInfo, self.clubBuId)

            end
        end
	end
    
	-----------------------------------------------------------------
	local table_list_view_size = self.TableListView:getContentSize()

	local width = table_list_view_size.width 
	local height = table_list_view_size.height  

	local centerX = width/2
	local centerY = height/2 - 57

	local intervalX = 400  --width/ (oneLineCount + 1) +
	local intervalY = 240 --两个桌子间高度差 height/(oneColCount + 1) +

	getTablePos = function(i)

		i = math.ceil(i % (oneLineCount * oneColCount + 0.01))

		local x = centerX -  (( (oneLineCount + 1) /2) - math.ceil(i % (oneLineCount + 0.01)) )
			* intervalX
		local y = centerY + (( (oneColCount + 1) /2) - math.ceil(i / (oneLineCount + 0.01)) )
			* intervalY

		return cc.p(x,y)

	end

	prescene_bt:addTouchEventListener(clubBtnsEvent)
	nextscene_bt:addTouchEventListener(clubBtnsEvent)
    --add_club_bt:addTouchEventListener(clubBtnsEvent)
	exit_bt:addTouchEventListener(clubBtnsEvent)
	self.friends_bt:addTouchEventListener(clubBtnsEvent)
	self.setting_bt:addTouchEventListener(clubBtnsEvent)
	create_club_txt:addTouchEventListener(clubBtnsEvent)
	join_club_txt:addTouchEventListener(clubBtnsEvent)
	sure_bt:addTouchEventListener(clubBtnsEvent)
	back_bt:addTouchEventListener(clubBtnsEvent)
	self.create_bt:addTouchEventListener(clubBtnsEvent)
	notice_bt:addTouchEventListener(clubBtnsEvent)
	floorConfig_bt:addTouchEventListener(clubBtnsEvent)
	cube_btn:addTouchEventListener(clubBtnsEvent)
	self.back_btn:addTouchEventListener(clubBtnsEvent)
	self.join_bt:addTouchEventListener(clubBtnsEvent)
	self.friends_plane:addTouchEventListener(clubBtnsEvent)
	self.delete_bt:addTouchEventListener(clubBtnsEvent)
	self.invitationList_bt:addTouchEventListener(clubBtnsEvent)
	self.apply_bt:addTouchEventListener(clubBtnsEvent)
	self.invitation_bt:addTouchEventListener(clubBtnsEvent)
	self.game_config_text:addTouchEventListener(clubBtnsEvent)

	self.biSaiXianZhi:addTouchEventListener(clubBtnsEvent)
    --初始化界面情况
    self.applyer_list_plane:setVisible(false)
    self.friends_plane:setVisible(false)
    --add_club_plane:setVisible(false)
	self.setting_plane :setVisible(false)
	self.invitation_plane :setVisible(false)
	self.setting_bt :setVisible(false)
	self.game_config_text:setVisible(false)
	self.game_config_text:setVisible(true)
	self.invitation_bt:setVisible(false) 
	self.delete_bt:loadTextures("hall/view/clubview/images/newclub/AutoAtlas-2_87.png", nil, nil)

    --请求查看联盟列表
    self:requestClubList()
	self:requestJoinNews(5)

end

function clubView:clubIdIsMy(toAddSubInfo, clubBuId)
    for k,v in pairs(toAddSubInfo) do
    	if clubBuId == tonumber(v.clubId) then
    		return v.owener
    	end
    end
end

--显示楼层选择界面
function clubView:showFloorSettingView()

	if curClubData == nil then
		return
	end

	local floor_config_scene = SCENENOW["scene"]:getChildByName("floor_config_scene")	

	if floor_config_scene then
		floor_config_scene:removeFromParent()
	end

	floor_config_scene = cc.CSLoader:createNode("hall/view/clubView/floor_config_scene.csb"):addTo(SCENENOW["scene"]):setName("floor_config_scene")
		local exit_bt = floor_config_scene:getChildByName("exit_bt")
		local rule_item = floor_config_scene:getChildByName("rule_item")
		---------------标签--------------------
		local rules_plane = floor_config_scene:getChildByName("rules_plane")

	exit_bt:onClick(function() floor_config_scene:removeFromParent() end)

	local selectedFlag_img_Table = {}

	for floorId = 1,5 do

		local floorData = curClubData:getFloorData(floorId)
		-- dump(floorData, "showFloorSettingView")

		local gameName = floorData.gameName or ""
		local floorNick = floorData.floorNick or ""

		local clone_rule_item = rule_item:clone()
			local floorName_txt = clone_rule_item:getChildByName("floorName_txt")
			local ruleName_txt = clone_rule_item:getChildByName("ruleName_txt")
			local setting_image = clone_rule_item:getChildByName("setting_image"):setVisible(curClubData:getclubOwnerUid() == USER_INFO["uid"])
			setting_image:setVisible(false)
			local take_txt = clone_rule_item:getChildByName("take_txt")
			local take_txt1 = clone_rule_item:getChildByName("take_txt1")
			local take_txt2 = clone_rule_item:getChildByName("take_txt2")
			local take_num = clone_rule_item:getChildByName("take_num")
			local selectedFlag_img = clone_rule_item:getChildByName("selectedFlag_img"):setOpacity(255)
			local create_btn = clone_rule_item:getChildByName("create_btn")
			table.insert(selectedFlag_img_Table,selectedFlag_img)
		
			local create = function(...) 
				require(CreateGroup_filePath):CreateScene(2, curSelectedClubId, nil, true, floorId)
			end 
	
			local join = function(...)
				for _,selectedFlag_img in pairs(selectedFlag_img_Table) do
					selectedFlag_img:setOpacity(255)
				end
				selectedFlag_img:setOpacity(255)
				curClubData:setCurFloor(floorId)
	
				SCENENOW["scene"]:performWithDelay(function()
					if tolua.isnull(floor_config_scene) == false then
						self.clubfloorinfo_txt:setString(floorNick .. "   " .. gameName)
						floor_config_scene:removeFromParent()
					end
				end, 0.5)
	
				self:loadClubRoomList()
			end 
			local func = function() end 
			create_btn:loadTexture("hall/view/clubView/image/newclub/clublist/join_btn.png")
			func = join
			if "" == gameName and "" == floorNick then 
				create_btn:loadTexture("hall/view/clubView/image/newclub/clublist/create_btn.png")
				func = create
			end 
			local state = "" == gameName and "" == floorNick
			take_num:setVisible(not state)
			create_btn:onClick(func , nil , true)
		floorName_txt:setString(floorNick .. "   " .. gameName)

		take_num:setString(string.format(Language.CLUB.NUMBER , floorId))
		self:DelearWithTake(take_txt , floorData , take_txt1 , take_txt2)

		ruleName_txt:setString(rule)
		rules_plane:pushBackCustomItem(clone_rule_item)

		setting_image:onClick(function() 
			require(CreateGroup_filePath):CreateScene(2, curSelectedClubId, nil, true, floorId)
		end , nil , true)

		-- selectedFlag_img:onClick(function() 
	    --     for _,selectedFlag_img in pairs(selectedFlag_img_Table) do
		--     	selectedFlag_img:setOpacity(0)
		--     end
		-- 	selectedFlag_img:setOpacity(255)
		-- 	curClubData:setCurFloor(floorId)

		-- 	SCENENOW["scene"]:performWithDelay(function()
		-- 		if tolua.isnull(floor_config_scene) == false then
		-- 			self.clubfloorinfo_txt:setString(floorNick .. "   " .. gameName)
		-- 			floor_config_scene:removeFromParent()
		-- 		end
		-- 	end, 0.5)


		-- end)

		if curClubData:getCurFloor() == floorId then
			selectedFlag_img:setOpacity(255)
		end

	end
end


function clubView:DelearWithTake(node , data , node1 , node2)
	local take_word = ""
	local take_word1 = ""
	local take_word2 = ""
	if "桂林十三水" == data.gameConfig.gameName then 
		take_word = data.gameConfig.shisanGameOption.optionName
		take_word1 = data.gameConfig.peopleNum.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "二八杠" == data.gameConfig.gameName then 
		take_word = data.gameConfig.pot_mode.optionName
		take_word1 = data.gameConfig.peopleNum.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "经典拼天九" == data.gameConfig.gameName or "推锅牌九" == data.gameConfig.gameName then 
		take_word = data.gameConfig.paigowGroupCount.optionName
		take_word1 = data.gameConfig.startPattern4Card.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "快乐麻将" == data.gameConfig.gameName then 
		take_word = data.gameConfig.hufa.optionName
		take_word1 = data.gameConfig.maxSeatCount.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "长沙麻将" == data.gameConfig.gameName then 
		take_word = data.gameConfig.zhuang.optionName
		take_word1 = data.gameConfig.maxSeatCount.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "血战麻将" == data.gameConfig.gameName then 
		take_word = data.gameConfig.zimo.optionName
		take_word1 = data.gameConfig.fan.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "广东麻将" == data.gameConfig.gameName then 
		take_word = data.gameConfig.zhuaniao.optionName
		take_word1 = data.gameConfig.round.optionName
	elseif "柳州麻将" == data.gameConfig.gameName then 
		take_word = data.gameConfig.wanfa.optionName
		take_word1 = data.gameConfig.maxSeatCount.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "随州卡五星" == data.gameConfig.gameName then 
		take_word = data.gameConfig.zimomaima.optionName
		take_word1 = data.gameConfig.maxFan.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "襄阳卡五星" == data.gameConfig.gameName then 
		take_word = data.gameConfig.niao.optionName
		take_word1 = data.gameConfig.maxSeatCount.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "孝感卡五星" == data.gameConfig.gameName then 
		take_word = data.gameConfig.zimomaima.optionName
		take_word1 = data.gameConfig.maxFan.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "营口麻将" == data.gameConfig.gameName then 
		take_word = data.gameConfig.canPick.optionName
		take_word1 = data.gameConfig.round.optionName
	elseif "镇江麻将" == data.gameConfig.gameName then 
		take_word = data.gameConfig.patternSelect.optionName
		take_word1 = data.gameConfig.maxSeatCount.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "宜春麻将" == data.gameConfig.gameName then 
		take_word = data.gameConfig.confBaseChip.optionName
		take_word1 = data.gameConfig.playerCount.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "常德字牌" == data.gameConfig.gameName then 
		take_word = data.gameConfig.rank.optionName
		take_word1 = data.gameConfig.pay_type.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "填大坑" == data.gameConfig.gameName then 
		take_word = data.gameConfig.gongzhang.optionName
		take_word1 = data.gameConfig.ti.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "斗地主" == data.gameConfig.gameName then 
		take_word = data.gameConfig.pay_type.optionName
		take_word1 = data.gameConfig.zha.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "跑得快" == data.gameConfig.gameName then 
		take_word = data.gameConfig.pay_type.optionName
		take_word1 = data.gameConfig.wanfa.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "诈金花" == data.gameConfig.gameName then 
		take_word = data.gameConfig.maxSeatCount.optionName
		take_word1 = data.gameConfig.pay_type.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "比鸡" == data.gameConfig.gameName then 
		take_word = data.gameConfig.happyscore.optionName
		take_word1 = data.gameConfig.pay_type.optionName
		take_word2 = data.gameConfig.round.optionName
	elseif "逮狗腿子" == data.gameConfig.gameName then 
		take_word = data.gameConfig.pay_type.optionName
		take_word1 = data.gameConfig.round.optionName
	elseif "明牌抢庄" == data.gameConfig.gameName then 
		take_word = data.gameConfig.maxSeatCount.optionName
		take_word1 = data.gameConfig.times.optionName
		take_word2 = data.gameConfig.gameType.optionName
	end 

	node:setString(string.format(Language.CLUB.TAKE_WORD , take_word))
	node1:setString(string.format(Language.CLUB.TAKE_WORD , take_word1))
	node2:setString(string.format(Language.CLUB.TAKE_WORD , take_word2))
end 

--保存设置和楼层玩法设置数据
function clubView:saveData(clubId, _SelectGameConfig, floorId)

	local clubId = clubId or curSelectedClubId
	local is_config = is_config -- allClubsData[curSelectedClubId]:getclubSettingData("is_config")
	local is_invitation = is_invitation -- allClubsData[curSelectedClubId]:getclubSettingData("is_invitation")
	local is_agree = is_agree -- allClubsData[curSelectedClubId]:getclubSettingData("is_agree")

	local floorInfo = curClubData:getFloorInfo() or {}  --allClubsData[clubId]

	if _SelectGameConfig then
		for _floorId, data in ipairs(floorInfo) do
			if _floorId ~= floorId and data.level == _SelectGameConfig.level then  --不同楼层不允许设置相同level的游戏
				require("hall.GameTips"):showTips("提示", "", 3, "不同楼层不能设置同一个游戏！")
				return
			end
		end

		floorInfo[floorId] = _SelectGameConfig
	end

	local data = {
		groupId = curSelectedClubId or 1,
		playerId = USER_INFO["uid"] or 1,
		is_config = 0, --is_config,
		is_invitation = is_invitation or 1,
		is_agree =  is_agree or 1 ,
		SelectGameConfig = json.encode(floorInfo) or "",
	}

	local function callback(returnCode, data)

		if returnCode == 0 then
			curClubData:setclubSettingData("is_config", is_config)
			curClubData:setclubSettingData("is_invitation", is_invitation)
			curClubData:setclubSettingData("is_agree", is_agree)
			curClubData:setFloorInfo(floorInfo)

			self:showFloorSettingView()
			require("hall.GameTips"):showTips("提示", "", 3, "设置成功！")
		end

	end

	clubSendData:requestUpdateGroupConfig(data, callback)
end


--联盟设置
function clubView:clubSetting()

	local close_btn = self.setting_plane:getChildByName("close_btn")
	local modify_name = self.setting_plane:getChildByName("setName")
	local input_clubName = self.setting_plane:getChildByName("input_culbName")
	input_clubName:setVisible(false)
	local clubName = self.setting_plane:getChildByName("culbName")
	clubName:setVisible(true)
	clubName:setString(self.club_name );
	local is_configY = self.setting_plane:getChildByName("is_configY")
	local is_configN = self.setting_plane:getChildByName("is_configN")
	local is_invitationY = self.setting_plane:getChildByName("is_invitationY")
	local is_invitationN = self.setting_plane:getChildByName("is_invitationN")
	local is_agreeY = self.setting_plane:getChildByName("is_agreeY")
	local is_agreeN = self.setting_plane:getChildByName("is_agreeN")

	local setting_planeBtnsEvent = function(sender,event)
		--触摸开始
		if event == TOUCH_EVENT_BEGAN then
			if 	sender ~= mask then
				--sender:setScale(0.9)
			end
		end

		--触摸取消
		if event == TOUCH_EVENT_CANCELED then
			sender:setScale(1)
		end

		--触摸结束
		if event == TOUCH_EVENT_ENDED then

			sender:setScale(1)

			require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
			if sender == modify_name then
				if clubName:isVisible() == true then
					clubName:setVisible(false)
					input_clubName:setVisible(true)
					input_clubName:setString("")
				else

					local name = input_clubName:getString()
					if name == "" then
						require("hall.GameTips"):showTips("提示", "", 3, group_name.."名字不能为空！")
						return
					end

					local data =  {
						owerId = USER_INFO["uid"],
						groupId = curSelectedClubId,
						groupName = name
					}

					local function callback(returnCode, data)
						if returnCode == 0 then
							clubListCache = nil
							self:requestClubList()
							require("hall.GameTips"):showTips("提示", "", 3, group_name.."改名成功")
							input_clubName:setVisible(false)
							clubName:setVisible(true)
							clubName:setString(name)
							input_clubName:setString("")
						end
					end

					clubSendData:requestUpdateGroupNameByOwerId(data, callback)

				end

			elseif sender == close_btn then
				self.setting_plane:setVisible(false)
				self:saveData()
			elseif sender == is_configY then
				is_configN:getChildByName("yes"):setVisible(false)
				is_configY:getChildByName("yes"):setVisible(true)
				is_config = 1
			elseif sender == is_configN then
				is_configN:getChildByName("yes"):setVisible(true)
				is_configY:getChildByName("yes"):setVisible(false)
				is_config = 0
			elseif sender == is_invitationY then
				is_invitationN:getChildByName("yes"):setVisible(false)
				is_invitationY:getChildByName("yes"):setVisible(true)
				is_invitation = 1
			elseif sender == is_invitationN then
				is_invitationN:getChildByName("yes"):setVisible(true)
				is_invitationY:getChildByName("yes"):setVisible(false)
				is_invitation = 0
			elseif sender == is_agreeY then
				is_agreeN:getChildByName("yes"):setVisible(false)
				is_agreeY:getChildByName("yes"):setVisible(true)
				is_agree = 1
			elseif sender == is_agreeN then
				is_agreeN:getChildByName("yes"):setVisible(true)
				is_agreeY:getChildByName("yes"):setVisible(false)
				is_agree = 0
			end
		end
	end

	is_configY:getChildByName("yes"):setVisible(is_config ~= 0)
	is_configN:getChildByName("yes"):setVisible(is_config == 0)

	is_invitationY:getChildByName("yes"):setVisible(is_invitation ~= 0)
	is_invitationN:getChildByName("yes"):setVisible(is_invitation == 0)

	is_agreeY:getChildByName("yes"):setVisible(is_agree ~= 0)
	is_agreeN:getChildByName("yes"):setVisible(is_agree == 0)

	modify_name:addTouchEventListener(setting_planeBtnsEvent)
	close_btn:addTouchEventListener(setting_planeBtnsEvent)
	is_configY:addTouchEventListener(setting_planeBtnsEvent)
	is_configN:addTouchEventListener(setting_planeBtnsEvent)
	is_invitationY:addTouchEventListener(setting_planeBtnsEvent)
	is_invitationN:addTouchEventListener(setting_planeBtnsEvent)
	is_agreeY:addTouchEventListener(setting_planeBtnsEvent)
	is_agreeN:addTouchEventListener(setting_planeBtnsEvent)

end

-----------------------------------------------联盟相关方法----------------------------------------
function clubView:refreshClubList()

	if 	tolua.isnull(my_club_scene) then
		return 
	end
	clubListCache = nil
	self:requestClubList()

end

--邀请界面
function clubView:invitation()

	local close_btn = self.invitation_plane:getChildByName("close_btn")
	local sure_btn = self.invitation_plane:getChildByName("sure_btn")
	local inputID = self.invitation_plane:getChildByName("inputID")

	local invitationBtnsEvent = function(sender,event)

		--触摸开始
		if event == TOUCH_EVENT_BEGAN then
			sender:setScale(0.9)
		end

		--触摸取消
		if event == TOUCH_EVENT_CANCELED then
			sender:setScale(1)
		end

		--触摸结束
		if event == TOUCH_EVENT_ENDED then

			sender:setScale(1)

			require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)--触摸开始

			if  sender == close_btn then

				self.invitation_plane:setVisible(false)

			elseif sender == sure_btn then

				local  ID = inputID:getString()
				if  ID == "" then
					require("hall.GameTips"):showTips("提示", "", 3, "邀请ID不能为空！")
					return
				end

				local data =  {
					playerId1   = USER_INFO["uid"],
					playerId2 = ID,
					groupId  = curSelectedClubId
				}

				local function callback(returnCode, data)
					if returnCode == 0 then
						self.invitation_plane:setVisible(false)
						require("hall.GameTips"):showTips("提示", "", 3, group_name.."邀请成功")
					elseif returnCode == 2 then
						require("hall.GameTips"):showTips("提示", "", 3, "该玩家已经在该联盟中！")
					end
				end

				clubSendData:inviteForJoinPlayerGroup(data, callback)

			end
		end

	end
	close_btn:addTouchEventListener(invitationBtnsEvent)
	sure_btn:addTouchEventListener(invitationBtnsEvent)

end

--请求查看自己的联盟列表
function clubView:requestClubList()

	if tolua.isnull(my_club_scene) then
		return
	end

	self:init()
    curSelectedClubId = nil
    dump("重置当前curSelectedClubId")

    self:clearClubList()

	if  clubListCache then
		dump(clubListCache,"有缓存，直接查看自己的联盟列表")
		self:loadClubList(clubListCache)
	else
	 	clubListCache = nil

		local data = { playerId = USER_INFO["uid"] }

		local function callback(returnCode, data)
		    if returnCode == 0 then
		    	clubListCache = data

				self:loadClubList(data)
			end
	    end

	    clubSendData:requestClubList(data, callback)

	end

end


function clubView:clearClubList()

	if 	tolua.isnull(self.room_list_plane) or tolua.isnull(self.clubs_plane) then
		return
	end

	self.clubs_plane:removeAllChildren()
	if not curClubData then return end
	curClubData:ClearClubOwnerUid()
end


function clubView:requestClubRecord(clubId)
	self.club_game_record_plane:setVisible(true)
	self.input_club_scene:setVisible(false)

	local data= {groupId = clubId}

	local function callback(returnCode, data)
		if returnCode == 0 then
			dump(data, "requestClubRecord")
			--------------标签部------------------
			self:loadClubRecord(data)
			dump(data, "miss-----------")
		end
	end

	clubSendData:requestClubRecord(data, callback)

end

function clubView:loadClubRecord(data)

	if tolua.isnull(self.club_game_record_plane) then
		dump("当前不在联盟战绩界面")
		return
	end

	local record_list_plane = self.club_game_record_plane:getChildByName("record_list_plane")
	record_list_plane:removeAllChildren()

	local club_game_record_item = self.club_game_record_plane:getChildByName("club_game_record_item")

	for i, v in ipairs(data) do

		local score = v.pointCount or 0
		local changciCount = v.changciCount or 0
		local nickName = v.nickName or "爱米粒"
		local big_win_score = v.dayingjiaPointCount 
		local dayingjiaCount = v.dayingjiaCount 
        ----------标签部--------------------
		local club_game_record_item = club_game_record_item:clone() 
			local playername = club_game_record_item:getChildByName("playername")
			local score_txt = club_game_record_item:getChildByName("score_txt")
			local index = club_game_record_item:getChildByName("index")
			local bigwin_count_txt = club_game_record_item:getChildByName("bigwin_count_txt")
		record_list_plane:pushBackCustomItem(club_game_record_item)

		playername:setString(nickName)	
		score_txt:setString(changciCount .."/" .. score)	
		index:setString(i)	
		bigwin_count_txt:setString( dayingjiaCount.."/" .. big_win_score)	
	end

end

function clubView:loadClubList(data)
    dump(data,"data is-------")  
	if 	tolua.isnull(self.clubs_plane) then
		return
	end

    local selectedFlag_img_Table = {}

    self:clearClubList()
    -----取数联盟数值的表----------
    self.toAddSubInfo = {}
    self.clubBuId = 0

    for clubId,v in pairs(data) do
    	v = json.decode(v)
		dump(v,"联盟数据")
		dump(clubId, "索引------")
		--------------标签---------------
		table.insert(self.toAddSubInfo, {clubId = clubId, owener = v.owerId,playerCount =v.playerCount})

		local clubId = tonumber(clubId)

		local config = json.decode(v.config) or {}
		local clubName = v.groupName or ""
		local clubRoomNum = v.clubRoomNum or 0
		local owerId = v.owerId or 0
		local playerCount = v.playerCount or "??"

		allClubsData[clubId] = allClubsData[clubId] or clubData.new() 

		allClubsData[clubId]:setclubSettingData(config)
		allClubsData[clubId]:setclubSettingData("is_config", is_config)
		allClubsData[clubId]:setclubSettingData("is_invitation", is_invitation)
		allClubsData[clubId]:setclubSettingData("is_agree", is_agree)

		allClubsData[clubId]:setFloorInfo(json.decode(config.SelectGameConfig))

		allClubsData[clubId]:setclubName(clubName)
		allClubsData[clubId]:setclubOwnerUid(owerId)
		-- allClubsData[clubId]:setclubOwnerName(owerId)

		allClubsData[clubId]:setclubId(clubId)

		local clubs_item = self.clubs_item:clone()
		clubs_item:setTag(clubId)

		self.clubs_plane:pushBackCustomItem(clubs_item)

			local selectedFlag_img = clubs_item:getChildByName("selectedFlag_img"):setOpacity(0)
			table.insert(selectedFlag_img_Table,selectedFlag_img)
            
            dump(selectedFlag_img_Table,"11111111")

			local show_record_bt = clubs_item:getChildByName("show_record_bt"):onClick(function() 
		        for _,_selectedFlag_img in pairs(selectedFlag_img_Table) do
			    	_selectedFlag_img:setOpacity(0)
			    end
			    selectedFlag_img:setOpacity(255)
			    ----------------------标签------------------------
				self:requestClubRecord(clubId)  
			end)

			local clubName_txt = clubs_item:getChildByName("clubName_txt")
				:setString(require("hall.GameCommon"):formatNick(clubName,5))
				-------------标签-------------
			local clubMemberNum_txt  = clubs_item:getChildByName("clubMemberNum_txt"):setString("人数：" .. playerCount)
	    	local clubId_txt = clubs_item:getChildByName("clubId_txt"):setString("ID：" .. clubId)

	    	local function loadSingleClubItem(sender)

				self:init()

				curSelectedClubId = clubId
				curClubData = allClubsData[curSelectedClubId]
				---------------
				dump(curClubData,"ID----")

		        for _,selectedFlag_img in pairs(selectedFlag_img_Table) do
			    	selectedFlag_img:setOpacity(0)
			    end
			    sender:setOpacity(255)

			    if 	self.friends_plane:isVisible() then
			    	self:requestClubMembers(curSelectedClubId)
			    end

			    self.clubname_txt:setString(clubName)

			    local floorNick = curClubData:getFloorData().floorNick
			    local gameName = curClubData:getFloorData().gameName

			    if floorNick == "" or floorNick == nil then
			    	self.clubfloorinfo_txt:setString(gameName)
			    else
			    	self.clubfloorinfo_txt:setString(floorNick)
			    end

				self.join_bt:setVisible(not is_config == 0)
				    self.clubBuId = curSelectedClubId
                -----------标签联盟-----------------------
				if 	curClubData:getclubOwnerUid() == USER_INFO["uid"] then
					self.setting_bt:setVisible(true)
					self.invitation_bt:setVisible(true)
                    
                    self.club_Name:setVisible(true)
	                self.club_Img1:setVisible(true)
	                self.club_Img2:setVisible(true)
	                self.background:setVisible(true)
	                self.jingman2_0_0:setVisible(true)
	                self.biSaiXianZhi:setVisible(true)

					self.delete_bt:loadTextures("hall/view/clubview/images/newclub/AutoAtlas-1_22.png", nil, nil)
					--self.clubId_txt:setString("联盟ID：" .. curSelectedClubId .. "    群主ID：" .. curClubData:getclubOwnerUid() .. "      房卡："  ..  USER_INFO["cardCount"])
                    self.club_Name:setString("联盟ID："..curSelectedClubId)
                    self.club_Id_One:setString("ID:" .. curClubData:getclubOwnerUid())
                    self.club_Fk_One:setString(USER_INFO["cardCount"])
				else
					self.setting_bt:setVisible(false)
					self.invitation_bt:setVisible(is_invitation == 1)
					self.delete_bt:loadTextures("hall/view/clubview/images/newclub/AutoAtlas-2_87.png", nil, nil)
					--self.clubId_txt:setString("联盟ID：" .. curSelectedClubId .. "        群主ID：" .. curClubData:getclubOwnerUid())
					self.club_Name:setString("联盟ID："..curSelectedClubId)
                    self.club_Id_One:setString("ID:" .. curClubData:getclubOwnerUid())
                    self.club_Fk_One:setString(USER_INFO["cardCount"])
                 	 self.biSaiXianZhi:setVisible(false)
                    self.club_Name:setVisible(false)
	                self.club_Img1:setVisible(false)
	                self.club_Img2:setVisible(false)
                    self.background:setVisible(false)
	                self.jingman2_0_0:setVisible(false)
				end
                -------------标签------------
                -- self:clubTableInit()
                --setJuLeBuId(curSelectedClubId)

				require("hall.HallServer"):sendClubData(curSelectedClubId)
				self:initTables()

				cc.UserDefault:getInstance():setIntegerForKey("clubId",clubId)
				require("hall.util.GameMenu"):registCopyClubIdFunc(self.share_btn, clubId, clubName)

			    --查看有没有新消息
			    self:requestJoinNews(0)

	    	end

	    	if clubId  == cc.UserDefault:getInstance():getIntegerForKey("clubId", 0) then
	    		loadSingleClubItem(selectedFlag_img)
	    	end

		    local selectedEvent = function(sender,event)

		            --触摸结束
		            if event == TOUCH_EVENT_ENDED then
		            	dump("touchloadSingleClubItem")
		            	loadSingleClubItem(sender)
		            	SCENENOW["scene"]:performWithDelay(function()
							self:removeClubListView()
						end,0.3)

		            end

		     end

			selectedFlag_img:addTouchEventListener(selectedEvent)

	end

	if next(data) == nil or cc.UserDefault:getInstance():getIntegerForKey("clubId", 0) == 0 then
		my_club_scene:getChildByName("clubView"):setVisible(true)
    end

    if not curClubData then return end 
    if curClubData:getclubOwnerUid() == USER_INFO["uid"]then
        self.biSaiXianZhi:setVisible(true)
     else
 	  	self.biSaiXianZhi:setVisible(false)
    end
end

function clubView:removeClubListView()
	if tolua.isnull(self.my_club_plane) == false then
		self.my_club_plane:setVisible(false)
	end
end


--请求添加联盟
function clubView:requestJoinOrCreateClub(addClubMode, clubId)  --addClubMode 1为创建， 2为加入

	if addClubMode == 1 then

		local  clubName = self.club_name_input:getString()
		if  clubName == "" then
			require("hall.GameTips"):showTips("提示", "", 3, group_name.."名不能为空！")
			return
		end

		local data =  {
			playerId = USER_INFO["uid"],
			groupName = clubName,
			configArrays = json.encode({SelectGameConfig = {{}, {}, {}, {}, {}}, is_config = 0, is_agree = 1, is_invitation = 1})
		}  

		local function callback(returnCode, data, error)
			if returnCode == 0 then
				clubListCache = nil
				self:requestClubList()
				require("hall.GameTips"):showTips("提示", "", 3, "创建"..group_name.."成功")
			else
				dump(data, "requestJoinOrCreateClub")
				require("hall.GameTips"):showTips("提示", "", 3, error)
			end
		end

		clubSendData:requestCreateClub(data, callback)

	elseif addClubMode == 2 then

		local  clubId = clubId or tonumber(self.club_name_input:getString()) 

		if  clubId == nil then
			require("hall.GameTips"):showTips("提示", "", 3, group_name .. "ID只能为数字！")
			return
		end

		dump(clubId, "申请加入联盟")

		local data =  {
            groupId = clubId,
            playerId = USER_INFO["uid"]
		}

		local function callback(returnCode, data)
            if returnCode == 0 then
       			require("hall.GameTips"):showTips("提示", "", 3, "申请成功")
            else
            	require("hall.GameTips"):showTips("提示", "", 3, "申请失败,"..group_name.."ID不存在")
            	print("returnCode不为0")
            end
		end

		clubSendData:requestJoinClub(data, callback)

	end
end

--请求解散联盟
function clubView:requestdissolveClub()
    local clubId = curSelectedClubId
    if  clubId == nil then
    	require("hall.GameTips"):showTips("提示", "", 3, "请选择一个"..group_name.."!")
    	return
    end

	local data={
	    owerId = USER_INFO["uid"],
	    groupId = clubId,
	}
	
	local function callback(returnCode, data)
        if returnCode == 0 then
        	require("hall.GameTips"):showTips("提示", "", 3, "解散"..group_name.."成功")
            clubView.room_list_plane:removeAllChildren()
			clubView:init()
        	clubView:requestClubList()
        else
        	require("hall.GameTips"):showTips("提示", "", 3, "解散"..group_name.."失败")
        end
	end

    clubSendData:requestdissolveClub(data, callback)

end

------------------------------------------------------------------------------------------------------

function clubView:init()
	self.setting_bt:setVisible(false)
	self.invitation_bt:setVisible(false)
	curSelectedClubId = nil
	clubListCache = nil
	self.game_config_text:setVisible(false)
	self.join_bt:setVisible(true)
	self.delete_bt:loadTextures("hall/view/clubview/images/newclub/AutoAtlas-2_87.png", nil, nil)
end

--------------------------------------------------房间相关对外接口-------------------------------------------
function clubView:refreshClubRooms(clubId)

	dump(clubId,"refreshClubRooms__clubId")

	--不在联盟界面的话则返回
	if 	tolua.isnull(my_club_scene) then
		return
	end

	if 	type(clubId) ~= "number" then
		return
	end

	dump(curSelectedClubId,"refreshClubRooms__curSelectedClubId")

end


--客户端预创建12张桌子
function clubView:initTables(beginIndex)

	beginIndex = beginIndex or 1
	if beginIndex == 1 then

		self.room_list_plane:removeAllChildren()
		for i = 1,math.ceil(12/(oneLineCount * oneColCount)) do
			local table_list_view = self.TableListView:clone()
			self:addPlaneTouchEvent(table_list_view)
			self.room_list_plane:addPage(table_list_view)
		end

	end

	local curGameConfig = curClubData:getFloorData().gameConfig
	dump(curGameConfig, "curGameConfig")
	
	local playerCountData = curGameConfig.maxSeatCount
	local playerCount 

	if playerCountData then
	 	playerCount = tonumber(playerCountData.optionValue)
	end

	if curGameConfig.gameId == 324 
		or curGameConfig.gameId == 325  
		then
		playerCount = 3
	elseif curGameConfig.gameId == 321 
		or curGameConfig.gameId == 326
		or curGameConfig.gameId == 327
		or curGameConfig.gameId == 328
		or curGameConfig.gameId == 329
		or curGameConfig.gameId == 333
		or curGameConfig.gameId == 319
		or curGameConfig.gameId == 320
		or curGameConfig.gameId == 308
		or curGameConfig.gameId == 309
		or curGameConfig.gameId == 301
		then

		playerCount = 4
	end

	-- dump(playerCount, "initTables-playerCount")
	------------------------------------
	for i = beginIndex, 12 do

		local pageIndex = i <= 6 and 0 or 1
		local table_list_view = self.room_list_plane:getItem(pageIndex)

		local room_list_item = table_list_view:getChildByTag(i)
		if room_list_item then
			room_list_item:removeFromParent()
		end

		room_list_item = getSuitTabledItem(playerCount or 8):addTo(table_list_view)
		room_list_item:setTag(i):setSwallowTouches(true):setPosition(getTablePos(i))

		local table_index_txt = room_list_item:getChildByName("table_index_txt"):setString(i)
		local gameConfig_txt = room_list_item:getChildByName("gameConfig_txt"):setVisible(false)
		local game_status = room_list_item:getChildByName("game_status"):setVisible(false)
		local player_panel = room_list_item:getChildByName("player_panel")

		self:updateItemContent(room_list_item, {})
		player_panel:addTouchEventListener(function(sender,event)

			if 	event == TOUCH_EVENT_BEGAN then
				sender:setScale(0.95)
			end

			if 	event == TOUCH_EVENT_CANCELED then
				sender:setScale(1)

			end
					
			if 	event == TOUCH_EVENT_ENDED then
				sender:setScale(1)

				if type(curGameConfig) == "table" then

					local txts = {}
					txts["title"] = "提示"
					txts["sureBt_txt"]  = "确定"
					txts["cancelBt_txt"] =  "取消"
					txts["msg"] = "是否加入" .. i .. "号桌？"

					local joincallback = function(data)
						local inviteCode = data.inviteCode
						local activityId = data.activityId
						local level = data.level
						dump(data, "joincallback")
						require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], inviteCode, activityId, true, level, false)
					end

					local createFunc = function()
						require(GroupSetting_filePath):create_agent(1, 1, 1, curGameConfig["level"], curGameConfig, curSelectedClubId, nil, joincallback)
					end

					local customfunc = {}
					customfunc["cancel_func"] = function() end
					customfunc["sure_func"]  = createFunc
					require("hall.GameTips"):showCustomTips(txts,customfunc,1)

				else

					local createFunc = function()
						require(CreateGroup_filePath):CreateScene(2,curSelectedClubId)
					end

					local txts = {}
					txts["title"] = "提示"
					txts["sureBt_txt"]  = "确定"
					txts["cancelBt_txt"] =  "取消"
					txts["msg"] = "此楼层无固定玩法，点击确定为这张桌子选择玩法"

					local customfunc = {}
					customfunc["cancel_func"] = function() end
					customfunc["sure_func"]  = createFunc
					require("hall.GameTips"):showCustomTips(txts,customfunc,1)
				end

			end

		end)

		-- require("hall.groudgamemanager"):
	end

end

-------------------------------handle数据接口
function clubView:saveTableData(data, typ)

    if 	tolua.isnull(my_club_scene) or tolua.isnull(self.room_list_plane) then
    	dump("当前不在联盟界面！")
        return
    end

    local _clubId = data[1] and data[1].club_id or -1

	if _clubId ~= curSelectedClubId then
		dump(_clubId, "更新的不是当前联盟的数据！")
		return
	end

	dump(typ, "saveTableData_typ")

	if typ == nil then
		curClubData:settableData(data)
	else
		curClubData:inserttableData(data)
	end

	-- dump(newTableData, "saveTableData_newTableData")
	self:loadClubRoomList()
end

--單個桌子数据协议的处理
function clubView:updateItemContent(item, userInfos)

	local player_panel = item:getChildByName("player_panel")

	dump(userInfos, "updateItemContent")
    for seat_id = 0,19 do

    	local i = seat_id + 1
        local head_img = player_panel:getChildByName("player_".. seat_id)

        if head_img then

	    	if userInfos[i] and json.decode(userInfos[i]) then

	    		local data = json.decode(userInfos[i])
		        local photoUrl = data.portrait

		        require("hall.GameCommon"):getUserHead(photoUrl, "", "", head_img, 50, false, "", true)
		        head_img:setTouchEnabled(false):setVisible(true)

		    else
		    	head_img:setVisible(false)
	    	end

    	else
    		break
    	end
    end
end

--桌子数据协议的处理
function clubView:loadClubRoomList(data)

	local data = curClubData:getTableData()

	if next(data) == nil  then
		self:initTables()
		return  dump("找不到当前桌子的数据")
	end

	dump(data,"loadClubRoomList_3")

	self:initTables(#data + 1)

	for i, v in ipairs(data) do

		-- local table_info = json.decode(v.table_info)
		local table_info = v.table_info
		local ownerInfo = table_info.creatorNickname
		local baseChip = table_info.baseChip or 0
		local inviteCode = table_info.inviteCode 

		local pageIndex = i <= 6 and 0 or 1
		local table_list_view = self.room_list_plane:getItem(pageIndex)

		local room_list_item = table_list_view:getChildByTag(i)
		if room_list_item then
			room_list_item:removeFromParent()
		end

		room_list_item = getSuitTabledItem(table_info.maxSeatCount):addTo(table_list_view)
		room_list_item:setTag(i):setSwallowTouches(true):setPosition(getTablePos(i))

		dump(v.table_id, "设置桌子ID")
		dump(i, "桌子INDEX")
		room_list_item.table_id = v.table_id

		local table_index_txt = room_list_item:getChildByName("table_index_txt"):setString(i)
		local gameConfig_txt = room_list_item:getChildByName("gameConfig_txt"):setVisible(false)
		local game_status = room_list_item:getChildByName("game_status"):setVisible(v and v.is_start ~= 0)
        local player_panel = room_list_item:getChildByName("player_panel")

       	self:updateItemContent(room_list_item, v.user_list)

       	local joinInfo = {inviteCode = table_info["inviteCode"], activityId = table_info["activityId"], level = v["level"]}
		player_panel:addTouchEventListener(function(sender, event)

			if 	event == TOUCH_EVENT_BEGAN then
				sender:setScale(0.95)
			end

			if 	event == TOUCH_EVENT_CANCELED then
				sender:setScale(1)

			end
					
			if 	event == TOUCH_EVENT_ENDED then
				sender:setScale(1)

				dump(joinInfo, "请求加入")

				local joinFunc = function()
					require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], joinInfo["inviteCode"], joinInfo["activityId"], true, joinInfo["level"], false)
				end

				local txts = {}
				txts["title"] = "提示"
				txts["sureBt_txt"]  = "确定"
				txts["cancelBt_txt"] =  "取消"
				txts["msg"] = "是否加入" .. i .. "号桌？"

				local customfunc = {}
				customfunc["cancel_func"] = function() end
				customfunc["sure_func"]  = joinFunc
				require("hall.GameTips"):showCustomTips(txts,customfunc,1)

			end
		end)
	end

	self.room_list_plane:setCurrentPageIndex(0)

	updateSwitchState()
end


--翻页容器的界面方法
function clubView:updateTableData(data, typ)

	-- dump(curClubData, "updateTableData")
	
    if 	tolua.isnull(my_club_scene) then
        return
    end
	
	-- local function removeRoomListPlane(n) 
	-- 	local plane = self.room_list_plane:getItem(n)
	--     if tolua.isnull(plane) == false then
	-- 		self.room_list_plane:removePage(plane)
	--     end
 --    end

    local _clubId = data.club_id

	dump(data, "updateTableData")

    if _clubId == nil then
    	return
    end

    _ClubData = allClubsData[_clubId]

	if  _ClubData == nil or next(_ClubData) == nil then 
		dump("updateTableData_ClubData数据不存在！")
		return
	end


	if _clubId ~= curSelectedClubId then
		dump("updateTableData更新的不是当前联盟的数据！")
		return
	end

    -- local tableData = _ClubData:getTableData() 

	if typ == 7 then   --解散

		curClubData:removeTableData(data["table_id"])
		self:loadClubRoomList()

	elseif typ >= 3 and typ <= 6 then   --用户退出

		local i, itemTableData = _ClubData:updateTable(data, typ)

		-- dump(itemTableData, "itemTableData")
		local findTimes = 0
		for _, table_list_view in pairs(self.room_list_plane:getChildren()) do
			for _, item in pairs(table_list_view:getChildren()) do

				findTimes = findTimes + 1
				print(findTimes, "finditemTableData")

				if item.table_id == data["table_id"] then
					dump(item.table_id, "itemTableData")
					self:updateItemContent(item, itemTableData.user_list)
					goto _end_
				end

			end

		end

		::_end_::
	end
end

 --可以为所有控件添加触摸事件
function clubView:addPlaneTouchEvent(node)

	local mousePosition

 	local function onTouchBegan(touch, event)

 		local toch_location = node:convertToNodeSpace(touch:getLocation())
 		local card_size = node:getContentSize()
 		local rect = cc.rect(0, 0, card_size.width, card_size.height)
 		--点击区域是否是对象区域内
 		if toch_location["x"] >= -1182 and toch_location["y"] >= 0 and toch_location["x"] <= 0 and toch_location["y"] <= 458 then
			mousePosition = toch_location
			return true
 		end
    end

     -- 触摸结束
    local function onTouchEnded(touch, event)

		local toch_location = node:convertToNodeSpace(touch:getLocation())
		local node_size = node:getContentSize()
		local rect = cc.rect(0, 0, node_size.width, node_size.height)
		 --点击区域是否是对象区域内

		local tableData = curClubData:getTableData()
		local maxIndex = #tableData

		SCENENOW["scene"]:performWithDelay(function()

			 local direction = ""
			 local currentPageIndex = 0
			 local toScrollPage = 0

	 		 if mousePosition["x"] > toch_location["x"] then

			 	direction = "left"
			 	currentPageIndex = 0
			 	toScrollPage = 1

				updateSwitchState("pre")

             elseif mousePosition["x"] < toch_location["x"] then

			 	direction = "right"
			 	currentPageIndex = 2
			 	toScrollPage = 1		

				updateSwitchState("next")

             elseif mousePosition["x"] == toch_location["x"] then
				
				updateSwitchState("next")

             end
			 ------------------------------------------------------------------------

		end,0)

    end

	local listener = cc.EventListenerTouchOneByOne:create()    ---- true不向下触摸，简单点来说，比如有两个sprite ,A和 B，A在上B在下（位置重叠），触摸A的时候，B不会受到影响,反之false，向下传递触摸，触摸A也等于触摸了B
	listener:setSwallowTouches(false)
	---- 注册两个回调监听方法
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()-- 事件派发器
	---- 绑定触摸事件到层当中
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener:clone(), node)

end
----------------------------------------------联盟成员----------------------------------------------
--请求查看联盟成员

function clubView:requestClubMembers(clubId,loadType)

	if  type(clubId) ~= "number" then
		require("hall.GameTips"):showTips("提示", "", 3, "请选择"..group_name.."!")
		return
	end

   	if  clubMemberCache[clubId] and loadType ~= "refresh" then
		self:loadClubMembers(clubMemberCache[clubId])
	
	else
		clubMemberCache[clubId] = nil
		data={groupId = clubId}

	    local function callback(returnCode, data)
           	if returnCode == 0 then
            	clubMemberCache[clubId] = data
       			self:loadClubMembers(data)
            end
	    end

	    clubSendData:requestClubMembers(data, callback)
	end
end


function clubView:loadClubMembers(data)
   
	if 	tolua.isnull(self.friends_lv) then
		return
	end

	self.friends_lv:removeAllChildren()
    ----栓除玩家事件----------------
	local deleteMember = function(sender,event)

        if  event == TOUCH_EVENT_ENDED then
        	local userId = tonumber(sender.userId)
        	dump(userId,"sender.userId1") --自己ID
            dump(curSelectedClubId,"curSelectedClubId") --当前联盟ID
        	self:requestDeleteMember(userId,curSelectedClubId)
        end
	end

	local players = data.players
	local owerId =  data.owerId
	
	if players == nil then return end
    

	for _,v in pairs(players) do
		local uid = v.userId
		local nickName = v.nickName
		local photoUrl = v.photoUrl
        
		local friends_item = self.friends_item:clone()
		self.friends_lv:pushBackCustomItem(friends_item)
        -----------------标签------------------
		local friendName_txt = friends_item:getChildByName("friendName_txt"):setString(nickName)
		local friendUid_txt = friends_item:getChildByName("friendUid_txt"):setString(uid)
		local head_img = friends_item:getChildByName("head_img"):setTouchEnabled(false)
		local club_manager_flag  = friends_item:getChildByName("club_manager_flag")
		---------栓除标签-----------------------
		local delete_img = friends_item:getChildByName("delete_img")

		friends_item.userId = uid
		delete_img.userId = uid

		require("hall.view.headView.headView"):addView(head_img,65,20, 68, 68, photoUrl)

		delete_img:addTouchEventListener(deleteMember)
		-- friends_item:addTouchEventListener(pressEvent)

		club_manager_flag:setVisible(tonumber(uid) == owerId)

		if USER_INFO["uid"] ~= owerId or tonumber(uid) == owerId then
			delete_img:setVisible(false)
		end

	end
end


function clubView:requestDeleteMember(userId, clubId)

	if  type(clubId) ~= "number" then
		require("hall.GameTips"):showTips("提示", "", 3, "请选择"..group_name.."!")
		return
	end

	dump(userId,"requestDeleteMember_userId")
	dump(clubId,"requestDeleteMember_clubId")

	local data = {
		playerId = userId;
        owerId = USER_INFO["uid"];
        groupId  = clubId;
    }

    local function callback(returnCode, data)
    	if returnCode == 0 then
	    	require("hall.GameTips"):showTips("提示", "", 3, "删除玩家成功！")
	    	self:requestClubMembers(clubId, "refresh")
	    end
    end

    clubSendData:requestDeleteMember(data, callback) 
end

----------------------------------消息相关
--请求查看新消息
function clubView:requestJoinNews(type)

	if 	tolua.isnull(my_club_scene) then
		return
	end

	dump("请求查看新消息")
	type = type or 0

    local data = {
        playerId = USER_INFO["uid"],
		status = type
    }

    local function callback(returnCode, data)
    	if returnCode == 0 then
			self:updateNews(data, type)
			self:showNews(type)
		end
	end

	clubSendData:requestJoinNews(data, callback)
end

function clubView:updateNews(data, type)

	if 	tolua.isnull(my_club_scene) then
		return
	end

	if type == 0 then 

		if curClubData then
			curClubData:setclubNews({}, "clear")
		end

		local news_tbl = {}
		for _, new in ipairs(data) do
			local groupId = new["groupId"]
			news_tbl[groupId] = news_tbl[groupId] or {}
			table.insert(news_tbl[groupId], new)
		end

		for groupId, news in pairs(news_tbl) do
			local _ClubData = allClubsData[groupId]
			-- dump(_ClubData.clubNews, "updateNews_ClubData")
			if _ClubData and type == 0 then
				_ClubData:setclubNews(news, type)
				-- dump(_ClubData.clubNews, "updateNews_ClubData")
			else

			end
		end
	else
		invitation_news = data
	end

 	dump(data,"updateNews")
 	local news_count = 0
 	if type == 5 then
 		news_count = #data
 	else
 		news_count = curClubData and #curClubData:getclubNews(type) or 0
 	end

	local news_num = (type == 5 and self.invitationList_bt or self.apply_bt):getChildByName("news_num")
	local news_num_txt = (type == 5 and self.invitationList_bt or self.apply_bt):getChildByName("news_num_txt")

	news_num:setVisible(news_count > 0)
	news_num_txt:setVisible(news_count > 0)
	news_num_txt:setString(news_count)

end

function clubView:showNews(type)

	if tolua.isnull(my_club_scene) then
		return
	end

	local news
	if  type == 5 then
		news = invitation_news
	elseif curClubData then
		news = curClubData:getclubNews(type)
	end

	dump(curClubData, "showNews_ClubData")

	-- dump(news,"showNews")
	dump(type,"showNews_type")

	local applyer_list_lv = self.applyer_list_plane:getChildByName("applyer_list_lv")
	local applyer_list_item = self.applyer_list_plane:getChildByName("applyer_list_item")
	local applyer_list_mask = self.applyer_list_plane:getChildByName("applyer_list_mask")

	self.applyer_list_plane:getChildByName("room_list_top"):getChildByName("Text_1"):setString( type == 0 and "申请者" or "邀请者")
	applyer_list_lv:removeAllChildren()

	if  news == nil or tolua.isnull(my_club_scene) then
		return
	end

	for i,v in pairs(news) do

		local applyer_list_item = applyer_list_item:clone():setVisible(true)
		applyer_list_lv:pushBackCustomItem(applyer_list_item)

		local applyerName_txt = applyer_list_item:getChildByName("applyerName_txt")
		local applyerHead = applyer_list_item:getChildByName("applyerHead")
		local refuse_bt = applyer_list_item:getChildByName("refuse_bt")
		local invite_bt = applyer_list_item:getChildByName("invite_bt")

		local uid = v.playerId
		local clubId = v.groupId
		local nickName = v.nickName
		local photoUrl = v.photoUrl

		require("hall.GameCommon"):getUserHead(photoUrl, uid, 1, applyerHead, 55, false, nickName)
		applyerHead:setTouchEnabled(false)
		applyerName_txt:setString(nickName)

		if type == 5 then
			local groupName = v.groupName
			if groupName ~= nil then
				applyerName_txt:setString(nickName.."邀请我加入："..groupName)
			else
				applyerName_txt:setString(nickName.."邀请我加入联盟")
			end
		end

		invite_bt:onClick(function()  
			if type == 0 then
				self:replyRequestJoinClub(uid,clubId,1,0)
			else
				self:replyRequestJoinClub(uid,clubId,6,5)
			end
		end) 

		refuse_bt:onClick(function()  
			if type == 0 then
				self:replyRequestJoinClub(uid,clubId,3,0)
			else
				self:replyRequestJoinClub(uid,clubId,7,5)
			end
		end) 

	end


end

--回复成员请求加入联盟/回复被邀请加入俱end乐部
function clubView:replyRequestJoinClub(uid,clubId,status,type)

	print(uid,clubId,status,type, "replyRequestJoinClub")

    local function callback(returnCode, data)

		self:requestJoinNews(type)

	    if returnCode == 0 then
	    	clubMemberCache[clubId] = nil
	    	require("hall.GameTips"):showTips("提示", "", 3, "已回复该玩家！") 
	    elseif returnCode == 2 or returnCode == 1 then
			require("hall.GameTips"):showTips("提示", "", 3, "玩家已经在该联盟中！")
		else
			dump(data,"returnCode不为0，联盟")
		end 
	end

	if type == 5 then

		local data={
            playerId = USER_INFO["uid"] ,
            owerId = uid,
            groupId = clubId,
            status = status,
			playerId1 = uid
        }

    	clubSendData:requestReplyInvite(data, callback)
	else

		local data={
            playerId = uid,
            owerId = USER_INFO["uid"],
            groupId = clubId,
            status = status,
			playerId1 =  USER_INFO["uid"] 
        }

    	clubSendData:requestReplyJoinClub(data, callback)
    end

end


--请求退出联盟
function clubView:requestQuitClub(clubId)
    local clubId = clubId or curSelectedClubId

    if  clubId == nil then
    	require("hall.GameTips"):showTips("提示", "", 3, "请选择一个"..group_name.."!")
    	return
    end

    local data = {
	    playerId = USER_INFO["uid"],
	    groupId = clubId
	}

	local function callback(returnCode, data)
	    if returnCode == 0 then
	    	require("hall.GameTips"):showTips("提示", "", 3, "成功退出"..group_name)
	    	clubView:requestClubList()
	    else
	    	require("hall.GameTips"):showTips("提示", "", 3, "退出"..group_name.."失败")
	    end
	end

    clubSendData:requestQuitClub(data, callback)

end

-------------------------------------------------------------------------------------------------
function clubView:removeScene()
	local clubScene = SCENENOW["scene"]:getChildByName("clubView")
    if  clubScene then
    	clubScene:removeFromParent()
    	-- clubView = nil 
    	-- package.loaded["hall.view.clubView.clubView"] = nil
    	SCENENOW["scene"]:refreshHallRoomList()
    	allClubsData = {}
		curClubData = nil
		collectgarbage("collect")
    end
end

return  clubView