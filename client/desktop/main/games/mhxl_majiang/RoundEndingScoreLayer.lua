
--add by zzy 2019-7-31 23:25
--单局结算界面

local sendHandle = require("mhxl_majiang.handle.XLMHSendHandle")
local Card = require("mhxl_majiang.card.card")

local COMMON_JI_ARR = {
    [0] = "翻牌鸡",
    [1] = "摇摆鸡",
    [2] = "摇摆鸡",
    [3] = "本鸡",
    [4] = "普通鸡",
    [5] = "金鸡",
    [6] = "乌骨鸡",
    [7] = "乌骨金鸡",
    [8] = "红中",
    [9] = "责任鸡",
    [10] = "责任乌骨鸡",
    [11] = "冲锋鸡",
    [12] = "冲锋金鸡",
    [13] = "冲锋乌骨鸡",
    [14] = "冲锋乌骨金鸡",
    [15] = "闷豆",
    [16] = "明豆",
    [17] = "点明豆",
    [18] = "转弯豆",
    [19] = "地豆",
    [20] = "包豆",
}

local HU_TYPE = {
    [0] = "平胡",
    [1] = "点炮",
    [2] = "自摸",
    [3] = "大对子",
    [4] = "七对",
    [5] = "清一色",
    [6] = "龙七对",
    [7] = "清大对",
    [8] = "清七对",
    [9] = "青龙背",
    [10] = "抢杠胡",
    [11] = "杠上花",
    [12] = "杠上炮",
    [13] = "天听硬报",
    [14] = "天听软报",
}

local testIMG_1 = "mhxl_majiang/image/new_img/ji_ze.png"
local testIMG_2 = "mhxl_majiang/image/new_img/wandou.png"
local testIMG_3 = "mhxl_majiang/image/new_img/zhuan.png"

local RoundEndingScoreLayer = class("RoundEndingScoreLayer", function ()
   return cc.CSLoader:createNode("mhxl_majiang/roundEndingScore.csb") 
end)

RoundEndingScoreLayer.COMMON_JI_TYPE = 1
RoundEndingScoreLayer.XQ_JI_TYPE = 2
RoundEndingScoreLayer.DOU_JI_TYPE = 3
RoundEndingScoreLayer.HU_TYPE = 4

RoundEndingScoreLayer.BTN_KAN = 1
RoundEndingScoreLayer.BTN_CTN = 2
RoundEndingScoreLayer.BTN_ALL_RESULT5 = 3

RoundEndingScoreLayer.ALL_PLAYER_NUMBER = 4

function RoundEndingScoreLayer:ctor(data)

    for k,v in pairs(data.players) do
        -- dump(v)
    end
    self.isShow = true

	self:setNodeEventEnabled(true)
    self.data = data
    self.root = self:getChildByName("Panel_1")
    self.root:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
	self:initUI()
    print("CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH",CONFIG_WIN_WIDTH,CONFIG_DESIGN_WIDTH)
end

function RoundEndingScoreLayer:getMaxWinPlayerIndex()
    local tempN = #self.data.players
    local tempScore,addN,maxScore,maxIndex = 0,0,0,1
    for k,v in pairs(self.data.players) do
        if v.changeCoins == tempScore then addN = addN + 1 end
        if maxScore <= v.changeCoins then 
            maxIndex = k
            maxScore = v.changeCoins 
        end
    end

    if addN == tempN then return nil end
    return maxIndex
end

function RoundEndingScoreLayer:getIsShow()
    return self.isShow
end

function RoundEndingScoreLayer:onEnter()
end

function RoundEndingScoreLayer:onExit()
    self.isShow = false
end

function RoundEndingScoreLayer:getJiNameByTypeAndIndex(_type,_index)
    if _type == RoundEndingScoreLayer.COMMON_JI_TYPE or _type == RoundEndingScoreLayer.DOU_JI_TYPE then
        local tempIndex = _index 
        return COMMON_JI_ARR[tempIndex] or " "
    elseif _type == RoundEndingScoreLayer.XQ_JI_TYPE then
        return "星期鸡"
    elseif _type == RoundEndingScoreLayer.HU_TYPE then
        return HU_TYPE[_index] or " "
    end
    return " "
end

