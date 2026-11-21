local UserInfoView = class("UserInfoView")
local PokerCard = require("zhajinhua_jb.src.PokerCard")
local SoundUtils = require("zhajinhua_jb.src.SoundUtils")
function UserInfoView:ctor(player)
    self:initUI(player)
    self.totalValue = 0--用户总下注
end

function UserInfoView:initUI(player, reload)
    self.player = player
    self.name = player:getName()
    player:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
    self.txt_score = player.txt_score:setString("")
    self.txt_score1 = player.txt_score1:hide()--小局积分
    self.txt_name = player.txt_name:setString("")
    self.img_zhuang = player.img_zhuang:hide()
    self.img_fangZhu = player.img_fangZhu:hide()
    self.img_network = player.img_network:hide()
    self.img_shine = player.img_shine:hide()
    self.img_2 = player.img_2--比牌点击用
    self.img_qi = player.img_qi:hide()
    self.txt_qiang = player.txt_qiang:hide()
    self.chip_img = player.chip_img:hide()
    self.img_ready = player.img_ready:hide()
    self.inhand_vw = player.inhand_vw
    self.img_head = player.img_head
    self.worldpoint = (self.img_head:getParent()):convertToWorldSpace(self.img_head:getPosition()) --这样写是为了贴近函数的原始用法
    if self.name == "player_1" then
        self.card_type = player.card_type:hide()
        local getWinSize = cc.Director:getInstance():getWinSize()
        local inhandSize = player:getContentSize()
        local pos = player:convertToNodeSpace(cc.p(getWinSize.width / 2, getWinSize.height / 2))
        self.card_type:setPositionX(pos.x)
        self.img_qi:setPositionX(pos.x)
        self.inhand_vw:setPositionX(pos.x)
    end
    if not reload then
        self.inhand_vw:removeAllChildren()
    end 
end

function UserInfoView:refreshPlayerInfo(icon_url, uid, sex, name, ip, addres)
	local size = self.img_head:getContentSize()
	require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.img_head, size.width, false, name, false, ip, addres)
	name = require("hall.GameCommon"):formatNick(name, 3)
    self.txt_name:setString(name or "")
end

function UserInfoView:clearData()
    self:isShowLight(false) 
    self:isShowZhuang(false) 
    self:isShowReady(false) 
    self:isShowChip(false) 
    self:isShowQiang(false) 
    self:isShowFangZhu(false) 
    self:isShowCardType(false) 
    self:isShowQi(false) 
    self.txt_score1:hide()--小局积分
    self.inhand_vw:removeAllChildren()
    self.totalValue = 0--用户总下注

end

function UserInfoView:getWorldpoint()
    return self.worldpoint
end

--刷新玩家的积分分数
function UserInfoView:setScore(score)
	self.txt_score:setString(tonumber(score) / 100)
end

function UserInfoView:setScore1(score)
    score = tonumber(score) / 100
    self.txt_score1:show()
    self.txt_score1:stopAllActions()
    if score > 0 then
        score = "+"..score
        self.txt_score1:setFntFile("zhajinhua_jb/res/GameScene/player/win_num.fnt")
    else
        self.txt_score1:setFntFile("zhajinhua_jb/res/GameScene/player/lose_num.fnt")
    end
	self.txt_score1:setString(score)
    local FadeIn = cc.FadeIn:create(0.2)
    local FadeOut = cc.FadeOut:create(0.2)
    local delay= cc.DelayTime:create(2)
    local seq = cc.Sequence:create(FadeIn, delay, FadeOut)
    self.txt_score1:runAction(seq)
end

function UserInfoView:isShowQiang(isShow, value)
	self.txt_qiang:setVisible(isShow)
    value = tonumber(value) or 0
    local str = "抢x"
    if value == 0 then
        str = "不抢"
    else
        str = str..value
    end
    self.txt_qiang:setString(str)
end

function UserInfoView:isShowChip(isShow, value, isAdd)
	self.chip_img:setVisible(isShow)
    value = tonumber(value) or 0
    if isAdd then
        value = self.totalValue + value
    end 
    self.totalValue = value--用户总下注
    value = value / 100
    self.chip_img.txt_zhuScore:setString(value)
end

function UserInfoView:isShowZhuang(isShow) 
	self.img_zhuang:setVisible(isShow)
end

function UserInfoView:isShowFangZhu(isShow) 
	self.img_fangZhu:setVisible(isShow)
end

function UserInfoView:isShowQi(isShow, isKan) 
    self.img_qi:setVisible(isShow)
    if isKan then
        self.img_qi:loadTexture("zhajinhua_jb/res/GameScene/player/icon_5.png")
    else
        self.img_qi:loadTexture("zhajinhua_jb/res/GameScene/player/icon_8.png")
    end
    self.img_qi:ignoreContentAdaptWithSize(true)
end

function UserInfoView:isShowReady(isShow) 
	self.img_ready:setVisible(isShow)
end

function UserInfoView:isShowNewWork(isShow) 
	self.img_network:setVisible(isShow)
end

function UserInfoView:isShowLight(isShow) 
    self.img_shine:stopAllActions()
	self.img_shine:setVisible(isShow)
    if isShow then
        local Blink = cc.Blink:create(0.5, 2)
        local RepeatForever = cc.RepeatForever:create(Blink)
        self.img_shine:runAction(RepeatForever)
    end
end

function UserInfoView:setCards(cards)
    local childs = self.inhand_vw:getChildren()
    for idx, node in ipairs(childs) do
        node:setCard(cards[idx])
    end
end

function UserInfoView:isShowCardType(isShow, value) 
    if self.name ~= "player_1" then
        return
    end
    self.card_type:setVisible(isShow)
    if value then
        self.card_type:loadTexture("zhajinhua_jb/res/card_type/"..value..".png")
        self.card_type:ignoreContentAdaptWithSize(true)
        SoundUtils:playCardKindEffect(value)
    end
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
    
end

return UserInfoView
