local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local GXLZMJController = class("GXLZMJController")

function GXLZMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.GXLZMJSendHandle"):requestHandle(controlType, value)
end

function GXLZMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function GXLZMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function GXLZMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.GXLZMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.GXLZMJSendHandle"):requestHandle(0, 0)
	end
end

function GXLZMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.GXLZMJSendHandle"):sendCard(value)


	--这个逻辑是显示 出牌后删牌的逻辑 改成到服务器消息到了以后 客户端在删牌
--[[	local seatId = GXLZMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end--]]
end

--请求解散房间
function GXLZMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.GXLZMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function GXLZMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.GXLZMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function GXLZMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function GXLZMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function GXLZMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function GXLZMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.GXLZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(GXLZMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.GXLZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function GXLZMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function GXLZMJController:requestLiang(card)
	require(TpackageName..".handle.GXLZMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function GXLZMJController:requestLiangGang()
	require(TpackageName..".handle.GXLZMJSendHandle"):CLI_REQUEST_LIANG_GANG(GXLZMJ_LG_CARDS)
end

function GXLZMJController:requestJiapiao(piao)
	require(TpackageName..".handle.GXLZMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function GXLZMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function GXLZMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function GXLZMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function GXLZMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function GXLZMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return GXLZMJController