local NewViewBaseLayer = require("hall.NewViewBaseLayer")

local ViewBaseLayer = require("hall.ViewBaseLayer")
local RoundEndingLayer = class("RoundEndingLayer", NewViewBaseLayer)

local receiveHandle = require(TpackageName..".handle.XLCHMJReceiveHandle")
local sendHandle = require(TpackageName..".handle.XLCHMJSendHandle")


--cc.p(0,-60)  分数位置
function RoundEndingLayer:ctor(data)
    RoundEndingLayer.super.ctor(self, "XLCH_majiang/res/RoundEndingLayer.csb")
    self._data = data
    --dump(data, "RoundEndingLayer == ")
    GameUtils.setNodeNameBindObj(self._csbNode)
    display.doLayout(self._csbNode)
    self:enableMask(true)
    self:setMask()
    --local userInfo = g_mainScene.userInfoByViewId[info.Uid]
    self:setUserInfo(data)
   -- self:__initUI()
    --self:showResult(self._data)
    self.root:onTouch(handler(self, self.onClick_vw), false)
    self:SetUi()
    if data.LiushuiSize>0 then
        self:SetZhanJiLiShi(data)
    end
    self:initBtn()
end

function RoundEndingLayer:initBtn()
    self.btnJiXu:onClick(handler(self, self.onClickBtnJiXu), true)
    self.btnZaiLaiYIju:onClick(handler(self, self.onClickZlyj), true)
    self.btnFanhui:onClick(handler(self, self.onClickFHDT), true)
    self.btnZaiLaiYIju:setVisible(false)
    self.btnFanhui:setVisible(false)
    
    if XLCHMJ_ROUND==XLCHMJ_TOTAL_ROUNDS then
        self.btnJiXu:setVisible(false)
        self.btnZaiLaiYIju:setVisible(true)
        self.btnFanhui:setVisible(true)
    end

end

function RoundEndingLayer:SetUi()
    self.root:getChildByName("TextRoundTime"):setString("第"..XLCHMJ_ROUND.."/"..XLCHMJ_TOTAL_ROUNDS.."局")
    local time_str = os.date("%Y-%m-%d %H:%M:%S", os.time())
    self.root:getChildByName("Text_Time"):setString(time_str)
    self.root:getChildByName("Text_RoomId"):setString("房号:"..USER_INFO["invote_code"])

end

function RoundEndingLayer:setUserInfo(data)
    
    for k=1,4 do
        self.root:getChildByName("Image_"..k):setVisible(false)
    end

    for i,v in ipairs(data.players) do
        local head_node=self.root:getChildByName("Image_"..i)
        head_node:setVisible(true)
        local seatID=XLCHMJ_SEAT_TABLE[v.uid]
        local userInfo=XLCHMJ_USERINFO_TABLE[seatID]
        --设置头像
       local headImg=head_node:getChildByName("img_head")
        local size = headImg:getSize()
        require("hall.GameCommon"):getUserHead(v.portrait, "", "", headImg, size.width , false, "", true)
        --设置自己的背景
        if v.uid==USER_INFO.uid then
            head_node:loadTexture(TpackageName.."/res/roundEndImg/selfBg.png")
            local sanjiao=self.root:getChildByName("Image_sanjiao"):clone()
            sanjiao:setPosition(cc.p(100,-10))
            sanjiao:addTo(head_node)
        end
        --
        head_node:getChildByName("nickname"):setString(userInfo.nick)
        --
        head_node:getChildByName("Text_Uid"):setString(v.uid)

        if v.changeCoins>0 then
            local WinText=self.root:getChildByName("WinScore"):clone()
            WinText:setString("+"..v.changeCoins/100)
            WinText:setPosition(cc.p(104,30))
            WinText:addTo(head_node)
        else
            local LoseText=self.root:getChildByName("LoseScore"):clone()
            LoseText:setString(v.changeCoins/100)
            LoseText:setPosition(cc.p(104,30))
            LoseText:addTo(head_node)
        end
    end
    local Item=self.root.PanelItem:clone()
end

function RoundEndingLayer:onClickBtnJiXu(event)
    sendHandle:readyNow()
    self:removeSelf()
end

function RoundEndingLayer:onClick_vw(event)
    if event.name == "began" then
            if self  then
                self:hide()
                self.maskLayout:hide()      
            end
     
    elseif event.name == "ended" then
            self:show()
            self.maskLayout:show()         
    elseif event.name == "cancelled" then
            self:show()
            self.maskLayout:show()
         
    end
end

