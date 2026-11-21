local FamilyTableView = class("FamilyTableView")

function FamilyTableView:getSuitTabledItem(flag, game_data)
    local pathStr = "hann10.csb"
    local level = tonumber(game_data.config.level)
    local maxSeatCount = game_data.maxPlayerCount

    local nn = level == 302
    local longhu100 = level == 101 or level == 102
    local sg = level == 360
    local fsp = level == 374
    local sss = level == 365 or level == 317 or level == 368
    local pdk = level == 325 or level == 345 or level == 342 or level == 353 or level == 392 or level == 501
    local mj = level == 391 or level == 308 or level == 393 or level == 371
    if nn then
        pathStr = "hall/res/FriendScircle/newTable/nn"..maxSeatCount..".csb"
    elseif sg then
        pathStr = "hall/res/FriendScircle/newTable/sg"..maxSeatCount..".csb"
    elseif sss then
        pathStr = "hall/res/FriendScircle/newTable/sss"..maxSeatCount..".csb"
    elseif pdk then
        pathStr = "hall/res/FriendScircle/newTable/pdk"..maxSeatCount..".csb"
    elseif mj then
        pathStr = "hall/res/FriendScircle/newTable/mj"..maxSeatCount..".csb"
    elseif fsp then
        pathStr = "hall/res/FriendScircle/newTable/sss6.csb"
    elseif longhu100 then
        pathStr = "hall/res/FriendScircle/newTable/longhu100.csb"
    end
    local pathStr1 = pathStr
    if device.platform == "ios" and (not isiOSVerify )then
        pathStr1 = cc.FileUtils:getInstance():getWritablePath() .. pathStr
    end
    
    if not io.exists(pathStr1) then
        if maxSeatCount == 2 then
            pathStr = "hall/res/FriendScircle/newTable/mj2.csb"
        elseif maxSeatCount == 3 then
            pathStr = "hall/res/FriendScircle/newTable/mj3.csb"
        elseif maxSeatCount == 4 then
            pathStr = "hall/res/FriendScircle/newTable/mj4.csb"
        elseif maxSeatCount == 6 then
            pathStr = "hall/res/FriendScircle/newTable/sss6.csb"
        elseif maxSeatCount == 8 then
            pathStr = "hall/res/FriendScircle/newTable/nn8.csb"
        elseif maxSeatCount == 10 then
            pathStr = "hall/res/FriendScircle/newTable/nn10.csb"
        else
            pathStr = "hall/res/FriendScircle/newTable/nn10.csb"
        end
    end
    print("table csb->", level, game_data.config.gameName, maxSeatCount, pathStr)

    local node
    if device.platform == "ios" and (not isiOSVerify )then
        node = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. pathStr)
    else
        node = cc.CSLoader:createNode(pathStr)
    end
    if node == nil then return end

    GameUtils.setNodeNameBindObj(node)
    if level == 102 then
        node.btn_game:loadTexture("hall/res/FriendScircle/newTable/image/102.png")
    end
    node.btn_game:onClick(function()
    end)
    node.btn_game:setSwallowTouches(false)
    node.btn_game:ignoreContentAdaptWithSize(true)
    if node.sp then
        node.sp:hide()
    end
    if node.btn_wanfa then
        node.btn_wanfa:hide()
    end
    for i = 1, 20 do
        local touxiang = node["touxiang" .. i]
        if touxiang then
            if touxiang.setBackGroundColorType then
                touxiang:setBackGroundColorType(0)
            end
            touxiang:setVisible(false)
        end
    end
    return node
end

return FamilyTableView