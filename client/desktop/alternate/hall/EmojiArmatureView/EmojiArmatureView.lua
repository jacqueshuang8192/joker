--[[
	公告弹出框
]]
local fs = require("hall.tool.utils.fs")
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local EmojiArmatureView = class("EmojiArmatureView", NewViewBaseLayer)
local faceResPath = 1
local cpath = "hall/res/EmojiArmatureView/"
local animiPath = {
  

    ---------飞行--------
    {name = "hongbao", type = 2},
    {name = "kiss", type = 2},
    {name = "zan", type = 2},
    {name = "zhadan", type = 2},
    ---------飞行--------

     ---------中间播放-------
     {name = "bailaoye", type = 1},
     {name = "caishen", type = 1},
     {name = "dajidali", type = 1},
     {name = "haoqiyo", type = 1},
     {name = "shengqile", type = 1},
     ---------中间播放-------
    ---------一个动画--------
    -- [{name = "jiqiang", type = 3},--自己播放
    ---------一个动画--------

}

function EmojiArmatureView:onExit( )
    -- scene:getChildByName("EmojiArmatureView")
end

function EmojiArmatureView:newEmojiArmatureView(data, scene)
    local emojiArmatureView = scene:getChildByName("EmojiArmatureView")
    if not emojiArmatureView and tolua.isnull(emojiArmatureView) then
        emojiArmatureView = self.new(data)
        emojiArmatureView:hide()
        local zindex = ViewBase:getZOrderByChilds(scene)
        scene:addChild(emojiArmatureView, zindex)
    end
    return emojiArmatureView
end

function EmojiArmatureView:showScene(icon_url, toUid, sex_num, nick, ip, addres)
    addres = addres or ""
    ip = ip or "0.0.0.0"
    if ip == "" or ip =="0" then
        ip = "0.0.0.0"
    end
    if toUid == nil then return end
    
    require("hall.GameCommon"):getUserHead(icon_url, toUid, sex_num, self.head, self.head:getWidth(), false, nick)
    local txtid = string.sub(toUid, 1, 3)
    txtid = txtid.."***"
    self.id:setString(txtid)
    self.ip:setString(ip)
    self.ip:hide()
    self.nameAndId_0_0:hide()
    self.id:setPositionY(473.14)
    self.nameAndId_0:setPositionY(473.14)
    self.name:setString(nick)
    self.addres:show()
    self.nameAndId_1:show()
    self.addres:setString("未知")

    if addres == "" then
        if type(g_hall_addresss) == "table" and g_hall_addresss[toUid] then
            addres = g_hall_addresss[toUid]
        else
            --[[self.addres:hide()
            self.nameAndId_1:hide()--]]
            self.addres:setString("未知")
        end
    else
        self.addres:setString(addres or "未知")
    end

    self._toUid = toUid
    self:show()
end

function EmojiArmatureView:ctor(data)
    for i,data in ipairs(animiPath) do
        local path = string.format("%semojiAnim/%s/%s", cpath, data.name, data.name)
        if fs.isfile(path.."1.png") then
            display.addSpriteFrames(path.."1.png", path.."1.plist")
        end
        display.addSpriteFrames(path.."0.png", path.."0.plist")
    end
    local csbPath = "hall/res/EmojiArmatureView/EmojiArmatureView.csb"
    self.data = data
	EmojiArmatureView.super.ctor(self, csbPath)
    self:setName("EmojiArmatureView")
    self:enableMask(true)
    self:initUI()
    self:initEvent()
end


--[[
	初始化UI
]]
function EmojiArmatureView:initUI()
    self.ListView:removeAllChildren()
    -- self.addres:hide()
    -- self.nameAndId_1:hide()
    -- self.nameAndId_1:setString("")
    self.item:hide()
    for i,data in ipairs(animiPath) do
        local item = self.item:clone()
        local path = string.format("%semojiAnim/%s/icon.png", cpath, data.name)
        item:show()
        GameUtils.setNodeNameBindObj(item)
        self.ListView:pushBackCustomItem(item)
        item.id = i
        item.icon:loadTexture(path)
        ViewBase:setTextureSize(item.icon)
        item:onClick(handler(self, self.onClickItem))
    end
end

--[[
	初始化Event
]]
function EmojiArmatureView:initEvent()
    self.maskLayout:onClick(function(  )
        self:onClickBtnClose()
    end)
end

function EmojiArmatureView:showAnimi(toPos, fromPos, id)
    print(id)
    local name = animiPath[id].name
    local _type = animiPath[id].type
    local path = string.format("%semojiAnim/%s/%s", cpath, name, name)
    local scene = SCENENOW["scene"]
    local size = scene:getContentSize()
    local Armature = self:creArmature( path, name )
    if size.width == 1280 then
        Armature:setScale(1280 / 1920)
    end
    if _type == 1 then
        Armature:setPosition(size.width / 2, size.height / 2)
    elseif _type == 2 and toPos and fromPos then
        Armature:setPosition(fromPos)
        local move = cc.MoveTo:create(0.2, toPos)
        local func = cc.CallFunc:create(function( fc )
        end)
        Armature:runAction(cc.Sequence:create(move,func))
    elseif _type == 3 then
        Armature:setPosition(size.width / 2, size.height / 2)
    end
end

function EmojiArmatureView:creArmature( path, name, callBack )
    dump(path,"动画--------")
    local scene = SCENENOW["scene"]
    local zindex = ViewBase:getZOrderByChilds(scene)
    local effectManage = ccs.ArmatureDataManager:getInstance() 
    display.addSpriteFrames(path.."0.png", path.."0.plist")
    if fs.isfile(path.."1.png") then
        display.addSpriteFrames(path.."1.png", path.."1.plist")
    end
    effectManage:addArmatureFileInfo(path.."0.png", path.."0.plist", path..".ExportJson")
    local Armature = ccs.Armature:create(name)
    Armature:addTo(scene, zindex)
    local anim = Armature:getAnimation()
    anim:playWithIndex(0, 0, 0) --第一个参数是动画表index 第二个是时间间隔 第三个是是否循环
    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            Armature:removeSelf()
            if callBack then
                callBack()
            end
			dump(os.time(),"动画结束-----------")
        end
    end
    anim:setMovementEventCallFunc(handler1)
    return Armature
end

function EmojiArmatureView:onClickItem(event)
    if isSkipSendFace then
        self:onClickBtnClose()
        return
    end
    
    local target = event.target
    local idx = target.id
    if self.data.sendFaceHand then
        self.data.sendFaceHand(idx, "EmojiArmatureView", self._toUid)
        self:onClickBtnClose()
    end
end


function EmojiArmatureView:updateContent(data)

end

-- 关闭界面
function EmojiArmatureView:onClickBtnClose()
    self:hide()
end

return EmojiArmatureView

