--[[
* author:   zwm
* date:     2019-04-11
* describe: 玩家信息节点绑定
--]]

local UserInfoNode = class("UserInfoNode")

function UserInfoNode:_init(data)
    self.isLeftPlayer = data.isLeftPlayer
    self.userInfo = data
    self:initUserInfo(data)
end

function UserInfoNode:initUserInfo(data)
    self.userInfo = data
    local strNick = require("hall.GameCommon"):formatNick(data.name, 4)
    self.name:setString(strNick or "")
    self.socre:setString(data.score or "")
    if data.icon_url == nil then
        self.headImg:loadTexture("hall/res/commom/blank_kuang.png")
    else
        local otherInfo = json.decode(self.userInfo.otherInfo) or {}
        dump(otherInfo, "otherInfo == ")
        local address = otherInfo.addres
        local ip = otherInfo.ip
        require("hall.GameCommon"):getUserHead(data["icon_url"], data["uid"], data["sex"], self.headImg, 79, false, data["name"], false, ip, address)
    end
    if data["uid"] and PLAYER_HEADS_POSITION_TABLE_FACE then
        local   worldpoint = (self.headImg:getParent()):convertToWorldSpace(self.headImg:getPosition()) --这样写是为了贴近函数的原始用法
        PLAYER_HEADS_POSITION_TABLE_FACE[data["uid"]] = worldpoint
    end


    self:setReadyVisible(data.isReady)
    self:setAlertVisible(data.isAlert)
    self:setPassVisible(false)
    self:hideMoreNode()
    self.piaoBg:setVisible(false)
end

function UserInfoNode:setLeftPlayer(b)
    self.isLeftPlayer = b
end

function UserInfoNode:hideMoreNode()
    if self.isLeftPlayer then
        self.leftReadyFlag:setVisible(false)
        self.leftBuyaoFlag:setVisible(false)
        self.leftAlert:setVisible(false)
    else
        self.rightReadyFlag:setVisible(false)
        self.rightBuyaoFlag:setVisible(false)
        self.rightAlert:setVisible(false)
    end
    self.rWScore:setVisible(false)
    self.lWScore:setVisible(false)
    self.rLScore:setVisible(false)
    self.lLScore:setVisible(false)
    self.rightSizeBg:setVisible(false)
    self.leftSizeBg:setVisible(false)
    self.fangzhuFlag:setVisible(false)
    self.zhuangFlag:setVisible(false)
end

function UserInfoNode:setFangZhuFlag( state )
    -- body
    self.fangzhuFlag:setVisible(state)
end

function UserInfoNode:setZhuangFlag( state )
    -- body
    self.zhuangFlag:setVisible(state)
end

function UserInfoNode:setReadyVisible(b)
    if b == nil then b = false end

    if self.isLeftPlayer then
        self.rightReadyFlag:setVisible(b)
    else
        self.leftReadyFlag:setVisible(b)
    end
end

function UserInfoNode:showPassAni(times)
    times = times == nil and 1.5 or times
    local seq = cc.Sequence:create(cc.DelayTime:create(times), cc.CallFunc:create(function ( ... )
                if self.isLeftPlayer then
                    self.rightBuyaoFlag:setVisible(false)
                else
                    self.leftBuyaoFlag:setVisible(false)
                end
            end))
    -- local function handler1(armature, MovementEventType, handlerName)
    --     if MovementEventType == ccs.MovementEventType.complete then
    --         armature:setVisible(false)
            
    --     end
    -- end
    -- local armature = ccs.Armature:create("yaobuqi")  -- 创建动画对象
    -- armature:addTo(self)
    if self.isLeftPlayer then
        -- armature:setPosition(cc.p(220, 120))
        self.rightBuyaoFlag:setVisible(true)
        -- local anim = self.rightBuyaoFlag:getAnimation()
        -- anim:playWithIndex(0, 0, 0)
        -- anim:setMovementEventCallFunc(handler1)
        self.rightBuyaoFlag:runAction(seq)
    else
        self.leftBuyaoFlag:setVisible(true)
        -- -- armature:setPosition(cc.p(-120, 120))
        -- local anim = self.leftBuyaoFlag:getAnimation()
        -- anim:playWithIndex(0, 0, 0)
        -- anim:setMovementEventCallFunc(handler1)
        self.leftBuyaoFlag:runAction(seq)
    end
