--[[
* author:   zwm
* date:     2019-03-11
* describe: 大厅主界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local FamilyData = require("hall.familyCircle.FamilyData")
local FamilyMainLayer = require("hall.familyCircle.FamilyMainLayer")
local ViewBaseLayer = require("hall.ViewBaseLayer")
local HallMainLayer = class("HallMainLayer", ViewBaseLayer)
local CocosUtil = require("hall.util.CocosUtil")
local FamilyCreateTip = require("hall.familyCircle.FamilyCreateTip")
local ItremGame = require("hall.ItremGame")
local addNumber = require("hall.familyCircle.addNumber")

-- local phoneBind = require("hall.phoneBind")

local EVENTNAME = {
	SELECT_PLAYER_GROUP = "/selectPlayerGroup",
    APPLY_FOR_JOIN_PLAYER_GROUP = "/applyForJoinPlayerGroup",
    UPDATE_APPLY_FOR_STATUS = "/updateApplyForStatus",
	GET_MSG_FOR_PLAYER_GROUP = "/getMsgForplayerGroup",

}

function HallMainLayer:ctor()
    print("EVENTNAME",EVENTNAME.SELECT_PLAYER_GROUP)
    ReqMgr:addHandle("HallMainLayer", EVENTNAME)
    -- display.addSpriteFrames("hallMainLayer.plist","hallMainLayer.png")
    HallMainLayer.super.ctor(self, "hall/res/hallMain/hallMainLayer.csb")
    --if device.platform ~= "windows" then
    --    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_DESIGN_WIDTH, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.FIXED_HEIGHT)--cc.ResolutionPolicy.SHOW_ALL//FIXED_WIDTH
    --    local scaleY=CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT
    --    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH/scaleY, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc.ResolutionPolicy.SHOW_ALL
    --    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_DESIGN_WIDTH, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.EXACT_FIT)--cc.ResolutionPolicy.SHOW_ALL
    --    print("MainScene:onEnter() ----------------------------", CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT)
    --else
    --    if device.platform=="android" then
    --
    --        local share_content = {}
    --        table.insert(share_content,1)
    --        cct.getDateForApp("changeOrientation", share_content, "V")
    --
    --    else
    --
    --    end
    --    local scaleY=CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT
    --    cc.Director:getInstance():getOpenGLView():setFrameSize(CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT)
    --    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH/scaleY, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc.ResolutionPolicy.SHOW_ALL
    --end

    self:setUserInfo()
    self:loadSubGame()
    self:loadClub()
    self._curData = nil
    g_hallMainLayer = self
    self:showAllAni()
    self:setScaleByNode(self.bottomBg)

    --add by zzy hide 2019-7-29
    self.btnYaoQing:setVisible(false)
    self.btnHongBao:setVisible(false)
    self.btnRenZheng:setVisible(false)
    self.btnErWeiMa:setVisible(false)
    dump(USER_INFO["hasReceiveRegisterBonus"],"USER_INFO[hasReceiveRegisterBonus]")

    print(0x16,"00888888")

    if USER_INFO["msgCount"] and USER_INFO["msgCount"] >= 1 then
        self.btnMsgRed:setVisible(true)
    else
        self.btnMsgRed:setVisible(false)
    end
    self.club_more:setVisible(false)

    self.datas = {}
    self.page = 0
    self.txt_page:setString("0/0")
    self.PageView_1:addEventListenerPageView(function (e,v)
        local getCurrentPageIndex = self.PageView_1:getCurrentPageIndex() + 1
        self.txt_page:setString(getCurrentPageIndex.."/"..self.page)
    end)
    self.item:hide()
    self.btn_mj.level = 308
    self.btn_niu.level = 368
    self.btn_sg.level = 360
    self.btn_sss.level = 365
    self.btn_pdk.level = 325
    self.btn_mj:onClick(handler(self, self.onClickBtn), true)
    self.btn_niu:onClick(handler(self, self.onClickBtn), true)
    self.btn_sg:onClick(handler(self, self.onClickBtn), true)
    self.btn_sss:onClick(handler(self, self.onClickBtn), true)
    self.btn_pdk:onClick(handler(self, self.onClickBtn), true)
