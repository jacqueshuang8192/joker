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
local zixidadunServer = import(TpackageName .. ".src.protocol.zixidadunServer")

local TABLE_CARD_INTERVAL    = 26
local TABLE_CARD_INTERVAL_MY = 37
local TABLE_CARD_HEIGHT      = 69

function TableLayer:ctor()
    TableLayer.super.ctor(self, "zixidadun/res/zixidadunMianLayer.csb")

        GameUtils.setNodeNameBindObj(self._csbNode)
    display.doLayout(self._csbNode)

    -- GameUtils.setNodeNameBindObj(self._csbNode)
    -- self:initUI()
    --self.showCard:setVisible(false)
    self:ShowOnClickCard()
    self:ShowAuto()
    self.Node_Open:setVisible(false)
    self.Node_NotOpen:setVisible(false)
    --self.btn_familySet:onClick(handler(self, self.onClickBtnFamilySet), true)
   -- g_mainScene.playerInfoLayer.outCardBtnNode:getChildByName("btnQuXiao"):onClick(handler(self, self.onClickBtnQuXiao), true)
   self.btn_layer:getChildByName("Button_510k"):onClick(handler(self, self.onClickBtn510K), true)
   self.btn_layer:getChildByName("Button_zhankai"):onClick(handler(self, self.onClickBtnzhankai), true)
   self.btn_layer:getChildByName("Button_fold"):onClick(handler(self, self.onClickBtnfold), true)
   self.btn_layer:getChildByName("Button_sort"):onClick(handler(self, self.onClickBtnSort), true)
   self.btn_layer:getChildByName("Button_zhankai"):setVisible(false)
   self.btn_layer:getChildByName("BtnMsg"):onClick(handler(self, self.loadGameMsgLayer), true)
   self:addVoiceRecordEvent(self.btn_layer:getChildByName("BtnVoice"))
end

-- function TableLayer:initUI( )
--     self._csbNode.root.logo:ignoreContentAdaptWithSize(true)
-- end

function TableLayer:onEnter()
    self:loadAniFrame()
    self.ROutCard:setPositionY(self.ROutCard:getPositionY() - 80)
    self.LOutCard:setPositionY(self.LOutCard:getPositionY() - 80)
    self.myOutCard:setPositionY(self.myOutCard:getPositionY() - 30)
end

function TableLayer:loadAniFrame()
    local basePath = "zixidadun/res/effects/"
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

--[[function TableLayer:onClickBtn510K(uid, cardType)
    g_mainScene.myHandlerCards
end--]]

function TableLayer:showOutCardsInTable(uid, cardType)
    g_mainScene.playerInfoLayer:initOutCardLayer(false)

    local viewId = g_mainScene.playerInfoLayer:getViewIdByUId(uid)

    self:showOutCardsByViewId(viewId, g_mainScene.prevOutCards, cardType)
end

function TableLayer:onClickBtn510K()
    --g_mainScene.playerInfoLayer:JustShowOutLayer(true)
    g_zxddGameData.IsSortByScore=false
    if not g_zxddGameData.Select_510k then
        g_zxddGameData.Select_510k=true
        g_mainScene.playerInfoLayer:Select510K()
        if g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then 
        g_mainScene.playerInfoLayer.outcard_bg:setVisible(true)
    end
    else
        self:init510_k()
    end
end

function TableLayer:init510_k()
    if g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then
        g_zxddGameData.Select_510k=false
        g_mainScene.playerInfoLayer:initOutCardLayer(false)
        g_mainScene.playerInfoLayer.outcard_bg:removeAllChildren()
        g_mainScene.playerInfoLayer:testOutCards()
        g_mainScene.playerInfoLayer.outcard_bg:setVisible(false)
    else
        g_zxddGameData.Select_510k=false
        local children=g_mainScene.playerInfoLayer.handCardPanle:getChildren()
        for i,v in ipairs(children) do
            if v.selected==1 then
                v.selected=0
                v:toDown()
            end
        end
    end
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
    end
