
local NetworkLoadingView = class("NetworkLoadingView")

function NetworkLoadingView:showLoading(msg)

	if SCENENOW["scene"] then

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("loading")
        if s then
            s:removeSelf()
        end

        s = cc.CSLoader:createNode("hall/res/NetworkLoadingLayer/NetworkLoadingLayer.csb")
        self:_initUIView(s)
        s:setName("loading")

        -- if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 1920 then
        --     s:setScale(1920/1280)
        -- end

        local load_iv = s:getChildByName("root"):getChildByName("load_iv")
        load_iv:loadTexture("hall/NetworkLoadingView/image/loading.png")
        local actionBy = cc.RotateBy:create(2 , 360)
	    load_iv:runAction(cc.RepeatForever:create(actionBy))

        local load_tt = s:getChildByName("root"):getChildByName("load_tt")
        load_tt:setString(msg)
        local x = 1
        load_tt:runAction(cc.RepeatForever:create(

        	cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()

	        	local s = SCENENOW["scene"]:getChildByName("loading")
	        	if s then
	        		local load_tt = s:getChildByName("root"):getChildByName("load_tt")
		        	if x == 1 then
		        		load_tt:setString(msg)
		        	elseif x == 2 then
		        		load_tt:setString(msg .. ".")
		        	elseif x == 3 then
		        		load_tt:setString(msg .. "..")
		        	elseif x == 4 then
		        		load_tt:setString(msg .. "...")
		        	end
	        	end

	        	x = x + 1

	        	if x == 5 then
	        		x = 1
	        	end

	        end))

        ))

        SCENENOW["scene"]:addChild(s,99999)

	end

end

function NetworkLoadingView:_getScaleParam()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
end

function NetworkLoadingView:_initUIView(csbNode)
    local bg = csbNode:getChildByName("bg")
    local precent = self:_getScaleParam()
    if bg then
        bg:setScaleX(bg:getScale()*precent)
        local x = bg:getPositionX()
        bg:setPositionX(x*precent)
    end

    local root = csbNode:getChildByName("root")
    if root then
        local child = root:getChildren()
        for i, v in ipairs( child or {} ) do
            local x = v:getPositionX()
            v:setPositionX(x*precent)
            if v:getDescription() == "ListView" then --容器按照比率重新设置大小
                local size = v:getContentSize()
                v:setContentSize(cc.size(size.width * precent, size.height))
            end
        end 
    end
end

function NetworkLoadingView:removeView(t)
    print("NetworkLoadingView_removeView",t)
	if not tolua.isnull(SCENENOW["scene"]) then

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("loading")
        if s then
            s:removeSelf()
        end

	end
	
end

return NetworkLoadingView