local rank_list = class("rank_list")

local _w = nil
local isShow = false
local s = nil
local rankDataCache = nil   

function rank_list:ctor()
	rank_list.super.ctor(self)
end

function rank_list:show()
	-- body
	--_isShow = _isShow or true
	
	if SCENENOW["scene"] then
		--释放之前的
        s = SCENENOW["scene"]:getChildByName("rank_list")
        if s then
            s:removeSelf()
        end

        --添加新场景
        if device.platform == "ios" then
            if isiOSVerify then
                s = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/rank/rank_list.csb")
            else
                s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/scene/res/" .. resFolder .."/rank/rank_list.csb")
            end
        else
            s = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/rank/rank_list.csb")
        end
		s:setName("rank_list")
		
		SCENENOW["scene"]:addChild(s)
		

		_w = self:loadChildrenWidget(s)
		
		_w["back_bt"]:addTouchEventListener(rank_list.touchEvent)
		self:queryRankList()
	end
	
end	

--获取子控件table
function rank_list:loadChildrenWidget(_node, _childrenTable)
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

function rank_list.touchEvent(sender, event)
	local name = sender:getName()
	if event == TOUCH_EVENT_BEGAN then
		require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
        sender:setScale(0.9)
    end
    if event == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end
	if event == TOUCH_EVENT_ENDED then
		sender:setScale(1.0)
		if name == "back_bt" then   
			
			s:removeSelf()
			
		end
	end	
end


function rank_list:showRankList(rankList)

    for k,v in pairs(rankList) do
        --dump(v, "-----单个排行榜数据-----")
        if  k > 10 then
            return
        end 

        --local rankcell = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/rank/rank_item.csb")             
        local itemLayout = _w["itemLayout"]:clone()  --rankcell:getChildByName("itemLayout")    
        local _itemW = self:loadChildrenWidget(itemLayout)
        -- itemLayout:removeFromParent()
        itemLayout:setVisible(true)

        _itemW["rank_txt"]:setString(k)

        if  k == 1 then
            _itemW["rank_txt"]:setTextColor(cc.c3b(0xdc,0x07,0x25))
            -- _itemW["rank_txt"]:enableStroke(cc.c3b(255,255,0),1,true)
        elseif  k == 2 then
            _itemW["rank_txt"]:setTextColor(cc.c3b(0xd0,0xce,0xcd))
            -- _itemW["rank_txt"]:enableStroke(cc.c3b(255,255,0),1,true)
        elseif  k == 3 then
            _itemW["rank_txt"]:setTextColor(cc.c3b(0xd4,0x8a,0x0a))
            -- _itemW["rank_txt"]:enableStroke(cc.c3b(255,255,0),1,true)
        elseif  k > 3 then
            _itemW["rank_txt"]:setTextColor(cc.c3b(0x9b,0x59,0x12))
        end

        -- for i,cardNode in pairs(itemLayout:getChildren()) do
        --     dump(cardNode:getName(),"控件名")
        -- end

        _itemW["rank_img"] = display.newSprite("hall/scene/res/" .. resFolder .."/image/rank/rank_normal.png"):addTo(itemLayout,0)
        _itemW["rank_img"]:setPosition(cc.p(56,51))
        _itemW["rank_txt"]:setZOrder(1)

        --排名    
        if k<4 then
            _itemW["rank_img"]:setVisible(true)
            _itemW["rank_txt"]:setVisible(true)
            _itemW["rank_img"]:setTexture("hall/scene/res/" .. resFolder .."/image/rank/rank_"..k..".png")
        else 
            _itemW["rank_img"]:setVisible(true)
            _itemW["rank_txt"]:setVisible(true)
            -- _itemW["rank_img"]:loadTexture("hall/scene/res/" .. resFolder .."/image/rank/rank_normal.png")
        end    

        --头像
        require("hall.GameCommon"):getUserHead(v["headURL"], "", "", _itemW["rank_head"], 60, false, v["nickNmae"])
        
        --昵称
        _itemW["player_id"]:setString(v["nickNmae"])

        --金币数
        local goldCount = v["goldCount"]
         if goldCount > 10000 then
            goldCount = string.format("%0.1f", math.floor(goldCount/1000)/10) .. "万"
        end  
        _itemW["player_coin"]:setString(goldCount)
        _itemW["player_coin"]:setColor(cc.c3b(255,255,0))

        --签名
        if v["sign"] ~= nil and v["sign"] ~= "" and v["sign"] ~= "0" then
            _itemW["player_sign"]:setString(v["sign"])
        else
            _itemW["player_sign"]:setString("")
        end


        _w["rank_list"]:pushBackCustomItem(itemLayout)
        _w["rank_list"]:jumpToTop()
    end

    _w["rank_list"]:setScrollBarEnabled(false)
end


--查询排行榜
function rank_list:queryRankList()

    if  rankDataCache then
        self:showRankList(rankDataCache)
        return
    end

    local table = {}
    --table["userId"] = USER_INFO["uid"]
    --table["rankcount"] = rankcount
    table["interfaceType"] = "J"

    cct.createHttRq({
        url = HttpAddr .. "/gold/getGoldRanking",  
        date = table,
        type_= "POST",
        requestMsg = "",
        callBack = function(data)

            --dump(data, "-----排行榜数据-----")

            if SCENENOW["name"] == GameScene_filePath then

                local responseData = data.netData
                if responseData then
                    responseData = json.decode(responseData)
                    local rankList = responseData.data
                    if rankList ~= nil then

                        rankList = json.decode(rankList)
                        
                        rankDataCache = rankList

                        if  tolua.isnull(_w["rank_list"]) then
                            return
                        end

                        dump("rankList count" .. #rankList)

                        self:showRankList(rankList)
                                                  
                    end
                end

            end

        end
    })

end

return rank_list
