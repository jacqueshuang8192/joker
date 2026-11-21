--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local LINE_HEIGTH = 80

local ViewBaseLayer = require("hall.NewViewBaseLayer")
local FamilyCreateGame = class("FamilyCreateGame"  , ViewBaseLayer)
local FamilyData = require("hall.familyCircle.FamilyData")
local GetGameName = require("hall.familyCircle.GetGameName")

local EVENTNAME = {
	ADD_GAME_CONFIG = "/addGameConfig", 
	A2I_CREATE_FREE_GAME = "/freeGame/A2IcreateFreeGame", 
	GOTO_CLUB = "/gotoClub",
}

function FamilyCreateGame:ctor(parents,type,level,data,gameType,length,configId,family_id)
    -- body
    ReqMgr:addHandle("FamilyCreateGame", EVENTNAME)
    local csbPath = "hall/res/FriendScircle/setuptip/setuptip.csb"
    FamilyCreateGame.super.ctor(self, csbPath)
    self:enableMask(true)
    self.parents = parents
    self.type = type
    self.length = length
    self.family_id = family_id
    self.gameType = gameType
    self.configId = configId

    --self.index = _index

    self.data = data
    self:InitGame()
    self.level = level

    dump(self.level,"self.level------------>")
    dump(self.data,"self.data------------>")
    dump(self.gameType,"self.gameType------------>")
    dump(self.configId,"self.configId------------>")

    if tolua.isnull(self.listView) then
        return
    end
    self.listView:setScrollBarEnabled(false)  --去掉下拉条

    --add by zzy  实现玩家游戏配置根据数据来自动显示游戏的列表分布
    --将原来csb中的按钮进行影藏
    self:setOldBtnHide()
    self:setBtnByType()

    self.gameListBtnArr = {}
    if self.type == 1 then
        self:addCrateConfig(gameType)
        --self:initListViewGame()
    elseif self.type == 2 then
        --self:openRoomInfoTip(data)
        dump(data,"datainitChangeWaysListViewGame")
        self:initChangeWaysListViewGame()
    end

end

function FamilyCreateGame:setBtnByType()

    if self.type == 1 then
        self.btnCreate:setVisible(true)
        self.btnChange:setVisible(false)
        self.btnDelConfig:setVisible(false)
    elseif self.type == 2 then
        self.btnCreate:setVisible(false)
        self.btnChange:setVisible(true)
        self.btnDelConfig:setVisible(true)
    end
end

function FamilyCreateGame:setOldBtnHide()
    self.btnPaodewkuai:setVisible(false)
    self.btnBiji:setVisible(false)
    self.btnHongzhong:setVisible(false)
    self.btnPaohuzi:setVisible(false)
    self.btnPintianjiu:setVisible(false)
    self.btnTuiduizi:setVisible(false)
    self.btnCell:setVisible(false)
end

function FamilyCreateGame:addCrateConfig(gameType)
    dump(gameType, "leve77l")
    local index = 1;
    dump(bm.gameList_forRoomCard,"bm.gameList_forRoomCard---------->>>>")
    for k, v1 in pairs( bm.gameList_forRoomCard ) do
        dump(v1.gameArr,"v1.gameArr-->>")
        for i, v2 in ipairs( v1.gameArr or {} ) do
            -- if v2.level == self.data.gameConfig.level and 325 ~= tonumber(v2.level) then
            dump(v2.gameType,"v2.gameType")
            dump(gameType,"gameType")
            if tonumber(v2.gameType) == tonumber(gameType)   then
                local layout = self.btnCell:clone()
                layout:setVisible(true)
                local txtName = layout:getChildByName("Text_1")
                txtName:setString(v2.name)
                layout:setTag(v2.level)
                txtName:setTag(index)
                table.insert(self.gameListBtnArr,layout)
                self.ListViewGame:pushBackCustomItem(layout)
                if index == 1 then
                    if bm.localGameList[v2.level] and next(bm.localGameList[v2.level]) then
                        self:openRoomInfoTip(bm.localGameList[v2.level])
                    else
                        require(Request_filePath):getCreateGroupGameConfigForGoldGame(v2.level, handler(self, self.openRoomInfoTip))
                    end
                end
                index= index+1;

            end
        end
    end
end
function FamilyCreateGame:initChangeWaysListViewGame()
    self.gameListBtnArr = {}
    self.ListViewGame:removeAllChildren()
    local _index = 1
	--dump(bm.gameList_forRoomCard, 'xxx')
    for k, v1 in pairs( bm.gameList_forRoomCard ) do
        for i, v2 in ipairs( v1.gameArr or {} ) do
            --dump(v2,"====gewgwegwegv2")
            -- if v2.level == self.data.gameConfig.level and 325 ~= tonumber(v2.level) then
            if v2.level == self.data.gameConfig.level  then
                 local layout = self.btnCell:clone()
                 layout:setVisible(true)
                 local txtName = layout:getChildByName("Text_1")
                 txtName:setString(v2.name)
                 layout:setTag(v2.level)
                 txtName:setTag(_index)
                 table.insert(self.gameListBtnArr,layout)
                 self.ListViewGame:pushBackCustomItem(layout)
                 if bm.localGameList[v2.level]  and next(bm.localGameList[v2.level])  then
                     dump("bm.localGameList[v2.level]")
                     self:openRoomInfoTip(bm.localGameList[v2.level])
                 else
                     dump("getCreateGroupGameConfigForGoldGame")
                     local params ={}
                     params["groupId"] = self.family_id
                     params["playerId"] = USER_INFO["uid"]
                     params["configId"] = self.configId
                     --require(Request_filePath):getSelectGameConfig(params, handler(self, self.openRoomInfoTip))
                     require(Request_filePath):getCreateGroupGameConfigForGoldGame(v2.level, handler(self, self.openRoomInfoTip))
                 end

                 _index = _index + 1
            end

        end
    end

    if #self.gameListBtnArr > 0 then
        self:setAllBtnUnclickNew()
        self.gameListBtnArr[1]:loadTextures(self.file_path[2] , self.file_path[2] , nil)
    end
end

--根据游戏配置数据来实现游戏的列表
function FamilyCreateGame:initListViewGame()
    self.gameListBtnArr = {}
    self.ListViewGame:removeAllChildren()
    local _index = 1
    for k, v1 in pairs( bm.gameList_forRoomCard ) do
        for i, v2 in ipairs( v1.gameArr or {} ) do
            if v2.level == 354 or v2.level == 349 or v2.level == 356
                    or v2.level == 353 or v2.level == 350
                    or v2.level == 351 or v2.level == 352
                    or v2.level == 355  then
            else
                if _index == 1 then
                    if bm.localGameList[v2.level]  and next(bm.localGameList[v2.level]) then
                        self:openRoomInfoTip(bm.localGameList[v2.level])
                    else
                        require(Request_filePath):getCreateGroupGameConfigForGoldGame(v2.level, handler(self, self.openRoomInfoTip))
                    end

                end

                if v2.level then
                    local layout = self.btnCell:clone()
                    layout:setVisible(true)
                    local txtName = layout:getChildByName("Text_1")
                    txtName:setString(v2.name)
                    layout:setTag(v2.level)
                    txtName:setTag(_index)
                    table.insert(self.gameListBtnArr,layout)
                    self.ListViewGame:pushBackCustomItem(layout)
                    _index = _index + 1
                end

            end
        end
    end

    if #self.gameListBtnArr > 0 then
        self:setAllBtnUnclickNew()
        self.gameListBtnArr[1]:loadTextures(self.file_path[2] , self.file_path[2] , nil)
    end

end

function FamilyCreateGame:setAllBtnUnclickNew()
    for i,v in ipairs(self.gameListBtnArr) do
        v:loadTextures(self.file_path[2] , self.file_path[2] , nil)
        v:getChildByName("Text_1"):setColor(cc.c3b(29, 69, 123))
    end
end

function FamilyCreateGame:onClickBtnCell(sender,event)
    self:setAllBtnUnclickNew()
    sender:loadTextures(self.file_path[1] , self.file_path[1] , nil)
    local Text_1 = sender:getChildByName("Text_1")
    Text_1:setColor(cc.c3b(133, 98, 59))
    local tempLevel = sender:getTag()
    local tempIndex = sender:getChildByName("Text_1"):getTag()
    --self.gameListBtnArr[tempIndex]:loadTextures(self.file_path[2] , self.file_path[2] , nil)
    for k, v1 in pairs( bm.gameList_forRoomCard ) do
        for i, v2 in ipairs( v1.gameArr or {} ) do
            if tonumber(v2.level) == tonumber(tempLevel)  then
                if bm.localGameList[v2.level]  and next(bm.localGameList[v2.level]) then
                    self:openRoomInfoTip(bm.localGameList[v2.level])
                else
                    require(Request_filePath):getCreateGroupGameConfigForGoldGame(tempLevel, handler(self, self.openRoomInfoTip))
                end

            end
        end
    end
end

