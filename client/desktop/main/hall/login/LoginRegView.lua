--登录注册界面
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local LoginRegView = class("LoginRegView", NewViewBaseLayer)

function LoginRegView:ctor()
    LoginRegView.super.ctor(self, "hall/res/login/LoginRegView.csb")
    -- self:registerScriptHandler(
    --     function(state)
    --         if state == "enter" then
    --             self:onEnter()
    --         elseif state == "exit" then
    --             self:onExit()
    --         -- elseif state == "enterTransitionFinish" then
    --         --     self:onEnterTransitionFinish()
    --         -- elseif state == "exitTransitionStart" then
    --         --     self:onExitTransitionStart()
    --         -- elseif state == "cleanup" then
    --         --     self:onCleanup()
    --         end
    --     end
    -- )

    self:initData()
    self:initUI()
    self:bindButton()
    self:initCache()
    HeadImgUpLoadOK = GameEvent:addListen("HeadImgUpLoadOK", handler(self, self.onUploadOK))
end

function LoginRegView:onEnter()
    print("onEnter -----------------------------")
    -- HeadImgUpLoadOK = GameEvent:addListen("HeadImgUpLoadOK", handler(self, self.onUploadOK))
end

function LoginRegView:onExit()
    -- GameEvent:delListen(self.event1)
end

function LoginRegView:initData()
    self.login_phone = 0
    self.login_pwd = ""
    self.is_keep_pwd = false

    self.register_name = ""
    self.register_phone = 0
    self.register_pwd = ""
    self.register_sex = 2 --1男，2女
    self.register_head = ""
end

function LoginRegView:initUI()
    -- 手动绑定一下头像控件，确保能正确访问
    if self.HeadImage then
        print("initUI - HeadImage 已绑定")
        local size = self.HeadImage:getContentSize()
        print("头像初始大小：", size.width, size.height)
    end
end

function LoginRegView:bindButton()
    local function addTouchListener(btn, callback)
        if btn then
            btn:addTouchEventListener(function(sender, event)
                if event == TOUCH_EVENT_BEGAN then
                    sender:setScale(0.9)
                elseif event == TOUCH_EVENT_CANCELED then
                    sender:setScale(1)
                elseif event == TOUCH_EVENT_ENDED then
                    sender:setScale(1)
                    if callback then
                        callback(self, sender)
                    end
                end
            end)
        end
    end

    addTouchListener(self.close_btn, self.onClose)
    addTouchListener(self.Button_login, self.onLogin)
    addTouchListener(self.Button_tab1, self.onSwitch)
    addTouchListener(self.Button_tab2, self.onSwitch)
    addTouchListener(self.Button_remember, self.onRemember)
    addTouchListener(self.Button_upload, self.onUpload)
    addTouchListener(self.Button_register, self.onRegister)
    addTouchListener(self.Button_girl, self.onGirl)
    addTouchListener(self.Button_boy, self.onBoy)
end

function LoginRegView:initCache()
    self:switchPanel("login")
    self.is_keep_pwd = cc.UserDefault:getInstance():getBoolForKey("is_login_keep_pwd", false)
    self:updateRememberBtn()
    if self.is_keep_pwd then
        self.login_phone = tonumber(cc.UserDefault:getInstance():getStringForKey("login_phone_in_local", "0"))
        self.login_pwd = cc.UserDefault:getInstance():getStringForKey("login_pwd_in_local", "")
        if self.login_phone ~= 0 then
            self.TextField_phone:setString(self.login_phone)
            if self.login_pwd ~= "" then
                self.TextField_password:setString(self.login_pwd)
            end
        end
    end
    print("self.is_keep_pwd, self.login_phone, self.login_pwd", self.is_keep_pwd, self.login_phone, self.login_pwd)
end

