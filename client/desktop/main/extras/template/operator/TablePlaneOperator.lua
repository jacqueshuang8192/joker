local TablePlaneOperator = class("TablePlaneOperator")
local CocosUtil = require("hall.util.CocosUtil")

function TablePlaneOperator:init(tableHall)
    self.invite_ly = tableHall:getChidByName("invite_ly")
    self.copy_btn = self.invite_ly:getChidByName("copy_btn")
    self.share_btn = self.invite_ly:getChidByName("share_btn")
    self.btn_voice = tableHall:getChidByName("btn_voice")
    self.btn_chat = tableHall:getChidByName("btn_chat")
    self.share_btn:onClick(CocosUtil:Bind(self.onClickShare , self))
    self.copy_btn:onClick(CocosUtil:Bind(self.onclickCopyInvoteCode , self))
    self:initVoice()
    self:showViewVC(false)
end
function TablePlaneOperator:onClickShare(event)
    USER_INFO["invote_code"] = USER_INFO["invote_code"] or " "
    local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
    local share_content = ""
    for k,v in pairs(config_arr) do
        if v ~= "" then
            share_content = share_content .. v .. ","
        end
    end
    share_content = string.sub(share_content, 1, string.len(share_content) - 1)
    local paras = {}
    paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
    paras["imagePath"] = "url"
    paras["name"] = GAME_NAME .. "，房号：" .. USER_INFO["invote_code"]
    paras["showType"] = 2;
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"],9999999)
    end
end
function TablePlaneOperator:onclickCopyInvoteCode()
    require("hall.util.GameMenu"):registCopyRoomIdFunc(self.copy_btn, USER_INFO["invote_code"],GAME_NAME)
end
--隐藏or显示桌子分享和复制房间号
function TablePlaneOperator:hideInvite(flag)
    self.invite_ly:setVisible(flag)
end
function TablePlaneOperator:initVoice()
    --添加录音按钮
    local voice_bt_worldpoint = (self.btn_voice:getParent()):convertToWorldSpace(self.btn_voice:getPosition())

    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(self.btn_voice,999)
    else
        VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
    end
end
function TablePlaneOperator:showViewVC(flag)
    self.btn_voice:setVisible(flag)
    self.btn_chat:setVisible(flag)
end

return TablePlaneOperator