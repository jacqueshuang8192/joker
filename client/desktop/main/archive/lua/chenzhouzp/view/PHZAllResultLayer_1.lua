--local PHZAllResultLayer = class("PHZAllResultLayer", function ()
--   return cc.CSLoader:createNode("chenzhouzp/res/PHZAllResultLayer.csb")
--end)
local NewViewBaseLayer = require("chenzhouzp.NewViewBaseLayer")
local PHZAllResultLayer = class("PHZAllResultLayer", NewViewBaseLayer)

PHZAllResultLayer.BTN_RETURN = 1
PHZAllResultLayer.BTN_SHARE = 2
PHZAllResultLayer.BTN_CLOSE = 3
PHZAllResultLayer.BTN_EXTEND = 4

function PHZAllResultLayer:ctor(data)
    print("====查看玩家战绩====")
    local csbPath = "chenzhouzp/res/PHZAllResultLayer.csb"
    PHZAllResultLayer.super.ctor(self, csbPath)
    --dump(data)

	self:setNodeEventEnabled(true)
    self.data = data
    --test
    -- self.data = {
    --     {uid = 15033,score=100,huxilist={10,10,11,-12,14,23,14,12}},
    --     {uid = 15034,score=-80,huxilist={10,-8,11,-12,14,23,14,12}},
    --     {uid = 15035,score=-20,huxilist={10,-2,11,-12,14,23,14,12}},
    -- }
    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
	self:initUI()
    self:refreshAllListView()
    --self:setPositionX(SCREEN_WIDTH/2)
    --self:getChildByName("result_bg"):setScale(g_PHZMainScene:_getScaleParam2())
    --g_PHZMainScene:setRootSize(self)
end


function PHZAllResultLayer:onEnter()
end

function PHZAllResultLayer:onExit()
end

function PHZAllResultLayer:initUI()
	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.ended then
    			self:onCallBack(sender:getTag())
    		end
    	end
    end

    --self.btn_retrun = self:getChildByName("btn_retrun")
	self.btn_retrun:setTag(PHZAllResultLayer.BTN_RETURN)
	self.btn_retrun:addTouchEventListener(onTouchButton)

    self.btn_extend:setTag(PHZAllResultLayer.BTN_EXTEND)
    self.btn_extend:addTouchEventListener(onTouchButton)

    --self.btn_share = self:getChildByName("btn_share")
    self.btn_share:setTag(PHZAllResultLayer.BTN_SHARE)
    self.btn_share:addTouchEventListener(onTouchButton)

    --self.AllListView = self:getChildByName("AllAllListView")
    --self.AllListView:setPositionX(SCREEN_WIDTH/2)
    self.result_bg = self:getChildByName("result_bg")
    -- self.result_bg:setTag(PHZAllResultLayer.BTN_CLOSE)
    -- self.result_bg:addTouchEventListener(onTouchButton)

    if g_PHZMainScene.m_bGameCount < g_PHZMainScene.m_bMaxGameCount and g_PHZMainScene.m_isGameOver == false then
        self.btn_retrun:setVisible(false)
    else
        self.btn_retrun:setVisible(true)
    end
end

function PHZAllResultLayer:getMaxMinPlayerList()
    local tempPlayerList = {}
    if self.data == nil then return nil end
    if #self.data.player_info <= 0  then return nil end  

    local ccSort = function(a,b)
        return a.m_totalBlc > b.m_totalBlc
    end

   table.sort(self.data.player_info,ccSort)

   local maxScore = self.data.player_info[1].m_totalBlc

   for k,v in pairs(self.data.player_info) do
        if v.m_totalBlc == maxScore then
            table.insert(tempPlayerList,v.uid)
        end
   end

   return tempPlayerList
end

function PHZAllResultLayer:refreshAllListView()

    --local cell = require("chenzhouzp.view.PHZPlayerResultCell")
    local tempPlayerNum = self:getAllPlayerNum()

    if tempPlayerNum <= 0  then return end
    local tempData = {}

    for k,v in pairs(self.data.player_info) do
        if v.uid ~= 0 then
            table.insert(tempData,v)
        end
    end 

    for k,v in pairs(tempData) do
        local itemTemp = self.item:clone()
        self:refreshInfo(v,itemTemp)
        --self:addCell(self.AllListView,cell,v)
    end

end



function PHZAllResultLayer:addCell(cell,data)
    if #data.huxilist <= 0 then return end
    for k,v in pairs(data.huxilist) do
       local textItem = self.text_item:clone()
        local strHuXi =v
        strHuXi =strHuXi/100
        if strHuXi > 0 then
            strHuXi = "+"..strHuXi
        end
        textItem:getChildByName("Text_jushu"):setString("第"..k.."局")
        textItem:getChildByName("Text_huxi"):setString(strHuXi)
        cell:getChildByName("ListViewItem"):pushBackCustomItem(textItem)
    end

