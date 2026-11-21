-- 房间记录
local fs = require("hall.tool.utils.fs")

local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local statistical_fjjl_replay = class("statistical_fjjl_replay", NewViewBaseLayer)

-- local statistical_fjjl_replay = class("statistical_fjjl",function()
--     return display.newLayer("statistical_fjjl")
-- end)

local EVENTNAME = {
	-- QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
    -- SELECT_POINT_CHANGE_HISTORY = "/selectPointChangeHistory",
    QUERY_CARD_ACTIVITIES2_ROUND_BY_USERID = '/freeGame/queryCardActivities2RoundByUserId',
}

local DOWN_LOAD_RECORD = {
    [308] = true, [320] = true, [366] = true, [325] = true, [369] = true, [375] = true, [342] = true, [392] = true, [388] = true, [398] = true, [345] = true,
    [353] = true, [618] = true, [611] = true, [359] = true, [381] = true, [376] = true, [612] = true, [374] = true,
    [386] = true, [387] = true, [371] = true, [358] = true, [383] = true, [379] = true, [396] = true, [329] = true, [394] = true,
    [348] = true, [370] = true, [390] = true, [391] = true, [393] = true, [389] = true, [399] = true, [400] = true, [384] = true, 
    [403] = true, [395] = true, [368] = true, [317] = true, [360] = true, [365] = true, [367] = true
}

function statistical_fjjl_replay:ctor(family_id, roleType,level,activityId,inviteCode)

    self.family_id = family_id
    self.roleType = roleType
    self.activityId = activityId
    self.inviteCode = inviteCode
    self.level = level
    
    self.clickRoomNumb = nil

    local path = "hall/res/FriendScircle/statistical_fjjl.csb"
    statistical_fjjl_replay.super.ctor(self, path)
    -- local node = nil 
    -- if device.platform == "ios" then
    --     if isiOSVerify then
    --         node = cc.CSLoader:createNode(path):addTo(self)
    --     else
    --         node = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. path):addTo(self)
    --     end
    -- else
    --     node = cc.CSLoader:createNode(path):addTo(self)
    -- end
    -- self._csbNode = node

    local recordVideoStr = cc.UserDefault:getInstance():getStringForKey("recordVideo")
    if recordVideoStr == nil or recordVideoStr == "" then
        self.recordVideo = {}
    else
        self.recordVideo = json.decode(recordVideoStr)
    end

    self:initUI()
    self:reqInfo()
end

function statistical_fjjl_replay:initUI()
    -- self.root = self._csbNode:getChildByName("root")
    local wanfaBg = self.root:getChildByName("wanfaBg")
    self.btnClose = wanfaBg:getChildByName("btnClose")
    self.qzjNode = self.root:getChildByName("qzjNode")

    -- 时间选择
    self.btnDate1 = self.qzjNode:getChildByName("btninput1")
    self.btnDateTxt1 = self.btnDate1:getChildByName("textinput1")
    self.btnDate1:setVisible(false)

    -- ID搜索
    self.input_word = self.qzjNode:getChildByName("time1"):getChildByName("input_word")
    self.qzjNode:getChildByName("time1"):setVisible(false)

    -- 页码
    self.root:getChildByName("btnPageL"):setVisible(false)
    self.root:getChildByName("btnPageR"):setVisible(false)
    self.root:getChildByName("labelPage"):setVisible(false)

    -- 总信息
    self.qzjNode:getChildByName("tip_bg3"):setVisible(false)

    self.root:getChildByName("txt_message"):setVisible(false)

    self.roleListV = self.qzjNode:getChildByName("ScrollView_1")
    self.roleListV:setScrollBarEnabled(false)
    self.roleListV:setContentSize(cc.size(1208,530))
    self.roleInfoPanel = self.roleListV:getChildByName("info")
    self.roleInfoPanel:setVisible(false)
    
    self.root:getChildByName("btn_tab_1"):setVisible(false)
    self.root:getChildByName("btn_tab_2"):setVisible(false)
    self.root:getChildByName("btn_tab_3"):setVisible(false)
    self.root:getChildByName("btn_tab_4"):setVisible(false)
    
    self:initEvent()
