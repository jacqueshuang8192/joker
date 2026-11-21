local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
local PROTOCOL = import(TpackageName..".handle.XLCHMJProtocol")
local sendHandle = require(TpackageName..".handle.XLCHMJSendHandle")
local receiveHandle = require(TpackageName..".handle.XLCHMJReceiveHandle")
local XLCHMJ_face=require("hall.FaceUI.faceUI")
local GPSShowLayer = require("hall.GPSShowLayer")
local cardUtils=require(TpackageName..".utils.cardUtils")
local Card = require(TpackageName.. ".2DMahjongCard.Card")

local XLCHMJScene = class("XLCHMJScene", function()
		return display:newScene()
    end)
    
function XLCHMJScene:setDefine( )
    TpackageName = "XLCH_majiang"
    GameName = "血流成河"
    G_game = {} --游戏内的全局变量 当游戏场景销毁时跟着销毁
    G_game.isYiMaQuanZhong = false
    G_game.isLaiZi = function (m_value)--是否是癞子
        if G_game and type(G_game.laiziCount) == "number" and m_value then
            local tabs = {
                [1] = {65},
                [2] = {65,67},
            }
            local tab = tabs[G_game.laiziCount] or {}
            for i,v in ipairs(tab) do
                if m_value == v then
                    return true
                end
            end
        end
        return false
    end
end

function XLCHMJScene:ctor()
    self:setDefine( )
    self:setNodeEventEnabled(true)
    require(TpackageName..".globle.XLCHMJData").new()

    require(TpackageName..".globle.XLCHMJDefine").new()
    D3_OPERATOR = require("hall.3DMahjongCard.ShowOperator")

    print("===========麻将的level打印！！！==============")
    print(USER_INFO["GroupLevel"])

    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    self.bg_select_index = 1
    self._scene = cc.CSLoader:createNode(TpackageName.."/res/GameScene/GameScene.csb"):addTo(self)
    GameUtils.setNodeNameBindObj(self._scene)
    self._scene.bg.titile_bg:ignoreContentAdaptWithSize(true)
    -- display.doLayout(nil, self._scene.bg)
    -- display.doLayout(self._scene.players)
    display.doLayout(self._scene.hall)

    local size = self._scene:getContentSize()
    DESIGN_SCREEN_WIDTH = size.width
    DESIGN_SCREEN_HEIGHT = size.height
    -- SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    -- SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    -- self._scene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)

    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getFrameSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getFrameSize().height
    local scaleY=SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT
    cc.Director:getInstance():getOpenGLView():setFrameSize(SCREEN_WIDTH, SCREEN_HEIGHT)
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(SCREEN_WIDTH/scaleY, DESIGN_SCREEN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc

	XLCHMJ_SCENE = self._scene
    self._hall = self._scene.hall
    
    self:_initUI()
    self:initEvent()
    self:setGameSetting()
    self:initSome()
    self:BtnSetClick()
    dump("XLCHMJ_SCENE",XLCHMJ_SCENE)
    local XLCHMJ_face_node = XLCHMJ_face.new();
    XLCHMJ_face_node:setHandle(sendHandle)
    self:addChild(XLCHMJ_face_node, 9999)
    XLCHMJ_face_node:setName("faceUI")


	XLCHMJ_CONTROLLER = require(TpackageName..".GameController")
    
    D3_OPERATOR:init(XLCHMJ_CONTROLLER,nil,nil,nil,XLCHMJ_SCENE.players)
	GamePlaneOperator:init()

    local device_info_plane = self._hall:getChildByName("device_info_plane")


    local btn_gameConfigMsg = self._hall:getChildByName("btn_gameConfigMsg")

    btn_gameConfigMsg:onClick(function(sender,event)
        if isOpenControl then
            sendHandle:CLI_REQ_TEST_CARDS()
        else
            -- 玩法介绍同意风格
            require("hall.util.GameMenu"):showConfigPanel(gameConfigTable)
        end
    end)
    self._hall.btn_menu:onClick(function(event)
        self:loadMoreFuncLayer()
    end)

    --邀请微信好友
    local btn_share = self._hall:getChildByName("btn_share")
    btn_share:setVisible(false)
    if isiOSVerify then
        btn_share:setVisible(false)
    end
    btn_share:onClick(function(event)
        local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
        local share_content = ""
        for k, v in pairs(config_arr) do
            if v ~= "" then
                share_content = share_content .. v .. ","
            end
        end

        share_content = string.sub(share_content, 1, string.len(share_content) - 1)
        local invote_code = USER_INFO["invote_code"] or ""

        local paras = {}
        paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
        paras["imagePath"] = "url"
        paras["name"] = GameName.."房号：" .. USER_INFO["invote_code"]
        paras["showType"] = 2;
        paras["url"] = appDownLoadAddress
        local shareLayer = require("hall.share.ShareLayer").new(paras)
        if shareLayer then
            shareLayer:addTo(SCENENOW["scene"],9999999)
        end
        -- require("hall.common.ShareLayer"):showShareLayer(GameName .. "，房号：" .. invote_code, "", "url", share_content)
    end)

    
    local btn_record = self._hall:getChildByName("btn_record")
    btn_record:setVisible(false)
    btn_record:onClick(function(sender,event)
        if device.platform ~= "windows" then
            require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])
        end
    end)

    self._hall.btn_chat:setVisible(false)
    self._hall.btn_chat:onClick(function (sender)
        self:loadGameMsgLayer()
    end)

    -- 复制房间号按钮
    local btn_copyRoom = self._hall:getChildByName("btn_copyRoom")
    btn_copyRoom:onClick(function (event)
        require("hall.util.GameMenu"):registCopyRoomIdFunc(btn_copyRoom, USER_INFO["invote_code"], GameName)
    end)
    btn_copyRoom:setVisible(false)

    -- 准备按钮
    local btn_ready = self._hall:getChildByName("btn_ready")
    btn_ready:onClick(function ( event)
        sendHandle:readyNow()
    end)
    btn_ready:setVisible(false)


    local lbVersion = ccui.Text:create()
    lbVersion:setString("1.0.3")
    lbVersion:setFontSize(18)
    lbVersion:setColor(cc.c3b(125, 125, 125))
    lbVersion:setPosition(cc.p(self._scene:getContentSize().width - lbVersion:getContentSize().width / 2, lbVersion:getContentSize().height / 2))
    self._scene:addChild(lbVersion, 999)

    --显示表情符号
    local idx = ViewBase:getZOrderByChilds(self)
    local EmojiArmatureView = require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self:getToSendFaceAndTxtFuncs(), self)
    EmojiArmatureView:setLocalZOrder(idx)
