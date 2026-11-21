
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ControlPlaneOperator = class("ControlPlaneOperator")
local CardPlaneOperator = require(TpackageName .. ".operator.CardPlaneOperator")

function ControlPlaneOperator:init(plane)
   
    self.plane = plane

    self.start_btn = SHISANZHANG_GAME_SCENE.start_btn:hide()--开始游戏
    self.start_btn:onClick(function()
        ShiSanZhangSendHandle:StartGame()
        -- self.start_btn:setVisible(false)
    end,true)
    --查看总结算按钮
    -- self.btn_check_group_result = plane:getChildByName("btn_check_group_result")
    -- self.btn_check_group_result:setVisible(false)
   
    -- self:showCardCountDown()
end

function ControlPlaneOperator:callBackToSendCard()

end

function ControlPlaneOperator:showCardCountDown(timeout)

end

function ControlPlaneOperator:playCountDown()

end


function ControlPlaneOperator:RemaidStartGame(flag)
    if self.start_btn then
        self.start_btn:setVisible(flag)
    end
end


return ControlPlaneOperator