end

function HallMainLayer:onClickBtn(event)
    local level = event.target.level
    local idx = self.PageView_1:getCurrentPageIndex() + 1
    if idx < 1 then
        idx = 1
    end
    local data = self.datas[idx]
    if data == nil then
        viewMgr:showTip({text = "请先加入联盟！"})
        return
    end
    self.familyMainlayer = FamilyMainLayer.new(data , self, level):addTo(self)
    USER_INFO["family_data"] = data
    FamilyData:SetFamilyId(data.key)
    cc.UserDefault:getInstance():setStringForKey("clubCode", data.key)
end

function HallMainLayer:setItem(key, data, item)
    GameUtils.setNodeNameBindObj(item)
    dump(data,"self.clubList")
    local partner_top = item.partner_top
    if data.roleType == 0 then
        item.txt_sf:setString("身份：盟主")
        partner_top:setVisible(true)
        partner_top:loadTexture("hall/res/hallMain/image/club_create_img.png")
    elseif data.roleType ==2 then
        item.txt_sf:setString("身份：合伙人")
        partner_top:setVisible(true)
    elseif data.roleType ==1 then
        item.txt_sf:setString("身份：管理员")
        partner_top:setVisible(false)
    elseif data.roleType ==3 then
        item.txt_sf:setString("身份：普通人员")
        partner_top:setVisible(false)
    end
    if data.isManager == 1 then
        item.txt_sf:setString("身份：管理员")
        partner_top:setVisible(false)
        partner_top:loadTexture("hall/res/hallMain/image/icon_3.png")
    end
    if data.isManager == 1 and data.roleType ~= 0 then
        partner_top:loadTexture("hall/res/hallMain/image/icon_3.png")
        partner_top:setVisible(true)
    end

    item.txt_name:setString(require("hall.GameCommon"):formatNick(data.groupName,5))
    item.txt_yqm:setString(data.clubCode)
    local playerCount = hallFamilyPlayerNum or data.playerCount
    item.txt_rs:setString("总人数："..playerCount)
    item.txt_qb:setString("钱包："..data.jifenCount / 100)
    local userHead = item.img_club_one
    require("hall.GameCommon"):getUserHead(data.owerUrl, "", "", userHead, 85 , false, "", true)
    data.key = key
    item.data = data
    item:onClick(function(event)
        local target = event.target
        local data = target.data
        local key = data.key
        self.familyMainlayer = FamilyMainLayer.new(data , self):addTo(self)
        USER_INFO["family_data"] = data
        FamilyData:SetFamilyId(key)
        cc.UserDefault:getInstance():setStringForKey("clubCode", key)
    end)
    table.insert(self.datas, data)
end

function HallMainLayer:setContentSizeByNode( _node )
    --部分适配修复
    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    dump(SCREEN_WIDTH,"SCREE888N_WIDTH")
    local size = _node:getContentSize()
    local precent = SCREEN_WIDTH/1280
    _node:setContentSize(cc.size(size.width * precent, size.height))
end
--add by zzy 2019-7-10
function HallMainLayer:setScaleByNode( _node )
    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    local precent = SCREEN_WIDTH/1280
    _node:setScaleX(precent)
end
function HallMainLayer:setUserInfo()
    self.glod:setString(USER_INFO["cardCount"] or "0")
    self.userID:setString("ID: "..(USER_INFO["uid"] or "0"))

    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"], 3)
    self.userName:setString(strNick or "")

    require("hall.GameCommon"):getUserHead(USER_INFO.icon_url, USER_INFO["uid"], USER_INFO["sex"], self.headImg, 69, false, USER_INFO["nick"])
