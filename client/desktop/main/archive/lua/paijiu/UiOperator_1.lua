---
--- Created by ChangShan.
--- DateTime: 2018/1/23 20:28
---

local uiOperator = class("uiOperator")

--获取子控件table
function uiOperator:loadChildrenWidget(_node, _childrenTable)
    local function func(node, childrenTable)
        if node ~= nil and node:getChildrenCount() <= 0 then return end
        local cTable = node:getChildren()
        for i, v in ipairs(cTable) do
            childrenTable[v:getName()] = v
            func(v, childrenTable)
        end
    end
    if _childrenTable == nil then _childrenTable = {} end
    func(_node, _childrenTable)
    return _childrenTable
end

function uiOperator:getWidget(mainPanel)
    -- 玩家主界面
    local player_1 = mainPanel:getChildByName("player_panel_1")
    local player_2 = mainPanel:getChildByName("player_panel_2")
    local player_3 = mainPanel:getChildByName("player_panel_3")
    local player_4 = mainPanel:getChildByName("player_panel_4")

    -- 道界面
    local chip_panel = mainPanel:getChildByName("chip_panel")

    -- 牌堆界面
    local card_pool_panel = mainPanel:getChildByName("card_pool_panel")

    -- 闲家操作按钮
    local player_panel = mainPanel:getChildByName("player_panel")

    -- 庄家操作按钮
    local banker_panel = mainPanel:getChildByName("banker_panel")

    -- 抢庄操作按钮
    local zhuang_panel = mainPanel:getChildByName("zhuang_panel")

    -- 设备信息
    local device_info_panel = mainPanel:getChildByName("device_info_panel")

    -- 桌面按钮
    local menu_panel = mainPanel:getChildByName("menu_panel")


    ------------------- 获取界面上的所有子节点----------------

    PLAYER_MY = self:loadChildrenWidget(player_1)
    PLAYER_LEFT = self:loadChildrenWidget(player_2)
    PLAYER_TOP = self:loadChildrenWidget(player_3)
    PLAYER_RIGHT = self:loadChildrenWidget(player_4)

    CARDS_POOL = self:loadChildrenWidget(card_pool_panel)

    PLAYER_PANEL = self:loadChildrenWidget(player_panel)

    BANKER_PANEL = self:loadChildrenWidget(banker_panel)

end


return uiOperator