end

function XLCHMJScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end
function XLCHMJScene:_getScaleParam()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT

    return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function XLCHMJScene:changeBgImg()
    if self.bg_select_index == 3 then
        self.bg_select_index = 1
    else
        self.bg_select_index = self.bg_select_index + 1
    end
    local bg = self._scene:getChildByName("bg")
    bg:setTexture(TpackageName.."/res/image/bg_"..self.bg_select_index..".png")
    -- self.BG:setVisible(false)
end

function XLCHMJScene:initSome()
    XLCHMJ_SCENE.PanelHuanpai:setVisible(false)
    XLCHMJ_SCENE:getChildByName("NodeSelect"):setVisible(false)
    XLCHMJ_SCENE.PanelSelectTip:setVisible(false)
    XLCHMJ_SCENE:getChildByName("ChangeLayer"):setVisible(false)
    XLCHMJ_SCENE:getChildByName("NodeDingQue"):setVisible(false)
    XLCHMJ_SCENE.PanelLiuShui:setVisible(false)
    XLCHMJ_SCENE.PanelLiuShui:getChildByName("Imageliushui"):getChildByName("TextAllScore"):setString("0")
    local closeLiushu=function ()
        XLCHMJ_SCENE.PanelLiuShui:setVisible(false)
    end
    XLCHMJ_SCENE.PanelLiuShui:onClick(closeLiushu)
    local ShowLiushui=function ( ... )
        XLCHMJ_SCENE.PanelLiuShui:setVisible(true)
    end
    self._scene.hall:getChildByName("btnLushui"):onClick(ShowLiushui)
    self:initChangScoreLb(false)
        local panel=XLCHMJ_SCENE.PanelLiuShui
    local listview= panel:getChildByName("Imageliushui"):getChildByName("ListView_1")
    listview:removeAllChildren()
    XLCHMJ_SCENE.NodeChaEnd:setVisible(false)
end

function XLCHMJScene:ShowChaEnd( isdajiao,ishuahzu )
    XLCHMJ_SCENE.NodeChaEnd:setVisible(true)
        XLCHMJ_SCENE.NodeChaEnd:setScale(1.5)
        XLCHMJ_SCENE.NodeChaEnd.Imagechadajiao:setVisible(isdajiao)
        XLCHMJ_SCENE.NodeChaEnd.Imagechahuazhu:setVisible(ishuahzu)

        local scale=cc.ScaleTo:create(1,1)
        local callBack=cc.CallFunc:create(function ()
            XLCHMJ_SCENE.NodeChaEnd:setVisible(false)
        end)
          local sque=cc.Sequence:create(scale,callBack)
        XLCHMJ_SCENE.NodeChaEnd:runAction(sque)
    
end

function XLCHMJScene:initChangScoreLb(flag)
    for i=1,4 do
        self._scene.PanelChangeScore:getChildByName("change"..i):setString("")
    end
    self._scene.PanelChangeScore:setVisible(flag)
end

