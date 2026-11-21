--
-- Author: Your Name
-- Date: 2017-09-05 19:57:49
--
local UserInfoPlaneOperator = class("UserInfoPlaneOperator")

function UserInfoPlaneOperator:init(headplane)
    headplane:setVisible(false)

    self:beginPlayCard(headplane, false)

    self:showRemainCardsNum(headplane, 0, false)
    self:showLandLord(headplane, nil, "clear")
    self:updateJoker(headplane, nil, "clear")
    self:showNetworkImg(headplane, false)
    self:setDoubleFlag(headplane, 1, false)
    self:showAlarm(headplane, false)
    self:setScore(headplane, "bonus", 0)
    local chips = headplane:getChildByName("chips"):setVisible(false)
    headplane:getChildByName("txt_bonus"):setString("0")
    headplane:getChildByName("jianfen_txt"):setString("0")
    headplane:getChildByName("gold_mine"):setString("0")
end

function UserInfoPlaneOperator:clearGameDatas(playerType, headplane)
    self:showLandLord(headplane, nil, "clear")
    self:updateJoker(headplane, nil, "clear")
    self:setDoubleFlag(headplane, 1, false)
    self:showRemainCardsNum(headplane, 0, false)
    self:showAlarm(headplane, false)
    self:clearUserDesk(playerType, headplane)
    self:setScore(headplane, "bonus", 0)
end

function UserInfoPlaneOperator:addScore(headplane, typ, score)
    local txt = headplane:getChildByName(typ == "bonus" and "txt_bonus")
    self:setScore(headplane, typ, tonumber(txt:getString()) + score)

    local txt1 = headplane:getChildByName(typ == "bonus" and "jianfen_txt")
    self:setScore(headplane, typ, tonumber(txt1:getString()) + score)
end

function UserInfoPlaneOperator:setScore(headplane, typ, score)
    local txt = headplane:getChildByName(typ == "bonus" and "txt_bonus")
    txt:setString(tostring(score))

    local txt1 = headplane:getChildByName(typ == "bonus" and "jianfen_txt")
    txt1:setString(tostring(score))
end

function UserInfoPlaneOperator:clearUserDesk(playerType, headplane)
    if layout_ui:getChildByName("tt" .. tostring(playerType)) then
        layout_ui:removeChildByName("tt" .. tostring(playerType))
    end

    if cardScene:getChildByName("clock") then
        cardScene:getChildByName("clock"):setVisible(false)
    end
end

function UserInfoPlaneOperator:removePlayer(playerType, headplane)
    headplane:setVisible(false)
    self:clearGameDatas(playerType, headplane)
end

function UserInfoPlaneOperator:showAlarm(headplane, flag)
    local alarm = headplane:getChildByName("baojing")

    if flag == false then
        flag = false
    else
        flag = true
    end

    if alarm then
        alarm:setVisible(flag)
    else
        local s = 0.3
        alarm = require("TaiHeGuoZha.Animation"):Alarm()
        alarm:addTo(headplane)
        alarm:setName("baojing")
        alarm:setScale(s)
        alarm:setVisible(flag)
        alarm:setPosition(cc.p(40, 108)) --alarm:getContentSize().height/4*s-20
    end
end

function UserInfoPlaneOperator:showPlayerInfo(playerType, headplane, userInfo)
    --dump1(userInfo, "userInfo")

    local uid = userInfo["uid"]
    local icon_url = userInfo["icon_url"]
    local sex = userInfo["sex"]
    local coins = userInfo["coins"]
    local head = headplane:getChildByName("head")
    local nickName = userInfo["nick"] --and require("hall.GameCommon"):formatNick(userInfo["nick"], 5) or "未知昵称"

    local size = head:getContentSize()
    ReqMgr:getAddress( userInfo.latitude, userInfo.longitude, userInfo.uid)
    require("hall.GameCommon"):getUserHead(icon_url, uid, sex, head, size.width, false,nickName,false,userInfo.ip)

    headplane:setVisible(true)
    headplane.uid = uid

    local txt_nick = headplane:getChildByName("nickName_txt")

    txt_nick:setString(require("hall.GameCommon"):formatNick(nickName))

    self:updateUserCoins(headplane, coins)

    return head
end

function UserInfoPlaneOperator:updateUserCoins(plane, coins)
    if not plane then
        return
    end
    local chips = coins/100

    plane:getChildByName("gold_mine"):setString(chips)