function FamilyCreateGame:InitGame( ... )
    self.file_path = {
        "hall/res/FriendScircle/setuptip/btn_2.png" ,
        "hall/res/FriendScircle/setuptip/btn_1.png" ,
    }
    self.btnPaodewkuai:loadTextures(self.file_path[2] , self.file_path[2] , nil)
    -- require(Request_filePath):getCreateGroupGameConfigForGoldGame(324, handler(self, self.openRoomInfoTip))
    FamilyData:Init()

    self:InitAllGameConfig()
end

function FamilyCreateGame:setAllBtnUnclick()
    self.btnPaodewkuai:loadTextures(self.file_path[1] , self.file_path[1] , nil)
    self.btnBiji:loadTextures(self.file_path[1] , self.file_path[1] , nil)
    self.btnHongzhong:loadTextures(self.file_path[1] , self.file_path[1] , nil)
    self.btnPaohuzi:loadTextures(self.file_path[1] , self.file_path[1] , nil)
    self.btnPintianjiu:loadTextures(self.file_path[1] , self.file_path[1] , nil)
    self.btnTuiduizi:loadTextures(self.file_path[1] , self.file_path[1] , nil)
end

function FamilyCreateGame:onClickBtnPaodewkuai()
    print ("跑得快")
    self:setAllBtnUnclick()
    self.btnPaodewkuai:loadTextures(self.file_path[2] , self.file_path[2] , nil)
end

function FamilyCreateGame:onClickBtnBiji()
    print ("比鸡")
    self:setAllBtnUnclick()
    self.btnBiji:loadTextures(self.file_path[2] , self.file_path[2] , nil)

end

function FamilyCreateGame:onClickBtnHongzhong()
    print ("快乐麻将")
    self:setAllBtnUnclick()
    self.btnHongzhong:loadTextures(self.file_path[2] , self.file_path[2] , nil)

end

function FamilyCreateGame:onClickBtnPaohuzi()
    print ("跑胡子")
    self:setAllBtnUnclick()
    self.btnPaohuzi:loadTextures(self.file_path[2] , self.file_path[2] , nil)

end

function FamilyCreateGame:onClickBtnPintianjiu()
    print ("拼天九")
    self:setAllBtnUnclick()
    self.btnPintianjiu:loadTextures(self.file_path[2] , self.file_path[2] , nil)

end

function FamilyCreateGame:onClickBtnTuiduizi()
    print ("推对子")
    self:setAllBtnUnclick()
    self.btnTuiduizi:loadTextures(self.file_path[2] , self.file_path[2] , nil)

end

--根据游戏的level，获取玩家的
function FamilyCreateGame:getGameConfigByLevel(_level)
    -- body
end

function FamilyCreateGame:InitAllGameConfig()
    for k, v1 in pairs( bm.gameList_forRoomCard ) do
        for i, v2 in ipairs( v1.gameArr or {} ) do
            -- print("======999999=====")
            -- print("======999999=====")
            -- print("======999999=====")
            -- print("======999999=====")
            -- print("======999999=====")
            -- print("======999999=====")
            -- dump(v2)
        end
    end
end

function FamilyCreateGame:openRoomInfoTip(roomInfo)
    dump(roomInfo,"roomInfo")
    dump(bm.localGameList,"bm.localGameList---->>>")
    bm.localGameList[roomInfo.level] = roomInfo

    if  tolua.isnull(self.listView) then
        return
    end
    self.listView:removeAllChildren()
    self.parameter = {}
    self.multiChoseOption = {}
    if self.data and next(self.data) then
        local tempData = self:updateConfigDefaultPara(self.data,roomInfo)
        dump(tempData,"tempData----------------------->>")
        self:initGameData(tempData)
        self:loadRoomInfo(tempData)
    else
        self:initGameData(roomInfo)
        self:loadRoomInfo(roomInfo)
    end

end


function FamilyCreateGame:initGameData(gameConfig)
    dump(gameConfig,"------gameConfig")
   
    
--记录当前游戏的抽水
    self.parameter["additionalPoint"] = gameConfig.additionalPoint or 0
    --平摊或者赢家
    self.parameter["oneOrAll"] = gameConfig.oneOrAll or 2

    --记录当前游戏的游戏id
    self.parameter["gameId"] = gameConfig.gameId
    --记录当前游戏对应的等级
    self.parameter["level"] = gameConfig.level
    --记录当前游戏对应的底注
    self.parameter["diZhu"] = gameConfig.dizhu
    --记录当前游戏对应的筹码
    self.parameter["chouMa"] = gameConfig.chouMa
    --记录当前游戏对应的大类名
    self.parameter["gameName"] = gameConfig.gameName
    --创建金币场时选择的底注
    self.parameter["baseChip"] = gameConfig.baseChip
    self.parameter["profitType"] = gameConfig.profitType
    self.parameter["rateOrConstant"] = gameConfig.rateOrConstant
    self.parameter["profit"] = gameConfig.profit
    self.parameter["profitLimit"] = gameConfig.profitLimit
    self.parameter["joinGamePoint"] = gameConfig.joinGamePoint
    self.parameter["readyPoint"] = gameConfig.readyPoint
    self.parameter["baseChip"] = gameConfig.baseChip
    self.parameter["gameType"] = self.gameType
    self.parameter.secConstant = gameConfig.secConstant or ""
    if gameConfig.startCost and gameConfig.startCost > 0 then
        self.parameter.startCost = gameConfig.startCost
    end
    self:setRoomDefaultPara(gameConfig)


end

function FamilyCreateGame:updateConfigDefaultPara(data,gameData)
    dump(gameData,"gameData-------->>>")
    for k1, v1 in pairs( gameData.gameConfig or {} ) do
        self.multiChoseOption[v1.configGroup[1].config] = {}
        if v1.configGroup[2] then
            self.multiChoseOption[v1.configGroup[2].config] = {}
        end
        for k2, v2 in pairs( v1.configGroup or {} ) do
            for k3, v3 in pairs( v2.configOption or {} ) do
                v3.isDefualt = 0
            end
        end
    end
    for k1, v1 in pairs( gameData.gameConfig or {} ) do
        self.multiChoseOption[v1.configGroup[1].config] = {}
        for k2, v2 in pairs( v1.configGroup or {} ) do
            for k3, v3 in pairs( v2.configOption or {} ) do
                if data.gameConfig[v2.config]  and type(data.gameConfig[v2.config]) == "table" then
                    if v2.isCheckBox == 0 or v2.isCheckBox ==2 or v2.isCheckBox ==3 then
                        if tostring(v3.optionValue) == tostring(data.gameConfig[v2.config].optionValue) then
                            v3.isDefualt = 1
                        end
                    elseif v2.isCheckBox ==1 then
                        local tempValue = string.split(data.gameConfig[v2.config].optionValue,",")
                        for tempK, tempV in pairs( tempValue ) do
                            if tostring(v3.optionValue)  == tempV then
                                v3.isDefualt = 1
                            end
                        end
                    elseif v2.isCheckBox == 5 then
                        local tempValue = data.gameConfig[v2.config].optionValue --string.split(data.gameConfig[v2.config].optionValue,",")
                        v3.isDefualt = 1
                        v3.optionValue = tempValue
                    end
                end
            end
        end
    end
    gameData["baseChip"] = data.gameConfig.baseChip
    gameData["profitType"] = data.gameConfig.profitType
    gameData["rateOrConstant"] = data.gameConfig.rateOrConstant
    gameData["profit"] = data.gameConfig.profit
    gameData["profitLimit"] = data.gameConfig.profitLimit
    gameData["joinGamePoint"] = data.gameConfig.joinGamePoint
    gameData["readyPoint"] = data.gameConfig.readyPoint
    gameData["baseChip"] = data.gameConfig.baseChip
    gameData.secConstant = data.gameConfig.secConstant or ""
    if data.gameConfig.startCost and data.gameConfig.startCost > 0 then
        gameData.startCost = data.gameConfig.startCost
    end
    if data.gameConfig.additionalPoint and data.gameConfig.additionalPoint > 0 then
        gameData.additionalPoint = data.gameConfig.additionalPoint
    end
     if data.gameConfig.oneOrAll then
        gameData.oneOrAll = data.gameConfig.oneOrAll
    end
    
    return gameData
end

function FamilyCreateGame:setRoomDefaultPara(gameConfig)

    --print_lua_table(gameConfig)
    for k1, v1 in pairs( gameConfig.gameConfig or {} ) do
        self.multiChoseOption[v1.configGroup[1].config] = {}
        if v1.configGroup[2] then
            self.multiChoseOption[v1.configGroup[2].config] = {}
        end
        for k2, v2 in pairs( v1.configGroup or {} ) do
            for k3, v3 in pairs( v2.configOption or {} ) do
                if v3.isDefualt == 1 then
                    if v2.config == "round" then
                        self.parameter["cardCount"] = v3.cardCount
                    end
                    self:updateConfig(v2.config, v1.configShowName, v3, v3.isDefualt, v2.isCheckBox)
                end
            end
        end
    end
end

