local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local JXMJController = class("JXMJController")

function JXMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.JXMJSendHandle"):requestHandle(controlType, value)
end

function JXMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function JXMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end

function JXMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.JXMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.JXMJSendHandle"):requestHandle(0, 0)
	end
end

function JXMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.JXMJSendHandle"):sendCard(value)


	--[[local seatId = JXMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end--]]
end

--请求解散房间
function JXMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.JXMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function JXMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.JXMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function JXMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function JXMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function JXMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function JXMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.JXMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(JXMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.JXMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function JXMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function JXMJController:requestLiang(card)
	require(TpackageName..".handle.JXMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function JXMJController:requestLiangGang()
	require(TpackageName..".handle.JXMJSendHandle"):CLI_REQUEST_LIANG_GANG(JXMJ_LG_CARDS)
end

function JXMJController:requestJiapiao(piao)
	require(TpackageName..".handle.JXMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function JXMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function JXMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function JXMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function JXMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function JXMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

function JXMJController:requestJiapiao(piao)
	require(TpackageName..".handle.JXMJSendHandle"):CLI_CHOSE_PIAO(piao)
end

function JXMJController:choiceGenDa(value)
	require(TpackageName..".handle.JXMJSendHandle"):CLI_CHOSE_GENDA(value)
end

return JXMJController