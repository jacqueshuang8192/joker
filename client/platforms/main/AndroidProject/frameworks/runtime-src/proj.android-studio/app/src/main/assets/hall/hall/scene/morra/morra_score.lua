local morra_score = class("morra_score")



local _w = nil


function morra_score:show()
	
	isShow = true


	local s = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/morra/morra_score.csb"):addTo(SCENENOW["scene"])

	
     
    _w = self:loadChildrenWidget(s) 

    --self:initTable()
    self:getMorraScoreData()

	--myRecord_plane:setVisible(false)
	--findOthersRecord_plane:setVisible(false)

    local floor = s:getChildByName("floor")
	local morra_close_btn = floor:getChildByName("morra_close_btn")  --返回
	



	local function touchButtonEvent(sender, event)

        if event == TOUCH_EVENT_ENDED then

        	require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
        	print("sender" .. sender:getName())

            if sender == morra_close_btn then  --点击返回的时候
              
            	s:removeFromParent() --清除界面，内存不减少，专门用cs做的界面
               
            	
            end
        end

    end

    morra_close_btn:addTouchEventListener(touchButtonEvent)

    
end


--请求猜拳战绩数据
function morra_score:getMorraScoreData()
	-- body	
	local params = {}
    params["userId"] = USER_INFO["uid"]
    params["level"] = 2
    params["currentPage"] = 1
    params["pageSize"] = 150
    params["interfaceType"] = "J"
    cct.createHttRq({
       -- url=HttpAddr .. "/freeGame/queryFreeGameRound",
        url=HttpAddr .. "/freeGame/queryGoldActivitiesByUserIdAndLevel",
        date= params,
        type_="POST",
        callBack = function(data)
        	      
            data_netData = json.decode(data["netData"])

            dump(data_netData, "---findRound---")
            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                if sData ~= nil then
                    --todo
	           		self:initMorraScoreTable(sData)
                end
               
            end              
        end
    })

end


--获取子控件table
function morra_score:loadChildrenWidget(_node, _childrenTable)
	local function func(node, childrenTable)
		if node ~= nil and node:getChildrenCount() <= 0 then return end
		local cTable = node:getChildren()
		for i, v in ipairs(cTable) do
			childrenTable[v:getName()] = v
			func(v, childrenTable)
		end
	end
	if _childrenTable == nil then _childrenTable = {} end
	func(_node, _childrenTable)
	return _childrenTable
end

--创建猜拳战绩列表

function morra_score:initMorraScoreTable(data)
	-- body
	dump(data,"------------猜拳战绩----------------")
	_w["score_list"]:removeAllChildren()
    if #data == 0 then
        _w["noscore_txt"]:setVisible(true)
    else
        _w["noscore_txt"]:setVisible(false)
    end     
	--_w["myRecord_scroll"]:setVisible(true)
	for k,v in pairs(data) do 
		local historycell = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/morra/item_morrascore.csb")
		local itemLayout = historycell:getChildByName("itemLayout")    
        local _itemW = self:loadChildrenWidget(itemLayout)
        itemLayout:removeFromParent()
        --dump(v["content"],"------------金币场战绩1----------------")

    	local userinfo = json.decode(v["content"])
        local gameName = userinfo["gameName"]
        local roomNumb = userinfo["roomNumb"] 
    		userinfo = userinfo["userinfos"]

        local gameTime = v["endTime"]
        local time_str = os.date("%Y-%m-%d %H:%M:%S", gameTime/1000)    
         
        _itemW["time_txt"]:setString(time_str)
    	--dump(userinfo,"------------金币场战绩2----------------")
    	for o,p in pairs(userinfo) do 
    		
    			_itemW["player_name"..o]:setString(p["nickName"])
    			require("hall.GameCommon"):getUserHead(p["photoUrl"], "", "", _itemW["player_head"..o], 70, false, p["nickName"])
    			local score = p["score"]
    			if score >0 then
    				score = "+"..score
    				_itemW["player_score"..o]:setColor(cc.c3b(0, 128, 0))
    			elseif score < 0 then
    				_itemW["player_score"..o]:setColor(cc.c3b(255, 0, 0))
    			end
    			_itemW["player_score"..o]:setString(score)
    		
    	end	
		        

        _w["score_list"]:pushBackCustomItem(itemLayout)
        _w["score_list"]:jumpToTop()

	end	
end


return morra_score