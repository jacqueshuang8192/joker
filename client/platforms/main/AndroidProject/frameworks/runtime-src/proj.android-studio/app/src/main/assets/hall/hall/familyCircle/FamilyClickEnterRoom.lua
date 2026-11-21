--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local FamilyClickEnterRoom = class("FamilyClickEnterRoom"  , NewViewBaseLayer)
local FamilyData = require("hall.familyCircle.FamilyData")
local GetGameName = require("hall.familyCircle.GetGameName")
local EVENTNAME = {
	SELECT_CLU_HISTORY = "/selectCluHistory",
}
function FamilyClickEnterRoom:ctor(param, parent, owerId)
    -- body
    self.param = param
    self.parent = parent
    self.owerId = owerId

    self.roleType = self.param.roleType

    
    local csbPath = "hall/res/FriendScircle/clickEnterRoom/clickEnterRoom.csb"
    FamilyClickEnterRoom.super.ctor(self, csbPath)

    self:enableMask(true)

    self:initUI()

    self:initEvent()

    self:initGame()

end

function FamilyClickEnterRoom:initGame()
    local config = self.param.game_data.config
    local level = config.level
    local gameName = GetGameName:getName(level)
    self.gameName = gameName

    self.title_txt:setString(gameName) --桌子类型名称
    self.showName = self.param.game_name or "" --桌子名称(玩家可编辑的那个)
    self.personNum = 0
    self.jushuNum = 0

    --self.title_txt_1:setString(self.showName) 

    self.number = 4

    local str1 = ""
    local str2 = ""
    local str3 = ""

    local GameConfig = self.parent:getGameConfigListById( config.id )
    if GameConfig and GameConfig.gameConfig then
        config = GameConfig.gameConfig
        self.param.game_data.config1 = GameConfig.gameConfig
    end

    if config.table_info then --这是具体桌子
        -- local tableInfo = json.decode(config.table_info)
        local tableInfo = config.table_info
        if tableInfo and tableInfo.maxSeatCount then
            str1 = tableInfo.maxSeatCount.."人"
            self.number = tonumber(tableInfo.maxSeatCount)

            if config.level == 373 then  --湖南碗碗是百人场 所以不要显示这么多人
                self.number = 7
            end
        end
        if tableInfo and tableInfo.round then
            str2 = tableInfo.round.."局"
        end
		
		--此description值好像无值为空串
        if tableInfo and tableInfo.description then
            str3 = tableInfo.description
        end
		
		--修复非新桌没有进桌玩法提示的BUG
		if str3 == '' and self.param.table_data and self.param.table_data[1] and self.param.table_data[1].config then
			local tempcfg = self.param.table_data[1].config
			str3 = ''
			for k,cfg in pairs(tempcfg) do
				if cfg and type(cfg) == "table" and cfg.configName and cfg.optionName then
					str3 =  str3.." "..cfg.configName.." "..cfg.optionName
				end
			end
		end
        self.desc = gameName..str3

        if config.level == 373 then  --湖南碗碗是百人场 所以不要显示这么多人
            self.inScore = 200
            self.outScore = 20
        else
            self.inScore = tableInfo.joinGamePoint/100
            self.outScore = tableInfo.readyPoint/100
        end
        self.flag = 2

    else   --这是玩法
        
        for k,cfg in pairs(config) do
            if cfg and type(cfg) == "table" and cfg.configName and cfg.optionName then

                local flag = true
                if config.gameId == 302 or config.gameId == 303 or config.gameId == 304 or config.gameId == 305 or config.gameId == 368 or config.gameId == 613 or config.gameId == 614 or config.gameId == 615 or config.gameId == 616 then
                    --牛牛玩法过滤
                    if k == 'speTypeOther' or k == 'pointMode' then
                        if config.gaoji and config.gaoji.optionValue then
                            if not string.find(config.gaoji.optionValue, '7') then
                                flag = false
                            end
                        else
                            flag = false
                        end
                    end
                    if k == 'speType' or k == 'timesRule'  then
                        if config.gaoji and config.gaoji.optionValue then
                            if string.find(config.gaoji.optionValue, '7') then
                                flag = false
                            end
                        end
                    end
                end

                if flag then
                    str3 =  str3.." "..cfg.configName.." "..cfg.optionName
                end
            end
        end

        if config.maxSeatCount then
            str1 = config.maxSeatCount.optionName
            self.number = tonumber(config.maxSeatCount.optionValue)
            if config.level == 373 then  --湖南碗碗是百人场 所以不要显示这么多人
                self.number = 7
            end
        end

        if config.round then
            str2 = config.round.optionName
        end

        if config.level == 373 then  --湖南碗碗是百人场 所以不要显示这么多人
            self.inScore = 200
            self.outScore = 20
        else
            self.inScore = config.joinGamePoint/100
            self.outScore = config.readyPoint/100
        end
        

        self.desc = gameName..str3
        self.flag = 1
    end


    self.personNum = str1
    self.jushuNum = str2

    if config.level == 373 then
        self.personNum = "万人场"
        self.jushuNum = "无限"
    end

    if 368 == config.level then
        self.jushuNum = "无限"
    end
    
    if config.level == 345 or config.level == 353 then
        self.jushuNum = ""
    end

    self:initListView(self.param.game_data)   --插入头像的 
    self:initPanel_info() --刷新房间数据

    if config.level == 373 then  --湖南碗碗是自定义的描述语
        self.ListView_desc:removeAllItems()
        local list_txt_373 = self.list_txt_373:clone()
        self.ListView_desc:pushBackCustomItem(list_txt_373)
    else
        self:initListView_desc()
    end
    
