local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local GXHCMJController = class("GXHCMJController")

function GXHCMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.GXHCMJSendHandle"):requestHandle(controlType, value)
end

function GXHCMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function GXHCMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function GXHCMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.GXHCMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.GXHCMJSendHandle"):requestHandle(0, 0)
	end
end

function GXHCMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.GXHCMJSendHandle"):sendCard(value)


	local seatId = GXHCMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function GXHCMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.GXHCMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function GXHCMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.GXHCMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function GXHCMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function GXHCMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function GXHCMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function GXHCMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.GXHCMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(GXHCMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.GXHCMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function GXHCMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function GXHCMJController:requestLiang(card)
	require(TpackageName..".handle.GXHCMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function GXHCMJController:requestLiangGang()
	require(TpackageName..".handle.GXHCMJSendHandle"):CLI_REQUEST_LIANG_GANG(GXHCMJ_LG_CARDS)
end

function GXHCMJController:requestJiapiao(piao)
	require(TpackageName..".handle.GXHCMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function GXHCMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function GXHCMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function GXHCMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function GXHCMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function GXHCMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return GXHCMJController