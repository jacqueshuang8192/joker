--[[
* author:   zwm
* date:     2019-03-14
* describe: 大厅里嵌套子界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local HallGameLayer = class("HallGameLayer", ViewBaseLayer)
local FamilyData = require("hall.familyCircle.FamilyData")
local FamilyMainLayer = require("hall.familyCircle.FamilyMainLayer")

local GAME_ID_TO_MORE_INFO = {
                                [325] = {type = 1, ico = "hall/res/hallMain/image/game_paodekuai.png"},
                                -- [342] = {type = 3, ico = "hall/res/hallMain/image/btn_paohuzi.png"},
                                -- [345] = {type = 1, ico = "hall/res/hallMain/image/btn_paohuzi.png"},
                                [308] = {type = 3, ico = "hall/res/hallMain/image/game_hongzhong.png"},
                                -- [340] = {type = 1, ico = "hall/res/hallMain/image/game_paodekuai.png"},


                                [347] = {type = 1, ico = "hall/res/hallMain/image/sanJiaYI.png"},

                                -- --add niuniu 2019-7-12
                                [302] = {type = 1, ico = "hall/res/hallMain/image/niuniu.png"},
                                [613] = {type = 1, ico = "hall/res/hallMain/image/niuniu.png"},

                                [348] = {type = 2, ico = "hall/res/hallMain/image/mj_mhxn.png"},
                                
                                [340] = {type = 3, ico = "hall/res/hallMain/image/btn_biji.png"},
                                [329] = {type = 1, ico = "hall/res/hallMain/image/aiyou_liuzhou.png"},
                                [359] = {type = 1, ico = "hall/res/hallMain/image/aiyou_bayi.png"},
                                -- [357] = {type = 1, ico = "hall/res/hallMain/image/btn_zzmj.png"},
                                -- [320] = {type = 1, ico = "hall/res/hallMain/image/btn_csmj.png"},

                            }

function HallGameLayer:ctor(parents)

    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/doudizhu/doudizhu0.png","hall/res/hallMain/newAnim/doudizhu/doudizhu0.plist","hall/res/hallMain/newAnim/doudizhu/doudizhu.ExportJson");                         -- 加载动画所用到的数据
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/hongzhongmajiang/hongzhongmajiang0.png","hall/res/hallMain/newAnim/hongzhongmajiang/hongzhongmajiang0.plist","hall/res/hallMain/newAnim/hongzhongmajiang/hongzhongmajiang.ExportJson");                         -- 加载动画所用到的数据
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/huanlepingshi/huanlepingshi0.png","hall/res/hallMain/newAnim/huanlepingshi/huanlepingshi0.plist","hall/res/hallMain/newAnim/huanlepingshi/huanlepingshi.ExportJson");                         -- 加载动画所用到的数据
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/huanlesangong/huanlesangong0.png","hall/res/hallMain/newAnim/huanlesangong/huanlesangong0.plist","hall/res/hallMain/newAnim/huanlesangong/huanlesangong.ExportJson");                         -- 加载动画所用到的数据
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/loudifangpaofa/loudifangpaofa0.png","hall/res/hallMain/newAnim/loudifangpaofa/loudifangpaofa0.plist","hall/res/hallMain/newAnim/loudifangpaofa/loudifangpaofa.ExportJson");                         -- 加载动画所用到的数据
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/paodekuai/paodekuai0.png","hall/res/hallMain/newAnim/paodekuai/paodekuai0.plist","hall/res/hallMain/newAnim/paodekuai/paodekuai.ExportJson");                         -- 加载动画所用到的数据
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/zhajinhua/zhajinhua0.png","hall/res/hallMain/newAnim/zhajinhua/zhajinhua0.plist","hall/res/hallMain/newAnim/zhajinhua/zhajinhua.ExportJson");                         -- 加载动画所用到的数据

    HallGameLayer.super.ctor(self, "hall/res/hallMain/hallGameLayer.csb")
    self.showSortGameId = {317,325,302,362,345,308,360,340}

    --self.showSortGameId = {348,325,317,302}
    -- self.showSortGameId = {302,325,317}
    -- self.showSortGameId = {302,308,325,317,357,320,358}
    -- self.showSortGameId = {329, 359}
    --self.showSortGameId = {362}
    self.showBtnGameValue = {}
    for v,k in pairs(self.showSortGameId) do

    end

	-- self.showSortGameId = {308,348,342,340}
    -- self.showSortGameId = {308,347,340,325}
    self.parents = parents
    self:showBySortGameId()
    --self:setScaleX(CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)
end

function HallGameLayer:showBySortGameId()
    self.maxGames = #self.showSortGameId
    local showSize = self.maxGames >= 8 and 7 or self.maxGames
    for i = 1, 8 do
        if self.showSortGameId[i] == nil then
           return
        end
        --local path = GAME_ID_TO_MORE_INFO[self.showSortGameId[i]].ico
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/anime"..self.showSortGameId[i].."/anime"..self.showSortGameId[i]..".png","hall/res/hallMain/newAnim/anime"..self.showSortGameId[i].."/anime"..self.showSortGameId[i]..".plist","hall/res/hallMain/newAnim/anime"..self.showSortGameId[i].."/anime"..self.showSortGameId[i]..".ExportJson");                         -- 加载动画所用到的数据
        self["btnGame"..i]:removeAllChildren()
        local armature = ccs.Armature:create("anime"..self.showSortGameId[i])  -- 创建动画对象
        armature:getAnimation():playWithIndex(0)
        armature:setPosition( self["btnGame"..i]:getContentSize().width/2, self["btnGame"..i]:getContentSize().height/2)                    -- 设置位置
        --armature:setScale(1.29)
        --armature:getAnimation():play("Tween",100)            -- 设置动画对象执行的动画名称
        self["btnGame"..i].level = self.showSortGameId[i]
        self["btnGame"..i]:addChild(armature)                      -- 把动画对象加载到场景内
        self["btnGame"..i]:setVisible(true)
        --require("hall.util.CocosUtil"):toReplaceButtonImg(self["btnGame"..i], path, path, nil, 1)

    end
    --self["btnGame"..(showSize+1)]:setVisible(true)
end

function HallGameLayer:onClickBtnGame1(sender, event)
    local tmp =  sender.level
    if tmp == nil then
        return
    end
    self:getRoomInfoFromHttpByLevel(tmp)
    --if self.showSortGameId[1] ~= nil then
    --    local tmp =  self.showSortGameId[1]
    --    self:getRoomInfoFromHttpByLevel(tmp)
    --    -- table.remove(self.showSortGameId, 1)
    --    -- table.insert(self.showSortGameId, tmp)
    --    -- self:showBySortGameId()
    --else
    --    -- local paras = {}
    --    -- paras.type = 1
    --    -- paras.title = "提示"
    --    -- paras.content = "敬请期待更多游戏"
    --    -- require("hall.tips.CommonTips"):showTips(paras)
    --    -- self:enterMoreGame()
    --end
end

function HallGameLayer:onClickBtnGame2(sender, event)
    local tmp =  sender.level
    if tmp == nil then
        return
    end
    self:getRoomInfoFromHttpByLevel(tmp)
    --if self.showSortGameId[2] ~= nil then
    --    local tmp =  self.showSortGameId[2]
    --    self:getRoomInfoFromHttpByLevel(tmp)
    --    -- table.remove(self.showSortGameId, 2)
    --    -- table.insert(self.showSortGameId, tmp)
    --    -- self:showBySortGameId()
    --else
    --    -- local paras = {}
    --    -- paras.type = 1
    --    -- paras.title = "提示"
    --    -- paras.content = "敬请期待更多游戏"
    --    -- require("hall.tips.CommonTips"):showTips(paras)
    --    self:enterMoreGame()
    --end
end

function HallGameLayer:onClickBtnGame3(sender, event)
    local tmp =  sender.level
    if tmp == nil then
        return
    end
    self:getRoomInfoFromHttpByLevel(tmp)
    --if self.showSortGameId[3] ~= nil then
    --    local tmp =  self.showSortGameId[3]
    --    self:getRoomInfoFromHttpByLevel(tmp)
    --    -- table.remove(self.showSortGameId, 3)
    --    -- table.insert(self.showSortGameId, tmp)
    --    -- self:showBySortGameId()
    --else
    --    -- local paras = {}
    --    -- paras.type = 1
    --    -- paras.title = "提示"
    --    -- paras.content = "敬请期待更多游戏"
    --    -- require("hall.tips.CommonTips"):showTips(paras)
    --    self:enterMoreGame()
    --end
end

function HallGameLayer:onClickBtnGame4(sender, event)
    local tmp =  sender.level
    if tmp == nil then
        return
    end
    self:getRoomInfoFromHttpByLevel(tmp)
    --if self.showSortGameId[4] ~= nil then
    --    local tmp =  self.showSortGameId[4]
    --    self:getRoomInfoFromHttpByLevel(tmp)
    --    -- table.remove(self.showSortGameId, 4)
    --    -- table.insert(self.showSortGameId, tmp)
    --    -- self:showBySortGameId()
    --else
    --    -- local paras = {}
    --    -- paras.type = 1
    --    -- paras.title = "提示"
    --    -- paras.content = "敬请期待更多游戏"
    --    -- require("hall.tips.CommonTips"):showTips(paras)
    --    self:enterMoreGame()
    --end
end

function HallGameLayer:onClickBtnGame5(sender, event)
    local tmp =  sender.level
    if tmp == nil then
        return
    end
    self:getRoomInfoFromHttpByLevel(tmp)
    --if self.showSortGameId[5] ~= nil then
    --    local tmp =  self.showSortGameId[5]
    --    self:getRoomInfoFromHttpByLevel(tmp)
    --    -- table.remove(self.showSortGameId, 5)
    --    -- table.insert(self.showSortGameId, tmp)
    --    -- self:showBySortGameId()
    --else
    --    -- local paras = {}
    --    -- paras.type = 1
    --    -- paras.title = "提示"
    --    -- paras.content = "敬请期待更多游戏"
    --    -- require("hall.tips.CommonTips"):showTips(paras)
    --    self:enterMoreGame()
    --end
end

function HallGameLayer:onClickBtnGame6(sender, event)
    local tmp =  sender.level
    if tmp == nil then
        return
    end
    self:getRoomInfoFromHttpByLevel(tmp)
    --if self.showSortGameId[6] ~= nil then
    --    local tmp =  self.showSortGameId[6]
    --    self:getRoomInfoFromHttpByLevel(tmp)
    --    -- table.remove(self.showSortGameId, 6)
    --    -- table.insert(self.showSortGameId, tmp)
    --    -- self:showBySortGameId()
    --else
    --    -- local paras = {}
    --    -- paras.type = 1
    --    -- paras.title = "提示"
    --    -- paras.content = "敬请期待更多游戏"
    --    -- require("hall.tips.CommonTips"):showTips(paras)
    --    self:enterMoreGame()
    --end
end
function HallGameLayer:onClickBtnGame7(sender, event)
    local tmp =  sender.level
    if tmp == nil then
        return
    end
    self:getRoomInfoFromHttpByLevel(tmp)
    --if self.showSortGameId[7] ~= nil then
    --    local tmp =  self.showSortGameId[7]
    --    self:getRoomInfoFromHttpByLevel(tmp)
    --    -- table.remove(self.showSortGameId, 6)
    --    -- table.insert(self.showSortGameId, tmp)
    --    -- self:showBySortGameId()
    --else
    --    -- local paras = {}
    --    -- paras.type = 1
    --    -- paras.title = "提示"
    --    -- paras.content = "敬请期待更多游戏"
    --    -- require("hall.tips.CommonTips"):showTips(paras)
    --    self:enterMoreGame()
    --end
end
function HallGameLayer:onClickBtnGame8(sender, event)
    local tmp =  sender.level
    if tmp == nil then
        return
    end
    self:getRoomInfoFromHttpByLevel(tmp)
    --if self.showSortGameId[8] ~= nil then
    --    local tmp =  self.showSortGameId[8]
    --    self:getRoomInfoFromHttpByLevel(tmp)
    --    -- table.remove(self.showSortGameId, 6)
    --    -- table.insert(self.showSortGameId, tmp)
    --    -- self:showBySortGameId()
    --else
    --    -- local paras = {}
    --    -- paras.type = 1
    --    -- paras.title = "提示"
    --    -- paras.content = "敬请期待更多游戏"
    --    -- require("hall.tips.CommonTips"):showTips(paras)
    --    self:enterMoreGame()
    --end
end
function HallGameLayer:enterMoreGame()
    print("=====enter more game select layer!!!=====")
    self.parents:onClickBtnCreatRoom()
end

function HallGameLayer:openRoomInfoTip(roomInfo)
    print("openRoomInfoTip --------------")
    if roomInfo == nil then return end
    
    local roomInfoTip = require("hall.createAndEnterRoom.CreateRoomInfoTip").new(roomInfo)
    if roomInfoTip then
        roomInfoTip:addTo(g_hallMainLayer)
    end
end

function HallGameLayer:getRoomInfoFromHttpByLevel( level )
    self:enterRoom(level)
    -- require(Request_filePath):getCreateGroupGameConfigForGoldGame(level, handler(self, self.openRoomInfoTip))
end

function HallGameLayer:enterRoom(level)
    dump(level,"gewgewgewg ew")
    if g_hallMainLayer then
        local HallMainLayer = g_hallMainLayer
        local data = HallMainLayer:getCurData()
        if data then
            dump(data.roleType,"data.roleType--")
            HallMainLayer.familyMainlayer = FamilyMainLayer.new(data, HallMainLayer, level):addTo(HallMainLayer)
            USER_INFO["family_data"] = data
            FamilyData:SetFamilyId(data.key)
        else
            viewMgr:showTip({text = "您还没有联盟，请先加入联盟"})
        end 
    end
end

return HallGameLayer