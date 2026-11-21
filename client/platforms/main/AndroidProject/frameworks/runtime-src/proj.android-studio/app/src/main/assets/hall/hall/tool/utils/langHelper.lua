
local global = _C("global")
local langConf = _C("lang_" .. global.LANG)
function _T(key)
    return langConf[key] or key
end