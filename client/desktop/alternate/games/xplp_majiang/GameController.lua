local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local XPLPMJController = class("XPLPMJController")

function XPLPMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.XPLPMJSendHandle"):requestHandle(controlType, value)
end

function XPLPMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function XPLPMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function XPLPMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.XPLPMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.XPLPMJSendHandle"):requestHandle(0, 0)
	end
end

function XPLPMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.XPLPMJSendHandle"):sendCard(value)
	local iszidong = true
	if iszidong then
		return--等服务器消息来了在删牌
	end

	local seatId = XPLPMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function XPLPMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.XPLPMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function XPLPMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.XPLPMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function XPLPMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function XPLPMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function XPLPMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function XPLPMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.XPLPMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(XPLPMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.XPLPMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function XPLPMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function XPLPMJController:requestLiang(card)
	require(TpackageName..".handle.XPLPMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function XPLPMJController:requestLiangGang()
	require(TpackageName..".handle.XPLPMJSendHandle"):CLI_REQUEST_LIANG_GANG(XPLPMJ_LG_CARDS)
end

--[[function XPLPMJController:requestJiapiao(piao)
	require(TpackageName..".handle.XPLPMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end--]]

function XPLPMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function XPLPMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function XPLPMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function XPLPMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function XPLPMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

function XPLPMJController:requestJiapiao(piao)
	require(TpackageName..".handle.XPLPMJSendHandle"):CLI_CHOSE_PIAO(piao)
end

function XPLPMJController:requestGuChou(num)
	require(TpackageName..".handle.XPLPMJSendHandle"):CLI_CHOSE_GUCHOU(num)
end


return XPLPMJController