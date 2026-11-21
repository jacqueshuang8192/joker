local ControlPlaneOperator = class("ControlPlaneOperator")

function ControlPlaneOperator:init()
    self.share_btn = CDSPanel.hall_plane.share_btn--微信邀请
    self.copy_btn = CDSPanel.hall_plane.copy_btn--复制房间号
    self:setGuanZhanVisible(false)
end

function ControlPlaneOperator:clearGameDatas(stage)

end

function ControlPlaneOperator:RemaidStartGame(flag)
    if self.btn_start then
		if g_isWatch == 0 then
			flag = false
        end
        self.btn_start:setVisible(flag)
    end
end

--观战
function ControlPlaneOperator:setGuanZhanVisible(flag)
    CDSPanel.hall_plane.guanZhan_img:setVisible(flag)
    flag = not flag
    CDSPanel.hall_plane.btn_voice:setVisible(flag)
    CDSPanel.hall_plane.btn_chat:setVisible(flag)
end

return ControlPlaneOperator