end

function HallMainLayer:updateGold()
    self.glod:setString(require(NumberUtil_filePath):toWan(USER_INFO["cardCount"], 99999))
end

function HallMainLayer:showAllAni()
    --self:showFXBAni()
    -- self:showShopAni()

    --走马灯
    package.loaded["hall.scene.hall.BraodComponent"] = nil
    -- self.braodPlane:setPositionX(41)
    require("hall.scene.hall.BraodComponent"):showBraod(self.braodPlane)
    self:showBroadcast()
end

--显示走马灯广播
function HallMainLayer:showBroadcast()
    if not isiOSVerify then
        if STATUS_GAME then
            return
        end
        if braodComponentDefaulMessage_hall and braodComponentDefaulMessage_hall ~= "" then
            require("hall.scene.hall.BraodComponent"):setDefaultBraodMessage(braodComponentDefaulMessage_hall)
        end
    end
end

function HallMainLayer:showFXBAni()
    local atlasPath = "hall/res/hallMain/ani/fuxiangbi/aniFXB.plist"
    local ani = require("hall.util.CocosUtil"):playAnimation(atlasPath, "aniFXB", 25, -1, 4/25) --require("hall.util.CocosUtil")
    if ani then
        self.glodAni:runAction(ani)--
    end
end

function HallMainLayer:showShopAni()
    local atlasPath = "hall/res/shop/image/shopAni.plist"
    local ani = require("hall.util.CocosUtil"):playAnimation(atlasPath, "shopAni_", 21, -1, 4/21, 0) --require("hall.util.CocosUtil")
    --print("HallMainLayer:showFXBAni() --------------------------------", ani == nil)
    if ani then
        self.shopAni:runAction(ani)--
    end
end

function HallMainLayer:loadSubGame()
    self.GameListView:removeAllChildren()
    self.GameListView:setScrollBarEnabled(false)
    ItremGame.new(self.GameListView,self.gameItem)

    --self.subGameLayer = require("hall.HallGameLayer").new(self)
    --if self.subGameLayer then
    --    self.subGameLayer:addTo(self.gamesNode)
    --    --local pY = self.subGameLayer:getPositionY()
    --    --self.subGameLayer:setPositionY(pY+30)
    --end
end

function HallMainLayer:onClickBtnQingyouquan(sender, event)
    if self.familyCreateLayer then
        self.familyCreateLayer:setVisible(true)
        self.familyCreateLayer:InitGame()
    else
        self.familyCreateLayer = require("hall.familyCircle.FamilyCreateLayer").new()
        if self.familyCreateLayer then
            self.familyCreateLayer:setName("familyCreateLayer")
            self.familyCreateLayer:addTo(self)
        end 
    end
   
end

function HallMainLayer:onClickBtnCreatRoom(sender, event)
    self.createRoomLayer = require("hall.createAndEnterRoom.CreateRoomLayer").new(bm.gameList_forRoomCard)
    if self.createRoomLayer then
        self.createRoomLayer:addTo(self)
    end
end

function HallMainLayer:onClickBtnEnterRoom(sender, event)
    self.enterRoomLayer = require("hall.createAndEnterRoom.EnterRoomLayer").new()
    if self.enterRoomLayer then
        self.enterRoomLayer:addTo(self)
    end
end

function HallMainLayer:onClickBtnErWeiMa(sender, event)

end

function HallMainLayer:onClickBtnZhanJi(sender, event)
    --查看战绩分两种情况，第一种再大厅中，只显示玩家的个人战绩
    local recordLayer = require("hall.record.RecordLayer").new()
    if recordLayer then
        recordLayer:addTo(self)
    end
end

function HallMainLayer:onClickBtnWanFa(sender, event)
    local PlayerInstructionLayer = require("hall.playerInstruction.PlayerInstructionLayer").new()
    if PlayerInstructionLayer then
        PlayerInstructionLayer:addTo(self)
    end