function FamilyCreateGame:isSelectInGroups(gameConfig, tags)
    for i,v in pairs(gameConfig or {}) do
        if v.configGroup and v.configGroup[1] and v.configGroup[1].configOption then
            for j, v2 in ipairs(v.configGroup[1].configOption) do
                if v2.selectShowTags and v2.unSelectShowTags then
                    local groupTags = v2.isDefualt == 1 and string.split(v2.unSelectShowTags, ",") or string.split(v2.selectShowTags, ",")
                    for _, tag in ipairs(groupTags or {}) do
                        if tonumber(tag) == tags then

                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

function FamilyCreateGame:loadRoomInfo(roomInfo)
    if roomInfo == nil then return end
    self._createRoomInfo = roomInfo
    dump(roomInfo.gameConfig, "loadRoomInfo == ")
    for k, v in pairs( roomInfo.gameConfig or {} ) do
        if v.groupTags then --有关联的组
            -- local hasOne = false
            -- local tags = string.split(v.groupTags, ",")
            -- for i,v2 in ipairs(tags or {}) do
            --     local tag = tonumber(v2)
            --     if self.listView:getChildByTag(tag) then
            --         hasOne = true
            --         break
            --     end
            -- end

            -- if not hasOne then
            --     self:addEachTypeToLst(v)
            -- end
            if self:isSelectInGroups(roomInfo.gameConfig, v.selfTags) then
                self:addEachTypeToLst(v)
            end
        else
            self:addEachTypeToLst(v)
        end
    end
    self:UpdateAA()
end

-- 添加每类的所有选项
function FamilyCreateGame:addEachTypeToLst(info)
    dump(info,"addEachTypeToLst info----------------->>")
    local groupLY = ccui.Layout:create()
    groupLY:setSwallowTouches(true)
    groupLY:setAnchorPoint(cc.p(0,0))
    groupLY:setTouchEnabled(false)

    if info.configGroup[1].parentConfig then
        local isVisible = false
        for k, v in pairs( self._createRoomInfo.gameConfig or {} ) do
            if v.configGroup[1].config == info.configGroup[1].parentConfig then
                local tags = string.split(info.configGroup[1].parentShowFlag, ",")
                for i,v2 in ipairs(tags or {}) do
                    for i3,v3 in ipairs(v.configGroup[1].configOption) do
                        if v3.isDefualt == 1 then
                            if v3.optionValue == tonumber(v2) then
                                isVisible = true
                                break
                            end 
                        end
                    end
                   
                end
            end
        end
        groupLY:setVisible(isVisible)
        groupLY:setName(info.configGroup[1].config)
    end

    local isHave,width,lines = self:addEachTypeContent(groupLY, info)

    if info.configGroup[2] then
        local tableGroup = {}
        tableGroup["configGroup"] = {}
        tableGroup["configGroup"][1] = info.configGroup[2]
        dump(tableGroup,"tableGroup")
        for k, v in pairs( tableGroup.configGroup[1].configOption or {} ) do
            if tableGroup.configGroup[1].isCheckBox == 0 or tableGroup.configGroup[1].isCheckBox == 1 then
                local des = v.optionName

                local checkBox = self:getCheckBox(tableGroup.configGroup[1].isCheckBox, des, (v.isDefualt or 0) > 0)

                checkBox:setName("checkBox"..tostring(k))
                checkBox:setPosition(self:getPositionByIndex(width+k,lines))
                checkBox.isToCheckShow = v.isToCheckShow
                checkBox.dataCheck =  tableGroup.configGroup[1]
                groupLY:addChild(checkBox)
                width = width + 1
                isHave = true
                self:toAddListenerCheckBox(groupLY, checkBox, tableGroup, tableGroup.configGroup[1].isCheckBox ~= 0)
                self:toUpdateCheckBox(groupLY)
            elseif tableGroup.configGroup[1].isCheckBox == 3 then
                self:updateConfig(tableGroup.configGroup[1].config, "", v, v.isDefualt, tableGroup.configGroup[1].isCheckBox)
            elseif tableGroup.configGroup[1].isCheckBox == 5 then
                local textField = self:getTextField(tableGroup)
                groupLY:addChild(textField)
            end

        end
    end

    if isHave then
        if info.selfTags then
            groupLY:setTag(info.selfTags)
        end
        self.listView:pushBackCustomItem(groupLY)
    end
end

