--[[
* author:   zwm
* date:     2019-03-15
* describe: cocos里，序列帧、button换图片、精灵换图片等的处理
--]]

local CocosUtil = class("CocosUtil")

-- 序列帧动画
-- 参数: filePath 图集的路径
-- 参数: name 图集的名字
-- 参数: size 图集的数量
-- 参数: times 循环次数 (-1 表示无限循环)
-- 参数: gap 时间间隙
-- 参数: beginIdx 第一张图片的下标
function CocosUtil:playAnimation(filePath, name, size, times, gap, beginIdx)
    if filePath == nil or name == nil or size == nil or times == nil or gap == nil then
        print("in function [playAnimation]:params has nil value ...")
        return
    end
    local spfc = cc.SpriteFrameCache:getInstance()
    -- 将plist配置文件和材质导入
    spfc:addSpriteFrames(filePath)
    -- 新建一个动画
    local animation = cc.Animation:create()

    local begin = beginIdx == nil and 1 or beginIdx
    -- 添加精灵帧
    for i = 1, size do
        -- 根据在TexturePacker中的图片的名称获取
        animation:addSpriteFrame(spfc:getSpriteFrame(name..(begin+i-1)..".png"))
    end
    -- 设置每帧延时
    animation:setDelayPerUnit(gap)
    -- 设置动画播放完成后是否回到起始帧
    animation:setRestoreOriginalFrame(true)
    -- 设置动画循环次数
    if times == -1 then
        times = 90000000
    end
    animation:setLoops(times)
    -- 根据当前动画配置生成Action
    local action = cc.Animate:create(animation)
    --调用Sprite的runAction方法可以看到效果了
    return action:clone()
end

-- 替换按钮图片
-- 参数: btn 要替换图片的按钮
-- 参数: norPath 正常状态的图片
-- 参数: pressPath 按下状态的图片
-- 参数: disPath 禁用状态的图片
-- 参数: texType 0 表示原始图片, 1 表示plist图片
function CocosUtil:toReplaceButtonImg(btn, norPath, pressPath, disPath, texType)
    texType = texType == nil and 0 or texType
    if btn and btn.loadTextureNormal and btn.loadTexturePressed and btn.loadTextureDisabled then
        if norPath and pressPath then
            dump(norPath,"norPath==")
            dump(texType,"texType==")
            btn:loadTextureNormal(norPath, texType)
            btn:loadTexturePressed(pressPath, texType)
        end
        if disPath then
            btn:loadTextureDisabled(disPath, texType)
        end
    else
        print("in function [toReplaceButtonImg]:params [btn] is not button ...")
    end
end

local moveRightToLeft = function (obj)
    obj:setPositionX(CONFIG_DESIGN_WIDTH)
    local action = cc.MoveTo:create(2, cc.p(0, 0))
    obj:runAction(action)
end

local moveTopToBottom = function (obj)
    obj:setPositionY(CONFIG_DESIGN_HEIGHT)
    local action = cc.MoveTo:create(1.5, cc.p(0, 0))
    obj:runAction(action)
end

-- 添加子界面到父界面
-- 参数: parent 父节点
-- 参数: obj 子节点
-- 参数: name 子节点在父节点的名字
-- 参数: aniType 1、表示从右向左移动，2、表示从上向下移动
function CocosUtil:addObjToParent(parent, obj, name, aniType)
    if parent ~= nil and obj ~= nil and name ~= nil then
        if not parent:getChildByName(name) then
            obj:setName(name)
            obj:addTo(parent)
            moveRightToLeft(obj)
        end
    else
        print("in function [addObjToParent]:params [parent] or [obj] or [name] is nil ...")
    end
end

--替换精灵图片
-- 参数: spr 精灵
-- 参数: path 路径
function CocosUtil:toReplaceSprImg(spr, path)
    if spr and path then
        local newSpr = cc.Sprite:create(path)
        if newSpr then
            spr:setSpriteFrame(newSpr:getSpriteFrame())
        else
            newSpr = cc.Sprite:createWithSpriteFrameName(path)
            spr:setSpriteFrame(newSpr:getSpriteFrame())
        end
    else
        print("in function [toReplaceSprImg]:params [spr] or [path] is not button ...")
    end
end

--节点绑定lua 脚本
-- 参数: obj 节点
-- 参数: path 脚本的路径
-- 参数: data 初始化节点的数据
-- 说明: 绑定节点的脚本里面要有一个 _init(data)的方法
function CocosUtil:bindCocosObjToLua(obj, path, data)
    if type(path) ~= "string" then
        print("paras 2 [path] is not string .............")
        return
    end
    if tolua.isnull(obj) then
        print("paras 1 [obj] is not cocos obj .............")
        return
    end
    local t = require(path)
    if t == nil then
        print("require [path] is error .............")
        return 
    end

    self:_toGetObj(obj, t)

    for k, v in pairs(t) do obj[k] = v end

    if data and t._init then
        obj:_init(data)
    end
    return obj
end

function CocosUtil:_toGetObj(node, t)
    if tolua.isnull(node) or t == nil then return end

    if node.getName then
        --去掉csb命名的空格，加一层括号，只返回格式化后的字符串
        local name = (string.gsub(node:getName(), "^%s*(.-)%s*$", "%1")) 
        t[name] = node
    end

    local child = node:getChildren()
    if #child ~= 0 then
        for i, v in ipairs( child or {} ) do
            self:_toGetObj(v, t)
        end
    end
end

--传入字符串 , 计算字符串的个数
function CocosUtil:LuaWordNum(str)
    local fontSize = 20
    local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte >= 128 and curByte < 224 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 240 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        else
            break
        end
        -- local char = string.sub(str, i, i+byteCount-1)
        i = i + byteCount
        count = count + 1
    end
    return count
end

--函数额外传参
-- 参数: func 函数
-- 参数: ... 额外参数
function CocosUtil:Bind(func , ...)
    local num = {...}
    local test = function() end
    test = function(number)
        if number <= #num then 
            return num[number] , test(number + 1)
        end 
    end 
    return function()
       func(test(1))
    end 
end 


--函数额外传参 回调函数适用于接口返回的回调
-- 参数: func 函数
-- 参数: ... 额外参数
function CocosUtil:Bind1(func , ...)
    local num = {...}
    local test = function() end
    test = function(number)
        if number <= #num then 
            return num[number] , test(number + 1)
        end 
    end 
    return function(...)
       func(test(1) , ...)
    end 
end 

--客户端金钱转服务端金钱
--参数: client_money 客户端金额
--参数: conversion 转化倍率
function CocosUtil:ClientTransferServer(client_money , conversion)
    local server_money = client_money * conversion
    return server_money
end

--服务端金钱转客户端金钱
--参数: server_money 服务端金额
--参数: conversion 转化倍率
function CocosUtil:ServerTransferClient(server_money , conversion)
    local client_money = server_money / conversion
    return client_money
end

function CocosUtil:pairsByKeys(t)
    local a = {}
    for n in pairs(t) do a[#a + 1] = n end
    table.sort(a)
    local i = 0
    return function ()
        i = i + 1
        return a[i], t[a[i]]
    end
end
return CocosUtil