function LoginRegView:switchPanel(name)
    if name == "login" then
        self.Panel_register:setVisible(false)
        self.Panel_login:setVisible(true)
        self.Button_tab1:getChildByName("normal"):setVisible(false)
        self.Button_tab1:getChildByName("select"):setVisible(true)
        self.Button_tab2:getChildByName("normal"):setVisible(true)
        self.Button_tab2:getChildByName("select"):setVisible(false)
    else
        self.Panel_register:setVisible(true)
        self.Panel_login:setVisible(false)
        self.Button_tab1:getChildByName("normal"):setVisible(true)
        self.Button_tab1:getChildByName("select"):setVisible(false)
        self.Button_tab2:getChildByName("normal"):setVisible(false)
        self.Button_tab2:getChildByName("select"):setVisible(true)
    end
end

function LoginRegView:onSwitch(sender, event)
    if sender:getName() == "Button_tab1" then
        self:switchPanel("login")
    else
        self:switchPanel("register")
    end
end

function LoginRegView:onRegister()
    -- do GameEvent:dispatch("HeadImgUpLoadOK", "hall/res/login/new_login/radio2.png") return end
    self.register_name = self.Register_name:getString()
    self.register_phone = self.Register_phone:getString()
    self.register_pwd = self.Register_password:getString()
    
    -- 验证昵称
    if self.register_name == "" then
        require("hall.tool.viewManager"):showTip({text = "请输入用户名！"})
        return
    end
    
    -- 验证手机号
    if (self:checkPhone(self.register_phone) ~= true) then
        require("hall.tool.viewManager"):showTip({text = "请输入手机号码！"})
        return
    end
    
    -- 验证密码
    if self.register_pwd == "" then
        require("hall.tool.viewManager"):showTip({text = "请输入密码！"})
        return
    end
    
    -- 验证头像
    -- if self.register_head == "" then
    --     require("hall.tool.viewManager"):showTip({text = "请上传头像！"})
    --     return
    -- end
    
    -- 发送注册请求
    local register_data = {
        url = HttpAddr .. "/playerUser/quickRegisterByPhone",
        date = {
            nickname = self.register_name, 
            phone = self.register_phone, 
            passWord = self.register_pwd, 
            sex = self.register_sex, 
            photo = self.register_head
        },
        type_ = "POST",
        requestMsg = "用户手机注册",
        callBack = handler(self, self.registerResp)
    }
    dump(register_data, "register_data")
    cct.createHttRq(register_data)
end

function LoginRegView:registerResp(resp)
    require(NetworkLoadingView_filePath):removeView()

    local netData = json.decode(resp.netData)
    dump(netData, "register_resp")

    if netData.returnCode == "0" then
        local function afterCaptured(succeed, sp_png)
            if succeed then
                print("截屏success", sp_png)
            end
        end
        cc.utils:captureScreen(afterCaptured, "user_save_register.png")   

        local cbAction1 = cc.CallFunc:create(function() 
            require("hall.tool.viewManager"):showTip({text = "注册成功"})
        end)

        local cbAction2 = cc.CallFunc:create(function() 
            self:switchPanel("login")
            self.TextField_phone:setString(self.register_phone)
            self.TextField_password:setString(self.register_pwd)
            if not self.is_keep_pwd  then
                self:onRemember()
            end
        end)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cbAction1, cc.DelayTime:create(1), cbAction2))
    else
        local data = {type = 1, title = "提示", content = netData.error or "未知注册失败"}
        require(CommonTips_filePath):showTips(data)
    end
end

function LoginRegView:onUpload()
    print("点击上传头像")
    if device.platform == "windows" then
        print("Windows平台：模拟上传头像")
        -- Windows下模拟上传头像成功，用专门的head.png
        local fakeData = {
            url = "hall/res/login/new_login/head.png",
            localFilePath = "hall/res/login/new_login/head.png"
        }
        self:onUploadOK(fakeData)
    else
        cct.getDateForApp("openAlbum", {}, "V")
    end
end

