--[[
* author:   zwm
* date:     2020-05-28
* describe: 510k小结算界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local NewViewBaseLayer = require("hall.NewViewBaseLayer")

local ViewBaseLayer = require("hall.ViewBaseLayer")
local SingleResultLayer = class("SingleResultLayer", NewViewBaseLayer)
local Card = require(TpackageName..".src.view.Card")
local zixidadunServer = import(TpackageName .. ".src.protocol.zixidadunServer")

local CELL_POS_X = 35
local CELL_POS_Y_BEGIN = 493
local CELL_POS_Y_INTERVAL = 124

function SingleResultLayer:ctor(data)
    SingleResultLayer.super.ctor(self, "zixidadun/res/SingleResultLayer.csb")
    self._data = data
    --dump(data, "SingleResultLayer == ")
    GameUtils.setNodeNameBindObj(self._csbNode)
    display.doLayout(self._csbNode)
    self:enableMask(true)
    
    --local userInfo = g_mainScene.userInfoByViewId[info.Uid]
    --self:setUserInfo(self.Image_1, userInfo)
   -- self:__initUI()
    self:showResult(self._data.playerList)

    self.Image_1:getChildByName("BtnClose"):onClick(handler(self, self.onClickBtnClose), true)
    self.Image_1:getChildByName("BtnTable"):onClick(handler(self, self.onClickBtnTable), true)
    self.Image_1:getChildByName("BtnContinue"):onClick(handler(self, self.onClickBtnContinue), true)
    self.Image_1:getChildByName("BtnShare"):onClick(handler(self, self.onClickBtnShare), true)
    self.make:onTouch(handler(self, self.onClick_vw), false)
end


function SingleResultLayer:onClick_vw(event)
    if event.name == "began" then
        dump("定时器------------------------------")
      
            if self  then
                self:hide()
                self.maskLayout:hide()
               -- self.btn_jixu:hide()
            end
     
    elseif event.name == "ended" then
        
            dump("清除定时器------------------------------")
            self:show()
            self.maskLayout:show()
            --self.btn_jixu:show()

    elseif event.name == "cancelled" then

            self:show()
            self.maskLayout:show()
           -- self.btn_jixu:show()
          
        
    end
end

function SingleResultLayer:__initUI()
--[[    self.rankFlag:setVisible(false)
    self.light1:setVisible(false)
    self.light2:setVisible(false)
    self.light3:setVisible(false)
    self.light4:setVisible(false)--]]
    -- self.cell1:setVisible(false)
    -- self.cell2:setVisible(false)
    -- self.cell3:setVisible(false)
    -- self.cell4:setVisible(false)
   -- dump(USER_INFO, "USER_INFO == ")
    -- self["light"..USER_INFO["seat_id"]]:setVisible(true)
end

function SingleResultLayer:__initUserInfo(obj)
    obj:getChildByName("Node_head"):getChildByName("Image_fangzhu"):setVisible(false)
    obj:getChildByName("Node_head"):getChildByName("Image_zhuang"):setVisible(false)
    obj:getChildByName("Text_dunfen"):setString("")
    obj:getChildByName("Text_paijujieguo"):setString("")
    obj:getChildByName("Text_benjuScore"):setString("")
    obj:getChildByName("text_AllScore_win"):setVisible(false)
    obj:getChildByName("text_AllScore_lose"):setVisible(false)
    obj:getChildByName("Image_rank"):setVisible(false)

end

function SingleResultLayer:showResult(data)
    if data == nil then return end
    dump(data, "showResult(data) == ")
    local index=1
    for i,v in ipairs(data) do
      --  local item = require("zixidadun.src.view.SingleCell").new(v)

        local obj=self.Image_1:getChildByName("Image_user"..index)
        self:__initUserInfo(obj)
        self:setUserInfo(obj,v)
        index=1+index
        --item:setVisible(true)
       -- item:setPosition(cc.p(35, 494- (i-1)*124))
        -- self:initItem(item, v)
        --self.content:addChild(item)
    end
    --self:showOtherCard(self._data.otherCards)
    local dataSig = json.decode(g_mainScene._gameConfingStr)
    local conf_str=dataSig.round.."局 "..dataSig.maxSeatCount.."人 "
    local canPickStr= string.split(dataSig.canpick, ",")
    for i,v in ipairs(canPickStr) do
        if v=='1' then
            conf_str=conf_str.."带赖子 "
        elseif v=='2' then
            conf_str=conf_str.."自动准备 "
        end
    end
    if dataSig.wanfa == 1 then
        conf_str=conf_str.."经典玩法 "
    elseif data.wanfa == 2 then
        conf_str=conf_str.."比盾玩法 "
    end
    self.Image_1:getChildByName("Text_config"):setString(conf_str)

end

function SingleResultLayer:setUserInfo(obj, info)
        local userInfo = nil
--[[    if USER_INFO["uid"] == info.Uid then
        userInfo = USER_INFO
    else--]]
        userInfo = g_mainScene.userInfoByViewId[info.Uid]
   -- end
    if userInfo == nil then return end
    local head_node=obj:getChildByName("Node_head")
    head_node:getChildByName("Text_nickname"):setString(require("hall.GameCommon"):formatNick(userInfo.name, 6))
    head_node:getChildByName("Text_id"):setString("ID:"..info.Uid)
    local strHead = self:getUnformatPic(userInfo.icon_url)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        local headImg = head_node:getChildByName("img_head")
        headImg:loadTexture(imgFullPath)
    end
    if info.Rank==1 then
       obj:getChildByName("Image_rank"):loadTexture("zixidadun/res/image/img_touyou.png")
       obj:getChildByName("Image_rank"):setVisible(true)
    elseif info.Rank==2 then
        obj:getChildByName("Image_rank"):loadTexture("zixidadun/res/image/img_eryou.png")
        obj:getChildByName("Image_rank"):setVisible(true)
    end
    obj:getChildByName("Text_dunfen"):setString(info.Jiangscore)
    obj:getChildByName("Text_benjuScore"):setString(info.Turningscore)
    obj:getChildByName("Text_paijujieguo"):setString(0)
    if info.TotalFen>0 then
        obj:getChildByName("text_AllScore_win"):setVisible(true)
        obj:getChildByName("text_AllScore_win"):setString("+"..info.TotalFen)
    else
        obj:getChildByName("text_AllScore_lose"):setVisible(true)
        obj:getChildByName("text_AllScore_lose"):setString(info.TotalFen)
    end
    --显示剩余手牌和奖牌
    if info.lefthandCardcount >0 and info.leftHandCard then
        self:setLeftOrJiangCard(obj:getChildByName("ListView_hand"),info.leftHandCard,true)
    end
    dump(info.Jiangbuf,"info.Jiangbuf")
    dump(info.Jiangscore,"info.Jiangscore")
    if info.Jiangscore>0 and info.Jiangbuf then
        self:setLeftOrJiangCard(obj:getChildByName("ListView_jiang"),info.Jiangbuf,false)
    end
end


function SingleResultLayer:setLeftOrJiangCard(obj, value,isHand)
    dump(value,"----value----")
   -- obj:setBounceEnabled(true)                             -- 滑动惯性
   obj:setScrollBarEnabled(false)       --隐藏滚动条
   obj:removeAllChildren()
   

    if isHand then
        local indx=200
        obj:setItemsMargin(-5)--设置间距
--[[        local panel_my = ccui.Layout:create()
        panel_my:setAnchorPoint(cc.p(0,0))--]]
        local CardData=g_mainScene.playerInfoLayer:exchangeCardsValue(value)
        for i,v in ipairs(CardData) do       
            local hcard = Card:getEndCard(v, 1 , not relogin)
           hcard:setVisible(true)
           --hcard:setAnchorPoint(cc.p(0,0))
            --设置i尺寸
           -- hcard:setContentSize(cc.size(48, 60))
            --hcard:setScale(60/220)
            hcard:ignoreContentAdaptWithSize(true)
           --hcard:setPosition(cc.p(indx,-30))
           -- panel_my:addChild(hcard)
             obj:pushBackCustomItem(hcard)

--[[
             local hacan=hcard:clone()
             hacan:setPosition(cc.p(indx,360))
             self:addChild(hacan)--]]
            
            indx=indx+26
        end
        
    else
            obj:setItemsMargin(-5)--设置间距
        for i,v in ipairs(value) do
            --local panel_my=self.Panel_Card:clone()
      --[[       local panel_my = ccui.ImageView:create()
             panel_my:setAnchorPoint(cc.p(0,0))--]]
             local CardData=g_mainScene.playerInfoLayer:exchangeCardsValue(v.Cardbuf)
            for _,j in ipairs(CardData) do

                    dump(tab,"--tab--")
                local hcard = Card:getEndCard(j, 1 , not relogin)

                hcard:setVisible(true)
                obj:pushBackCustomItem(hcard)

                --obj:setItemsMargin(-15)--设置间距
            end
            --obj:setItemsMargin(15)--设置间距
            
        end
    end
end


function SingleResultLayer:getUnformatPic(url)
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


function SingleResultLayer:onClickBtnClose(sender, event)
    self:removeSelf()
    -- CardPlaneOperator:clearGameDatas()
    
    if g_zxddGameData.IsOver then
        g_mainScene:showAllResultLayer(g_zxddGameData.IsOverData)
    else
        zixidadunServer:CLI_READY_GAME(1)
    end
end

function SingleResultLayer:onClickBtnTable(sender, event)
    self:removeSelf()
	-- CardPlaneOperator:clearGameDatas()
        if g_zxddGameData.IsOver then
        g_mainScene:showAllResultLayer(g_zxddGameData.IsOverData)
    else
        zixidadunServer:CLI_READY_GAME(1)
    end
end

function SingleResultLayer:onClickBtnContinue(sender, event)
    self:removeSelf()
    -- CardPlaneOperator:clearGameDatas()
        if g_zxddGameData.IsOver then
        g_mainScene:showAllResultLayer(g_zxddGameData.IsOverData)
    else
        zixidadunServer:CLI_READY_GAME(1)
    end
end

function SingleResultLayer:onClickBtnShare(sender, event)
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

--[[function SingleResultLayer:onClickBtnShuffle(sender, event)
    self:removeSelf()
    -- CardPlaneOperator:clearGameDatas()
    zixidadunServer:CLIENT_USER_SHUFFLE()
    zixidadunServer:CLI_READY_GAME(1)
    
end--]]

function SingleResultLayer:onExit()
    -- body
end

return SingleResultLayer