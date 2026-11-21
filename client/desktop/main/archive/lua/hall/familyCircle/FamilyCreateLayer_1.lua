--[[
* author:   hzp
* date:     2019-06-11
* 创建亲友圈
--]]
local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyCreateLayer = class("FamilyCreateLayer", ViewBaseLayer)
local Figure = require("hall.familyCircle.Figure")
local FamilyCreateTip = require("hall.familyCircle.FamilyCreateTip")
local clubSendData = require("hall.view.clubView.clubSendData")
local FamilyCell =  require("hall.familyCircle.FamilyCell")
local FamilyData = require("hall.familyCircle.FamilyData")
local FamilyMainLayer = require("hall.familyCircle.FamilyMainLayer")
local CommonTips = require("hall.tips.CommonTips")
local CocosUtil = require("hall.util.CocosUtil")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")

function FamilyCreateLayer:ctor()

    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height


    local csbPath = "hall/res/FriendScircle/createCircleLayer.csb"
    FamilyCreateLayer.super.ctor(self, csbPath)

    --add by zzy 2019-7-24
    self.listData = {}
    self:CreateGirl(self.listData)
    self:createTableView()
    self:InitGame()
end

function FamilyCreateLayer:InitGame()
    --delect by zzy
    -- self:SetGirlStatus()
    --end
    FamilyData:Init()

    self:ObserFamilyList()

end 

--test by zzy 2019-7-24
function FamilyCreateLayer:createTableView()

    self.userList = cc.TableView:create(cc.size(1230*SCREEN_WIDTH/1280, 457))
    self.userList:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) 
    self.userList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.userList:setAnchorPoint(cc.p(0, 0))
    self.userList:setPosition(cc.p(50, 120))
    self.userList:setDelegate()
    self.userList:addTo(self.root)
    self.userList:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self.userList:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self.userList:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.userList:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.userList:reloadData()
end

--test
function FamilyCreateLayer:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local item = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
        local userBar = self:createUser(self.listData[idx+1], idx + 1)
        cell:addChild(userBar)
    else
        local node = cell:getChildByName("ly"):getChildByName("playerNode")
        self:initCellInfo(node,self.listData[idx+1], idx + 1)
     end
     return cell
end

function FamilyCreateLayer:initCellInfo(_node,userItem,index)
    local tempRoot = _node:getChildByName("layout")
    local _bgIndex = 1

    for id , v in pairs(userItem) do 
        v = json.decode(v)
        FamilyData:SetFamilyData(id , v)
        local cellBg1 = tempRoot:getChildByName("cellBg1")
        local cellBg2 = tempRoot:getChildByName("cellBg2")
        local tempN = index%2
        --add by zzy 非常奇怪，为啥用setTexTure 无效
        if tempN == 1 then
            cellBg1:setVisible(false)
            cellBg2:setVisible(true)
        elseif tempN == 0 then
            cellBg1:setVisible(true)
            cellBg2:setVisible(false)
        end

        tempRoot:getChildByName("family_name"):setString(v.groupName or "")
        tempRoot:getChildByName("family_id"):setString("亲友圈ID:" .. id)
        FamilyData:GetClubUserInfo(v.owerId , handler(self , self.DelearWithName) , tempRoot:getChildByName("create_name"))
        tempRoot:getChildByName("create_id"):setString(v.owerId)
        tempRoot:getChildByName("member_num"):setString(v.playerCount or "??")
        tempRoot:getChildByName("flagImg"):setVisible(USER_INFO["uid"] == v.owerId)

        tempRoot:getChildByName("txt_Delect"):setVisible(false)
        tempRoot:getChildByName("txt_exit"):setVisible(false)

        --add by zzy 
        tempRoot:getChildByName("btnDelect"):setVisible(USER_INFO["uid"] == v.owerId)
        tempRoot:getChildByName("btnExit"):setVisible(USER_INFO["uid"] ~= v.owerId)
        tempRoot:getChildByName("txt_Delect"):setVisible(USER_INFO["uid"] == v.owerId)
        tempRoot:getChildByName("txt_exit"):setVisible(USER_INFO["uid"] ~= v.owerId)

        tempRoot:getChildByName("btnDelect"):onClick(CocosUtil:Bind(self.showDelectTip , self , index , id,v.owerId))
        tempRoot:getChildByName("btnExit"):onClick(CocosUtil:Bind(self.showExitTip , self , index , id))

        require("hall.GameCommon"):getUserHead(v.owerUrl, "", "", tempRoot:getChildByName("headImg"), 70 , false, "", true)
        tempRoot:getChildByName("btnToTop"):onClick(CocosUtil:Bind(self.JumpTopIndex , self , index , self.listData))
        tempRoot:getChildByName("btnJoin"):onClick(CocosUtil:Bind(self.JoinFamily , self , id , USER_INFO["uid"] == v.owerId))
        
        local this = self
        self.moveT = 0
        local function onTouchButton(sender,eventType)
            if sender then
                if eventType == ccui.TouchEventType.began then
                    sender:setScale(1.1)
                    this.moveT = 0
                elseif eventType == ccui.TouchEventType.moved then
                    this.moveT = this.moveT + 1
                elseif eventType == ccui.TouchEventType.ended then
                    sender:setScale(1)
                    if this.moveT <= 15 then
                        this:JoinFamily(id,USER_INFO["uid"] == v.owerId)
                    end
                    this.moveT = 0
                elseif eventType == ccui.TouchEventType.canceled then
                    sender:setScale(1)
                    this.moveT = 0
                end
            end
        end
        tempRoot:addTouchEventListener(onTouchButton)
        -- tempRoot:onClick(CocosUtil:Bind(self.JoinFamily , self , id , USER_INFO["uid"] == v.owerId))
        tempRoot:setSwallowTouches(false)

    end 
