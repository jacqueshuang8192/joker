---------------------------------------
-- 资源路径
---------------------------------------
local ResPath = {}

function ResPath.getEffect(path)
    return "animation/effect/" .. path
end

function ResPath.getAnim(path)
    return "animation/" .. path
end 

function ResPath.getIcon(path)
    return "icon/" .. path
end

function ResPath.getMusic(path)
    --根据平台返回不同格式
    -- if device.platform == "android" then
    --     return string.format("sound/android/%s.ogg", path)
    -- elseif device.platform == "ios" then
    --     return string.format("sound/ios/%s.m4a", path)
    -- else
        -- return string.format("sound/win32/%s.mp3", path)
    -- end
    return string.format("sound/%s.mp3", path)
end

function ResPath.getSound(path)
    --根据平台返回不同格式
    -- if device.platform == "android" then
    --     return string.format("sound/android/%s.ogg", path)
    -- elseif device.platform == "ios" then
    --     return string.format("sound/ios/%s.m4a", path)
    -- else
    --     return string.format("sound/win32/%s.mp3", path)
    -- end
    return string.format("sound/%s.mp3", path)
end

function ResPath.getShader(path)
    return "effect/" .. path
end

function ResPath.getParticle(path)
    return "effect/" .. path
end

function ResPath.getUIImage(path)
    return "ui/" .. path
end

function ResPath.getUIFrame(path)
    return path
end

function ResPath.getMisc(path)
    return "misc/" .. path
end

function ResPath.getFile(path)
    return path
end

function ResPath.getMap(path)
    return "map/" .. path
end

function ResPath.getEnemyImage(id)
    return string.format("#enemy_plane1/%s.png", id)
end

function ResPath.getPlaneImage(id)
    return string.format("icon/plane/%s.png", id)
end

function ResPath.getWingPlaneImage(id)
    return string.format("icon/wing_plane/%s.png", id)
end

function ResPath.getDropItemFrame(id)
    return string.format("drop_item_%s", id)
end

function ResPath.getFont(path)
    return "ui/fonts/" .. path
end

return ResPath