end

function HallMainLayer:onClickBtnShare(sender, event)
    local paras = {}
    paras.showType = 1
    paras.name = appName
    paras.url = appDownLoadAddress
    paras.imagePath = "url"
    paras.desc = hallShareMessage

    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(self)
    end
end

function HallMainLayer:onClickBtnKeFu(sender, event)
    if OPEN_POP800_KeFuURL and #OPEN_POP800_KeFuURL >0  then
        cc.Application:getInstance():openURL(OPEN_POP800_KeFuURL)
    else
        if not isiOSVerify then
            local params = {}
            params["type"] = "4"
            cct.createHttRq({
                url = HttpAddr .. "/baseData/queryAnnouncements",
                date = params,
                type_="POST",
                requestMsg = "",
                isshowfailTip = false,
                callBack = function(data)
                    if STATUS_GAME then
                        return
                    end

                    local data_netData = json.decode(data["netData"])
                    if data_netData.returnCode == "0" then
                        local sData = data_netData.data
                        if table.getn(sData) > 0 and table.getn(sData[1]) > 0 then
                            local param = {}
                            param.type =  1
                            param.content = sData[1][1]["content"]
                            require("hall.tips.CommonTips"):showTips(param)
                            -- require("hall.scene.hall.BraodComponent"):setDefaultBraodMessage(sData[1][1]["content"])
                        end
                    end
                end
            })
        end
    end
end

function HallMainLayer:onClickBtnMsg(sender, event)
    local ReminderView = require("hall.familyCircle.ReminderView").new(self.family_id)
    if ReminderView then
        ReminderView:addTo(self)
    end
end

function HallMainLayer:onClickBtnSetting(sender, event)
    local enterRoomLayer = require("hall.setting.SettingLayer").new(true)
    if enterRoomLayer then
        enterRoomLayer:addTo(self)
    end
end

function HallMainLayer:onClickBtnShop(sender, event)
    if Shangcheng ==true then
        require("hall.shop.ShopLayer"):showShop()
    end
end


-- function HallMainLayer:FamilyJoinClub()
--     local data = {
--         playerId = USER_INFO["uid"] ,
--     }
--     ReqMgr:request(EVENTNAME.GET_MSG_FOR_PLAYER_GROUP, data, handler(self , self.getMsgForPlayerJoinGroup))
-- end


function HallMainLayer:getMsgForPlayerJoinGroup( event)
    local netData = event.netData
	local param = event.param
	local returnCode = netData.returnCode
	local data = netData.data
    local error = netData.error

end

function HallMainLayer:FamilyHelpTip()
    -- local typ = 5
    -- local data = {
    --     playerId = USER_INFO["uid"] ,
    --     status = typ ,
    -- }

    local data = {
        playerId = USER_INFO["uid"] ,
    }
    ReqMgr:request(EVENTNAME.GET_MSG_FOR_PLAYER_GROUP, data, handler(self , self.getMsgForPlayerGroup))
end

