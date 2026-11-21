--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyTakeLayer = class("FamilyTakeLayer" , ViewBaseLayer)
local FamilyTakeList = require("hall.familyCircle.FamilyTakeList")
local FamilyCreateGame = require("hall.familyCircle.FamilyCreateGame")
local FamilyPlayingtip = require("hall.familyCircle.FamilyPlayingtip")
local FamilyData = require("hall.familyCircle.FamilyData")
local CocosUtil = require("hall.util.CocosUtil")
local clubSendData = require("hall.view.clubView.clubSendData")
local CommonTips = require("hall.tips.CommonTips")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")


local GAME_ID_TO_MORE_INFO = {
                                [308] =  "hall/res/FriendScircle/image/playingimge/xbtn_hzmj.png",
                                [315] = "hall/res/FriendScircle/image/playingimge/xbtn_ptj.png",
                                [316] =  "hall/res/FriendScircle/image/playingimge/xbtn_tuiduizi.png",
                                [325] = "hall/res/FriendScircle/image/playingimge/xbtn_pdk.png",
                                [342] =  "hall/res/FriendScircle/image/playingimge/xbtn_phz.png",
                            }

function FamilyTakeLayer:ctor(family_id,family_data,parents)
    print("联盟所有得数据！！！！")
    -- dump(family_data)
    self.parents = parents
    self.family_id = family_id
    self.family_ownID =  nil

    --这一步是为了将数据为空的时候，将原来的数据进行顶替，可能是会存在一些问题
    if next(family_data.family_list) == nil  then 
        print("========6666666666==(family_data.family_list) == nil===")
        family_data.family_list = TempFamilyList
        -- CommonTips:showTips(FamilyUntils:SetCommTipLabel("数据family_list为空！！！"))
    else
        TempFamilyList = family_data.family_list
    end
    -- body
    local csbPath = "hall/res/FriendScircle/playing.csb"
    FamilyTakeLayer.super.ctor(self, csbPath)
    -- self.family_id = family_id
    --print("========family_data.family_list[self.family_id]========",family_data.family_list[self.family_id])
    if not family_data.family_list or  not family_data.family_list[self.family_id] then
        print("=========5555555555555========")
        return 
    end

    self.family_ownID = family_data.family_list[self.family_id].owerId
    self:InitData()
    self:InitGame()
end

function FamilyTakeLayer:InitData()
    self.FloorData = {} --联盟以楼层为key的数据
    self.LevelToFloorMap = {} --楼层对应的level信息

    for floorId = 1, 200 do
        self.FloorData[floorId] = {}
        self.FloorData[floorId].gameName = ""
        self.FloorData[floorId].gameLevel = 0
        self.FloorData[floorId].gameType = 0
        self.FloorData[floorId].floorNick = ""
        self.FloorData[floorId].gameConfig = ""  --用来创建游戏的楼层配置

        self.FloorData[floorId].tableData = {}
    end

end

function FamilyTakeLayer:setFloorInfo(data) 
    -- print("=======oooooooooooooo=====")
    -- print("=======oooooooooooooo=====")
    -- print("=======oooooooooooooo=====")
    -- dump(data)

    self.FloorInfo = data or {} 
    local LevelToType = require("hall.GameList"):getLevelToTypeTable() 
    for floorId = 1 , 200 do
        local v = self.FloorInfo[floorId]
       
        if v then
            self.LevelToFloorMap[v.level] = floorId
            self.FloorData[floorId].gameName = v.gameName
            self.FloorData[floorId].gameLevel = v.level
            self.FloorData[floorId].gameType = LevelToType[v.level]
            -- self.FloorData[floorId].floorNick = ""
            self.FloorData[floorId].gameConfig = v  --用来创建游戏的楼层配置
        end
    end
    self:ShowData()
end

function FamilyTakeLayer:ShowData()
    local num = 0
    self.recv_data = {}
    for k , v in pairs(self.FloorData) do 
        if "" ~= v.gameConfig then 
             num = num + 1
             self.recv_data[num] = v.gameConfig
        end
    end
    -- self:CreateTakeTable(num , self.recv_data)
    self.take_data = self.recv_data
    self:ShowTakeData(self.take_data)
end 

