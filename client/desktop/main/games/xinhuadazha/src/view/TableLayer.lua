--[[
* author:   
* date:     2021-01-10
* describe: 新化打炸牌桌界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local Card = require(TpackageName .. ".src.view.Card") 

local ViewBaseLayer = require("hall.ViewBaseLayer")
local TableLayer = class("TableLayer", ViewBaseLayer)
local xhdzServer = import(TpackageName .. ".src.protocol.xhdzServer")

local TABLE_CARD_INTERVAL    = 25
local TABLE_CARD_INTERVAL_MY = 37
local TABLE_CARD_HEIGHT      = 69

function TableLayer:ctor()
    TableLayer.super.ctor(self, "xinhuadazha/res/xhdzMianLayer.csb")
    -- GameUtils.setNodeNameBindObj(self._csbNode)
    -- self:initUI()
    self:ShowOnClickCard()
    self:ShowAuto()

    self.btn_auto:setVisible(false)

    self.cardOriginY = 30--70  --手牌的初始高度 
    self.cardHigher = 30   --手牌高度差 
    self.cardInterval = 26  --手牌的间隙
    self.cardLineMax = 11   --一行最多多少张牌    27张或者22张  22张一行就11张

end

-- function TableLayer:initUI( )
--     self._csbNode.root.logo:ignoreContentAdaptWithSize(true)
-- end

function TableLayer:onEnter()
    self:loadAniFrame()
    self.ROutCard:setPositionY(self.ROutCard:getPositionY() - 80)
    self.LOutCard:setPositionY(self.LOutCard:getPositionY() - 80)
    self.myOutCard:setPositionY(self.myOutCard:getPositionY() - 30)
    self.TOutCard:setPositionY(self.TOutCard:getPositionY() - 30)
end

function TableLayer:loadAniFrame()
    local basePath = "xinhuadazha/res/effects/"
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."baodan/baodan.png", basePath.."baodan/baodan.plist", basePath.."baodan/baodan.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."duizi/duizi.png", basePath.."duizi/duizi.plist", basePath.."duizi/duizi.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."liandui/liandui.png", basePath.."liandui/liandui.plist", basePath.."liandui/liandui.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."sandaier/sandaier.png", basePath.."sandaier/sandaier.plist", basePath.."sandaier/sandaier.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."sandaiyi/sandaiyi.png", basePath.."sandaiyi/sandaiyi.plist", basePath.."sandaiyi/sandaiyi.ExportJson")       
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."sidaier/sidaier.png", basePath.."sidaier/sidaier.plist", basePath.."sidaier/sidaier.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."sidaisan/sidaisan.png", basePath.."sidaisan/sidaisan.plist", basePath.."sidaisan/sidaisan.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."sidaiyi/sidaiyi.png", basePath.."sidaiyi/sidaiyi.plist", basePath.."sidaiyi/sidaiyi.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."yaobuqi/yaobuqi.png", basePath.."yaobuqi/yaobuqi.plist", basePath.."yaobuqi/yaobuqi.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."shunzi/shunzi.png", basePath.."shunzi/shunzi.plist", basePath.."shunzi/shunzi.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."xipai/xipai0.png", basePath.."xipai/xipai0.plist", basePath.."xipai/xipai.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(basePath.."chuntian/chuntian0.png", basePath.."chuntian/chuntian0.plist", basePath.."chuntian/chuntian.ExportJson")
    
end

function TableLayer:clearAllOutCards()
    local panle = {"LOutCard", "ROutCard", "myOutCard", "TOutCard"}
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
    elseif viewId == 4 then
        self.TOutCard:removeAllChildren()
    end
end

function TableLayer:showOutCardsInTable(uid, cardType)
    local viewId = g_mainScene.playerInfoLayer:getViewIdByUId(uid)

    self:showOutCardsByViewId(viewId, g_mainScene.prevOutCards, cardType)
end

function TableLayer:showOutCardsByViewId(viewId, cards, cardType , relogin)
    dump(cards,"=====打出去的牌====")
    print(cards,cardType)
    if #(cards or {}) == 0 then return end
    local showCards = self:sortForShowByType(cards, cardType)
    dump(showCards,"=========显示的牌=======")
    if viewId == 1 then
        self:showOutCardsForMy(showCards, cardType, relogin)
    elseif viewId == 2 then
        self:showOutCardsForRightUser(showCards, cardType, relogin)
    elseif viewId == 3 then
        self:showOutCardsForLeftUser(showCards, cardType, relogin)
    elseif viewId == 4 then
        self:showOutCardsForTopUser(showCards, cardType, relogin)
    end
end

function TableLayer:ShowPlayCard(uid , cards , cardType)
    local viewId = g_mainScene.playerInfoLayer:getViewIdByUId(uid)
    self:showHelpCard(viewId , cards , cardType)
end


--[[
                    view == 4
    
  view == 3                             view == 2          
                    
                    view == 1
]]
function TableLayer:showHelpCard(viewId, cards, cardType)
    if #(cards or {}) == 0 then return end
    local showCards = self:sortForShowByType(cards, cardType)
    if viewId == 2 then
        self:showCardsRightUser(showCards)
    elseif viewId == 3 then
        self:showCardsLeftUser(showCards)
    elseif viewId == 4 then
        self:showCardsTopUser(showCards)
    elseif viewId == 1 then
        self:showCardsBottomUser(showCards)
    end
end

function TableLayer:showOutCardsForMy(structCards, cardType, relogin)
    local beginPos = 240-((#structCards-1)/2)*TABLE_CARD_INTERVAL_MY
    self:addCardsToPlane(structCards, beginPos, self.myOutCard, TABLE_CARD_INTERVAL_MY, cardType, relogin, true)
end

function TableLayer:showOutCardsForLeftUser(structCards, cardType,relogin)
    local beginPos = 70
    self:addCardsToPlane(structCards, beginPos, self.LOutCard, TABLE_CARD_INTERVAL, cardType, relogin, true)
end

function TableLayer:showOutCardsForRightUser(structCards, cardType,relogin )
    local beginPos = 485 - (52 + (#structCards-1)*TABLE_CARD_INTERVAL)
    self:addCardsToPlane(structCards, beginPos, self.ROutCard, TABLE_CARD_INTERVAL, cardType, relogin, true)
end

function TableLayer:showOutCardsForTopUser(structCards, cardType,relogin)
    local beginPos = 70
    self:addCardsToPlane(structCards, beginPos, self.TOutCard, TABLE_CARD_INTERVAL, cardType, relogin, true)
end


--左边也是竖着放
function TableLayer:showCardsLeftUser(structCards)
    --local beginPos = 70
    --self:addCardsToPlane(structCards, beginPos, self.LShowCard, TABLE_CARD_INTERVAL)
    self:addCardsToPlaneVertical(structCards, 142 , self.LShowCard, TABLE_CARD_INTERVAL, true)
end

--右边也是竖着放
function TableLayer:showCardsRightUser(structCards)
    --local beginPos = 485 - (52 + (#structCards-1)*TABLE_CARD_INTERVAL)
    --self:addCardsToPlane(structCards, beginPos, self.RShowCard, TABLE_CARD_INTERVAL)
    self:addCardsToPlaneVertical(structCards, 80 , self.RShowCard, TABLE_CARD_INTERVAL, false)
end


function TableLayer:showCardsTopUser(structCards)
    local beginPos = 580 - (52 + (#structCards-1)*TABLE_CARD_INTERVAL)
    self:addCardsToPlane(structCards, beginPos, self.TShowCard, TABLE_CARD_INTERVAL)
end


function TableLayer:showCardsBottomUser(structCards)
    local beginPos = 680 - (52 + (#structCards-1)*TABLE_CARD_INTERVAL_MY)

    dump(structCards,"TableLayer:showCardsBottomUser")
    self:addCardsToPlane(structCards, beginPos, self.MShowCard, TABLE_CARD_INTERVAL_MY)
end


function TableLayer:addCardsToPlaneVertical(structCards, beginPos, panle, interval, isLeft)
    panle:removeAllChildren()

    for i, v in ipairs( structCards or {}) do
        local card = Card:getCard(v, 2)
        if card then
            --card:setPosition(cc.p(beginPos + interval*(i-1), TABLE_CARD_HEIGHT))

            if isLeft == true then
                card:setRotation(-90)
            else
                card:setRotation(-90)
            end

            card:setPosition(cc.p(beginPos, interval*(i-1) - 180))
            card:addTo(panle)
        end
    end
end


local function addTextToOutPlane(panle, score,  posX,  posY)
    
    if score == 0 or score == nil then
        return
    end

    local text_str = score.."分"

    local text_pick = display.newTTFLabel({
        text = text_str,
        font = "res/fonts/fzcy.ttf",
        size = 30,
        color = cc.c3b(255,255,255),
        })

    text_pick:addTo(panle)
    text_pick:setPosition(cc.p(posX,posY))

end

local function getPickScore(structCards)

    dump(structCards,"getPickScore")
    --[1] = 5     5
    --[1] = 10    10
    --[1] = 13    k
 
    local total = 0
    for i, v in ipairs( structCards or {} ) do

        if v[1] == 5 then
            total = total + 5
        elseif v[1] == 10 then
            total = total + 10
        elseif v[1] == 13 then
            total = total + 10
        end
    end

    return total

end


function TableLayer:addCardsToPlane(structCards, beginPos, panle, interval , cardType , relogin, showPick)
    panle:removeAllChildren()
    for i, v in ipairs( structCards or {} ) do
        local card = Card:getCard(v, 2) 
        if card then
            card:setPosition(cc.p(beginPos + interval*(i-1), TABLE_CARD_HEIGHT))
            card:addTo(panle)
        end 
    end

    --展示多少分
    if showPick then
        local pickScore = getPickScore(structCards)
        addTextToOutPlane(panle, pickScore , beginPos + interval *(#structCards) / 2 - 10 ,TABLE_CARD_HEIGHT-50)
    end

    if cardType and not relogin then 
        local info = {Cardtype = cardType}
        self:PlayEffect(info , beginPos, panle)
        self:PlayCardType(info, beginPos, panle, #structCards)
    end
end

--堆叠方式 放牌
function TableLayer:addCardsToPlaneUseHeap(structCards, offsetPosX, panle)
    panle:removeAllChildren()

    --27张模式 改成每列14张
    if #structCards == 27 then
        self.cardLineMax = 14
    end

    local beginPos = self:getBeginPos(#structCards, offsetPosX)
    
    local indexCardPos = nil
    for i, v in ipairs( structCards or {} ) do
        local card = Card:getCard(v, 2)
        if card then
            indexCardPos = self:getIndexHandCardPos(i,beginPos,#structCards)
            card:setPosition(cc.p(indexCardPos.x, indexCardPos.y))

            card.index = i
            card.value = v
            card.oriPosition = cc.p(indexCardPos.x, indexCardPos.y)

            card:addTo(panle)
        end
    end
end

function TableLayer:getBeginPos( size, offsetPosX )
    if size <= self.cardLineMax then
            return {
                --640
                x = 320 - self.cardInterval*math.floor(size/2) + 30 + offsetPosX,
                y = self.cardOriginY,
            }
        else
            self.lastCardX = 320 - self.cardInterval * math.floor(self.cardLineMax/2) + 30 + self.cardInterval * (self.cardLineMax-1) + offsetPosX
            self.firstCardX = self.lastCardX - (self.cardLineMax - 1) * self.cardInterval
            return {
                x = self.lastCardX - self.cardInterval*(size%self.cardLineMax - 1),
                y = self.cardOriginY + self.cardHigher*math.floor(size/self.cardLineMax),
            }
    end
end


function TableLayer:getIndexHandCardPos(index,beginPos,allNum)
    -- 最上面一排有多少个
    if allNum <= self.cardLineMax then 
        return {
            x = beginPos.x + self.cardInterval*(index-1),
            y = beginPos.y,
        }
    elseif index <= allNum%self.cardLineMax then
        return {
            x = beginPos.x + self.cardInterval*(index-1),
            y = beginPos.y,
        }
    else
        local leftIndex = (index - allNum%self.cardLineMax - 1)%self.cardLineMax
        return {
            x = self.firstCardX + leftIndex*self.cardInterval,
            y = beginPos.y - math.ceil((index - allNum%self.cardLineMax)/self.cardLineMax)*self.cardHigher,
        }
    end
end




local CT_SINGLE                   = 1        --单牌类型
local CT_DOUBLE                   = 2        --对牌类型
local CT_THREE                    = 3        --三条类型
local CT_ONE_LINE                 = 4        --单连类型
local CT_DOUBLE_LINE              = 5        --对连类型
local CT_PANEL                    = 6        --飞机类型

local CT_BOMB_BASE                = 10       --基础炸弹
local CT_BOMB_4                   = 14       --4炸类型
local CT_BOMB_5                   = 15       --5弹类型                           
local CT_BOMB_6                   = 16       --6炸类型                           
local CT_BOMB_7                   = 17       --7炸类型                           
local CT_BOMB_8                   = 18       --8炸类型    




--local CT_PANEL_LACK               = 8        --飞机
--local CT_BOMB_CARD                = 12       --炸弹类型
--local CT_3A_BOMB                  = 12       --3个A算特殊炸弹
--local CT_BOMB_TAKE                = 9        --四带3
--local CT_FOUR_TAKE_TWO            = 10       --四带二
--local CT_FOUR_TAKE_ONE            = 11       --四带一

function TableLayer:PlayEffect( info ,  beginPos, panle)
    -- body
    local card_type = info.Cardtype
    local path_name = ""
    if CT_PANEL == card_type then 
        path_name = "doudizhu4_feiji"
    elseif CT_ONE_LINE == card_type then 
        path_name = "doudizhu4_shunzi"
    elseif card_type >= CT_BOMB_4 and card_type <=  CT_BOMB_8  then 
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

function TableLayer:PlayCardType( info, beginPos, panle, cardCount )
    -- body
    local aniName = nil
    local card_type = info.Cardtype
    --print ("info.Cardtype -------------- " , card_type)
    dump(card_type,"info.Cardtype --------------")

    if CT_ONE_LINE == card_type then 
        aniName = "shunzi" 
    elseif CT_DOUBLE == card_type then 
        aniName = "duizi"
    elseif CT_DOUBLE_LINE == card_type then 
        aniName = "liandui"  
    elseif CT_THREE == card_type and cardCount == 5 then    --3带2 5张牌
        aniName = "sandaier"
    elseif CT_THREE == card_type and cardCount == 4 then    --3带1 4张牌
        aniName = "sandaiyi"
    --elseif CT_BOMB_TAKE == card_type then 
    --    aniName = "sidaisan"
    --elseif CT_FOUR_TAKE_TWO == card_type then 
    --    aniName = "sidaier"
    --elseif CT_FOUR_TAKE_ONE == card_type then 
    --    aniName = "sidaiyi"
    end
    -- path_name = path_name .. ".png"

    if aniName == nil then return end

    local armature = ccs.Armature:create(aniName)  -- 创建动画对象
    armature:setPosition(cc.p(beginPos - 150 , TABLE_CARD_HEIGHT + 40))
    -- local card_img = ccui.ImageView:create(path_name)
    -- card_img:setPosition(cc.p(beginPos - 150 , TABLE_CARD_HEIGHT + 40))
    panle:addChild(armature , 101)

    local anim = armature:getAnimation()
    anim:playWithIndex(0, 0, 0) --第一个参数是动画表index 第二个是时间间隔 第三个是是否循环
    local function handler1(armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            armature:removeSelf()

        end
    end
    anim:setMovementEventCallFunc(handler1)

    -- local seq = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function ( ... )
    --     armature:removeFromParent()
    --     armature = nil
    -- end))

    -- card_img:runAction(seq)

end

function TableLayer:sortForShowByType(structCards, type)
    local result = {}
    if type ~= nil and type >= 5 and type <= 11 then-- type == 7 or type == 8 or type == 5 or type == 6 or  then
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
    self.showCard:setVisible(true)
    local CocosUtil = require("hall.util.CocosUtil")
    self.showCard.noScale = true
    self.showCard:onClick(handler(self, self.onClickShowCard))
    self.load_bg = 1
end


function TableLayer:showShuffleCard()
    local armature = ccs.Armature:create("xipai")  -- 创建动画对象
    armature:setPosition(cc.p(640*ViewBaseLayer:_getScaleParam2(), 360))
    self:addChild(armature, 101)

    local anim = armature:getAnimation()
    anim:playWithIndex(0, 0, 0) --第一个参数是动画表index 第二个是时间间隔 第三个是是否循环
    local function handler1(armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            armature:removeSelf()

        end
    end
    anim:setMovementEventCallFunc(handler1)
end

function TableLayer:showChuntianAni(callFunc, data)
    local armature = ccs.Armature:create("chuntian")  -- 创建动画对象
    armature:setPosition(cc.p(640*ViewBaseLayer:_getScaleParam2(), 360))
    self:addChild(armature, 101)

    local anim = armature:getAnimation()
    anim:playWithIndex(0, 0, 0) --第一个参数是动画表index 第二个是时间间隔 第三个是是否循环
    local function handler1(armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            armature:removeSelf()
            if callFunc then
                callFunc(data)
            end
        end
    end
    anim:setMovementEventCallFunc(handler1)
end

function TableLayer:LoadBg( ... )
    -- body
    if 3 == self.load_bg then 
        self.load_bg = 0
    end
    self.load_bg = self.load_bg + 1
    local cache = cc.Director:getInstance():getTextureCache():addImage(TpackageName .. "/res/image/" .. "xhdz_bg" .. self.load_bg .. ".png")
    self.tableBg:setTexture(cache)
end

function TableLayer:setShowCardBtn(isTest)
    self.showCard:setVisible(true)
end

function TableLayer:onClickShowCard()
    if isShowVerifyBt then
        g_mainScene:showSelectCardsLayer()
    end
end
function TableLayer:onClickShowAuto(event,sender)
    if tableAI[USER_INFO["uid"]] == nil then
        xhdzServer:CLIENT_COMMAND_AUTO(1)
    else
        if tableAI[USER_INFO["uid"]] == 1 then
            xhdzServer:CLIENT_COMMAND_AUTO(0)
        else
            xhdzServer:CLIENT_COMMAND_AUTO(1)
        end
    end
end
function TableLayer:ShowAuto()
    local CocosUtil = require("hall.util.CocosUtil")
    self.btn_auto:onClick(handler(self, self.onClickShowAuto))

end

function TableLayer:setWanfaDes(type)

    dump(type, "TableLayer:setWanfaDes")

    
    if type == "1" then
        self.wanfaDes:setString("去大小王,3,4")
    else 
        self.wanfaDes:setString("")
    end

    --local str = type == 1 and "去大小王,3,4" or "常规牌"
    --self.wanfaDes:setString(str)
end

function TableLayer:onExit()
    -- body
end

return TableLayer