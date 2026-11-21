local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local XLCHMJController = class("XLCHMJController")

function XLCHMJController:control(controlType, value)
	if D3_CHUPAI == 2 and controlType ~= CONTROL_TYPE_BAOJIAO and  XLCH_can_out_card == 0 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.XLCHMJSendHandle"):requestHandle(controlType, value)
end

function XLCHMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function XLCHMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function XLCHMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.XLCHMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.XLCHMJSendHandle"):requestHandle(0, 0)
	end
end

function XLCHMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.XLCHMJSendHandle"):sendCard(value)


	local seatId = XLCHMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function XLCHMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.XLCHMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function XLCHMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.XLCHMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function XLCHMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function XLCHMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function XLCHMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function XLCHMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.XLCHMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(XLCHMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.XLCHMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function XLCHMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function XLCHMJController:requestLiang(card)
	require(TpackageName..".handle.XLCHMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function XLCHMJController:requestLiangGang()
	require(TpackageName..".handle.XLCHMJSendHandle"):CLI_REQUEST_LIANG_GANG(XLCHMJ_LG_CARDS)
end

function XLCHMJController:requestJiapiao(piao)
	require(TpackageName..".handle.XLCHMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function XLCHMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function XLCHMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function XLCHMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function XLCHMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function XLCHMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return XLCHMJController