function XLCHMJScene:SetLiuShuiReconnet(data)
    dump(data.Liushui,"lushui")
    local panel=XLCHMJ_SCENE.PanelLiuShui
    local listview= panel:getChildByName("Imageliushui"):getChildByName("ListView_1")
    listview:setScrollBarEnabled(false)       --隐藏滚动条


    for i,v in ipairs(data.Liushui) do
        local IsSet=false
        local ChangeWinLose
        local CaoZuo
        local TypeFan
        local Cuser=""
        local WinUser={}
        local LoseUser={}
        local AllWinLose=0
        for j,k in ipairs(v.Change) do
            if k.ChangeWinLose>0 then
                table.insert(WinUser,k.Uid)
            elseif k.ChangeWinLose<0 then
                table.insert(LoseUser,k.Uid)
            end
            if k.Uid==USER_INFO.uid and k.ChangeWinLose~=0 then
                IsSet=true
                ChangeWinLose=k.ChangeWinLose
                AllWinLose=v.AllWinLose
            end
        end
        if IsSet then
            if v.GnagOpe==GANG_TYPE_PG then
                CaoZuo="点杠 "
                TypeFan="+2 "
                Cuser=self:GetWeiZhiByUid(WinUser[1])
            elseif v.GnagOpe==GANG_TYPE_AN then
                CaoZuo="暗杠 "
                TypeFan="+2 "
                if ChangeWinLose>0 then
                    Cuser="三家"
                else
                    Cuser=self:GetWeiZhiByUid(WinUser[1])
                end
            elseif v.GnagOpe==GANG_TYPE_BU then
                CaoZuo="补杠 " 
                TypeFan="+1 "
                dump(WinUser[1],"WinUser[1]")
                if ChangeWinLose>0 then
                    Cuser="三家"
                else
                    Cuser=self:GetWeiZhiByUid(WinUser[1])
                end 
            end


            for p=1,v.HuTaiSize do
                TypeFan=XLCHMJ_HU_TYPE_TABLE[v.HuTai[p].huType].." +"..v.HuTai[p].huCount.." "
                if v.HuTai[p].isZimo==1 then
                    if ChangeWinLose>0 then
                        CaoZuo="自摸 "
                        Cuser=" 三家 "
                    else
                        CaoZuo="被自摸 "
                        Cuser=self:GetWeiZhiByUid(WinUser[1])
                    end
                else
                    if ChangeWinLose>0 then
                        CaoZuo="放炮 "
                        Cuser=Cuser..self:GetWeiZhiByUid(LoseUser[1]).."、"
                    else
                        CaoZuo="点炮 "
                        dump()
                        if #WinUser>1 then
                            CaoZuo=CaoZuo.."一炮多响 "
                        end
                        for i1,v2 in ipairs(WinUser) do
                            Cuser=Cuser..self:GetWeiZhiByUid(v2).."、"
                        end
                    end
                end
            end

            -----
        panel:getChildByName("Imageliushui"):getChildByName("TextAllScore"):setString(data.AllWinLose/100)
    
        local item=panel:getChildByName("LiushuiItme"):clone()

            if ChangeWinLose>0 then
                item:getChildByName("TxtMessage"):setString(CaoZuo..TypeFan..Cuser.." +"..ChangeWinLose)
            else
                item:getChildByName("TxtMessage"):setString(CaoZuo..TypeFan..Cuser.." "..ChangeWinLose)
            end
            
            listview:pushBackCustomItem(item)          --添加item
            
        end

    end

end

function XLCHMJScene:showChangScore(data)
    self:initChangScoreLb(true)
    for i,v in ipairs(data.players) do
        
            local index=XLCHMJ_SEAT_TABLE[v.Uid]
            local pt=cardUtils:getPlayerType(index)
            if pt==CARD_PLAYERTYPE_RIGHT then
                index=2
            elseif pt==CARD_PLAYERTYPE_LEFT then
                index=4
            elseif pt==CARD_PLAYERTYPE_TOP then
                index=3
            else
                index=1
            end
            if v.ChangeWinLose>0 then
                self._scene.PanelChangeScore:getChildByName("change"..index):setString("+"..v.ChangeWinLose/100)
            elseif v.ChangeWinLose < 0 then
                self._scene.PanelChangeScore:getChildByName("change"..index):setString(v.ChangeWinLose/100)
            end
        
    end
    --显示分数变化动画  这里最好是动态创建text
    for i=1,4 do
        local xy=self._scene.PanelChangeScore:getChildByName("change"..i):getPosition()
        local moveby=cc.MoveBy:create(1.5,cc.p(0,80))
        local scale=cc.ScaleTo:create(1.5,1.5)
        local spawn=cc.Spawn:create(moveby,scale)
        local callBack=cc.CallFunc:create(function ( ... )
            self:initChangScoreLb(false)
            self._scene.PanelChangeScore:getChildByName("change"..i):setPosition(xy)
        end)
        local sque=cc.Sequence:create(spawn,callBack)
        self._scene.PanelChangeScore:getChildByName("change"..i):runAction(sque)
    end

end

function XLCHMJScene:ShowHuanPai()
    XLCHMJ_SCENE.PanelHuanpai:setVisible(true)
    XLCHMJ_SCENE:getChildByName("NodeSelect"):setVisible(true)
end

function XLCHMJScene:BtnSetClick()

   XLCHMJ_SCENE.PanelHuanpai.btnQueRen:onClick(self.btnQueRen)
end

function XLCHMJScene:RemoveHandCard(chids,tab)
    dump(tab,"tab.m_value")
    dump(chids,"chids.m_value")
    for i,v in ipairs(chids) do
        for j,k in ipairs(tab) do
            dump(v.m_value,"v.m_value")
            dump(k,"k.m_value")
            if v.m_value==k then
                v:removeSelf()
                table.remove(tab,j)
                break
            end
        end
    end
end

