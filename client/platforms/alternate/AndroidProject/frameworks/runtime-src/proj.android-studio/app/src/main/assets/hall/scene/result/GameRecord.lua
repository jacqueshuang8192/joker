--
-- Author: zhanghongpeng
-- Date: 2017-07-29 15:19:08


local GameRecord = class("GameRecord")

local interfaceGroupRecord = {}

local activity_id

local IsReload = false   --重登或者新一局后重新加载界面的标记

local record_plane
local roundrecord_plane   --组局数据
local roundrecord_detail  --单回合详细数据
local grouprecord_bt    --战绩流水按钮

local win_round_count = {}   --胜场数
local total_round_count = {}     --总赛场数

-- GroupData[round_index].content  --JSON数据
						-- [[content.userinfos
								-- userinfos.uid
								-- userinfos.sex
								-- userinfos.photo_url
								-- userinfos.nickName
								-- userinfos.score]]

-- GroupData数据格式
--[[GroupData[round_index][uid].cards    手牌，可以为精灵或图片（存入时最好克隆并使用retain方法，不然local的控件会被销毁）
	GroupData[round_index][uid].desc_txt   文字格式的番数   选传
	GroupData[round_index][uid].desc_pic   图片格式的番数    
	GroupData[round_index].banker_uid  庄家的UID]]   

