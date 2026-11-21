--[[
* author:   zzy
* date:     2019-06-10
* describe: 大厅总结算（四人以下,包含四人）
* explain:  
]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local CommonEndResult = class("CommonEndResult", ViewBaseLayer)

local VIEW_WIDTH = 1200
local CELL_WIDTH = 280
local CELL_HEIGHT = 454
local CELL_POS_Y = 50

function CommonEndResult:ctor(data)

    CommonEndResult.super.ctor(self, "hall/res/gameEndResult/CommonEndResult.csb")
    self:setNodeEventEnabled(true)
    self.data = data or {}
    self.playerNum = self.data.user_mount or 0
	dump(data,'gameResult------x')
	if data["activity_id"] then
		self.btnExtend:setVisible(true);
		self.btnReturn:setPositionX(626.93);
		self.btnShare:setPositionX(986.99);
		self.btnExtend:setPositionX(296.00);
	else
		self.btnReturn:setPositionX(444.37);
		self.btnShare:setPositionX(826.42);
		self.btnExtend:setVisible(false);
	end

    self.bg1:setVisible(false)
    self:refreshListView()
end

function CommonEndResult:onEnter()
end

function CommonEndResult:onExit()
end

--刷新玩家结算内容
function CommonEndResult:refreshListView()
	print("CommonEndResult:refreshListView!!!")
	if self.playerNum == 0 then return end
	local cell = require("hall.roomCommonUI.CommonResultCell")
	local tempIndex = 1
	for k,v in pairs(self.data.playerlist) do
		self:addPlayerCell(cell,v,tempIndex)
		tempIndex = tempIndex + 1
	end
end


function CommonEndResult:addPlayerCell(_cell,_playerData,_tempIndex)
	local Widget = ccui.Widget:create()
    local item = _cell.new(_playerData,_tempIndex)
    -- Widget:addChild(item)
    -- Widget:setContentSize(CELL_WIDTH,CELL_HEIGHT)
    self.view:addChild(item)

    self:setPlayerCellPosition(item,_tempIndex)
end

function CommonEndResult:getFirstBegainX()
	local _x = VIEW_WIDTH/2 - self.playerNum*CELL_WIDTH/2
	return _x
end

function CommonEndResult:setPlayerCellPosition(_widget,_tempIndex)
	local x = self:getFirstBegainX() + (_tempIndex-1)*CELL_WIDTH
	local y = CELL_POS_Y

	print("=====666666666666=====")
	print("=====666666666666=====")
	print("=====666666666666=====")
	print("=====666666666666=====")
	print(x,y)
	_widget:setPosition(cc.p(x,y))
end

--点击返回大厅
function CommonEndResult:onClickBtnReturn(sender, event)
	print("CommonEndResult:onClickBtnReturn!!!")
	require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"] , USER_INFO["family_data"])--self.data.club_state and 1 == self.data.club_state)
end

--点击分享
function CommonEndResult:onClickBtnShare(sender, event)
	print("CommonEndResult:onClickBtnShare!!!")

	local paras = {}
	paras["showType"] = 2;
	paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
	paras["imagePath"] = "screen"
	paras["name"] = "分享结果"
	paras["url"] = appDownLoadAddress
	local shareLayer = require("hall.share.ShareLayer").new(paras)
	if shareLayer then
		shareLayer:addTo(SCENENOW["scene"],9999999)
	end

	-- require(Share_filePath):showShareLayerInHall("【" .. appName .. "】", "http://download.doudougame.cn/app/index.html", "url", hallShareMessage)
end

--点击再来一局
function CommonEndResult:onClickBtnExtend(sender, event)
	print("CommonEndResult:onClickbtnExtend!!!")
	require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"])

end

return CommonEndResult