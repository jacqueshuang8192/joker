--[[
* author:   zwm
* date:     2019-03-16
* describe: 创建游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]------------------------------

-- 游戏ID和类型、 ico的对应表
local GAME_ID_TO_MORE_INFO = {  

                                [308] = {type = 2, ico = "hall/res/createRoom/image/game_hongzhongMJ.png"},  --快乐麻将
                                [348] = {type = 2, ico = "hall/res/createRoom/image/mj_mhxn.png"},  --快乐麻将
                                [315] = {type = 3, ico = "hall/res/createRoom/image/game_pingtianjiu.png"},  
                                [316] = {type = 2, ico = "hall/res/createRoom/image/game_tuiduizi.png"},
                                [325] = {type = 1, ico = "hall/res/createRoom/image/game_paodekuai.png"},    --跑的快
                                [340] = {type = 1, ico = "hall/res/createRoom/image/btn_biji.png"},       --
                                [342] = {type = 3, ico = "hall/res/createRoom/image/btn_paohuzi.png"},       --常德字牌

                                [345] = {type = 3, ico = "hall/res/createRoom/image/btn_loudifangpao.png"},       --娄底跑胡子
                                [347] = {type = 1, ico = "hall/res/createRoom/image/btn_superSanAddYi.png"},       --超级三加一

                                [302] = {type = 1 ,ico = "hall/res/createRoom/image/game_niuniu.png"} ,      --名牌抢庄
                                [317] = {type = 1 ,ico = "hall/res/createRoom/image/game_zhajinhua.png"} ,   --炸金花
                            
                                [354] = {type = 3, ico = "hall/res/createRoom/image/btn_xxGHZ.png"}, 
                                [349] = {type = 3, ico = "hall/res/createRoom/image/btn_hyLHZ.png"}, 
                                [356] = {type = 3, ico = "hall/res/createRoom/image/btn_PHZ.png"}, 
                                [353] = {type = 3, ico = "hall/res/createRoom/image/btn_syBP.png"}, 
                                [350] = {type = 3, ico = "hall/res/createRoom/image/btn_SHK.png"}, 
                                [351] = {type = 3, ico = "hall/res/createRoom/image/btn_WHZ.png"}, 
                                [352] = {type = 3, ico = "hall/res/createRoom/image/btn_xhPHZ.png"}, 
                                [355] = {type = 3, ico = "hall/res/createRoom/image/btn_yzPHZ.png"}, 
                                -- [309] = {type = 2, ico = "hall/res/createRoom/image/game_hongzhongMJ.png"},  --广东麻将
                                [329] = {type = 2, ico = "hall/res/createRoom/image/game_hongzhongMJ.png"},  --广西柳州麻将
                                [120] = {type = 1 ,ico = "hall/res/createRoom/image/game_zhajinhua.png"} ,   --三公


                                [320] = {type = 2 ,ico = "hall/res/createRoom/image/btn_csmj.png"} ,   --长沙麻将
                                [357] = {type = 2 ,ico = "hall/res/createRoom/image/btn_zzmj.png"} ,   --转转麻将
                                [358] = {type = 2 ,ico = "hall/res/createRoom/image/yj_btn.png"} ,   --转转麻将
                            }


local ViewBaseLayer = require("hall.ViewBaseLayer")
local CreateRoomLayer = class("CreateRoomLayer", ViewBaseLayer)

-- gameData 数据格式
--[[ 
    gameData = {
        {type = 1, gameName = "pdk", gameId = 100, gameLevel = 100, gameImgPath = "hall/res/createRoom/image/game_paodekuai.png"},
    }
--]]
function CreateRoomLayer:ctor(gameData)
    display.addSpriteFrames("hall/res/createRoom/image/create_room.plist","hall/res/createRoom/image/create_room.png")
    local csbPath = "hall/res/createRoom/createRoomLayer.csb"
    CreateRoomLayer.super.ctor(self, csbPath)

    self.gameData = self:getAllGameData()
    self:showGameByType(1)
    g_createRoomLayer = self
    self.gameRoomInfo = {}
end

local ReadyOpenGame = {
    [354] = "湘乡告胡子",
    [349] = "衡阳6胡抢",
    [356] = "碰胡子",
    [353] = "邵阳剥皮",
    [350] = "十胡卡",
    [351] = "歪胡子",
    [352] = "新化跑胡子",
    [355] = "永州跑胡子",
}

function CreateRoomLayer:getAllGameData()
    local result = {}
    for k, v1 in pairs( bm.gameList_forRoomCard ) do
        for i, v2 in ipairs( v1.gameArr or {} ) do
            local tData = {}
            tData.type = self:getGameTypeById(v2.gameId)
            tData.gameName = v2.code
            tData.gameId = v2.gameId
            tData.gameLevel = v2.level
            tData.gameImgPath = self:getGameImgById(v2.gameId)
            if tData.type ~= nil and tData.gameImgPath ~= nil then
                table.insert(result, clone(tData))
            else
                print("get [type] or [gameImgPath] is nil from table [GAME_ID_TO_MORE_INFO] ...")
            end
        end
    end

    --add by zzy 2019-8-17
    -- for k,v in pairs(ReadyOpenGame) do
    --     local tData = {}
    --     tData.type = self:getGameTypeById(k)
    --     tData.gameName = v
    --     tData.gameId = k
    --     tData.gameLevel = k
    --     tData.gameImgPath = self:getGameImgById(k)
    --     if tData.type ~= nil and tData.gameImgPath ~= nil then
    --         table.insert(result, clone(tData))
    --     else
    --         print("get [type] or [gameImgPath] is nil from table [GAME_ID_TO_MORE_INFO] ...")
    --     end
    -- end

    dump(result, "getAllGameData")
    return result 
end

function CreateRoomLayer:getGameTypeById(gameId)
    if GAME_ID_TO_MORE_INFO[gameId] == nil then
        return nil
    end
    return GAME_ID_TO_MORE_INFO[gameId].type
end

function CreateRoomLayer:getGameImgById(gameId)
    if GAME_ID_TO_MORE_INFO[gameId] == nil then
        return nil
    end
    return GAME_ID_TO_MORE_INFO[gameId].ico
end

function CreateRoomLayer:showGameByType(type)
    local prevSubGameType = self.subGameType
    self:setSelSubGameStatus(type)
    self.listView:removeAllChildren()
    local subGameData = self:getSubGameDataByType(type)
    for i = 1, math.ceil(#subGameData/4) do
        local cellData = {subGameData[(i-1)*4 + 1], subGameData[(i-1)*4 + 2], subGameData[(i-1)*4 + 3], subGameData[(i-1)*4 + 4]}
        -- dump(cellData, "cellData")
        local subGameCell = require("hall.createAndEnterRoom.SubGameCell").new(cellData)
        subGameCell:setName("subCell"..tostring(i))
        local groupLY = ccui.Layout:create()
        groupLY:setAnchorPoint(cc.p(0,1))
        groupLY:setTouchEnabled(false)
        groupLY:setContentSize(cc.size(1060, 220))
        groupLY:addChild(subGameCell)
        groupLY:setName("subCell"..tostring(i))
        self.listView:pushBackCustomItem(groupLY)
    end

    -- if prevSubGameType == nil then
    --     local subGameData = self:getSubGameDataByType(type)
    --     for i = 1, math.ceil(#subGameData/4) do
    --         local cellData = {subGameData[(i-1)*4 + 1], subGameData[(i-1)*4 + 2], subGameData[(i-1)*4 + 3], subGameData[(i-1)*4 + 4]}
    --         dump(cellData, "cellData")
    --         local subGameCell = require("hall.createAndEnterRoom.SubGameCell").new(cellData)
    --         subGameCell:setName("subCell"..tostring(i))
    --         local groupLY = ccui.Layout:create()
    --         groupLY:setAnchorPoint(cc.p(0,1))
    --         groupLY:setTouchEnabled(false)
    --         groupLY:setContentSize(cc.size(1060, 220))
    --         groupLY:addChild(subGameCell)
    --         groupLY:setName("subCell"..tostring(i))
    --         self.listView:pushBackCustomItem(groupLY)
    --     end
    -- else
    --     local prevSubGameData = self:getSubGameDataByType(prevSubGameType)
    --     local subGameData = self:getSubGameDataByType(type)
    --     if #prevSubGameData > #subGameData then -- 上次加载的节点比本次要加载的多
    --         for i = 1, math.ceil(#prevSubGameData/4) do
    --             local cell = self.listView:getChildByName("subCell"..tostring(i)):getChildByName("subCell"..tostring(i))
    --             if i > math.ceil(#subGameData/4) then
    --                 if cell then
    --                     cell:removeFromParent()
    --                 end
    --             else
    --                 local cellData = {subGameData[(i-1)*4 + 1], subGameData[(i-1)*4 + 2], subGameData[(i-1)*4 + 3], subGameData[(i-1)*4 + 4]}
    --                 cell:refrashGameData(cellData)
    --             end
    --         end
    --     else
    --         for i = 1, math.ceil(#subGameData/4) do
    --             local cellData = {subGameData[(i-1)*4 + 1], subGameData[(i-1)*4 + 2], subGameData[(i-1)*4 + 3], subGameData[(i-1)*4 + 4]}
    --             if i > math.ceil(#prevSubGameData/4) then 
    --                 local subGameCell = require("hall.createAndEnterRoom.subGameCell").new(cellData)
    --                 subGameCell:setName("subCell"..tostring(i))
    --                 local groupLY = ccui.Layout:create()
    --                 groupLY:setAnchorPoint(cc.p(0,1))
    --                 groupLY:setTouchEnabled(false)
    --                 groupLY:setContentSize(cc.size(1060, 220))
    --                 groupLY:addChild(subGameCell)
    --                 groupLY:setName("subCell"..tostring(i))
    --                 self.listView:pushBackCustomItem(groupLY)
    --             else
    --                 local cell = self.listView:getChildByName("subCell"..tostring(i)):getChildByName("subCell"..tostring(i))
    --                 cell:refrashGameData(cellData)
    --             end
    --         end
    --     end
    -- end
end

function CreateRoomLayer:setSelSubGameStatus(type)
    self.subGameType = type
    local subGameTypeBg = {"pukeSelImg", "MJSelImg", "zhipaiSelImg"} 
    local subGameTypeTxt = {"namePuke", "nameMJ", "nameZhipai"}
    for i, v in ipairs( subGameTypeBg ) do
         self[v]:setVisible(i == type)
    end

    for i, v in ipairs( subGameTypeTxt ) do
        if i == type then
            self[v]:setTextColor(cc.c3b(255, 255, 255))
            self[v]:enableOutline(cc.c4b(31, 42, 0, 119), 2)
        else
            self[v]:setTextColor(cc.c3b(139, 187, 255))
            self[v]:enableOutline(cc.c4b(31, 42, 0, 119), 2)
        end
    end
end

function CreateRoomLayer:getSubGameDataByType(type)
    local result = {}
    for i, v in ipairs( self.gameData or {} ) do
        if type == v.type  then
            table.insert(result, v)
        end
        -- if type == v.type and type ~= 3 then
        --     table.insert(result, v)
        -- elseif type == 3 and v.type == 3 then
        --     if  v.gameId == 342  then
        --         table.insert(result, v)
        --     end
        -- end
    end 

    return clone(result)
end

function CreateRoomLayer:onClickBtnReturn(sender, event)
    self:removeSelf()
end

function CreateRoomLayer:onClickBtnGamePuke(sender, event)
    self:showGameByType(1)
end

function CreateRoomLayer:onClickBtnGameMJ(sender, event)
    self:showGameByType(2)
end

function CreateRoomLayer:onClickBtnGameZhipai(sender, event)
    self:showGameByType(3)
end

function CreateRoomLayer:onExit()
    g_createRoomLayer = nil
end

return CreateRoomLayer