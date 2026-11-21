local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local HZMJController = class("HZMJController")

function HZMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.HZMJSendHandle"):requestHandle(controlType, value)
end

function HZMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function HZMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end

function HZMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.HZMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.HZMJSendHandle"):requestHandle(0, 0)
	end
end

function HZMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.HZMJSendHandle"):sendCard(value)


	local seatId = HZMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function HZMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.HZMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function HZMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.HZMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function HZMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function HZMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function HZMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function HZMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.HZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(HZMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.HZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function HZMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function HZMJController:requestLiang(card)
	require(TpackageName..".handle.HZMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function HZMJController:requestLiangGang()
	require(TpackageName..".handle.HZMJSendHandle"):CLI_REQUEST_LIANG_GANG(HZMJ_LG_CARDS)
end

function HZMJController:requestJiapiao(piao)
	require(TpackageName..".handle.HZMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function HZMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function HZMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function HZMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function HZMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function HZMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

function HZMJController:requestJiapiao(piao)
	require(TpackageName..".handle.HZMJSendHandle"):CLI_CHOSE_PIAO(piao)
end

return HZMJController