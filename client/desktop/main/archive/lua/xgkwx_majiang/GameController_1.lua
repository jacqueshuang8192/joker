local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local XGKWXController = class("XGKWXController")

function XGKWXController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.XGKWXSendHandle"):requestHandle(controlType, value)
end

function XGKWXController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function XGKWXController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function XGKWXController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.XGKWXSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.XGKWXSendHandle"):requestHandle(0, 0)
	end
end

function XGKWXController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.XGKWXSendHandle"):sendCard(value)


	local seatId = XGKWX_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function XGKWXController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.XGKWXSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function XGKWXController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.XGKWXSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function XGKWXController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function XGKWXController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function XGKWXController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function XGKWXController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.XGKWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(XGKWX_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.XGKWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function XGKWXController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function XGKWXController:requestLiang(card)
	require(TpackageName..".handle.XGKWXSendHandle"):CLI_REQUEST_LIANG(card)
end

function XGKWXController:requestLiangGang()
	require(TpackageName..".handle.XGKWXSendHandle"):CLI_REQUEST_LIANG_GANG(XGKWX_LG_CARDS)
end

function XGKWXController:requestJiapiao(piao)
	require(TpackageName..".handle.XGKWXSendHandle"):CLI_CHOSE_PIAO(piao)
end

function XGKWXController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function XGKWXController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function XGKWXController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function XGKWXController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function XGKWXController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return XGKWXController