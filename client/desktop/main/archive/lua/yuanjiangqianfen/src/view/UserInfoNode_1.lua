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
        require("hall.GameCommon"):getUserHead(data["icon_url"], data["uid"], data["sex"], self.headImg, 79, false, nil)
    end
    self:setReadyVisible(data.isReady or false)
    self:setPassVisible(false)
    self.rankFlag:setVisible(false)
    self:hideMoreNode()
    self:createOptKuangAni()
    self:setUserGameScore()
end

function UserInfoNode:setLeftPlayer(b)
    self.isLeftPlayer = b
end

function UserInfoNode:hideMoreNode()
    if self.isLeftPlayer then
        self.leftReadyFlag:setVisible(false)
        self.leftBuyaoFlag:setVisible(false)
    else
        self.rightReadyFlag:setVisible(false)
        self.rightBuyaoFlag:setVisible(false)
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
    if self.isLeftPlayer then
        self.rightReadyFlag:setVisible(b)
    else
        self.leftReadyFlag:setVisible(b)
    end
end

function UserInfoNode:showPassAni(times)
    times = times == nil and 2 or times
    local seq = cc.Sequence:create(cc.DelayTime:create(times), cc.CallFunc:create(function ( ... )
                if self.isLeftPlayer then
                    self.rightBuyaoFlag:setVisible(false)
                else
                    self.leftBuyaoFlag:setVisible(false)
                end
            end))

    if self.isLeftPlayer then
        self.rightBuyaoFlag:setVisible(true)
        self.rightBuyaoFlag:runAction(seq)
    else
        self.leftBuyaoFlag:setVisible(true)
        self.leftBuyaoFlag:runAction(seq)
    end
end

function UserInfoNode:setUserGameScore(sP, tP, sB, tB)
    print("asdfasfd -------------", sP, tP, sB, tB, debug.traceback())
    self:setSinglePickScore(sP)
    self:setTotalPickScore(tP)
    self:setSingleBombScore(sB)
    self:setTotalBombScore(tB)
end

function UserInfoNode:setSinglePickScore(score)
    self.singleScore:setString(string.format("积分:%d", tonumber(score or "0")))
end

function UserInfoNode:setTotalPickScore(score)
    self.totalScore:setString(string.format("总积分:%d", tonumber(score or "0")))
end

function UserInfoNode:setSingleBombScore(score)
    self.singleBombScore:setString(string.format("喜分:%d", tonumber(score or "0")))
end

function UserInfoNode:setTotalBombScore(score)
    self.totalBombScore:setString(string.format("总喜分:%d", tonumber(score or "0")))
end

function UserInfoNode:setPassVisible(b)
    if self.isLeftPlayer then
        self.rightBuyaoFlag:setVisible(b)
    else
        self.leftBuyaoFlag:setVisible(b)
    end
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
        self.rightCardSize:setString((size or 0))
    else
        self.leftCardSize:setString((size or 0))
        self.leftSizeBg:setVisible(false)
    end
end

-- 出牌后显示的数量
function UserInfoNode:reduceCardSize(size)
    if self.isLeftPlayer then
        self.rightSizeBg:setVisible(false)
        -- local preSize = tonumber(self.rightCardSize:getString())
        self.rightCardSize:setString(size or 0)
        -- self.rightCardSize:setString((preSize or 0) - (size or 0))
    else
        -- local preSize = tonumber(self.leftCardSize:getString())
         self.leftCardSize:setString(size or 0)
        -- self.leftCardSize:setString((preSize or 0) - (size or 0))
        self.leftSizeBg:setVisible(false)
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

function UserInfoNode:createOptKuangAni()
    local FadeIn = cc.FadeIn:create(0.5)
    local FadeOut = cc.FadeOut:create(0.5)
    local seqAc = cc.Sequence:create(FadeIn, FadeOut)
    self.optKuang:setVisible(false)
    self.optKuang:runAction(cc.RepeatForever:create(seqAc))
end

function UserInfoNode:showRank(rank)
    self.rankFlag:setVisible(true)
    self.rankFlag:loadTexture("yuanjiangqianfen/res/image/rank_flag".."rank"..".png")
    print("showRank --------------------- ", rank)
    if self.isLeftPlayer then
        self.rankFlag:setPositionX(170)
    else
        self.rankFlag:setPositionX(-70)
    end
end

function UserInfoNode:onExit()
    if self.secondSchedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.secondSchedulerID)
    end
    self.secondSchedulerID = nil
end

return UserInfoNode