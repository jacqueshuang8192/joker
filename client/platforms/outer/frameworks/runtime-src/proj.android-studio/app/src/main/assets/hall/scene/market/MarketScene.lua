local MarketScene = class("MarketScene")

local datas = 0
local points = 0   --积分
local isShow = false


function MarketScene:showMarketScene()

	 --获取界面
    isShow = true
    local MarketSceneCsb = cc.CSLoader:createNode(MarketCsb_filePath)
    SCENENOW["scene"]:addChild(MarketSceneCsb)
    --获取滚动容器
    local market_list = MarketSceneCsb:getChildByName("market_list")
    --获取兑换记录
    local market_record = MarketSceneCsb:getChildByName("market_record")
    --获取兑换说明 
    local market_exppain = MarketSceneCsb:getChildByName("market_exppain")
    --获取积分
    local market_integral = MarketSceneCsb:getChildByName("market_integral")
    local market_text = market_integral:getChildByName("market_text")
    --获取背景
    local bg = MarketSceneCsb:getChildByName("bg")

     self.sene_=MarketSceneCsb


    local function touchButtonEvent(sender,event)
        
            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                if sender == market_exppain then
                      self:Exppain ()
                end
               if  sender == bg then
                    isShow = false
                   
                    MarketSceneCsb:removeSelf()      
               end
          end
    end
    market_exppain:addTouchEventListener(touchButtonEvent)
    bg:addTouchEventListener(touchButtonEvent)
   

           
    market_text:setString(points)        --积分显示   
    --商品接口
    local params = {}
    params["type"] = "1"
    params["interfaceType"] = "J"
    cct.createHttRq({
        url=HttpAddr .. "/goods/queryGoods",
        date= params,
        type_="POST",
        callBack = function(data)
           
            local data_netData = json.decode(data["netData"])
            dump(data_netData,"----dddmarekkd----")
            if  not isShow then
                  return
                end
            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                if sData ~= nil and table.getn(sData) > 0 then
                    --todo
                    local histories = {}
                    for k,v in pairs(sData) do
                      table.insert(histories, v)

                      if k == 6 then
                        --todo

                        break
                      end
                    end
                      self:MarketPoint(histories)
                end
            end              
        end
    })

    --积分 引用房接口
    local params = {}
    params["userId"] = USER_INFO["uid"]
    params["interfaceType"] = "J"
    cct.createHttRq({
        url=HttpAddr .. "/roomCard/queryRoomCardCount",
        date= params,
        type_="GET",
        callBack = function(data)
            if not isShow then
               return
            end

            local data_netData = json.decode(data["netData"])

            local sData = data_netData.data
            points=sData["points"]
            
          
        end
    })

     
     --商品历史
    local params = {}
    params["userId"] = USER_INFO["uid"]
    params["interfaceType"] = "J"
    cct.createHttRq({
        url=HttpAddr .. "/goods/queryExchangeHistory",
        date= params,
        type_="POST",
        callBack = function(data)

            local responseData = data.netData
            local data_netData = json.decode(responseData)

            local  returnCode = data_netData["returnCode"]

            if  not isShow then
                return
            end

            if data_netData.returnCode == "0" then

                local sData = data_netData.data
                  
                if sData and table.getn(sData) > 0 then
                 
                        local intergras = {}
                        for k,v in pairs(sData) do
                          table.insert(intergras, v)

                          if k == 12 then
                            break
                          end

                        end   

                        if tolua.isnull(market_record) then
                           return
                        end

                        market_record:setTouchEnabled(true)
                        market_record:addTouchEventListener(
                        function(sender,event)

                          if event == TOUCH_EVENT_ENDED then  
                              self:intergra(intergras) 
                          end 

                        end)            
                
              end
            end              
        end
    })


