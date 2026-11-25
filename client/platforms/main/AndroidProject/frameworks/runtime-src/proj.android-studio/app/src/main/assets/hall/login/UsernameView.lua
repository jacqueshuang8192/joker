local M = {}
local bodyFont = "hall/res/font/wryh.ttf"
local titleFont = "hall/res/font/fzcy.ttf"

local function box(parent, width, height, x, y, color)
    local node = ccui.Layout:create()
    node:setBackGroundColorType(1)
    node:setBackGroundColor(color)
    node:setContentSize(cc.size(width, height))
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setPosition(x, y)
    parent:addChild(node)
    return node
end

local function label(parent, text, size, x, y, color)
    local node = ccui.Text:create(text, size >= 25 and titleFont or bodyFont, size)
    node:setColor(color or cc.c3b(255, 255, 255))
    node:setPosition(x, y)
    parent:addChild(node)
    return node
end

local ink = cc.c3b(31, 59, 95)
local muted = cc.c3b(83, 109, 137)
local linkColor = cc.c3b(20, 88, 163)
local inputRim = cc.c3b(153, 180, 204)
local focusedRim = cc.c3b(49, 145, 216)
local common = "hall/res/commom/"

local function texture(parent, path, width, height, x, y, insets)
    local image = ccui.ImageView:create(path)
    if insets then
        image:setScale9Enabled(true)
        image:setCapInsets(insets)
    else
        image:ignoreContentAdaptWithSize(false)
    end
    image:setContentSize(cc.size(width, height))
    image:setPosition(x, y)
    parent:addChild(image)
    return image
end

local function onTap(node, action)
    node:setTouchEnabled(true)
    node:addTouchEventListener(function(_, event)
        if event == ccui.TouchEventType.began then
            node:setOpacity(185)
        elseif event == ccui.TouchEventType.canceled or event == ccui.TouchEventType.ended then
            node:setOpacity(255)
            if event == ccui.TouchEventType.ended then action() end
        end
    end)
end

local function textAction(parent, caption, width, x, y, action)
    local hit = ccui.Layout:create()
    hit:setContentSize(cc.size(width, 44))
    hit:setAnchorPoint(cc.p(0.5, 0.5))
    hit:setPosition(x, y)
    hit:setCascadeOpacityEnabled(true)
    parent:addChild(hit)
    local text = label(hit, caption, 20, width / 2, 22, linkColor)
    onTap(hit, action)
    return hit, text
end

