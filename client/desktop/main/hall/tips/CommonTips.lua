--[[
* author:   zwm
* date:     2019-03-29
* describe: 公用提示框
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local CommonTips = class("CommonTips", function()
    return cc.CSLoader:createNode("hall/res/tips/commonTip.csb")
end)

--打开共用提示框 data里面的type
--type： 1表示 只显示单一的确定按钮；2表示 显示取消和确定按钮 3表示 显示viewMgr:showTip
-- callBackCancel 点击取消的回调函数
-- callBackSure   点击确定的回调函数(type 为2时)
-- callBackSingleSure 点击单一确定的回调函数
-- title 标题
-- content 内容

function CommonTips:showTips(data)
    if data.type == 3 then 
        viewMgr:showTip({text = data.content})
        return
    end
    data.callBackSure = data.callBackSure or data.callBackSingleSure
    if SCENENOW["scene"]:getChildByTag(99998) ~= nil then
        SCENENOW["scene"]:removeChildByTag(99998)
    end
    self.new(data):addTo(SCENENOW["scene"], 99998)
end

function CommonTips:showTipsAndToHall(data)
    data.callBackSure = handler(self, self._gameToHall)
    data.callBackSingleSure = handler(self, self._gameToHall)
    self:showTips(data)
end

function CommonTips:_gameToHall()
    --设置不需要检查重连
    bm.notCheckReload = 1
    --移除录音按钮
    --require("hall.VoiceRecord.VoiceRecordView"):removeView()

    --通知本地退出房间
    require("hall.util.GameUtil"):LogoutRoom()

    audio.stopMusic()
    --离开房间
    display_scene(GameScene_filePath)
end

function CommonTips:ctor(data)
    self.data = data
    local size = data.size or cc.size(600, 400)
    if size.width < 500 then--最小尺寸
        size.width = 500
    end
    if size.height < 350 then--最小尺寸
        size.height = 350
    end
    --移除所有加载进度条
    require("hall.GameCommon"):landLoading(false)
    require(NetworkLoadingView_filePath):removeView(17)
    self:setMask()
    self:initUI(size)
    self:showUIInfo(data)
    self:setTag(99998)
    if data.sceneName then
        self:setName(data.sceneName)
    end
end

function CommonTips:initUI(size)
    import("hall.tool.init")
    GameUtils.setNodeNameBindObj(self)
    display.doLayout(self)
    self.bg = self.root.bg
    self.titleTxt = self.bg.titleTxt
    self.btnCancel = self.bg.btnCancel
    self.btnSure = self.bg.btnSure
    self.msgTxt = self.bg.msgTxt
    self.bg:setContentSize(size)

    self.btnCancel:onClick(handler(self, self.onClickBtnCancel), true)
    self.btnSure:onClick(handler(self,self.onClickBtnSure), true)
end

function CommonTips:showUIInfo(data)
    if data.type == 1 then
        self.btnCancel:setVisible(false)
        self.btnSure:setVisible(true)
        local size = self.root.bg:getContentSize()
        self.btnSure:setPositionX(size.width / 2)
    elseif data.type == 2 then
        self.btnSure:setVisible(true)
        self.btnCancel:setVisible(true)
    end
    self.titleTxt:setString(data.title or "提示")
    self.msgTxt:setString(data.content or "")
end

function CommonTips:onClickBtnCancel(event)
    if self.data.callBackCancel then
        self.data.callBackCancel()
    end
    self:removeSelf()
end

function CommonTips:onClickBtnSure(event)
    if self.data.callBackSure and type(self.data.callBackSure) == "function" then
        self.data.callBackSure()
    end
    self:removeSelf()
end

function CommonTips:setMask()
	local director = cc.Director:getInstance()
	local size = director:getWinSize()
    self.maskLayout = ccui.Layout:create()
    self.maskLayout:setAnchorPoint(cc.p(0.5, 0.5))
    self.maskLayout:setContentSize(cc.size(size.width, size.height))

    -- local size = self:getContentSize()
    self.maskLayout:setPosition(cc.p(size.width / 2, size.height / 2))
    self.maskLayout:setBackGroundColorType(1)
    self.maskLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    self.maskLayout:setBackGroundColorOpacity(150)
    self.maskLayout:setTouchEnabled(true)
    self.maskLayout:setVisible(true)
    self:addChild(self.maskLayout, -1000)
end

return CommonTips