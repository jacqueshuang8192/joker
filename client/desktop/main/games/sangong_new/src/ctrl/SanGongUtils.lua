local SanGongUtils = class("SanGongUtils")
local GameCommon = require("hall.GameCommon")

function SanGongUtils:ctor(ctrl)
    self.ctrl = ctrl
    self.logic = ctrl.logic
end

return SanGongUtils