local function input(parent, caption, y, secret, onEdit)
    local width, height = 335, 55
    label(parent, caption, 24, 119, y, ink)
    local slot = common .. "bg_1.png"
    local insets = cc.rect(16, 16, 8, 8)
    local rim = texture(parent, slot, width, height, 350, y, insets)
    rim:setColor(inputRim)
    texture(rim, slot, width - 3, height - 3, width / 2, height / 2, insets)
    local field = ccui.EditBox:create(cc.size(width - 28, height - 4), ccui.Scale9Sprite:create())
    field:setPosition(width / 2, height / 2)
    field:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    field:setInputFlag(secret and cc.EDITBOX_INPUT_FLAG_PASSWORD or cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    field:setMaxLength(secret and 255 or 20)
    field:setFontColor(ink)
    field:setFontSize(23)
    field:setFontName(bodyFont)
    local hint = label(rim, "", 20, 15, height / 2, muted)
    hint:setAnchorPoint(cc.p(0, 0.5))
    field:registerScriptEditBoxHandler(function(event)
        if onEdit then onEdit(field:getText()) end
        local editing = event == "began" or event == "changed"
        hint:setVisible(not editing and field:getText() == "")
        rim:setColor(editing and focusedRim or inputRim)
    end)
    rim:addChild(field)
    return field, hint
end

local function isPhone(account)
    return #account == 11 and account:match("^1[3-9]%d+$") ~= nil
end

local function requestBody(account, pwd, register, profile)
    local devices = {ios = 0, android = 1, windows = 2}
    local deviceId = devices[device.platform] or 3
    if not isPhone(account) then
        local path = register and "/playerUser/username/register" or "/playerUser/username/login"
        return path, "application/json", json.encode({username = account, password = pwd, device = deviceId, requestRecoveryCode = true})
    end
    local params = {phone = account}
    local path = "/userLogin"
    if register then
        path = "/playerUser/quickRegisterByPhone"
        params.passWord = pwd
        params.nickname = profile and profile.nickname or "新玩家"
        params.photo = profile and profile.photo or ""
        params.sex = profile and profile.sex or 1
    else
        params.password = pwd
        params.device = deviceId
    end
    local pairsEncoded = {}
    for key, value in pairs(params) do
        pairsEncoded[#pairsEncoded + 1] = key .. "=" .. string.urlencode(value)
    end
    return path, "application/x-www-form-urlencoded", table.concat(pairsEncoded, "&")
end

local function serviceBase()
    local base = (HttpAddr or ""):gsub("/+$", "")
    if base:match("^https://") then return base end
    local authority = base:match("^http://([^/]+)")
    if authority then
        local host = authority:match("^([^:]+):%d+$") or authority
        if host == "127.0.0.1" or host == "localhost" then return base end
    end
end

local function validCode(code)
    return type(code) == "string" and #code == 32 and code:match("^%x+$") ~= nil
end

local function post(view, url, contentType, body, callback)
    local xhr=cc.XMLHttpRequest:new()
    xhr:open("POST",url)
    xhr:setRequestHeader("Content-Type",contentType.."; charset=utf-8")
    xhr.timeout=15
    xhr:registerScriptHandler(function()
        if xhr.readyState~=4 and xhr.status~=0 then return end
        xhr:unregisterScriptHandler()
        if tolua.isnull(view) or view:getParent()==nil then return end
        if xhr.status~=200 then callback(nil); return end
        local ok,result=pcall(json.decode,xhr.response)
        callback(ok and type(result)=="table" and result or {error="服务响应异常"})
    end)
    xhr:send(body)
end

local function open(loginLayer, entry, startWithRegistration)
    if loginLayer:getChildByName("usernameForm") then return end
    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local w, h = size.width, size.height
    local overlay = box(loginLayer, w, h, w / 2, h / 2, cc.c3b(9, 25, 55))
    overlay:setName("usernameForm")
    overlay:setLocalZOrder(10)
    overlay:setBackGroundColorOpacity(129)
    overlay:setTouchEnabled(true)

    local panelWidth, panelHeight = 590, 375
    local scale = math.min(1, (w - 36) / panelWidth, h * 0.57 / panelHeight)
    -- Leave the game logo above the form and the safety notice below it.
    local panel = texture(overlay, "hall/res/login/account-panel.png", panelWidth, panelHeight,
                          w / 2, h * 0.082 + panelHeight * scale / 2)
    panel:setScale(scale)
    local heading = label(panel, "", 37, panelWidth / 2, 330)
    heading:enableOutline(cc.c4b(16, 69, 155, 255), 2)
    local wechat = loginLayer.btnLogin
    local showWechat = wechat:isVisible()
    entry:setVisible(false)
    wechat:setVisible(false)
    local pending, registering = false, false
    local close = texture(panel, "hall/res/login/image/close.png", 46, 45, 548, 331)
    onTap(close, function()
        if pending then return end
        entry:setVisible(true)
        wechat:setVisible(showWechat)
        overlay:removeFromParent()
    end)
    local profileButton,changeLink,forgotLink
    local function updateProfileLink(account)
        if changeLink then
            local available=not registering and not pending and not isPhone(account)
            changeLink:setVisible(available)
            forgotLink:setVisible(available)
        end
        if profileButton then profileButton:setVisible(registering and not pending and isPhone(account)) end
    end
    local username, nameHint = input(panel, "账号", 246, false, updateProfileLink)
    local password, passHint = input(panel, "密码", 179, true)
    local status = label(panel, "", 18, panelWidth / 2, 133, cc.c3b(162, 54, 43))
    local primary, primaryText, switchButton, switchText

    local function setMode(register)
        registering = register
        updateProfileLink(username:getText())
        heading:setString(register and "账号注册" or "账号登录")
        nameHint:setString("请输入手机号或用户名")
        passHint:setString(register and "设置登录密码" or "请输入密码")
        primaryText:setString(register and "注册并登录" or "登录游戏")
        switchText:setString(register and "已有账号？去登录" or "没有账号？去注册")
        status:setString("")
    end

    local function setBusy(busy, message)
        pending = busy
        updateProfileLink(username:getText())
        primary:setTouchEnabled(not busy)
        switchButton:setTouchEnabled(not busy)
        username:setTouchEnabled(not busy)
        password:setTouchEnabled(not busy)
        primary:setOpacity(busy and 160 or 255)
        primaryText:setString(message or (registering and "注册并登录" or "登录游戏"))
    end

    local function sheet(title,height)
        panel:setVisible(false)
        local view=texture(overlay,"hall/res/login/account-panel.png",panelWidth,height,w/2,h/2)
        view:setScale(math.min(1,(w-36)/panelWidth,(h-36)/height))
        local header=label(view,title,32,panelWidth/2,height-44)
        header:enableOutline(cc.c4b(16,69,155,255),2)
        return view
    end

    local function saveCode(name,code,done)
        local view=sheet("保存一次性恢复码",360)
        label(view,"用户名  "..name,22,295,236,ink)
        local groups={}
        for group in code:gmatch("....") do groups[#groups+1]=group end
        label(view,table.concat(groups,"-",1,4),28,295,194,ink)
        label(view,table.concat(groups,"-",5,8),28,295,160,ink)
        label(view,"恢复码只显示一次，请按两行顺序保存，勿交给他人。",18,295,111,muted)
        textAction(view,"已保存，继续",215,295,55,function()
            view:removeFromParent()
            panel:setVisible(true)
            done()
        end)
    end

    local function manage(reset)
        if pending then return end
        local view=sheet(reset and "找回用户名密码" or "修改用户名密码",475)
        local account,accountHint=input(view,"用户名",367,false)
        account:setText(username:getText())
        accountHint:setString("输入注册的用户名")
        accountHint:setVisible(account:getText()=="")
        local proof,proofHint=input(view,reset and "恢复码" or "原密码",303,true)
        proofHint:setString(reset and "输入保存的完整恢复码" or "输入原登录密码")
        local newPwd,newHint=input(view,"新密码",239,true)
        newHint:setString("设置 8 至 64 字节的新密码")
        local confirm,confirmHint=input(view,"确认密码",175,true)
        confirmHint:setString("再次输入新密码")
        local note=label(view,"",18,295,127,muted)
        local sending=false
        local back=texture(view,"hall/res/login/image/close.png",46,45,548,431)
        onTap(back,function()
            if sending then return end
            view:removeFromParent()
            panel:setVisible(true)
        end)
        textAction(view,reset and "重设密码" or "保存新密码",218,295,66,function()
            if sending then return end
            local name=account:getText():match("^%s*(.-)%s*$")
            local secret,pwd=proof:getText(),newPwd:getText()
            if #name<3 or #name>20 or not name:match("^[A-Za-z][A-Za-z0-9_]*$") then
                note:setString("请输入有效的用户名"); return
            end
            if reset then
                secret=secret:gsub("[%s%-]",""):upper()
                if #secret~=32 or not secret:match("^%x+$") then note:setString("请输入完整的 32 位恢复码"); return end
            elseif secret=="" then note:setString("请输入原密码"); return end
            if #pwd<8 or #pwd>64 or not pwd:find("%S") then note:setString("新密码须为 8 至 64 字节"); return end
            if pwd~=confirm:getText() then note:setString("两次输入的新密码不一致"); return end
            local base=serviceBase()
            if not base then note:setString("请先配置本服的 HTTPS 接口地址"); return end
            local payload={username=name,newPassword=pwd}
            if reset then payload.recoveryCode=secret else payload.oldPassword=secret end
            sending=true
            note:setString("正在保存…")
            post(view,base.."/playerUser/username/"..(reset and "resetPassword" or "changePassword"),
                "application/json",json.encode(payload),function(result)
                    sending=false
                    if not result then note:setString("结果待确认，可先用新密码登录"); return end
                    if result.returnCode~="0" then note:setString(result.error or "未能更改密码"); return end
                    view:removeFromParent()
                    setMode(false)
                    username:setText(name); nameHint:setVisible(false)
                    password:setText(""); passHint:setVisible(true)
                    local code = type(result.data) == "table" and result.data.recoveryCode
                    if validCode(code) then
                        saveCode(name,code,function() status:setString("密码已更新，请用新密码登录") end)
                    else
                        panel:setVisible(true)
                        status:setString("未收到恢复码，请用新密码登录后再次改密领取")
                    end
                end)
        end)
    end

    local function enterGame(name,data)
        UID, token = tonumber(data.userId), data.token
        USER_INFO = {uid = UID, token = token, account = data.account or name,
                     nick = data.nickName or name, type = "P", phone = data.phone or "",
                     loginMethod = isPhone(name) and "phone" or "username"}
        if device.platform == "android" then
            local bridge = require("cocos.cocos2d.luaj")
            bridge.callStaticMethod(luaJniClass, "setUserID", {UID}, "(I)V")
            bridge.callStaticMethod(luaJniClass, "setToken", {token}, "(Ljava/lang/String;)V")
            bridge.callStaticMethod(luaJniClass, "setNickName", {USER_INFO.nick}, "(Ljava/lang/String;)V")
        end
        display_scene("hall.hallScene", 1)
    end

    local function authenticate(base,name,pwd,register,justRegistered,profile)
        local path,contentType,body=requestBody(name,pwd,register,profile)
        setBusy(true,register and "正在注册…" or "正在登录…")
        status:setString("")
        post(overlay,base..path,contentType,body,function(result)
            setBusy(false)
            if not result then
                if justRegistered then status:setString("账号已创建，连接失败，请重新登录")
                elseif register then status:setString("注册结果未确认，请重试或切换登录")
                else status:setString("无法连接登录服务，请稍后重试") end
                return
            end
            if result.returnCode~="0" then status:setString(result.error or "登录服务响应异常"); return end
            local data=type(result.data)=="table" and result.data or {}
            local function proceed()
                if register then
                    setMode(false)
                    authenticate(base,name,pwd,false,true)
                elseif tonumber(data.userId) and type(data.token)=="string" and data.token~="" then
                    enterGame(name,data)
                else status:setString("登录响应缺少玩家身份信息") end
            end
            if validCode(data.recoveryCode) then saveCode(name,data.recoveryCode,proceed) else proceed() end
        end)
    end

    local function submit(profile)
        if pending then return end
        local name = username:getText():match("^%s*(.-)%s*$")
        local pwd = password:getText()
        if name == "" then
            status:setString("请输入手机号或用户名")
            return
        end
        if name:match("^%d+$") then
            if not isPhone(name) then
                status:setString("请输入有效的11位手机号")
                return
            end
            if pwd == "" or (registering and #pwd < 6) then
                status:setString(registering and "手机号注册密码至少6位" or "请输入登录密码")
                return
            end
        else
            if #name < 3 or #name > 20 or not name:match("^[A-Za-z][A-Za-z0-9_]*$") then
                status:setString("请输入手机号，或3至20位字母开头的用户名")
                return
            end
            if #pwd < 8 or #pwd > 64 or not pwd:find("%S") then
                status:setString("用户名密码长度须为8至64字节")
                return
            end
        end
        local base=serviceBase()
        if not base then
            status:setString("请先配置本服的 HTTPS 接口地址")
            return
        end
        authenticate(base, name, pwd, registering, false, profile)
    end

    primary = texture(panel, common .. "btn_7.png", 282, 63, panelWidth / 2, 88,
                      cc.rect(38, 20, 123, 26))
    primary:setCascadeOpacityEnabled(true)
    primaryText = label(primary, "", 29, 141, 34)
    primaryText:enableOutline(cc.c4b(153, 77, 8, 255), 2)
    onTap(primary, submit)
    switchButton, switchText = textAction(panel, "", 206, panelWidth / 2, 31,
                                         function() setMode(not registering) end)
    profileButton = textAction(panel, "昵称 / 头像", 130, 475, 31, function()
        local details = require("hall.login.LoginRegView").new(true)
        details.Button_tab1:setVisible(false)
        details.Register_phone:setString(username:getText())
        details.Register_password:setString(password:getText())
        details.Register_name:setString("新玩家")
        details.submitPhoneProfile = function(phone, pwd, profile)
            username:setText(phone)
            password:setText(pwd)
            nameHint:setVisible(phone == "")
            passHint:setVisible(pwd == "")
            details:removeFromParent()
            submit(profile)
        end
        overlay:addChild(details, 20)
    end)
    changeLink=textAction(panel,"修改密码",126,108,31,function() manage(false) end)
    forgotLink=textAction(panel,"忘记密码",126,484,31,function() manage(true) end)
    setMode(startWithRegistration)
end

local function accountAction(sprite, caption, startX, width, textX, fontSize, activate)
    local hit = ccui.Layout:create()
    hit:setContentSize(cc.size(width, 85))
    hit:setPosition(startX, 0)
    hit:setTouchEnabled(true)
    sprite:addChild(hit)
    local title = label(hit, caption, fontSize, textX, 44)
    title:enableOutline(cc.c4b(15, 65, 111, 255), 2)
    hit:addTouchEventListener(function(_, event)
        if event == ccui.TouchEventType.began then
            sprite:setColor(cc.c3b(207, 225, 242))
        elseif event == ccui.TouchEventType.canceled or event == ccui.TouchEventType.ended then
            sprite:setColor(cc.c3b(255, 255, 255))
            if event == ccui.TouchEventType.ended then activate() end
        end
    end)
end

function M.attach(layer)
    local phone, wechat = layer.btnPhone, layer.btnLogin
    local x = (phone:getPositionX() + wechat:getPositionX()) / 2
    local y = (phone:getPositionY() + wechat:getPositionY()) / 2
    local entry = cc.Sprite:create("hall/res/login/image/account-entry.png")
    phone:getParent():addChild(entry)
    -- Use the same scale and baseline as the two buttons from the scene file.
    entry:setScaleX(phone:getScaleX())
    entry:setScaleY(phone:getScaleY())
    entry:setPosition(x, y)
    phone:setVisible(false)
    phone:setTouchEnabled(false)
    local accountWidth = entry:getContentSize().width * entry:getScaleX()
    local wechatWidth = wechat:getContentSize().width * wechat:getScaleX()
    local gap = 32 * entry:getScaleX()
    wechat:setPosition(x - (accountWidth + gap) / 2, y)
    entry:setPosition(x + (wechatWidth + gap) / 2, y)

    local separator = box(entry, 2, 37, 232, 43, cc.c3b(230, 248, 255))
    separator:setBackGroundColorOpacity(155)
    accountAction(entry, "账号登录", 0, 232, 154, 27, function() open(layer, entry, false) end)
    accountAction(entry, "注册", 232, 80, 39, 27, function() open(layer, entry, true) end)
end

return M
