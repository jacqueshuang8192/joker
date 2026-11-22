--[[
* author:   zwm
* date:     2019-04-01
* describe: 大厅主界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local ViewBaseLayer = require("hall.ViewBaseLayer")
local LoginLayer = class("LoginLayer", ViewBaseLayer)
local LoginRegView = require("hall.login.LoginRegView")
function LoginLayer:show()
    local scene = SCENENOW["scene"]
    if scene:getChildByName("loginLayer") then return end
    bm.checknetworking = false
    USER_INFO, UID, token = {}, nil, nil
    self.new():addTo(scene, 90000)
end

function LoginLayer:ctor()
    LoginLayer.super.ctor(self, "hall/res/login/loginLayer.csb")
    require("hall.login.UsernameView").attach(self)
    self.isCanLogin = true
    -- 设置 name，方便后续查找和移除
    self:setName("loginLayer")

    --[[
    if is_wechat_login then
        self.btnPhone:setVisible(false)
        self.btnLogin:setVisible(true)
    else
        self.btnPhone:setVisible(true)
        self.btnLogin:setVisible(false)
    end
    local size = self.root:getContentSize()
    self.btnPhone:setPositionX(size.width / 2)
    self.btnLogin:setPositionX(size.width / 2)
    --]]
end

function LoginLayer:onClickBtnLogin(sender, event)
    if device.platform == "windows" then
        require("hall.tool.viewManager"):showTip({text = "微信登录请使用手机客户端"})
        return
    end
    if self.checkBox:isSelected() then
        if not self.isCanLogin then return end
        cct.getDateForApp("wxLogin", {}, "V")

        self.isCanLogin = false
        bm.SchedulerPool:delayCall(
            function()
                self.isCanLogin = true
            end,
            2
        )
    else
        local paras = {}
        paras.type = 1
        paras.title = "提示"
        paras.content = "请先勾选同意游戏协议"

        require("hall.tips.CommonTips"):showTips(paras)
    end
end
function LoginLayer:onClickBtnPhone(sender, event)
    if self:getChildByName("phoneForm") then return end
    local form = LoginRegView.new()
    form:setName("phoneForm")
    form:addTo(self)
end

return LoginLayer
