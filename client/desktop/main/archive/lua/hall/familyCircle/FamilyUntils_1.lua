local FamilyUntils = FamilyUntils or {}

function FamilyUntils:__init()
    
end 

function FamilyUntils:SetListData(data)
	self.__list_data = data
end

function FamilyUntils:GetListData()
	return self.__list_data
end

function FamilyUntils:PackData(data)
 	local recv_data = {}
    for k , v in pairs(data) do 
        local temp = {}
        temp[k] = v 
        table.insert(recv_data , temp)
    end
    return recv_data
end 

function FamilyUntils:SetCommTipLabel(label)
    local tip_data = {type = 3 , content = label}
    return tip_data
end 

function FamilyUntils:RemoveCommonTip()
    if SCENENOW["scene"]:getChildByTag(99998) ~= nil then
        SCENENOW["scene"]:removeChildByTag(99998)
    end
end

return FamilyUntils
