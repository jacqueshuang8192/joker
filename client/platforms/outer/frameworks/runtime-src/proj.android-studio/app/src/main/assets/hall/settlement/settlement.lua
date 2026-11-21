local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local SettlementView = class("SettlementView", NewViewBaseLayer)
local scheduler = cc.load("scheduler")

function SettlementView:test()

    local data = {}
    data["resultSceneType"] = 1       --战绩界面展示选择，1为长条形，2为方块形
    data["invote_code"] = "123456"      --房间号
    data["fenchang"] = "123"            --分场
    data["round"] = 10                  --局数
    data["date"] = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data["resultData"] = {}             --玩家数据数组

    local p1 = {}             --玩家数据实体
    p1["nick"] = "我"           --昵称
    p1["uid"] = "00001"         --uid
    p1["icon_url"] = ""         --头像链接
    p1["sex"] = 1               --性别
    p1["isRoomOwer"] = 1        --是否为房主，1是，非1或不填不是
    p1["isWinner"] = 1          --是否为赢家，1是，非1或不填不是
    -- p1["isLoser"] = 1          --是否为大输家，1是，非1或不填不是
    p1["total"] = "+100"        --总输赢分
    p1["gameDetail"] = {}       --游戏详情数组

    local gameDetail1 = {}           --游戏详情实体
    gameDetail1["showName"] = "自摸"   --展示名
    gameDetail1["value"] = "0"         --值

    local gameDetail2 = {}
    gameDetail2["showName"] = "点炮"
    gameDetail2["value"] = "0"

    local gameDetail3 = {}
    gameDetail3["showName"] = "抢杠"
    gameDetail3["value"] = "0"

    table.insert(p1["gameDetail"], gameDetail1)
    table.insert(p1["gameDetail"], gameDetail2)
    table.insert(p1["gameDetail"], gameDetail3)

    table.insert(data["resultData"], p1)
    --table.insert(data["resultData"], p1)
    --table.insert(data["resultData"], p1)
    --table.insert(data["resultData"], p1)
    --table.insert(data["resultData"], p1)

    local p2 = {}             --玩家数据实体
    p2["nick"] = "我1"           --昵称
    p2["uid"] = "0008011"         --uid
    p2["icon_url"] = ""         --头像链接
    p2["sex"] = 0               --性别
    p2["isRoomOwer"] = 0        --是否为房主，1是，非1或不填不是
    p2["isWinner"] = 0          --是否为赢家，1是，非1或不填不是
    -- p2["isLoser"] = 0          --是否为大输家，1是，非1或不填不是
    p2["total"] = "-100"        --总输赢分
    p2["gameDetail"] = {}       --游戏详情数组
    table.insert(data["resultData"], p2)
    table.insert(data["resultData"], p2)
    table.insert(data["resultData"], p2)
    self.new(data)
    return data
end

function SettlementView:getBigWiner(data)
    local maxValue = 0
    local index = 1
    for k,v in pairs(data) do
        if v.total >= maxValue then
            maxValue = v.total
            index = k
        end
    end

    return index
end

function SettlementView:ctor(param, hallCallBack, shareCallBack, isAddScene, extendCallBack)
    isAddScene = isAddScene == nil and true or false
    self:removeScene()
    if not param then param = self:test() end
    local csbPath = SETTLEMENT_VIEW
    local resultSceneType = param["resultSceneType"]
    dump(param)
    SettlementView.super.ctor(self, csbPath)
    local tempX = self._csbNode:getContentSize().width
    self:setName("SettlementView")
    self._csbNode:setZOrder(999)
    GameUtils.setNodeNameBindObj(self._csbNode)
    -- display.doLayout(self._csbNode.root)
    -- display.doLayout(self._csbNode.Panel_1)
    local SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    self._csbNode.Panel_1:setPositionX(SCREEN_WIDTH/2)

    -- self._csbNode:setScaleX(SCREEN_WIDTH/tempX)
    if isAddScene then
        self:setLocalZOrder(9999)
        SCENENOW["scene"]:addChild(self)
    end

    self:enableMask(true)
    self:initUI( )
    self:initEvent()
    self:showScene(param)
    self.shareCallBack = shareCallBack
    self.hallCallBack = hallCallBack
    self.extendCallBack = extendCallBack
end

