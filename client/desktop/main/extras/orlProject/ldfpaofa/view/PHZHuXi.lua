local PHZHuXi = class("PHZHuXi", function ()
   return cc.CSLoader:createNode("ldfpaofa/res/PHZHuXi.csb")
end)


function PHZHuXi:ctor(data,index)
    self.index = index or 1
    self.data = data or 0
	self:setNodeEventEnabled(true)
	self:initUI()
end

function PHZHuXi:onEnter()

end

function PHZHuXi:onExit()

end

function PHZHuXi:initUI()
    local bg = self:getChildByName("bg")
	self.Text_jushu = bg:getChildByName("Text_jushu")
    self.Text_huxi = bg:getChildByName("Text_huxi")

    local strHuXi = self.data
    if self.data > 0 then
        strHuXi = "+"..strHuXi
    end

    self.Text_jushu:setString("第"..self.index.."局")  
    self.Text_huxi:setString(strHuXi/100)
end


return PHZHuXi