--兑换商品界面
function MarketScene:MarketPoint(histories)

   local spHead = nil
   
     --获取滚动容器
   local market_list = self.sene_:getChildByName("market_list")
   local point = market_list:getChildByName("point")

  if self.sene_ then

    for k,v in pairs(histories) do


      local data = v[ "name"]
       datas = v["price"]
      local photos  = v["photo"]

    	--获取商品csb
    	local Cell = cc.CSLoader:createNode(boardCsb_filePath)

       if k > 3 then
    	   Cell:setPosition(280*k-270*4-30, -440)
    	 else 	
         Cell:setPosition(280*k-270, -240) 
    	 end 

    	 point:addChild(Cell)

        --获取商品版面
        local  market_board = Cell:getChildByName("market_board")
         market_board:setTouchEnabled(false)

        --商品价钱
        local price = market_board:getChildByName("price")
        if data ~= nil then
         price:setString(tostring(data)) 
        else
         price:setString("")
        end
     
        --商品图片的
        local photopng = require("hall.GameCommon"):getUrlPicture(photos)

        if photopng == nil or photopng == "" then
            return
        end
        local picture = market_board:getChildByName("picture")

    --先在本地获取
    local imgFullPath = device.writablePath..photopng

    local file,fileErr = io.open(imgFullPath)


     if fileErr == nil then

            local x = file:seek("end")
            if x > 0 then
                  spHead = display.newSprite(imgFullPath)
                  cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)
            else
               
            end
                picture:loadTexture(imgFullPath)  
                picture:setAnchorPoint(0, 0)
            
     else

            local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return
            end

            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            print(response)
            
            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            print("savedata:"..filename)
            while (not request:saveResponseData(filename)) and times < 30 do
                times = times + 1
            end
            local isOvertime = (times == 30) --是否超时

            cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)
           
                photos = imgFullPath
                    
      end


        local request = network.createHTTPRequest(function (event)
            -- body
            if event.name == "completed" then
                onRequestFinished(event,imgFullPath)
            end
        end,photos,"GET")

        request:start()

    end





        --商品兑换积分
        local prices = market_board:getChildByName("prices")
        local number = prices:getChildByName("number")

         if datas then
           number:setString(tostring(datas))
         else
           number:setString("") 
         end

         local goodsId = v["goodsId"]

         prices:setTouchEnabled(true)
         prices:addTouchEventListener(
            function(sender,event)
                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                   local params = {}
                   params["userId"] = USER_INFO["uid"]
                   params["goodsId"] = v["goodsId"]
                   params["interfaceType"] = "J"
                   cct.createHttRq({
                   url = HttpAddr .. "/goods/exchange",
                   date = params,
                   type_ = "POST",
                   callBack = function(data)
                            if not isShow then
                              return
                            end
                           local data_netData = json.decode(data["netData"])  
                           --积分的扣除
                           local returnCode = data_netData["returnCode"] --兑换标记 0为成功兑换 1为不成功
                           local errorjf = data_netData["error"] --不成功兑换结果
                           local data_result= data_netData["data"]  --成功兑换结果
                  
                           self:Exchanger(returnCode,errorjf,data_result)

                 end
                  })  
               end                
            end)

         --设置容器内容大小
         market_list:setCascadeOpacityEnabled(true)
         market_list:setInnerContainerSize(cc.size(500, 90*k))
    end
  end   
end   

--兑换结果
function MarketScene:Exchanger(returnCode,errorjf,data_result)
       
        local market_integral = self.sene_:getChildByName("market_integral")
        local market_text = market_integral:getChildByName("market_text") 
        local ChangerCsb = cc.CSLoader:createNode(changerCsb_filePath)
        SCENENOW["scene"]:addChild(ChangerCsb)
        local exchanger = ChangerCsb:getChildByName("exchanger") --背景图
        local extext = ChangerCsb:getChildByName("extext") --文本
        local bg_changer = ChangerCsb:getChildByName("bg_changer")
        local success = ChangerCsb:getChildByName("success")
        local code = success:getChildByName("code")
        success:setVisible(false)
       --触摸
        local function touchButtonEvent(sender, event)
       
            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                --背景触摸
                if sender == bg_changer then
                    isShow = false
                     ChangerCsb:removeSelf()
                end
          end
    end
    bg_changer:addTouchEventListener(touchButtonEvent) 


        local pointsdd = 0
        if returnCode == "0" then
            pointsdd = points - datas 
             success:setVisible(true) 
            code:setString(data_result) 
        else 
            pointsdd = points  
            extext:setString(errorjf)     
        end
            
        market_text:setString(pointsdd)        
        
end


 --规则说明
