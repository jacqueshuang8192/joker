--[[
* author:   zwm
* date:     2020-05-28
* describe: 510k小结算界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local ViewBaseLayer = require("hall.ViewBaseLayer")
local SingleResultLayer = class("SingleResultLayer", ViewBaseLayer)
local Card = require(TpackageName..".src.view.Card")
local PDKServer = import(TpackageName .. ".src.protocol.PDKServer")

local CELL_POS_X = 35
local CELL_POS_Y_BEGIN = 493
local CELL_POS_Y_INTERVAL = 124

function SingleResultLayer:ctor(data)
    SingleResultLayer.super.ctor(self, "pdk/res/SingleResultLayer.csb")
    self._data = data
    --dump(data, "SingleResultLayer == ")
    self:__initUI()
    self:showResult(self._data.playerList)
end

function SingleResultLayer:__initUI()
    self.rankFlag:setVisible(false)
    self.light1:setVisible(false)
    self.light2:setVisible(false)
    self.light3:setVisible(false)
    self.light4:setVisible(false)
    -- self.cell1:setVisible(false)
    -- self.cell2:setVisible(false)
    -- self.cell3:setVisible(false)
    -- self.cell4:setVisible(false)
    dump(USER_INFO, "USER_INFO == ")
    -- self["light"..USER_INFO["seat_id"]]:setVisible(true)
end

function SingleResultLayer:showResult(data)
    if data == nil then return end
    dump(data, "showResult(data) == ")
    for i, v in ipairs(data) do
        local item = require("pdk.src.view.SingleCell").new(v)
        item:setVisible(true)
        item:setPosition(cc.p(35, 494- (i-1)*124))
        -- self:initItem(item, v)
        self.content:addChild(item)
    end
    self:showOtherCard(self._data.otherCards)
end

function SingleResultLayer:initItem(obj, info)
    local cell = obj:getChildByName("cell")
    cell:getChildByName("tScore"):setString(info.Turningscore)
    self:setUserInfo(cell, info)
    -- if next(info.Cardbuf) then
    --     self:showHandlerCards(cell, info.Cardbuf)
    -- end
end

-- function SingleResultLayer:showHandlerCards(obj, cards)
--     if cards == nil or next(cards) == nil then return end
--     local outCards = {}
--     local surCards = {}
--     local tmp = {}
--     for i,v in ipairs(cards) do
--         if i > 2 and v ~= 0 and cards[i-1] == 0 and cards[i-2] == 0 then
--             for j = i, #cards do
--                 if cards[j] ~= 120 and cards[j] ~= 0 then
--                     table.insert(surCards, cards[j])
--                 else
--                     break
--                 end
--             end
--             break
--         end
--     end

--     for i,v in ipairs(cards) do
--         if i > 1 and v ~= 0 and cards[i-1] == 0 then
--             for j = i, #cards do
--                 if cards[j] ~= 0 and cards[j] ~= 120 then
--                     table.insert(tmp, cards[j])
--                 else
--                     if #tmp ~= 0 then 
--                         table.insert(outCards, tmp)
--                         tmp = {}
--                         break
--                     end
--                 end
--             end
--             -- break
--         elseif v == 120 then
--             break
--         end
--     end


--     for i,v in ipairs(surCards) do
--         local value, kind = Card:init(v)
--         local sp = Card:getSmallCard(value, kind)
--         if sp then
--             sp:setPosition(cc.p(350+ 24*(i-1), 95))
--             obj:addChild(sp)
--         end
--     end

--     for i,v in ipairs(outCards) do
--         for j,v1 in ipairs(v) do
--             local value, kind = Card:init(v)
--             local sp = Card:getSmallCard(value, kind)
--             if sp then
--                 sp:setPosition(cc.p(350+ 24*(j-1)+ 50*(i-1), 45))
--                 obj:addChild(sp)
--             end
--         end
--     end
-- end

function SingleResultLayer:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    strUrl = string.sub(strUrl,nPos+1,string.len(strUrl))
    nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    return strPic..".jpg"
end

function SingleResultLayer:setUserInfo(obj, info)
    local userInfo = nil
    if USER_INFO["uid"] == info.uid then
        userInfo = USER_INFO
    else
        userInfo = DDZ_USERINFO_TABLE[info.uid]
    end
    if userInfo == nil then return end

    obj:getChildByName("name"):setString(require("hall.GameCommon"):formatNick(userInfo.nick, 4))

    local strHead = self:getUnformatPic(userInfo.icon_url)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        obj:getChildByName("headImg"):loadTexture(imgFullPath, 0)
    end
    -- body
end

--显示2人玩时 第3手牌
function SingleResultLayer:showOtherCard(cards)
    dump(cards, "otherCards == ")
    if cards ~= nil then
        self.light3:setVisible(true)
    end
    for i,v in ipairs(cards or {}) do
        local value, kind = Card:init(v)
        local sp = Card:getSmallCard(value, kind)
        if sp then
            sp:setPosition(cc.p(350 + 30*(i-1), 38))
            self.light3:addChild(sp)
        end
    end
end

function SingleResultLayer:onClickBtnAgain(sender, event)
    self:removeSelf()
	-- CardPlaneOperator:clearGameDatas()
    PDKServer:CLI_READY_GAME(1)
end

function SingleResultLayer:onClickBtnShare(sender, event)
    local paras = {}
    paras["showType"] = 2;
    paras["desc"] = " "
    paras["imagePath"] = "screen"
    paras["name"] = "分享结果"
    paras["url"] = appDownLoadAddress
    local ShareLayer = require("hall.share.ShareLayer").new(paras)
    if ShareLayer then
        ShareLayer:onClickBtnToFriend()
        ShareLayer:removeSelf()
    end
end

function SingleResultLayer:onClickBtnShuffle(sender, event)
    self:removeSelf()
    -- CardPlaneOperator:clearGameDatas()
    PDKServer:CLIENT_USER_SHUFFLE()
    PDKServer:CLI_READY_GAME(1)
    
end

function SingleResultLayer:onExit()
    -- body
end

return SingleResultLayer