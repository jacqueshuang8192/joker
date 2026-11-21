--[[
* author:   zwm
* date:     2019-04-11
* describe: 跑得快牌桌界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local Card = require(TpackageName .. ".src.view.Card") 

local ViewBaseLayer = require("hall.ViewBaseLayer")
local TableLayer = class("TableLayer", ViewBaseLayer)
local YJQFServer = import(TpackageName .. ".src.protocol.YJQFServer")

local TABLE_CARD_INTERVAL    = 26
local TABLE_CARD_INTERVAL_MY = 37
local TABLE_CARD_HEIGHT      = 69

local CT_ONE_LINE                 = 4        --顺子类型
local CT_THREE                    = 5        --三带二和飞机
local CT_BOMB_4                   = 6        --
local CT_BOMB_5                   = 7        --
local CT_BOMB_6                   = 8        --
local CT_BOMB_7                   = 9        --
local CT_BOMB_8                   = 10       --
local CT_BOMB_9                   = 11       --
local CT_BOMB_10                  = 12       --
local CT_BOMB_11                  = 13       --
local CT_BOMB_12                  = 14       --

function TableLayer:ctor()
    TableLayer.super.ctor(self, "yuanjiangqianfen/res/YJQFMianLayer.csb")
    self:ShowOnClickCard()
    self:ShowAuto()
end

function TableLayer:clearAllOutCards()
    local panle = {"LOutCard", "ROutCard", "myOutCard"}
    for i, v in ipairs( panle ) do
        self[v]:removeAllChildren()
    end
end

function TableLayer:clearTableOutCardsByViewId(uid)
    local viewId = g_mainScene.playerInfoLayer:getViewIdByUId(uid)
    if viewId == 1 then
        self.myOutCard:removeAllChildren()
    elseif viewId == 2 then
        self.ROutCard:removeAllChildren()
    elseif viewId == 3 then
        self.LOutCard:removeAllChildren()
    end
end

function TableLayer:showOutCardsInTable(uid, cardType)
    local viewId = g_mainScene.playerInfoLayer:getViewIdByUId(uid)

    self:showOutCardsByViewId(viewId, g_mainScene.prevOutCards, cardType)
end

function TableLayer:showOutCardsByViewId(viewId, cards, cardType , relogin, offsetX)
    dump(cards,"=====打出去的牌====")
    print(cards,cardType)
    if #(cards or {}) == 0 then return end
    local showCards = self:sortForShowByType(cards, cardType)
    dump(showCards,"=========显示的牌=======")
    if viewId == 1 then
        self:showOutCardsForMy(showCards, cardType, relogin)
    elseif viewId == 2 then
        self:showOutCardsForRightUser(showCards, cardType, relogin, offsetX)
    elseif viewId == 3 then
        self:showOutCardsForLeftUser(showCards, cardType, relogin, offsetX)
    end
end

function TableLayer:ShowPlayCard(uid , cards , cardType)
    local viewId = g_mainScene.playerInfoLayer:getViewIdByUId(uid)
    self:showHelpCard(viewId , cards , cardType)
end

function TableLayer:showHelpCard(viewId, cards, cardType, offsetX)
    if #(cards or {}) == 0 then return end 
    local showCards = self:sortForShowByType(cards, cardType)
    if viewId == 2 then
        self:showCardsRightUser(showCards)
    elseif viewId == 3 then
        self:showCardsLeftUser(showCards)
    end
end

function TableLayer:showOutCardsForMy(structCards, cardType, relogin)
    local beginPos = 240-((#structCards-1)/2)*TABLE_CARD_INTERVAL_MY
    self:addCardsToPlane(structCards, beginPos, self.myOutCard, TABLE_CARD_INTERVAL_MY, cardType, relogin)
end

function TableLayer:showOutCardsForLeftUser(structCards, cardType,relogin, offsetX)
    local beginPos = 52
    if offsetX then
        beginPos = beginPos + offsetX
    end
    self:addCardsToPlane(structCards, beginPos, self.LOutCard, TABLE_CARD_INTERVAL, cardType, relogin)
end

function TableLayer:showOutCardsForRightUser(structCards, cardType,relogin, offsetX)
    local beginPos = 485 - (52 + (#structCards-1)*TABLE_CARD_INTERVAL)
    if offsetX then
        beginPos = beginPos - offsetX
    end
    self:addCardsToPlane(structCards, beginPos, self.ROutCard, TABLE_CARD_INTERVAL, cardType, relogin)
end

function TableLayer:showCardsLeftUser(structCards)
    local beginPos = 52
    self.LShowCard:setRotation(90)
    self.LShowCard:setPositionX(130*self:_getScaleParam2())
    self.LShowCard:setPositionY(720)
    self.LShowCard:setScale(0.5)
    self:addCardsToPlane(structCards, beginPos, self.LShowCard, TABLE_CARD_INTERVAL)
end

function TableLayer:showCardsRightUser(structCards)
    local beginPos = 485 - (52 + (#structCards-1)*TABLE_CARD_INTERVAL)
    self.RShowCard:setRotation(-90)
    self.RShowCard:setPositionX(1100*self:_getScaleParam2())
    self.RShowCard:setPositionY(480)
    self.RShowCard:setScale(0.5)
    self:addCardsToPlane(structCards, beginPos, self.RShowCard, TABLE_CARD_INTERVAL)
end

function TableLayer:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end


function TableLayer:addCardsToPlane(structCards, beginPos, panle, interval , cardType , relogin)
    panle:removeAllChildren()
    for i, v in ipairs( structCards or {} ) do
        local card = Card:getCard(v, 2) 
        if card then
            card:setPosition(cc.p(beginPos + interval*(i-1), TABLE_CARD_HEIGHT))
            card:addTo(panle)
        end 
    end

    if cardType and cardType >= CT_BOMB_4 then
        local bgBomb = ccui.ImageView:create("hall/scene/res/singlered/image/tip/niukind_bottom.png")
        bgBomb:setScale(0.8)
        local htmlLabel = ccui.Text:create()
        htmlLabel:setString(string.format("%d炸", cardType - 2))
        htmlLabel:setCascadeOpacityEnabled(true)

        htmlLabel:setFontName("hall/res/font/FZY3JW.TTF")
        htmlLabel:setFontSize(32)
        bgBomb:setPosition(beginPos + interval*(#(structCards)/2) - 20, TABLE_CARD_HEIGHT - 10)
        htmlLabel:setPosition(beginPos + interval*(#(structCards)/2)- 20, TABLE_CARD_HEIGHT - 10)
        bgBomb:addTo(panle)
        htmlLabel:addTo(panle)
    end

    if cardType and not relogin then 
        local info = {Cardtype = cardType}
        -- self:PlayEffect(info , beginPos, panle)
        self:PlayCardType(info, beginPos, panle)
    end
end

function TableLayer:showDiCards(cards)
    self.diCardsShow:removeAllChildren()
    local beginPos = -200
    for i,v in ipairs(cards) do
        local card = Card:getCard(v, 1)
        card:addTo(self.diCardsShow)
        card:setPosition(cc.p(beginPos + (i - 1)*80, 0))
        card:setScale(0.5)
    end
    local child = self.diCardsShow:getChildren()
    for i, v in ipairs(child or {}) do
        if v.value[1] == 5 or v.value[1] == 10 or v.value[1] == 13 then
            local pos = v:getPosition()
            v:runAction(transition.sequence({
                cc.MoveTo:create(0.5 , cc.p(pos.x, pos.y + 20)),
                cc.CallFunc:create(function()
            end),
            }))
        end
    end
    
    self.diCardsShow:runAction(transition.sequence({
            cc.DelayTime:create(4),
            cc.CallFunc:create(function()
                g_mainScene.playerInfoLayer:showSingleResult(g_mainScene.playerInfoLayer._singleResultData)
                g_mainScene.playerInfoLayer:clearDeskForOver()
                self.diCardsShow:removeAllChildren()
                self:clearAllOutCards()
        end),
        }))
end

function TableLayer:PlayEffect( info ,  beginPos, panle)
    -- body
    local card_type = info.Cardtype
    local path_name = ""
    if CT_ONE_LINE == card_type then 
        path_name = "doudizhu4_shunzi"
    elseif CT_BOMB_4 <= card_type and CT_BOMB_12 >= card_type then 
        path_name = "doudizhu4_zhadan"
    end

    if path_name == "" then return end
    local path = TpackageName .. "/res/effects/" .. path_name .. "/" .. path_name
    local effectManage = ccs.ArmatureDataManager:getInstance() 
    effectManage:addArmatureFileInfo(path .. "0.png", path .. "0.plist" , path .. ".ExportJson")

    local armatureObj = ccs.Armature:create(path_name)
    print ("PlayEffect", beginPos)
    armatureObj:setPosition(cc.p(beginPos + 50 , TABLE_CARD_HEIGHT - 100))

    armatureObj:getAnimation():playWithIndex(0)
    armatureObj:getAnimation():setMovementEventCallFunc(handler(self , self.RemoveEffect))
    panle:addChild(armatureObj , 100)

end

function TableLayer:RemoveEffect( Armature, MovementEventType, name )
    -- body
    --1.2代表帧动画播放完毕
    if 2 == MovementEventType then
        Armature:removeFromParent()
        Armature = nil
    end
end

function TableLayer:PlayCardType( info, beginPos, panle )
    do return end
    -- body
    local card_type = info.Cardtype
    print ("info.Cardtype" , card_type)
    local path_name = TpackageName .. "/res/image/card_type/"
    if CT_ONE_LINE == card_type then 
        path_name = path_name .. "shunzi" 
    elseif CT_DOUBLE == card_type then 
        path_name = path_name .. "duizi"
    elseif CT_DOUBLE_LINE == card_type then 
        path_name = path_name .. "liandui"  
    elseif CT_THREE_TAKE_TOW == card_type then 
        path_name = "three_take_two"
    elseif CT_BOMB_TAKE == card_type then 
        path_name = "bomb_take_three"
    elseif CT_FOUR_TAKE_TWO == card_type then 
        path_name = "bomb_take_two"
    elseif CT_FOUR_TAKE_ONE == card_type then 
        path_name = "bomb_take_one"
    end
    path_name = path_name .. ".png"

    local card_img = ccui.ImageView:create(path_name)
    card_img:setPosition(cc.p(beginPos - 150 , TABLE_CARD_HEIGHT + 40))
    panle:addChild(card_img , 101)

    local seq = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function ( ... )
        card_img:removeFromParent()
        card_img = nil
    end))

    card_img:runAction(seq)

end

function TableLayer:sortForShowByType(structCards, type)
    local result = {}
    if type == 7 or type == 8 or type == 9 or type == 10 then
        for i, v in ipairs( structCards ) do
            if result[v[1]] == nil then
                result[v[1]] = {}
                table.insert(result[v[1]], v)
            else
                table.insert(result[v[1]], v)
            end
        end
        
        local tmp = {} 
        for k, v in pairs( result ) do
            if #v >= 3 then
                for i = 1, #v do
                    table.insert(tmp, v[i])
                end
            end
        end
        if type == 7 or type == 8 then
            Card:sortCard(tmp)
            local tmp1 = {} 
            for k, v in pairs( result ) do
                if #v < 3 then
                    for i = 1, #v do
                        table.insert(tmp1, v[i])
                    end
                end
            end
            Card:sortCard(tmp1)
            dump(tmp1)
            for i = 1, #tmp1 do
                table.insert(tmp, tmp1[i])
            end
            return tmp
        elseif type == 9 then
            Card:sortCard(structCards)
            -- return self:sortForPlane( structCards )
            return structCards
        elseif type == 10 then
            return self:sortForBombTake(structCards)
        end
    else
        result = clone(structCards)
        Card:sortCard(result)
        return result
    end

    return result
end

function TableLayer:sortForPlane( structCards )
    local tempLst = clone(structCards)
    Card:sortCard(tempLst)
    local result = {} 
    for i, v in ipairs( tempLst ) do
        if result[v[1]] == nil then
            result[v[1]] = {}
            table.insert(result[v[1]], v)
        else
            table.insert(result[v[1]], v)
        end
    end
    local tmpResult1 = {} 
    local tmpResult2 = {} 
    if #structCards > 10 then
        local tempArr = clone(result)
        for k, v in pairs( result ) do
            if #v >= 3 and #(result[k-1] or {}) >= 3 and #(result[k-2] or {}) >= 3 then
                table.insert(tmpResult1, v[1])
                table.insert(tmpResult1, v[2])
                table.insert(tmpResult1, v[3])
                table.insert(tmpResult1, result[k-1][1])
                table.insert(tmpResult1, result[k-1][2])
                table.insert(tmpResult1, result[k-1][3])
                table.insert(tmpResult1, result[k-2][1])
                table.insert(tmpResult1, result[k-2][2])
                table.insert(tmpResult1, result[k-2][3])

                table.remove(tempArr,k)
                table.remove(tempArr,k-1)
                table.remove(tempArr,k-2)
            end
        end

        result = clone(tempArr)

        for k, v in pairs( result ) do
            if #v > 3 then
                table.insert(tmpResult2, v[4])
            else
                for i = 1, #v do
                    table.insert(tmpResult2, v[i])
                end
            end
        end

        Card:sortCard(tmpResult2)
        for i, v in ipairs( tmpResult2 ) do
            table.insert(tmpResult1, v)
        end
        return tmpResult1
    else
        local tempArr = clone(result)
        for k, v in pairs( result ) do
            if #v >= 3 and #(result[k-1] or {}) >= 3  then
                table.insert(tmpResult1, v[1])
                table.insert(tmpResult1, v[2])
                table.insert(tmpResult1, v[3])
                table.insert(tmpResult1, result[k-1][1])
                table.insert(tmpResult1, result[k-1][2])
                table.insert(tmpResult1, result[k-1][3])

                table.remove(tempArr,k)
                table.remove(tempArr,k-1)
            end
        end

        result = clone(tempArr)

        for k, v in pairs( result ) do
            if #v > 3 then
                table.insert(tmpResult2, v[4])
            else
                for i = 1, #v do
                    table.insert(tmpResult2, v[i])
                end
            end
        end

        Card:sortCard(tmpResult2)
        for i, v in ipairs( tmpResult2 ) do
            table.insert(tmpResult1, v)
        end
        return tmpResult1
    end
end

--4带3
function TableLayer:sortForBombTake(structCards)
    local cardSize = #(structCards or {})
    local result = {}
    local tmpResult1 = {} 
    local tmpResult2 = {}
    for i, v in ipairs( structCards ) do
        if result[v[1]] == nil then
            result[v[1]] = {}
            table.insert(result[v[1]], v)
        else
            table.insert(result[v[1]], v)
        end
    end
    if cardSize <= 7 then
        for k, v in pairs( result ) do
            if #v == 4 then
                for i, v1 in ipairs( v ) do
                    table.insert(tmpResult1, v1)
                end
            else
                for i, v1 in ipairs( v ) do
                    table.insert(tmpResult2, v1)
                end
                
            end
        end
        Card:sortCard(tmpResult2)
        for i, v in ipairs( tmpResult2 ) do
            table.insert(tmpResult1, v)
        end

        return tmpResult1
    elseif cardSize > 7 then
        for k, v in pairs( result ) do
            if #v >= 4 and #(result[k-1] or {}) >= 4  then
                table.insert(tmpResult1, v[1])
                table.insert(tmpResult1, v[2])
                table.insert(tmpResult1, v[3])
                table.insert(tmpResult1, v[4])
                table.insert(tmpResult1, result[k-1][1])
                table.insert(tmpResult1, result[k-1][2])
                table.insert(tmpResult1, result[k-1][3])
                table.insert(tmpResult1, result[k-1][4])
            else
                for i = 1, #v do
                    table.insert(tmpResult2, v[i])
                end
            end
        end

        Card:sortCard(tmpResult2)
        for i, v in ipairs( tmpResult2 ) do
            table.insert(tmpResult1, v)
        end
        return tmpResult1
    end
end

function TableLayer:ShowOnClickCard()
    -- self.showCard:setVisible(false)
    -- local CocosUtil = require("hall.util.CocosUtil")
    -- self.showCard.noScale = true
    -- self.showCard:onClick(handler(self, self.onClickShowCard))
    -- self.load_bg = 1
end

function TableLayer:LoadBg( ... )
    -- body
    if self.load_bg == nil then
        self.load_bg = 1
    end
    if 3 == self.load_bg then 
        self.load_bg = 0
    end
    self.load_bg = self.load_bg + 1
    local cache = cc.Director:getInstance():getTextureCache():addImage(TpackageName .. "/res/image/" .. "pdk_bg" .. self.load_bg .. ".png")
    self.tableBg:setTexture(cache)
end

function TableLayer:onClickShowCard()
    YJQFServer:CLIENT_SEND_MINGPAI_REMIND()
end
function TableLayer:onClickShowAuto(event,sender)
    if tableAI[USER_INFO["uid"]] == nil then
        YJQFServer:CLIENT_COMMAND_AUTO(1)
    else
        if tableAI[USER_INFO["uid"]] == 1 then
            YJQFServer:CLIENT_COMMAND_AUTO(0)
        else
            YJQFServer:CLIENT_COMMAND_AUTO(1)
        end
    end
end
function TableLayer:ShowAuto()
    local CocosUtil = require("hall.util.CocosUtil")
    self.btn_auto:onClick(handler(self, self.onClickShowAuto))

end
function TableLayer:onExit()
    -- body
end

return TableLayer