function LoginRegView:onUploadOK(data)
    self.register_head = data.url
    dump(data, "=======onUploadOK=====")
    
    if device.platform == "windows" then
        -- Windows平台直接显示本地图片
        if self.HeadImage then
            print("显示头像：", data.localFilePath)
            -- 直接用ImageView的方式加载
            self.HeadImage:loadTexture(data.localFilePath)
            self.HeadImage:setVisible(true)
            self.HeadImage:setOpacity(255)
            print("头像已设置完成")
        end
    else
        -- 移动端正常使用getUserHead
        local common = require("hall.GameCommon")
        common:getUserHead(data.url, "", self.register_sex, self.HeadImage, 130, false, "")
    end
end

function LoginRegView:onGirl()
    self.register_sex = 2
    self.Button_girl:loadTextureNormal("hall/res/login/new_login/radio2.png", 0)
    self.Button_boy:loadTextureNormal("hall/res/login/new_login/radio1.png", 0)
end

function LoginRegView:onBoy()
    self.register_sex = 1
    self.Button_girl:loadTextureNormal("hall/res/login/new_login/radio1.png", 0)
    self.Button_boy:loadTextureNormal("hall/res/login/new_login/radio2.png", 0)
end

function LoginRegView:onRemember()
    self.is_keep_pwd = not self.is_keep_pwd
    cc.UserDefault:getInstance():setBoolForKey("is_login_keep_pwd", self.is_keep_pwd)
    self:updateRememberBtn()
end

function LoginRegView:updateRememberBtn()
    local res = "hall/res/login/new_login/radio1.png"
    if self.is_keep_pwd then
        res = "hall/res/login/new_login/radio2.png"
    end
    self.Button_remember:loadTextureNormal(res, 0)
end

function LoginRegView:onLogin(sender)
    local phone = self.TextField_phone:getString()
    if (self:checkPhone(phone) ~= true) then
        return
    end

    local pwd = self.TextField_password:getString()
    if pwd == "" then
        return
    end

    require(NetworkLoadingView_filePath):showLoading("正在登入")

    self.login_phone = phone
    self.login_pwd = pwd
    
    -- 保存记住密码的状态
    if self.is_keep_pwd then
        cc.UserDefault:getInstance():setStringForKey("login_phone_in_local", tostring(self.login_phone))
        cc.UserDefault:getInstance():setStringForKey("login_pwd_in_local", self.login_pwd)
    else
        cc.UserDefault:getInstance():setStringForKey("login_phone_in_local", "0")
        cc.UserDefault:getInstance():setStringForKey("login_pwd_in_local", "")
    end
    
    -- ========================================
    -- 登录方式选择：
    -- 方式1：使用HTTP登录（当前使用）
    -- 方式2：使用原生SDK登录（已注释）
    -- ========================================
    
    -- 方式1：HTTP登录
    if self.login_pwd ~= pwd then
        self.login_pwd = crypto.md5(pwd, false)
    end

    local dev = 0 --0:IOS;1：ANDROID;2：PC;3：其他
    if device.platform == "ios" then
        dev = 0
    elseif device.platform == "android" then
        dev = 1
    elseif device.platform == "windows" then
        dev = 2
    else
        dev = 3
    end

    local login_data = {
        url = HttpAddr .. "/userLogin",
        date = {phone = self.login_phone, password = self.login_pwd, device = dev},
        type_ = "POST",
        requestMsg = "用户登陆",
        callBack = handler(self, self.loginResp)
    }

    dump(login_data, "login_data")
    cct.createHttRq(login_data)
    
    --[[
    -- 方式2：原生SDK登录（取消注释启用）
    local arr = {}
    if device.platform == "android" then
        arr = {self.login_phone, self.login_pwd}
    else
        arr["phone"] = self.login_phone
        arr["password"] = self.login_pwd
    end
    cct.getDateForApp("loginWithPhone", arr, "V")
    --]]
