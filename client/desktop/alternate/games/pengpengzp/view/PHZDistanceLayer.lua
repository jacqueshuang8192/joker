local PHZDistanceLayer = class("PHZDistanceLayer", function ()
   return cc.CSLoader:createNode("pengpengzp/res/PHZDistanceLayer.csb")
end)

function PHZDistanceLayer:ctor()
	self:setNodeEventEnabled(true)
	self:initUI()
    self:testMain()

    self:getChildByName("result_bg"):setScale(g_PHZMainScene:_getScaleParam2())
    g_PHZMainScene:setRootSize(self)
end

function PHZDistanceLayer:onEnter()
end

function PHZDistanceLayer:onExit()
end

function PHZDistanceLayer:testMain()

    --test
    -- local t = g_PHZMainScene:get_all_out_cardArr()
    -- dump(t)
    -- local c = g_PHZMainScene:getTingCardNumByCardID(2)
    -- print("===还是比较好 c ==="..c)

    -- local GameLogic = require("pengpengzp.logic.GameLogic")
    -- -- local t = {1,2,3,17,17,18,21,21,23,26}
    -- local t = {1,2,4,4,5,6,7,8,8,9,9,10,10,17,18,19,22,23,23,24,25}
    -- local t = {1,1,1,4,5,6,5,6,7,7}
    -- self.m_GameLogic = GameLogic:new()
    -- local c = self.m_GameLogic:getTingCardArr(t)
    -- dump(c)

    -- g_PHZMainLayer:showTingNode()


    -- print("====玩家弃牌以及玩家不要的牌还有玩家====")

    -- dump(g_CardScene.m_DCardData)
    -- dump(g_CardScene.m_WeaveItem)

    -- for k,v in pairs(g_CardScene.m_WeaveItem) do
    --     for k1,v1 in pairs(v) do
    --         dump(v1.cbCardList)
    --     end
    -- end

--     local final_list = {}

-- function get_val(card)
--     local val = card
--     if card > 16 then
--         val = card - 16
--     end
--     return val
-- end

-- function change_hash(hash, val, ...)
--     local pos_list = {...}
--     for k, v in ipairs(pos_list) do
--         hash[v] = hash[v] + val
--     end

--     if val < 0 then
--         for k, v in ipairs(pos_list) do
--             for i = 1, -val do
--                 table.insert(final_list, v)
--             end
--         end
--     else
--         for k, v in ipairs(pos_list) do
--             for i = 1, val do
--                 table.remove(final_list)
--             end
--         end
--     end
-- end
-- --[[
-- 三张 10
-- 2 7 10   5
-- 顺子  3
-- 吃 2
-- ]]
-- local score = 0

-- function get_hu_xi(hash)
--     for i = 1, 31 do
--         if hash[i] > 0 then
--             if hash[i] == 3 then
--                 change_hash(hash, -3, i)
--                 score = score + 10
--                 local re = get_hu_xi(hash)
--                 if re == -1 then
--                     change_hash(hash, 3, i)
--                     score = score - 10
--                 else
--                     return score
--                 end
--             end
            
--             if get_val(i) == 2 and hash[i + 5] > 0 and hash[i + 5] < 3 and hash[i + 8] > 0 and hash[i + 8] < 3 then
--                 change_hash(hash, -1, i, i + 5, i + 8)
--                 score = score + 5
--                 local re = get_hu_xi(hash)
--                 if re == -1 then
--                     change_hash(hash, 1, i, i + 5, i + 8)
--                     score = score - 5
--                 else
--                     return score
--                 end
--             end
            
--             if hash[i + 1] > 0 and hash[i + 1] < 3 and hash[i + 2] > 0 and hash[i + 2] < 3 then
--                 change_hash(hash, -1, i, i + 1, i + 2)
--                 score = score + 3
--                 local re = get_hu_xi(hash)
--                 if re == -1 then
--                     change_hash(hash, 1, i, i + 1, i + 2)
--                     score = score - 3
--                 else
--                     return score
--                 end
--             end
            
--             if i < 16 and hash[i + 16] > 0 and hash[i + 16] < 3 and hash[i] + hash[i + 16] > 3 then
--                 local cnt = hash[i]
--                 change_hash(hash, -cnt, i)
--                 change_hash(hash, -3 + cnt, i + 16)
--                 score = score + 2
--                 local re = get_hu_xi(hash)
--                 if re == -1 then
--                     change_hash(hash, cnt, i)
--                     change_hash(hash, 3 - cnt, i + 16)
--                     score = score - 2
--                 else
--                     return score
--                 end
--             end