function MarketScene:Exppain ()
	 --加载csb兑换说明

	  local ExppainCsb = cc.CSLoader:createNode(exppainCsb_filePath)
	  SCENENOW["scene"]:addChild(ExppainCsb)
	--获取兑换说明bg
    local bg_exppain = ExppainCsb:getChildByName("bg_exppain")
    --获取兑换记录确定按钮
    local buttn_certain = ExppainCsb:getChildByName("buttn_certain")
    --规则说明文本
    local text = ExppainCsb:getChildByName("text")
     --触摸
     local function touchButtonEvent(sender, event)
       
            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                --背景触摸
                if sender == bg_exppain or sender == buttn_certain then
                     ExppainCsb:removeSelf()
                end

          end
    end
     --启动触摸
    bg_exppain:addTouchEventListener(touchButtonEvent)
    buttn_certain:addTouchEventListener(touchButtonEvent)  	
    --基础接口之商品说明
    local params = {}
    params["type"] = "4"
    params["interfaceType"] = "J"
    cct.createHttRq({
        url = HttpAddr .. "/baseData/queryAnnouncements",
        date = params,
        type_ ="POST",
        callBack = function(data)
           
           local data_netData = json.decode(data["netData"])

            if data_netData.returnCode == "0" then

                local sData = data_netData.data
                if sData ~= nil and table.getn(sData) > 0 then
                    local histories = {}
                    for k,v in pairs(sData) do
                      table.insert(histories, v)

                      if k == 6 then

                        break
                      end


                    end
                      
                end
            end              
        end
    })



end  

--兑换记录
function MarketScene:intergra(intergras)
    local intergras = intergras

    --加载csb兑换记录
	  local IntergralCsb = cc.CSLoader:createNode(IntergralCsb_filepath)
	  SCENENOW["scene"]:addChild(IntergralCsb)
	--获取兑换记录bg
    local bg_intergra = IntergralCsb:getChildByName("bg_intergra")
    --获取兑换记录确定按钮
    local Button_integral = IntergralCsb:getChildByName("Button_integral")
    --获取兑换滚动容器
    local integral_rocm = IntergralCsb:getChildByName("integral_rocm")
    --获取兑换记录条
    local integral_hell = IntergralCsb:getChildByName("integral_hell")
     --没有兑换记录
    local no_intergara = IntergralCsb:getChildByName("no_intergara")
     no_intergara:setVisible(false)

     --触摸                             
     local function touchButtonEvent(sender, event)
       
            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                 --背景触摸 or 确定按钮触摸
                if sender == bg_intergra or sender == Button_integral then  
                    isShow = false
                    IntergralCsb:removeSelf()
                end


          end
    end
    --启动触摸
    bg_intergra:addTouchEventListener(touchButtonEvent)
    Button_integral:addTouchEventListener(touchButtonEvent)
    
     
    if intergras == nil  then
        no_intergara:setVisible(true)
    else

    --滚动清除一次容器
    integral_rocm:removeAllChildren()
    --设置滚动容器大小 就是滚动内部大小
    integral_rocm:setInnerContainerSize(cc.size(integral_rocm:getSize().width / 2, integral_hell:getSize().height * table.getn(intergras)-10))
    table.foreach(intergras,function(i, v) 
        --克隆记录条

        local cell = integral_hell:clone()
        local scoredl1 = cell:getChildByName("scoredl1")
        local scoredl2 = cell:getChildByName("scoredl2")
        local scoredl3 = cell:getChildByName("scoredl3")
    
        if intergras[i] then
            scoredl1:setString(intergras[i]["goodsName"])
            scoredl2:setString(intergras[i]["nickname"])
            local time_str = os.date("%Y-%m-%d %H:%M:%S",intergras[i]["time"]/1000)
            scoredl3:setString(time_str)
        end
        
        --设置锚点 coco中最好设置
        cell:setAnchorPoint(cc.p(0.5,0.5))
        --设置记录条位置
        cell:setPosition(integral_rocm:getSize().width / 2, integral_rocm:getInnerContainerSize().height - cell:getSize().height / 2 - cell:getSize().height * (i-1))
        --把记录条放人滚动容器
        integral_rocm:addChild(cell)
        end)

      end
        


end

end


return MarketScene