end

function PHZAllResultLayer:refreshAllListView2()

    local cell = require("chenzhouzp.view.PHZPlayerResultCell")
    local tempPlayerNum = self:getAllPlayerNum()

    if tempPlayerNum <= 0  then return end

    local tempData = {}
    for k,v in pairs(self.data.player_info) do
        if v.uid ~= 0 then
            table.insert(tempData,v)
        end
    end 

    local TableView = require("chenzhouzp.logic.TableView")
    local sizeSource = function(self, index)
        return cc.size(200, 460)
    end
    local loadSoruce = function(self, index)
        local Widget = ccui.Widget:create()
        -- dump(this.data[index])
        local item = cell.new(tempData[index])
        Widget:addChild(item)
        Widget:setContentSize(200,460)
        return Widget
    end

    local unloadSoruce = function(self, index)
    end

    TableView.attachTo(self.AllListView, sizeSource, loadSoruce, unloadSoruce)
    self.AllListView:initDefaultItems(tempPlayerNum)
    self.AllListView:jumpTo(1)
    self.AllListView:addScrollViewEventListener(function(ref, type)
    end)
end

function PHZAllResultLayer:getAllPlayerNum()
    if self.data ==nil then
        return 0
    end
    local tempAllPlayerN = 0
    for k,v in pairs(self.data.player_info) do
        if v.uid ~= 0 then
            tempAllPlayerN = tempAllPlayerN + 1
        end
    end
    return tempAllPlayerN
end

function PHZAllResultLayer:onCallBack(_tag)
	if _tag == PHZAllResultLayer.BTN_RETURN then
		self:clickBtnReturn()
	elseif _tag == PHZAllResultLayer.BTN_SHARE then
		self:cliclBtnShare()
    elseif _tag == PHZAllResultLayer.BTN_CLOSE then
        self:cliclBtnClose()
	elseif _tag == PHZAllResultLayer.BTN_EXTEND then
        self:cliclBtnExtend()
    end
end

function PHZAllResultLayer:cliclBtnClose()
   --if g_PHZMainScene.m_bGameCount < g_PHZMainScene.m_bMaxGameCount then
   --   self:removeFromParent()
   --end
    self:removeSelf()
end

function PHZAllResultLayer:clickBtnReturn()
    self:removeSelf()
    print("返回大厅")
    bm.isDisbandSuccess = true
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)

end

function PHZAllResultLayer:cliclBtnExtend()
    dump(USER_INFO["activity_id"],"activity_idx------>")
    --再来一局
    if USER_INFO["activity_id"] then
        require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"], TpackageName .. ".gameScene")
    end
end

function PHZAllResultLayer:cliclBtnShare()
    print("名片分享")
    --通知APP分享结果
    local paras = {}
    paras["showType"] = 2;
    paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
    paras["imagePath"] = "screen"
    paras["name"] = "分享结果"
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"],9999999)
    end
end
--设置玩家总得分情况
function PHZAllResultLayer:refreshInfo(data,cell)
    dump(data,"refreshInfo")
    if data.m_totalBlc > 0 then
        --self.img_max_winner_1:setVisible(true)
        --self.img_max_winner_2:setVisible(true)
        data.m_totalBlc = "+".. (data.m_totalBlc /100)
        data.totalScore = "+".. (data.totalScore)
    else
        data.m_totalBlc = data.m_totalBlc/100
        data.totalScore = data.totalScore
    end
    dump(data.m_totalBlc,"self.data.score")
    dump(data.totalScore,"self.data.totalScore")
    cell:getChildByName("txt_score"):setString(data.m_totalBlc or "")
    cell:getChildByName("txt_all_huxi"):setString(data.totalScore  or "")
    cell:getChildByName("txt_score"):setVisible(true)
    cell:getChildByName("txt_all_huxi"):setVisible(true)
    local playerImg =  cell:getChildByName("playerImg")
    local icon_url = USER_INFO.icon_url
    local sex = USER_INFO.sex
    local nick = USER_INFO.nick

    if data.uid ~= USER_INFO.uid then
        local playerData = g_PHZMainScene.otherInfo[data.uid]
        if not playerData then return end
        icon_url = playerData.portrait
        sex = playerData.sex
        nick = playerData.nickName
    end
    nick = require("hall.GameCommon"):formatNick(nick, 3)
    cell:getChildByName("playerName"):setString(nick or "")
    self:addCell(cell,data)
    require("hall.GameCommon"):getUserHead(icon_url,data.uid,sex,playerImg, 96, false,nick)
    self.AllListView:pushBackCustomItem(cell)
end
return PHZAllResultLayer