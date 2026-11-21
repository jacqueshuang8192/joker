--[[
	公告弹出框
]]
local ViewBaseLayer = require("hall.NewViewBaseLayer")
local BusinessCard = class("BusinessCard", ViewBaseLayer)

local EVENTNAME = {
	GET_MY_ID_CARD = "/getMyIDCard",
	UPDATE_MY_ID_CARD = "/updateMyIDCard",
}

function BusinessCard:onExit()
    ReqMgr:delHandle("BusinessCard", EVENTNAME)
end

function BusinessCard:ctor(data)
    -- local img = display.getImage(bgNode)
    
    self.family_id = data.key
    self.groupName = data.groupName
    self.owerUrl = data.owerUrl
    self.data = data
    local csbPath = "hall/res/business_card/business_card_1.csb"
    BusinessCard.super.ctor(self, csbPath)
    GameUtils.setNodeNameBindObj(self._csbNode)
	self:enableMask(true)
    self:initUI()
    self:initEvent()
end

function BusinessCard:initUI()
    local root = self._csbNode.root
    self.btn_parentCard = root.btn_parentCard --上级名片
    self.btn_parentCard:hide()

    self.btn_share = root.btn_share
    self.btn_sure = root.btn_sure
    self.btn_updata = root.btn_updata
    -- self.urlTxt = root.urlTxt
    -- self.erweima = root.erweima
    -- self.codeTxt = root.codeTxt
    self.weixin = root.weixin.txt
    self.qq = root.qq.txt
    self.xianliao = root.xianliao.txt

    self.urlTxt:setString("")
    self.codeTxt:setString("")
    self.weixin:setString("")
    self.qq:setString("")
    self.xianliao:setString("")
end

function BusinessCard:initEvent()
    ReqMgr:addHandle("BusinessCard", EVENTNAME)
    local data = {
        ["groupId"] = self.family_id,
        ["playerId"] = USER_INFO.uid,
    }
    dump(data,"data===")
    ReqMgr:request(EVENTNAME.GET_MY_ID_CARD, data, handler(self, self.GET_MY_ID_CARD))
    self.btn_parentCard:onClick(handler(self, self.onClickParentCard), true)
    self.btn_share:onClick(handler(self, self.onClickShare), true)
    self.btn_sure:onClick(handler(self, self.onClickSure), true)
    self.btn_updata:onClick(handler(self, self.onClickUpdata), true)
end

function BusinessCard:GET_MY_ID_CARD(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if not (returnCode == 0) then
        viewMgr:showTip({text = error})
        return
    end
    if data == nil or not data.myIdCard then
        viewMgr:showTip({text = "没有获得有效的名片数据"})
        return
    end
    local size = self.erweima:getSize()
    local inviteCode = data.myIdCard.inviteCode or ""
    local wxchat = data.myIdCard.wxchat or ""
    local qq = data.myIdCard.qq or ""
    local xianliao = data.myIdCard.xianliao or ""
    local inviteIcon = data.myIdCard.inviteIcon or ""
    local domain = data.domain or ""

    self.urlTxt:setString(domain)
    self.codeTxt:setString(inviteCode)
    self.weixin:setString(wxchat)
    self.qq:setString(qq)
    self.xianliao:setString(xianliao)
    --upIdCard  还有一个同级的  myidcard
    require("hall.GameCommon"):getUserHead(inviteIcon, "", "", self.erweima, size.width , false, "", true)
    if data.upIdCard then
        self.btn_parentCard:show()
        self._upIdCard = data.upIdCard
    else
        self.btn_parentCard:hide()
    end
    dump(event)
end


function BusinessCard:onClickParentCard(event)
    if not self._upIdCard then
        return
    end
    local data = self._upIdCard
    local event = {
        netData = {
            data = {
                upIdCard = {
                    inviteCode = data.inviteCode,
                    wxchat = data.wxchat,
                    qq = data.qq,
                    xianliao = data.xianliao,
                    inviteIcon = data.inviteIcon,
                }
            },
            returnCode = 0
        }
    }

    local BusinessCard_2 = require("hall.BusinessCard.BusinessCard_2")
    local BusinessCard_2 = BusinessCard_2.new(self.data):addTo(self)
    BusinessCard_2:GET_MY_ID_CARD(event)
end

function BusinessCard:onClickShare(event)
    local paras = {}
    paras["showType"] = 2;
    paras["desc"] = " "
    paras["imagePath"] = "screen"
    paras["name"] = "分享结果"
    paras["url"] = appDownLoadAddress
    local ShareLayer = require("hall.share.ShareLayer").new(paras)
    if ShareLayer then
        ShareLayer:onClickBtnToFriend()
        ShareLayer:removeSelf()
    end
end


function BusinessCard:onClickSure(event)
    local BusinessCard_3 = require("hall.BusinessCard.BusinessCard_3")
    local BusinessCard_3 = BusinessCard_3.new(self.family_id, self.groupName, self.owerUrl):addTo(self)
end

function BusinessCard:onClickUpdata(event)
    local weixin = self.weixin:getString()
    local qq = self.qq:getString()
    local xianliao = self.xianliao:getString()
    local data = {
        ["groupId"] = self.family_id,
        ["playerId"] = USER_INFO.uid,
        ["wechat"] = weixin,
        ["qq"] = qq,
        ["xianliao"] = xianliao,
    }
    ReqMgr:request(EVENTNAME.UPDATE_MY_ID_CARD, data, handler(self, self.UPDATE_MY_ID_CARD))
    
end

function BusinessCard:UPDATE_MY_ID_CARD(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if returnCode == 0 then
        viewMgr:showTip({text = "修改成功"})
        local data = {
            ["groupId"] = self.family_id,
            ["playerId"] = USER_INFO.uid,
        }
        ReqMgr:request(EVENTNAME.GET_MY_ID_CARD, data, handler(self, self.GET_MY_ID_CARD))
    else
        viewMgr:showTip({text = error})
    end
end
-- 关闭界面
function BusinessCard:onClickBtnClose(sender, event)
    self:removeSelf()
end

return BusinessCard

