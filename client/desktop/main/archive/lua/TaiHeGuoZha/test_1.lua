local Test = class("Test")
local ddzServer = import("TaiHeGuoZha.ddzServer")
function Test:debugTool()
	ddzServer:CLIENT_COMMAND_GET_CARD()
	print('------------------------')

end

function Test:KEY_F11()
	local cards = {
        [1]  = 78,
        [2]  = 78,
        [3]  = 78,
        [4]  = 78,
        [5]  = 78,
        [6]  = 78,
        [7]  = 78,
        [8]  = 78,
        [9]  = 78,
        [10] = 79,
        [11] = 79,
        [12] = 79,
        [13] = 79,
        [14] = 79,
        [15] = 79,
        [16] = 79,
        [17] = 79,
        [18] = 79,
    }
	ddzServer:CLIENT_COMMAND_USER_CARD(cards)
end

function Test:KEY_F12()

end
return Test