--             if i > 16 and hash[i - 16] > 0 and hash[i - 16] < 3 and hash[i] + hash[i - 16] > 3 then
--                 local cnt = hash[i]
--                 change_hash(hash, -cnt, i)
--                 change_hash(hash, -3 + cnt, i - 16)
--                 score = score + 2
--                 local re = get_hu_xi(hash)
--                 if re == -1 then
--                     change_hash(hash, cnt, i)
--                     change_hash(hash, 3 - cnt, i - 16)
--                     score = score - 2
--                 else
--                     return score
--                 end
--             end
--         end
--     end

--     local flag = false
--     for i = 1, 31 do
--         if hash[i] > 0 then
--             if hash[i] == 2 then
--                 if not flag then
--                     flag = true
--                 else
--                     return -1
--                 end
--             else
--                 return -1
--             end
--         end
--     end

--     return score
-- end

-- function f(card)
--     local hash = {}
--     for i = 1, 31 do
--         hash[i] = 0
--     end

--     for k, v in ipairs(card) do
--         hash[v] = hash[v] + 1
--     end

--     score = 0
--     final_list = {}
--     get_hu_xi(hash)

--     if score ~= -1 then
--         for k, v in pairs(hash) do
--             if v > 0 then
--                 for i = 1, v do
--                     table.insert(final_list, k)
--                 end
--             end
--         end
--     end
-- end


    -- local card = {21,21,5,7,7,7}
    -- -- print("xxxxxxxx", f(card), final_list)
    -- print("=====胡牌列表打印=====")

    -- local GameLogic = require("pengpengzp.logic.GameLogic")
    -- self.m_GameLogic = GameLogic:new()
    -- local temp_huCardData = nil
    -- -- if not temp_huCardData then return end
    -- temp_huCardData = self.m_GameLogic:getHuPaiArr(card)
    -- dump(temp_huCardData)

    
    -- local tempNum = 3                                              --胡牌基本以三个
    -- local huCardArr = {}
    -- local cardNum = #temp_huCardData
    -- print("=cardNum=",cardNum)
    -- local tempArr = {}
    -- for k,v in pairs(temp_huCardData) do
    --     print("==还有什么东西么==",v)
    --     table.insert(tempArr,v)
    --     if #tempArr == tempNum or k == cardNum then
    --         dump(tempArr)
    --         table.insert(huCardArr,tempArr)
    --         tempArr = {}
    --     end
    -- end
    -- dump(final_list)
end


function PHZDistanceLayer:initUI()

    local function getDistance(latitude,longitude,b_latitude,b_longitude,lb)
       if  (latitude == 0 or latitude == nil) or (b_latitude == 0 or b_latitude == nil)  then   --距离数据不存在
           lb:setString("距离未知")
       else
            local s = require("hall.util.LocationUtil"):getDistance(latitude, longitude, b_latitude, b_longitude)
            if s >= 0 then

                if s < 1000 then
                    lb:setString(tostring(s) .. "米")
                else
                    s = s / 1000
                    s = math.floor(s)
                    lb:setString(tostring(s) .. "公里")
                end
            end
       end
    end

	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.ended then
    			self:removeFromParent()
    		end
    	end
    end

    self.btn_bg = self:getChildByName("result_bg")
    self.btn_bg:addTouchEventListener(onTouchButton)

    local distance = self:getChildByName("distance")
    local left_top_lb = distance:getChildByName("Text_2")
    local left_right_lb = distance:getChildByName("Text_1")
    local right_top_lb = distance:getChildByName("Text_3")

    local LocaArrayByPlayerType = {}

    LocaArrayByPlayerType[0] = {[1] = tonumber(USER_INFO.longitude) ,[2] = tonumber(USER_INFO.latitude)}
    
    for k,v in pairs(g_PHZMainScene.otherInfo) do
        local _index = g_PHZMainScene:getViewChairId(v.seat_id)
        LocaArrayByPlayerType[_index] = {[1] = tonumber(v.longitude) ,[2] = tonumber(v.latitude)}
    end

    -- dump(g_PHZMainScene.otherInfo)

    -- dump(LocaArrayByPlayerType)

    local  left = LocaArrayByPlayerType[2] or {0,0}
    local  right = LocaArrayByPlayerType[1] or {0,0}
    local  top =  LocaArrayByPlayerType[0] or {0,0}

    local left_right_txt = getDistance(left[2],  left[1],  right[2], right[1],  left_right_lb)
    local left_top_txt   = getDistance(left[2],  left[1],  top[2],   top[1],    left_top_lb)
    local right_top_txt  = getDistance(right[2], right[1], top[2],   top[1],    right_top_lb)

end

return PHZDistanceLayer