local cardUtils = require(TpackageName..".utils.cardUtils")
local voiceUtils = require(TpackageName..".utils.VoiceUtils")
local CXZMJController = class("CXZMJController")

function CXZMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require(TpackageName..".handle.CXZMJSendHandle"):requestHandle(controlType, value)
end

function CXZMJController:showSameCard(value)
    require(TpackageName..".operator.GamePlaneOperator"):showSameCard(value)
end

function CXZMJController:hideSameCard()
	require(TpackageName..".operator.GamePlaneOperator"):hideSameCard()
end


function CXZMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require(TpackageName..".handle.CXZMJSendHandle"):requestHandle(0x2000, 0)
	else
		require(TpackageName..".handle.CXZMJSendHandle"):requestHandle(0, 0)
	end
end

function CXZMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    -- self:hideSameCard()
	self:hideControlPlane()--碰杠胡按钮隐藏
	local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
	GamePlaneOperator:didSelectOutCard(value)
	require(TpackageName..".handle.CXZMJSendHandle"):sendCard(value)


	local seatId = CXZMJ_SEAT_TABLE[	USER_INFO.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	local tag = cardUtils:playCard(seatId, value)
	GamePlaneOperator:playCard(playerType, tag, value)
	voiceUtils:playCardSound(seatId, value)
	if playerType == CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end
end

--请求解散房间
function CXZMJController:C2G_CMD_DISSOLVE_ROOM()
    require(TpackageName..".handle.CXZMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function CXZMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require(TpackageName..".handle.CXZMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function CXZMJController:showTingCards(tingSeq)
	require(TpackageName..".operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function CXZMJController:hideTingHuPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideTingHuPlane()
end

function CXZMJController:showTingHuPlane(playerType, tingHuCards)
	require(TpackageName..".operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function CXZMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require(TpackageName..".handle.CXZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(CXZMJ_ROOM.dianpao_card)
	else
		-- require(TpackageName..".handle.CXZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function CXZMJController:showLgSelectBox(lgCards)
	require(TpackageName..".operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function CXZMJController:requestLiang(card)
	require(TpackageName..".handle.CXZMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function CXZMJController:requestLiangGang()
	require(TpackageName..".handle.CXZMJSendHandle"):CLI_REQUEST_LIANG_GANG(CXZMJ_LG_CARDS)
end

function CXZMJController:requestJiapiao(piao)
	require(TpackageName..".handle.CXZMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function CXZMJController:clearGameDatas()
	require(TpackageName..".operator.GamePlaneOperator"):clearGameDatas()
end

function CXZMJController:hideControlPlane()
	require(TpackageName..".operator.GamePlaneOperator"):hideControlPlane()
end

function CXZMJController:didSelectOutCard(card)
	require(TpackageName..".operator.GamePlaneOperator"):didSelectOutCard(card)
end

function CXZMJController:showHupai_vw(card)
	require(TpackageName..".operator.GamePlaneOperator"):showHupai_vw(card)
end

function CXZMJController:setTingNodeVisible(flag)
	require(TpackageName..".operator.GamePlaneOperator"):setTingNodeVisible(flag)
end

return CXZMJController