end

--test
function FamilyCreateLayer:createUser(userItem, index)
    local ly = ccui.Layout:create()
    ly:setContentSize(cc.size(520, 455))

    local node = cc.CSLoader:createNode("hall/res/FriendScircle/familyCell.csb")
    node:setName("playerNode")
    node:setScaleX(SCREEN_WIDTH/1280)

    self:initCellInfo(node,userItem, index)
  
    ly:addChild(node)
    ly:setName("ly")
  
    return ly
end

function FamilyCreateLayer:tableCellTouched(view, cell)
    -- JoinFamily(family_id , home_status)
end

function FamilyCreateLayer.cellSizeForTable()
    return 450, 455
end

function FamilyCreateLayer:numberOfCellsInTableView()
    return #self.listData or 0
end

function FamilyCreateLayer:RefushJLBList(data)
    self.listData = {}
    self.__girl:SetVisible(not next(data))
    if not data then return end
    self.listData = data
    self.userList:reloadData()
end


function FamilyCreateLayer:SetGirlStatus()
    local data = {playerId = USER_INFO["uid"]}
    local function callback(returnCode, data)
        if returnCode == 0 then
            -- if self.CreateGirl then  --屏蔽因为进入游戏再返回该协议，报空
            --     self:CreateGirl(data)
            -- end
        end
    end
    clubSendData:requestClubList(data, callback)
end

function FamilyCreateLayer:CreateGirl(data)
    self.__girl = Figure.new(self)
    self.__girl:SetPositionX(400)
    self.__girl:SetString("0  \"创建\"或者\"加\n入\"亲友圈吧!加入亲友圈\n需要的ID。可联系群主获得")
    self.__girl:SetLabelPosition(490 , 470)
    self.__girl:SetVisible(not next(data))

    -- delect by zzy 2019-7-24
    -- self:ObserFamilyList()
    -- end
end

function FamilyCreateLayer:ShowFamilyList()
    FamilyUntils:RemoveCommonTip()
    self:ObserFamilyList()
end 

function FamilyCreateLayer:ObserFamilyList()
    local data = {playerId = USER_INFO["uid"]}
    local function callback(returnCode, data)
            if returnCode == 0 then
                if self then  --屏蔽因为进入游戏再返回该协议，报空
                    -- delect by zzy 2019-7-24
                    -- self:RemoveChildren()
                    -- end
                    -- if self.CreateGirl then
                    --     self:CreateGirl(data)
                    -- end
                    if self.loadClubList then 
                        local list_data = FamilyUntils:PackData(data)
                        -- self.__girl:SetVisible(not next(list_data))
                        print("======玩家相关信息！！！=====")
                        self:loadClubList(list_data)
                    end
                end
               
            end
        end
    clubSendData:requestClubList(data, callback)
end 

function FamilyCreateLayer:loadClubList(list_data)

    self:RefushJLBList(list_data)

end


function FamilyCreateLayer:showDelectTip( index,groupId,ownerId)
    local this = self
    local function callFunc()
        this:DelectJLB(index,groupId,ownerId)
    end
    local data = {type = 2, title = "提示", content = "是否解散联盟？", callBackSure = callFunc} 

    require("hall.tips.CommonTips"):showTips(data)
end

function FamilyCreateLayer:showExitTip( index,groupId)
    local this = self
    local function callFunc()
        this:ExitJLB(index , groupId)
    end
    local data = {type = 2, title = "提示", content = "是否退出联盟？", callBackSure = callFunc} 

    require("hall.tips.CommonTips"):showTips(data)
end


