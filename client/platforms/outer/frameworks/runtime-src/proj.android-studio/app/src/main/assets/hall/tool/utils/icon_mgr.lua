--[[
	图标加载管理
]]

local textureCache = cc.Director:getInstance():getTextureCache()

local IconMgr = class("IconMgr")

function IconMgr:ctor()
	self.iconTb = {}
end

--[[
	加载Icon资源
	@param path 相对于icon文件加的路径，没有后缀名
	@result 返回完整路径
]]
function IconMgr:get(path)
	local icon = self.iconTb[path]
	local iconPath = "icon/" .. path .. ".png"
	if not icon then
		icon = textureCache:addImage(iconPath)
		if icon then
			icon:retain()
			self.iconTb[path] = icon
		end
	end
	return iconPath
end

--[[
	移除Icon资源
	@param path 相对于icon文件加的路径，没有后缀名
]]
function IconMgr:remove(path)
	local icon = self.iconTb[path]
	if icon then
		icon:release()
		self.iconTb[path] = nil
		if icon:getReferenceCount() <= 1 then
			textureCache:removeTexture(icon)
		end
	end
end

--[[
	移除未使用的Icon资源
]]
function IconMgr:removeUnused()
	for path, icon in pairs(self.iconTb) do
		if icon:getReferenceCount() <= 2 then
			icon:release()
			textureCache:removeTexture(icon)
			self.iconTb[path] = nil
		end
	end
end

return IconMgr.new()