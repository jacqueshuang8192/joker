
local NumberUtil = class("NumberUtil")

--把传入值转成万显示
function NumberUtil:toWan(number, limit, customStr)

	if 	number == nil then
		return 0
	end

	customStr = customStr or "万"
	limit = limit or 999999
	if 	number <= limit then
		return number
	end

	local x = number / 10000

	return string.format("%.1f", x) .. customStr

end

function NumberUtil:formatGold(number)

	if 	number == nil then
		return 0
	end

	local numberStr_tail = string.sub(number,-2) 
	local numberStr_head = string.sub(number,1,-3) 

	-- dump(numberStr_tail,"numberStr_tail")
	-- dump(numberStr_head,"numberStr_head")
	return number > 100 and numberStr_head .. "," .. numberStr_tail or number

end

return NumberUtil