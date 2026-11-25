-- 订单在发送前落盘。未收到明确回执时，重新进入大厅仍可确认同一笔。
local M={}
function M.open(parent,ui)
    if not parent or parent:getChildByName("chipPurchase") then return end
    local size=cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local root=ui.box(parent,size.width,size.height,0,0,ui.rail)
    root:setName("chipPurchase"); root:setLocalZOrder(1200); root:setTouchEnabled(true)
    local scale=math.min(size.width/960,size.height/540)
    local panel=ui.box(root,960,540,(size.width-960*scale)/2,(size.height-540*scale)/2,ui.felt)
    panel:setScale(scale)
    local store=cc.UserDefault:getInstance()
    local key="chipPurchase."..tostring(USER_INFO.uid)
    local saved=store:getStringForKey(key,"")
    local order=saved~="" and json.decode(saved) or nil
    local alive,busy=true,false
    local amount,notice=nil,""
    local render
    local function confirm()
        if busy then return end
        if not order then
            local seq=store:getIntegerForKey(key..".seq",0)+1
            store:setIntegerForKey(key..".seq",seq)
            local entropy={tostring(token),tostring(os.time()),tostring(os.clock()),tostring(math.random()),tostring(seq)}
            order={chips=amount,requestId=crypto.md5(table.concat(entropy,":"),false)}
            store:setStringForKey(key,json.encode(order)); store:flush()
        end
        busy=true; notice="正在确认订单…"; render()
        cct.createHttRq({url=HttpAddr.."/wallet/purchaseChips",date={chips=order.chips,requestId=order.requestId},
            type_="POST",encodeForm=true,isshowfailTip=false,
            onFailure=function()
                if alive then busy=false; notice="尚未收到回执，请确认原订单"; render() end
            end,
            callBack=function(reply)
                if not alive then return end
                busy=false
                local res=json.decode(reply.netData) or {}
                if tostring(res.returnCode)=="0" and res.data and res.data.requestId==order.requestId then
                    notice=string.format("本笔已兑换 %d 筹码",res.data.chips)
                elseif tostring(res.returnCode)=="1" and res.error then
                    notice=res.error
                else
                    notice="尚未取得本笔回执，重新登录后可继续确认"; render(); return
                end
                store:setStringForKey(key,""); store:flush()
                order=nil; amount=nil; render()
            end})
    end
    render=function()
        panel:removeAllChildren()
        ui.label(panel,"兑换筹码",480,460,34,ui.gold)
        ui.button(panel,"返回大厅",120,42,870,495,function() root:removeFromParent() end)
        if order or amount then
            local chips=order and order.chips or amount
            ui.label(panel,string.format("扣除钱包余额 %d，兑换 %d 筹码",math.floor(chips*1200/1000),chips),480,314,24)
            ui.label(panel,string.format("百人场计分 %.2f 分",chips/100),480,256,20)
            ui.button(panel,order and "确认原订单" or "确认兑换",175,50,480,185,confirm,true)
            if not order then ui.button(panel,"修改数量",142,40,480,118,function() amount=nil; render() end) end
        else
            ui.label(panel,"输入筹码数量，下一步核对扣款金额",480,362,22)
            local field=ccui.EditBox:create(cc.size(295,48),ccui.Scale9Sprite:create())
            field:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC); field:setMaxLength(10)
            field:setPlaceHolder("筹码数量"); field:setFontSize(24); field:setPosition(480,278); panel:addChild(field)
            ui.button(panel,"核对金额",165,50,480,177,function()
                local value=field:getText()
                local n=tonumber(value)
                if not n or not value:match("^%d+$") or n<1 or n>2147483647 then
                    notice="请输入有效的正整数"; render(); return
                end
                amount=n; notice=""; render()
            end,true)
        end
        ui.label(panel,notice,480,54,19,ui.gold)
    end
    root:registerScriptHandler(function(event) if event=="exit" then alive=false end end)
    render()
end
return M
