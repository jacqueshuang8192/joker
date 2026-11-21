local ControlPlaneOperator = class("ControlPlaneOperator")
function ControlPlaneOperator:init(game_hall)
    self.ready_plane = game_hall:getChildByName("ready_plane")
    self.btn_ready = self.ready_plane:getChildByName("btn_ready")
end

return ControlPlaneOperator