end

function statistical_fjjl_replay:initEvent()
    ReqMgr:addHandle("statistical_fjjl_replay", EVENTNAME)

    -- self.btnDate1:onClick(handler(self, self.onClickDateSelect), true)
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)
    -- self.btnPageL:onClick(handler(self, self.onClickBtnPageL), true)
    -- self.btnPageR:onClick(handler(self, self.onClickBtnPageR), true)

    -- self.cytjBtn:onClick(handler(self, self.onClickcytjBtn), true)
    -- self.jyztBtn:onClick(handler(self, self.onClickjyztBtn), true)
    -- self.qtjBtn:onClick(handler(self, self.onClickqtjBtn), true)
    -- self.fjjlBtn:onClick(handler(self, self.onClickfjjlBtn), true)
end


function statistical_fjjl_replay:onClickDateSelect()
    
end

function statistical_fjjl_replay:onClickcytjBtn()
    
end

function statistical_fjjl_replay:onClickjyztBtn()
    
end

function statistical_fjjl_replay:onClickqtjBtn()
    
end

function statistical_fjjl_replay:onClickfjjlBtn()
    
end

function statistical_fjjl_replay:onClickBtnClose()
    self:removeSelf()
end

function statistical_fjjl_replay:reqInfo()
    -- videoid  activityId
    -- videoid  activityId
    -- require("hall.record.RecordLayerInfo").new(recordInfo.activityId, recordInfo.level, nil, self.roleType):addTo(SCENENOW.scene)

    -- 输入回放码回放
    -- require("hall.record.RecordLayerInfo").new(nil, nil, inviteCode, self.roleType):addTo(SCENENOW.scene)

    
-- function RecordLayerInfo:getZJInfo(activityId, inviteCode)
    local data = {}
    data['userId'] = USER_INFO['uid']
    data['activityId'] = self.activityId
    data['inviteCode'] = self.inviteCode
    data['interfaceType'] = 'J'

    ReqMgr:request(EVENTNAME.QUERY_CARD_ACTIVITIES2_ROUND_BY_USERID, data, handler(self, self.resultVideo))
-- end

end

function statistical_fjjl_replay:resultVideo( event )

    local netData = event.netData
    -- dump(netData, '===成功返回战绩详情===')

    if netData.returnCode == 0 then
        -- dump(netData.data, '===成功返回战绩详情===')
        local sData = netData.data
        if sData == nil or #sData <= 0 then
            viewMgr:showTip({text = '战绩不存在...'})
            self:onClickBtnClose()
            return
        end

        if sData ~= nil and self then
            self.sData = sData
            dump(sData, '===成功返回战绩详情===')
            self:refreshList()
        end
    else
        viewMgr:showTip({text = '战绩不存在...'})
        self:onClickBtnClose()
    end

end

function statistical_fjjl_replay:refreshList()
    self.roleInfoPanel:setVisible(false)
    for i, info in ipairs(self.roleListV:getChildren()) do
        if i ~= 1 then
            info:removeSelf()
        end
    end
    
    local infoNode = nil
    local allNum = #self.sData
    local allInnerContH = 176*allNum
    if allInnerContH < 530 then
        allInnerContH = 530
    end
    for i, info in ipairs(self.sData) do
        if i == 1 then
            infoNode = self.roleInfoPanel
            infoNode:setVisible(true)
        else
            infoNode = self.roleInfoPanel:clone()
            infoNode:setVisible(true)
            self.roleListV:addChild(infoNode)
        end
        infoNode:setPositionY(allInnerContH - (i-1)*176 - 88)
        self:setRecordInfo(infoNode,info)
    end
    self.roleListV:setInnerContainerSize(cc.size(1208,allInnerContH))
end