--根据类型来创建各种鸡的图片
function RoundEndingScoreLayer:getTypeCreateJiImg(_type,_imgNode,_value,_index)
    local tempIndex = _index 
    print("=====_type====",_type,_index)
    if _type == RoundEndingScoreLayer.COMMON_JI_TYPE or _type == RoundEndingScoreLayer.DOU_JI_TYPE then
        if tempIndex >= 15 then
            print("====>=15====")
            if tempIndex == 15 then
                print("======15=======")
                _imgNode:setTexture("mhxl_majiang/image/new_img/wandou.png")
            elseif tempIndex == 16 then
                _imgNode:setTexture("mhxl_majiang/image/new_img/wandou.png")
            elseif tempIndex == 17 then
                _imgNode:setTexture("mhxl_majiang/image/new_img/wandou2.png")
            elseif tempIndex == 18 then
                _imgNode:setTexture("mhxl_majiang/image/new_img/zhuan.png")
            elseif tempIndex == 19 then
                _imgNode:setTexture("mhxl_majiang/image/new_img/wandou.png")
            elseif tempIndex == 20 then
                _imgNode:setTexture("mhxl_majiang/image/new_img/wandou.png")
            end
            _imgNode:setPositionX(_imgNode:getPositionX() - 13) 
        else
            if tempIndex == 9 or tempIndex == 10 then
                _imgNode:setTexture("mhxl_majiang/image/new_img/ji_ze.png")
                _imgNode:setPositionX(_imgNode:getPositionX() - 13) 
            else
                self:CreateBirdCards(_imgNode,_value)
            end
        end
    elseif _type == RoundEndingScoreLayer.XQ_JI_TYPE then
        self:CreateBirdCards(_imgNode,_value)
    end
end

function RoundEndingScoreLayer:CreateBirdCards(_cardNode,_value)

    if not _value then
        return
    end

    local bird_card_plane = _cardNode
    local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, _value)
    card:setScale(1.5)
    card:setPosition(cc.p(0,25))
    bird_card_plane:addChild(card)
    
end

function RoundEndingScoreLayer:setGameEndState()
    self.btn_allData:setVisible(true)
    self.btn_continuous:setVisible(false)
end

function RoundEndingScoreLayer:initUI()
	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.ended then
    			self:onCallBack(sender:getTag())
    		end
    	end
    end

    self.btn_kan = self.root:getChildByName("btn_kan")
	self.btn_kan:setTag(RoundEndingScoreLayer.BTN_KAN)
	self.btn_kan:addTouchEventListener(onTouchButton)

    self.btn_continuous = self.root:getChildByName("btn_continuous")
    self.btn_continuous:setTag(RoundEndingScoreLayer.BTN_CTN)
    self.btn_continuous:addTouchEventListener(onTouchButton)

    self.btn_allData = self.root:getChildByName("btn_allData")
    self.btn_allData:setTag(RoundEndingScoreLayer.BTN_ALL_RESULT5)
    self.btn_allData:addTouchEventListener(onTouchButton)

    if XLMH_ROUND == XLMH_TOTAL_ROUNDS then
       self.btn_allData:setVisible(true)
       self.btn_continuous:setVisible(false)
    else
       self.btn_allData:setVisible(false)
       self.btn_continuous:setVisible(true)
    end

    if  SCENENOW["scene"].isGameOver then
        self.btn_allData:setVisible(true)
        self.btn_continuous:setVisible(false)
    end

    self.fanhao = self.root:getChildByName("fanhao")             --房号
    self.jushu_count = self.root:getChildByName("jushu_count")   --当前局数
    self.time = self.root:getChildByName("time")                 --当前时间

    self.node_player_arr = {}
    for i=1,RoundEndingScoreLayer.ALL_PLAYER_NUMBER do
        self.node_player_arr[i] = {}
        local userNode = self.root:getChildByName("user_"..i)
        self.node_player_arr[i].head_kuan = userNode:getChildByName("head_kuan")
        self.node_player_arr[i].head_mi = userNode:getChildByName("head_mi")
        self.node_player_arr[i].img_fangzhu = userNode:getChildByName("img_fangzhu")

        self.node_player_arr[i].img_fangzhu:setVisible(false)

        self.node_player_arr[i].nick = userNode:getChildByName("nick")
        self.node_player_arr[i].id = userNode:getChildByName("id")
        self.node_player_arr[i].Image_3 = userNode:getChildByName("Image_3")
        self.node_player_arr[i].hu_img = userNode:getChildByName("hu_img")

        self.node_player_arr[i].img_dayingjia = userNode:getChildByName("img_dayingjia")
        self.node_player_arr[i].img_dayingjia:setVisible(false)

        self.node_player_arr[i].listView = userNode:getChildByName("listView")
        self.node_player_arr[i].Image_5 = userNode:getChildByName("Image_5")
        self.node_player_arr[i].Text_3 = userNode:getChildByName("Text_3")
    end

    self:refreshRoomInfo()
    self:refreshTime()
    self:refreshResultInfo(self.data.players)
    self:showBirdCards(self.data.birdCards)

    local maxWinPlayerIndex = self:getMaxWinPlayerIndex()
    if maxWinPlayerIndex then
        self.node_player_arr[maxWinPlayerIndex].img_dayingjia:setVisible(true)
    end
