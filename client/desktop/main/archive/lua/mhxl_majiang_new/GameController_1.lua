local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local MHXLMJController = class("MHXLMJController")

function MHXLMJController:control(controlType, value)
	if D3_CHUPAI == 2 and controlType ~= CONTROL_TYPE_BAOJIAO and  MHXL_can_out_card == 0 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.MHXLMJSendHandle"):requestHandle(controlType, value)
end

function MHXLMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function MHXLMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function MHXLMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.MHXLMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.MHXLMJSendHandle"):requestHandle(0, 0)
	end
end

function MHXLMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.MHXLMJSendHandle"):sendCard(value)


	local seatId = MHXLMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function MHXLMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.MHXLMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function MHXLMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.MHXLMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function MHXLMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function MHXLMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function MHXLMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function MHXLMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.MHXLMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(MHXLMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.MHXLMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function MHXLMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function MHXLMJController:requestLiang(card)
	require(TpackageName..".handle.MHXLMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function MHXLMJController:requestLiangGang()
	require(TpackageName..".handle.MHXLMJSendHandle"):CLI_REQUEST_LIANG_GANG(MHXLMJ_LG_CARDS)
end

function MHXLMJController:requestJiapiao(piao)
	require(TpackageName..".handle.MHXLMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function MHXLMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function MHXLMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function MHXLMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function MHXLMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function MHXLMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return MHXLMJController