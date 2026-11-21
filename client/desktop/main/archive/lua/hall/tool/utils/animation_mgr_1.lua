--[[
    动画管理类
]]
local AnimationMgr = class("AnimationMgr")

function AnimationMgr:ctor()
    self.animationTb = {}
    self.addTb = {}
    self.isUpdatting = false
end

function AnimationMgr:update(dt)
    self.isUpdatting = true
    for animation in pairs(self.animationTb) do
        if animation then 
            animation:update(dt)    
        end
    end
    self.isUpdatting = false

    local animation = next(self.animationTb)
    while animation do
        local nextAnimation = next(self.animationTb, animation)
        if animation.deleted then
            self.animationTb[animation] = nil
        end
        animation = nextAnimation
    end
    
    for k, v in pairs(self.addTb) do
        self.animationTb[k] = v
        self.addTb[k] = nil
    end
end

function AnimationMgr:addAnimation(animation)    
    if not self.isUpdatting then 
        self.animationTb[animation] = true
        return 
    end
    if not self.animationTb[animation] then 
        self.addTb[animation] = true
    end
end

function AnimationMgr:remove(animation)
    if not self.isUpdatting then 
        if self.animationTb[animation] then 
            self.animationTb[animation] = nil
        end
        return 
    end
    if self.animationTb[animation] then 
        animation.deleted = true
    end
end

function AnimationMgr:resumeAnime()
    for animation in pairs(self.animationTb) do
        animation:resumeAnime()
    end
end

function AnimationMgr:pauseAnime()
    for animation in pairs(self.animationTb) do
        animation:pauseAnime()
    end
end

function AnimationMgr:destroy()
    self.animationTb = {}
    self.addTb = {}
end

return AnimationMgr.new()