end

function RoundEndingScoreLayer:refreshRoomInfo()
    self.fanhao:setString(USER_INFO["invote_code"])
    self.jushu_count:setString("第"..XLMH_ROUND.."局")
end

function RoundEndingScoreLayer:getPlayerDataByID(_id)
    if not _id then return nil end
    if not XLMH_USERINFO_TABLE then return nil end
    for k,v in pairs(XLMH_USERINFO_TABLE) do
        if v.uid == _id then
            return v
        end
    end
    return nil
end
 
function RoundEndingScoreLayer:refreshTime()
    local tempTimeStr = os.date("%Y-%m-%d %H:%M:%S", self.data.time or os.time())
    self.time:setString(tempTimeStr)
end

function RoundEndingScoreLayer:hidePlayerNode(_index)
    local _index = tonumber(_index)
    if not self.node_player_arr[_index] then return end
    -- for k,v in pairs(self.node_player_arr[_index]) do
    --     v:setVisible(false)
    -- end
    self.node_player_arr[_index].head_kuan:setVisible(false)
    self.node_player_arr[_index].head_mi:setVisible(false)
    self.node_player_arr[_index].img_fangzhu:setVisible(false)
    self.node_player_arr[_index].nick:setVisible(false)
    self.node_player_arr[_index].id:setVisible(false)
    self.node_player_arr[_index].Image_3:setVisible(false)
    self.node_player_arr[_index].hu_img:setVisible(false)
    self.node_player_arr[_index].img_dayingjia:setVisible(false)
    self.node_player_arr[_index].listView:setVisible(false)
    self.node_player_arr[_index].Image_5:setVisible(false)
    self.node_player_arr[_index].Text_3:setVisible(false)
end

function RoundEndingScoreLayer:refreshResultInfo(data)
    if not data then return end

    local tempGamePlayerN = #data
    if tempGamePlayerN < RoundEndingScoreLayer.ALL_PLAYER_NUMBER then
        for i = (tempGamePlayerN+1),RoundEndingScoreLayer.ALL_PLAYER_NUMBER do
            self:hidePlayerNode(i)
        end
    end

    local _tempIndex = 0

    for k,v in pairs(data) do
        _tempIndex = _tempIndex + 1
        local tempID = v.uid 
        local tempPlayerData = self:getPlayerDataByID(tempID)
        if not tempPlayerData then return end
        require("hall.GameCommon"):getUserHead(tempPlayerData.photoUrl, v.uid, tempPlayerData.sex, self.node_player_arr[_tempIndex].head_mi, 103, false)
        self.node_player_arr[_tempIndex].nick:setString(tempPlayerData.nick)
        self.node_player_arr[_tempIndex].id:setString(tempPlayerData.uid or "")
        local tempScore = self:getScoreStr(v.changeCoins or "")
        self.node_player_arr[_tempIndex].Text_3:setString(tonumber(tempScore)/100)

        if v.is_dahu == 1 then
            self.node_player_arr[_tempIndex].hu_img:setVisible(true)
        else
            self.node_player_arr[_tempIndex].hu_img:setVisible(false)
        end

        self:refreshListView(self.node_player_arr[_tempIndex].listView,v)

    end


   
end

