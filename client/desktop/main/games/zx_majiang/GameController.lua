local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local ZXMJController = class("ZXMJController")

function ZXMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.ZXMJSendHandle"):requestHandle(controlType, value)
end

function ZXMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function ZXMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function ZXMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.ZXMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.ZXMJSendHandle"):requestHandle(0, 0)
	end
end

function ZXMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.ZXMJSendHandle"):sendCard(value)


	--这个逻辑是显示 出牌后删牌的逻辑 改成到服务器消息到了以后 客户端在删牌
--[[	local seatId = ZXMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end--]]
end

--请求解散房间
function ZXMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.ZXMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function ZXMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.ZXMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function ZXMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function ZXMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function ZXMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function ZXMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.ZXMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(ZXMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.ZXMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function ZXMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function ZXMJController:requestLiang(card)
	require(TpackageName..".handle.ZXMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function ZXMJController:requestLiangGang()
	require(TpackageName..".handle.ZXMJSendHandle"):CLI_REQUEST_LIANG_GANG(ZXMJ_LG_CARDS)
end

function ZXMJController:requestJiapiao(piao)
	require(TpackageName..".handle.ZXMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function ZXMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function ZXMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function ZXMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function ZXMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function ZXMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return ZXMJController