function HallMainLayer:getMsgForPlayerGroup( event)
    local netData = event.netData
	local param = event.param
	local returnCode = netData.returnCode
	local data = netData.data
    local error = netData.error


    local function ProcessData(data , func)
        -- local tail_data = data[#data]
        dump(data)
        local commtip_data =  {}
        commtip_data.type = 2
        commtip_data.title = "亲友圈"
        commtip_data.content = "你愿意进入" .. data.nickName .. "的亲友圈么"

        local function Sure(id)
             print("********************************3")
 
             local data = {
                 XYUid = USER_INFO["uid"],
                 msgId = id,
                 status = 6,
             }
             ReqMgr:request(EVENTNAME.UPDATE_APPLY_FOR_STATUS, data, handler(self , self.UPDATE_APPLY_FOR_STATUS))
 
        end
        local function Cancel(id)
             print("********************************4")
             print(parame1)
             
             local data = {
                XYUid = USER_INFO["uid"],
                msgId = id,
                status = 7,
            }
            ReqMgr:request(EVENTNAME.UPDATE_APPLY_FOR_STATUS, data, handler(self , self.UPDATE_APPLY_FOR_STATUS))
        end
        
        commtip_data.callBackSure = CocosUtil:Bind(Sure ,data.id)
        commtip_data.callBackCancel = CocosUtil:Bind(Cancel ,data.id)
        require("hall.tips.CommonTips"):showTips(commtip_data)
    end

    if returnCode == 0 and data and #data > 0 then
        ProcessData(data[#data])
    end
end

function HallMainLayer:UPDATE_APPLY_FOR_STATUS( event)
    local netData = event.netData
	local param = event.param
	local returnCode = netData.returnCode
	local data = netData.data
    local error = netData.error

    if returnCode == 0 then
        -- viewMgr:showTip({text = "操作成功"})
    end
end


--公告
function HallMainLayer:onClickBtnGongGao(sender, event)
    self.announcement = require("hall.announcement.announcement").new()
    if self.announcement then
        self.announcement:setName("announcement")
        self.announcement:addTo(self)
    end 
end

function HallMainLayer:onClickBtnRenZheng(sender, event)
end

function HallMainLayer:onClickBtnHongBao(sender, event)
end

function HallMainLayer:onClickBtnYaoQing(sender, event)
end

--function HallMainLayer:onClickBtnJLBLM(sender, event)
--end
--
--function HallMainLayer:onClickBtnKuaiSu(sender, event)
--end

function HallMainLayer:onClickBtnAddGlod(sender, event)
    if Shangcheng ==true then
        require("hall.shop.ShopLayer"):showShop()
    end
end

function HallMainLayer:initBtnSelect(id)
    for k,btn_select in pairs(self.btn_selects or {}) do
        btn_select:setTouchEnabled(true)
        -- btn_select:setColor(cc.c3b(255,255,255))
        btn_select.is_select:setVisible(false)
    end
    if id and self.btn_selects[id] then
        local btn_select = self.btn_selects[id]
        btn_select:setTouchEnabled(false)
        -- btn_select:setColor(cc.c3b(000,000,000))
        btn_select.is_select:setVisible(true)

        cc.UserDefault:getInstance():setStringForKey("clubCode", id)
        self._curData =  btn_select.data
        local curitem = btn_select:getParent()
        local cury = curitem:getPositionY()
        local maxY = 0
        local item
        for i,node in ipairs(self.ScrollView:getChildren()) do
            local y = node:getPositionY()
            if y > maxY then
                item = node
                maxY = y
            end
        end
        curitem:setPositionY(maxY)
        item:setPositionY(cury)
        self.ScrollView:jumpToTop()
    end
end

function HallMainLayer:getCurData()
   return self._curData or nil
end

function HallMainLayer:onClickBtnSelect(event)
    if event.name == "ended" then
        local target = event.target
        self:initBtnSelect(target.data.key)
    end
end

function HallMainLayer:onExit()
    if STATUS_GAME then
        if self.familyCreateLayer then
            self.familyCreateLayer:removeFromParent()
            self.familyCreateLayer = nil
        end
    end
    ReqMgr:delHandle("HallMainLayer", EVENTNAME)
    --g_hallMainLayer = nil
end

function HallMainLayer:loadClub()

    local params = {}
    params["playerId"] = USER_INFO['uid']
    
    ReqMgr:request(EVENTNAME.SELECT_PLAYER_GROUP, params, handler(self, self.select_player_group), nil, nil, false)
    self._curData = nil
     --cct.createHttRq({
     --    url = HttpAddr .. "/selectPlayerGroup",
     --    date = params,
     --    type_="POST",
     --    requestMsg = "",
     --    isshowfailTip = false,
     --    callBack = function(data)
     --        if STATUS_GAME then
     --            return
     --        end
     --        local data_netData = json.decode(data["netData"])
     --        dump(data_netData,"0000000sData")
     --        if data_netData.returnCode == "0" then
     --            local sData = data_netData.data
     --
     --            if table.nums(sData) == 0 then
     --                if  self.showLeftBtnClub1 then
     --                    self:showLeftBtnClub1()
     --                end
     --
     --            elseif  table.nums(sData) == 1 then
     --                if  self.showLeftClubOne then
     --                    self:showLeftClubOne(sData)
     --                end
     --
     --            else
     --                if  self.showLeftClubMore then
     --                    self:showLeftClubMore(sData)
     --                end
     --
     --            end
     --            --self:showLeftClubOne(sData)
     --        end
     --    end
     --})

end

function HallMainLayer:select_player_group(event)
    if STATUS_GAME then
        return
    end
    local netData = event.netData
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error

    -- local data_netData = json.decode(data["netData"])
    if returnCode == 0 then
        self.configData = data
        if table.nums(data) == 0 then
            if self.showLeftBtnClub1 then
                self:showLeftBtnClub1()
            end
        -- elseif  table.nums(data) == 1 then
        --     if self.showLeftClubOne then
        --         self:showLeftClubOne(data)
        --     end
        else
            if self.showLeftClubMore then
                self:showLeftClubMore(data)
            end
        end
    else
        viewMgr:showTip({text = error})
    end
end

function HallMainLayer:createRoom()
    local this = self
    if self.clubLimit == 1 then
        FamilyCreateTip.new(self):addTo(self)
    else
        local function callback(returnCode, data, error)
            if returnCode == 0 then
                dump (data, "角色信息----------")
                local clubLimit = data.playerProfile.clubLimit
                if clubLimit == 1 then
                    this.clubLimit = clubLimit
                    FamilyCreateTip.new(self):addTo(self)
                else
                    viewMgr:showTip({text = "您未获取创建联盟权限！"})
                end
            else
                viewMgr:showTip({text = error})
            end
        end
        local data = {userId = USER_INFO["uid"]}
        require("hall.view.clubView.clubSendData"):RequestGetRoleInfo(data, callback)
    end
end

--显示没人的
function HallMainLayer:showLeftBtnClub1()
    do
        self.leftbtnClub1:setVisible(false)
        self.club_one:setVisible(false)
        self.club_more:setVisible(false)
        self.leftbtnClub2:setVisible(true)
        self:bindCreateJoinBtn()
        return
    end

    self.leftbtnClub1:setVisible(true)

    self.bt_create_club:onClick(function (sender,event)
            self:createRoom()
    end,true)

    self.bt_join_club:onClick(function (sender,event)
            self:addNumber()
    end,true)

    self:hideLeftBtnClub2()

end
---显示多个人
function HallMainLayer:showLeftClubMore(sData)
    self.leftbtnClub2:setVisible(true)
    self:bindCreateJoinBtn()
    -- self.club_more:setVisible(true);
    self:hideLeftBtnClub1()
    self:hideClubOne()
    self:initClubMore(sData)
end
function HallMainLayer:initClubOne(sData)
    for key,value in pairs(sData) do
        local data = json.decode(value)
        dump(data,"self.clubList")
        local partner_top = self.club_one:getChildByName("partner_top")
        if data.roleType == 0 then
            self.club_one:getChildByName("rank_club_2"):setString("盟主")
            partner_top:setVisible(true)
            partner_top:loadTexture("hall/res/hallMain/image/club_create_img.png")
        elseif data.roleType ==2 then
            self.club_one:getChildByName("rank_club_2"):setString("合伙人")
            partner_top:setVisible(true)
        elseif data.roleType ==1 then
            self.club_one:getChildByName("rank_club_2"):setString("管理员")
            partner_top:setVisible(false)
        elseif data.roleType ==3 then
            self.club_one:getChildByName("rank_club_2"):setString("普通人员")
            partner_top:setVisible(false)
        end
        if data.isManager == 1 then
            self.club_one:getChildByName("rank_club_2"):setString("管理员")
            partner_top:setVisible(false)
            partner_top:loadTexture("hall/res/hallMain/image/icon_3.png")
        end
        data.key = key
        self.club_one:getChildByName("name_club"):setString(require("hall.GameCommon"):formatNick(data.groupName,5))
        self.club_one:getChildByName("code_club_2"):setString(data.clubCode)
        local playerCount = hallFamilyPlayerNum or data.playerCount
        self.club_one:getChildByName("count_club_2"):setString(playerCount)
        local userHead = self.club_one:getChildByName("img_club_one")
        require("hall.GameCommon"):getUserHead(data.owerUrl, "", "", userHead, 85 , false, "", true)
        local function onTouchButton(sender,eventType)
            if sender then
                if eventType == ccui.TouchEventType.ended then
                    self.familyMainlayer = FamilyMainLayer.new(data , self):addTo(self)
                    USER_INFO["family_data"] = data
                    FamilyData:SetFamilyId(key)
                end
            end
        end
        self.club_one:getChildByName("bt_goto_club"):addTouchEventListener(onTouchButton)
        self._curData = data
        return
    end

end
function HallMainLayer:initClubMore(sData)
    local clubCode = cc.UserDefault:getInstance():getStringForKey("clubCode")
    self.PageView_1:removeAllPages()
    self.page = 0
    for key, value in pairs(sData) do
        local data = json.decode(value)
        self.page  = self.page + 1
        if clubCode == key then
            local item = self.item:clone():show()
            self.PageView_1:addPage(item)
            self:setItem( key, data, item )
        end
    end

    for key, value in pairs(sData) do
        local data = json.decode(value)
        if clubCode ~= key then
            local item = self.item:clone():show()
            self.PageView_1:addPage(item)
            self:setItem( key, data, item )
        end
    end

    local getCurrentPageIndex = 1
    self.txt_page:setString(getCurrentPageIndex.."/"..self.page)
    do
        return
    end
    self.ScrollView = self.club_more:getChildByName("ScrollView"):removeAllChildren()
    self.ScrollView:setScrollBarEnabled(false)

    self.btn_selects = {}
    local clubCode = cc.UserDefault:getInstance():getStringForKey("clubCode")
    local is = false

    local size_1 = self.club_item:getContentSize()
    local size_2 = self.ScrollView:getContentSize()
    local height = 0
    for key,value in pairs(sData) do
        if clubCode == key then is = true end
        height = height + size_1.height
    end
    if height < size_2.height then
        height = size_2.height
    end
    if is == false then clubCode = "" end
    local idx = 0
   
    self.ScrollView:setInnerContainerSize(cc.size(size_2.width, height))

    for key,value in pairs(sData) do
        local data = json.decode(value)
        data["key"]= key
        local item = self.club_item:clone()
        item:setVisible(true)
        GameUtils.setNodeNameBindObj(item)
        item:getChildByName("club_name"):setString(require("hall.GameCommon"):formatNick(data.groupName,5))
        item:getChildByName("club_code_2"):setString(data.clubCode)
        item:getChildByName("partner_top_more"):setVisible(false)
        local playerCount = hallFamilyPlayerNum or data.playerCount
        item:getChildByName("count_club"):setString("联盟人数:"..playerCount)
        if data.roleType == 0 then
            item:getChildByName("partner_top_more"):setVisible(true)
            item:getChildByName("partner_top_more"):loadTexture("hall/res/hallMain/image/club_create_img.png")
        elseif data.roleType ==2 then
            item:getChildByName("partner_top_more"):loadTexture("hall/res/hallMain/image/partner_top.png")
            item:getChildByName("partner_top_more"):setVisible(true)
        elseif data.roleType ==1 then

            item:getChildByName("partner_top_more"):setVisible(false)
        elseif data.roleType ==3 then
            item:getChildByName("partner_top_more"):setVisible(false)
        end
        --优先显示盟主
        if data.isManager == 1 and data.roleType ~= 0 then
            item:getChildByName("partner_top_more"):loadTexture("hall/res/hallMain/image/icon_3.png")
            item:getChildByName("partner_top_more"):setVisible(true)
        end
        require("hall.GameCommon"):getUserHead(data.owerUrl, "", "", item:getChildByName("img_club_more"), 96 , false, "", true)
        local function onTouchButton(sender,eventType)
            if sender then
                if eventType == ccui.TouchEventType.ended then

                        self.familyMainlayer = FamilyMainLayer.new(data, self):addTo(self)
                    USER_INFO["family_data"] = data
                    FamilyData:SetFamilyId(data.key)
                end
            end
        end
        item:addTouchEventListener(onTouchButton)

        self.ScrollView:addChild(item)
        local initY = height - size_1.height
        local y = initY - idx  * size_1.height
        idx = idx + 1
        item:setPosition(cc.p(0, y))

        item.btn_select.data = data
        item.btn_select:onClick(handler(self, self.onClickBtnSelect))
        self.btn_selects[key] = item.btn_select
        -- dump(cc.UserDefault:getInstance():getStringForKey("clubCode"))
        if not clubCode or clubCode == "" or clubCode == nil then
            clubCode = key
        end
    end

    self:initBtnSelect(clubCode)
end

function HallMainLayer:bindCreateJoinBtn()
    self.bt_create_club:onClick(function (sender,event)
            self:createRoom()
    end,true)

    self.bt_join_club:onClick(function (sender,event)
            self:addNumber()
    end,true)
end

---显示单个人的
function HallMainLayer:showLeftClubOne(data)
    self.leftbtnClub2:setVisible(true)
    self.club_one:setVisible(false);
    
    self:bindCreateJoinBtn()
    self:hideLeftBtnClub1()
    self:hideClubMore()
    self:initClubOne(data)
end
function HallMainLayer:hideLeftBtnClub2()
    self.leftbtnClub2:setVisible(false)
end
function HallMainLayer:hideLeftBtnClub1()
    self.leftbtnClub1:setVisible(false)
end
function HallMainLayer:hideClubMore()
    self.club_more:setVisible(false)
end
function HallMainLayer:hideClubOne()
    self.club_one:setVisible(false)
end

function HallMainLayer:InvitePlayer(callData)
    print(callData,"======InvitePlayer======")
    local number = callData.number
    if not number then
        viewMgr:showTip({text = "操作失败！"})
        return
    end
    local data = {
        playerId = USER_INFO.uid,
        inviteCode = number,
    }
    ReqMgr:request(EVENTNAME.APPLY_FOR_JOIN_PLAYER_GROUP, data, handler(self , self.APPLY_FOR_JOIN_PLAYER_GROUP))
end

function HallMainLayer:APPLY_FOR_JOIN_PLAYER_GROUP(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if netData.returnCode == 0 then
        self:loadClub()
        viewMgr:showTip({text = "加入联盟成功！"})
    else
        viewMgr:showTip({text = error})
    end
end

function HallMainLayer:addNumber()
    local addNumber = addNumber.new(handler(self, self.InvitePlayer))
    self:addChild(addNumber)
end

function HallMainLayer:onChangeBg()
    local str = cc.UserDefault:getInstance():getIntegerForKey("GameBgType" .. USER_INFO["level"],1)
    -- self.bg:loadTexture("hall/res/hallMain/image/bg_"..str..".png")
end

--function HallMainLayer:onClickBtnPhone()
--    phoneBind.new():addTo(self)
--end
return HallMainLayer