function SettlementView:initUI( )

    self.ListView_1:removeAllItems()
    self.ListView_1:setScrollBarEnabled(false)
    self.ListView_2:removeAllItems()
    self.ListView_2:setScrollBarEnabled(false)
    self.ListView_3:removeAllItems()
    self.ListView_3:setScrollBarEnabled(false)
    self.gameConfig:setString("")
    self.time:setString("")
    self.master_name:setString("")
    self.master_id:setString("")
    self.item_2:hide()--长
    self.item_1:hide()--短
end

function SettlementView:initEvent( )
    self.btn_share:onClick(handler(self, self.onClickShare), true)
    self.btn_hall:onClick(handler(self, self.onClickHall), true)
    self.btn_extend:onClick(handler(self, self.onClickExtend), true)
    self.make:onTouch(handler(self, self.onClick_vw)) --长按屏幕查看桌面
    self.make:setScale(SCREEN_WIDTH/1280)
    -- dump(self.make:getContentSize())
    -- dump(SCREEN_WIDTH/1280*self.make:getContentSize().width)
    dump("定时器------------------------------")

end

function SettlementView:onClick_vw(event)
    if event.name == "began" then
        dump("定时器------------------------------")
        self.handle = scheduler.performWithDelayGlobal(function()
            if self and self.root == nil then
                return
            end
            self.root:hide()
            self.btn_hall:hide()
            self.btn_extend:hide()
            self.btn_share:hide()
            self.maskLayout:hide()
        end, 0.1)
    elseif event.name == "ended" or event.name == "cancelled" then
        if self and self.handle and self.root then
            dump("清除定时器------------------------------")
            self.root:show()
            self.btn_hall:show()
            self.btn_extend:show()
            self.btn_share:show()
            self.maskLayout:show()
            scheduler.unscheduleGlobal(self.handle)
        end
    end
end

function SettlementView:onClickShare(event)
    if self.shareCallBack then
        self.shareCallBack()
    end
end

function SettlementView:onClickHall(event)
    if self.hallCallBack then
        self.hallCallBack()
    else
        self:removeScene()
    end
end

function SettlementView:onClickExtend(event)
    if self.extendCallBack then
        self.extendCallBack()
    else
        self:removeScene()
    end
end

function SettlementView:setData(playerlist)
    if not(playerlist and type(playerlist) == "table") then
        return {}
    end
    local loser_uid = nil
    local win_uid = nil
    local nextTotal = 0
    local maxTotal = 0
    -- table.sort(playerlist, function(a,b) return tonumber(a.total) < tonumber(b.total) end)

    local group_owner = tonumber(USER_INFO["group_owner"])
    
    for k,v in ipairs(playerlist) do
        --获取用户id
        local uid = v.uid
        local total = tonumber(v.total)
        if total ~= nil then
            --比较分数
            if total < nextTotal then
                nextTotal = total
                loser_uid = uid
            end
            if total > maxTotal then
                maxTotal = total
                win_uid = uid
            end
        end
    end

    for idx, userData in ipairs(playerlist) do
        local uid = userData["uid"]
        userData["isWinner"] = 0
        userData["isLoser"] = 0
        if uid == loser_uid then
            userData["isLoser"] = 1          --是否为输家，1是，非1或不填不是
        end
        if uid == win_uid then
            userData["isWinner"] = 1          --是否为输家，1是，非1或不填不是
        end
        if uid == group_owner then
            userData["isRoomOwer"] = 1        --是否为房主，1是，非1或不填不是
        end
    end

    return playerlist
end