function XLCHMJScene:btnQueRen()

    local RemoveHandCard=function ( chids,tab)
        dump(tab,"tab.m_value")
    dump(chids,"chids.m_value")
    for i,v in ipairs(chids) do
        for j,k in ipairs(tab) do
            dump(v.m_value,"v.m_value")
            dump(k,"k.m_value")
            if v.m_value==k then
                v:removeSelf()
                table.remove(tab,j)
                break
            end
             end
        end
    end
    local plane = XLCHMJ_SCENE.players:getChildByName("my_card_plane"):getChildByName("inhand_plane")
            local chids=plane:getChildren()
        local Count=0
        local huaSe=-1
        local tabValue={}
        for i,v in ipairs(chids) do
            if v.IsSelect then
                if huaSe==-1 or huaSe==bit.brshift(v.m_value,4) then
                    huaSe=bit.brshift(v.m_value,4)
                    Count=Count+1
                    table.insert(tabValue,v.m_value)
                else
                    Count=0
                end
            end
        end
        if Count==3 then

            sendHandle:CLI_HUAN_PAI(tabValue[1],tabValue[2],tabValue[3])
                dump(tabValue,"tab.m_value")
    dump(chids,"chids.m_value")
            RemoveHandCard(chids,tabValue)  --删除手牌
            XLCHMJ_SCENE.PanelHuanpai:setVisible(false)
        else
            XLCHMJ_SCENE.PanelHuanpai:getChildByName("Text_Tip"):setString("选牌错误 请重新选择！")
            XLCHMJ_SCENE.PanelHuanpai:performWithDelay(function()
                XLCHMJ_SCENE.PanelHuanpai:getChildByName("Text_Tip"):setString("选择3张同花色的牌")
            end,1)
        end
end


function XLCHMJScene:SetSelfHandCardTouch(flag,NewCard)
    local count=1

    local plane = XLCHMJ_SCENE.players:getChildByName("my_card_plane"):getChildByName("inhand_plane")
    for i,v in ipairs(plane:getChildren()) do
        dump(v.m_value,"SetSelfHandCardTouch")
        if NewCard and v.m_value==NewCard and count==1 then 
            count=count-1
        
        else
            v.IsAlreadyHu=flag
            v:setColor(cc.c3b(140,140,140))
        end
    end
end

function XLCHMJScene:SetLiuShuiForHu(data)
    local panel=XLCHMJ_SCENE.PanelLiuShui
    local AllWinLose=0
    local ChangeWinLose=""
    local HuCaozuo=""
    local huType=""
    local Win=false
    local IsZimo=false
    local WinCount=0
    local HuUser=""
    local winTab={}
    local LoseTab={}
    for i,v in ipairs(data.players) do
        if v.ChangeWinLose>0 then
            WinCount=WinCount+1
            table.insert(winTab,v.Uid)
        else
            table.insert(LoseTab,v.Uid)
        end
        if v.Uid==USER_INFO.uid then
            AllWinLose=v.AllWinLose/100
            
            if v.ChangeWinLose>0 then
                Win=true
                ChangeWinLose=" +"..v.ChangeWinLose/100
            elseif v.ChangeWinLose==0 then
                return
            elseif v.ChangeWinLose<0 then
                ChangeWinLose=" "..v.ChangeWinLose/100
            end
        end
        if v.taiSize>0 then
            for j,k in ipairs(v.tais) do
                if k.isZiMo==1 then
                    IsZimo=true
                end
                huType=XLCHMJ_HU_TYPE_TABLE[k.type].." +"..k.taiCount.." "
            end
        end
    end
    if Win then
        if IsZimo then
            HuCaozuo="自摸 "
            HuUser="三家 "
        else
            HuCaozuo="放炮 "
            HuUser=self:GetWeiZhiByUid(LoseTab[1])
        end
    else
        if IsZimo then
            HuUser=self:GetWeiZhiByUid(winTab[1])
            HuCaozuo="被自摸 "
        else
            HuCaozuo="点炮 "
            if WinCount>1 then
                HuCaozuo=HuCaozuo.." 一炮多响 "
            end
            for i=1,#winTab do
                HuUser=HuUser..self:GetWeiZhiByUid(winTab[i]).."、 "
            end
        end
    end
    ----
    panel:getChildByName("Imageliushui"):getChildByName("TextAllScore"):setString(AllWinLose)
    
    local item=panel:getChildByName("LiushuiItme"):clone()
    item:getChildByName("TxtMessage"):setString(HuCaozuo..huType..HuUser..ChangeWinLose)
    local listview= panel:getChildByName("Imageliushui"):getChildByName("ListView_1")
    listview:setScrollBarEnabled(false)       --隐藏滚动条
    listview:pushBackCustomItem(item)          --添加item
    

end

