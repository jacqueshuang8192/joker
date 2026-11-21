--
-- Author: zhang hongpeng
-- Date: 2017-05-06 15:28:11
--
local Recommend = class("Recommend")

local playlistcacheState = 0

local fangka_count_lb

function Recommend:showView()
    dump("加载成功")
  	local s
  	local path = RecommendCsb_filePath
    if device.platform == "ios" then
        if isiOSVerify then
            s = cc.CSLoader:createNode(path)
        else
            s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. path)
        end
    else
        s = cc.CSLoader:createNode(path)
    end
    
    s:setName("Recommend")
    SCENENOW["scene"]:addChild(s)
    
    local floor = s:getChildByName("floor")
    local close_bt = floor:getChildByName("close_bt")
    close_bt:addTouchEventListener(
        function(sender,event)

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                s:removeSelf()
                playlistcacheState = 0
            end
        end
    )
    

---------------------------------------------控件注册--------------------------------------
          fangka_count_lb = floor:getChildByName("fangka_count_lb")

    local MyRecommender_bt =  floor:getChildByName("MyRecommender_bt") --一级按钮
          local binding = floor:getChildByName("binding")    --一级容器
                local has_not_binding = binding:getChildByName("has_not_binding")    --二级容器
                      local binding_bt = has_not_binding:getChildByName("binding_bt")
                      local binding_input = has_not_binding:getChildByName("binding_input")
              
                local bindingsuccess = binding:getChildByName("bindingsuccess")                    --二级容器
                      local nickname = bindingsuccess:getChildByName("nickname")
                      local uid = bindingsuccess:getChildByName("uid")
                      local head = bindingsuccess:getChildByName("uid")
                      local Receive_card_bt = bindingsuccess:getChildByName("Receive_card_bt")
                            Receive_card_bt:setVisible(false)

-----------------------------------------------------------------------------------------------------
    local Recommended_byme_bt = floor:getChildByName("Recommended_byme_bt")  --一级按钮

    local binding_to_me =  floor:getChildByName("binding_to_me")  --一级容器

          local playerlist_sv = binding_to_me:getChildByName("playerlist_sv")   --二级滚动容器
          local player  = binding_to_me:getChildByName("player")  

          local txt_has_list =  binding_to_me:getChildByName("txt_has_list")

          local wx_bt = binding_to_me:getChildByName("wx_bt")     --二级按钮     
          local pyq_bt= binding_to_me:getChildByName("pyq_bt")    --二级按钮

