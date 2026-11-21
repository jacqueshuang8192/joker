
local Loader = Loader

local textureCache = cc.Director:getInstance():getTextureCache()
local spriteFrameCache = cc.SpriteFrameCache:getInstance()
local ResLoader = class("ResLoader")

function ResLoader:ctor(resList)
	self._loader = Loader.new()
	self._spriteFrames = {}
	self._textures = {}
	self._sounds = {}
	self._isLoaded = false

	self._uiList = resList.ui or {}
	self._fishList = resList.fish or {}
	self._effectList = resList.effect or {}
	self._bgList = resList.bg or {}
	self._soundList = resList.sound or {}
	self._other = resList.other or {}
	self._completeHandle = self._loader:addEventListener(self._loader.EVENT_COMPLETE
		, function()
			self._isLoaded = true
			if self._onComplete then self._onComplete() end
		end)
end

function ResLoader:getLoader()
	return self._loader
end

function ResLoader:isLoaded()
	return self._isLoaded
end

function ResLoader:load(callback)
	self._onComplete = callback
	self._loader:start()
end

function ResLoader:parse(package)
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("fight_plist/prop.plist")

	self:_parseUI(package)
	self:_parseBg()
	self:_parseFish()
	self:_parseEffect()
	self:_parseSound()
	self:_parseOther()
end

function ResLoader:destroy()
	self._loader:stop()
	if self._completeHandle then
		self._loader:addEventListener(self._completeHandle)
		self._completeHandle = nil
	end

	for path, texture in pairs(self._spriteFrames) do
		spriteFrameCache:removeSpriteFrameByName(path)
	    textureCache:removeTexture(texture)
	end

	for path, texture in pairs(self._textures) do
		textureCache:removeTexture(texture)
	end

	for path in pairs(self._sounds) do
		audio.unloadSound(path)
	end

	self._isLoaded = false
end

function ResLoader:_parseBg()
	local items = {}
	for _, path in pairs(self._bgList) do
		local imgPath = resPath.getUIImage(path)
		items[#items + 1] = {type = LoadType.IMAGE
						, path = imgPath
						, callback = function(_, texture) self._textures[imgPath] = texture end
					}
	end
	
	self._loader:addItems(items)
end

function ResLoader:_parseUI(package)
	local items = {}
	for _, info in pairs(self._uiList[package] or {}) do
		-- local imgPath = resPath.getUIImage(info.imgPath)
		-- local plistPath = resPath.getUIImage(info.plistPath)
		local imgPath = info.imgPath
		local plistPath = info.plistPath
		dump({imgPath, plistPath},"--------------------------------------加载UI")
		items[#items + 1] = {type = LoadType.IMAGE
						, path = imgPath
						, callback = function(_, texture) 
		spriteFrameCache:addSpriteFrames(plistPath)
							self._spriteFrames[plistPath] = texture
	end
					}
	end
	
	self._loader:addItems(items)
end

function ResLoader:_parseFish()
	local items = {}
	for _, info in pairs(self._fishList) do
		local imgPath = resPath.getAnim(info.imgPath)
		local plistPath = resPath.getAnim(info.plistPath)
		items[#items + 1] = {type = LoadType.IMAGE
						, path = imgPath
						, callback = function(_, texture) 
							spriteFrameCache:addSpriteFrames(plistPath)
							self._spriteFrames[plistPath] = texture
						end
					}
	end
	
	self._loader:addItems(items)
end

function ResLoader:_parseEffect()
	local items = {}
	for _, info in pairs(self._effectList) do
		local imgPath = resPath.getAnim(info.imgPath)
		local plistPath = resPath.getAnim(info.plistPath)
		items[#items + 1] = {type = LoadType.IMAGE
						, path = imgPath
						, callback = function(_, texture) 
							spriteFrameCache:addSpriteFrames(plistPath)
							self._spriteFrames[plistPath] = texture
						end
					}
	end
	
	self._loader:addItems(items)
end

function ResLoader:_parseSound()
	local items = {}
	for _, path in pairs(self._soundList) do
		local soundPath = resPath.getSound(path)
		items[#items + 1] = {type = LoadType.SOUND
						, path = soundPath
						, callback = function(_, result) self._sounds[soundPath] = true end
					}
	end
	self._loader:addItems(items)
end

function ResLoader:_parseOther( )
	local items = {}
	for _, info in pairs(self._other) do
		local imgPath = info.imgPath
		local plistPath = info.plistPath
		items[#items + 1] = {type = LoadType.IMAGE
						, path = imgPath
						, callback = function(_, texture) 
							spriteFrameCache:addSpriteFrames(plistPath)
							self._spriteFrames[plistPath] = texture
						end
					}
	end
	self._loader:addItems(items)
end

return ResLoader