function XLCHMJScene:SetLiuShuiForGang(data)
    local panel=XLCHMJ_SCENE.PanelLiuShui
    local AllWinLose=0
    local ChangeWinLose=""
    local GangCaozuo=""
    local gangType=""
    local Win=false
    local IsZimo=false
    local WinCount=0
    local GangUser=""
    local winTab={}
    local LoseTab={}
    for i,v in ipairs(data.players) do
                if v.ChangeWinLose>0 then
            WinCount=WinCount+1
            table.insert(winTab,v.Uid)
        elseif v.ChangeWinLose<0 then
            table.insert(LoseTab,v.Uid)
        end
        if v.Uid==USER_INFO.uid then
            if v.ChangeWinLose==0 then
                return 
            elseif v.ChangeWinLose>0 then
                Win=true
                ChangeWinLose=" +"..v.ChangeWinLose/100
            elseif v.ChangeWinLose<0 then
                ChangeWinLose=" "..v.ChangeWinLose/100
            end
            AllWinLose=v.AllWinLose/100
        end
    end
    dump(data.gangType,"data.gangType")
    if data.gangType==GANG_TYPE_PG then
        GangCaozuo="点杠 "
        gangType="+2 "
    elseif data.gangType==GANG_TYPE_AN then
        GangCaozuo="暗杠 "
        gangType="+2 "
    elseif data.gangType==GANG_TYPE_BU then
        GangCaozuo="补杠 " 
        gangType="+1 "  
    end
    if Win then
        if #LoseTab==3 then
            GangUser="三家 "
        else
            GangUser=self:GetWeiZhiByUid(LoseTab[1])
        end
    else
        GangUser=self:GetWeiZhiByUid(winTab[1])
    end
    ----
    panel:getChildByName("Imageliushui"):getChildByName("TextAllScore"):setString(AllWinLose)
    
    local item=panel:getChildByName("LiushuiItme"):clone()
    item:getChildByName("TxtMessage"):setString(GangCaozuo..gangType..GangUser..ChangeWinLose)
    local listview= panel:getChildByName("Imageliushui"):getChildByName("ListView_1")
    listview:setScrollBarEnabled(false)       --隐藏滚动条
    listview:pushBackCustomItem(item)          --添加item

end

function XLCHMJScene:GetWeiZhiByUid(uid)
    local weizhi=""
    local seatId = XLCHMJ_SEAT_TABLE[uid]
    local playType=cardUtils:getPlayerType(seatId)
    if playType==CARD_PLAYERTYPE_RIGHT then
        weizhi="下家"
    elseif playType==CARD_PLAYERTYPE_TOP then
        weizhi="对家"
    elseif playType==CARD_PLAYERTYPE_LEFT then
        weizhi="上家"
    end
    return weizhi
end

function XLCHMJScene:ShowChangeCard(data,type)
    XLCHMJ_SCENE.PanelHuanpai:setVisible(false)
    XLCHMJ_SCENE:getChildByName("NodeSelect"):setVisible(false)
    local node=XLCHMJ_SCENE:getChildByName("ChangeLayer")
    node:setVisible(true)
    local By=15
    local Bx=16
    for i,v in ipairs(data) do
        local card=Card:newMyInHandCard(v)
        card:setAnchorPoint(0,0)
        card:setPosition(Bx+((i-1)*110),By)
        card:addTo(node)
    end
    --显示换牌模式
    dump(type,"ShowChangeCard")
    if type==0 then
        XLCHMJ_SCENE.PanelSelectTip:setVisible(true)
        XLCHMJ_SCENE.PanelSelectTip:getChildByName("ImgShun"):setVisible(true)
        XLCHMJ_SCENE.PanelSelectTip:getChildByName("ImgNi"):setVisible(false)
        XLCHMJ_SCENE.PanelSelectTip:getChildByName("ImgDuiJia"):setVisible(false)
    elseif type==1 then
        XLCHMJ_SCENE.PanelSelectTip:setVisible(true)
        XLCHMJ_SCENE.PanelSelectTip:getChildByName("ImgShun"):setVisible(false)
        XLCHMJ_SCENE.PanelSelectTip:getChildByName("ImgNi"):setVisible(true)
        XLCHMJ_SCENE.PanelSelectTip:getChildByName("ImgDuiJia"):setVisible(false)
    elseif type==2 then
        XLCHMJ_SCENE.PanelSelectTip:setVisible(true)
        XLCHMJ_SCENE.PanelSelectTip:getChildByName("ImgShun"):setVisible(false)
        XLCHMJ_SCENE.PanelSelectTip:getChildByName("ImgNi"):setVisible(false)
        XLCHMJ_SCENE.PanelSelectTip:getChildByName("ImgDuiJia"):setVisible(true)
    end
end

function XLCHMJScene:RemoveChangeCard()
    XLCHMJ_SCENE.PanelSelectTip:setVisible(false)
        local node=XLCHMJ_SCENE:getChildByName("ChangeLayer")
    node:setVisible(false)
    node:removeAllChildren()
end

function XLCHMJScene:ShowDingQue()
    XLCHMJ_SCENE:getChildByName("NodeDingQue"):setVisible(true)
    local btnWan= XLCHMJ_SCENE:getChildByName("NodeDingQue"):getChildByName("btnWan")
    local btnTong= XLCHMJ_SCENE:getChildByName("NodeDingQue"):getChildByName("btnTong")
    local btnTiao= XLCHMJ_SCENE:getChildByName("NodeDingQue"):getChildByName("btnTiao")
    local ClickWan=function ()
        sendHandle:CLI_CHOICE_QUE(0)
        XLCHMJ_SCENE:getChildByName("NodeDingQue"):setVisible(false)
    end
        local ClickTong=function ()
        sendHandle:CLI_CHOICE_QUE(1)
        XLCHMJ_SCENE:getChildByName("NodeDingQue"):setVisible(false)
    end
        local ClickTiao=function ()
        sendHandle:CLI_CHOICE_QUE(2)
        XLCHMJ_SCENE:getChildByName("NodeDingQue"):setVisible(false)
    end
    btnWan:onClick(ClickWan)
    btnTong:onClick(ClickTong)
    btnTiao:onClick(ClickTiao)