function RoundEndingScoreLayer:refreshListView( _node, data )
    -- _node:removeAllChildren()
    local tempXQJData = data.xqj_list
    local tempXQJN = data.xqjCount
    local tempDOUData = data.dou_list
    local tempDOUN = data.douCount
    local tempJIDATA = data.jiTypes
    local tempJIN = data.jiCount
    local tempHuTais = data.huTaisCount
    local tempHuTaisData = data.huTais
    local tempUse_tai_count = data.use_tai_count
    local tempUse_tai_Data = data.use_tai_list
    dump(tempUse_tai_Data,"===tempUse_tai_Data====")
    if tempHuTais > 0  then 
        -- for i=1,5 do
            for k,v in pairs(tempHuTaisData) do
            local tempCell = self.root:getChildByName("panel"):clone()

            tempCell:setSwallowTouches(false)

            local tempImg = tempCell:getChildByName("sp")
            local tempText = tempCell:getChildByName("text")
            local tempScore = tempCell:getChildByName("score")

            local IMGNode = display.newSprite():addTo(tempCell)
            IMGNode:setContentSize(cc.size(42, 48))
            IMGNode:setPosition(cc.p(60,20))

            local strName = self:getJiNameByTypeAndIndex(4,v.byType)

            -- by zzy delect
            -- if v.isZiMo == 1 then
            --     strName = "自摸"..strName
            -- elseif v.isZiMo == 0 then
            --     if self.data.players.uid == v.paoId then
            --         strName = "放炮"
            --     else
            --         strName = "平胡"
            --     end
            -- end

            tempText:setString(strName or " ")

            local strScore = v.byTaiCount
            if strScore > 0 then strScore = "+"..strScore end
            tempScore:setString(strScore or "")
            -- tempImg:setTexture("mhxl_majiang/image/new_img/zhuan.png")
            -- self:getTypeCreateJiImg(4,IMGNode,v.cardType,v.jiType)
            _node:pushBackCustomItem(tempCell)
        end
        -- end
        

        
    end

    if tempUse_tai_count > 0 then
        for k,v in pairs(tempUse_tai_Data) do
            local tempCell = self.root:getChildByName("panel"):clone()

            tempCell:setSwallowTouches(false)

            local tempImg = tempCell:getChildByName("sp")
            local tempText = tempCell:getChildByName("text")
            local tempScore = tempCell:getChildByName("score")

            local IMGNode = display.newSprite():addTo(tempCell)
            IMGNode:setContentSize(cc.size(42, 48))
            IMGNode:setPosition(cc.p(60,20))

            local strName = self:getJiNameByTypeAndIndex(4,v.byType)
            tempText:setString(strName or " ")
            local strScore = v.byTaiCount
            if strScore > 0 then 
                strScore = "+"..strScore
            elseif  strScore == 0 then
                strScore = " "
            end
            tempScore:setString(strScore or "")
             _node:pushBackCustomItem(tempCell)
        end

    end

    if tempJIN > 0 then

        for k,v in pairs(tempJIDATA) do
            local tempCell = self.root:getChildByName("panel"):clone()
            tempCell:setSwallowTouches(false)
            local tempImg = tempCell:getChildByName("sp")
            local tempText = tempCell:getChildByName("text")
            local tempScore = tempCell:getChildByName("score")

            local IMGNode = display.newSprite():addTo(tempCell)
            IMGNode:setContentSize(cc.size(42, 48))
            IMGNode:setPosition(cc.p(60,20))

            local strName = self:getJiNameByTypeAndIndex(1,v.jiType)
            tempText:setString(strName or " ")

            local strScore = v.taiCount
            if strScore > 0 then strScore = "+"..strScore end
            tempScore:setString(strScore or "")
            -- tempImg:setTexture("mhxl_majiang/image/new_img/zhuan.png")
            self:getTypeCreateJiImg(1,IMGNode,v.cardType,v.jiType)
            _node:pushBackCustomItem(tempCell)
        end

        
    end

    if tempXQJN > 0 then

        for k,v in pairs(tempXQJData) do
            local tempCell = self.root:getChildByName("panel"):clone()
            tempCell:setSwallowTouches(false)
            local tempImg = tempCell:getChildByName("sp")
            local tempText = tempCell:getChildByName("text")
            local tempScore = tempCell:getChildByName("score")

            local IMGNode = display.newSprite():addTo(tempCell)
            IMGNode:setContentSize(cc.size(42, 48))
            IMGNode:setPosition(cc.p(60,20))

            local strName = self:getJiNameByTypeAndIndex(2,k)
            tempText:setString(strName or " ")
             local strScore = v.taiCount
            if strScore > 0 then strScore = "+"..strScore end
            tempScore:setString(strScore or "")
            -- tempImg:setTexture("mhxl_majiang/image/new_img/zhuan.png")
            self:getTypeCreateJiImg(2,IMGNode,v.jiType,-1)
            _node:pushBackCustomItem(tempCell)

        end

       
    end

    if tempDOUN > 0 then
        for k,v in pairs(tempDOUData) do
            local tempCell = self.root:getChildByName("panel"):clone()
            tempCell:setSwallowTouches(false)
            local tempImg = tempCell:getChildByName("sp")
            local tempText = tempCell:getChildByName("text")
            local tempScore = tempCell:getChildByName("score")

            local strName = self:getJiNameByTypeAndIndex(3,v.jiType)
            tempText:setString(strName or " ")
            local strScore = v.taiCount
            if strScore > 0 then strScore = "+"..strScore end
            tempScore:setString(strScore or "")

            local IMGNode = display.newSprite():addTo(tempCell)
            IMGNode:setContentSize(cc.size(42, 48))
            IMGNode:setPosition(cc.p(60,20))

            -- tempImg:setTexture("mhxl_majiang/image/new_img/zhuan.png")
            self:getTypeCreateJiImg(3,IMGNode,v.cardType,v.jiType)
            _node:pushBackCustomItem(tempCell)
        end
    end

