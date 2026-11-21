local XLMHController = class("XLMHController")

function XLMHController:control(controlType, value)
	if D3_CHUPAI == 2 then
		--todo
		D3_CHUPAI = 1
	end

	if bit.band(controlType, GANG_TYPE_AN) > 0 and bit.band(controlType, GANG_TYPE_BU) > 0 then
		--todo
		local count = 0

		for i,v in ipairs(XLMH_GAMEINFO_TABLE[XLMH_MY_USERINFO.seat_id .. ""].hand) do
			if v == value then
				--todo
				count = count + 1
			end
		end

		if count == 4 then
			--todo
			require("mhxl_majiang.handle.XLMHSendHandle"):requestHandle(GANG_TYPE_AN, value)
		else
			require("mhxl_majiang.handle.XLMHSendHandle"):requestHandle(GANG_TYPE_BU, value)
		end

		return
	end

	require("mhxl_majiang.handle.XLMHSendHandle"):requestHandle(controlType, value)
end

function XLMHController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("mhxl_majiang.handle.XLMHSendHandle"):requestHandle(0x2000, 0)
	else
		require("mhxl_majiang.handle.XLMHSendHandle"):requestHandle(0, 0)
	end
end

function XLMHController:playCard(value)
	-- dump(value, "out card value ")

	D3_CHUPAI = 0

	self:hideControlPlane()
	
	require("mhxl_majiang.handle.XLMHSendHandle"):sendCard(value)
end

--请求解散房间
function XLMHController:C2G_CMD_DISSOLVE_ROOM()
    require("mhxl_majiang.handle.XLMHSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function XLMHController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("mhxl_majiang.handle.XLMHSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function XLMHController:showTingCards(tingSeq)
	require("mhxl_majiang.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function XLMHController:hideTingHuPlane()
	require("mhxl_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
end

function XLMHController:showTingHuPlane(playerType, tingHuCards)
	require("mhxl_majiang.operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function XLMHController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("mhxl_majiang.handle.XLMHSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(XLMH_ROOM.dianpao_card)
	else
		-- require("mhxl_majiang.handle.XLMHSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		D3_CHUPAI = 1
	end
end

function XLMHController:showLgSelectBox(lgCards)
	require("mhxl_majiang.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function XLMHController:requestLiang(card, componentIndexs)
	require("mhxl_majiang.handle.XLMHSendHandle"):CLI_REQUEST_LIANG(card, componentIndexs)
end

function XLMHController:requestLiangGang()
	require("mhxl_majiang.handle.XLMHSendHandle"):CLI_REQUEST_LIANG_GANG(XLMH_LG_CARDS)
end

function XLMHController:requestJiapiao(piao)
	require("mhxl_majiang.handle.XLMHSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function XLMHController:requestSendPosition()
	require("mhxl_majiang.handle.XLMHSendHandle"):CLI_REQUEST_SEND_POSITION()
end

function XLMHController:clearGameDatas()
	require("mhxl_majiang.operator.GamePlaneOperator"):clearGameDatas()
end

function XLMHController:hideControlPlane()
	require("mhxl_majiang.operator.GamePlaneOperator"):hideControlPlane()
end

function XLMHController:revertOutCardPosition()
	require("mhxl_majiang.operator.GamePlaneOperator"):revertOutCardPosition()
end

function XLMHController:showComponentSelectBox(outCardParam)
	require("mhxl_majiang.operator.GamePlaneOperator"):showComponentSelectBox(outCardParam)
end

function XLMHController:didSelectOutCard(card)
	local tingParam = XLMH_GAMEINFO_TABLE[XLMH_MY_USERINFO.seat_id .. ""].tingParam

	-- dump(tingParam, "test 0513")

	if not tingParam then
		require("mhxl_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
		return
	end

	if table.getn(tingParam) == 0 then
		require("mhxl_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
		return
	end

	for i,v in ipairs(tingParam) do
		if v.card == card then
			local tingHuCards = {}

			for i1,v1 in ipairs(v.tingHuCards) do
				if not v1.huCards then
					require("mhxl_majiang.operator.GamePlaneOperator"):showTingHuPlane(CARD_PLAYERTYPE_MY, {})
					return
				end
				if table.getn(v1.huCards) == 0 then
					require("mhxl_majiang.operator.GamePlaneOperator"):showTingHuPlane(CARD_PLAYERTYPE_MY, {})
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

			require("mhxl_majiang.operator.GamePlaneOperator"):showTingHuPlane(CARD_PLAYERTYPE_MY, tingHuCards)
			return
		end
	end

	require("mhxl_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
end

function XLMHController:sendGrabGangCard(card)
	require("mhxl_majiang.handle.XLMHSendHandle"):CLI_REQUEST_GRAB_GANG_CARD(card)
end

return XLMHController