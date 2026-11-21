-- lfs.lua — LuaFileSystem 纯 Lua 替代实现
-- 替代原生 lfs.so，基于 Cocos2d-x FileUtils

local lfs = {}
local _currentDir = ""

local function _fixPath(path)
    if not path then return "" end
    -- 确保路径以 / 结尾（目录操作）
    return path
end

function lfs.currentdir()
    if _currentDir == "" then
        _currentDir = cc.FileUtils:getInstance():getWritablePath()
    end
    return _currentDir
end

function lfs.chdir(path)
    if not path then return false, "invalid path" end
    local fileUtils = cc.FileUtils:getInstance()
    if fileUtils:isDirectoryExist(path) then
        _currentDir = path
        return true
    end
    -- 也尝试不加尾部斜杠
    local altPath = path
    if string.sub(altPath, -1) == "/" then
        altPath = string.sub(altPath, 1, -2)
    end
    if fileUtils:isDirectoryExist(altPath) then
        _currentDir = altPath
        return true
    end
    return false, "no such directory"
end

function lfs.mkdir(path)
    if not path then return false, "invalid path" end
    local fileUtils = cc.FileUtils:getInstance()
    -- 移除尾部斜杠
    local dirPath = path
    if string.sub(dirPath, -1) == "/" then
        dirPath = string.sub(dirPath, 1, -2)
    end
    if fileUtils:isDirectoryExist(dirPath) then
        return true  -- already exists
    end
    local ok = fileUtils:createDirectory(dirPath)
    return ok, (ok and nil or "create failed")
end

function lfs.rmdir(path)
    if not path then return false, "invalid path" end
    local fileUtils = cc.FileUtils:getInstance()
    local dirPath = path
    if string.sub(dirPath, -1) == "/" then
        dirPath = string.sub(dirPath, 1, -2)
    end
    if not fileUtils:isDirectoryExist(dirPath) then
        return true  -- already gone
    end
    local ok = fileUtils:removeDirectory(dirPath)
    return ok, (ok and nil or "remove failed")
end

-- 目录迭代器
function lfs.dir(path)
    local fileUtils = cc.FileUtils:getInstance()
    local files = {}

    if path and fileUtils:isDirectoryExist(path) then
        -- 尝试通过 searchPath 机制获取文件列表
        -- Cocos2d-x 3.16 的 FileUtils 在 Android 上可能不支持 listFiles
        -- 作为回退，返回 "." 和 ".."
    end

    -- 构建一个安全的迭代器
    local i = 1
    local function iter(state)
        i = i + 1
        if i <= #state then
            return state[i]
        end
        return nil
    end

    table.insert(files, ".")
    table.insert(files, "..")

    return iter, files
end

function lfs.attributes(path, attr)
    if not path then return nil end
    local fileUtils = cc.FileUtils:getInstance()
    if attr == "mode" then
        if fileUtils:isDirectoryExist(path) then
            return "directory"
        elseif fileUtils:isFileExist(path) then
            return "file"
        end
    end
    return nil
end

return lfs
