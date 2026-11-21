local fs = {}
require("lfs")
local fsUtils = cc.FileUtils:getInstance()
--检查文件是否存在
function fs.exists(path)
	return fsUtils:isFileExist(path)
end

function fs.size(path)
	return io.filesize(path)
end

function fs.isfile(path)
	return not fs.isdir(path)
end

function fs.isdir(path)
	local mode = lfs.attributes(path, "mode")
	return mode == "directory"
end

--重命名文件
function fs.rename(oldname, newname)
	return os.rename(oldname, newname)
end

--读文件
function fs.read(path)
	local file = io.open(path, "rb")
	if file then
		local content = file:read("*all")
		io.close(file)
		return content
	end
	return nil
end

--写文件
function fs.write(path, content, mode)
	mode = mode or "w+b"
	local file = io.open(path, mode)
	if file then
		if file:write(content) == nil then return false end
		io.close(file)
		return true
	else
		return false
	end
end

--删除路径
function fs.remove(path)
	local mode = lfs.attributes(path, "mode")
	if mode == "directory" then
		local dirPath = path .. "/"
		for file in lfs.dir(dirPath) do
			if file ~= "." and file ~= ".." then
				local f = dirPath .. file
				fs.remove(f)
			end
		end
		lfs.rmdir(path)
	else
		os.remove(path)
	end
end

function fs.list(path)
	local files = {}
	local dirs = {}
	local function lll(dir)
		for file in lfs.dir(dir) do
			if file == "." or file == ".." then
			else
				local p = dir .. '/' .. file
				local mode = lfs.attributes(p, "mode")
				if mode == "directory" then
					lll(p)
					table.insert(dirs, p)
				else
					table.insert(files, p)
				end
			end
		end
	end

	local mode = lfs.attributes(path, "mode")
	if mode ~= "directory" then
		return
	end
	lll(path)
	return dirs, files
end

function fs.split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if (delimiter == '') then return false end
	local pos, arr = 0, {}
	-- for each divider found
	for st, sp in function() return string.find(input, delimiter, pos, true) end do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end

--创建目录
function fs.mkdir(path)
	if not fs.exists(path) then
		return lfs.mkdir(path)
	end
	return true
end

function fs.dofile(name)
	local path = fsUtils:fullPathForFilename(name)
	local function ppp()
		local filefun = loadstring(fsUtils:getDataFromFile(path))
		return filefun()
	end
	local ret, r = pcall(ppp)
	if ret then
		return r
	else
		print("[Error]----fs.dofile " .. (path or ""))
	end
end

--md5
function fs.md5(filepath)
	if filepath ~= nil then
		return cc.Crypto:MD5File(filepath)
	else
		return nil
	end
end

-- local ffff = fs.fullpath("res/ui.zip")
-- print(ffff)

-- local xx = fs.mount("DDZ", ffff, true, 1)
-- print(xx)
-- local xxxx = "@DDZ/ui/btn/begin.png"
-- display.newSprite(xxxx, 640, 320):addTo(self)

-- fs.mountclean()

function fs.data(name)
	local path = fsUtils:fullPathForFilename(name)
	local r = fsUtils:getDataFromFile(path)
	if (r) then
		return r
	else
		print("[Error]----fs.data " .. (path or ""))
	end
end

--
function fs.fullpath(name)
	return fsUtils:fullPathForFilename(name)
end

function fs.addpath(a)
	return fsUtils:addSearchPath(a)
end


function fs.load_code(file)
	return CCLuaLoadChunksFromZIP(file)
end

function fs.unload_code(file)
	local zipfile = cc.LuaZipFile:create(file)
	if(zipfile) then
		local files = zipfile:getFileList()
		for _,n in ipairs(files) do
        	package.loaded[n] = nil
        	package.preload[n] = nil
    	end
    end
end
function fs.reload_code(file)
	fs.unload_code(file)
	fs.load_code(file)
end

-- 初始可以写目录
local writepath = fsUtils:getWritablePath()
writepath = string.gsub(writepath, "[\\\\/]+$", "") .. "/"

fs.writepath = writepath
-- fs.updpath = writepath .. "upd/"
-- fs.mkdir(fs.updpath)

return fs
