local TingView = class("TingView")
function TingView:ctor(ting_vw)
	self.ting_vw = ting_vw
    self.img_renyi = self.ting_vw.img_renyi:hide()
    self.hupai_vw = self.ting_vw.hupai_vw:hide()
end

function TingView:showTingHuPlane()
	
end

function TingView:setDianNodeBytingpai()

end

return TingView	