end


--设置定缺牌的颜色
function XLCHMJScene:SetDingQueColor()
    local plane = XLCHMJ_SCENE.players:getChildByName("my_card_plane"):getChildByName("inhand_plane")
    local chids=plane:getChildren()
    for i,v in ipairs(chids) do
        if bit.brshift(v.m_value,4)==UserDingQueHuaSe then
            v:setColor(cc.c3b(140,140,140))  --定缺牌变灰
        end
    end
end

function XLCHMJScene:_initUI()
    if self._scene then
        local bg = self._scene:getChildByName("Image_1")
        local precent = self:_getScaleParam2()
        if bg then
            bg:setScaleX(bg:getScale()*precent)
            -- local x = bg:getPositionX()
            -- bg:setPositionX(x*precent)
        end

        local root = self._scene
        if root then
            local child = root:getChildren()
            for i, v in ipairs( child or {} ) do
                local x = v:getPositionX()
                v:setPositionX(x*precent)
                if v:getDescription() == "ListView" then --容器按照比率重新设置大小
                    local size = v:getContentSize()
                    v:setContentSize(cc.size(size.width * precent, size.height))
                end
            end
        end

		local mj_danjiChuPai = cc.UserDefault:getInstance():getBoolForKey("mj_danjiChuPai")
        self.checkBox = self._scene.hall.CheckBox_1:setSelectedState(mj_danjiChuPai)
        if mj_danjiChuPai then
            self.checkBox.Text_14:setString("单击")
        else
            self.checkBox.Text_14:setString("双击")
        end

        --双击且不可见
        self.checkBox:setVisible(false)
        cc.UserDefault:getInstance():setBoolForKey("mj_danjiChuPai",false)



        self:TgState(false)


             ---gps按钮
        local gpsBtn = self._scene:getChildByName("btn_gps")
        gpsBtn:setVisible(false)
        gpsBtn:addTouchEventListener(function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then

               sender:setScale(1)
               local gpsLayer = GPSShowLayer.new()
               self:addChild(gpsLayer)
               local temptab = {}
               for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
                   table.insert(temptab,v)
               end
               gpsLayer:setInfo(temptab)

            end
        end)


    end
end

function XLCHMJScene:showGPSButton()
    dump(XLCHMJ_USERINFO_TABLE,"showGPSButton--XLCHMJ_USERINFO_TABLE")
    local temptab = {}
    for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
        table.insert(temptab,v)
    end
    local btn_gps = self._scene:getChildByName("btn_gps")

    if #temptab == 1 then
        btn_gps:setVisible(false)
        return
    end

    local isWarning = 0
    for i=1,#temptab do
        for j=i+1,#temptab do
            if calculateDistance(temptab[i].latitude,temptab[j].latitude,temptab[i].longitude,temptab[j].longitude) <= 100 then
                isWarning = isWarning + 1
                break
            end
        end
    end

    local img_safe = btn_gps:getChildByName("img_safe")
    local img_warnning = btn_gps:getChildByName("img_warnning")

    if isWarning > 0 then
        img_safe:setVisible(false)
        img_warnning:setVisible(true)
    else
        img_safe:setVisible(true)
        img_warnning:setVisible(false)
    end

    btn_gps:setVisible(true)
end

function XLCHMJScene:initEvent()
    self.checkBox:addEventListenerCheckBox(function(sender,eventType)
        require("hall.GameCommon"):onClickSound()
        if eventType == CHECKBOX_STATE_EVENT_SELECTED then
			cc.UserDefault:getInstance():setBoolForKey("mj_danjiChuPai",true)
            self.checkBox:setSelectedState(true)
            self.checkBox.Text_14:setString("单击")
        elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
			cc.UserDefault:getInstance():setBoolForKey("mj_danjiChuPai",false)
            self.checkBox:setSelectedState(false)
            self.checkBox.Text_14:setString("双击")
        end
    end)
    self._hall:getChildByName("btn_tg"):onClick(function(event)
        sendHandle:CLI_ROBOT(1)
    end)
    self._scene.take_bg.btn_cl:onClick(function(event)
        sendHandle:CLI_ROBOT(0)
    end)
end

function XLCHMJScene:onEnter()
    local device_info_plane = self._hall:getChildByName("device_info_plane") 
    require("hall.util.GameMenu"):addMenu(nil,device_info_plane,GameName)

    self:showInviteCode()
    sendHandle:LoginGame()
	if tableIdReload == 0 then --非重登
    else
        tableIdReload = 0
    end
    
end

function XLCHMJScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = XLCHMJ_SEAT_TABLE[uid ]

    if seatId then
        --todo

        if XLCHMJ_USERINFO_TABLE[seatId ] and XLCHMJ_USERINFO_TABLE[seatId ].ip then
            --todo
            ip_ = XLCHMJ_USERINFO_TABLE[seatId ].ip
        end
    end

    return ip_
end

function XLCHMJScene:showLeaderLayer()

end

function XLCHMJScene:ShowChatButton()
    self._hall.btn_chat:setVisible(true)
end

