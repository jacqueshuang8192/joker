--[[
* author:   zwm
* date:     2019-03-25
* describe: 总战绩界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local fs = require("hall.tool.utils.fs")
local GetGameName = require("hall.familyCircle.GetGameName")
local ViewBaseLayer = require('hall.NewViewBaseLayer')
local PokerCard = require('hall.PokerCard')
local RecordLayerInfo = class('RecordLayerInfo', ViewBaseLayer)
local EVENTNAME = {
    QUERY_CARD_ACTIVITIES2_ROUND_BY_USERID = '/freeGame/queryCardActivities2RoundByUserId'
}

local DOWN_LOAD_RECORD = {
    [308] = true, [320] = true, [366] = true, [325] = true, [369] = true, [375] = true, [342] = true, [392] = true, [388] = true, [398] = true, [345] = true,
    [353] = true, [618] = true, [611] = true, [359] = true, [381] = true, [376] = true, [612] = true, [374] = true,
    [386] = true, [387] = true, [371] = true, [358] = true, [383] = true, [379] = true, [396] = true, [329] = true, [394] = true,
    [348] = true, [370] = true, [390] = true, [391] = true, [393] = true, [389] = true, [399] = true, [400] = true, [384] = true, [403] = true,[402] = true, [404] = true, [397] = true,

}

function RecordLayerInfo:onExit()
    TpackageName = nil
    ReqMgr:delHandle('RecordLayerInfo', EVENTNAME)
end

function RecordLayerInfo:ctor(activityId, level, inviteCode, roleType)
    if GetGameName:existPath(level) and level ~= nil then
        viewMgr:showTip({text = "请先进入游戏更新！"})
        return
    end
    local csbPath = 'hall/res/record/recordLayerInfo.csb'
    PokerCard:loadRes()

    local ins = cc.SpriteFrameCache:getInstance()
    if level == 395 then
        print("safafdas ++++++++++++++++++ ")
        local isLoad = ins:isSpriteFramesWithFileLoaded('NewNiuniu/res/cardType/Plist.plist')
        if not isLoad then
            ins:addSpriteFrames('NewNiuniu/res/cardType/Plist.plist', 'NewNiuniu/res/cardType/Plist.png')
        end
    else
        local isLoad = ins:isSpriteFramesWithFileLoaded('niuniu/csb/CardType/Plist.plist')
        if not isLoad then
            ins:addSpriteFrames('niuniu/csb/CardType/Plist.plist', 'niuniu/csb/CardType/Plist.png')
        end
    end

    RecordLayerInfo.super.ctor(self, csbPath)
    self.level = level
    self.inviteCode = inviteCode
    self.roleType = roleType
    self:enableMask(true)

    self.lastFromIndex = 1
    self.lastToIndex = 1

    self:initUI()
    self:createTableView()
    self:initEvent()
    self:getZJInfo(activityId, inviteCode)
end

function RecordLayerInfo:initUI()
    self.table_size = cc.size(1186, 550)
    self.item_small:setVisible(false)
    self.item_big:setVisible(false)
    self.member_small:setVisible(false)
    self.userInfo_big:setVisible(false)
    self.Image_banner1:setVisible(false)
    self.Image_banner2:setVisible(false)
    self.item_small:setPosition(self.table_size.width / 2, 63)
    self.item_big:setPosition(self.table_size.width / 2, 183.5)
end

function RecordLayerInfo:createTableView()
    -- self.table_view = cc.TableView:create(self.table_size)
    -- self.table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- self.table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- self.table_view:setPosition(cc.p(8, 5))
    -- self.table_view:setDelegate()
    -- self.Image_bg2:addChild(self.table_view)
    -- self.table_view:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    -- self.table_view:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    -- self.table_view:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    -- self.table_view:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.ScrollView_1:setScrollBarEnabled(false)
    self.ScrollView_1:addEventListenerScrollView(handler(self, self.addEventListenerScrollView))

end

-- function RecordLayerInfo:tableCellAtIndex(table, idx)
--     local cell = table:dequeueCell()
--     if nil == cell then
--         cell = cc.TableViewCell:new()
--     else
--         cell:removeChildByName('TabelCellNodeView')
--     end

--     local tData = self.table_data[idx + 1]
--     local node
--     if self.bIsBigItem then
--         node = self:cloneItemBig(tData)
--     else
--         node = self:cloneItemSmall(tData)
--     end
--     cell:addChild(node)
--     return cell
-- end


function RecordLayerInfo:showGrabAndBetScore(userItem, userInfo, level)
    -- dump(userInfo, "userInfo == ")
    if userInfo.grabTimes and userInfo.grabTimes > 0 then
        userItem.Image_banker:setVisible(true)
        if level == 302 or level == 395 then
            userItem.infoStr:setVisible(true)
            userItem.infoStr:setString("抢 X"..userInfo.grabTimes)
        end
    end

    if userInfo.grabTimes and userInfo.betScore > 0 then
        userItem.Image_bet:setVisible(true)
        userItem.betStr:setVisible(true)
        userItem.betStr:setString(userInfo.betScore)
    end
end

-- self:cloneItemBig(infoNode,self.table_data[i],i)
function RecordLayerInfo:cloneItemBig(itemNode,data,index)
    -- local item = self.item_big:clone()
    -- item:setVisible(true)
    -- item:setName('TabelCellNodeView')
    GameUtils.setNodeNameBindObj(itemNode)
    local content = json.decode(data['content'])
    -- dump(content)
    itemNode.indexStr:setString(data.roundIndex)
    local time_str = os.date('%Y-%m-%d\n%H:%M:%S', data.endTime / 1000)
    itemNode.timeStr:setString(time_str)
    itemNode.nameStr:setString(content.gameName)
    itemNode.fanghaoStr:setString(content.roomNumb)

    local scoreColor, userItem, score
    for idx, userInfo in ipairs(content.userinfos) do
        userItem = self.userInfo_big:clone()
        userItem:setVisible(true)
        local x = 20 + ((idx - 1) % 5) * 200
        local y = 203 - math.floor((idx - 1) / 5) * 195
        userItem:setPosition(x, y)
        itemNode.PanelUsers:addChild(userItem)
        GameUtils.setNodeNameBindObj(userItem)

        if userInfo.score >= 0 then
            scoreColor = cc.c3b(0xff, 0xff, 0x0)
            if self.level == 325 then
                score = '+' .. userInfo.score
            else
                score = '+' .. userInfo.score / 100
            end
        else
            scoreColor = cc.c3b(0x0, 0xff, 0x0)
            if self.level == 325 then
                score = userInfo.score
            else
                score = userInfo.score / 100
            end
        end

        local nickname = require('hall.GameCommon'):formatNick(userInfo.nickName, 3)
        userItem.nameStr:setString(userInfo.uid)
        userItem.nameId:setString(nickname)
        userItem.scoreStr:setString(score)
        userItem.scoreStr:setTextColor(scoreColor)

        -- userItem.infoStr:setString("抢x88")
        -- userItem.betStr:setString("58")
        userItem.Image_banker:setVisible(false)
        userItem.Image_bet:setVisible(false)
        userItem.infoStr:setVisible(false)
        userItem.betStr:setVisible(false)
        self:loadCards(userItem.PanelCards, self.level, userInfo, userItem.ImageCardsType)
        if self.level == 302 or self.level == 303 or self.level == 304 or self.level == 395 or self.level == 305 
           or self.level == 613 or self.level == 614 or self.level == 615 or self.level == 616 then
            self:showGrabAndBetScore(userItem, userInfo, self.level)
        end
        
        if appmsg_showinscore and userInfo.beginScore and userInfo.beginScore ~= nil then
            userItem.betStr_0:setVisible(true)
            local showinscore = userInfo.beginScore/100
            userItem.betStr_0:setString(showinscore)
        else
            userItem.betStr_0:setVisible(false)
        end
        

        if idx >= 10 then
            break
        end
    end

    -- return item
end

function RecordLayerInfo:cloneItemSmall(itemNode,data,index)
    local content = json.decode(data['content'])
    GameUtils.setNodeNameBindObj(itemNode)

    itemNode.indexStr:setString(data.roundIndex)
    local time_str = os.date('%Y-%m-%d\n%H:%M:%S', data.endTime / 1000)
    itemNode.timeStr:setString(time_str)

    itemNode.nameStr:setString(content.gameName)
    itemNode.fanghaoStr:setString(content.roomNumb)

    if DOWN_LOAD_RECORD[self.level] then
        itemNode.playBtn._initData = data
        itemNode.playBtn:addTouchEventListener(handler(self, self.onClickSubItem))
    else
        itemNode.playBtn:setVisible(false)
    end

    local scoreColor, memberItem, score
    for idx, userInfo in ipairs(content.userinfos) do
        memberItem = self.member_small:clone()
        memberItem:setVisible(true)
        GameUtils.setNodeNameBindObj(memberItem)

        if userInfo.score >= 0 then
            scoreColor = cc.c3b(0xa9, 0x5f, 0x24)
            score = '+' .. userInfo.score / 100
        else
            scoreColor = cc.c3b(0x64, 0xb8, 0x77)
            score = userInfo.score / 100
        end

        -- local nickname = require("hall.GameCommon"):formatNick(userInfo.nickName, 3)
        memberItem.chengyuanName:setString(userInfo.uid)
        memberItem.chengyuanScore1:setString(score)
        memberItem.chengyuanScore1:setTextColor(scoreColor)

        if appmsg_showinscore and userInfo.beginScore and userInfo.beginScore ~= nil then
            local showinscore = userInfo.beginScore/100
            memberItem.chengyuanScore1:setString(score .. "(" .. showinscore .. ")")
        end

        -- memberItem.chengyuanScore2:setString(score)
        -- memberItem.chengyuanScore2:setTextColor(scoreColor)
        memberItem.chengyuanScore2:setVisible(false)
        itemNode.Panel_members:addChild(memberItem)
    end
    itemNode.Panel_members:setLayoutType(1)
    -- item.Panel_members:doLayout()
    -- return item
end

function RecordLayerInfo:updateTableView(recordData)
    self.table_data = recordData

    --如果是用邀请码进来的,则从把结算中拿回level
    if self.inviteCode then
        if #recordData > 0 then
            self.level = recordData[1].level
        end
    end

    self.contH = self.ScrollView_1:getContentSize().height   
    self.itemH = 126
    self.threshold = 6 --or self.level == 374
    self.bIsBigItem = self.level == 368 or self.level == 302 or self.level == 303 or self.level == 304 or self.level == 395 
        or self.level == 305 or self.level == 613 or self.level == 614 or self.level == 615 or self.level == 616 or self.level == 317 or self.level == 360  or self.level == 365 or self.level == 367 or self.level == 617 or self.level == 315 

    if self.bIsBigItem then
        self.itemH = 400
        self.threshold = 3
        self.Image_banner1:setVisible(false)
        self.Image_banner2:setVisible(true)
    else
        self.itemH = 126
        self.threshold = 6
        self.Image_banner1:setVisible(true)
        self.Image_banner2:setVisible(false)
    end

    -- dump(self.table_data)
    -- self.table_view:reloadData()
    self:refreshList()
end


function RecordLayerInfo:refreshList()
    self.itemList = {}

    self.cacheItemNum = 2
    self.allTripH = self.contH - self.itemH * #self.table_data -- 总可滑动行程
    self.numPerPage = math.ceil(self.contH/self.itemH)

    for index, value in ipairs(self.ScrollView_1:getChildren()) do
        value:removeSelf()
    end

    local infoNode = nil
    self.allNum = #self.table_data
    local endIndex = self.threshold
    if self.allNum < self.threshold then
        endIndex = self.allNum
    end

    local allInnerContH = self.itemH*self.allNum
    if allInnerContH < 550 then
        allInnerContH = 550
    end


    for i = 1, endIndex do
        if self.bIsBigItem then
            infoNode = self.item_big:clone()
        else
            infoNode = self.item_small:clone()
        end

        infoNode:setVisible(true)
        self.ScrollView_1:addChild(infoNode)

        if self.bIsBigItem then
            infoNode:setPositionY(allInnerContH - i*self.itemH + 200)
            self:cloneItemBig(infoNode,self.table_data[i],i)
        else
            infoNode:setPositionY(allInnerContH - i*self.itemH + 63)
            dump(allInnerContH - i*self.itemH + 200)

            self:cloneItemSmall(infoNode,self.table_data[i],i)
        end
        self.itemList[i] = infoNode
    end
    self.ScrollView_1:setInnerContainerSize(cc.size(1208,allInnerContH))
end


function RecordLayerInfo:addEventListenerScrollView(target, selector)

    if #self.table_data < self.threshold then
        return
    end

    local pos = self.ScrollView_1:getInnerContainerPosition().y

    local passItemNum = math.ceil((pos - self.allTripH)/self.itemH)  -- 当前滑了多少格
    
    for i = self.lastFromIndex, self.lastToIndex do
        if self.itemList[i] ~= nil then
            self.itemList[i]:setVisible(false)
        end
    end

    local fromItemIndex = math.max(1,(passItemNum - self.cacheItemNum))
    local toItemIndex = math.min(#self.table_data,(passItemNum + self.cacheItemNum + self.numPerPage))
    self.lastFromIndex = fromItemIndex
    self.lastToIndex = toItemIndex

    local allInnerContH = self.itemH*self.allNum
    if allInnerContH < 550 then
        allInnerContH = 550
    end
    -- -- 展示  passItemNum - self.cacheItemNum 到  passItemNum + self.cacheItemNum + self.numPerPage
    for i = fromItemIndex, toItemIndex do
        if self.itemList[i] == nil then
            if self.bIsBigItem then
                self.itemList[i] = self.item_big:clone()
                self.itemList[i]:setPositionY(allInnerContH - i*self.itemH + 200)
                self:cloneItemBig(self.itemList[i],self.table_data[i],i)
            else
                self.itemList[i] = self.item_small:clone()
                self.itemList[i]:setPositionY(allInnerContH - i*self.itemH + 63)
                self:cloneItemSmall(self.itemList[i],self.table_data[i],i)
            end
            self.ScrollView_1:addChild(self.itemList[i])
        else
            self.itemList[i]:setVisible(true)
        end
    end
end

function RecordLayerInfo:tableCellTouched(table, cell)
end

function RecordLayerInfo:cellSizeForTable(table, idx)
    if self.bIsBigItem then
        return self.table_size.width, 400
    else
        return self.table_size.width, 126
    end
end

function RecordLayerInfo:numberOfCellsInTableView()
    return #self.table_data
end

function RecordLayerInfo:initEvent()
    ReqMgr:addHandle('RecordLayerInfo', EVENTNAME)
end

function RecordLayerInfo:resultZJ(event)
    local netData = event.netData

    if netData.returnCode == 0 then
        dump(netData.data, '===成功返回战绩详情===')
        local sData = netData.data
        if sData == nil or #sData <= 0 then
            viewMgr:showTip({text = '战绩不存在...'})
            self:onClickBtnReturn()
            return
        end

        if sData ~= nil and self then

            if GetGameName:existPath(sData[1].level) then
                viewMgr:showTip({text = "请先进入游戏更新！"})
                return
            end

            self:updateTableView(sData)
        end
    else
        viewMgr:showTip({text = '战绩不存在...'})
        self:onClickBtnReturn()
    end
end

function RecordLayerInfo:onClickSubItem(sender, event)
    if event == TOUCH_EVENT_ENDED then
        local data = sender._initData
        if string.sub(data.replayUrl,1,string.len('XY::')) == 'XY::' then
            
            self.httpHead = string.gsub(HttpAddr, '/hbiInterface', '');
            self.httpSuffix = string.gsub(data.replayUrl, 'XY::', '');
            data.replayUrl = self.httpHead .. self.httpSuffix
        end

        local splitAr = string.split(data.replayUrl, '/')
        local fileName = splitAr[#splitAr]
        self:getRecoreContent(data.replayUrl, fileName, handler(self, self.toPlayingVideo))
    end
end

function RecordLayerInfo:toPlayingVideo(contentStr)
    if contentStr == nil or #contentStr == 0 then
        return
    end

    if
        self.level == 308 or self.level == 320 or self.level == 366 or self.level == 376 or self.level == 612 or
            self.level == 386 or
            self.level == 387 or
            self.level == 371 or
            self.level == 358 or
            self.level == 329 or
            self.level == 370 or
            self.level == 389 or
            self.level == 390 or
            self.level == 393 or
            self.level == 348 or
            self.level == 394 or
            self.level == 399 or
            self.level == 400 or
            self.level == 403 or
            self.level == 404

     then
        local videoLayer = require('hall.record.MJGameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 325 then
        local videoLayer = require('pdk.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 397 then --新化打炸
        local videoLayer = require('xinhuadazha.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
            return
        end
    elseif self.level == 369 then
        local videoLayer = require('xinyu510k.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 402 then
        local videoLayer = require('qs510k.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 375 or self.level == 342 or self.level == 353 or self.level == 618 or self.level == 611 or self.level == 359 or self.level == 379 or self.level == 396 or self.level == 398 or self.level == 345 then
        local videoLayer = require('hall.record.phz_record.PHZMainLayer').new(contentStr, self.level, self.roleType)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 392  then
        local videoLayer = require('hall.record.xupuphz.gameScene').new(contentStr, self.level, self.roleType)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 388  then
        local videoLayer = require('jchuapai.src.record.gameScene').new(contentStr, self.level, self.roleType)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 381 then
        local videoLayer = require('TaiHeGuoZha.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 383 then
        local videoLayer = require('yuanjiangqianfen.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 391 then --溆浦老牌

        local videoLayer = require('hall.record.xplp_recode.XPLPGameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 374 then --翻三皮
        local videoLayer = require('FanSanPi.view.VideoMenjiroomView').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 384  then
        local videoLayer = require('96game.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    end
end

function RecordLayerInfo:loadCards(PanelCards, level, userInfo, CardTypeNode)
    if level == 365 or level == 367 or level == 617 then --十三水
        local csbPath = 'hall/res/record/node/shisanzhang_cords.csb'
        local cardsNode = cc.CSLoader:createNode(csbPath)
        PanelCards:addChild(cardsNode)
        self:setShiSanZhang(cardsNode, userInfo)
    elseif level == 315 then --退锅牌九 or self.level == 318  还咩合数据
        local csbPath = 'hall/res/record/node/paijiu_cards.csb'
        local cardsNode = cc.CSLoader:createNode(csbPath)
        cardsNode:setPositionY(20)
        PanelCards:addChild(cardsNode)
        self:setPaiJiu(cardsNode, userInfo)
    elseif level == 368 or level == 302 or level == 303 or level == 304 or level == 305 
        or level == 613 or level == 614 or level == 615 or level == 616 or level == 395 then -- 牛牛
        self:loadPokerCards(PanelCards, userInfo, CardTypeNode, true, level)
    elseif level == 317 or level == 360 or level == 374 then -- 炸金花 三公 翻三皮
        self:loadPokerCards(PanelCards, userInfo, CardTypeNode, false,level)
    end
end

function RecordLayerInfo:loadPokerCards(PanelCards, userInfo, CardTypeNode, isShowType,level)
    -- print("loadPokerCards ----------------", debug.traceback())
    if userInfo.cards == nil then
        return
    end

    local cards = string.split(userInfo.cards, ',') or {}
    local offset = (5 - #cards) * 16
    for i, card in ipairs(cards) do
        local poker = PokerCard.new(0.4)
        poker:setCardId(tonumber(card),level)
        poker:showFront()
        poker:setPosition(26 + (i - 1) * 32 + offset, 40)
        PanelCards:addChild(poker)
    end

    if isShowType then
        local path = 'NewNiuniu/res/cardType/result_' .. (userInfo.niuType or '1') .. '.png' 
        print(" ---------- ", path, level)
        if level == 395 then
            CardTypeNode:loadTexture('NewNiuniu/res/cardType/result_' .. (userInfo.niuType or '1') .. '.png', 1)

        else
            CardTypeNode:loadTexture('niuniu/csb/CardType/result_' .. (userInfo.niuType or '1') .. '.png', 1)
        end
        
        CardTypeNode:ignoreContentAdaptWithSize(true)
        CardTypeNode:setScale(0.35)
    else
        CardTypeNode:setVisible(false)
    end
end

function RecordLayerInfo:setShiSanZhang(node, data)
    local root = node:getChildByName('root')
    root:setVisible(false)
    if not data.cardList then
        return
    end
    root:show()
    TpackageName = 'shisanzhang_new'
    GameUtils.setNodeNameBindObj(node)
    root.result:hide()
    local dao = root.dao
    local cardlist = data.cardList
    cardlist = cardlist[1]
    if not cardlist then
        return
    end
    for idx, value in ipairs(cardlist or {}) do
        local cardNodes = dao['Panel_' .. idx]:getChildren()
        local cards = string.sub(value.cards, 2, -2)
        cards = string.split(cards, ',') or {}
        for i, card in ipairs(cards) do
            local cardNode = cardNodes[i]
            if not cardNode:getComponent('shisanzhang_new.PokerCard_3') then
                cc(cardNode):addComponent('shisanzhang_new.PokerCard_3'):exportMethods()
                cardNode:initUI(cardNode)
                cardNode:setCard(tonumber(card))
                cardNode:showFront()
            end
        end
    end
end

function RecordLayerInfo:setPaiJiu(scene, cardsstr)
    local root = scene:getChildByName('root')
    local chids = root:getChildren()

    for i, node in ipairs(chids) do
        node:hide()
    end

    if cardsstr == nil or cardsstr.cards == nil then
        return
    end

    GameUtils.setNodeNameBindObj(scene)
    local cards = string.split(cardsstr.cards, ',') or {}

    --如果是大牌九 4张牌
    if #cards == 4 then
        --这里交换一下 让大牌放到小牌前面
        local temp_cards = {cards[3],cards[4],cards[1],cards[2]}
        dump(temp_cards,"RecordLayerInfo:setPaiJiu_1")
        cards = temp_cards
    end

    --如果是大牌九
    if #cards == 4 then

        for i, card in ipairs(cards) do
            local node = chids[i]
            local path = 'paijiu/images/cards/' .. card .. '.png'
            node:loadTexture(path)
            node:show()
        end

    elseif #cards == 2 then

        local LoadCard = require('paijiu.DominoCard')

        for i, card in ipairs(cards) do
            local node = chids[i]
            local card_path = LoadCard:getPokerCardPath(tonumber(card))
            
            node:loadTexture(card_path)
            node:show()

        end

    end

    --游戏类型
    local img_left = root:getChildByName('img_left')
    local img_right = root:getChildByName('img_right')
    local img_mid = root:getChildByName('img_mid')
    img_left:setVisible(false)
    img_right:setVisible(false)
    img_mid:setVisible(false)
    
    if #cards == 4 then --大牌九
        local LoadCard = require('paijiu.operator.LoadCard')
        
        img_left:setString(LoadCard.changeCardsString(cards[1], cards[2]))
        img_left:setVisible(true)
        
        img_right:setString(LoadCard.changeCardsString(cards[3], cards[4]))
        img_right:setVisible(true)
    elseif #cards == 2 then --小牌九
        local PJ_GROUP_TYPE_SPE = 10
        local PJ_GROUP_TYPE = {
            '杂',
            '短',
            '长',
            '娥',
            '人',
            '地',
            '天',
            '',
            '',
            '分割',
            '地杠',
            '天杠',
            '对杂五',
            '对杂七',
            '对杂八',
            '对杂九',
            '对短',
            '对长',
            '对娥',
            '对人',
            '对地',
            '对天',
            '地九娘娘',
            '天王九',
            '皇上',
            '鬼子',
            '炸弹'
        }
        PJ_GROUP_TYPE[0] = '毕十'
        local PJ_GROUP_POINT = {'一', '二', '三', '四', '五', '六', '七', '八', '九'}
        PJ_GROUP_POINT[0] = '零'
        local PJ_CARD_TYPE = {
            ['炸弹'] = 1, ['鬼子'] = 2, ['皇上'] = 4, ['天王九'] = 5, 
            ['地九娘娘'] = 6, ['对天'] = 7, ['对地'] = 8, ['对人'] = 9, ['对娥'] = 10, 
            ['对长'] = 11, ['对短'] = 14, ['对杂九'] = 18, ['对杂八'] = 19, ['对杂七'] = 20, 
            ['对杂五'] = 21, ['天杠'] = 22, ['地杠'] = 23, ['天九'] = 24, ['地九'] = 25, ['人九'] = 26, 
            ['娥九'] = 27, ['长九'] = 28, ['短九'] = 29, ['天八'] = 30, 
            ['地八'] = 31, ['人八'] = 32, ['娥八'] = 33, ['长八'] = 34, ['短八'] = 35, 
            ['天七'] = 37, ['地七'] = 38, ['人七'] = 39, ['娥七'] = 40, 
            ['长七'] = 41, ['短七'] = 42, ['杂七'] = 43, ['天六'] = 44, ['地六'] = 45, ['人六'] = 46, 
            ['长六'] = 47, ['短六'] = 48, ['杂六'] = 49, ['天五'] = 50, 
            ['地五'] = 51, ['人五'] = 52, ['娥五'] = 53, ['长五'] = 54, ['短五'] = 55, ['杂五'] = 56, 
            ['天四'] = 57, ['人四'] = 58, ['娥四'] = 59, ['长四'] = 60, 
            ['短四'] = 61, ['杂四'] = 62, ['天三'] = 63, ['地三'] = 64, ['人三'] = 65, ['娥三'] = 66, 
            ['长三'] = 67, ['短三'] = 68, ['杂三'] = 69, ['天二'] = 70, 
            ['地二'] = 71, ['人二'] = 72, ['娥二'] = 73, ['长二'] = 74, ['短二'] = 75, ['杂二'] = 76, 
            ['地一'] = 78, ['人一'] = 79, ['娥一'] = 80, 
            ['长一'] = 81, ['短一'] = 82, ['杂一'] = 83, ['毕十'] = 84
        }

        local typeTemp = tonumber(cardsstr.cardTypes)
        local point = tonumber(cardsstr.cardPoints)

        local _type
        if typeTemp > PJ_GROUP_TYPE_SPE or typeTemp == 0 then
            _type = PJ_GROUP_TYPE[typeTemp]
        else
            _type = PJ_GROUP_TYPE[typeTemp] .. PJ_GROUP_POINT[point]
        end
        
        img_mid:loadTexture('paijiu/images/cardname/' .. PJ_CARD_TYPE[tostring(_type)] .. '.png')
        img_mid:setVisible(true)
        img_mid:setScale(3)
    end
end

function RecordLayerInfo:onClickItem(event)
    if event.name == 'ended' then
        local target = event.target
        local activityId = target.id
        self:getZJInfo(activityId, nil)
    end
end

function RecordLayerInfo:getZJInfo(activityId, inviteCode)
    local this = self
    local data = {}
    data['userId'] = USER_INFO['uid']
    data['activityId'] = activityId
    data['inviteCode'] = inviteCode
    data['interfaceType'] = 'J'
    
    -- local fun = function ( sData )
    --     this:dispatchEvent({ name = EVENTNAME.QUERY_CARD_ACTIVITIES2_ROUND_BY_USERID, netData = sData })
    -- end
    -- local interfaceName = "/freeGame/queryCardActivities2RoundByUserId"
    -- local httpType = "POST"
    -- self:commonRequest(interfaceName, params, fun, httpType)
    ReqMgr:request(EVENTNAME.QUERY_CARD_ACTIVITIES2_ROUND_BY_USERID, data, handler(self, self.resultZJ))
end

function RecordLayerInfo:onClickBtnReturn(sender, event)
    self:removeSelf()
end

function RecordLayerInfo:getRecoreContent(url, fileName, callback)
    --先在本地获取
    local path = device.writablePath
    if device.platform == "windows" then
        path = device.writablePath.."cache\\" --获取本地存储目录
        if not fs.exists(path) then
            fs.mkdir(path) --目录不存在，创建此目录
        end
    end
    local imgFullPath = path..fileName

    local file, fileErr = io.open(imgFullPath)
    if fileErr == nil then
        local fileContent = file:read()
        if callback then
            callback(fileContent)
        end
    else
        local function onRequestFinished(event, filename)
            local ok = (event.name == 'completed')
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return
            end

            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            while (not request:saveResponseData(imgFullPath)) and times < 30 do --filename
                times = times + 1
            end
            file, fileErr = io.open(imgFullPath)
            if fileErr == nil then
                local fileContent = file:read()
                if callback then
                    callback(fileContent)
                end
            else
                print('获取战绩失败 ---- url = ', url)
            end
        end

        local request =
            network.createHTTPRequest(
            function(event)
                if event.name == 'completed' then
                    onRequestFinished(event, imgFullPath)
                end
            end,
            url,
            'GET'
        )
        request:start()
    end
end

return RecordLayerInfo