end

function RoundEndingScoreLayer:showBirdCards(cards)
   if not cards then
        --todo
        return
    end

    local bird_card_plane = self.root:getChildByName("bird_card_plane")

    local height = bird_card_plane:getSize().height

    local count = table.getn(cards)
    for i=1,count do
        local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cards[i]["card"])

        local scale = height / card:getSize().height/2

        if cards[i]["position"] == 1 then
            --todo
            card:setColor(cc.c3b(200, 200, 50))

            local countKey = cards[i]["position"] .. "birdCount"

            if win_lose_table[countKey] then
                --todo
                local count = win_lose_table[countKey] + 1

                win_lose_table[countKey] = count
            else
                local count = 1
                win_lose_table[countKey] = count
            end
        end

        card:setScale(scale)
        if i<= 6 then
            card:setPosition(cc.p(card:getSize().width * scale * (i - 1) + card:getSize().width * scale / 2, height / 2+card:getSize().height/2))
        else
            card:setPosition(cc.p(card:getSize().width * scale * (i - 7) + card:getSize().width * scale / 2, card:getSize().height/2))
        end
        card:setScale(2)
        bird_card_plane:addChild(card)
        end
end

function RoundEndingScoreLayer:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))

end

--获取分数字符串
function RoundEndingScoreLayer:getScoreStr(_score)
    local tempScore = " "
    if tonumber(_score) >= 0 then
        tempScore = "+".._score
    else
        tempScore = _score 
    end
    return tempScore
end


function RoundEndingScoreLayer:onCallBack(_tag)
	if _tag == RoundEndingScoreLayer.BTN_KAN then
		self:clickBtnKan()
	elseif _tag == RoundEndingScoreLayer.BTN_CTN then
		self:cliclBtnCTN()
    elseif _tag == RoundEndingScoreLayer.BTN_ALL_RESULT5 then
        self:cliclBtnAllResult()
	end
end

function RoundEndingScoreLayer:clickBtnKan()
    local layer = SCENENOW["scene"]:getChildByName("roundEndingLayer")
    if layer then
        layer:setVisible(true)
    end
end

function RoundEndingScoreLayer:cliclBtnCTN()
    -- --清掉所有结算亮牌
    -- for k,v in pairs(XLMH_TOTAL_BIRD_CARD_PLANES) do
    --     v:removeAllChildren()
    -- end

    local layer = SCENENOW["scene"]:getChildByName("roundEndingLayer")
    if layer then
        layer:removeFromParent()
    end
    sendHandle:readyNow()
    self:removeFromParent()
end

function RoundEndingScoreLayer:cliclBtnAllResult()
    if XLMH_GROUP_ENDING_DATA then
        --todo
        require("mhxl_majiang.GroupEndingLayer"):showGroupResult(XLMH_GROUP_ENDING_DATA)
    end
    SCENENOW["scene"].isGameOver = false
    self:removeFromParent()
end


return RoundEndingScoreLayer