function SettlementView:showScene(data, backHall_action, share_action)

    if(data == nil) then
        require(CommonTips_filePath):showTips("提示", "", 3, "战绩数据异常")
        return
    end

    if SCENENOW["scene"] ~= nil then
        --是否显示再来一局
        dump('activity_idx------>', data["activity_id"])
        if data["activity_id"] then
            dump('activity_idy------>', data["activity_id"])
            self.btn_extend:setVisible(true)
        end
        
        --时间
        local date = data["date"]
        if date then
            self.time:setString(date)
        end

        --战绩信息
        local resultData = data["resultData"]
        local resultSceneType = data.resultSceneType
        if resultData and #resultData > 0 then
            resultData = self:setData(resultData)
            for idx, userData in ipairs(resultData) do
                local item
                if resultSceneType == 1 then
                    item = self.item_2:clone()--长
                else
                    item = self.item_1:clone()--短
                end
                item:show()
                GameUtils.setNodeNameBindObj(item)
                local icon_url = userData["icon_url"]
                local uid = userData["uid"]
                local sex = userData["sex"]
                local nick = userData["nick"]
                local isRoomOwer = userData["isRoomOwer"]
                local isWinner = userData["isWinner"]
                local isLoser = userData["isLoser"]
                local total = userData["total"] or 0
                local gameDetail = userData["gameDetail"]

                -- --房主
                if isRoomOwer and isRoomOwer == 1 then
                    -- self.masterData = userData
                    if icon_url then
                        require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.master_haed, 75, false, nick)
                    end
                    --昵称
                    self.master_name:setString(nick)

                    --id
                    self.master_id:setString("ID:"..uid)
                end

                --赢家
                item.mvp:setVisible(false)
                if isWinner and isWinner == 1 then
                    item.mvp:setVisible(true)
                end

                item.loser:setVisible(false)
                if isLoser and isLoser == 1 then
                    item.loser:setVisible(true)
                end

                --头像
                if icon_url then
                    require("hall.GameCommon"):getUserHead(icon_url, uid, sex, item.haed, 75, false, nick)
                end

                --昵称
                if nick then
                    local namenick = require("hall.GameCommon"):formatNick(nick, 5)
                    item.name:setString(namenick)
                end
                --id
                if uid then
                    item.id:setString("ID:"..uid)
                end

                --总分
                total = tonumber(total/100) or 0
                local str = ""
                if total >= 0 then
                    str = "+"..tostring(total)
                    item.score:setFntFile("hall/res/settlement/win_num.fnt")
                else
                    str = tostring(total)
                    item.score:setFntFile("hall/res/settlement/lose_num.fnt")
                end
                item.score:setString(str)
              

                if resultSceneType == 1 then
                    -- if gameDetail and #gameDetail > 0 then
                    --     -- item.maxScore:setString(gameDetail[1].value / 100)   --最高分数 
                    --     -- item.cardType:setString(gameDetail[2].value) --最大牌型
                    -- end
                    self:setItem(item, total, gameDetail)
                    self.ListView_1:pushBackCustomItem(item)
                    self.ListView_1:setScrollBarEnabled(true)
                else
                    if #resultData <= 5 then
                        self.ListView_3:pushBackCustomItem(item)
                    else
                        if idx <= 5 then
                            self.ListView_1:pushBackCustomItem(item)
                        else
                            self.ListView_2:pushBackCustomItem(item)
                        end
                    end
                end
            end
        end
    end
end

function SettlementView:setItem(item, score, gameDetail)
    local color = cc.c3b(11,147,114)
    local path = "hall/res/settlement/bg_2.png"       
    if score >= 0 then
        color = cc.c3b(201,65,40)
        path = "hall/res/settlement/bg_1.png"        
    end
    item:loadTexture(path,1)

    if type(gameDetail) ~= "table" then
       return
    end
    local svw = item.gameDetail_svw
    svw:removeAllChildren()
    local fontSize = 22
    local interValH = fontSize + 5
    local size = svw:getContentSize()
    local svwHeight = size.height
    local svwWidth = size.width
    local svwHeight = interValH * #gameDetail
    if svwHeight < size.height then
        svwHeight = size.height
    end
    svw:setInnerContainerSize(cc.size(svwWidth, svwHeight))
    local initY = (svwHeight - interValH / 2)
    for idx,data in ipairs(gameDetail) do
        local pos = {}
        pos.y = initY - (idx - 1) * interValH
        pos.x = 0
        local key = cc.Label:createWithTTF(data.showName or "", "hall/res/font/FZY3JW.TTF", fontSize)
        key:setAnchorPoint(cc.p(0, 0.5))
        key:setPosition(pos)
        key:enableOutline(color,1)
        key:show()
        key:setName("key")
        key:addTo(svw)

        pos.x = svwWidth
        local value = cc.Label:createWithTTF(data.value or "", "hall/res/font/FZY3JW.TTF", fontSize)
        value:setAnchorPoint(cc.p(1, 0.5))
        value:setPosition(pos)
        value:enableOutline(color,1)
        value:show()
        value:setName("value")
        value:addTo(svw)
    end
end

function SettlementView:removeScene()
    local s = SCENENOW["scene"]:getChildByName("SettlementView")
    if s then
        s:removeSelf()
    end
end

return SettlementView