-----------------------------------------事件添加--------------------------------------------
        local function btn_state(from)
                if from == "MyRecommender_bt" then 
                    MyRecommender_bt:loadTextures("hall/scene/res/"..resFolder.."/image/Recommend/yaoqingyouli_bt02.png",nil,nil)
                    Recommended_byme_bt:loadTextures("hall/scene/res/"..resFolder.."/image/Recommend/yaoqingyouli_bt01.png",nil,nil)
                    binding:setVisible(true)
                    binding_to_me:setVisible(false)
                    -- has_not_binding:setVisible(true)
                    -- bindingsuccess:setVisible(false)
                elseif from == "Recommended_byme_bt" then 
                    Recommended_byme_bt:loadTextures("hall/scene/res/"..resFolder.."/image/Recommend/yaoqingyouli_bt02.png",nil,nil)
                    MyRecommender_bt:loadTextures("hall/scene/res/"..resFolder.."/image/Recommend/yaoqingyouli_bt01.png",nil,nil)
                    binding:setVisible(false)
                    binding_to_me:setVisible(true)
                end

             end 
            
        USER_INFO["agentId"] = USER_INFO["uid"]
        USER_INFO["agentName"] = USER_INFO["nick"]

        local function getUserInfo()

            local table = {}
            table['userId'] = tonumber(USER_INFO["uid"])

            cct.createHttRq({
            url = HttpAddr .. "/playerUser/getUserInfo4GameServer",
            date = table,
            type_= "POST",
            callBack = function(data)
            local netData = json.decode(data["netData"]) 
            dump(netData,"----------用户数据----------")
            if netData.returnCode == "0" then
                local data = netData.data  
                 
                local receive_room_card = data.yaoqingRoomcards or 0

                
                if tolua.isnull(fangka_count_lb) then
                    return
                end

                fangka_count_lb:setString(receive_room_card)
                 
                 if  data.promoterId then
                   local  promoterId = data.promoterId
                   local  promoterName = data.promoterName
                   local  smallIcon = data.smallIcon

                   nickname:setString(promoterName)
                   uid:setString(promoterId)
                   require("hall.view.headView.headView"):addView(head, -40, 30, 80, 80, smallIcon)

                   has_not_binding:setVisible(false)
                   bindingsuccess:setVisible(true)

                 else

                   has_not_binding:setVisible(true)
                   bindingsuccess:setVisible(false)

                 end
            end


            end
            })

        end
        
        getUserInfo()

        MyRecommender_bt:addTouchEventListener(function(sender,event) 

                if  event == TOUCH_EVENT_ENDED then
                    btn_state("MyRecommender_bt")


                    --查询是否已经绑定接口
                  local table = {}
                        table['userId'] = tonumber(USER_INFO["uid"])

                        cct.createHttRq({
                        url = HttpAddr .. "/playerUser/getUserInfo4GameServer",
                        date = table,
                        type_= "POST",
                        callBack = function(data)
                        local netData = json.decode(data["netData"]) 
                        dump(netData,"----------用户数据----------")
                        if netData.returnCode == "0" then
                            local data = netData.data  
                             
                            local receive_room_card = data.yaoqingRoomcards or 0

                            if tolua.isnull(fangka_count_lb) then
                                return
                            end

                            fangka_count_lb:setString(receive_room_card)
                             
                             if  data.promoterId then
                               local  promoterId = data.promoterId
                               local  promoterName = data.promoterName
                               local  smallIcon = data.smallIcon

                               nickname:setString(promoterName)
                               uid:setString(promoterId)
                               require("hall.view.headView.headView"):addView(head, -40, 30, 80, 80, smallIcon)

                               has_not_binding:setVisible(false)
                               bindingsuccess:setVisible(true)

                             else

                               has_not_binding:setVisible(true)
                               bindingsuccess:setVisible(false)

                             end
                        end


                        end
                        })
                end

          end)
                 

                binding_bt:addTouchEventListener(function(sender,event) 

                if  event == TOUCH_EVENT_ENDED then
                    
                    --绑定接口
                    local table={}
                          table["userId"] = USER_INFO["uid"]
                          table["promoterId"] = binding_input:getString() or ""

                          if table["promoterId"] == "" then
                             require(CommonTips_filePath):showTips("提示", "", 3, "请输入推荐者ID！")
                             return
                          end

                        cct.createHttRq({
                        url = HttpAddr .. "/userBindingPromoter",
                        date = table,
                        type_= "POST",
                        callBack = function(data)
                        local netData = json.decode(data["netData"])                   
                        dump(netData,"----绑定返回------")
                            if netData.returnCode == "0" then
                                require(CommonTips_filePath):showTips("提示", "", 3, "恭喜您绑定成功！您已成功获得房卡")
                                if not has_not_binding then
                                   return
                                end
                                
                                require(GameScene_filePath):queryRoomCardCount()

                                has_not_binding:setVisible(false)
                                bindingsuccess:setVisible(true)
                                s:removeSelf()
                            else
                                require(CommonTips_filePath):showTips("提示", "", 3, "绑定失败！")
                            end

                        end
                        })

                end

                end)   --) end addTouchEventListener
