--[[
* author:   zwm
* date:     2019-04-03
* describe: 游戏说明界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local disclaimer_content = cc.FileUtils:getInstance():getStringFromFile("hall/playerInstruction/PlayerInstructionLayer.json")
local disclaimer_config = json.decode(disclaimer_content)
-- 游戏ID和游戏名字的对应表 
local GAME_ID_TO_NAME = 
{
    [1] ={ [395] = {fontS = "font_hzMJ_s.png", fontN = "font_hzMJ.png", name="欢乐拼十", desc="牛牛"},},
    -- [2] ={[340] = {fontS = "font_paodekuai_s.png", fontN = "font_paodekuai.png", name="比鸡", desc="比鸡"},},
    [3] ={[308] = {fontS = "font_hzMJ_s.png", fontN = "font_hzMJ.png", name="红中麻将", desc="红中麻将"},},
    [4] ={ [325] = {fontS = "font_paodekuai_s.png", fontN = "font_paodekuai.png", name="跑得快", desc="跑得快"},},
    -- [5] ={ [317] = {fontS = "font_paohuzi_s.png", fontN = "font_paohuzi.png", name="欢乐三张", desc="炸金花"},},
    [6] ={ [345] = {fontS = "font_paohuzi_s.png", fontN = "font_paohuzi.png", name="娄底放炮", desc="娄底放炮罚"},},
    -- [7] ={[324] = {fontS = "font_paohuzi_s.png", fontN = "font_paohuzi.png", name="斗地主", desc="斗地主"},},
    -- [8] ={ [329] = {fontS = "font_paohuzi_s.png", fontN = "font_paohuzi.png", name="柳州麻将", desc="柳州麻将"},},
    -- [9] ={[359] = {fontS = "font_paohuzi_s.png", fontN = "font_paohuzi.png", name="八一字牌", desc="八一字牌"},},
    -- [10] ={[315] = {fontS = "font_paijiu_s.png", fontN = "font_paijiu.png",name="牌九", desc="牌九"},},
    -- [11] ={[316] = {fontS = "font_tuiduizi_s.png", fontN = "font_tuiduizi.png", name="二八杠", desc="二八杠"},},
    -- [12] ={[357] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="转转麻将", desc="转转麻将"},},
    -- [13] ={[360] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="欢乐三公", desc="欢乐三公"},},
    -- [14] ={[362] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="金州水鱼", desc="金州水鱼"},},
    -- [15] ={[363] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="十三水", desc="十三水"},},
    -- [16] ={[348] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="闷胡血流", desc="闷胡血流"},},
    [17] ={[365] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="新十三水", desc="新十三水"},},
    -- [18] ={[367] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="福建十三水", desc="福建十三水"},},
    -- [19] ={[366] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="梅州红中宝", desc="梅州红中宝"},},
    -- [20] ={[611] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="常德字牌", desc="常德字牌"},},
    -- [21] ={[376] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="卡二条", desc="卡二条"},},
    [21] ={[391] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="溆浦老牌", desc="溆浦老牌"},},
    [22] ={[392] = {fontS = "font_paohuzi_s.png", fontN = "font_tuiduizi.png", name="溆浦跑胡子", desc="溆浦跑胡子"},},
}
local BASE_PATH = "hall/res/playerInstruction/image/"

-- local ViewBaseLayer = require("hall.ViewBaseLayer")
local PlayerInstructionLayer = class("PlayerInstructionLayer", NewViewBaseLayer)
local CocosUtil = require("hall.util.CocosUtil")
function PlayerInstructionLayer:ctor()
    local csbPath = "hall/res/playerInstruction/playerInstructionLayer.csb"
    PlayerInstructionLayer.super.ctor(self, csbPath)
    self:loadAllGameLst()
    self:enableMask(true)
    self.btn_item:hide()
end

function PlayerInstructionLayer:loadAllGameLst()
    local index = 1
    for k,v in CocosUtil:pairsByKeys(GAME_ID_TO_NAME or {}) do
    --for k, v in pairs( GAME_ID_TO_NAME or {} ) do
        local state = (index == 1) and 1 or 0
        for k2, v2 in pairs( v or {} ) do
            local button = self:createButtonByGameID(k2, state)
            -- local groupLY = ccui.Layout:create()
            -- groupLY:setAnchorPoint(cc.p(0,1))
            -- groupLY:setTouchEnabled(false)
            -- groupLY:setContentSize(cc.size(176, 62))
            -- groupLY:addChild(button)
            self.gameListView:pushBackCustomItem(button)
            index = index + 1
        end

    end
end

function PlayerInstructionLayer:createButtonByGameID(gameId, state)
    -- local buttonNode = self:loadCSB("hall/res/playerInstruction/gameNode.csb")
    
    local button = self.btn_item:clone()
    button:show()
    button:setName("btn>"..tostring(gameId))
    button:addTouchEventListener(handler(self, self.touchCallBack))
    self["btn>"..tostring(gameId)] = button
    self["game>"..tostring(gameId)] = button

    self:exchangeBtnState(gameId, state)
    if state == 1 then
        self:showInstructionByGameID(gameId)
    end
    
    return button
