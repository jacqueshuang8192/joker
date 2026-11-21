local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local SZKWXController = class("SZKWXController")

function SZKWXController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.SZKWXSendHandle"):requestHandle(controlType, value)
end

function SZKWXController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function SZKWXController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function SZKWXController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.SZKWXSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.SZKWXSendHandle"):requestHandle(0, 0)
	end
end

function SZKWXController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.SZKWXSendHandle"):sendCard(value)


	local seatId = SZKWX_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function SZKWXController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.SZKWXSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function SZKWXController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.SZKWXSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function SZKWXController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function SZKWXController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function SZKWXController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function SZKWXController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.SZKWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(SZKWX_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.SZKWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function SZKWXController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function SZKWXController:requestLiang(card)
	require(TpackageName..".handle.SZKWXSendHandle"):CLI_REQUEST_LIANG(card)
end

function SZKWXController:requestLiangGang()
	require(TpackageName..".handle.SZKWXSendHandle"):CLI_REQUEST_LIANG_GANG(SZKWX_LG_CARDS)
end

function SZKWXController:requestJiapiao(piao)
	require(TpackageName..".handle.SZKWXSendHandle"):CLI_CHOSE_PIAO(piao)
end

function SZKWXController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function SZKWXController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function SZKWXController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function SZKWXController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function SZKWXController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return SZKWXController