function GameRecord:addView(view,GroupData,gameType,current_round)

	local 	view = view or SCENENOW["scene"]
    local 	s = view:getChildByName("GameRecord")
            
    --预留给游戏内传来的组局总数据  
 --    if GroupData[current_round] and interfaceGroupRecord[round_index].content then
 --    	interfaceGroupRecord = GroupData
	-- end

			if 	activity_id ~= USER_INFO["activity_id"]  then   --组局切换时或者重连时数据初始化
				interfaceGroupRecord = {}
				activity_id = USER_INFO["activity_id"]
				gameType = gameType or "poker"
                win_round_count = {}
                total_round_count = {}

				if s then
					s:removeFromParent()
				end
			end
    
            if not s or tolua.isnull(s) then
		     	s =  cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/gameResult/GameRecord.csb"):addTo(view)
	    	  	s:setName("GameRecord")
	    	  	IsReload = true
	    	else
	    		s:setVisible(true)
	    		IsReload = false
	    	end

		    local   current_round = current_round or 0
		    local   GroupData = GroupData or {}
		    dump(GroupData,"游戏传来的组局总数据")
    
 		 	record_plane = s:getChildByName("record_plane")

    	 	grouprecord_bt = record_plane:getChildByName("grouprecord_bt")
    		grouprecord_bt:addTouchEventListener(
		        function(sender,event)

		            --触摸结束
		            if event == TOUCH_EVENT_ENDED then
		                sender:setScale(1.0)
                        self:switchRoundandGroup("toGroupRecord")
		            end
		        end)  

    
    local 	close_bt = record_plane:getChildByName("close_bt")
		    close_bt:addTouchEventListener(
		        function(sender,event)

		            --触摸结束
		            if event == TOUCH_EVENT_ENDED then
		                sender:setScale(1.0)
                        self:removeView(view)
		            end
		        end)  


    	 	roundrecord_plane = record_plane:getChildByName("roundrecord_plane")
			roundrecord_plane:setVisible(true)

	local 	roundrecord_cell = record_plane:getChildByName("roundrecord_cell")
	        local 	round_count_pic = roundrecord_cell:getChildByName("round_count_pic")
	        		local 	round_count = round_count_pic:getChildByName("round_count")

		 	roundrecord_detail = record_plane:getChildByName("roundrecord_detail")
			roundrecord_detail:setVisible(false)
	local 	detail_cell = record_plane:getChildByName("detail_cell")    

    		self:switchRoundandGroup("toGroupRecord")   --设置战绩流水按钮为按下状态
     

    local function showRecord(interfaceGroupRecord)
        --滚动容器要用setInner,getInner方法
        
		roundrecord_plane:setInnerContainerSize(cc.size(roundrecord_plane:getSize().width,(roundrecord_cell:getSize().height + 15) * table.getn(interfaceGroupRecord)))
        -- roundrecord_plane:removeAllChildren()
        local 	has_draw_round = 0
        for _,child in ipairs(roundrecord_plane:getChildren()) do
        	local  round_index = child:getTag()
        	has_draw_round = has_draw_round + 1
		    child:setPositionY(roundrecord_plane:getInnerContainerSize().height - (round_index-1)*(child:getSize().height+15)-5)      
        end

        dump(interfaceGroupRecord, "interfaceGroupRecord")

	    for i,v in ipairs(interfaceGroupRecord) do   --interfaceGroupRecord可能为空数组，必须用ipairs
       
            while true do 

		    	if  i <= has_draw_round and IsReload == false then  
		    		break
		    	end    

	    	    local   round_data = v

	    	    local   round_index = i
      
	            local  	content = json.decode(round_data["content"])

		    	local 	roundrecord_cell = roundrecord_cell:clone()

						local 	round_count_pic = roundrecord_cell:getChildByName("round_count_pic")
								local 	round_count = round_count_pic:getChildByName("round_count")

		    	        local 	player_1 =  roundrecord_cell:getChildByName("player_1")
	        			local 	player_2 =  roundrecord_cell:getChildByName("player_2")
	        			local 	player_3 =  roundrecord_cell:getChildByName("player_3")
	        			local 	player_4 =  roundrecord_cell:getChildByName("player_4")
	        			local 	player_5 =  roundrecord_cell:getChildByName("player_5")


	        			local 	player_widget_array =	{  
	        					   	[1] = player_1,
	                               	[2] = player_2,
	                               	[3] = player_3,
	                              	[4] = player_4,
	                               	[5] = player_5 }

		    	roundrecord_plane:addChild(roundrecord_cell) 

		    	roundrecord_cell:setPositionY(roundrecord_plane:getInnerContainerSize().height - (round_index-1)*(roundrecord_cell:getSize().height+15)-5)    
                
                roundrecord_cell:setTag(round_index)

	            round_count:setString(round_index)
	                 
	            local playerCount = #content.userinfos or 5

	            for _i,_v in ipairs(content.userinfos) do
  
		            local player = player_widget_array[_i]

					if _v then
                        		
						player:setVisible(true)
	                    
	                    local   FullNickName = _v["nickName"] or "昵称未知"
	                    local   uid = _v["uid"] or 10000
						local   sex = _v["sex"] or 1
						local   photo_url = _v["photo_url"] or ""

						local 	nickName =  require("hall.GameCommon"):formatNick(FullNickName, 2) 
						local 	nick = player:getChildByName("nick")
								nick:setString(nickName)
						local   score = player:getChildByName("score")
						        score:setString(_v["score"])

						        total_round_count[uid] = (total_round_count[uid] or 0) + 1

						        if _v["score"] > 0 then
						        	win_round_count[uid] = (win_round_count[uid] or 0)+ 1
						        end

						player:setPositionX((750/(playerCount))*(_i-1) + 85)

						require("hall.GameCommon"):getUserHead(photo_url, uid, sex, player, 58, false, FullNickName)

					end
				end
             
				roundrecord_detail:setInnerContainerSize(cc.size(roundrecord_detail:getSize().width,(detail_cell:getSize().height + 20) *playerCount*2))
                roundrecord_cell:setTouchEnabled(true)
				roundrecord_cell:addTouchEventListener(
			        function(sender,event)

			            --触摸结束
			            if event == TOUCH_EVENT_ENDED then 
			            	if 	GroupData[round_index] then
			            		self:switchRoundandGroup("toRoundDetail")
                              	self:showRoundResult(round_index,round_data,gameType,win_round_count,total_round_count,GroupData)
        					else
        						dump(round_index,"要查看的是哪个回合")
        						dump(GroupData,"要查看的是哪个回合")
        						dump(GroupData[round_index],"要查看的是哪个回合")

           				 		require("hall.GameTips"):showTips("提示", "", 3, "无法查看更多信息")
           					end
			            end

			        end)

				break
			end  --end while
		end --end for 
	end  --en function

    if 	#interfaceGroupRecord < current_round then

			local params = {}
			params["activityId"] = USER_INFO["activity_id"] or 10000
			params["interfaceType"] = "J"
			cct.createHttRq({

				url = HttpAddr .. "/freeGame/querRoundsByActivityId",
				date = params,
				type_ = "POST",
				callBack = function(data)
                
                data_netData = json.decode(data["netData"])
                
				if data_netData.returnCode == "0" then

                    interfaceGroupRecord =  data_netData.data

				    local function SortbyRoundIndex(a,b)
				      	return a.roundIndex < b.roundIndex
				    end

				    table.sort(interfaceGroupRecord,SortbyRoundIndex)
                    
                    local s = view:getChildByName("GameRecord")
                    if 	s then
                		showRecord(interfaceGroupRecord)
                	end
				end
          
			end})

	else
        showRecord(interfaceGroupRecord)
	end

end

