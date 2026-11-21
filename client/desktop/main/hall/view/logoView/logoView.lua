local logoView = class("logoView")

function logoView:showView()

	if SCENENOW["scene"] ~= nil then

	    local s = cc.CSLoader:createNode("hall/view/logoView/logoViewLayer.csb")
	    s:setName("logoView")
	    s:setOpacity(0)
	    SCENENOW["scene"]:addChild(s, 100000)

	    --渐现
	    s:runAction(cc.FadeIn:create(1))

	    --背景
	    local bg_gao = s:getChildByName("bg_gao")
	    
	    --底部
	    local Panel_1 = s:getChildByName("Panel_1")
	    Panel_1:setVisible(isShowBanHao)

	    --版号信息
	    local banhao_tt = Panel_1:getChildByName("banhao_tt")
	    banhao_tt:setString(banHaoMessage)

	    --公司信息
	    local company_tt = Panel_1:getChildByName("company_tt")
	    company_tt:setString(companyMessage)

    end

end

function logoView:removeView()

	local s = SCENENOW["scene"]:getChildByName("logoView")
    if s then
        s:removeSelf()
    end

end

return logoView