function FamilyCreateGame:addEachTypeContent(groupLY, info)
    local lines = 1
    local effectSize = 0 --需要显示的个数
    -- dump(info.configGroup[1], "info.configGroup.configOption")
    if info == nil or info.configGroup == nil or info.configGroup[1].configOption == nil then
        return
    end

    for k, v in pairs( info.configGroup[1].configOption or {} ) do
        if v.delCell == nil then
            effectSize = effectSize + 1
        end
    end
    if info and info.configGroup and info.configGroup[1].configOption then
        local tempM = math.floor(effectSize/4) + 1
        local tempN = effectSize % 4
        if tempN == 0 then
            tempM = tempM -1
        end
        -- lines = math.ceil(#info.configGroup[1].configOption / 4)
        lines = tempM
        groupLY:setContentSize(cc.size(1160 , LINE_HEIGTH * lines))
    else
        return
    end
    local groupName = self:getGroupTTF(info.configShowName)
    if groupName then
        groupName:addTo(groupLY)
        groupName:setPositionY(LINE_HEIGTH*(lines-0.5))
    end

    local line = self:getLineSpr()
    if line then
        line:addTo(groupLY)
    end
    local isHave = false
    -- dump(info,"===info")
    local width = 0
    if lines == 1 and #info.configGroup[1].configOption == 2 then
    end
	 --dump(info, 'xmz   ======================= ')
    if info.configGroup[1] then
        local k = 0
        for _, v in pairs( info.configGroup[1].configOption or {} ) do
            if v.delCell then
                -- v.isDefualt = 0
                k = k + 1
            else
                k = k + 1
                if info.configGroup[1].isCheckBox == 0 or info.configGroup[1].isCheckBox == 1 then
                    local des = v.optionName
                    if info.configGroup[1].config == "round" then
                        des = string.format("%s(Fx%d)", des, v.cardCount)
                    end
                    width = width + 1
                    local checkBox = self:getCheckBox(info.configGroup[1].isCheckBox, des, (v.isDefualt or 0) > 0,info.configGroup[1].config)
                    if info.configGroup[1].config == "round" then
                        checkBox.toName = "round"
                        if (v.isDefualt or 0) > 0 then
                            checkBox.toSelect = true
                        end
                        checkBox.optionName = v.optionName
                        checkBox.optionValue =v.optionValue
                        checkBox.aaCardCount = v.aa_cardCount
                        checkBox.cardCount = v.cardCount
                    end
                    if info.configGroup[1].config ==  "pay_type" then
                        if (v.isDefualt or 0) > 0 then
                            checkBox.toSelect = true
                        end
                        checkBox.optionName = v.optionName
                        checkBox.toName = "pay_type"
                        checkBox.optionValue =v.optionValue
                    end
                    checkBox:setName("checkBox"..tostring(k))
                    if lines == 1 and #info.configGroup[1].configOption == 2 then
                        checkBox:setPosition(self:getPositionByIndex(width*2-1,lines))
                    else
                        checkBox:setPosition(self:getPositionByIndex(width,lines))
                    end
                    checkBox.isToCheck = v.isToCheck
                    groupLY:addChild(checkBox)
                    isHave = true
                    self:toAddListenerCheckBox(groupLY, checkBox, info, info.configGroup[1].isCheckBox ~= 0)
                elseif info.configGroup[1].isCheckBox == 3 then
                    self:updateConfig(info.configGroup[1].config, info.configShowName, v, v.isDefualt, info.configGroup[1].isCheckBox)
                elseif info.configGroup[1].isCheckBox == 5 then
                    width = width + 1
                    isHave = true
                    local textField = self:getTextField(info)
                    textField:setPosition(self:getPositionByIndex(width,lines))
                    groupLY:addChild(textField)
                end
            end
        end
    end

    return isHave,width,lines
end

function FamilyCreateGame:getGroupTTF(str)
    local label = cc.Label:createWithTTF(str or "", "hall/res/font/FZY3JW.TTF", 30)
    label:setAnchorPoint(cc.p(0, 0.5))
    label:setPosition(cc.p(20, LINE_HEIGTH/2))
    label:setColor(cc.c3b(103, 113, 150))
    return clone(label)
end

function FamilyCreateGame:getLineSpr()
    local sprite = cc.Sprite:create("hall/res/createRoom/image/huan_line.png")
    sprite:setPosition(1160/2, 3)
    return clone(sprite)
end

function FamilyCreateGame:getCheckBox(type, des, isSel,config)
    local checkNode = nil
    if type == 0 then
        checkNode = cc.CSLoader:createNode("hall/res/FriendScircle/setupchoose2.csb")
    elseif type == 1 then
        checkNode = cc.CSLoader:createNode("hall/res/FriendScircle/setupchoose.csb")
    end

    if checkNode then
        local content = checkNode:getChildByName("content")

        local checkBox = content:getChildByName("checkBox")
        checkBox:setSelectedState(isSel)

        local desTxt = content:getChildByName("desTxt")
        desTxt:setString(des)
        checkBox.select = isSel
        if isSel then
            desTxt:setTextColor(cc.c3b(71, 192, 125))
        end
        return clone(checkNode)
    end
end

function FamilyCreateGame:getTextField(tableGroup)
    print("tableGroup ---------- -------------- ", debug.traceback())
    dump(tableGroup, "tableGroup --------------------")
    local textFieldNode = cc.CSLoader:createNode("hall/res/FriendScircle/setupchoose5.csb")
    if textFieldNode then
        local content = textFieldNode:getChildByName("content")
        self:newEditBox(content, 5, tableGroup)

        return clone(textFieldNode)
    end
end

function FamilyCreateGame:newEditBox(node, maxLength, groupData)
    maxLength = maxLength or 10
    local params = {
        size = node:getContentSize(),
        -- fontSize = node:getFontSize(),
        fontSize = 1,
        fontColor = ccs.COLOR_WHITE,--node:getTextColor(),
        maxLength = maxLength,
        inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
        -- placeHolder = string,
    }
    local data = groupData.configGroup[1]
    local txt = node:getChildByName("txt")
    txt:setString(data.configOption[1].optionValue or "1")
    
    local editBox = ccs.newEditBox(params)
    node:getParent():addChild(editBox)
    editBox:setAnchorPoint(node:getAnchorPoint())
    editBox:setPosition(node:getPosition())
    local idx = editBox:getLocalZOrder()
    editBox:setLocalZOrder(-99)

    editBox:setText(data.configOption[1].optionValue or "1")
    editBox:registerScriptEditBoxHandler(function( strEventName,sender )
        if strEventName == "began" then--光标进入，选中全部内容
            sender:setText("")
        elseif strEventName == "ended" then--当编辑框失去焦点并且键盘消失的时候被调用
            local num = tonumber(sender:getText()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            sender:setText(num)
            txt:setString(num)
            data.configOption[1].optionValue = num
            dump(data, "data ==")
            self:updateConfig(data.config, groupData.configShowName, data.configOption[1], 1, data.isCheckBox)
        elseif strEventName == "return" then--当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
        elseif strEventName == "changed" then--输入内容改变时调用
            local num = tonumber(sender:getText()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            --sender:setText(num)
            txt:setString(num)
            
            -- self:updateConfig()
        end
    end)
end

function FamilyCreateGame:toAddListenerTextField(textFieldNode, groupData)
    local textField = textFieldNode:getChildByName("content"):getChildByName("textField")
    local data = groupData.configGroup[1]

    textField:addEventListenerCheckBox(function(sender,eventType)
        require("hall.GameCommon"):playEffectSound("hall/scene/res/common/music/Audio_Button_Click.mp3")

        -- local index = tonumber(string.sub(checkNode:getName(), 9, -1))
        if eventType == CHECKBOX_STATE_EVENT_SELECTED then
             dump(isMutex,"isMutex_CHECKBOX_STATE_EVENT_SELECTED")
             dump(groupData)
            if isMutex then
                local data = groupData.configGroup[1]
                dump(data,"isMutex_data")

                if data.checkbox then
                    self:reSetNewCheckByIndex(parant, groupData, index,sender)
                else
                    self:updateConfig(data.config, groupData.configShowName, data.configOption[index], 1, data.isCheckBox)
                    label:setTextColor(cc.c3b(71, 192, 125))
                    sender.select = true
                end
            else
                self:reSetDesTxtColorByIndex(parant, groupData, index)
            end
            self:toUpdateCheckBox(parant)
            local data = groupData.configGroup[1]

            if data and data.configOption[index].selectShowTags and data.configOption[index].unSelectShowTags then
                local seltags = string.split(data.configOption[index].selectShowTags, ",")
                local unSeltags = string.split(data.configOption[index].unSelectShowTags, ",")
                for i,v in ipairs(seltags or {}) do
                    local item = self:_getChildByTag(tonumber(v))
                    local info = self:getInfoByTag(tonumber(unSeltags[i]))
                    print("un select ------------------------------", item == nil)
                    -- dump(info)
                    if item and info then
                        print("un select ------------------------------", item:getTag())
                        item:removeAllChildren()
                        self:addEachTypeContent(item, info)
                        item:setTag(unSeltags[i])
                    end
                end
            end

            if data and data.configOption[index].selectDelOption then
                local groupAr = string.split(data.configOption[index].selectDelOption, ";")
                for _, group in ipairs(groupAr or {}) do
                    local seltags = string.split(group, ":") --：前的数字 表示删除那个tag，后面为这个tag 为index
                    if seltags[1] ==  nil or seltags[2] == nil then
                        return
                    end
                    local arTags = string.split(seltags[1], ",")
                    local opIdxs = string.split(seltags[2], ",")
                    for i,v in ipairs(arTags or {}) do
                        local item = self:_getChildByTag(tonumber(v))
                        -- if item then
                            local info = self:getInfoByTag(tonumber(v))

                            for j,v1 in ipairs(opIdxs or {}) do
                                info.configGroup[1].configOption[tonumber(v1) ].delCell = 1
                            end
                            dump(info, "get info by tag == ")
                            if info.configGroup[1].isCheckBox == 0 then -- 单选的才要这样处理
                                for idx, val in ipairs(info.configGroup[1].configOption) do
                                    if idx == 1 then
                                        info.configGroup[1].configOption[idx].isDefualt = 1
                                    else
                                        info.configGroup[1].configOption[idx].isDefualt = 0
                                    end
                                end
                            end
                        -- end
                        if item and info then
                            item:removeAllChildren()
                            self:addEachTypeContent(item, info)
                        end
                    end
                end
            end

        elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
            dump(isMutex,"isMutex_CHECKBOX_STATE_EVENT_UNSELECTED")
            if isMutex then

                local data = groupData.configGroup[1]
                if data.checkbox then
                    self:reSetNewCheckByIndex(parant, groupData, index,sender)
                else
                    self:updateConfig(data.config, groupData.configShowName, data.configOption[index], 2, data.isCheckBox)
                    label:setTextColor(cc.c3b(71, 192, 125))
                    sender.select = true
                end

            else
                sender.select = true;
                sender:setSelectedState(true)
            end
            local data = groupData.configGroup[1]
            if data and data.configOption[index].selectShowTags and data.configOption[index].unSelectShowTags then
                --print(" select 1------------------------------" )
                local seltags = string.split(data.configOption[index].selectShowTags, ",")
                local unSeltags = string.split(data.configOption[index].unSelectShowTags, ",")
                for i,v in ipairs(unSeltags or {}) do
                    --print(" select 2------------------------------", v)
                    local item = self:_getChildByTag(tonumber(v))
                    local info = self:getInfoByTag(tonumber(seltags[i]))
                    --print(" select ------------------------------", item == nil)
                    -- dump(info)
                    if item and info then
                        --print(" select ------------------------------", item:getTag())
                        item:removeAllChildren()
                        self:addEachTypeContent(item, info)
                        item:setTag(seltags[i])
                    end
                end
            end

            if data and data.configOption[index].selectDelOption then
                local groupAr = string.split(data.configOption[index].selectDelOption, ";")
                for _, group in ipairs(groupAr or {}) do
                    local seltags = string.split(group, ":") --：前的数字 表示删除那个tag，后面为这个tag 为index
                    if seltags[1] ==  nil or seltags[2] == nil then
                        return
                    end
                    local arTags = string.split(seltags[1], ",")
                    local opIdxs = string.split(seltags[2], ",")
                    for i,v in ipairs(arTags or {}) do
                        local item = self:_getChildByTag(tonumber(v))
                        -- if item then
                            local info = self:getInfoByTag(tonumber(v))
                            dump(info, "selectDelOption --------- == ")
                            for j,v1 in ipairs(opIdxs or {}) do
                                info.configGroup[1].configOption[tonumber(v1) ].delCell = nil
                                -- info.configGroup[1].configOption[tonumber(v1) ].isDefualt = 1
                                -- info.configGroup[1].configOption[tonumber(v1) ].isDefualt = info.configGroup[1].configOption[tonumber(v1) ].prveValue or 1
                            end
                            dump(info, "selectDelOption get info by tag == ")
                            if info.configGroup[1].isCheckBox == 0 then -- 单选的才要这样处理
                                for idx, val in ipairs(info.configGroup[1].configOption) do
                                    if idx == 1 then
                                        info.configGroup[1].configOption[idx].isDefualt = 1
                                    else
                                        info.configGroup[1].configOption[idx].isDefualt = 0
                                    end
                                end
                            end
                        -- end
                        if item and info then
                            print("selectDelOption ------------------------------", item:getTag())
                            item:removeAllChildren()
                            self:addEachTypeContent(item, info)
                            -- item:setTag(unSeltags[i])
                        end
                    end
                end
            end
        end
        --设置关联项可见与否
        if groupData.configGroup[1].childConfig then
            local tags = string.split(groupData.configGroup[1].childConfig, ",")
            for i,v in ipairs(self._createRoomInfo.gameConfig or {}) do
                for i1,v1 in ipairs(tags) do
                    if v.configGroup[1].config == v1 then
                        if v.configGroup[1].parentShowFlag then
                            local isVisible = false
                            local tags2 = string.split(v.configGroup[1].parentShowFlag, ",")
                            for i2,v3 in ipairs(tags2) do
                                if self.parameter[groupData.configGroup[1].config].optionValue == tonumber(v3) then
                                    isVisible = true
                                    break
                                end
                            end
                            self:_getChildByName(v1):setVisible(isVisible)
                        end
                    end
                end
            end
        end
    end)

end

function FamilyCreateGame:getPositionByIndex(index,allLines)
    -- local line = math.floor(index/3)
    -- local mod = math.mod(index, 3)
    -- local beginPosX = 150
    -- if mod == 0 then
    --     return cc.p(2*260 + beginPosX, LINE_HEIGTH*(line))
    -- else
    --     return cc.p((mod-1)*260 + beginPosX, LINE_HEIGTH*(line+1))
    -- end

    --changed by zzy
    local number = 4
    local line = math.floor(index/number)
    local _index = index%number
    if _index == 0 then
        _index = number
        line = line - 1
    end
    local beginPosX = 200
    --print("===line==_index==",line,_index)

    return cc.p((_index-1)*230+beginPosX,LINE_HEIGTH*(allLines-line))
end
function FamilyCreateGame:toUpdateCheckBox(parant)
    local children = parant:getChildren()
    local isShow = true
    for k,v in pairs(children) do
        if v:getChildByName("content") then
            local checkBox = v:getChildByName("content"):getChildByName("checkBox")
            local sel = checkBox.select
            if  v.isToCheck  and v.isToCheck == 1 and sel == true then
                isShow = false
            end
        end

    end
    if isShow == false then
        for k,v in pairs(children) do
            if v:getChildByName("content") then
                local checkBox = v:getChildByName("content"):getChildByName("checkBox")
                if  v.isToCheckShow  and v.isToCheckShow == 1  then
                    v:setVisible(true)
                    if v.dataCheck.isDefualt then
                        checkBox:setSelectedState(true)
                        checkBox.select = true
                        self:updateConfig(v.dataCheck.config, "", v.dataCheck["configOption"][1], 1, v.dataCheck.isCheckBox)
                    end
                end
            end

        end
    else
        for k,v in pairs(children) do
            if v:getChildByName("content") then
                local checkBox = v:getChildByName("content"):getChildByName("checkBox")
                if  v.isToCheckShow  and v.isToCheckShow == 1  then
                    checkBox:setSelectedState(false)
                    checkBox.select = false
                    v:setVisible(false)
                    self:updateConfig(v.dataCheck.config, "", v.dataCheck["configOption"][1], 0, v.dataCheck.isCheckBox)
                end
            end
        end
    end
end
--选局数 判断是否是aa
function FamilyCreateGame:UpdateAA()
    local flag = false
    if self.listView then
        local items = self.listView:getItems()
        for i,v in ipairs(items or {}) do
            for k2,v2 in ipairs(v:getChildren() or {}) do
                if v2.toName == "pay_type" then
                    --dump(v2.optionValue,"gwegjtyjrtjtrj")
                    if v2.optionValue == "AA" then
                        local content = v2:getChildByName("content")
                        local checkBox = content:getChildByName("checkBox")
                        if checkBox.select == true then
                            flag =true
                        end
                    end
                end
            end
        end

        for i,v in ipairs(items or {}) do
            for k2,v2 in ipairs(v:getChildren() or {}) do
                if v2.toName == "round" then
                    local content = v2:getChildByName("content")
                    local checkBox = content:getChildByName("checkBox")
                    if flag == true then
                        local des = v2.optionName
                        local content = v2:getChildByName("content")
                        local desTxt = content:getChildByName("desTxt")
                        desTxt:setString(des)
                        --dump(v2.aaCardCount ,"gewg===============-------")
                        des = string.format("%s(Fx%d)", des, v2.aaCardCount)
                        --self.parameter["cardCount"] = v2.aaCardCount
                        local desTxt = content:getChildByName("desTxt")
                        desTxt:setString(des)
                        if checkBox.select == true then
                            self.parameter["cardCount"] = v2.aaCardCount
                        end

                    else
                        local des = v2.optionName
                        local content = v2:getChildByName("content")
                        local desTxt = content:getChildByName("desTxt")
                        desTxt:setString(des)
                        des = string.format("%s(Fx%d)", des, v2.cardCount)
                        local desTxt = content:getChildByName("desTxt")
                        desTxt:setString(des)
                        if checkBox.select == true then
                            self.parameter["cardCount"] = v2.cardCount
                        end

                    end
                end
            end

        end
    end
end
--选aa或者房卡 改变局数 扣卡
function FamilyCreateGame:UpdateFk(data)

    if self.listView then
        local items = self.listView:getItems()
        for i,v in ipairs(items or {}) do
            for k2,v2 in ipairs(v:getChildren() or {}) do
                if v2.toName == "round" then
                    if data == "fangka" then
                        dump(v2.cardCount,"fankafankafankafanka")
                        local des = v2.optionName
                        local content = v2:getChildByName("content")
                        local desTxt = content:getChildByName("desTxt")
                        desTxt:setString(des)
                        des = string.format("%s(Fx%d)", des, v2.cardCount)
                        local desTxt = content:getChildByName("desTxt")
                        desTxt:setString(des)
                        local checkBox = content:getChildByName("checkBox")
                        if checkBox.select == true then
                            self.parameter["cardCount"] = v2.cardCount
                        end
                        dump(checkBox.select,"checkBox.select===")
                    elseif data == "AA" then
                        local des = v2.optionName
                        local content = v2:getChildByName("content")
                        local desTxt = content:getChildByName("desTxt")
                        desTxt:setString(des)
                        des = string.format("%s(Fx%d)", des, v2.aaCardCount)
                        --self.parameter["cardCount"] = v2.aaCardCount
                        local desTxt = content:getChildByName("desTxt")
                        desTxt:setString(des)
                        local checkBox = content:getChildByName("checkBox")
                        dump(checkBox.select,"checkBox.select===")
                        if checkBox.select == true then
                            self.parameter["cardCount"] = v2.aaCardCount
                        end
                    end
                    --dump(v2.toName, "v.toName---09--")
                end

            end
        end
    end
end

function FamilyCreateGame:getInfoByTag(tag)
    for k, v in pairs(self._createRoomInfo.gameConfig or {}) do
        if v.selfTags and v.selfTags == tag then
            return v
        end
    end
    return nil
end

function FamilyCreateGame:_getChildByTag(tag)
    local items = self.listView:getItems()
    for i,v in ipairs(items or {}) do
        print("tag -----------------------", i, v:getTag(), tag)
        if v:getTag() == tag then
            return v
        end
    end

    return nil
end

function FamilyCreateGame:_getChildByName(name)
    local items = self.listView:getItems()
    for i,v in ipairs(items or {}) do
        if v:getName() == name then
            return v
        end
    end

    return nil
end

function FamilyCreateGame:initForSelectDel(data, index)
    if data and data.configOption[index].selectDelOption then
        local groupAr = string.split(data.configOption[index].selectDelOption, ";")
        for _, group in ipairs(groupAr or {}) do
            local seltags = string.split(group, ":") --：前的数字 表示删除那个tag，后面为这个tag 为index
            if seltags[1] ==  nil or seltags[2] == nil then
                return
            end
            local arTags = string.split(seltags[1], ",")
            local opIdxs = string.split(seltags[2], ",")
            for i,v in ipairs(arTags or {}) do
                local item = self:_getChildByTag(tonumber(v))
                -- if item then
                    local info = self:getInfoByTag(tonumber(v))
                    if info == nil then
                        break
                    end
                    dump(info, "get info by tag == ")
                    for j,v1 in ipairs(opIdxs or {}) do
                        print("asdfasf -------------", tonumber(v1))
                        info.configGroup[1].configOption[tonumber(v1) ].delCell = 1
                        -- info.configGroup[1].configOption[tonumber(v1) ].prveValue = info.configGroup[1].configOption[tonumber(v1) ].isDefualt
                        info.configGroup[1].configOption[tonumber(v1) ].isDefualt = 0
                    end
                    
                    if info.configGroup[1].isCheckBox == 0 then -- 单选的才要这样处理
                        for idx, val in ipairs(info.configGroup[1].configOption) do
                            if idx == 1 then
                                info.configGroup[1].configOption[idx].isDefualt = 1
                            else
                                info.configGroup[1].configOption[idx].isDefualt = 0
                            end
                        end
                    end
                -- end
                if item and info then
                    print("un select ------------------------------", item:getTag())
                    item:removeAllChildren()
                    self:addEachTypeContent(item, info)
                    -- item:setTag(unSeltags[i])
                end
            end
        end
    end
end

function FamilyCreateGame:toAddListenerCheckBox(parant, checkNode, groupData, isMutex)

    local checkBox = checkNode:getChildByName("content"):getChildByName("checkBox")
    local label    = checkNode:getChildByName("content"):getChildByName("desTxt")
    local data = groupData.configGroup[1]
    local index = tonumber(string.sub(checkNode:getName(), 9, -1))

    if data and data.configOption[index].selectDelOption and checkBox.select then
        self:initForSelectDel(data, index)
    end
    -- dump(data, "toAddListenerCheckBox == s")
    checkBox:addEventListenerCheckBox(function(sender,eventType)
        require("hall.GameCommon"):playEffectSound("hall/scene/res/common/music/Audio_Button_Click.mp3")
        -- local index = tonumber(string.sub(checkNode:getName(), 9, -1))
        if eventType == CHECKBOX_STATE_EVENT_SELECTED then
             dump(isMutex,"isMutex_CHECKBOX_STATE_EVENT_SELECTED")
			 dump(groupData)
            if isMutex then
                local data = groupData.configGroup[1]
                dump(data,"isMutex_data")

                if data.checkbox then
                    self:reSetNewCheckByIndex(parant, groupData, index,sender)
                else
                    self:updateConfig(data.config, groupData.configShowName, data.configOption[index], 1, data.isCheckBox)
                    label:setTextColor(cc.c3b(71, 192, 125))
                    sender.select = true
                end
            else
                self:reSetDesTxtColorByIndex(parant, groupData, index)
            end
            self:toUpdateCheckBox(parant)
            local data = groupData.configGroup[1]

            if data and data.configOption[index].selectShowTags and data.configOption[index].unSelectShowTags then
                local seltags = string.split(data.configOption[index].selectShowTags, ",")
                local unSeltags = string.split(data.configOption[index].unSelectShowTags, ",")
                for i,v in ipairs(seltags or {}) do
                    local item = self:_getChildByTag(tonumber(v))
                    local info = self:getInfoByTag(tonumber(unSeltags[i]))
                    print("un select ------------------------------", item == nil)
                    -- dump(info)
                    if item and info then
                        print("un select ------------------------------", item:getTag())
                        item:removeAllChildren()
                        self:addEachTypeContent(item, info)
                        item:setTag(unSeltags[i])
                    end
                end
            end

            if data and data.configOption[index].selectDelOption then
                local groupAr = string.split(data.configOption[index].selectDelOption, ";")
                for _, group in ipairs(groupAr or {}) do
                    local seltags = string.split(group, ":") --：前的数字 表示删除那个tag，后面为这个tag 为index
                    if seltags[1] ==  nil or seltags[2] == nil then
                        return
                    end
                    local arTags = string.split(seltags[1], ",")
                    local opIdxs = string.split(seltags[2], ",")
                    for i,v in ipairs(arTags or {}) do
                        local item = self:_getChildByTag(tonumber(v))
                        -- if item then
                            local info = self:getInfoByTag(tonumber(v))

                            for j,v1 in ipairs(opIdxs or {}) do
                                info.configGroup[1].configOption[tonumber(v1) ].delCell = 1
                                -- info.configGroup[1].configOption[tonumber(v1) ].prveValue = info.configGroup[1].configOption[tonumber(v1) ].isDefualt
                                -- info.configGroup[1].configOption[tonumber(v1) ].isDefualt = 0
                            end
                            dump(info, "get info by tag == ")
                            if info.configGroup[1].isCheckBox == 0 then -- 单选的才要这样处理
                                for idx, val in ipairs(info.configGroup[1].configOption) do
                                    if idx == 1 then
                                        info.configGroup[1].configOption[idx].isDefualt = 1
                                    else
                                        info.configGroup[1].configOption[idx].isDefualt = 0
                                    end
                                end
                            end
                        -- end
                        if item and info then
                            print("un select ------------------------------", item:getTag())
                            item:removeAllChildren()
                            self:addEachTypeContent(item, info)
                            -- item:setTag(unSeltags[i])
                        end
                    end
                end
                -- local seltags = string.split(data.configOption[index].selectDelOption, ":") --：前的数字 表示删除那个tag，后面为这个tag 为index
                -- if seltags[1] ==  nil or seltags[2] == nil then
                --     return
                -- end
                -- local arTags = string.split(seltags[1], ",")
                -- local opIdxs = string.split(seltags[2], ",")
                -- for i,v in ipairs(arTags or {}) do
                --     local item = self:_getChildByTag(tonumber(v))
                --     -- if item then
                --         local info = self:getInfoByTag(tonumber(v))

                --         for j,v1 in ipairs(opIdxs or {}) do
                --             info.configGroup[1].configOption[tonumber(v1) ].delCell = 1
                --             -- info.configGroup[1].configOption[tonumber(v1) ].prveValue = info.configGroup[1].configOption[tonumber(v1) ].isDefualt
                --             info.configGroup[1].configOption[tonumber(v1) ].isDefualt = 0
                --         end
                --         dump(info, "get info by tag == ")
                --     -- end
                --     if item and info then
                --         print("un select ------------------------------", item:getTag())
                --         item:removeAllChildren()
                --         self:addEachTypeContent(item, info)
                --         -- item:setTag(unSeltags[i])
                --     end
                -- end
            end

        elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
            dump(isMutex,"isMutex_CHECKBOX_STATE_EVENT_UNSELECTED")
            if isMutex then

                local data = groupData.configGroup[1]
                if data.checkbox then
                    self:reSetNewCheckByIndex(parant, groupData, index,sender)
                else
                    self:updateConfig(data.config, groupData.configShowName, data.configOption[index], 2, data.isCheckBox)
                    label:setTextColor(cc.c3b(71, 192, 125))
                    sender.select = true
                end

            else
                sender.select = true;
                sender:setSelectedState(true)
            end
            local data = groupData.configGroup[1]
            if data and data.configOption[index].selectShowTags and data.configOption[index].unSelectShowTags then
                --print(" select 1------------------------------" )
                local seltags = string.split(data.configOption[index].selectShowTags, ",")
                local unSeltags = string.split(data.configOption[index].unSelectShowTags, ",")
                for i,v in ipairs(unSeltags or {}) do
                    --print(" select 2------------------------------", v)
                    local item = self:_getChildByTag(tonumber(v))
                    local info = self:getInfoByTag(tonumber(seltags[i]))
                    --print(" select ------------------------------", item == nil)
                    -- dump(info)
                    if item and info then
                        --print(" select ------------------------------", item:getTag())
                        item:removeAllChildren()
                        self:addEachTypeContent(item, info)
                        item:setTag(seltags[i])
                    end
                end
            end

            if data and data.configOption[index].selectDelOption then
                local groupAr = string.split(data.configOption[index].selectDelOption, ";")
                for _, group in ipairs(groupAr or {}) do
                    local seltags = string.split(group, ":") --：前的数字 表示删除那个tag，后面为这个tag 为index
                    if seltags[1] ==  nil or seltags[2] == nil then
                        return
                    end
                    local arTags = string.split(seltags[1], ",")
                    local opIdxs = string.split(seltags[2], ",")
                    for i,v in ipairs(arTags or {}) do
                        local item = self:_getChildByTag(tonumber(v))
                        -- if item then
                            local info = self:getInfoByTag(tonumber(v))
                            dump(info, "selectDelOption --------- == ")
                            for j,v1 in ipairs(opIdxs or {}) do
                                info.configGroup[1].configOption[tonumber(v1) ].delCell = nil
                                -- info.configGroup[1].configOption[tonumber(v1) ].isDefualt = 1
                                -- info.configGroup[1].configOption[tonumber(v1) ].isDefualt = info.configGroup[1].configOption[tonumber(v1) ].prveValue or 1
                            end
                            dump(info, "selectDelOption get info by tag == ")
                            if info.configGroup[1].isCheckBox == 0 then -- 单选的才要这样处理
                                for idx, val in ipairs(info.configGroup[1].configOption) do
                                    if idx == 1 then
                                        info.configGroup[1].configOption[idx].isDefualt = 1
                                    else
                                        info.configGroup[1].configOption[idx].isDefualt = 0
                                    end
                                end
                            end
                        -- end
                        if item and info then
                            print("selectDelOption ------------------------------", item:getTag())
                            item:removeAllChildren()
                            self:addEachTypeContent(item, info)
                            -- item:setTag(unSeltags[i])
                        end
                    end
                end
            end
        end
        --设置关联项可见与否
        if groupData.configGroup[1].childConfig then
            local tags = string.split(groupData.configGroup[1].childConfig, ",")
            for i,v in ipairs(self._createRoomInfo.gameConfig or {}) do
                for i1,v1 in ipairs(tags) do
                    if v.configGroup[1].config == v1 then
                        if v.configGroup[1].parentShowFlag then
                            local isVisible = false
                            local tags2 = string.split(v.configGroup[1].parentShowFlag, ",")
                            for i2,v3 in ipairs(tags2) do
                                if self.parameter[groupData.configGroup[1].config].optionValue == tonumber(v3) then
                                    isVisible = true
                                    break
                                end
                            end
                            self:_getChildByName(v1):setVisible(isVisible)
                        end
                    end
                end
            end
        end
    end)

    local btnCallBack = function ( sender, event )
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound(BTN_CLICK_VOICE)
        elseif event == TOUCH_EVENT_ENDED then
            local sel = checkBox:getSelectedState()
            if not sel and isMutex then
                local index = tonumber(string.sub(checkNode:getName(), 9, -1))
                self:reSetDesTxtColorByIndex(parant, groupData, index)
            end
        end
    end
    -- label:setTouchEnabled(true)
    -- label:addTouchEventListener(btnCallBack)

end
function FamilyCreateGame:reSetNewCheckByIndex(parant,data,index,sender)
    local currentData = data.configGroup[1].configOption[index]
    local test =1
    for k,v in ipairs(data.configGroup[1].configOption)do
        if v.check ==0 then
            test = 0
        end
    end
    local value = currentData.check;
    dump(value,"valuejjjjj")
    local checkBoxNo = parant:getChildByName("checkBox"..tonumber(1)):getChildByName("content"):getChildByName("checkBox")
    if value == 0 then
        if not sender.select then
            local tempValue = -1;
            for k,v in ipairs(data.configGroup[1].configOption)do
                local checkBox = parant:getChildByName("checkBox"..tonumber(k)):getChildByName("content"):getChildByName("checkBox")
                local label = parant:getChildByName("checkBox"..tonumber(k)):getChildByName("content"):getChildByName("desTxt")
                if v.check ~= tempValue then
                    tempValue = v.check
                    checkBox:setSelectedState(true)
                    checkBox.select = true;
                    self:updateConfig(data.configGroup[1].config, data.configShowName, data.configGroup[1].configOption[k], data.configGroup[1].configOption[k].isDefualt, data.configGroup[1].isCheckBox)
                    label:setTextColor(cc.c3b(71, 192, 125))
                end
            end
        else
            for k,v in ipairs(data.configGroup[1].configOption)do
                local checkBox = parant:getChildByName("checkBox"..tonumber(k)):getChildByName("content"):getChildByName("checkBox")
                local label = parant:getChildByName("checkBox"..tonumber(k)):getChildByName("content"):getChildByName("desTxt")
                checkBox:setSelectedState(false)
                checkBox.select = false;
                label:setTextColor(cc.c3b(103, 113, 150))
            end
        end
    else
        if checkBoxNo.select == false and test == 0 then
            sender.select = false
            sender:setSelectedState(false)
            return
        end
        if not sender.select then
            sender.select = true
            sender:setSelectedState(true)
            dump(data.configGroup[1].configOption[index],"data.configGroup[1].configOption[index].isDefualt")

            self:updateConfig(data.configGroup[1].config, data.configShowName, data.configGroup[1].configOption[index], 1, data.configGroup[1].isCheckBox)
            for k,v in ipairs(data.configGroup[1].configOption)do
                local checkBox = parant:getChildByName("checkBox"..tonumber(k)):getChildByName("content"):getChildByName("checkBox")
                local label = parant:getChildByName("checkBox"..tonumber(k)):getChildByName("content"):getChildByName("desTxt")
                if v.check == value and k ~= index then
                    checkBox:setSelectedState(false)
                    checkBox.select = false;
                    self:updateConfig(data.configGroup[1].config, data.configShowName, data.configGroup[1].configOption[k], 0, data.configGroup[1].isCheckBox)
                    label:setTextColor(cc.c3b(103, 113, 150))
                else
                    if checkBox.select then
                        checkBox:setSelectedState(true)
                        checkBox.select = true;
                        self:updateConfig(data.configGroup[1].config, data.configShowName, data.configGroup[1].configOption[k], 1, data.configGroup[1].isCheckBox)
                        label:setTextColor(cc.c3b(71, 192, 125))
                    end
                end
            end
        else
            sender.select = true
            sender:setSelectedState(true)
            self:updateConfig(data.configGroup[1].config, data.configShowName, data.configGroup[1].configOption[index], data.configGroup[1].configOption[index].isDefualt, data.configGroup[1].isCheckBox)
        end
    end


end
function FamilyCreateGame:reSetDesTxtColorByIndex(parant, data, index)
    dump(data,"gwegggggggggg---")
    --for k,v in ipairs(data.configGroup)do
    --    for k1,v1 in pairs(v["configOption"]) do
    --        local checkBox = parant:getChildByName("checkBox"..tonumber(v["isCheckBox"])):getChildByName("content"):getChildByName("checkBox")
    --        local label = parant:getChildByName("checkBox"..tonumber(v["isCheckBox"])):getChildByName("content"):getChildByName("desTxt")
    --        dump(k1," tonumber(k1)")
    --        if tonumber(k1) == index then
    --            checkBox:setSelected(true)
    --            label:setTextColor(cc.c3b(71, 192, 125))
    --            if v["config"] == "round" then
    --                self.parameter["cardCount"] = v["config"].configOption[index].cardCount
    --            end
    --            self:updateConfig(v["config"], data.configShowName, v1, v1.isDefualt, v.isCheckBox)
    --        else
    --            checkBox:setSelected(false)
    --            label:setTextColor(cc.c3b(103, 113, 150))
    --        end
    --    end
    --
    --
    --end

    for i, v in ipairs(data.configGroup[1].configOption) do
        if v.delCell == nil then
            local checkBox = parant:getChildByName("checkBox"..tonumber(i)):getChildByName("content"):getChildByName("checkBox")
            local label = parant:getChildByName("checkBox"..tonumber(i)):getChildByName("content"):getChildByName("desTxt")
            if i == index then
                checkBox:setSelectedState(true)
                checkBox.select = true;
                if checkBox.toName == "round" then
                    checkBox.optionValue = v.optionName
                    checkBox.toSelect = true
                    checkBox.aaCardCount = v.aa_cardCount
                    checkBox.cardCount = v.cardCount
                end
                label:setTextColor(cc.c3b(71, 192, 125))

                if data.configGroup[1].config == "round" then
                    self.parameter["cardCount"] = data.configGroup[1].configOption[index].cardCount
                    self:UpdateAA()
                end
                dump(v,"ggewahg==========")
                if data.configGroup[1] and data.configGroup[1]["config"] == "pay_type" then
                    if v.optionValue == "fangka" then
                        self:UpdateFk("fangka")
                    else
                        self:UpdateFk("AA")
                    end
                end
                self:updateConfig(data.configGroup[1].config, data.configShowName, data.configGroup[1].configOption[index], data.configGroup[1].configOption[index].isDefualt, data.configGroup[1].isCheckBox)
            else
                if checkBox.toName == "round" then
                    checkBox.optionName = v.optionName
                    checkBox.optionValue = v.optionValue
                    checkBox.toSelect = false
                    checkBox.aaCardCount = v.aa_cardCount
                    checkBox.cardCount = v.cardCount
                end
                if checkBox.toName == "pay_type" then
                    checkBox.optionName = v.optionName
                    checkBox.optionValue = v.optionValue
                    checkBox.toSelect = false
                end
                checkBox.select = false;
                checkBox:setSelectedState(false)
                label:setTextColor(cc.c3b(103, 113, 150))
            end
        end
    end
    dump(self.parameter["cardCount"],"self.parameter[cardCount]")
    -- for i = 1, #data.configGroup[1].configOption do
    --     local checkBox = parant:getChildByName("checkBox"..tonumber(i)):getChildByName("content"):getChildByName("checkBox")
    --     local label = parant:getChildByName("checkBox"..tonumber(i)):getChildByName("content"):getChildByName("desTxt")
    --     if i == index then
    --         checkBox:setSelectedState(true)
    --         checkBox.select = true;
    --         label:setTextColor(cc.c3b(71, 192, 125))
    --         if data.configGroup[1].config == "round" then
    --             self.parameter["cardCount"] = data.configGroup[1].configOption[index].cardCount
    --         end
    --         self:updateConfig(data.configGroup[1].config, data.configShowName, data.configGroup[1].configOption[index], data.configGroup[1].configOption[index].isDefualt, data.configGroup[1].isCheckBox)
    --     else
    --         checkBox.select = false;
    --         checkBox:setSelectedState(false)
    --         label:setTextColor(cc.c3b(103, 113, 150))
    --     end
    -- end

end

function FamilyCreateGame:changeGroupParameter(delName, addName)
    -- body
end

function FamilyCreateGame:changeSingleParameter(name, idx, addOrDel)-- true 表示添加，false 表示删除
    for k, v in pairs(self.parameter or {}) do
        if k == name then
            if addOrDel then
                v.optionValue = v.optionValue..","..idx
            else
                local optionValueAr = string.split(v.optionValue, ",")
                local newOptionValue = {}
                for i, v1 in ipairs(optionValueAr or {}) do
                    if tonumber(v1) ~= tonumber(idx) then
                        table.insert(newOptionValue, tonumber(v1))
                    end
                end
                v.optionValue = table.concat(newOptionValue, ",")
            end
            break
        end
    end
end

function FamilyCreateGame:updateConfig(config , configName , option , updateType , checkBoxType)

    local optionName = option["optionName"]
    local optionValue = option["optionValue"]
    local isShow = option["isShow"]
    local newRelateConfigArr = option["newRelateConfigArr"]

    if checkBoxType == 1 or checkBoxType == 4 then

        local select = {}
        select["optionName"] = ""
        select["optionValue"] = ""
        -- dump(config,"config")
        -- dump(optionName,"optionName")
        -- dump(optionValue,"optionValue")
        -- dump(updateType,"updateType")
        if  updateType ==  1 then  --添加
            self.multiChoseOption[config][optionName] = {}
            self.multiChoseOption[config][optionName]["value"] = optionValue
            self.multiChoseOption[config][optionName]["updateType"] = 1
        else
            self.multiChoseOption[config][optionName] = {}
            self.multiChoseOption[config][optionName]["value"] = optionValue
            self.multiChoseOption[config][optionName]["updateType"] = 2
        end

        for optionName , optionTable in pairs(self.multiChoseOption[config]) do
            if optionTable["updateType"] == 1 then
                select["optionName"] = select["optionName"] .. optionName .. " "
                select["optionValue"] = select["optionValue"] .. optionTable["value"] .. ","
            end
        end

        --添加默认项
        select["optionName"] = string.sub(select["optionName"], 1, string.len(select["optionName"]) - 1)
        select["optionValue"] = string.sub(select["optionValue"], 1, string.len(select["optionValue"]) - 1)
        select["isShow"] = isShow
        select["configName"] = configName
        select["isCheckBox"] = checkBoxType
        self.parameter[config] = select
        dump(self.parameter, "self.parameter == ")
    elseif checkBoxType == 0 or checkBoxType == 3 or checkBoxType == 5 then

        local select = {}
        select["optionName"] = optionName
        select["optionValue"] = optionValue
        select["isShow"] = isShow
        select["configName"] = configName
        select["isCheckBox"] = checkBoxType
        self.parameter[config] = select

    elseif checkBoxType == 2 then

        local select = {}
        select["optionName"] = optionName
        select["optionValue"] = optionValue
        select["isShow"] = isShow
        select["configName"] = configName
        select["isCheckBox"] = checkBoxType
        --配置项为底分时，把选项值放到
        if  config == "baseChip" then
            self.parameter["baseChip"] = tonumber(optionValue)
        else
            self.parameter[config] = select
        end
    else
        local select = {}
        select["optionName"] = optionName
        select["optionValue"] = optionValue
        select["isShow"] = false
        select["configName"] = configName
        select["isCheckBox"] = checkBoxType
        self.parameter[config] = select
    end
end

function FamilyCreateGame:onClickBtnCreate( sender, event )
    if self.parameter == nil then
        return
    end
    self.parameter.name = self.parameter["gameName"]..self.length
    -- FamilyData:SetPlayerTakeData(self.parameter , self.parents.family_id ,self.type,self.index ,self.gameType,self.length, handler(self , self.RemoveCreateGame))
    self.btnCreate:setEnabled(false)

    -- if GetGameName:isBidTable( self.parameter.level ) then
    --     local data = {
    --         clubId = self.parents.family_id or 1,
    --         level =  self.parameter["level"],
    --     }
    --     ReqMgr:request(EVENTNAME.A2I_CREATE_FREE_GAME, data, handler(self, self.ADD_GAME_CONFIG),{level = data.level})
    -- else
        local data = {
            groupId = self.parents.family_id or 1,
            playerId = USER_INFO["uid"] or 1,
            level =  self.parameter["level"],
            name = self.parameter["name"],
            config = json.encode(self.parameter) or "",
        }
        ReqMgr:request(EVENTNAME.ADD_GAME_CONFIG, data, handler(self, self.ADD_GAME_CONFIG))
    -- end
end

function FamilyCreateGame:ADD_GAME_CONFIG(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if returnCode == 0 then
        dump(data,"创建房间成功!")
        if GetGameName:isBidTable( param.level ) then
            viewMgr:showTip({text = "创建房间成功!"})
        else
            viewMgr:showTip({text = "创建玩法成功!"})
        end
        -- 创建成功后刷新父页面数据
        if self.parents then
            -- 先保存要使用的数据
            local parents = self.parents
            local keepLevel = parents.curLevel  -- 直接使用 parents 当前选中的 level
            print("=== 新增玩法，keepLevel =", keepLevel, "parents.curLevel =", parents.curLevel)
            
            -- 关闭当前页面
            self:removeSelf()
            
            -- 使用修改后的 select_game_config 函数，传入 keepLevel
            local datav = {groupId = parents.family_id, playerId = USER_INFO["uid"]}
            ReqMgr:request(EVENTNAME.GOTO_CLUB, datav, function(event2)
                parents:select_game_config(event2, keepLevel)
            end, nil, nil, false)
            return
        end
    else
        viewMgr:showTip({text = error})
    end
    self:removeSelf()
end

function FamilyCreateGame:onClickBtnChange( sender, event )
    FamilyData:updateGameConfig(self.parameter , self.parents.family_id, self.configId,handler(self , self.RemoveCreateGame))
    self.btnChange:setEnabled(false)
end

function FamilyCreateGame:onClickBtnDelConfig() --删除玩法
    FamilyData:delGameConfig(self.parents.family_id, self.configId,handler(self , self.RemoveCreateGame))
end

function FamilyCreateGame:RemoveCreateGame(type,data)
    -- 先检查是否页面还存在
    if tolua.isnull(self) then
        return
    end
    
    if  tolua.isnull(self.parents) or  tolua.isnull(self.parents.parents) then
        return
    end
    
    -- 先保存好需要的引用
    local parents = self.parents
    local keepLevel = parents.curLevel  -- 直接使用 parents 当前选中的 level，更可靠
    print("=== RemoveCreateGame, type =", type, "keepLevel =", keepLevel, "parents.curLevel =", parents.curLevel)
    
    if type == "del" then
        -- self.parents:delConfigData(tostring(self.gameType),tostring(self.configId))
        if self.parameter then
            local SelectLevelAndConfigID = cc.UserDefault:getInstance():getStringForKey("SelectLevelAndConfigID", 1)
            SelectLevelAndConfigID = string.split(SelectLevelAndConfigID, ":")
            local selectLevel = tonumber(SelectLevelAndConfigID[1])
            local selectId = tonumber(SelectLevelAndConfigID[2])
            if selectLevel == self.parameter.level and self.configId == selectId then
                cc.UserDefault:getInstance():deleteValueForKey("SelectLevelAndConfigID")
                cc.UserDefault:getInstance():deleteValueForKey("SpeedjoinViewWanFaName")
                parents:initSpeedjoinTxt()
            end
        end
        -- 删除成功后刷新父页面数据
        self:removeSelf()
        local datav = {groupId = parents.family_id, playerId = USER_INFO["uid"]}
        ReqMgr:request(EVENTNAME.GOTO_CLUB, datav, function(event2)
            parents:select_game_config(event2, keepLevel)
        end, nil, nil, false)
        return
    elseif type =="create" then
        if self.parameter then
            local flood = {}
            flood.gameConfig = self.parameter
            flood.gameConfig.id = data.configId
            flood.gameConfig.tempGameType = data.gameType
            flood.gameType = data.gameType
            flood.gameLevel = self.parameter.level
            flood.level = self.parameter.level
            flood.gameName = self.parameter.name
            flood.name = self.parameter.name
            flood.id = data.configId
            -- self.parents:addConfigData(flood)
        end
    elseif type =="update" then
        if self.parameter then
            local flood = {}
            flood.gameConfig = self.parameter
            flood.gameConfig.tempGameType = self.gameType
            flood.gameType = self.gameType
            flood.gameLevel = self.parameter.level
            flood.gameName = self.data.name
            flood.name =  self.data.name
            flood.level = self.parameter.level
            flood.id = self.configId
            flood.gameConfig.name = self.data.name
            flood.gameConfig.id = self.configId
            parents:delConfigData(self.gameType,self.configId)
            parents:addConfigData(flood)
        end
        -- 更新成功后刷新父页面数据
        self:removeSelf()
        local datav = {groupId = parents.family_id, playerId = USER_INFO["uid"]}
        ReqMgr:request(EVENTNAME.GOTO_CLUB, datav, function(event2)
            parents:select_game_config(event2, keepLevel)
        end, nil, nil, false)
        return
    elseif type =="createRoom" then
        dump("创建房间=======createRoom")
        self:removeSelf()
        return
    end
    self:removeSelf()
end

function FamilyCreateGame:onClickBtnClose(...)
    -- package.loaded["hall.familyCircle.FamilyTakeLayer"] = nil
    -- package.loaded["hall.familyCircle.FamilyCreateGame"] = nil 
    self:removeSelf()
end

function FamilyCreateGame:onExit()
    ReqMgr:delHandle("FamilyCreateGame", EVENTNAME)
end


return FamilyCreateGame