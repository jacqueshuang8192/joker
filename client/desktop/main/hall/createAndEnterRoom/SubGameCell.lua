--[[
* author:   zwm
* date:     2019-03-16
* describe: 游戏进入的Ico界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local SubGameCell = class("SubGameCell", ViewBaseLayer)

function SubGameCell:ctor(data)
    local csbPath = "hall/res/createRoom/subGameCell.csb"
    SubGameCell.super.ctor(self, csbPath)

    self:refrashGameData(data)
end

function SubGameCell:refrashGameData(data)
    self.gameData = data
    for i = 1, 4 do
        if data[i] then
            self["btnGame"..tostring(i)]:setVisible(true)
            require("hall.util.CocosUtil"):toReplaceButtonImg(self["btnGame"..tostring(i)], data[i].gameImgPath, data[i].gameImgPath, nil, 1)
        else
            self["btnGame"..tostring(i)]:setVisible(false)
        end
    end
end

function SubGameCell:onClickBtnGame1(sender, event)
    -- to open room info tip
    if self.gameData[1] then
        self:openRoomInfoTipByGameId(self.gameData[1].gameLevel)
    end
end

function SubGameCell:onClickBtnGame2(sender, event)
    if self.gameData[2] then
        self:openRoomInfoTipByGameId(self.gameData[2].gameLevel)
    end
end

function SubGameCell:onClickBtnGame3(sender, event)
    if self.gameData[3] then
        self:openRoomInfoTipByGameId(self.gameData[3].gameLevel)
    end
end

function SubGameCell:onClickBtnGame4(sender, event)
    if self.gameData[4] then
        self:openRoomInfoTipByGameId(self.gameData[4].gameLevel)
    end
end

function SubGameCell:openRoomInfoTipByGameId(level)
    print("======level=======",level)
    if level then
        level = tonumber(level)
        if level == 354 or level == 349 or level == 356
         or level == 353 or level == 350 
         or level == 351 or level == 352
         or level == 355 or level == 345 then
            require("hall.GameTips"):showTips("提示", "", 2, "游戏正在开发中...")
        else
            local roomInfo = self:getRoomInfoForLocalByLevel(level)
            dump(roomInfo, "openRoomInfoTipByGameId")
            if roomInfo then
                self:openRoomInfoTip(roomInfo)
            else
                self:getRoomInfoFromHttpByLevel(level)
            end
        end
    end
end

function SubGameCell:getRoomInfoForLocalByLevel(level)
    for i, v in ipairs( g_createRoomLayer.gameRoomInfo or {} ) do
        if v.level == level then
            return v
        end
    end

    return nil
end

function SubGameCell:openRoomInfoTip(roomInfo)
    print("openRoomInfoTip --------------")
    dump(roomInfo)
    if roomInfo == nil then return end
    local isHasData = false 
    for i, v in ipairs( g_createRoomLayer.gameRoomInfo or {} ) do
        if v.level == roomInfo.level then
            isHasData = true
            break
        end
    end

    if not isHasData then
        if g_createRoomLayer.gameRoomInfo == nil or roomInfo == nil then
            return
        end
        table.insert(g_createRoomLayer.gameRoomInfo, roomInfo)
    end
    
    local roomInfoTip = require("hall.createAndEnterRoom.CreateRoomInfoTip").new(roomInfo)
    if roomInfoTip then
        roomInfoTip:addTo(g_createRoomLayer)
    end
end

function SubGameCell:getRoomInfoFromHttpByLevel( level )
    require(Request_filePath):getCreateGroupGameConfigForGoldGame(level, handler(self, self.openRoomInfoTip))
end

return SubGameCell