end

function FamilyClickEnterRoom:initPanel_info()
    self.txt_name:setString(self.showName)
    self.txt_num:setString(self.personNum)  --局数
    self.txt_jushu:setString(self.jushuNum)
    self.txt_inScore:setString(self.inScore)
    self.txt_outScore:setString(self.outScore)
end


function FamilyClickEnterRoom:initListView_desc()
    self.ListView_desc:removeAllItems()

    local content = self.desc or ""

    local txtWidth = 800
    local txtCount = string.len(content)
    local lineCount = (txtCount * 10) / txtWidth

    local label = display.newTTFLabel({
        text = "玩法信息："..content,
        font = "hall/res/font/FZY3JW.TTF",
        size = 24,
        color = cc.c3b(128, 136, 166),
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(txtWidth, 0)
    })
    label:setAnchorPoint(cc.p(0,0))

    local groupLY = ccui.Layout:create()
    groupLY:setAnchorPoint(cc.p(0,0))
    groupLY:setTouchEnabled(false)
    groupLY:setContentSize(cc.size(txtWidth+10, label:getContentSize().height))
    groupLY:addChild(label)

    self.ListView_desc:pushBackCustomItem(groupLY)
end

function FamilyClickEnterRoom:initListView(game_data)
    self.ListView_1:removeAllItems()
    local user_list = game_data.config.user_list
    if not user_list then return end
    local tal = {}
    for _, info in ipairs(user_list) do
        local data = json.decode(info)
        tal[data.uid] = data
    end

     for uid, info in pairs(tal) do

        local node = self.Panel_item:clone()
        local head_img = node:getChildByName("head")
        local photoUrl = info.profit
        local headSize = head_img:getContentSize().width
        require("hall.GameCommon"):getUserHead(photoUrl, "", "", head_img, headSize, false, "", true)
        head_img:setTouchEnabled(false):setVisible(true)
        local name = node:getChildByName("name")
        --name:setString("ID: "..info.uid)
        name:setString(" ")

        self.ListView_1:pushBackCustomItem(node)
    end

end

function FamilyClickEnterRoom:ShowHead(game_data)
    local user_list = game_data.config.user_list
    if not user_list then return end

    local tal = {}
    for _, info in ipairs(user_list) do
        local data = json.decode(info)
        tal[data.uid] = data
    end

    local nodes = self.pnl_vw:getChildren()
    local nodeIdx = 1
    for uid, info in pairs(tal) do
        local node = nodes[nodeIdx]
        local head_img = node.haed
        local photoUrl = info.profit
        local headSize = head_img:getContentSize().width
        require("hall.GameCommon"):getUserHead(photoUrl, "", "", head_img, headSize, false, "", true)
        head_img:setTouchEnabled(false):setVisible(true)
        -- node.name:setAnchorPoint(cc.p(0, 0))
        node.name:setString("ID: "..info.uid)
        nodeIdx = nodeIdx + 1
    end