function FamilyCreateLayer:DelectJLB(index , groupId,ownerId)
    print("======DelectJLB======")
    local this = self
    local interfaceName = "/deleteGroupByOwerId"
    local httpType = "POST"

     local data = {
            owerId = ownerId,
            groupId = groupId,
     }
    local function callback(returnCode, data)
     
    end

    cct.createHttRq({
        url = HttpAddr .. interfaceName,
        date = data,
        type_= httpType,

        callBack = function(data)
            local returnCode = tonumber(json.decode(data.netData).returnCode)
            if 0 == returnCode then 
                -- delected by zzy 2019-7-24
                this:InitGame()
                -- end
                CommonTips:showTips(FamilyUntils:SetCommTipLabel("解散联盟成功"))
            elseif 1 == returnCode then 
                CommonTips:showTips(FamilyUntils:SetCommTipLabel("解散联盟失败"))
            end 
        end})
end

function FamilyCreateLayer:ExitJLB(index , groupId)
     local this = self
    local interfaceName = "/playerExitGroupByGroupId"
    local httpType = "POST"

     local data = {
            playerId = USER_INFO.uid,
            groupId = groupId,
     }
    local function callback(returnCode, data)
    end

    cct.createHttRq({
        url = HttpAddr .. interfaceName,
        date = data,
        type_= httpType,

        callBack = function(data)
            local returnCode = tonumber(json.decode(data.netData).returnCode)
            if 0 == returnCode then 
                this:InitGame()
                CommonTips:showTips(FamilyUntils:SetCommTipLabel("退出联盟成功"))
            elseif 1 == returnCode then 
                CommonTips:showTips(FamilyUntils:SetCommTipLabel("退出联盟失败"))
            end 
        end})
end

function FamilyCreateLayer:DelearWithName(data , name_node)
    if tolua.isnull(name_node) then 
        return 
    end
    dump(data,"====DelearWithName=====")
    -- local name = data["playerProfile"]["nickName"]
    local name = data.playerProfile.nickName
    local nick_name = string.sub(name , 1 , 12) .. "..."
    name_node:setString(nick_name)
end

function FamilyCreateLayer:JumpTopIndex(index , list_data) 
    print("====JumpTopIndex====",JumpTopIndex)
    -- self:RemoveChildren()
    -- if  self.familycell then 
    --     self.familycell:RemoveFromParents()
    --     self.familycell = nil
    -- end 
    list_data[1] , list_data[index] = list_data[index] , list_data[1]
    FamilyUntils:SetListData(list_data)
    self:loadClubList(list_data)
end

function FamilyCreateLayer:JoinFamily(family_id , home_status)
    if self.familyMainlayer then
        self.familyMainlayer:setVisible(true)
        self.familyMainlayer:FreshData(family_id , home_status , FamilyData, self)
    else
        self.familyMainlayer = FamilyMainLayer.new(family_id , home_status , FamilyData, self):addTo(self)
    end
    USER_INFO["family_data"] = {
        ["family_id"] = family_id ,
        ["home_status"] = home_status ,
        ["FamilyData"] = FamilyData,
    }
    FamilyData:SetFamilyId(family_id)
end

function FamilyCreateLayer:onClickBtnCreateCircle(...)
    FamilyCreateTip.new(self):addTo(self)
end

function FamilyCreateLayer:onClickBtnJoin(...)
    self.enterRoomLayer = require("hall.createAndEnterRoom.EnterRoomLayer").new():addTo(self)
    self.enterRoomLayer:SetFunc(CocosUtil:Bind1(self.JoinFunc , self))
end

function FamilyCreateLayer:JoinFunc(password)
     local data =  {
        groupId = password,
        playerId = USER_INFO["uid"]
    }
    local function callback(returnCode, data)
        if returnCode == 0 then
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("申请成功"))
            self:RemoveEnterRoom()
            return 
        end
        CommonTips:showTips(FamilyUntils:SetCommTipLabel("申请失败 , 联盟ID不存在"))
        self:RemoveEnterRoom()
    end
    require("hall.view.clubView.clubSendData"):requestJoinClub(data, callback)
end

function FamilyCreateLayer:RemoveEnterRoom()
    if self.enterRoomLayer and not tolua.isnull(self.enterRoomLayer)  then
        self.enterRoomLayer:onClickBtnClose()
        self.enterRoomLayer = nil
    end
   
end

function FamilyCreateLayer:onClickBtnReturn( ... )
    USER_INFO["family_data"] = nil
    self:setVisible(false)
    -- self:removeSelf()
end

function FamilyCreateLayer:RemoveChildren()
     self.ListView:removeAllChildren()
end

function FamilyCreateLayer:onExit()
    g_hallMainLayer.familyCreateLayer = nil
end

return FamilyCreateLayer