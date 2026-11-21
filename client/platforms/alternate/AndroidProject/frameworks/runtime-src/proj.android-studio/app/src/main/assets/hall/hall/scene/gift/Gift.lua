
local Gift = class("Gift")
local isShow = false
local reuslt1 = 0
local GiftSceneCsb

function Gift:showGiftScene(typ)	 
	isShow = true
   
	GiftSceneCsb = cc.CSLoader:createNode(GiftCsb_filePath):setScale(1280/1920)
    GiftSceneCsb:setPosition(cc.p(0,0))   --SCREEN_HEIGHT - 650)
    SCENENOW["scene"]:addChild(GiftSceneCsb,999)

    local btn_close = GiftSceneCsb:getChildByName("btn_close")  
    --按钮
    local btn_sure = GiftSceneCsb:getChildByName("btn_sure") 

    local box_content = GiftSceneCsb:getChildByName("box_content")
    --赠送人id
    local gift_p = box_content:getChildByName("gift_p"):setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    --赠送房卡数
    local gift_k = box_content:getChildByName("gift_k"):setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)

    local txt_title = GiftSceneCsb:getChildByName("txt_title")

    local txt_title_k = box_content:getChildByName("txt_title_k")

    dump(typ, "showGiftScene")
    if typ == 1 then
        txt_title:setString("赠送房卡")
        txt_title_k:setString("房卡数")
    end

    local giftName = typ == 1 and "房卡"  or "钻石" 

    local function explain()

        local p = gift_p:getString()
        local k = gift_k:getString()
         
        if  k == tostring(USER_INFO["uid"]) then
            require(CommonTips_filePath):showTips("提示", "", 3, "无法赠送给自己！")
            return
        elseif  k == "" then
            require(CommonTips_filePath):showTips("提示", "", 3, "受赠人ID不能为空！")
            return
        elseif  tonumber(k) == nil then
            require(CommonTips_filePath):showTips("提示", "", 3, "受赠人ID只能为数字！")
            return    
        elseif  p  == "" then
            require(CommonTips_filePath):showTips("提示", "", 3, "赠送数额不能为空！")
            return
        elseif  tonumber(p) == nil or math.floor(tonumber(p)) < tonumber(p) then
            require(CommonTips_filePath):showTips("提示", "", 3, "赠送数额只能为整！")
            return  
        -- elseif  tonumber(p) > USER_INFO["gold"] then
        --     require(CommonTips_filePath):showTips("提示", "", 3, "赠送数额超出您拥有的" .. giftName .. "！")
        --     return  
        end   

        --赠送房卡接口
        local params = {}
        local _url

        if typ == 1 then 
            params["userId"] = USER_INFO["uid"]
            params["toUserId"] = k
            params["roomCard"] = p
            _url = HttpAddr .. "/fortune/giftRoomCard"

        else
            params["playerId1"] = USER_INFO["uid"]
            params["playerId2"] = k
            params["count"] = p 
            params["sign"] = crypto.md5(USER_INFO["uid"] .. "&"..k.."*"..p.."-yigelajidemima", false)  
            dump(params["sign"],"xadadwdcaw") 
            _url = HttpAddr .. "/playerXXX"

        end  

        cct.createHttRq({
            url= _url,
            date= params,
            type_="POST",
            callBack = function(data)
               
                local data_netData = json.decode(data["netData"])

                if  not isShow then
                    return
                end

                local returnCode=data_netData["returnCode"]
                if data_netData ~= nil then
                    dump(data_netData,"赠送金币返回信息")

                    if returnCode == "0"  then --成功状态

                        local sData = data_netData.data 
                        local sid = sData["userId"]
                        local isd = tostring(sid)
                        if p == isd then
                            reuslt1 = "赠送自己无效"
                        else
                            reuslt1 = data_netData["data"] --sData["0"]

                            local msg = {}
                            msg["type"] = "roomCard"
                            msg["handle"] = "refresh"
                            --通知对方玩家更新房卡数量
                            require(HallServer_filePath):SendHallMsg(tonumber(p), json.encode(msg))
                        end

                        require("hall.gameScene"):queryRoomCardCount()
                        require(CommonTips_filePath):showTips("提示", "", 3, "赠送成功")  

                        self:removeScene()      

                    elseif returnCode == "1" then 
                         reuslt1 = data_netData["error"]
                         require(CommonTips_filePath):showTips("提示", "", 3, "赠送失败")  
                    elseif returnCode == "2" then
                         reuslt1 = data_netData["data"]  
                         require(CommonTips_filePath):showTips("提示", "", 3, "赠送失败")   
                    end
                
                 end   
            end})
    end

    local function touchButtonEvent(sender,event)
        
        --触摸结束
        if event == TOUCH_EVENT_ENDED then

            if  sender == btn_sure then
                explain()
                self:removeScene()
            end

            if  sender == btn_close then
                isShow = false
                self:removeScene()      
            end

        end

    end

    btn_sure:addTouchEventListener(touchButtonEvent)
    btn_close:addTouchEventListener(touchButtonEvent)

end

function Gift:removeScene()    
    if  tolua.isnull(GiftSceneCsb) == false then
        GiftSceneCsb:removeSelf() 
    end
end

return Gift