end

function UserInfoNode:setPassVisible(b)
    if b == nil then b = false end
    
    if self.isLeftPlayer then
        self.rightBuyaoFlag:setVisible(b)
    else
        self.leftBuyaoFlag:setVisible(b)
    end
end

function UserInfoNode:setAlertVisible(b)
    if b == nil then b = false end
    self:clearUserAni()
    if self.isLeftPlayer then
        self.rightAlert:setVisible(b)
        self.rightAlert:runAction(self:creatBlinkAni())
    else
        self.leftAlert:setVisible(b)
        self.leftAlert:runAction(self:creatBlinkAni())
    end
end

function UserInfoNode:clearUserAni(  )
     if self.isLeftPlayer then
        self.rightAlert:setVisible(false)
        self.rightAlert:stopAllActions()
    else
        self.leftAlert:setVisible(false)
        self.leftAlert:stopAllActions()
    end
end

function UserInfoNode:creatBlinkAni(  )
    local sequence = cc.Sequence:create(cc.DelayTime:create(0.2),cc.FadeOut:create(0.4),cc.DelayTime:create(0),cc.FadeIn:create(0.4))
    local repeatForever = CCRepeatForever:create(sequence)

    return repeatForever
end

function UserInfoNode:exchangeForSingleScore(score)
    --(self.userInfo.score or 0) + 
    local newScore = score
    self.userInfo.score = newScore
    self:setUserScore(newScore)
end

function UserInfoNode:setUserScore(score)
    self.userInfo.score = score
    self.socre:setString(score or "0")
end

function UserInfoNode:getUserScore(score)
    return self.userInfo.score or 0
end

function UserInfoNode:showCheckTip()
    local mb = cc.MoveBy:create(1.5,cc.p(0,60))
    local mb2 = cc.MoveBy:create(0.1,cc.p(0,-60))
    local hide = cc.Hide:create()

    --add by zzy 2019-8-7 修改这个文字显示效果
    local fo1 = cc.FadeIn:create(0.01)

    local fo = cc.FadeOut:create(0.5)
    local callBack = cc.CallFunc:create(function()
            self.rTip:setVisible(false)
            self.lTip:setVisible(false)
        end)
    local seq = cc.Sequence:create(fo1,mb, fo, hide, mb2, callBack)
    if self.isLeftPlayer then
        self.rTip:setVisible(true)
        self.lTip:setVisible(false)
        self.rTip:runAction(seq)
    else
        self.lTip:setVisible(true)
        self.rTip:setVisible(false)        
        self.lTip:runAction(seq)
    end
end

function UserInfoNode:showResutlScore(score)
    local mb = cc.MoveBy:create(1.5,cc.p(0,60))
    local mb2 = cc.MoveBy:create(0.1,cc.p(0,-60))
    local hide = cc.Hide:create()

    --add by zzy 2019-8-7 修改这个文字显示效果
    local fo1 = cc.FadeIn:create(0.01)

    local fo = cc.FadeOut:create(0.5)
    local callBack = cc.CallFunc:create(function()
            self.rWScore:setVisible(false)
            self.lWScore:setVisible(false)
            self.rLScore:setVisible(false)
            self.lLScore:setVisible(false)
        end)
    local seq = cc.Sequence:create(fo1,mb, fo, hide, mb2, callBack)
    local str = score > 0 and "+"..tostring(score) or tostring(score)
    if self.isLeftPlayer then
        if score >= 0 then
            self.rWScore:setVisible(true)
            self.lWScore:setVisible(false)
            self.rLScore:setVisible(false)
            self.lLScore:setVisible(false)
            self.rWScore:setString(str)
            self.rWScore:runAction(seq)
        else
            self.rLScore:setVisible(true)
            self.rWScore:setVisible(false)
            self.lWScore:setVisible(false)
            self.lLScore:setVisible(false)
            self.rLScore:setString(str)
            self.rLScore:runAction(seq)
        end
    else
        if score >= 0 then
            self.lWScore:setVisible(true)
            self.rWScore:setVisible(false)
            self.rLScore:setVisible(false)
            self.lLScore:setVisible(false)
            self.lWScore:setString(str)
            self.lWScore:runAction(seq)
        else
            self.lLScore:setVisible(true)
            self.rWScore:setVisible(false)
            self.lWScore:setVisible(false)
            self.rLScore:setVisible(false)
            self.lLScore:setString(str)
            self.lLScore:runAction(seq)
        end
    end
