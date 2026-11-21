
local Test = class("Test")

local PHZ_Ting = require("cdpaohuzi.PHZ_Ting")

function Test:debugTool()
	local t1 = os.clock()
   local handCards = g_CardScene:getMyHandCardData()
   local tingInfo = PHZ_Ting:CheckTingCard(handCards)
   print('------------------------ting2----costtime----', (os.clock()-t1)*1000)
   dump(tingInfo, 'tingInfo')
end

function Test:KEY_F11()
  
end

function Test:KEY_F7( )
    
end

function Test:KEY_F11()
 
end

return Test