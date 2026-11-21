local CSMJController = class("CSMJController")

function CSMJController:control(controlType, value, _user_bonus)
	if D3_CHUPAI == 2 then
		--todo
		D3_CHUPAI = 1
	end

	if _user_bonus == nil then 
		_user_bonus = 0 
	end

	--print("---------- SEND USER OPERATOR:", controlType, value, _user_bonus)

	require("cs_majiang.handle.CSMJSendHandle"):requestHandle(controlType, value, _user_bonus)
end

function CSMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("cs_majiang.handle.CSMJSendHandle"):requestHandle(0x2000, 0)
	else
		require("cs_majiang.handle.CSMJSendHandle"):requestHandle(0, 0)
	end
end

function CSMJController:playCard(value)
	-- dump(value, "out card value ")

	D3_CHUPAI = 0

	require("cs_majiang.handle.CSMJSendHandle"):sendCard(value)
end

function CSMJController:clearGameDatas()
	require("cs_majiang.operator.GamePlaneOperator"):clearGameDatas()
end

function CSMJController:didSelectOutCard(card)
	local tingCards = CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].tingCards

	if not tingCards then
		require("cs_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
		return
	end

	if table.getn(tingCards) == 0 then
		require("cs_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
		return
	end

	for i,v in ipairs(tingCards) do
		if card == v.card then
			--todo
			require("cs_majiang.operator.GamePlaneOperator"):showTingHuPlane(v.tingHuCards)
			return
		end
	end

	require("cs_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
end

function CSMJController:requestJiapiao(piao)
	require(TpackageName..".handle.CSMJSendHandle"):CLI_CHOSE_PIAO(piao)
end


return CSMJController