local  GamePlaneOperator = class("GamePlaneOperator")

local  	ControlPlaneOperator = require(TpackageName .. ".operator.ControlPlaneOperator")
local   PlayerPlaneOperator = require(TpackageName .. ".operator.PlayerPlaneOperator")
local   TablePlaneOperator = require(TpackageName .. ".operator.TablePlaneOperator")

function GamePlaneOperator:ctor(scene)
    local PLAYER_PLANE_TABLE ={}
    PLAYER_PLANE_TABLE={[CARD_PLAYERTYPE_MY] = scene:getChildByName("player_plane_my"),
                        [CARD_PLAYERTYPE_LEFT] = scene:getChildByName("player_plane_left"),
                        [CARD_PLAYERTYPE_RIGHT] = scene:getChildByName("player_plane_top"),
                        [CARD_PLAYERTYPE_TOP] = scene:getChildByName("player_plane_right")}
    local game_plane = scene:getChildByName("game_plane")
    local hall_plane = scene:getChildByName("hall_plane")
    ControlPlaneOperator:init(game_plane)
    TablePlaneOperator:init(hall_plane)
    PlayerPlaneOperator:init(PLAYER_PLANE_TABLE)
end

return  GamePlaneOperator