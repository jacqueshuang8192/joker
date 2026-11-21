local PkgMgr = {}

local packages = {}

local function reload(path)
	package.loaded[path] = nil
	require(path)
end

function PkgMgr.add(path)
	packages[path] = true
end

function PkgMgr.reload(path)
	if path then
		reload(path)
	else
		for path in pairs(packages) do
			package.loaded[path] = nil
		end
		for path in pairs(packages) do
			require(path)
		end
	end

	-- if not path then
	-- 	app.ctrls:reset()
	--     PkgMgr.reload("app.models.login.login_model")
	--     PkgMgr.reload("app.ctrls.init")
	--     PkgMgr.reload("app.ctrls.gameCtrl")
	--     PkgMgr.reload("app.ctrls.loginCtrl")
	--     PkgMgr.reload("app.ctrls.httpCtrl")
	--     PkgMgr.reload("app.ctrls.sdkCtrl")
	--     -- pkgMgr.reload("app.ctrls.sdkIosCtrl")
	--     PkgMgr.reload("app.errorcode")
	--     PkgMgr.reload("app.protoConfig")
	-- end
end

return PkgMgr