end

function LoginRegView:loginResp(resp)
    print("===== LoginRegView:loginResp 被调用 =====")
    require(NetworkLoadingView_filePath):removeView()
    local netData = json.decode(resp.netData)
    dump(netData, "login_resp")

    if netData.returnCode == "0" then
        print("===== 登录验证成功，开始处理 =====")
        -- 保存登录信息
        local data = netData.data
        USER_INFO = USER_INFO or {}
        USER_INFO["uid"] = tonumber(data.userId)
        USER_INFO["token"] = data.token
        USER_INFO["account"] = data.account
        USER_INFO["phone"] = data.phone
        USER_INFO["coinAmount"] = data.coinAmount or 0
        USER_INFO["cardCount"] = data.cardCount or 0
        USER_INFO["jewelAmount"] = data.jewelAmount or 0
        USER_INFO["wealth"] = data.wealth or 0
        -- 服务器返回的数据中没有这些字段，使用默认值
        USER_INFO["nick"] = "玩家" .. USER_INFO["uid"]
        USER_INFO["sex"] = 1
        USER_INFO["icon_url"] = ""
        USER_INFO["level"] = data.level or 0
        
        -- 同时更新 UID
        UID = USER_INFO["uid"]
        
        -- 设置 user_info 字段（这是登录大厅需要的）
        local user_info = {
            level = USER_INFO["level"],
            nickName = USER_INFO["nick"],
            photoUrl = USER_INFO["icon_url"],
            sex = USER_INFO["sex"],
            money = USER_INFO["coinAmount"]
        }
        USER_INFO["user_info"] = json.encode(user_info)
        
        print("===== 设置 USER_INFO.user_info =====", USER_INFO["user_info"])
        dump(USER_INFO, "完整的USER_INFO:")
        
        -- 保存到本地
        if self.is_keep_pwd then
            cc.UserDefault:getInstance():setStringForKey("login_phone_in_local", tostring(self.login_phone))
            cc.UserDefault:getInstance():setStringForKey("login_pwd_in_local", self.login_pwd)
        else
            cc.UserDefault:getInstance():setStringForKey("login_phone_in_local", "0")
            cc.UserDefault:getInstance():setStringForKey("login_pwd_in_local", "")
        end
        
        -- 保存全局 token
        token = data.token
        
        print("===== 登录成功，保存用户信息：uid=", USER_INFO["uid"], "token=", USER_INFO["token"])
        
        -- 先获取父节点（应该是LoginLayer）
        local parent = self:getParent()
        print("===== 当前父节点 =====", parent)
        
        -- 移除自己
        self:retain()
        self:removeFromParent()
        
        -- 移除父节点（LoginLayer）
        if parent then
            print("===== 移除父节点 LoginLayer =====")
            parent:removeFromParent()
        end
        
        -- 额外检查，确保移除所有loginLayer
        if SCENENOW and SCENENOW["scene"] then
            local loginLayer = SCENENOW["scene"]:getChildByName("loginLayer")
            if loginLayer then
                print("===== 额外移除 LoginLayer =====")
                loginLayer:removeFromParent()
            end
        end
        
        self:release()
        
        -- 切换到大厅场景
        print("===== 开始切换到大厅场景 =====")
        display_scene("hall.hallScene", 1)
        print("===== 场景切换调用完成 =====")
    else
        local data = {type = 1, title = "提示", content = netData.error or "未知登录失败"}
        require(CommonTips_filePath):showTips(data)
    end
end

--手机号验证
function LoginRegView:checkPhone(var)
    local b = tonumber(var)

    if (b == nil) then
        return false
    end

    if (#var ~= 11) then
        require("hall.tool.viewManager"):showTip({text = "请输入11位手机号码！"})
        return false
    end

    return true
end

function LoginRegView:onClose(sender)
    self:removeFromParent()
end

return LoginRegView
