local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local YJMJController = class("YJMJController")

function YJMJController:control(controlType, value)
	if D3_CHUPAI == 2 and controlType ~= CONTROL_TYPE_BAOJIAO then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.YJMJSendHandle"):requestHandle(controlType, value)
end

function YJMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function YJMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function YJMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.YJMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.YJMJSendHandle"):requestHandle(0, 0)
	end
end

function YJMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.YJMJSendHandle"):sendCard(value)


	local seatId = YJMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function YJMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.YJMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function YJMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.YJMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function YJMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function YJMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function YJMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function YJMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.YJMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(YJMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.YJMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function YJMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function YJMJController:requestLiang(card)
	require(TpackageName..".handle.YJMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function YJMJController:requestLiangGang()
	require(TpackageName..".handle.YJMJSendHandle"):CLI_REQUEST_LIANG_GANG(YJMJ_LG_CARDS)
end

function YJMJController:requestJiapiao(piao)
	require(TpackageName..".handle.YJMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function YJMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function YJMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function YJMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function YJMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function YJMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return YJMJController