local UserInfoView = class("UserInfoView")
local PokerCard = require("hz_majiang.src.PokerCard")
local SoundUtils = require("hz_majiang.src.SoundUtils")
local OutCardView = require("hz_majiang.src.view.OutCardView")
local PAndGView = require("hz_majiang.src.view.PAndGView")
local HandCardView = require("hz_majiang.src.view.HandCardView")
local OtherHandCardView = require("hz_majiang.src.view.OtherHandCardView")
function UserInfoView:ctor(player, cards_vw, GameSceneView)
    self.player = player
    self.cards_vw = cards_vw
    self.player:hide()
    self.name = self.player:getName()
    self.viewId = 0
	if self.name == "player_1" then
		self.viewId = g_308.viewId_my
	elseif self.name == "player_2" then
		self.viewId = g_308.viewId_top
	elseif self.name == "player_3" then
		self.viewId = g_308.viewId_right
	elseif self.name == "player_4" then
		self.viewId = g_308.viewId_left
    end

    if self.name == "player_1" then
        self.HandCardView = HandCardView.new(GameSceneView, cards_vw.inhand_vw)
    else
        self.HandCardView = OtherHandCardView.new(cards_vw.inhand_vw, self.viewId)
    end

    self:initUI(player)
    self.player:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
    self.OutCardView = OutCardView.new(cards_vw.out_cards_vw, cards_vw:getParent().card_pointer, self.viewId)
    self.PAndGView = PAndGView.new(cards_vw.PAndG_vw, self.viewId)
end

function UserInfoView:initUI()
    self.txt_score = self.player.txt_score:setString("")
    self.txt_name = self.player.txt_name:setString("")
    self.img_zhuang = self.player.img_zhuang:hide()
    self.img_network = self.player.img_network:hide()
    self.img_shine = self.player.img_shine:hide()
    self.img_ready = self.player.img_ready:hide()
    self.pengAndGang = self.cards_vw.pengAndGang:hide()
    self.img_head = self.player.img_head
    self.worldpoint = (self.img_head:getParent()):convertToWorldSpace(self.img_head:getPosition()) --这样写是为了贴近函数的原始用法
end

function UserInfoView:refreshPlayerInfo(icon_url, uid, sex, name, ip, addres)
    local size = self.img_head:getContentSize()
    
    if g_308.gameConfig.model == 1 then  --黑夜模式
		self.img_head:loadTexture("hz_majiang/res/GameScene/player/headimg.png")
		self.txt_name:setString("黑衣人")
	else
		require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.img_head, size.width, false, name, false, ip, addres)
	    name = require("hall.GameCommon"):formatNick(name, 3)
        self.txt_name:setString(name or "")
    end
    
	
end

function UserInfoView:clearData()
    self:isShowLight(false) 
    self:isShowZhuang(false) 
    self:isShowReady(false) 
  
    self.HandCardView:clearData()
    self.OutCardView:clearData()
    self.PAndGView:clearData()
end

function UserInfoView:getWorldpoint()
    return self.worldpoint
end

--刷新玩家的积分分数
function UserInfoView:setScore(score)
	self.txt_score:setString(tonumber(score) / 100)
end

function UserInfoView:isShowZhuang(isShow) 
	self.img_zhuang:setVisible(isShow)
end

function UserInfoView:isShowReady(isShow) 
	self.img_ready:setVisible(isShow)
end

function UserInfoView:isShowNewWork(isShow) 
	self.img_network:setVisible(isShow)
end

function UserInfoView:isShowLight(isShow) 
	self.img_shine:setVisible(isShow)
    self.img_shine:stopAllActions()
    if isShow == true then
        local fadeTo1 = cc.FadeTo:create(1.3, 50)
        local fadeTo2 = cc.FadeTo:create(1.3, 255)
        local seqAc = cc.Sequence:create(fadeTo1, fadeTo2)
        self.img_shine:runAction(cc.RepeatForever:create(seqAc))
    end
end

function UserInfoView:showImgTxt(type_)
    local img_type = ""
	if bit.band(type_, g_308.t_hu) > 0 then
		img_type = "hu"
		if bit.band(type_, g_308.hu_zm) > 0 then
			img_type = "zimo"		
		end
	elseif bit.band(type_, g_308.t_gang) > 0 then
		img_type = "gang"
	elseif bit.band(type_, g_308.t_peng) > 0 then
		img_type = "peng"
	elseif bit.band(type_, g_308.t_chi) > 0 then
		img_type = "chi"
	end
    self.pengAndGang:show()
    local anim = self.pengAndGang:getAnimation()
    anim:playWithNames({img_type}, 0, false)
    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
        end
    end
    anim:setMovementEventCallFunc(handler1)
    self.time = 2
end

function UserInfoView:show( )
    self.player:setVisible(true)
end

function UserInfoView:hide( )
    self.player:setVisible(false)
    self:clearData()
    self.img_head:removeAllChildren()
end

function UserInfoView:update( dt )
    if self.time then
        self.time = self.time - dt
        if self.time <= 0 then
            self.time = nil
            self.pengAndGang:hide()
            
        end
    end
end

return UserInfoView