function RoundEndingLayer:SetZhanJiLiShi(data)
    local listview=self.root.bg.ListView_1
    listview:setScrollBarEnabled(false)       --隐藏滚动条

    for i,v in ipairs(data.Liushui) do
        local IsSet=false
        local ChangeWinLose
        local CaoZuo=""
        local TypeFan=""
        local Cuser=""
        local WinUser={}
        local LoseUser={}
        for j,k in ipairs(v.Change) do
            if k.ChangeWinLose>0 then
                table.insert(WinUser,k.Uid)
            else
                table.insert(LoseUser,k.Uid)
            end
            if k.Uid==USER_INFO.uid and k.ChangeWinLose~=0 then
                IsSet=true
                ChangeWinLose=k.ChangeWinLose
            end
        end
        if IsSet then
            if v.GnagOpe==GANG_TYPE_PG then
                CaoZuo="点杠 "
                TypeFan="+2 "

            elseif v.GnagOpe==GANG_TYPE_AN then
                CaoZuo="暗杠 "
                TypeFan="+2 "
             elseif v.GnagOpe==GANG_TYPE_BU then
                CaoZuo="补杠 " 
                TypeFan="+1 "  
            end
        if ChangeWinLose>0 then
            if #LoseUser==3 then
                Cuser="三家 "
            else
                Cuser=SCENENOW['scene']:GetWeiZhiByUid(LoseUser[1])
            end
        else
            Cuser=SCENENOW['scene']:GetWeiZhiByUid(WinUser[1])
        end


            for i=1,v.HuTaiSize do
                TypeFan=XLCHMJ_HU_TYPE_TABLE[v.HuTai[i].huType].." +"..v.HuTai[i].huCount
                if v.HuTai[i].isZimo==1 then
                    if ChangeWinLose>0 then
                        if #LoseUser==3 then
                            CaoZuo="自摸"
                            Cuser=" 三家"
                        else
                            CaoZuo="自摸"
                            Cuser=" 对家"
                        end
                    else
                        CaoZuo=" 被自摸"
                        Cuser=SCENENOW['scene']:GetWeiZhiByUid(WinUser[1])
                    end
                else
                    if ChangeWinLose>0 then
                        CaoZuo="放炮"
                        Cuser=Cuser.."、"
                    else
                        CaoZuo="点炮"
                        if #WinUser>1 then
                            CaoZuo=CaoZuo.." 一炮多响"
                        end
                        Cuser=""
                        for i=1,#WinUser do
                            Cuser=Cuser..SCENENOW['scene']:GetWeiZhiByUid(WinUser[i]).."、"
                        end
                    end
                end
            end

            -----
            local Item=self.root.PanelItem:clone()
            if ChangeWinLose>0 then

                Item:getChildByName("TextMesg"):setString(CaoZuo..TypeFan..Cuser.." +"..ChangeWinLose)
            else
                Item:getChildByName("TextMesg"):setString(CaoZuo..TypeFan..Cuser.." "..ChangeWinLose)
            end
            
            listview:pushBackCustomItem(Item)          --添加item
            
        end

    end
    --查大叫
    if data.chadajiao then
        for i,v in ipairs(data.chadajiao) do
            if v.Uid==USER_INFO.uid then
                local Item=self.root.PanelItem:clone()
                if v.ChangeWinLose>0 then
                    Item:getChildByName("TextMesg"):setString("查大叫    +"..v.ChangeWinLose/100)
                else
                    Item:getChildByName("TextMesg"):setString("查大叫    "..v.ChangeWinLose/100)
                end
                listview:pushBackCustomItem(Item)
            end
        end
    end
        --查花猪
    if data.chahuazhu then
        for i,v in ipairs(data.chahuazhu) do
            if v.Uid==USER_INFO.uid then
                local Item=self.root.PanelItem:clone()
                if v.ChangeWinLose>0 then
                    Item:getChildByName("TextMesg"):setString("查花猪    +"..v.ChangeWinLose/100)
                else
                    Item:getChildByName("TextMesg"):setString("查花猪    "..v.ChangeWinLose/100)
                end
                listview:pushBackCustomItem(Item)
            end
        end
    end
        --退税
    if data.tuishui then
        for i,v in ipairs(data.tuishui) do
            if v.Uid==USER_INFO.uid then
                local Item=self.root.PanelItem:clone()
                if v.ChangeWinLose>0 then
                    Item:getChildByName("TextMesg"):setString("退税    +"..v.ChangeWinLose/100)
                else
                    Item:getChildByName("TextMesg"):setString("退税    "..v.ChangeWinLose/100)
                end
                listview:pushBackCustomItem(Item)
            end
        end
    end

end

function RoundEndingLayer:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    strUrl = string.sub(strUrl,nPos+1,string.len(strUrl))
    nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    return strPic..".jpg"
end

function RoundEndingLayer:onClickZlyj()
    require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"], TpackageName .. ".gameScene")
end

function RoundEndingLayer:onClickFHDT()
    HEART_BEAT_TID = 0
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
end



return RoundEndingLayer