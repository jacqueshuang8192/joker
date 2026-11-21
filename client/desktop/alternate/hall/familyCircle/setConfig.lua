local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local setConfigView = class("setConfigView", NewViewBaseLayer)
local panelCount=0
local selectpanel=nil
function setConfigView:ctor(data,familymain)
	    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height

	self.data=data
	self.familymain=familymain
	
    local csbPath = "hall/res/FriendScircle/SpeedjoinLayer.csb"
    setConfigView.super.ctor(self, csbPath)

    --add by zzy 2019-7-24

   -- self.listData = {}
   -- self:CreateGirl(self.listData)
    self:createTableView()
   -- self:InitGame()

   self.bt_yes:onClick(handler(self, self.onClickBtnYes), true)

end

function setConfigView:createTableView()
	local close_btn=self.Image_home:getChildByName("bt_close")
	close_btn:addTouchEventListener(function( sender, event )
		self:removeSelf()
	end)
	selectpanel=nil
	panelCount=0
	local count=1
	local isclone=false
	local first=1
	local panel2=nil
	local tab={}
	local panel =self.Image_home:getChildByName("ListView"):getChildByName("Panel_1")
	self:initvivw(panel) 
	dump(self.data,"--------data-------data")
	for gameType,id in pairs(self.data) do
		for id,v in pairs(id) do 		
			if first <=2 then
				if v.gameConfig then
					panel:getChildByName("bt_name_"..count):setVisible(true)
					panel:getChildByName("bt_name_"..count):getChildByName("text"):setString(v.name or "")
					tab[v.id]=panel:getChildByName("bt_name_"..count):getChildByName("select")
					local save=cc.UserDefault:getInstance():getIntegerForKey("SelectConfigID",1)
					if save==v.id then
						selectpanel=tab[v.id]
						tab[v.id]:setVisible(true)
					end
					panel:getChildByName("bt_name_"..count):addTouchEventListener(function(sender, event)
						--self:hideAllSelect()
						if selectpanel then
							selectpanel:setVisible(false)
						end
						selectpanel=tab[v.id]
						selectpanel:setVisible(true)
						myconfigID=v.id
						game_level=v.level
						cc.UserDefault:getInstance():setIntegerForKey("SelectConfigID",v.id)
						dump(myconfigID,"------myconfigID----")
						dump(game_level,"------game_level----")
						dump(count,"-----count-----")
					end)
				end
			end

			if isclone then

				panelCount=panelCount+1
				panel2=panel:clone()
				self.Image_home:getChildByName("ListView"):pushBackCustomItem(panel2)
				panel2:setName("Panel_"..first/2+1)
				self:initvivw(panel2)
				isclone=false
			end
			if panel2 then
				if v.gameConfig then
					dump(panelCount,"-------panelCount-----")
					panel2:getChildByName("bt_name_"..count):setVisible(true)
					tab[v.id]=panel2:getChildByName("bt_name_"..count):getChildByName("select")
					local save=cc.UserDefault:getInstance():getIntegerForKey("SelectConfigID",1)
					if save==v.id then
						selectpanel=tab[v.id]
						tab[v.id]:setVisible(true)
					end
					panel2:getChildByName("bt_name_"..count):getChildByName("text"):setString(v.name or "")
					panel2:getChildByName("bt_name_"..count):addTouchEventListener(function(sender, event)
						--self:hideAllSelect()
						if selectpanel then
							selectpanel:setVisible(false)
						end
						selectpanel=tab[v.id]
						selectpanel:setVisible(true)
						myconfigID=v.id
						game_level=v.level
						cc.UserDefault:getInstance():setIntegerForKey("SelectConfigID",v.id)
						dump(myconfigID,"------myconfigID----")
						dump(game_level,"------game_level----")
						dump(count,"-----count-----")
						dump(panel2:getName(),"-----panel2:getName()-----")

					end)
				end
			end
			if count==2 then
				count=0
				isclone=true
			end
			count=count+1
			first=first+1
		end
	end
	dump(count,"-------count------")
	dump(first,"-------first------")
	--dump(panelCount,"-------panelCount------")

end

function setConfigView:initvivw(panel)
	for i=1,2 do
		panel:getChildByName("bt_name_"..i):setVisible(false)

		panel:getChildByName("bt_name_"..i):getChildByName("text"):setString("")
		panel:getChildByName("bt_name_"..i):getChildByName("select"):setVisible(false)
	end
end

--[[function setConfigView:hideAllSelect()
	for i=1,panelCount do
		if panel then
		local panel=self.Image_home:getChildByName("ListView"):getChildByName("Panel_"..panelCount)
		panel:getChildByName("bt_name_1"):getChildByName("select"):setVisible(false)
		panel:getChildByName("bt_name_2"):getChildByName("select"):setVisible(false)
	end
	end
end--]]

function setConfigView:onClickBtnYes()
	
    require("hall.HallServer"):SPEED_JOIN(self.familymain.family_id,game_level,myconfigID)
    if myconfigID then
        makeroom=self.familymain:getGameConfigListById(myconfigID)
    end
end

return setConfigView