------------------------------------------------------------------------------------------
          Recommended_byme_bt:addTouchEventListener(function(sender,event) 

            if  event == TOUCH_EVENT_ENDED then
                btn_state("Recommended_byme_bt")

                if playlistcacheState ==0 then

                txt_has_list:setVisible(true)

                local table={}
                      table["userId"] = USER_INFO["uid"]
                   
                    --我推荐的玩家列表接口
                    cct.createHttRq({
                    url = HttpAddr .. "/queryPromoterList",
                    date = table,
                    type_= "POST",
                    callBack = function(data)
                    dump(data,"----我推荐的玩家列表返回------")
                    local netData = json.decode(data["netData"])
                        if netData and netData.returnCode == "0" then
                            
                            local data = netData.data
            
                            if tolua.isnull(playerlist_sv) or (not data) or next(data)==nil then
                                return
                            end

                            txt_has_list:setVisible(false)

                            if #data>3 then
                               playerlist_sv:setInnerContainerSize(cc.size(702,math.ceil(#data)/3*270+100))
                            end

                            for i,v in pairs(data) do
                            local  player = player:clone()

                            if tolua.isnull(player) then 
                                return 
                            end
                                   
                                   playlistcacheState = 1
                                   playerlist_sv:addChild(player)
                                   player:setPositionY(-i*(player:getSize().height+5)+playerlist_sv:getInnerContainerSize().height+50)
                                   self:showBinding_to_me_list(v,player)
                            end

                        end

                    end  --end function
                    })

                 end
            end

            end)   --) end addTouchEventListener

            --分享接口
            wx_bt,pyq_bt=require(Share_filePath):showShareLayerForBinding(appName, "", "url", "输入我的推荐号码"..tostring(USER_INFO["agentId"])..",即可免费领取房卡！",wx_bt,pyq_bt)

end


function Recommend:showBinding_to_me_list(data,player)
     
      dump(data, "---------用户单次数据-------")

      local nick_txt = data.userName or ""
      local uid_txt = data.userId  or 0
      -- local has_experience_state = player.has_experience or false
      local Receive_state = data.isGetRoomcards or 0

      local nickname = player:getChildByName("nickname")  
            nickname:setString(nick_txt)
      local uid = player:getChildByName("uid")
            uid:setString(uid_txt)
      local has_experience = player:getChildByName("has_experience")
            has_experience:setString("已绑定")

      local Receive_card_bt = player:getChildByName("Receive_card_bt")
      local Receive_txt = Receive_card_bt:getChildByName("Receive_txt")
            if  Receive_state == 0 then 
                Receive_card_bt:loadTextures("hall/scene/res/"..resFolder.."/image/Recommend/join_green_bt.png",nil,nil)
                Receive_txt:setString("未领取")
                Receive_card_bt:addTouchEventListener(function(sender,event)          

                    if  event == TOUCH_EVENT_ENDED then

                      --绑定接口
                      local table={}
                          table["userId"] = uid_txt

                          cct.createHttRq({
                          url = HttpAddr .. "/getRoomcard",
                          date = table,
                          type_= "POST",
                          callBack = function(data)
                          local netData = json.decode(data["netData"])                   
                          dump(netData,"----绑定返回------")
                              if netData.returnCode == "0" then
                                  require(CommonTips_filePath):showTips("提示", "", 3, "成功获得房卡！再接再厉")
                                  
                                  if tolua.isnull(Receive_card_bt) then 
                                      return
                                  end
                                   
                                  local receive_room_card = tonumber(netData.data.yaoqingRoomcards)


                                  if receive_room_card and (not tolua.isnull(fangka_count_lb)) then
                                     fangka_count_lb:setString(tonumber(fangka_count_lb:getString())+ receive_room_card)
                                  end 
                                  
                                  Receive_card_bt:loadTextures("hall/scene/res/"..resFolder.."/image/Recommend/yaoqingyouli_text_yilingqu.png",nil,nil)
                                  Receive_txt:setString("")
                                  Receive_state = 1
                                  require(GameScene_filePath):queryRoomCardCount()
                              else
                                  require(CommonTips_filePath):showTips("提示", "", 3, "领取失败")
                              end

                          end
                          })

                end
                end)

            elseif Receive_state == 1 then
                Receive_txt:setString("")
                Receive_card_bt:loadTextures("hall/scene/res/"..resFolder.."/image/Recommend/yaoqingyouli_text_yilingqu.png",nil,nil)
                Receive_card_bt:setTouchEnabled(false)
            end

end


function Recommend:removeScene()
   local s =SCENENOW["scene"]:getChildByName("Recommend")  
   if (not tolua.isnull(s)) then
       s:removeSelf()
   end
end

return Recommend