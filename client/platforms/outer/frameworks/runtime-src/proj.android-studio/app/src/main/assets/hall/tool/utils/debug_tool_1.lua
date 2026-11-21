--调试工具

-- local filePath = "hall.tool.utils.reload_file"
local function reload(path)
	package.loaded[path] = nil
	require(path)
end

local DebugTool = {}

function DebugTool.reloadFile()
	local ok, ret = pcall(function()
		package.loaded[filePath] = nil
        return require(filePath)
    end)
    printInfo("reloadFile:%s, error:%s", ok, ret)
    viewMgr:showTip({text = string.format("<font color=#%s>reload file %s</font>", ok and "1eff00" or "ff2828", ok and "succeed" or "fail")})
end

return DebugTool