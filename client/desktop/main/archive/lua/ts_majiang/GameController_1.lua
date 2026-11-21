local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local TSMJController = class("TSMJController")

function TSMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.TSMJSendHandle"):requestHandle(controlType, value)
end

function TSMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function TSMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function TSMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.TSMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.TSMJSendHandle"):requestHandle(0, 0)
	end
end

function TSMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.TSMJSendHandle"):sendCard(value)


	local seatId = TSMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function TSMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.TSMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function TSMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.TSMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function TSMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function TSMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function TSMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function TSMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.TSMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(TSMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.TSMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function TSMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function TSMJController:requestLiang(card)
	require(TpackageName..".handle.TSMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function TSMJController:requestLiangGang()
	require(TpackageName..".handle.TSMJSendHandle"):CLI_REQUEST_LIANG_GANG(TSMJ_LG_CARDS)
end

function TSMJController:requestJiapiao(piao)
	require(TpackageName..".handle.TSMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function TSMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function TSMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function TSMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function TSMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function TSMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return TSMJController