end

--显示庄家Flag
function UserInfoPlaneOperator:showLandLord(headplane, _type, flag)
    local landlord_flag = headplane:getChildByName("landlord_flag")
    dump(_type, "tool.utils.load_type======")
    if flag == "clear" then
        landlord_flag:setVisible(false)
    elseif _type == "LandLord" then
        landlord_flag:setVisible(true)
        landlord_flag:loadTexture("TaiHeGuoZha/res/images/help.png")
    elseif _type == "Farmer" then
        landlord_flag:setVisible(false)
    elseif _type == "Banker" then
        landlord_flag:setVisible(true)
        landlord_flag:loadTexture("TaiHeGuoZha/res/images/banker.png")
    elseif _type == "du" then
        landlord_flag:setVisible(true)
        landlord_flag:loadTexture("TaiHeGuoZha/res/images/du.png")
    end
end

function UserInfoPlaneOperator:showNetworkImg(headplane, flag)
    local network_img = headplane:getChildByName("network_img")
    if network_img then
        network_img:setVisible(flag)
    end
end

function UserInfoPlaneOperator:updateCoin(playerType, headplane, value)
    local AllFen = headplane:getChildByName("gold_mine")
    if AllFen ~= nil then
        AllFen:setVisible(true)
        AllFen:setString(require(NumberUtil_filePath):toWan(value / 100, 99999, "w"))
    end
end

--奖分
function UserInfoPlaneOperator:updateJiang(headplane, value)
    headplane:getChildByName("txt_bonus"):setString(tostring(value))
end

--桌面显示的分
function UserInfoPlaneOperator:updatetxtFen(headplane, value, flag)
    txt_jianfen = cardScene:getChildByName("txt_jianfen"):setString(tostring(value))
    txt_jianfen:setVisible(true)
end

--显示你的总得分
function UserInfoPlaneOperator:updateAllFen(playerType, headplane, value)
    local AllFen = headplane:getChildByName("gold_mine")
    if AllFen ~= nil then
        AllFen:setVisible(true)
        AllFen:setString(require(NumberUtil_filePath):toWan(value / 100, 99999, "w"))
    end
end

--显示头奖Flag
function UserInfoPlaneOperator:updateJoker(headplane, _type, flag)
    if headplane ~= nil then
        dump(headplane, "headplane ===== ")
        local JokerPos = headplane:getChildByName("toujiangflag")
        dump(_type, "toujiangtype ===== ")
        if flag == "clear" then
            JokerPos:setVisible(false)
        elseif _type == "Joker" then
            JokerPos:setVisible(true)
            JokerPos:loadTexture("TaiHeGuoZha/res/images/toujiang.png")
        end
    end
end

--玩家自己的捡分
function UserInfoPlaneOperator:updateFen(headplane, value)
    headplane:getChildByName("jianfen_txt"):setString(tostring(value))
end

function UserInfoPlaneOperator:setDoubleFlag(headplane, times, flag)
    local txt_player_double = headplane:getChildByName("txt_player_double")
    if txt_player_double then
        txt_player_double:setVisible(flag)
    end
end

function UserInfoPlaneOperator:showRemainCardsNum(headplane, value, flag)
    local cardNumBack = headplane:getChildByName("cardNumBack")

    if cardNumBack then
        cardNumBack:setVisible(flag)
        if value then
            local cardNum_txt = cardNumBack:getChildByName("cardNum")
            cardNum_txt:setVisible(true)
            cardNum_txt:setString(value)
        else
            cardNumBack:getChildByName("cardNum"):setVisible(true)
        end
    end
end

function UserInfoPlaneOperator:beginPlayCard(headplane, flag)
    local img = headplane:getChildByName("turn_img")

    if img then
        if flag == true then
            img:setVisible(true)

            local showTurnAc =
                cc.CallFunc:create(
                function()
                    if img:getOpacity() > 220 then
                        img:fadeTo(1.3, 50)
                    elseif img:getOpacity() < 80 then
                        img:fadeTo(1.3, 255)
                    end
                end
            )

            seqAc = cc.Sequence:create(cc.DelayTime:create(1.3), showTurnAc)
            img:runAction(cc.RepeatForever:create(seqAc))
        else
            img:stopAllActions()
            img:setVisible(false)
        end
    end
end

return UserInfoPlaneOperator