function GameRecord:showRoundResult(round_index,round_data,gameType,win_round_count,total_round_count,GroupData)
    	
		local  	content = json.decode(round_data["content"])
		dump(content,"单回合数据")

		roundrecord_detail:removeAllChildren()

	    for _i,_v in ipairs(content.userinfos) do

		local 	detail_cell = record_plane:getChildByName("detail_cell"):clone()
				local 	index = detail_cell:getChildByName("index")
				local 	nick = detail_cell:getChildByName("nick")
				local 	head = detail_cell:getChildByName("head")
						local 	zhuang_flag = head:getChildByName("zhuang_flag")
				local 	win_round = detail_cell:getChildByName("win_round_count")
				local  	total_round = detail_cell:getChildByName("total_round_count")
				local 	score = detail_cell:getChildByName("score")
                
				local 	majiang_card_info = detail_cell:getChildByName("majiang_card_info")
				local 	poker_card_info = detail_cell:getChildByName("poker_card_info")

				local   current_info = poker_card_info

						local 	bg_img = poker_card_info:getChildByName("bg_img")
		                local 	card_plane = poker_card_info:getChildByName("card_plane")
		                local 	desc_lb = poker_card_info:getChildByName("desc_lb")
		                local 	desc_pic = poker_card_info:getChildByName("desc_pic")
						
				 		if  gameType =="majiang" then 
                               
                                current_info = majiang_card_info
				 				majiang_card_info:setVisible(true)
								bg_img = majiang_card_info:getChildByName("bg_img")
								card_plane = majiang_card_info:getChildByName("card_plane")
								desc_lb = majiang_card_info:getChildByName("desc_lb")
								desc_pic = majiang_card_info:getChildByName("desc_pic")

				 		elseif  gameType =="poker" then 

                                current_info = poker_card_info
				 				poker_card_info:setVisible(true)
					        	bg_img = poker_card_info:getChildByName("bg_img")
								card_plane = poker_card_info:getChildByName("card_plane")
								desc_lb = poker_card_info:getChildByName("desc_lb")
								desc_pic = poker_card_info:getChildByName("desc_pic")

						end
                
                roundrecord_detail:addChild(detail_cell,99-_i)
                detail_cell:setTouchEnabled(false) 

				detail_cell:addTouchEventListener(
			        function(sender,event)

			            --触摸结束
			            if 	event == TOUCH_EVENT_ENDED then 

			            	if current_info:getPosition().y >34 then
								local target_pos = cc.p(current_info:getPosition().x, -50)
								local action_move = cc.MoveTo:create(0.3,target_pos)
								local sum_action = cc.Spawn:create(action_move)
								current_info:runAction(sum_action)
	                            current_info:setVisible(true)
	                        else
								local target_pos = cc.p(current_info:getPosition().x, 41)
								current_info:setPosition(target_pos)
								current_info:setVisible(false)
	                        end

			            end

			        end)
             

			    bg_img:setTouchEnabled(false)
			    bg_img:setVisible(true)
				bg_img:addTouchEventListener(
			        function(sender,event)

			            --触摸结束
			            if 	event == TOUCH_EVENT_ENDED then 
							local target_pos = cc.p(current_info:getPosition().x, 41)
							current_info:setPosition(target_pos)
                            current_info:setVisible(false)

			            end

			        end)

	        local   FullNickName = _v["nickName"] or "昵称未知"
            local   uid = _v["uid"] or 10000
			local   sex = _v["sex"] or 1
			local   photo_url = _v["photo_url"] or ""
                     
                    index:setString(_i)
					nick:setString(FullNickName)
                    
                    if _v["score"]>=0 then
                       _v["score"] = "+".._v["score"]
                       score:setColor(cc.c3b(0xff,0,0))
                   	else
                   	   _v["score"] = "-"..math.abs(_v["score"])
                       score:setColor(cc.c3b(0x15,0xf5,0x15))
                    end  

			        score:setString(_v["score"])
			        win_round:setString(win_round_count[uid] or "0")
			        total_round:setString(total_round_count[uid])

			        dump(GroupData[round_index][uid],"用户数据")
			        dump(uid,"用户UID")
                     
			        -- --画牌和显示番数               
                    if GroupData[round_index][uid] then
				        if GroupData[round_index][uid].cards then
				        	for i,v in ipairs(GroupData[round_index][uid].cards) do
				        		if not tolua.isnull(v) then
				        			card_plane:addChild(v)
				        		end
				        	end
				        end
                        
                        desc_lb:setVisible(false)
				        if GroupData[round_index][uid].desc_txt then 
                        	desc_lb:setVisible(true) 	
	                       	desc_lb:setString(GroupData[round_index][uid].desc_txt)
				        end

                        desc_pic:setVisible(false)			     
				        if GroupData[round_index][uid].desc_pic then
                        	desc_pic:setVisible(true)			     
	                       	desc_pic:loadTexture(GroupData[round_index][uid].desc_pic)
				        end 
				    end

				    if GroupData[round_index].banker_uid == uid  then
				    	zhuang_flag:setVisible(true)
				    end

			detail_cell:setPositionY(roundrecord_detail:getInnerContainerSize().height - (_i-1)*(detail_cell:getSize().height+20)*2)  

			require("hall.GameCommon"):getUserHead(photo_url, uid, sex, head, 78, false, FullNickName)

		end  		
end


function GameRecord:switchRoundandGroup(flag)
	if flag == "toRoundDetail" then
		roundrecord_plane:setVisible(false)
		roundrecord_detail:setVisible(true)
		grouprecord_bt:setBrightStyle(0)
    	grouprecord_bt:setTouchEnabled(true)

	elseif flag == "toGroupRecord" then
		roundrecord_plane:setVisible(true)
		roundrecord_detail:setVisible(false)
		grouprecord_bt:setBrightStyle(1)
    	grouprecord_bt:setTouchEnabled(false)
	end
end


function GameRecord:removeView(view)

	if view then

		local s = view:getChildByName("GameRecord")
	    if s then
	        s:setVisible(false)
	    end	

	end

end

return GameRecord
