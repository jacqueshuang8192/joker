--[[
* author:   zwm
* date:     2019-03-21
* describe: 设置界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.NewViewBaseLayer")
local WanFaSettingLayer = class("WanFaSettingLayer", ViewBaseLayer)
local GetGameName = require("hall.familyCircle.GetGameName")
local HallServer = import(HallServer_filePath)

function WanFaSettingLayer:ctor(family_id,chooseWanFaType)
    self.bgData = bgData or {}
    local csbPath = "hall/res/FriendScircle/WanFaSettingLayer.csb"
    WanFaSettingLayer.super.ctor(self, csbPath)
    GameUtils.setNodeNameBindObj(self._csbNode)
    self.family_id = family_id

    self:enableMask(true)
    self:setTag(1001)
    --local SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    --self.settingBg:setPositionX(SCREEN_WIDTH/2)

    local levelList = require("hall.familyCircle.levelList")
    local jifen_levels = levelList[1]
    self:initUI(jifen_levels)


    --从大厅服 拿到已经设置了哪几个游戏  为何步直接从监听的数据拿？
    --HallServer:broadcastHallMsg(USER_INFO["uid"],family_id)
    self:refreshUI(chooseWanFaType) --应改由服务器数据回调
end

function WanFaSettingLayer:initUI(jifen_levels)
    local size = self.ListView_1:getContentSize()
    local index = 0
    local itemIdx = 1
    self.Panel_1Clone = nil
    self.Panel_1:hide()
    self.childs = {}
    for i,value in ipairs(jifen_levels) do
        for key,level in pairs(value) do
            if level > 0  then
                local item = nil
                if itemIdx == 1 then
                    self.Panel_1Clone = self.Panel_1:clone():show()
                    GameUtils.setNodeNameBindObj(self.Panel_1Clone)
                    itemIdx = 1 + itemIdx
                    item = self.Panel_1Clone.item_1
                    self.Panel_1Clone.item_2:hide()
                    self.ListView_1:pushBackCustomItem(self.Panel_1Clone)
                elseif itemIdx == 2 then
                    itemIdx = 1
                    item = self.Panel_1Clone.item_2:show()
                end

                local name = GetGameName:getName(level)
                item:getChildByName("txt_gameName"):setString(name)

                --这里显示勾勾
                item:setName(key)
                item:setTag(level)
                item:onClick(handler(self, self.onClickItem))
                index = index + 1
                table.insert(self.childs, item)
            end
        end
    end
end

function WanFaSettingLayer:refreshUI(chooseWanFaType)
    local gameType = chooseWanFaType
    local gameTypeReal = {}
    for i,v in ipairs(gameType) do
        gameTypeReal[v] = 1
    end

    local childs = self.childs
    for k,child in pairs(childs) do
        if gameTypeReal[child:getName()] then
            child:getChildByName("Image_check"):setVisible(true)
        else
            child:getChildByName("Image_check"):setVisible(false)
        end 
    end
end

function WanFaSettingLayer:onClickItem(event)
    local target = event.target
    local Image_check = target:getChildByName("Image_check")
    Image_check:setVisible(not Image_check:isVisible())
end

function WanFaSettingLayer:onClickBtnReturn(sender, event)
    self:removeSelf()
end

function WanFaSettingLayer:onClickBtnSure(sender, event)
    local childs = self.childs
    local str = ""
    for k,child in pairs(childs) do
       local Image_check = child:getChildByName("Image_check")
       if Image_check:isVisible() then
            local gametype = child:getName()
            if str == "" then
                str = str ..gametype
            else
                str = str .. "-" ..gametype
            end
       end
    end

    if str == "" then
        viewMgr:showTip({text = "请至少选择一款游戏"})
        return
    end

    local interfaceName = "/opeSetClubGameLimit"
    local httpType = "POST"

    local data = {
        groupId = self.family_id,
        XYUid = USER_INFO["uid"],
        gameLimits = str,
    }

    dump(str,"wanfa---str==")

    cct.createHttRq({
        url = HttpAddr .. interfaceName,
        date = data,
        type_= httpType,

        callBack = function(data)
            local returnCode = tonumber(json.decode(data.netData).returnCode)
            if 0 == returnCode then 
                self:removeSelf()
            end
        end})
end

return WanFaSettingLayer