end

function UserInfoNode:setIsLeftPlayer(_bool)
   self.isLeftPlayer = _bool
end

function UserInfoNode:setSurplusCardSize(size)
    if self.isLeftPlayer then
        self.rightSizeBg:setVisible(false)
        self.rightCardSize:setVisible(false)--setString((size or 0))
    else
        self.leftCardSize:setVisible(false)--setString((size or 0))
        self.leftSizeBg:setVisible(false)
    end
    self:reduceCardSize(size)
end

-- 出牌后显示的数量
function UserInfoNode:reduceCardSize(size)
    if self.isLeftPlayer then
        self.rightSizeBg:setVisible(true)
        local preSize = tonumber(self.rightCardSize:getString())
        self.rightCardSize:setVisible(true)--setString(size or 0)
        self.rightCardSize:setString(size)
    else
        local preSize = tonumber(self.leftCardSize:getString())
         self.leftCardSize:setVisible(true)--setString(size or 0)
        self.leftCardSize:setString(size)
        self.leftSizeBg:setVisible(true)
    end
end

function UserInfoNode:getUserId()
    return self.userInfo.uid
end

function UserInfoNode:getUserInfo()
    return self.userInfo
end

function UserInfoNode:showFaceAndTxtByIndex(idx)
    if self.isLeftPlayer then
        self.rightChat:setVisible(true)
        self.leftChat:setVisible(false)
    else
        self.rightChat:setVisible(false)
        self.leftChat:setVisible(true)
    end

    if idx > 50 then -- 表示接受的是表情
        local ani = g_mainScene.gameMsgLayer:getFaceAniByIdx(idx)
        --transition.playAnimationOnce(ani)
        --transition.playAnimationOnce(self.faceAni,ani,true,function () end)
        --self:runAction(ani)
        self.faceAni:stopAllActions()
        self.faceAni:setVisible(true)
        local selfv = self
       local seq =  cc.Sequence:create(ani,cc.CallFunc:create(function ()
            selfv.faceAni:setVisible(false)
        end))
        self.faceAni:runAction(seq)
    else
        local info = g_mainScene.gameMsgLayer:getTxtVoice(idx)

        if self.isLeftPlayer then
            --self.rightChat:setString(info.txt or "")
            local faceUI = g_mainScene:getChildByName("faceUI")
            if faceUI == nil then
                print("scene:"..SCENENOW["name"],"not match faceUI")
                return
            end
            faceUI:showGetFace(self.userInfo.uid, idx, self.userInfo.sex, self, 1)
        else
            --self.leftChat:setString(info.txt or "")
            local faceUI = g_mainScene:getChildByName("faceUI")
            if faceUI == nil then
                print("scene:"..SCENENOW["name"],"not match faceUI")
                return
            end
            faceUI:showGetFace(self.userInfo.uid, idx, self.userInfo.sex, self, 0)
        end
        --local path = self.userInfo.sex == 1 and info.path[1] or info.path[2]
        --
        --local FaceUIPath = "hall/FaceUI/"
        --local voiceResPath = FaceUIPath .."audio/"
        --
        --require("hall.GameCommon"):playEffectSound(voiceResPath..path)
        --
        --self.secondSchedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.schedulerCallBack), 3, false)
    end
end

function UserInfoNode:schedulerCallBack()
    if self.secondSchedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.secondSchedulerID)
    end
    if self.isLeftPlayer then
        self.rightChat:setString("")
    else
        self.leftChat:setString("")
    end
end

function UserInfoNode:onExit()
    if self.secondSchedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.secondSchedulerID)
    end
    self.secondSchedulerID = nil
end

return UserInfoNode