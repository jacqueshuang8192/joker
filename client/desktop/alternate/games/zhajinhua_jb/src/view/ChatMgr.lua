local ChatMgr = class("ChatMgr")

local chatTxt = {
	[1]  = '跟',
	[2]  = '闷' ,
	[3]  = '不要了',
	[4]  = '丢了丢了',
	[5]  = '涨价',
	[6]  = '看牌',
	[7]  = '闷到底',
	[8]  = '来，投资一点',
	[9]  = '不来了',
	[10]  = '跟到底',
}

function ChatMgr:ctor(GameSceneView)
	self.GameSceneView = GameSceneView
end

function ChatMgr:setTextMessage(textMessage, uid)
    local faceUI = self.GameSceneView:getChildByName("faceUI")
    local seatId = g_317.userInfos[uid].seat_id
	local UserInfoView = self.GameSceneView:getPlayerBySeatId(seatId)
	faceUI:showGetText(uid, textMessage, 0, UserInfoView.img_head, UserInfoView.isLeft)
end

function ChatMgr:getGenTxt(pack)
	local point = 0
    if g_317.isKan[pack.uid] == nil then
        point = 2
        if pack.now_turns >= 3 then
            local num = math.random(1,10)
            if num >= 7 then
                point = 7
            else
                point = 2
            end
        end
    else
        point = 1
        if pack.now_turns >= 3 then
            local num = math.random(1,10)
            if num >= 7 then
                point = 10
            else
                point = 1
            end
        else
            local num = math.random(1,10)
            if num >= 7 then
                point = 8
            end
        end
	end

	self:setTextMessage(chatTxt[point], pack.uid)
	return chatTxt[point]
end

function ChatMgr:getQiTxt(uid)
	local point = 4
    local num = math.random(1,10)
    if num % 2 == 0 then
        point = 3
    end
	self:setTextMessage(chatTxt[point], uid)
	return chatTxt[point]
end

function ChatMgr:getJiaTxt(uid)
	self:setTextMessage(chatTxt[5], uid)
	return chatTxt[5]
end

function ChatMgr:getQuanYaTxt(uid)
	self:setTextMessage(chatTxt[5], uid)
	return chatTxt[5]
end

function ChatMgr:getKanTxt(uid)
	self:setTextMessage(chatTxt[6], uid)
	return chatTxt[6]
end

return ChatMgr