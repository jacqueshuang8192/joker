local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local HEZHOUMJController = class("HEZHOUMJController")

function HEZHOUMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.HEZHOUMJSendHandle"):requestHandle(controlType, value)
end

function HEZHOUMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function HEZHOUMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function HEZHOUMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.HEZHOUMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.HEZHOUMJSendHandle"):requestHandle(0, 0)
	end
end

function HEZHOUMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.HEZHOUMJSendHandle"):sendCard(value)


	local seatId = HEZHOUMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function HEZHOUMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.HEZHOUMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function HEZHOUMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.HEZHOUMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function HEZHOUMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function HEZHOUMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function HEZHOUMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function HEZHOUMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.HEZHOUMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(HEZHOUMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.HEZHOUMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function HEZHOUMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function HEZHOUMJController:requestLiang(card)
	require(TpackageName..".handle.HEZHOUMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function HEZHOUMJController:requestLiangGang()
	require(TpackageName..".handle.HEZHOUMJSendHandle"):CLI_REQUEST_LIANG_GANG(HEZHOUMJ_LG_CARDS)
end

function HEZHOUMJController:requestJiapiao(piao)
	require(TpackageName..".handle.HEZHOUMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function HEZHOUMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function HEZHOUMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function HEZHOUMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function HEZHOUMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function HEZHOUMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return HEZHOUMJController