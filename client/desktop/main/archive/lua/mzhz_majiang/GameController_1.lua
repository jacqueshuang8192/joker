local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local ZZMJController = class("ZZMJController")

function ZZMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.ZZMJSendHandle"):requestHandle(controlType, value)
end

function ZZMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function ZZMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function ZZMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.ZZMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.ZZMJSendHandle"):requestHandle(0, 0)
	end
end

function ZZMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.ZZMJSendHandle"):sendCard(value)


	local seatId = ZZMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function ZZMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.ZZMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function ZZMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.ZZMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function ZZMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function ZZMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function ZZMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function ZZMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.ZZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(ZZMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.ZZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function ZZMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function ZZMJController:requestLiang(card)
	require(TpackageName..".handle.ZZMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function ZZMJController:requestLiangGang()
	require(TpackageName..".handle.ZZMJSendHandle"):CLI_REQUEST_LIANG_GANG(ZZMJ_LG_CARDS)
end

function ZZMJController:requestJiapiao(piao)
	require(TpackageName..".handle.ZZMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function ZZMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function ZZMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function ZZMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function ZZMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function ZZMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return ZZMJController