function FamilyTakeLayer:InitGame()
    self.ListView:setScrollBarEnabled(false)
    self:RemoveChildRen()

    local data = {playerId = USER_INFO["uid"]}
    local function callback(returnCode, data)
        print("InitGame 返回成功了！！！！")
        print("InitGame 返回成功了！！！！")
        print("InitGame 返回成功了！！！！")
        print("InitGame 返回成功了！！！！",returnCode)

        -- dump(data)
        local take_tab = {}
        if returnCode == 0 then
    
            for clubId , v in pairs(data) do 
                -- dump(v,"ggggggggggggg====")
                local v = json.decode(v)
                -- dump(v,"kkkkkkkkkk====")
                local config = json.decode(v.config) or {}
                -- dump(config,"hhhhhhhhh====")
                if clubId == self.family_id then 
                    -- local tempConfig = json.decode(config.SelectGameConfig)
                    -- dump(tempConfig,"uuuuuuuuuuuuu------")
                    -- self:setFloorInfo(tempConfig)
                    self:setFloorInfo(config.SelectGameConfig)
                end 
            end
        end
    end
    
    clubSendData:requestClubList(data, callback)
end

function FamilyTakeLayer:ShowTakeData(take_tab)
    print("=====init ways to layer!!!====")
    local family_list = FamilyTakeList.new()
    self.ListView:removeAllChildren()
    for i = 1 , 10 do 
        -- dump(take_tab[i])
        local take_path = take_tab[i] and "change_take" or "add_take"
        local add_obj = family_list:GetObj(take_path)
        local layout = add_obj:clone()
        local clone_layout = family_list:CloneLayout(layout)
        if "add_take" == take_path then 
            self:IncreaseTake(clone_layout ,  i)
        else
            self:ChangeTake(clone_layout , take_tab[i] , i)
        end
        self.ListView:pushBackCustomItem(layout)
    end
end

function FamilyTakeLayer:IncreaseTake(layout , index)
    layout.take_id:setString("玩法" .. index)
    layout.BtnAddTake:onClick(CocosUtil:Bind(self.OnClickBtnTake , self))
    layout.BtnAddTake:setVisible(tonumber(USER_INFO.uid) == self.family_ownID)
    layout.Text_8_0:setVisible(not (tonumber(USER_INFO.uid) == self.family_ownID))
end

function FamilyTakeLayer:setGameWFText(layout,take_data,index)
    --add by zzy 2019-6-19 因为每一个游戏的配置玩法key不一致，暂时先判断来描写

    -- elseif gameID == 325 or gameID == 340 or gameID == 302 
    --     or gameID == 303 or gameID == 304 or gameID == 305 
    --     or gameID == 306 or gameID == 307 or gameID == 317 
    --     or gameID == 347 or gameID == 308 then
        --跑得快 or 比鸡 or 明牌抢庄 or 自由上庄 or 轮庄斗牛 or 定庄斗牛 or 疯狂斗牛
        --牛牛上庄 or 诈金花 or 超级三加一 or 快乐麻将



    layout.name_txt:setString(take_data.gameName or "")
    local tempGameStr = " "
    for k,v in pairs(take_data) do
        if type(v) == "table" then
            if v.isShow ~= nil and v.isShow == 1 then
                tempGameStr = tempGameStr..v.configName..":"..v.optionName.." "
            end
        end
    end
    layout.num_txt:setString(tempGameStr)


    -- if take_data.gameId == 342 or take_data.gameId == 345 then
    --     layout.num_txt:setString("3人".." "..take_data.huxi_score.optionName.." "..take_data.pay_type.optionName.." "..take_data.rank.optionName.." "..take_data.round.optionName.." "..take_data.wanfa.optionName)
    -- elseif take_data.gameId == 308 then  --快乐麻将
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.canPick.optionName.." "..take_data.hufa.optionName.." "..take_data.pay_type.optionName.." "..take_data.pay_type.optionName.." "..take_data.round.optionName.." "..take_data.zhuaniao.optionName)
    -- elseif take_data.gameId == 325 then  --跑得快
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.round.optionName.." "..take_data.wanfa.optionName)
    -- elseif take_data.gameId == 340 then  --比鸡
    --     -- layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.grabTimes.optionName.." "..take_data.matchcard.optionName.." "..take_data.round.optionName.." "..take_data.gaoji.optionName)
    -- elseif take_data.gameId == 302 then  --明牌抢庄
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.grabTimes.optionName.." "..take_data.pay_type.optionName.." "..take_data.gaoji.optionName)
    --     -- layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.grabTimes.optionName.." "..take_data.pay_type.optionName.." "..take_data.round.optionName.." "..take_data.gaoji.optionName)
    -- elseif take_data.gameId == 303 then  --自由上庄
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.grabTimes.optionName.." "..take_data.pay_type.optionName.." "..take_data.round.optionName.." "..take_data.gaoji.optionName)
    -- elseif take_data.gameId == 304 then  --轮庄斗牛
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.grabTimes.optionName.." "..take_data.pay_type.optionName.." "..take_data.round.optionName.." "..take_data.gaoji.optionName)
    -- elseif take_data.gameId == 305 then  --定庄斗牛
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.grabTimes.optionName.." "..take_data.pay_type.optionName.." "..take_data.round.optionName.." "..take_data.gaoji.optionName)
    -- elseif take_data.gameId == 306 then  --疯狂斗牛
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.grabTimes.optionName.." "..take_data.pay_type.optionName.." "..take_data.round.optionName.." "..take_data.gaoji.optionName)
    -- elseif take_data.gameId == 307 then  --牛牛上庄
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.pay_type.optionName.." "..take_data.round.optionName.." "..take_data.gaoji.optionName)
    -- elseif take_data.gameId == 317 then  --诈金花
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.circleNeededToShowCards.optionName.." "..take_data.max_round.optionName.." "..take_data.min_round_allin.optionName.." "..take_data.round.optionName.." "..take_data.pay_type.optionName)
    -- elseif take_data.gameId == 347 then  --超级三加一
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.gaoji.optionName.." "..take_data.bankertype.optionName.." "..take_data.round.optionName.." "..take_data.pay_type.optionName)
    -- elseif take_data.gameId == 348 then  --闷胡血牛
    --     layout.num_txt:setString(take_data.maxSeatCount.optionName.." "..take_data.round.optionName.." "..take_data.wanfa.optionName)
    -- end