end

function TableLayer:ShowPlayCard(uid , cards , cardType)
    local viewId = g_mainScene.playerInfoLayer:getViewIdByUId(uid)
    self:showHelpCard(viewId , cards , cardType)
end


--设置信息栏
function TableLayer:SetHandDunScore(HandDunScore)
  self.btn_layer:getChildByName("Image_HandDunScore"):getChildByName("Text_Handdun_sore"):setString(HandDunScore)
end

function TableLayer:SetDunScore(data)
  self.btn_layer:getChildByName("Image_dunFen"):getChildByName("Text_dun_sore"):setString(data)
end

function TableLayer:SetAllScore(data)
    self.btn_layer:getChildByName("Image_dunFen"):getChildByName("Text_dun_sore"):setString("0")
  self.btn_layer:getChildByName("Image_AllScore"):getChildByName("Text_All_sore"):setString(data)
end

function TableLayer:SetnickName(data)
  self.btn_layer:getChildByName("Image_6"):getChildByName("Text_myname"):setString(data)
end

function TableLayer:SetXinXiLan(Alls,Duns,hDuns)
    self:SetAllScore(Alls)
    self:SetDunScore(Duns)
    self:SetHandDunScore(hDuns)
end

function TableLayer:showHelpCard(viewId, cards, cardType)
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
    g_mainScene.playerInfoLayer.outcard_bg:setVisible(false)
end

function TableLayer:showOutCardsForLeftUser(structCards, cardType,relogin)
    local beginPos = 70
    self:addCardsToPlane(structCards, beginPos, self.LOutCard, TABLE_CARD_INTERVAL, cardType, relogin)
end