end

function PlayerInstructionLayer:loadCSB(path)
    local node = nil
    if device.platform == "ios" then
        if isiOSVerify then
            node = cc.CSLoader:createNode(path)
        else
            node = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. path)
        end
    else
        node = cc.CSLoader:createNode(path)
    end

    return clone(node)
end

function PlayerInstructionLayer:exchangeBtnState(gameId, state)
    local button = self["btn>"..tostring(gameId)]
    local path = (state == nil or state == 0) and "btn_sel_n.png" or "btn_sel.png" -- 0 表示没选中状态
    require("hall.util.CocosUtil"):toReplaceButtonImg(button, BASE_PATH..path, BASE_PATH..path, nil, 1)
    local info = nil
    for k,v in CocosUtil:pairsByKeys(GAME_ID_TO_NAME or {}) do
        for k2, v2 in pairs( v or {} ) do
            if k2 == gameId then
                info = v2
                break
            end
        end
    end
    if info ==nil then
        return
    end
    --local info = GAME_ID_TO_NAME[gameId]
    local node = self["game>"..tostring(gameId)]
    dump(node:getChildByName("anbtntext"))
     local anbtntext = node:getChildByName("anbtntext") 
     anbtntext:setText(info["name"])
     --[[if (state == nil or state == 0) then
        anbtntext:setFontSize(38)
        anbtntext:setTextColor(cc.c3b(255,255,255))
        anbtntext:enableOutline(cc.c4b(0,88,6,255), 2)
        anbtntext:enableShadow(cc.c3b(92,92,92), cc.size(0,-1), 1)
    else
        anbtntext:setFontSize(38)
        anbtntext:setTextColor(cc.c3b(255,255,255))
        anbtntext:enableOutline(cc.c4b(239,93,24,255), 1)
        anbtntext:enableShadow(cc.c3b(92,92,92), cc.size(0,-1), 1)
    end--]]
    -- local img = self["game>"..tostring(gameId)]:getChildByName("nameImg") 
    -- local imgPath = (state == nil or state == 0) and info.fontN or info.fontS -- 0 表示没选中状态
    -- require("hall.util.CocosUtil"):toReplaceSprImg(img, BASE_PATH..imgPath)
end

function PlayerInstructionLayer:touchCallBack(sender, event)
    if event == TOUCH_EVENT_BEGAN then
        sender:setScale(0.9)
        require("hall.GameCommon"):playEffectSound("hall/scene/res/common/music/Audio_Button_Click.mp3")
    elseif  event == TOUCH_EVENT_CANCELED then
        sender:setScale(1)
    elseif event == TOUCH_EVENT_ENDED then
        sender:setScale(1)
        local gameId = tonumber(string.split(sender:getName(), ">")[2])
        if gameId then
            self:showInstructionByGameID(gameId)
            self:refrashAllBtnState(gameId)
        end
    end
end

function PlayerInstructionLayer:showInstructionByGameID(gameId)
    self.contentListView:removeAllChildren()
    local desc = nil
    --local desc = GAME_ID_TO_NAME[gameId].desc
    for k,v in CocosUtil:pairsByKeys(GAME_ID_TO_NAME or {}) do
        for k2, v2 in pairs( v or {} ) do
            if k2 == gameId then
                desc = v2.desc
                break
            end

        end

    end
    if desc == nil then
        return
    end
    -- dump(disclaimer_content)
    -- dump(disclaimer_config[desc])
    local content = disclaimer_config[desc] or ""

    local txtWidth = 740
    local txtCount = string.len(content)
    local lineCount = (txtCount * 10) / txtWidth

    local label = display.newTTFLabel({
        text = content,
        font = "hall/res/font/FZY3JW.TTF",
        size = 26,
        color = cc.c3b(103, 113, 150),
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(txtWidth, 0)
    })
    -- label:setLineHeight(40) 
    label:setAnchorPoint(cc.p(0,0))
    local groupLY = ccui.Layout:create()
    groupLY:setAnchorPoint(cc.p(0,0))
    groupLY:setTouchEnabled(false)
    groupLY:setContentSize(cc.size(750, label:getContentSize().height))
    groupLY:addChild(label)
    self.contentListView:pushBackCustomItem(groupLY)
end

function PlayerInstructionLayer:refrashAllBtnState( gameId )
    for k,v in CocosUtil:pairsByKeys(GAME_ID_TO_NAME or {}) do
        for k2, v2 in pairs( v or {} ) do
            local state = (k2 == gameId) and 1 or 0
            self:exchangeBtnState(k2, state)
            break
        end

    end
end

function PlayerInstructionLayer:onClickBtnClose(sender, event)
    self:removeSelf()
end

return PlayerInstructionLayer