function XLCHMJScene:showVoice()
    local scenes  = self._scene
     if scenes then
         local btn_voice = self._hall.btn_voice
         local voice_bt_worldpoint = (btn_voice:getParent()):convertToWorldSpace(btn_voice:getPosition())
         local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
         if  VoiceRecordView.addVoiceRecordEvent then
             btn_voice:setVisible(true)
             VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
         else
             VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
         end

         btn_voice:setVisible(false)
     end
     
end

function XLCHMJScene:ShowRecordButton()
    self._hall.btn_record:setVisible(false)

    self._hall.btn_chat:setVisible(true)

    --语音按钮

    self:showVoice()
    ------self:showLeaderLayer()
end

--获取用户播放录音位置
function XLCHMJScene:getPosforSeat(uid)
    return XLCHMJ_ROOM.positionTable[uid ]
end

--显示设置按钮（弃用）
function XLCHMJScene:ShowSettingButton()

end


-------------------------游戏未开始前的解散房间和分享按钮------------------------
function XLCHMJScene:hideCloseRoomButton()
end

function XLCHMJScene:hideShareButton()
	local btn_share = self._hall:getChildByName("btn_share")
	btn_share:setVisible(false)
    -- 复制房间号按钮
    local btn_copyRoom = self._hall:getChildByName("btn_copyRoom")
    btn_copyRoom:setVisible(false)
end
----------------------------------------------------------------------------------
--解散房间
function XLCHMJScene:disbandGroup()

	--查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
	cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameStatus",
        date = {
        	activityId = USER_INFO["activity_id"],
        	interfaceType = "j"
        },
        type_= "POST",
        callBack = function(data)
            local responseData = data.netData
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
            if returnCode == "0" then
            	local data = tonumber(responseData.data)
            	--dump(data, "检查当前组局状态")
            	if data == 1 then
            		--创建组局
                    if isiOSVerify or isGoldGame ~= 1 then
                        require("hall.GameTips"):showDisbandTips("解散房间", "XLCHMJ_disbandGroup", 1, "是否解散房间？")
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "XLCHMJ_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？")
                    end

            	elseif data == 2 then
            		--开始组局
                    if isiOSVerify or isGoldGame ~= 1 then
                        require("hall.GameTips"):showDisbandTips("解散房间", "XLCHMJ_disbandGroup", 1, "是否申请解散房间？")
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "XLCHMJ_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？")
                    end
            		
            	elseif data == 0 then
            		--结束组局
                    require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

            	end

            else
            		
            end

 		end
	})

end

--聊天
function XLCHMJScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
    local s = self:getChildByName("faceUI")
    
    if tonumber(sex) >= 0 then
        s:showGetFace(uid, type, tonumber(sex), node_head, isLeft)
    end
end
function XLCHMJScene:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function XLCHMJScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    sendHandle:LoginGame()
end
--function XLCHMJScene:reConnect()
--    dump("test 1123 begin")
--    bm.server:setProtocol(PROTOCOL)
--    bm.server:setHandle(receiveHandle.new())
--    sendHandle:LoginGame()
--end

function XLCHMJScene:showInviteCode()
    local invote_code = USER_INFO.invote_code or ""
    self._hall.room_lb:setString("房间号："..invote_code)
end

function XLCHMJScene:hideInviteCode()
    self._hall.room_lb:setVisible(false)
end

function XLCHMJScene:showCopyInviteBtn(isShow)
    if XLCHMJ_ROUND and XLCHMJ_ROUND >= 1 then
        isShow = false
    end
    -- 复制房间号按钮
    local btn_copyRoom = self._hall:getChildByName("btn_copyRoom")
    btn_copyRoom:setVisible(isShow)

    --邀请微信好友
    local btn_share = self._hall:getChildByName("btn_share")
    btn_share:setVisible(isShow)
    if isiOSVerify then
        btn_share:setVisible(false)
        btn_copyRoom:setVisible(false)
    end
    btn_share:onClick(
        function(sender,event)
            local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
            local share_content = ""
            for k, v in pairs(config_arr) do
                if v ~= "" then
                    share_content = share_content .. v .. ","
                end
            end

            share_content = string.sub(share_content, 1, string.len(share_content) - 1)
            local invote_code = USER_INFO["invote_code"] or ""
            
            local paras = {}
            paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
            paras["imagePath"] = "url"
            paras["name"] = GameName.."房号：" .. USER_INFO["invote_code"]
            paras["showType"] = 2;
            paras["url"] = appDownLoadAddress
            local shareLayer = require("hall.share.ShareLayer").new(paras)
            if shareLayer then
                shareLayer:addTo(SCENENOW["scene"],9999999)
            end
            -- require("hall.common.ShareLayer"):showShareLayer(GameName .. "，房号：" .. invote_code, "", "url", share_content)
        end
    )

end


function XLCHMJScene:showBtnByUserStatus(_type)

    -- 准备按钮
    local btn_ready = self._hall:getChildByName("btn_ready")

    if not _type then

        btn_ready:setVisible(false)

    elseif _type == "ready" then
        btn_ready:setVisible(false)

    elseif _type == "sit" then
        btn_ready:setVisible(true)
    elseif _type == "stand" then
        btn_ready:setVisible(false)

    end
end

