local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local CSMJController = class("CSMJController")

function CSMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.CSMJSendHandle"):requestHandle(controlType, value)
end

function CSMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function CSMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function CSMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.CSMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.CSMJSendHandle"):requestHandle(0, 0)
	end
end

function CSMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.CSMJSendHandle"):sendCard(value)


	--这个逻辑是显示 出牌后删牌的逻辑 改成到服务器消息到了以后 客户端在删牌
	--[[local seatId = CSMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end--]]
end

--请求解散房间
function CSMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.CSMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function CSMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.CSMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function CSMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function CSMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function CSMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function CSMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.CSMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(CSMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.CSMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function CSMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function CSMJController:requestLiang(card)
	require(TpackageName..".handle.CSMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function CSMJController:requestLiangGang()
	require(TpackageName..".handle.CSMJSendHandle"):CLI_REQUEST_LIANG_GANG(CSMJ_LG_CARDS)
end

function CSMJController:requestJiapiao(piao)
	require(TpackageName..".handle.CSMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function CSMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function CSMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function CSMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function CSMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function CSMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

function CSMJController:requestJiapiao(piao)
	require(TpackageName..".handle.CSMJSendHandle"):CLI_CHOSE_PIAO(piao)
end

return CSMJController