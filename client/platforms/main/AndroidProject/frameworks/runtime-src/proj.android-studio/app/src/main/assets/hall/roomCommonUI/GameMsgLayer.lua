--[[
* author:   zwm
* date:     2019-04-20
* describe: 发送文字和表情的界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local voiceResPath = ""
local faceResPath  = "hall/res/roomCommonUI/image/" 

local ViewBaseLayer = require("hall.ViewBaseLayer")
local GameMsgLayer = class("GameMsgLayer", ViewBaseLayer)

GameMsgLayer.txt={

    [1] =  "快点啊，我等的到花儿都谢了",
    [2] = "鼻孔都这么大啦，还那么装羞，快点出来啦",
    [3] ="大家好，想找我签名的请先排队",
    [4] ="流氓不可怕，就怕流氓有文化",
    [5] ="牌差要什么紧，偶靠地是牌技",
    [6] ="我说你是炮兵学院毕业地",
    [7] ="再牛的肖邦也弹不出老子的悲伤呐",
    [8] = "拖时间是没用的，快出牌吧",
    [9] ="他再接电话，请稍候",
    [10] ="不要吵了，有什么好吵的，专心玩游戏",
    [11] ="不要走，决战到天亮",
}

GameMsgLayer.voice={
    [1] = {[1] = voiceResPath .."Man_cc_7.mp3",[2] = voiceResPath .."Woman_cc_7.mp3"},
    [2] = {[1] = voiceResPath .."Man_cc_1.mp3",[2] = voiceResPath .."Woman_cc_1.mp3"},
    [3] = {[1] = voiceResPath .."Man_cc_2.mp3",[2] = voiceResPath .."Woman_cc_2.mp3"},
    [4] = {[1] = voiceResPath .."Man_cc_3.mp3",[2] = voiceResPath .."Woman_cc_3.mp3"},
    [5] = {[1] = voiceResPath .."Man_cc_4.mp3",[2] = voiceResPath .."Woman_cc_4.mp3"},
    [6] = {[1] = voiceResPath .."Man_cc_5.mp3",[2] = voiceResPath .."Woman_cc_5.mp3"},
    [7] = {[1] = voiceResPath .."Man_cc_6.mp3",[2] = voiceResPath .."Woman_cc_6.mp3"},
    [8] = {[1] = voiceResPath .."Man_cc_0.mp3",[2] = voiceResPath .."Woman_cc_0.mp3"}, 
    [9] = {[1] = voiceResPath .."Man_cc_8.mp3",[2] = voiceResPath .."Woman_cc_8.mp3"},
    [10] = {[1] = voiceResPath .."Man_cc_9.mp3",[2] = voiceResPath .."Woman_cc_9.mp3"},
    [11] = {[1] = voiceResPath .."Man_cc_10.mp3",[2] = voiceResPath .."Woman_cc_10.mp3"},
}

GameMsgLayer.face={
    [51] = {path = faceResPath .."crazy.png", key = "crazy", size = 8},
    [52] = {path = faceResPath .."fennu.png", key = "fennu", size = 4},
    [53] = {path = faceResPath .."han.png", key = "han", size = 6},
    [54] = {path = faceResPath .."happy.png", key = "happy", size = 4},
    [55] = {path = faceResPath .."huaixiao.png", key = "huaixiao", size = 4},
    [56] = {path = faceResPath .."jiong.png", key = "jiong", size = 6},
    [57] = {path = faceResPath .."lihai.png", key = "lihai", size = 16},
    [58] = {path = faceResPath .."se.png", key = "se", size = 6},
    [59] = {path = faceResPath .."shaoxiang.png", key = "shaoxiang", size = 6},
    [60] = {path = faceResPath .."shihua.png", key = "shihua", size = 4},
    [61] = {path = faceResPath .."sleep.png", key = "sleep", size = 6},
    [62] = {path = faceResPath .."smile.png", key = "smile", size = 4},
    [63] = {path = faceResPath .."touxiang.png", key = "touxiang", size = 6},
    [64] = {path = faceResPath .."yun.png", key = "yun", size = 6},
    [65] = {path = faceResPath .."ziya.png", key = "ziya", size = 6},
}

--  sendFaceHand 发送表情的回调
--  sendEditHand 发送自己编辑文本的回调
function GameMsgLayer:ctor(data)
    GameMsgLayer.super.ctor(self, "hall/res/roomCommonUI/gameMsgLayer.csb")
    self:refrashTxtLst()
    self:refrashFaceLst()
    self:showContentByType(1)
    self.data = data
    self.inputBg:hide()
    self.btnSendInput:hide()
    local size = self.txtContent:getContentSize()
    self.txtContent:setContentSize(size.width, 320.00)
    if isHideBiaoQing then
        self:setScale(0)
    end
end

function GameMsgLayer:onEnter()
    self.dt = 0
    self:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
    local parent = self:getParent()
end

function GameMsgLayer:update(dt)
    -- self.dt = self.dt + dt
    -- -- print(dt)
    -- -- dump(self.dt)
    -- if SCENENOW["name"] ~= "hall.gameScene" then
    --     local scene = SCENENOW.scene
    --     local EmojiArmatureView = scene:getChildByName("EmojiArmatureView")
    --     if not EmojiArmatureView then
    --         require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self.data)
    --     end
    -- end

end

function GameMsgLayer:refrashTxtLst()
    for i, v in ipairs( self.txt ) do
        local node = self:getTxtNode(v, i)
        self.txtContent:pushBackCustomItem(node)
    end
end

function GameMsgLayer:refrashFaceLst()
    local info = {} 
    local index = 0
    for k, v in pairs( self.face ) do
        index = index + 1
        if math.mod(index, 3) == 0 or index == #self.face then
            local tmp = {path = v.path, idx = k} 
            table.insert(info, tmp)
            local node = self:getFaceNode(info)
            self.faceContent:pushBackCustomItem(node)
            info = {}
        else
            local tmp = {path = v.path, idx = k} 
            table.insert(info, tmp)
        end
    end
end

function GameMsgLayer:getTxtNode(str, idx)
    if not (self and self.txtBase) then
        return
    end
    local node = self.txtBase:clone()
    local btn = node:getChildByName("btnSendTxt")
    btn:setName("sendTxt>"..idx)
    btn:addTouchEventListener(handler(self, self.callBackSendTxt))
    node:getChildByName("showTxt"):setString(str)

    return node
end

function GameMsgLayer:callBackSendTxt(sender, event)
    if event == TOUCH_EVENT_ENDED then
        local lst = string.split(sender:getName(), ">")
        local idx = tonumber(lst[#lst])
        if self.data.sendFaceHand then
            self.data.sendFaceHand(idx)
            self:onClickBtnClose()

        end
    end
end

function GameMsgLayer:getVoiceInfoByIndex(idx)
    local result = {txt = self.txt[idx], voice = self.voice[idx]} 
    return result
end

function GameMsgLayer:getFaceNode(info)
    local node = self.faceBase:clone()
    for i = 1, 3 do
        if info[i] then
            local btn = node:getChildByName("btnSendFace"..i)
            if btn.addTouchEventListener then
                require("hall.util.CocosUtil"):toReplaceButtonImg(btn, info[i].path, info[i].path, nil, 0)
                btn:setName("sendFace>"..info[i].idx)
                btn:addTouchEventListener(handler(self, self.callBackSendFace))
            end
        else
            node:getChildByName("btnSendFace"..i):setVisible(false)
        end
    end

    return node
end

function GameMsgLayer:callBackSendFace(sender, event)
    if event == TOUCH_EVENT_ENDED then
        local lst = string.split(sender:getName(), ">")
        local idx = tonumber(lst[#lst])
        if self.data.sendFaceHand then
            self.data.sendFaceHand(idx)
            self:onClickBtnClose()
        end
    end
end

--参数:type 1、表示显示文字；2、表示显示表情
function GameMsgLayer:showContentByType(type)
    -- self.faceContent:setVisible(type == 2)
    -- self.txtContent:setVisible(type == 1)
end

function GameMsgLayer:onClickBtnSendInput(sender, event)
    local   textMessage = self.textField:getString()

    if not textMessage or textMessage == "" then
        return
    end
    
    textMessage = require("hall.GameCommon"):formatNick(textMessage,60)

    self.textField:setString("")

    local textMessage_table = {}
          textMessage_table["uid"] = USER_INFO["uid"]
          textMessage_table["textMessage"] = textMessage
          textMessage_table["msgType"] = "text"
    local msg = json.encode(textMessage_table)
    if self.data.sendEditHand then
        self.data.sendEditHand(msg)
    else
        local currentGameLevel = USER_INFO["GroupLevel"] or 40        
        local pack = bm.server:createPacketBuilder(0x801)      --CLIENT_CMD_SEND_MSG_TO_SERVER 协议 
                    :setParameter("level",currentGameLevel)
                    :setParameter("msg", msg)
                    :build()

        bm.server:send(pack)
    end
    self:onClickBtnClose()

end

function GameMsgLayer:getFaceAniByIdx(idx)
    local info = self.face[idx]
    local filePath = "hall/res/roomCommonUI/image/emoji.plist" 
    local ani = require("hall.util.CocosUtil"):playAnimation(filePath, info.key, info.size, 1, 4/25, 0)
    print("GameMsgLayer:getFaceAniByIdx ------------------------", tolua.isnull(ani))
    return ani
end

function GameMsgLayer:getTxtVoice(idx)
    return {txt = self.txt[idx], path = self.voice[idx]}
end

function GameMsgLayer:onClickBtnSendFace(sender, event)
    self:showContentByType(2)

end

function GameMsgLayer:onClickBtnSendTxt(sender, event)
    self:showContentByType(1)
end

function GameMsgLayer:onClickBtnClose( sender, event )
    self:setVisible(false)
end

return GameMsgLayer