end

function FamilyClickEnterRoom:initEvent()
	self.btn_share:onClick(handler(self, self.onClickShare), true)
    self.btnSure:onClick(handler(self, self.onClickEnterRoom), true)
    self.btn_guanzhan:onClick(handler(self, self.onClickGuanzhan), true)
    self.btn_dissolution:onClick(handler(self, self.onClick_dissolution), true)
    ReqMgr:addHandle("FamilyClickEnterRoom", EVENTNAME)
    -- ReqMgr:request(EVENTNAME.SELECT_CLU_HISTORY, data, handler(self, self.FlushPartnerInfo), {page = page})
end

function FamilyClickEnterRoom:onClickGuanzhan()
    self.parent:CreateGameTable(self.flag , self.param.game_data , self.param.table_data, 0)
    self:removeSelf()
end

function FamilyClickEnterRoom:onClick_dissolution()
    local tid = self.table_id
    require("hall.HallServer"):CLIENT_REMOVE_GROUP(tid)
    self:removeSelf()
end

function FamilyClickEnterRoom:onClickShare()
    local paras = {}
    paras["desc"] =  self.desc
    paras["imagePath"] = "url"
    paras["name"] = self.gameName
    paras["showType"] = 2;
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"],9999999)
    end
end

function FamilyClickEnterRoom:onClickEnterRoom()
    self.parent:CreateGameTable(self.param.game_data.flag , self.param.game_data , self.param.table_data, 1)
    self:removeSelf()
end

function FamilyClickEnterRoom:initUI()
    self.title_txt:setString("") --桌子类型名称
    self.txt_name:setString("")
    self.txt_num:setString("")
    self.txt_jushu:setString("")
    self.txt_inScore:setString("")
    self.txt_outScore:setString("")

    self.item1:hide()
    self.item2:hide()
    self.item3:hide()
    self.ListView_1:removeAllItems()
    self.ListView_1:setScrollBarEnabled(false)
    self.ListView_desc:removeAllItems()
    self.ListView_desc:setScrollBarEnabled(false)

    local vwsize = self.btns:getContentSize()
    local size = self.btn_guanzhan:getContentSize()
    local chils = self.btns:getChildren()
    local width = size.width
    for idx,btn in ipairs(chils) do
        btn:hide()
    end
    local level = self.param.game_data.config.level
	local isOpenGuanZhang = false
	if level == 365 or level == 360 or level == 317 
        or level == 302 or level == 368 
        or level == 303 or level == 304 or level == 305 
        or level == 374 or level == 613 or level == 614 or level == 615 or level == 616 or level == 617 then
        isOpenGuanZhang = true
    end
    local btns = {
        self.btn_share,
        self.btnSure,
    }

    if self.roleType ~= 0 then
        -- statements
        isOpenGuanZhang = false
    end

    if self.param.game_data.flag == 2 then
        self.table_id = self.param.game_data.config.table_id

        if isOpenGuanZhang then
            table.insert( btns, self.btn_guanzhan)
        end

        if self.owerId == USER_INFO.uid then --盟主解散
            table.insert( btns, self.btn_dissolution)
        end
    end

    local num = #btns
    local intevalW = (vwsize.width - width * num) / (num+1) + width
    local oriX = intevalW - width / 2

    for idx,node in ipairs(btns) do
        local x = oriX + intevalW * (idx - 1) 
        node:setPositionX(x)
        node:show()
    end
    
end

function FamilyClickEnterRoom:onExit()
    ReqMgr:delHandle("FamilyClickEnterRoom", EVENTNAME)
end

function FamilyClickEnterRoom:onClickBtnClose(...)
	self:removeSelf()
end


return FamilyClickEnterRoom