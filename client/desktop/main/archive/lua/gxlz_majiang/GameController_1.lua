local GXLZController = class("GXLZController")

function GXLZController:control(controlType, value)
	if D3_CHUPAI == 2 then
		--todo
		D3_CHUPAI = 1
	end

	if bit.band(controlType, GANG_TYPE_AN) > 0 and bit.band(controlType, GANG_TYPE_BU) > 0 then
		--todo
		local count = 0

		for i,v in ipairs(GXLZ_GAMEINFO_TABLE[GXLZ_MY_USERINFO.seat_id .. ""].hand) do
			if v == value then
				--todo
				count = count + 1
			end
		end

		if count == 4 then
			--todo
			require("gxlz_majiang.handle.GXLZSendHandle"):requestHandle(GANG_TYPE_AN, value)
		else
			require("gxlz_majiang.handle.GXLZSendHandle"):requestHandle(GANG_TYPE_BU, value)
		end

		return
	end

	require("gxlz_majiang.handle.GXLZSendHandle"):requestHandle(controlType, value)
end

function GXLZController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("gxlz_majiang.handle.GXLZSendHandle"):requestHandle(0x2000, 0)
	else
		require("gxlz_majiang.handle.GXLZSendHandle"):requestHandle(0, 0)
	end
end

function GXLZController:playCard(value)
	dump(value, "out card value ")

	D3_CHUPAI = 0

	self:hideControlPlane()
	
	require("gxlz_majiang.handle.GXLZSendHandle"):sendCard(value)
end

--请求解散房间
function GXLZController:C2G_CMD_DISSOLVE_ROOM()
    require("gxlz_majiang.handle.GXLZSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function GXLZController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("gxlz_majiang.handle.GXLZSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function GXLZController:showTingCards(tingSeq)
	require("gxlz_majiang.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function GXLZController:hideTingHuPlane()
	require("gxlz_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
end

function GXLZController:showTingHuPlane(playerType, tingHuCards)
	require("gxlz_majiang.operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function GXLZController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("gxlz_majiang.handle.GXLZSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(GXLZ_ROOM.dianpao_card)
	else
		-- require("gxlz_majiang.handle.GXLZSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function GXLZController:showLgSelectBox(lgCards)
	require("gxlz_majiang.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function GXLZController:requestLiang(card, componentIndexs)
	require("gxlz_majiang.handle.GXLZSendHandle"):CLI_REQUEST_LIANG(card, componentIndexs)
end

function GXLZController:requestLiangGang()
	require("gxlz_majiang.handle.GXLZSendHandle"):CLI_REQUEST_LIANG_GANG(GXLZ_LG_CARDS)
end

function GXLZController:requestJiapiao(piao)
	require("gxlz_majiang.handle.GXLZSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function GXLZController:requestSendPosition()
	require("gxlz_majiang.handle.GXLZSendHandle"):CLI_REQUEST_SEND_POSITION()
end

function GXLZController:clearGameDatas()
	require("gxlz_majiang.operator.GamePlaneOperator"):clearGameDatas()
end

function GXLZController:hideControlPlane()
	require("gxlz_majiang.operator.GamePlaneOperator"):hideControlPlane()
end

function GXLZController:revertOutCardPosition()
	require("gxlz_majiang.operator.GamePlaneOperator"):revertOutCardPosition()
end

function GXLZController:showComponentSelectBox(outCardParam)
	require("gxlz_majiang.operator.GamePlaneOperator"):showComponentSelectBox(outCardParam)
end

function GXLZController:didSelectOutCard(card)
	local tingParam = GXLZ_GAMEINFO_TABLE[GXLZ_MY_USERINFO.seat_id .. ""].tingParam

	dump(tingParam, "test 0513")

	if not tingParam then
		require("gxlz_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
		return
	end

	if table.getn(tingParam) == 0 then
		require("gxlz_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
		return
	end

	for i,v in ipairs(tingParam) do
		if v.card == card then
			local tingHuCards = {}

			for i1,v1 in ipairs(v.tingHuCards) do
				if not v1.huCards then
					require("gxlz_majiang.operator.GamePlaneOperator"):showTingHuPlane(CARD_PLAYERTYPE_MY, {})
					return
				end
				if table.getn(v1.huCards) == 0 then
					require("gxlz_majiang.operator.GamePlaneOperator"):showTingHuPlane(CARD_PLAYERTYPE_MY, {})
					return
				end
				for i2,v2 in ipairs(v1.huCards) do
					local isExist = false
					for i3,v3 in ipairs(tingHuCards) do
						if v3 == v2 then
							isExist = true
							break
						end
					end
					if not isExist then
						table.insert(tingHuCards, v2)
					end
				end
			end

			require("gxlz_majiang.operator.GamePlaneOperator"):showTingHuPlane(CARD_PLAYERTYPE_MY, tingHuCards)
			return
		end
	end

	require("gxlz_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
end

function GXLZController:sendGrabGangCard(card)
	require("gxlz_majiang.handle.GXLZSendHandle"):CLI_REQUEST_GRAB_GANG_CARD(card)
end

return GXLZController