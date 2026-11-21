local PHZPlayerResultCell = class("PHZPlayerResultCell", function ()
   return cc.CSLoader:createNode("pengpengzp/res/PHZPlayerResultCell.csb")
end)


function PHZPlayerResultCell:ctor(data,maxWinList)
	self:setNodeEventEnabled(true)
    self.data = data
    --self.maxWinList = maxWinList
    dump(self.data)
    --self.isMaxWin = self:getIsMaxWin()
    self.m_allHuxi = 0

	self:initUI()
end

function PHZPlayerResultCell:getIsMaxWin()
    for k,v in pairs(self.maxWinList) do
        if self.data.uid == v then
            return true
        end
    end
    return false
end

function PHZPlayerResultCell:getAllHuxi()
    if not self.data  then return 0 end
    local tempHuXi = 0
    for k,v in pairs(self.data.huxilist) do
        tempHuXi = tempHuXi + v
    end
    return tempHuXi
end

function PHZPlayerResultCell:onEnter()
end

function PHZPlayerResultCell:onExit()
    self.m_allHuxi = 0
    self.listView:removeAllChildren()
end

function PHZPlayerResultCell:initUI()
	self.img_max_winner_1 = self:getChildByName("img_winner_max_1")
    self.img_max_winner_2 = self:getChildByName("img_winner_max_2")

    self.img_max_winner_1:setVisible(false)
    self.img_max_winner_2:setVisible(false)

    self.playerImg = self:getChildByName("playerImg")
    self.txt_score = self:getChildByName("txt_score")
    self.txt_all_huxi = self:getChildByName("txt_all_huxi")
    --self.txt_all_huxi:setVisible(false)
    self.playerName = self:getChildByName("pllayerName")

    self.listView = self:getChildByName("ListView_1")

    self:refreshInfo()
    self:refreshListView()

end

--设置玩家总得分情况
function PHZPlayerResultCell:refreshInfo()
    if self.data.m_totalBlc > 0 then
        --self.img_max_winner_1:setVisible(true)
        --self.img_max_winner_2:setVisible(true)
        self.data.m_totalBlc = "+".. (self.data.m_totalBlc /100)
        self.data.totalScore = "+".. (self.data.totalScore /100)
    else
        self.data.m_totalBlc = self.data.m_totalBlc/100
        self.data.totalScore = self.data.totalScore/100
    end
    dump(self.data.m_totalBlc,"self.data.score")
    dump(self.data.totalScore,"self.data.totalScore")
    self.txt_score:setString(self.data.m_totalBlc or "")
    self.txt_all_huxi:setString(self.data.totalScore  or "")
    self.txt_score:setVisible(true)
    self.txt_all_huxi:setVisible(true)
    local icon_url = USER_INFO.icon_url
    local sex = USER_INFO.sex
    local nick = USER_INFO.nick

    if self.data.uid ~= USER_INFO.uid then
        local playerData = g_PHZMainScene.otherInfo[self.data.uid]
        if not playerData then return end
        icon_url = playerData.portrait
        sex = playerData.sex
        nick = playerData.nickName
    end
    nick = require("hall.GameCommon"):formatNick(nick, 3)
    self.playerName:setString(nick or "")
    require("hall.GameCommon"):getUserHead(icon_url,self.data.uid,sex,self.playerImg, 96, false,nick)

end

function PHZPlayerResultCell:refreshListView()
    local this = self
    local cell = require("pengpengzp.view.PHZHuXi")

    self.listView:removeAllChildren()

    if #self.data.huxilist <= 0 then return end

    -- listview add
    for k,v in pairs(self.data.huxilist) do
        self:addCell(cell,v,k)
    end

    -- local TableView = require("pengpengzp.logic.TableView")
    -- local sizeSource = function(self, index)
    --     return cc.size(240, 40)
    -- end
    -- local loadSoruce = function(self, index)
    --     local Widget = ccui.Widget:create()
    --     local item = cell.new(this.data.huxilist[index],index)
    --     Widget:addChild(item)
    --     Widget:setContentSize(240,40)
    --     return Widget
    -- end

    -- local unloadSoruce = function(self, index)
    -- end

    -- TableView.attachTo(self.listView, sizeSource, loadSoruce, unloadSoruce)
    -- self.listView:initDefaultItems(#self.data.huxilist)
    -- self.listView:jumpTo(1)

    -- self.listView:addScrollViewEventListener(function(ref, type)
        
    -- end)
end

function PHZPlayerResultCell:addCell(cell,data,index)
    if not cell then return end
    if not data then return end
    if not index then return end
    local Widget = ccui.Widget:create()
    local item = cell.new(data,index)
    Widget:addChild(item)
    Widget:setContentSize(cc.size(self.listView:getContentSize().width,40))
    Widget:setAnchorPoint(cc.p(0, 0))
    self.listView:pushBackCustomItem(Widget)
end

return PHZPlayerResultCell