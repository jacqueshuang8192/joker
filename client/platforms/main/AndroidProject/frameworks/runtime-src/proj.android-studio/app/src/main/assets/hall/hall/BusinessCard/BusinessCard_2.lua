--[[
	公告弹出框
]]
local ViewBaseLayer = require("hall.NewViewBaseLayer")
local BusinessCard_2 = class("BusinessCard_2", ViewBaseLayer)

local EVENTNAME = {
	GET_MY_ID_CARD = "/getMyIDCard",
}

function BusinessCard_2:onExit()
    ReqMgr:delHandle("BusinessCard_2", EVENTNAME)
end

function BusinessCard_2:initGame( )
    local data = {
        ["groupId"] = self.family_id,
        ["playerId"] = USER_INFO.uid,
    }
    ReqMgr:request(EVENTNAME.GET_MY_ID_CARD, data, handler(self, self.GET_MY_ID_CARD))
end

function BusinessCard_2:ctor(data)
    ReqMgr:addHandle("BusinessCard_2", EVENTNAME)
    self.family_id = data.key
    self.groupName = data.groupName
    self.owerUrl = data.owerUrl

    local csbPath = "hall/res/business_card/business_card_2.csb"
    BusinessCard_2.super.ctor(self, csbPath)
    GameUtils.setNodeNameBindObj(self._csbNode)
	self:enableMask(true)
    self:initUI()
    self:initEvent()
end

function BusinessCard_2:initUI()
    local root = self._csbNode.root
    -- self.urlTxt = root.urlTxt
    self.codeTxt =root.codebg.txt
    self.weixin = root.weixin.txt
    self.qq = root.qq.txt
    self.xianliao = root.xianliao.txt
    self.weixinBtn = root.weixin.btn_copy:hide()
    self.qqBtn = root.qq.btn_copy:hide()
    self.xianliaoBtn = root.xianliao.btn_copy:hide()
    self.codeBtn = root.codebg.btn_copy
    
    self.urlTxt:setString("")
    self.codeTxt:setString("")
    self.weixin:setString("")
    self.qq:setString("")
    self.xianliao:setString("")
    self.lianmeng_txt:setString("")
end

function BusinessCard_2:initEvent()
    
    self.xianliaoBtn:onClick(handler(self, self.onClickCopy), true)
    self.weixinBtn:onClick(handler(self, self.onClickCopy), true)
    self.qqBtn:onClick(handler(self, self.onClickCopy), true)
    self.codeBtn:onClick(handler(self, self.onClickCopy), true)
    self.maskLayout:onClick(handler(self, self.onClickBtnClose), false)
end

function BusinessCard_2:GET_MY_ID_CARD(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data or {}
    local error = netData.error
    if not (returnCode == 0) then
        viewMgr:showTip({text = error})
        return
    end
    data.upIdCard = data.upIdCard or {}
    local size = self.haed:getSize()
    local inviteCode = data.upIdCard.inviteCode or ""
    local wxchat = data.upIdCard.wxchat or ""
    local qq = data.upIdCard.qq or ""
    local xianliao = data.upIdCard.xianliao or ""
    if wxchat then
        self.weixinBtn:show()
    else
        wxchat = "未填写"
    end
    if qq then
        self.qqBtn:show()
    else
        qq = "未填写"
    end
    if xianliao then
        self.xianliaoBtn:show()
    else
        xianliao = "未填写"
    end
    self.urlTxt:setString(data.domain or "")
    self.codeTxt:setString(inviteCode)
    self.weixin:setString(wxchat)
    self.qq:setString(qq)
    self.xianliao:setString(xianliao)
    self.lianmeng_txt:setString(self.groupName or "")
    --upIdCard  还有一个同级的  myidcard

    require("hall.GameCommon"):getUserHead(self.owerUrl, "", "", self.haed, size.width , false, "", true)
end

function BusinessCard_2:onClickCopy(event)
    local target = event.target
    local str = target:getParent().txt:getString()
    require(GameSetting_filePath):copyToClipboard(str) 
end

-- 关闭界面
function BusinessCard_2:onClickBtnClose(event)
    self:removeSelf()
end

return BusinessCard_2

