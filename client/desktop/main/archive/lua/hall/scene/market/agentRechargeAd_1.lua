local agentRechargeAd = class("agentRechargeAd")
local s

local registerInfo = {}
local agentGoodsList = nil

function agentRechargeAd:showScene()

    s = cc.CSLoader:createNode("hall/scene/res/" ..resFolder.. "/hall/agent_ad.csb")
    SCENENOW["scene"]:addChild(s)
    s:setScale(1280/1920)
    -- local action = cc.CSLoader:createTimeline(MissionSceneCsb_filePath)
    -- s:runAction(action)
    -- action:gotoFrameAndPlay(0, 25, false)

	local register_plane = s:getChildByName("register_plane")
		  register_plane:setVisible(false)
    local close_bt = s:getChildByName("close_bt")

	close_bt:addTouchEventListener(function(sender,event)
		
		if 	event == TOUCH_EVENT_BEGAN then
			sender:setScale(0.9)
		end

		if  event == TOUCH_EVENT_CANCELED then
			sender:setScale(1)

		end

		if 	event == TOUCH_EVENT_ENDED then
			sender:setScale(1)
			self:removeScene()
		end

	end)


	if 	cc.UserDefault:getInstance():getBoolForKey("hasAgentRegisterChance",false) == true then
		self:openRegisterPage()
	end


	if 	agentGoodsList then
		self:showAgentGoods(agentGoodsList)
	else

	    local parm = {}
	    parm["device"] = "1"
	    parm["userId"] = USER_INFO["uid"]
	    parm["interfaceType"] = "J"

		cct.createHttRq({
	        url = HttpAddr .. "/goods/queryGoodsList",
	        date = parm,
	        type_= "GET",
	        callBack = function(data)

	            local responseData = data.netData
	            if responseData then
	                responseData = json.decode(responseData)
	                local data = responseData.data
	                if 	data then
	                	dump(data,"showGoods")

	                	local list = data.list

						table.sort(list,function(a,b) return a.price < b.price  end)

						agentGoodsList  = {}
	        			for k,v in pairs(list) do
	    				    if 	tonumber(v.categoryType) == 3 then
	                            table.insert(agentGoodsList, v)
	                        end
						end

						self:showAgentGoods(agentGoodsList)

	                end
	            end

	        end})

	end

end

function agentRechargeAd:showAgentGoods(agentGoodsList)

    local buycard_plane = s:getChildByName("buycard_plane")
	local buycard_list = buycard_plane:getChildByName("buycard_list")

	for i,good in ipairs(agentGoodsList) do

		local buycard_item = buycard_list:getChildByName("buycard_item_"..i)
		local money = buycard_item:getChildByName("money")
		local goods_info = buycard_item:getChildByName("goods_info")
		local buy_bt = buycard_item:getChildByName("buy_bt")

		local price = good["price"] * 0.01
		money:setString("￥"..price)

		local goodName = require(NumberUtil_filePath):toWan(tonumber(good["name"]), 99999)
		goods_info:setString("获得"..goodName.."张房卡")

		buy_bt:addTouchEventListener(function(sender,event)

			if 	event == TOUCH_EVENT_BEGAN then
				sender:setScale(0.9)
			end

			if  event == TOUCH_EVENT_CANCELED then
				sender:setScale(1)
			end

			if 	event == TOUCH_EVENT_ENDED then
				sender:setScale(1)

				EnterAgentPayPage = true
				require(".bqMarketScene"):openPayPage(good["goodsId"],good["amount"])
			end

		end)
	end

end

function agentRechargeAd:openRegisterPage()

	dump(self,"openRegisterPage")
	if 	tolua.isnull(s) == true then
		self:showScene()
	end

	local register_plane = s:getChildByName("register_plane")
		  register_plane:setVisible(true)

	local register_plane_mask = register_plane:getChildByName("register_plane_mask")

    local name_input =  register_plane:getChildByName("name_ly"):getChildByName("input_tf")
    local id_input =  register_plane:getChildByName("id_ly"):getChildByName("input_tf")
    local phone_input =  register_plane:getChildByName("phone_ly"):getChildByName("input_tf")
    local confirm_ly = register_plane:getChildByName("confirm_ly"):getChildByName("input_tf")

    name_input:setString("")
	id_input:setString("")
	phone_input:setString("")
	confirm_ly:setString("")

    local sure_bt = register_plane:getChildByName("sure_bt")
    local cancel_bt = register_plane:getChildByName("cancel_bt")

    local buttonCallFuc = function(sender,event)
		
		if 	event == TOUCH_EVENT_BEGAN then
			sender:setScale(0.9)
		end

		if  event == TOUCH_EVENT_CANCELED then
			sender:setScale(1)
		end

		if 	event == TOUCH_EVENT_ENDED then
			sender:setScale(1)

			if  sender == sure_bt then

				registerInfo["userId"] = USER_INFO["uid"]
				registerInfo["loginName"] = name_input:getString()
				registerInfo["passWord"] = id_input:getString()
				registerInfo["phone"] = phone_input:getString()
				local confirmPassWord = confirm_ly:getString()

				if  registerInfo["loginName"] == "" then
					require(CommonTips_filePath):showTips("提示", "", 3, "登录名不能为空！")
					return
				elseif registerInfo["passWord"] == "" then
					require(CommonTips_filePath):showTips("提示", "", 3, "密码不能为空！")
					return
				elseif registerInfo["passWord"] ~= confirmPassWord then
					require(CommonTips_filePath):showTips("提示", "", 3, "两次输入密码不一致！")
					return
				elseif registerInfo["phone"] == "" then
					require(CommonTips_filePath):showTips("提示", "", 3, "手机号不能为空！")
					return
				end

				cct.createHttRq({
                    url=HttpAddr .. "/playerRegister2Agent",
                    date= registerInfo,
                    type_= "POST",
                    callBack = function(data)

                        local data_netData = json.decode(data["netData"])

                    	dump(data_netData,"playerRegister2Agent_data_netData")
                        if  data_netData.returnCode == "0" then
                            require(CommonTips_filePath):showTips("提示", "", 3, "注册代理成功！")
                            register_plane:setVisible(false)	
                            cc.UserDefault:getInstance():setBoolForKey("hasAgentRegisterChance",false)
                        else
                        	if 	type(data_netData["error"]) == "string" then
                        		require(CommonTips_filePath):showTips("提示", "", 3, data_netData["error"])
                        	end
                        end

                end})

			elseif  sender == register_plane_mask then
				register_plane:setVisible(false)
			elseif  sender == cancel_bt then
				register_plane:setVisible(false)
			end

		end

	end

	sure_bt:addTouchEventListener(buttonCallFuc)
	cancel_bt:addTouchEventListener(buttonCallFuc)
	register_plane_mask:addTouchEventListener(buttonCallFuc)

end

function agentRechargeAd:removeScene()

	if 	tolua.isnull(s) == false then
		s:removeFromParent()
	end

end

return agentRechargeAd
