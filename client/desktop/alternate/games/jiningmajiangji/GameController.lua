local ZZMJController = class("ZZMJController")

function ZZMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require("jiningmajiangji.handle.ZZMJSendHandle"):requestHandle(controlType, value)
end

function ZZMJController:showSameCard(value)
    require("jiningmajiangji.operator.GamePlaneOperator"):showSameCard(value)
end

function ZZMJController:hideSameCard()
	require("jiningmajiangji.operator.GamePlaneOperator"):hideSameCard()
end


function ZZMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("jiningmajiangji.handle.ZZMJSendHandle"):requestHandle(0x2000, 0)
	else
		require("jiningmajiangji.handle.ZZMJSendHandle"):requestHandle(0, 0)
	end
end

function ZZMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    
    -- self:hideSameCard()
	self:hideControlPlane()
	require("jiningmajiangji.operator.GamePlaneOperator"):didSelectOutCard(value)
	
	require("jiningmajiangji.handle.ZZMJSendHandle"):sendCard(value)
end

--请求解散房间
function ZZMJController:C2G_CMD_DISSOLVE_ROOM()
    require("jiningmajiangji.handle.ZZMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function ZZMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("jiningmajiangji.handle.ZZMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function ZZMJController:showTingCards(tingSeq)
	require("jiningmajiangji.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function ZZMJController:hideTingHuPlane()
	require("jiningmajiangji.operator.GamePlaneOperator"):hideTingHuPlane()
end

function ZZMJController:showTingHuPlane(playerType, tingHuCards)
	require("jiningmajiangji.operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function ZZMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("jiningmajiangji.handle.ZZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(ZZMJ_ROOM.dianpao_card)
	else
		-- require("jiningmajiangji.handle.ZZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function ZZMJController:showLgSelectBox(lgCards)
	require("jiningmajiangji.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function ZZMJController:requestLiang(card)
	require("jiningmajiangji.handle.ZZMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function ZZMJController:requestLiangGang()
	require("jiningmajiangji.handle.ZZMJSendHandle"):CLI_REQUEST_LIANG_GANG(ZZMJ_LG_CARDS)
end

function ZZMJController:requestJiapiao(piao)
	require("jiningmajiangji.handle.ZZMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function ZZMJController:clearGameDatas()
	require("jiningmajiangji.operator.GamePlaneOperator"):clearGameDatas()
end

function ZZMJController:hideControlPlane()
	require("jiningmajiangji.operator.GamePlaneOperator"):hideControlPlane()
end

function ZZMJController:didSelectOutCard(card)
	-- require("jiningmajiangji.operator.GamePlaneOperator"):hideSameCard()
 --    require("jiningmajiangji.operator.GamePlaneOperator"):showSameCard(card)
	require("jiningmajiangji.operator.GamePlaneOperator"):didSelectOutCard(card)
end

return ZZMJController