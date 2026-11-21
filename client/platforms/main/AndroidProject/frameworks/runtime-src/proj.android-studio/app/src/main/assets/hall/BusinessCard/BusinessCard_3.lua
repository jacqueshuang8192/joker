--[[
	公告弹出框
]]
local ViewBaseLayer = require("hall.NewViewBaseLayer")
local BusinessCard_3 = class("BusinessCard_3", ViewBaseLayer)

local EVENTNAME = {
	GET_MY_ID_CARD = "/getMyIDCard",
}

function BusinessCard_3:onExit()
    ReqMgr:delHandle("BusinessCard_3", EVENTNAME)
end

function BusinessCard_3:initGame( )
    local data = {
        ["groupId"] = self.family_id,
        ["playerId"] = USER_INFO.uid,
    }
    ReqMgr:request(EVENTNAME.GET_MY_ID_CARD, data, handler(self, self.GET_MY_ID_CARD))
end

function BusinessCard_3:ctor(family_id, groupName, owerUrl)
    ReqMgr:addHandle("BusinessCard_3", EVENTNAME)
    self.family_id = family_id
    self.groupName = groupName
    self.owerUrl = owerUrl
    local csbPath = "hall/res/business_card/business_card_3.csb"
    BusinessCard_3.super.ctor(self, csbPath, false)
    GameUtils.setNodeNameBindObj(self._csbNode)
	self:enableMask(true)
    self:initUI()
    self:initEvent()
    self:initGame( )
    self.time = 0
    self:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)

end

function BusinessCard_3:update(dt)
    if self.time then
        self.time = self.time + dt
        if self.time >= 1 then
            local function afterCaptured(succeed,sp_png)
                if succeed then
                    print("截屏success",sp_png)
                    viewMgr:showTip({text = "图片已经保存到手机相册"})
                end
            end
            -- local writablePath = string.gsub(device.writablePath, "[\\\\/]+$", "")
            display.captureScreen(afterCaptured, "BusinessCard_3.png")
            self.time = nil
        end
    end
end

function BusinessCard_3:initUI()
    local root = self._csbNode.root.bg
    -- display.doLayout(nil, self._csbNode.bg)
    -- self.urlTxt = root.urlTxt
    self.erweima = root.erweima
    self.codeTxt = root.codebg.txt
    self.weixin = root.weixin.txt
    self.qq = root.qq.txt
    self.xianliao = root.xianliao.txt
    self.lianmeng_txt = root.lianmeng_txt
    self.id_txt = root.id_txt
    self.urlTxt = root.urlTxt
    self.haed = root.haed
    self.bg = self._csbNode.bg
    
    self.urlTxt:setString("")
    self.codeTxt:setString("")
    self.weixin:setString("")
    self.qq:setString("")
    self.xianliao:setString("")
    self.lianmeng_txt:setString("")
    self.id_txt:setString(USER_INFO.uid or "")
   
    if g_hallMainLayer then
        local texture = g_hallMainLayer.bg:getTexture():getPath()
        self.bg:loadTexture(texture)
    end
    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    
end

function BusinessCard_3:initEvent()
    self.maskLayout:onClick(handler(self, self.onClickBtnClose), false)
end

function BusinessCard_3:GET_MY_ID_CARD(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if not (returnCode == 0) then
        viewMgr:showTip({text = error})
        return
    end
    local size = self.haed:getSize()

    local inviteCode = data.myIdCard.inviteCode or ""
    local wxchat = data.myIdCard.wxchat or ""
    local qq = data.myIdCard.qq or ""
    local xianliao = data.myIdCard.xianliao or ""
    local inviteIcon = data.myIdCard.inviteIcon
    local domain = data.domain or ""

    self.urlTxt:setString(domain)
    self.codeTxt:setString(inviteCode)
    self.weixin:setString(wxchat)
    self.qq:setString(qq)
    self.xianliao:setString(xianliao)
    self.lianmeng_txt:setString(self.groupName)
    --upIdCard  还有一个同级的  myidcard

    require("hall.GameCommon"):getUserHead(self.owerUrl, "", "", self.haed, size.width , false, "", true)

    local size = self.erweima:getSize()
    require("hall.GameCommon"):getUserHead(inviteIcon, "", "", self.erweima, size.width , false, "", true)

end

function BusinessCard_3:onClickCopy(event)
    local target = event.target
    local str = target:getParent().txt:getString()
    require(GameSetting_filePath):copyToClipboard(str) 
end

-- 关闭界面
function BusinessCard_3:onClickBtnClose(event)
    self:removeSelf()
end

return BusinessCard_3

