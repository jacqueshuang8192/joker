local ZZMJController = class("ZZMJController")

function ZZMJController:control(controlType, value)
	if D3_CHUPAI == 2 then
		D3_CHUPAI = 1
	end

	require("zz_majiang_old_3d.handle.ZZMJSendHandle"):requestHandle(controlType, value)
end

function ZZMJController:showSameCard(value)
    require("zz_majiang_old_3d.operator.GamePlaneOperator"):showSameCard(value)
end

function ZZMJController:hideSameCard()
	require("zz_majiang_old_3d.operator.GamePlaneOperator"):hideSameCard()
end


function ZZMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("zz_majiang_old_3d.handle.ZZMJSendHandle"):requestHandle(0x2000, 0)
	else
		require("zz_majiang_old_3d.handle.ZZMJSendHandle"):requestHandle(0, 0)
	end
end

function ZZMJController:playCard(value)
	dump(value, "playCard OUtcard")

	D3_CHUPAI = 0
    
    -- self:hideSameCard()
	self:hideControlPlane()
	require("zz_majiang_old_3d.operator.GamePlaneOperator"):didSelectOutCard(value)
	
	require("zz_majiang_old_3d.handle.ZZMJSendHandle"):sendCard(value)
end

--请求解散房间
function ZZMJController:C2G_CMD_DISSOLVE_ROOM()
    require("zz_majiang_old_3d.handle.ZZMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function ZZMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("zz_majiang_old_3d.handle.ZZMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function ZZMJController:showTingCards(tingSeq)
	require("zz_majiang_old_3d.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function ZZMJController:hideTingHuPlane()
	require("zz_majiang_old_3d.operator.GamePlaneOperator"):hideTingHuPlane()
end

function ZZMJController:showTingHuPlane(playerType, tingHuCards)
	require("zz_majiang_old_3d.operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function ZZMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("zz_majiang_old_3d.handle.ZZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(ZZMJ_ROOM.dianpao_card)
	else
		-- require("zz_majiang_old_3d.handle.ZZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function ZZMJController:showLgSelectBox(lgCards)
	require("zz_majiang_old_3d.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function ZZMJController:requestLiang(card)
	require("zz_majiang_old_3d.handle.ZZMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function ZZMJController:requestLiangGang()
	require("zz_majiang_old_3d.handle.ZZMJSendHandle"):CLI_REQUEST_LIANG_GANG(ZZMJ_LG_CARDS)
end

function ZZMJController:requestJiapiao(piao)
	require("zz_majiang_old_3d.handle.ZZMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function ZZMJController:clearGameDatas()
	require("zz_majiang_old_3d.operator.GamePlaneOperator"):clearGameDatas()
end

function ZZMJController:hideControlPlane()
	require("zz_majiang_old_3d.operator.GamePlaneOperator"):hideControlPlane()
end

function ZZMJController:didSelectOutCard(card)
	-- require("zz_majiang_old_3d.operator.GamePlaneOperator"):hideSameCard()
 --    require("zz_majiang_old_3d.operator.GamePlaneOperator"):showSameCard(card)
	require("zz_majiang_old_3d.operator.GamePlaneOperator"):didSelectOutCard(card)
end

return ZZMJController