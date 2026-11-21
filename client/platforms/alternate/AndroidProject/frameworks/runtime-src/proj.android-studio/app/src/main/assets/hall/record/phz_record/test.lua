
local Test = class("Test")

function Test:debugTool()
    g_342 = {}
    g_342.path = "hall.record.phz_record"
	local data = cc.FileUtils:getInstance():getStringFromFile("dump.json")

    local PHZMainLayer = require(g_342.path..".PHZMainLayer").new(data, 375)
    PHZMainLayer:addTo(SCENENOW.scene)
    PHZMainLayer:setName("test")
end

function Test:KEY_F11()
  
end

function Test:KEY_F7( )
end

function Test:KEY_F11()
 
end

return Test