function TableLayer:showOutCardsForRightUser(structCards, cardType,relogin )
    local beginPos = 485 - (52 + (#structCards-1)*TABLE_CARD_INTERVAL)
    self:addCardsToPlane(structCards, beginPos, self.ROutCard, TABLE_CARD_INTERVAL, cardType, relogin)
end

function TableLayer:showCardsLeftUser(structCards)
    local beginPos = 70
    self:addCardsToPlane(structCards, beginPos, self.LShowCard, TABLE_CARD_INTERVAL)
end

function TableLayer:showCardsRightUser(structCards)
    local beginPos = 485 - (52 + (#structCards-1)*TABLE_CARD_INTERVAL)
    self:addCardsToPlane(structCards, beginPos, self.RShowCard, TABLE_CARD_INTERVAL)
end

function TableLayer:addCardsToPlane(structCards, beginPos, panle, interval , cardType , relogin)
    panle:removeAllChildren()
    for i, v in ipairs( structCards or {} ) do
        local card = Card:getCard(v, 2) 
        if card then
            card:setPosition(cc.p(beginPos + interval*(i-1), TABLE_CARD_HEIGHT))
            card:setScale(0.7)
            card:addTo(panle)
        end 
    end
    if cardType and not relogin then 
        local info = {Cardtype = cardType}
        self:PlayEffect(info , beginPos, panle)
        self:PlayCardType(info, beginPos, panle)
    end
end

function TableLayer:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end

function TableLayer:getToSendFaceAndTxtFuncs()
    local data = {}
    -- data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function TableLayer:sendFaceByIdx(id, msgType, to_uid)
    print("sendFaceMsg --------------------------", id)
    zixidadunServer:CLI_MSG_FACE(id, msgType, to_uid)
end

function TableLayer:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
       
        self:addChild(self.gameMsgLayer, 99999)
        self.gameMsgLayer:setVisible(false)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

-- local CT_ONE_LINE                 = 4        --单连类型
-- local CT_PANEL                    = 8        --飞机
-- local CT_BOMB_CARD                = 9       --炸弹类型
-- local CT_DOUBLE                   = 2        --对牌类型
-- local CT_DOUBLE_LINE              = 5        --对连类型
-- local CT_THREE_TAKE_TOW           = 7        --三带二
-- local CT_BOMB_TAKE                = 11      --四带3
-- local CT_FOUR_TAKE_TWO            = 12      --四带二
-- local CT_FOUR_TAKE_ONE            = 13      --四带一

local CT_SINGLE                   = 1        --单牌类型
local CT_DOUBLE                   = 2        --对牌类型
local CT_THREE                    = 6        --三条类型
local CT_ONE_LINE                 = 4        --单连类型
local CT_DOUBLE_LINE              = 3        --对连类型
local CT_THREE_TAKE_ONE           = 6        --三带一单
local CT_THREE_TAKE_TOW           = 5        --三带二
local CT_PANEL                    = 7        --飞机
local CT_PANEL_LACK               = 8        --飞机
local CT_BOMB_CARD                = 12       --炸弹类型
local CT_3A_BOMB                  = 12       --3个A算特殊炸弹
local CT_BOMB_TAKE                = 9      --四带3
local CT_FOUR_TAKE_TWO = 10 --四带二
local CT_FOUR_TAKE_ONE = 11 --四带一

function TableLayer:PlayEffect( info ,  beginPos, panle)
    -- body
    local card_type = info.Cardtype
    local path_name = ""
    if CT_PANEL == card_type then 
        path_name = "doudizhu4_feiji"
    elseif CT_ONE_LINE == card_type then 
        path_name = "doudizhu4_shunzi"
    elseif  card_type>=23 then 
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
    -- body
    local aniName = nil
    local card_type = info.Cardtype
    print ("info.Cardtype -------------- " , card_type)

    if CT_ONE_LINE == card_type then 
        aniName = "shunzi" 
    elseif CT_DOUBLE == card_type then 
        aniName = "duizi"
    elseif CT_DOUBLE_LINE == card_type then 
        aniName = "liandui"  
    elseif CT_THREE_TAKE_TOW == card_type then 
        aniName = "sandaier"
    elseif CT_THREE_TAKE_ONE == card_type then 
        aniName = "sandaiyi"
    elseif CT_BOMB_TAKE == card_type then 
        aniName = "sidaisan"
    elseif CT_FOUR_TAKE_TWO == card_type then 
        aniName = "sidaier"
    elseif CT_FOUR_TAKE_ONE == card_type then 
        aniName = "sidaiyi"
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



function TableLayer:onClickBtnVoice(sender, event)

    local data=g_mainScene:getToDisbandFuncs()
    if data.voiceRecordHandler then
        data.voiceRecordHandler(sender)
    end
end

function TableLayer:onClickBtnMsg(sender, event)
    local data=g_mainScene:getToDisbandFuncs()
    if data.showGameMsgLayerHandler then
        data.showGameMsgLayerHandler()
    end
    -- g_mainScene:loadGameMsgLayer()
end


--折叠牌
function TableLayer:onClickBtnfold(sender, event)
    --g_zxddGameData.Select_510k=false
    g_mainScene.myHandlerCardsZD = CardsAnalysis:analysisFoldingCards(g_mainScene.myHandlerCards)
    g_mainScene.playerInfoLayer:foldingCards()
    self.btn_layer:getChildByName("Button_zhankai"):setVisible(true)
    self.btn_layer:getChildByName("Button_fold"):setVisible(false)
    self:SetBtnWeizhi(true)
    if g_zxddGameData.curOutCardUser==USER_INFO.uid then
        --g_mainScene.playerInfoLayer.outcard_bg:setVisible(true)
    else
        g_mainScene.playerInfoLayer.outcard_bg:setVisible(false)
    end
    g_zxddGameData.IsSortByScore=false
end
--展开
function TableLayer:onClickBtnzhankai(sender, event)
    g_zxddGameData.IsSortByScore=false
    self:SetBtnWeizhi(false)
    g_zxddGameData.Select_510k=false
    g_mainScene.playerInfoLayer:addCardsToPlane(g_mainScene.myHandlerCards, nil, true,true)
    g_mainScene.playerInfoLayer:returnHanCardData()
    g_mainScene.playerInfoLayer:initOutCardLayer(false)
    g_mainScene.playerInfoLayer.outcard_bg:removeAllChildren()
    self.btn_layer:getChildByName("Button_zhankai"):setVisible(false)
    self.btn_layer:getChildByName("Button_fold"):setVisible(true)
end

function TableLayer:SetBtnWeizhi(isFold)
    if isFold then
    local X=g_mainScene.playerInfoLayer.outCardBtnNode:getPositionX()
    g_mainScene.playerInfoLayer.outCardBtnNode:setPosition(X,300)
    g_mainScene.playerInfoLayer.BtnLiangDun:setPosition(X,300)
else
        local X=g_mainScene.playerInfoLayer.outCardBtnNode:getPositionX()
    g_mainScene.playerInfoLayer.outCardBtnNode:setPosition(X,480)
    g_mainScene.playerInfoLayer.BtnLiangDun:setPosition(X,480)
end
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
    --self.showCard:setVisible(true)
    local CocosUtil = require("hall.util.CocosUtil")
  --  self.showCard.noScale = true
    --self.showCard:onClick(handler(self, self.onClickShowCard))
    self.load_bg = 1
end


function TableLayer:onClickBtnSort()
    if g_mainScene.myHandlerCardsZD==nil or g_mainScene.myHandlerCards==nil then
        return
    end
    if not g_zxddGameData.IsSortByScore then
        g_mainScene.playerInfoLayer:onClickBtnQuXiao()
        g_mainScene.playerInfoLayer:foldingCardsByScore()
        if g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then

            g_mainScene.playerInfoLayer:foldingCards()
        else
            --self:SortZhanKaiByScore()
            g_mainScene.playerInfoLayer:addCardsToPlane(self:SortZhanKaiByScore(), nil, true,true,true)
        end
        g_zxddGameData.IsSortByScore=true
    else
        g_mainScene.playerInfoLayer:onClickBtnQuXiao()

        if g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then

            g_mainScene.playerInfoLayer:foldingCards()
        else
            g_mainScene.playerInfoLayer:addCardsToPlane(g_mainScene.myHandlerCards, nil, true,true)
        end
        g_zxddGameData.IsSortByScore=false
    end
end

function TableLayer:SortZhanKaiByScore()
    local tabHand={}

    for i,v in ipairs(g_mainScene.myHandlerCardsZD) do
        for j,k in ipairs(v) do
            local tab=clone(k)
            table.insert(tabHand,tab)
        end
    end
    return clone(tabHand)
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
    local cache = cc.Director:getInstance():getTextureCache():addImage(TpackageName .. "/res/image/" .. "zixidadun_bg" .. self.load_bg .. ".png")
    self.tableBg:setTexture(cache)
end

--[[function TableLayer:setShowCardBtn(isTest)
    self.showCard:setVisible(isShowVerifyBt)
end--]]

function TableLayer:onClickShowCard()
    -- g_mainScene:showSelectCardsLayer()
    --zixidadunServer:CLIENT_SEND_MINGPAI_REMIND()
end
function TableLayer:onClickShowAuto(event,sender)
    if tableAI[USER_INFO["uid"]] == nil then
        zixidadunServer:CLIENT_COMMAND_AUTO(1)
    else
        if tableAI[USER_INFO["uid"]] == 1 then
            zixidadunServer:CLIENT_COMMAND_AUTO(0)
        else
            zixidadunServer:CLIENT_COMMAND_AUTO(1)
        end
    end
end
function TableLayer:ShowAuto()
    local CocosUtil = require("hall.util.CocosUtil")
    self.btn_auto:onClick(handler(self, self.onClickShowAuto))

end

function TableLayer:setWanfaDes(type)
    local str = type == 1 and "经典玩法" or "比盾玩法"
   -- self.wanfaDes:setString(str)
end

function TableLayer:onExit()
    -- body
end

return TableLayer