function statistical_fjjl_replay:setRecordInfo(recordNode,recordInfo)
    local contInfo = json.decode(recordInfo.content)

    recordNode:getChildByName("nameText"):setString(contInfo.gameName)
    -- recordNode:getChildByName("circleIdText"):setString("亲友圈:"..self.family_id)
    recordNode:getChildByName("circleIdText"):setVisible(false)

    recordNode:getChildByName("videoText"):setString(contInfo.roomNumb)
    recordNode:getChildByName("videoText"):setVisible(false)

    recordNode:getChildByName("timeText"):setString(os.date("%Y/%m/%d %H:%M:%S", recordInfo.endTime/1000))
    recordNode:getChildByName("checkBox"):setVisible(false)

    if DOWN_LOAD_RECORD[self.level] then
        recordNode:getChildByName("btnmem"):setVisible(true)
    else
        recordNode:getChildByName("btnmem"):setVisible(false)
    end


    local roleNodes = {}
    for i = 1, 4 do
        roleNodes[i] = recordNode:getChildByName("rolePanel"..i)
        roleNodes[i]:setVisible(false)
    end

    for i, role in ipairs(contInfo.userinfos) do
        if roleNodes[i] then
            roleNodes[i]:setVisible(true)
            self:setRoleInfo(roleNodes[i],role)
        end
    end

    recordNode:getChildByName("btnmem"):addClickEventListener(function(sender)
        -- 播放
        self.clickRoomNumb = contInfo.roomNumb
        -- local data = sender._initData
        if string.sub(recordInfo.replayUrl,1,string.len('XY::')) == 'XY::' then
            
            self.httpHead = string.gsub(HttpAddr, '/hbiInterface', '');
            self.httpSuffix = string.gsub(recordInfo.replayUrl, 'XY::', '');
            recordInfo.replayUrl = self.httpHead .. self.httpSuffix
        end

        local splitAr = string.split(recordInfo.replayUrl, '/')
        local fileName = splitAr[#splitAr]
        self:getRecoreContent(recordInfo.replayUrl, fileName, handler(self, self.toPlayingVideo))
    end)
end

function statistical_fjjl_replay:onClickBtnmem()
end


function statistical_fjjl_replay:toPlayingVideo(contentStr)
    if contentStr == nil or #contentStr == 0 then
        return
    end

--[[    if self.level == 325 then  -- 1
        local videoLayer = require('pdk.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 308 then-- 1
        local videoLayer = require('hall.record.MJGameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 391 then --溆浦老牌
        local videoLayer = require('hall.record.xplp_recode.XPLPGameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 392  then
        local videoLayer = require('hall.record.xupuphz.gameScene').new(contentStr, self.level, self.roleType)
        if videoLayer then
            videoLayer:addTo(self)
        end
    end--]]

    if
        self.level == 308 or self.level == 320 or self.level == 366 or self.level == 376 or self.level == 612 or
            self.level == 386 or
            self.level == 387 or
            self.level == 371 or
            self.level == 358 or
            self.level == 329 or
            self.level == 370 or
            self.level == 389 or
            self.level == 390 or
            self.level == 393 or
            self.level == 348 or
            self.level == 394 or
            self.level == 399 or
            self.level == 400 or
            self.level == 403 

    then
        local videoLayer = require('hall.record.MJGameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 325 then
        if not io.exists('pdk/gameVideoScene.lua') then
            viewMgr:showTip({text = "请先进入游戏更新！"})
            return
        end
        local videoLayer = require('pdk.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 369 then
        if not io.exists('xinyu510k/gameVideoScene.lua') then
            viewMgr:showTip({text = "请先进入游戏更新！"})
            return
        end
        local videoLayer = require('xinyu510k.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 375 or self.level == 342 or self.level == 353 or self.level == 618 or self.level == 611 or self.level == 359 or self.level == 379 or self.level == 396 or self.level == 398 or self.level == 345 then
        local videoLayer = require('hall.record.phz_record.PHZMainLayer').new(contentStr, self.level, self.roleType)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 392  then
        local videoLayer = require('hall.record.xupuphz.gameScene').new(contentStr, self.level, self.roleType)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 388  then
        if not io.exists('jchuapai/src/record/gameScene.lua') then
            viewMgr:showTip({text = "请先进入游戏更新！"})
            return
        end
        local videoLayer = require('jchuapai.src.record.gameScene').new(contentStr, self.level, self.roleType)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 381 then
        if not io.exists('TaiHeGuoZha/gameVideoScene.lua') then
            viewMgr:showTip({text = "请先进入游戏更新！"})
            return
        end
        local videoLayer = require('TaiHeGuoZha.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 383 then
        if not io.exists('yuanjiangqianfen/gameVideoScene.lua') then
            viewMgr:showTip({text = "请先进入游戏更新！"})
            return
        end
        local videoLayer = require('yuanjiangqianfen.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 391 then --溆浦老牌
        local videoLayer = require('hall.record.xplp_recode.XPLPGameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 374 then --翻三皮
        local videoLayer = require('FanSanPi.view.VideoMenjiroomView').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 384  then
        if not io.exists('96game/gameVideoScene.lua') then
            viewMgr:showTip({text = "请先进入游戏更新！"})
            return
        end
        local videoLayer = require('96game.gameVideoScene').new(contentStr, self.level)
        if videoLayer then
            videoLayer:addTo(self)
        end
    elseif self.level == 368 or self.level == 395 
        or self.level == 305 or self.level == 613 or self.level == 614 or self.level == 615 or self.level == 616 
        or self.level == 317 or self.level == 360  or self.level == 365 or self.level == 367 or self.level == 617
        or self.level == 315  then  

        dump(self.clickRoomNumb,"self.clickRoomNumb==>>>")     
       require("hall.record.RecordLayerInfo").new(nil, nil, self.clickRoomNumb, self.roleType):addTo(SCENENOW.scene)
    end
end

function statistical_fjjl_replay:getRecoreContent(url, fileName, callback)
    --先在本地获取
    local path = device.writablePath
    if device.platform == "windows" then
        path = device.writablePath.."cache\\" --获取本地存储目录
        if not fs.exists(path) then
            fs.mkdir(path) --目录不存在，创建此目录
        end
    end
    local imgFullPath = path..fileName

    local file, fileErr = io.open(imgFullPath)
    if fileErr == nil then
        local fileContent = file:read()
        if callback then
            callback(fileContent)
        end
    else
        local function onRequestFinished(event, filename)
            local ok = (event.name == 'completed')
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return
            end

            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            while (not request:saveResponseData(imgFullPath)) and times < 30 do --filename
                times = times + 1
            end
            file, fileErr = io.open(imgFullPath)
            if fileErr == nil then
                local fileContent = file:read()
                if callback then
                    callback(fileContent)
                end
            else
                print('获取战绩失败 ---- url = ', url)
            end
        end

        local request =
            network.createHTTPRequest(
            function(event)
                if event.name == 'completed' then
                    onRequestFinished(event, imgFullPath)
                end
            end,
            url,
            'GET'
        )
        request:start()
    end
end

function statistical_fjjl_replay:setRoleInfo(roleNode,roleInfo)
    local strName = require("hall.GameCommon"):formatNick(roleInfo.nickName or "0")
    roleNode:getChildByName("Text_2"):setString(strName)
    
    roleNode:getChildByName("Text_3"):setString(roleInfo.uid)
    
    if roleInfo.score > 0 then
        roleNode:getChildByName("Text_1"):setTextColor(cc.c3b(60,191,146))
        roleNode:getChildByName("Text_1"):setString("+" .. string.format("%.2f", roleInfo.score/100))
    elseif roleInfo.score < 0 then
        roleNode:getChildByName("Text_1"):setTextColor(cc.c3b(226,60,60))
        roleNode:getChildByName("Text_1"):setString(string.format("%.2f", roleInfo.score/100))
    elseif roleInfo.score == 0 then
        roleNode:getChildByName("Text_1"):setTextColor(cc.c3b(60,191,146))
        roleNode:getChildByName("Text_1"):setString(string.format("%.2f", roleInfo.score/100))
    end
    require("hall.GameCommon"):getUserHead(roleInfo.photoUrl, "", "", roleNode:getChildByName("headImg"), 69, false, "", true)
end

function statistical_fjjl_replay:onExit()
    ReqMgr:delHandle("statistical_fjjl_replay", EVENTNAME)
end

return statistical_fjjl_replay