--[[
* author:   zwm
* date:     2020-05-28
* describe: 510k大结算界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local ViewBaseLayer = require("hall.ViewBaseLayer")
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local TotalResultLayer = class("TotalResultLayer", NewViewBaseLayer)

local CELL_POS_X = 35
local CELL_POS_Y_BEGIN = 493
local CELL_POS_Y_INTERVAL = 124
TpackageName="zixidadun"
function TotalResultLayer:ctor(data)
    TotalResultLayer.super.ctor(self, "zixidadun/res/TotalResultLayer.csb")
        self:enableMask(true)
            GameUtils.setNodeNameBindObj(self._csbNode)
    display.doLayout(self._csbNode)
    
    self._data = data
    self:__initUI()
    self:showResult(self._data)
    self.Image_1:getChildByName("BtnClose"):onClick(handler(self, self.onClickBtnClose), true)
    --self.Image_1:getChildByName("BtnClose"):onClick(handler(self, self.onClickBtnClose), true)
end

function TotalResultLayer:__initUI()    
    --self.BtnShare:setVisible(false)
    -- self.cell1:setVisible(false)
    -- self.cell2:setVisible(false)
    -- self.cell3:setVisible(false)
    -- self.cell4:setVisible(false)
    self.Image_1:getChildByName("text_time"):setString("")
    for j=1,3 do
        for i=1,6 do
            self.Image_1:getChildByName("node_user"..j):getChildByName("text_result"..i):setVisible(false)
        end
        local node_user=self.Image_1:getChildByName("node_user"..j)
        node_user:getChildByName("head_node"):getChildByName("Image_zhuang"):setVisible(false)
        node_user:getChildByName("text_nickName"):setString("")
        node_user:getChildByName("text_userId"):setString("")
        node_user:getChildByName("text_db"):setString("")
    end
end

function TotalResultLayer:showResult(data)
    dump(data,"---data--")
    print("TotalResultLayer:showResult ------------------", data == nil)
    if data == nil then 
        return 
    end
    local bigWinUid = self:getBigWinUid()
    local time_str = os.date("%Y-%m-%d %H:%M:%S", os.time())
    self.Image_1:getChildByName("text_time"):setString(time_str)
    local index=2
    for i, v in ipairs(data or {}) do
        dump(v,"---vvv--")
        
        
            local node=self.Image_1:getChildByName("node_user"..i)
            self:initItem(node,v,bigWinUid==v.uid)
            
        
    end
    self:SetConfigAndTime()
end

function TotalResultLayer:SetConfigAndTime()
    local data = json.decode(g_mainScene._gameConfingStr)
    local conf_str=data.round.."局 "..data.maxSeatCount.."人 "
    local canPickStr= string.split(data.canpick, ",")
    dump(data,"data----SetConfigAndTime")
    for i,v in ipairs(canPickStr) do
        if v=='1' then
            conf_str=conf_str.."带赖子 "
        elseif v=='2' then
            conf_str=conf_str.."自动准备 "
        end
    end
    if data.wanfa == 0 then
        conf_str=conf_str.."经典玩法 "
    elseif data.wanfa == 1 then
        conf_str=conf_str.."比盾玩法 "
    end
    self.Image_1:getChildByName("Text_config"):setString(conf_str)
    local time_str = os.date("%Y-%m-%d %H:%M:%S", os.time())
    self.Image_1:getChildByName("text_time"):setString(time_str)

    local round_str="资溪打盾 "..SCENENOW["scene"].GameRound.."/"..data.round.."局"
    self.Image_1:getChildByName("text_round"):setString(round_str)
    self.Image_1:getChildByName("text_roomId"):setString("房间号:"..USER_INFO["invote_code"])
end

function TotalResultLayer:getBigWinUid()
    local uid = 0
    local maxSocre = 0
    for i, v in ipairs(self._data or {}) do
        if v.chips > maxSocre then
            maxSocre = v.chips
            uid = v.uid
        end
    end
    
    return uid
end

function TotalResultLayer:initItem(obj, info, isBigWin)
dump(info,"-----info---")
        local userInfo = nil
--[[    if USER_INFO["uid"] == info.uid then
        userInfo = USER_INFO
    else--]]

        userInfo = g_mainScene.userInfoByViewId[info.uid]
   -- end
    if isBigWin then
        obj:getChildByName("head_node"):getChildByName("Image_zhuang"):setVisible(false)
    end
    if userInfo == nil then return end
    local head_node=obj:getChildByName("head_node")
    obj:getChildByName("text_nickName"):setString(require("hall.GameCommon"):formatNick(userInfo.name, 6))
    obj:getChildByName("text_userId"):setString("ID:"..info.uid)
    local strHead = self:getUnformatPic(userInfo.icon_url)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        local headImg = head_node:getChildByName("img_head")
        headImg:loadTexture(imgFullPath)
    end
    for i=1,info.RoundSize do
        if info.RoundScore[i].Sigscore > 0 then 
            obj:getChildByName("text_result"..i):setVisible(true)
            obj:getChildByName("text_result"..i):setString("第"..info.RoundScore[i].roundTime.."局: +"..info.RoundScore[i].Sigscore)
        else
            obj:getChildByName("text_result"..i):setVisible(true)
            obj:getChildByName("text_result"..i):setString("第"..info.RoundScore[i].roundTime.."局: "..info.RoundScore[i].Sigscore)
        end   
    end
    --总分
    local AllScore_str=info.chips

    if info.chips > 0 then
        AllScore_str="+"..AllScore_str
        obj:getChildByName("BitmapFontLabel_4"):setFntFile(TpackageName .. "/res/font/over_win.fnt")
        obj:getChildByName("BitmapFontLabel_4"):setString(AllScore_str)
    else
        obj:getChildByName("BitmapFontLabel_4"):setFntFile(TpackageName .. "/res/font/over_lose.fnt")
        obj:getChildByName("BitmapFontLabel_4"):setString(AllScore_str)
    end

    local data = json.decode(g_mainScene._gameConfingStr)
    obj:getChildByName("text_db"):setString("底分:"..info.chips/data.baseChip.." x 倍率:"..data.baseChip)
    --obj:getChildByName("text_round"):setString(info.)

    --[[dump(obj, "obj == ")
    local cell = obj:getChildByName("cell")
    cell:getChildByName("tScore"):setString(info.chips)
    cell:getChildByName("winFlag"):setVisible(isBigWin)
    if info.chips < 0 then
        local sp = display.newSprite("zixidadun/res/image/total/lose_bg.png")
        if sp then
            cell:getChildByName("winOrLossBg"):setTexture("zixidadun/res/image/total/lose_bg.png")
        end
    end
   -- self:setUserInfo(cell, info)
    local subCell = cell:getChildByName("subCell")
    subCell:setVisible(false)
    for i,v in ipairs(info.turnchip) do
        local subItem = subCell:clone()
        subItem:setVisible(true)
        self:initSubItem(subItem, v/100, i)
        cell:getChildByName("subRecordList"):pushBackCustomItem(subItem)
    end--]]
end
--[[
function TotalResultLayer:initSubItem(obj, v, idx)
    obj:getChildByName("subIdx"):setString(string.format("第%d局", idx))
    obj:getChildByName("subScore"):setString(v or "0")
end--]]

function TotalResultLayer:getUnformatPic(url)
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

function TotalResultLayer:setUserInfo(obj, info)
    obj:getChildByName("name"):setString(require("hall.GameCommon"):formatNick(info.nickName, 4))

    local strHead = self:getUnformatPic(info.portrait)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        obj:getChildByName("headImg"):loadTexture(imgFullPath)
    end
    -- body
end

function TotalResultLayer:onClickBtnClose(sender, event)
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], USER_INFO["family_id"])
    -- require("hall.tips.CommonTips"):_gameToHall()

end

function TotalResultLayer:onClickBtnSpeedJoin(sender, event)

    require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"], TpackageName .. ".gameScene")
end

function TotalResultLayer:onClickBtnShare(sender, event)
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

function TotalResultLayer:onClickBtnShareImg(sender, event)
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

function TotalResultLayer:playingVideo(sender, event)
    if event == TOUCH_EVENT_ENDED then
        print("playing video ----------------------------")
    end
end

function TotalResultLayer:onExit()
    -- body
end

return TotalResultLayer