function XLCHMJScene:showGameConfig(gameConfigtbl)
    local gameConfigStr = ""
	for k, v in pairs(gameConfigtbl) do
        if k == "pay_type" then
            if v == "fangka" then
                gameConfigStr = gameConfigStr .. "房主开房 "
            elseif v == "AA" then
                gameConfigStr = gameConfigStr .. "AA开房 "
            end
        -- elseif k == "hufa" then
        --     if v == 0 then
        --         gameConfigStr = gameConfigStr .. "可抢杠胡 "
        --     elseif v == 1 then
        --         gameConfigStr = gameConfigStr .. "自摸胡 "
        --     end
        elseif k == "laiziCount" then
            if v == 0 then
                gameConfigStr = gameConfigStr .. "无宝 "
            elseif v == 1 then
                gameConfigStr = gameConfigStr .. "红中做宝 "
            elseif v == 3 then
                gameConfigStr = gameConfigStr .. "双宝 "
            end
        elseif k == "zhuaniao" then
            if v == 2 then
                gameConfigStr = gameConfigStr .. "2码 "
            elseif v == 4 then
                gameConfigStr = gameConfigStr .. "4码 "
            elseif v == 6 then
				gameConfigStr = gameConfigStr .. "6码 "
			elseif v == 8 then
                gameConfigStr = gameConfigStr .. "8码 "
            elseif v == 999 then
                gameConfigStr = gameConfigStr .. "一码全中 "
                G_game.isYiMaQuanZhong = true
			elseif v == 0 then
                gameConfigStr = gameConfigStr .. "无码 "
			end
		elseif k == "huPaiScore" then
            if v == 2 then
				gameConfigStr = gameConfigStr .. "2分起胡 "
			elseif v == 3 then
                gameConfigStr = gameConfigStr .. "3分起胡 "
            end
        elseif k == "tgTime" then
            if v == 0 then
                gameConfigStr = gameConfigStr .. "无托管 "
			end
        -- elseif k == "canPick" then
        --     local canPickStr= string.split(v, ",")
        --     for _, x in pairs(canPickStr) do
        --         if x == '0' then
        --             gameConfigStr = gameConfigStr .. "庄闲(算分) "
        --         elseif x == '1' then
        --             gameConfigStr = gameConfigStr .. "可胡七对 "
        --         elseif x == '2' then
        --             gameConfigStr = gameConfigStr .. "红中癞子 "
        --         end
        --     end
        end
	end
    USER_INFO["gameConfig"] = "玩法: "..gameConfigStr
    
    gameConfigTable = {{["游戏名"]=GameName, ["底分"] = BASE_CHIP}, {["特殊玩法"] = gameConfigStr}}
end


function XLCHMJScene:setGameSetting()
    self.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
    self:addChild(self.roomCommonLayer, 15)
    self.roomCommonLayer:setTouchSwallowEnabled(false)
    self.roomCommonLayer:setVisible(false)
    self:loadGameMsgLayer()
end


function XLCHMJScene:showGameSetting()
    print("=====self:showGameSetting=====")
    print("=====self:showGameSetting=====")
    self:setGameSetting()
    self:loadMoreFuncLayer()
end
function XLCHMJScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end
function XLCHMJScene:disbandRoom()
    sendHandle:C2G_CMD_DISSOLVE_ROOM()
end

function XLCHMJScene:rejectDisband()
    sendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function XLCHMJScene:agreeDisband()
    sendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function XLCHMJScene:getToDisbandFuncs()
    local data = {}
    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandRoom)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
    data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
    --data.showGameMsgLayerHandler = handler(self, self.loadGameMsgLayer)
    data.voiceRecordHandler = handler(self,self.addVoiceRecordEvent)
    return data
end

function XLCHMJScene:loadMoreFuncLayer()
    print("=====loadMoreFuncLayer=====")
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(self.moreFuncLayer, 99999)
        local data = {}
        data.quitRoom = handler(self, self.quitRoom)
        data.disbandRoom = handler(self, self.disbandRoom)
        self.moreFuncLayer:registerDisbandFuncs(data)
    else
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
    -- print("======SCENENOW['scene'].GameRound======",SCENENOW["scene"].GameRound)

--[[    if 0 == SCENENOW["scene"].GameRound then
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    else
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    end--]]
    --self.moreFuncLayer.btnDisbandRoom:setVisible(false)
end

function XLCHMJScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
       
        self:addChild(self.gameMsgLayer, 99999)
        self.gameMsgLayer:setVisible(false)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function XLCHMJScene:getToSendFaceAndTxtFuncs()
    local data = {}
    -- data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end
function XLCHMJScene:quitRoom()
    -- sendHandle:CLI_QUIT_ROOM()
    print("=====quitRoom===6666666===")
    sendHandle:quitRoom()
    -- self:disbandGroup()
end

function XLCHMJScene:sendFaceByIdx(id, msgType, to_uid)
    print("sendFaceMsg --------------------------", id)
    sendHandle:CLI_MSG_FACE(id, msgType, to_uid)
end

function XLCHMJScene:sendEditTxt(str)
    print("sendEditMsg --------------------------", id)
end
function XLCHMJScene:TgState(flag)
    self._scene.take_bg:setVisible(flag)
end

function XLCHMJScene:onExit()
    dump("---------------退出快乐麻将")
    GamePlaneOperator:clearGameDatas()
    --G_game = nil
    --TpackageName = nil
    D3_CHUPAI = 0

end
return XLCHMJScene