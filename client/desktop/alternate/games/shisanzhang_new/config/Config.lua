local Config = class("Config", cc.Node)

function Config:ctor()
	self:setNodeEventEnabled(true)
    g_365_isHuaSe = false--false不比花色  true比花色
    g_365_isSkipSendFace = false--是否禁用表情动画
    g_CompCardTime = 0.12--每一道开牌速度实际上是 * 5了的
    -- isShowJieSanBtn = false--不显示解散按钮
end

function Config:onExit( )
    if USER_INFO.level ~= 365 then--退出游戏或者返回大厅的时候清除
        g_365_isHuaSe = nil
        g_365_isSkipSendFace = nil
        g_CompCardTime = nil
        isShowJieSanBtn = nil--不显示解散按钮
    end
end

return Config