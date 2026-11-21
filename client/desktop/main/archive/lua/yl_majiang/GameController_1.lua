local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local YLMJController = class("YLMJController")

function YLMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.YLMJSendHandle"):requestHandle(controlType, value)
end

function YLMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function YLMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end

function YLMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.YLMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.YLMJSendHandle"):requestHandle(0, 0)
	end
end

function YLMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.YLMJSendHandle"):sendCard(value)


	local seatId = YLMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function YLMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.YLMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function YLMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.YLMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function YLMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function YLMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function YLMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function YLMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.YLMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(YLMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.YLMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function YLMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function YLMJController:requestLiang(card)
	require(TpackageName..".handle.YLMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function YLMJController:requestLiangGang()
	require(TpackageName..".handle.YLMJSendHandle"):CLI_REQUEST_LIANG_GANG(YLMJ_LG_CARDS)
end

function YLMJController:requestJiapiao(piao)
	require(TpackageName..".handle.YLMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function YLMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function YLMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function YLMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function YLMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function YLMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

function YLMJController:requestJiapiao(piao)
	require(TpackageName..".handle.YLMJSendHandle"):CLI_CHOSE_PIAO(piao)
end

return YLMJController