end

function FamilyTakeLayer:ChangeTake(layout , take_data , index)

    self:setGameWFText(layout,take_data,index)

    layout.take_id:setString("玩法" .. index)
    -- layout.name_txt:setString(take_data.gameName)
    -- layout.num_txt:setVisible(false)
    local path = GAME_ID_TO_MORE_INFO[take_data.gameId] or "hall/res/FriendScircle/image/playingimge/xbtn_pdk.png"
    print("======game ways textTure init path======",path)
    if path then 
        layout.take_pic:loadTexture(path)
    end 

    --add by zzy 
    layout.btn_playing:setTag(index)

    layout.btn_playing:onClick(CocosUtil:Bind(self.OnClickBtnChange , self , index,self.FloorData))
    layout.btn_closewf:onClick(CocosUtil:Bind(self.OnClickBtnCloseWf , self , index,self.FloorData))

    layout.btn_playing:setVisible(tonumber(USER_INFO.uid) == self.family_ownID)
    layout.btn_closewf:setVisible(tonumber(USER_INFO.uid) == self.family_ownID)
    -- layout.Text_8_0_0:setVisible(not (tonumber(USER_INFO.uid) == self.family_ownID))
    layout.Text_8_0_0:setVisible(false)

    -- layout.btn_playing:setVisible(true)
    -- layout.btn_closewf:setVisible(true)
    -- layout.Text_8_0_0:setVisible(not (tonumber(USER_INFO.uid) == self.family_ownID))
end 

function FamilyTakeLayer:OnClickBtnCloseWf(index,data)
    print("=======关闭该玩法======")
    print("=======关闭该玩法======")
    local tempIndex = index-1 or 0
    local tempFamilyID = self.family_id
    local UserID = USER_INFO.uid
    FamilyData:RequestDeleteWF(tempFamilyID , UserID , tempIndex , handler(self , self.returnDeleteWF))

end

function FamilyTakeLayer:returnDeleteWF(data)
    print("我删除成功了！！！")
    -- self.parents:InitTakeTable()
    -- self.parents:InitGame(self.family_id)
    if tolua.isnull(self.parents) or tolua.isnull(self.parents.parents) then
        return
    end

    self.parents.parents:InitGame()
    self.parents:InitGame(self.family_id)

    self:InitData()
    self:InitGame()
    CommonTips:showTips(FamilyUntils:SetCommTipLabel("删除玩法成功！！"))
end

function FamilyTakeLayer:OnClickBtnTake()
    --添加玩法，输入类型为1，修改玩法，输入类型为2
    FamilyCreateGame.new(self,1,nil,nil):addTo(self)
end

function FamilyTakeLayer:OnClickBtnChange(index,data)
    print ("---------修改玩法---创建房间列表-----")
    -- FamilyPlayingtip.new(self,index,data):addTo(self)
    --添加玩法，输入类型为1，修改玩法，输入类型为2
    FamilyCreateGame.new(self,2,index,data[index]):addTo(self)
end    

function FamilyTakeLayer:RemoveChildRen()
    self.ListView:removeAllChildren()
end

function FamilyTakeLayer:onClickBtnClose()
    self:removeSelf()
    -- self:setVisible(false)
end

return FamilyTakeLayer