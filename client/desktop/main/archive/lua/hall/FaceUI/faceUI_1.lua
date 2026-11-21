--
-- Author: tao
-- Date: 2016-08-01 16:38:28
-- 表情

local sendHandle

local currentGameLevel
local FaceUIPath = "hall/FaceUI/"
local voiceResPath = FaceUIPath .."audio/"

local emojiResPath = ""

local faceUI=class("faceUI",function()
    return display.newScene("faceUI")
end)

faceUI.animatePlist={

    plist=FaceUIPath .. "faceAnimate.plist",
    faceSpeed=8/32,
    frameName="face_",
    animateList={
        [1]=4,
        [2]=3,
        [3]={1,2,3,3,4,4},
        [4]=2,
        [5]={ 1,3,1,3,1,2,1,2,1},
        [6]={1,2,3,2,1,2,3,2,4},
        [7]=2,
        [8]={1,2,1,1,2,3},
        [9]={1,2,1,2,1},
        [10]=2,
        [11]={1,2,3,2,3,2},
        [12]={1,2,1,2,3,4},
        [13]=7,
        [14]={1,2,1,2,1,2,3,4,3},
        [15]={1,2,1,3},
    },
}

faceUI.faceData={
    faceSize={width=75,height=75},
    hNum=4,--一行多少个表情
    faceNum=15,
    scaleNum=1.2,
}

local isTest=false



faceUI.txt={

    [1] =  "快点啊，我等的到花儿都谢了",
    [2] = "鼻孔都这么大啦，还那么装羞，快点出来啦",
    [3] ="大家好，想找我签名的请先排队",
    [4] ="流氓不可怕，就怕流氓有文化",
    [5] ="牌差要什么紧，偶靠地是牌技",
    [6] ="我说你是炮兵学院毕业地",
    [7] ="再牛的肖邦也弹不出老子的悲伤呐",
    [8] = "拖时间是没用的，快出牌吧",
    [9] ="他再接电话，请稍候",
    [10] ="不要吵了，有什么好吵的，专心玩游戏",
    [11] ="不要走，决战到天亮",
}

faceUI.voice={
    [1] = {[1] = voiceResPath .."Man_cc_7.mp3",[2] = voiceResPath .."Woman_cc_7.mp3"},
    [2] = {[1] = voiceResPath .."Man_cc_1.mp3",[2] = voiceResPath .."Woman_cc_1.mp3"},
    [3] = {[1] = voiceResPath .."Man_cc_2.mp3",[2] = voiceResPath .."Woman_cc_2.mp3"},
    [4] = {[1] = voiceResPath .."Man_cc_3.mp3",[2] = voiceResPath .."Woman_cc_3.mp3"},
    [5] = {[1] = voiceResPath .."Man_cc_4.mp3",[2] = voiceResPath .."Woman_cc_4.mp3"},
    [6] = {[1] = voiceResPath .."Man_cc_5.mp3",[2] = voiceResPath .."Woman_cc_5.mp3"},
    [7] = {[1] = voiceResPath .."Man_cc_6.mp3",[2] = voiceResPath .."Woman_cc_6.mp3"},
    [8] = {[1] = voiceResPath .."Man_cc_0.mp3",[2] = voiceResPath .."Woman_cc_0.mp3"},
    [9] = {[1] = voiceResPath .."Man_cc_8.mp3",[2] = voiceResPath .."Woman_cc_8.mp3"},
    [10] = {[1] = voiceResPath .."Man_cc_9.mp3",[2] = voiceResPath .."Woman_cc_9.mp3"},
    [11] = {[1] = voiceResPath .."Man_cc_10.mp3",[2] = voiceResPath .."Woman_cc_10.mp3"},
}

local faceResPath  = "hall/res/roomCommonUI/image/"
faceUI.face={
    [51] = {path = faceResPath .."crazy.png", key = "crazy", size = 8},
    [52] = {path = faceResPath .."fennu.png", key = "fennu", size = 4},
    [53] = {path = faceResPath .."han.png", key = "han", size = 6},
    [54] = {path = faceResPath .."happy.png", key = "happy", size = 4},
    [55] = {path = faceResPath .."huaixiao.png", key = "huaixiao", size = 4},
    [56] = {path = faceResPath .."jiong.png", key = "jiong", size = 6},
    [57] = {path = faceResPath .."lihai.png", key = "lihai", size = 16},
    [58] = {path = faceResPath .."se.png", key = "se", size = 6},
    [59] = {path = faceResPath .."shaoxiang.png", key = "shaoxiang", size = 6},
    [60] = {path = faceResPath .."shihua.png", key = "shihua", size = 4},
    [61] = {path = faceResPath .."sleep.png", key = "sleep", size = 6},
    [62] = {path = faceResPath .."smile.png", key = "smile", size = 4},
    [63] = {path = faceResPath .."touxiang.png", key = "touxiang", size = 6},
    [64] = {path = faceResPath .."yun.png", key = "yun", size = 6},
    [65] = {path = faceResPath .."ziya.png", key = "ziya", size = 6},
}


function faceUI:changeChatMessage(txt,voice)

    self.txt = txt
    self.voice = voice
    self.txt_panle:removeAllChildren()

    local lay_bg = self.rootNodes:getChildByName("lay_bg")
    local itemClone = lay_bg:getChildByName("single_message")
    local txts = itemClone:getChildByName("chat_txt")
    itemClone:setVisible(false)

    for key, text in ipairs(self.txt) do
        local item = itemClone:clone()
        -- GameUtils.setNodeNameBindObj(item)
        item:setVisible(true)
        local itemTxt=item:getChildByName("chat_txt")
        itemTxt:setString(text)
        itemTxt:setTextColor(cc.c3b(255, 255, 255))
        self.txt_panle:pushBackCustomItem(item)  --列表容器增加元素
        item.id=key
    end

    self.txt_panle:onEvent(handler(self,self.ClickIntemTxt))

end

function faceUI:ctor()



    if device.platform == "ios" then
        if isiOSVerify then
            self.rootNodes=cc.CSLoader:createNode("hall/FaceUI/faceUI.csb")
        else
            self.rootNodes=cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/FaceUI/faceUI.csb")
        end
    else
        self.rootNodes=cc.CSLoader:createNode("hall/FaceUI/faceUI.csb")
    end

    self.screenWidth = 1280
    self.screenHeight = 720

    if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then

        self.screenWidth = 960
        self.screenHeight = 540

    elseif cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 1280 then

        self.screenWidth = 1280
        self.screenHeight = 720

    end

    if  currentGameLevel and currentGameLevel ~= USER_INFO["GroupLevel"] then
        local oldaceUI = SCENENOW["scene"]:getChildByName("faceUI")
        dump("释放上个faceUI")
        if  oldaceUI then
            oldaceUI:removeFromParent()
            oldaceUI = nil
        end
    end

    currentGameLevel = USER_INFO["GroupLevel"]

    self:addChild(self.rootNodes)
    self.rootNodes:hide()

    local lay_bg = self.rootNodes:getChildByName("lay_bg")

    self.face_panle= lay_bg:getChildByName("emojis")
    self.message_input = lay_bg:getChildByName("message_input")
    self.txt_panle = lay_bg:getChildByName("messages")

    local btn_chat = lay_bg:getChildByName("btn_chat")
    local btn_face = lay_bg:getChildByName("btn_face")
    local btn_sendmessage = lay_bg:getChildByName("btn_sendmessage")

    ------------------------------------------根据游戏开启文字聊天功能-------------------
    local Image_1 = lay_bg:getChildByName("Image_1")
    local Image_2 = lay_bg:getChildByName("Image_2")

    -- if currentGameLevel  == 111 or currentGameLevel  == 205 then
    Image_1:setPositionY(320)
    Image_1:setContentSize(Image_1:getContentSize().width,671)
    Image_2:setVisible(true)
    self.message_input:setVisible(true)
    btn_sendmessage:setVisible(true)
    -- else
    --     Image_1:setPositionY(372) 
    --     Image_1:setContentSize(Image_1:getContentSize().width,572)
    --     Image_2:setVisible(false)
    --     self.message_input:setVisible(false)
    --     btn_sendmessage:setVisible(false)
    -- end

    if currentGameLevel == 318 then
        --推锅牌九不要
         self.message_input:setVisible(false)
    end
    -------------------------------------------点击空白处隐藏表情框体-----------------------------
    local function onTouchBegan(touch, event)
        self.rootNodes:hide()
    end

    local listener2 = cc.EventListenerTouchOneByOne:create()
    listener2:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )

    local touchlayer = cc.Layer:create()
    self:addChild(touchlayer,-1)
    touchlayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener2:clone(),touchlayer)
    ---------------------------------------------------------------------------------------------------

    --切换到表情界面
    btn_face:addTouchEventListener(function (sender,event)

        if event==TOUCH_EVENT_ENDED then
            btn_chat:setBrightStyle(1)
            btn_face:setBrightStyle(1)
            self.txt_panle:hide()
            self.face_panle:show()
        end
    end)

    --切换到聊天界面
    btn_chat:addTouchEventListener(function (sender,event)

        if event==TOUCH_EVENT_ENDED then
            btn_chat:setBrightStyle(0)
            btn_face:setBrightStyle(0)
            self.txt_panle:show()
            self.face_panle:hide()
        end
    end)

    --发送聊天内容
    btn_sendmessage:addTouchEventListener(function (sender,event)

        if event==TOUCH_EVENT_ENDED then
            self:sendTextMessage()
            self.rootNodes:hide()
        end
    end)


    -------------------------------------------------添加emoji表情----------------------------------------
    self.face_panle:hide()
    display.addSpriteFrames(self.animatePlist.plist,string.split(self.animatePlist.plist, ".")[1]..".png")

    local face_nodes=self.face_panle:getInnerContainer()

    self:setBagNode({
        tnum=self.faceData.faceNum,
        hNum=self.faceData.hNum,
        size=self.faceData.faceSize,
        emojis=face_nodes,
        scaleNum=self.faceData.scaleNum,
        idaddNum=50,--id的增加量
    })

    local index=0
    for k,v1 in pairs(face_nodes:getChildren()) do
        index=index+1
        local animateList=self.animatePlist.animateList
        local v=animateList[index]
        local frameName=self.animatePlist.frameName..index.."_"
        local frames={}
        local animateSpeed=self.animatePlist.animateSpeed
        if type(v)=="table" then --自定义整虚列
            for key, var in pairs(v) do
                local name=frameName..var..".png"
                local spriteFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
                frames[#frames+1]=spriteFrame
            end
        else
            frames = display.newFrames(frameName.."%d.png", 1, v)
        end
        local animation = display.newAnimation(frames, animateSpeed)
        transition.playAnimationForever(v1.sp,animation)
    end


    self.show_face_node=cc.Node:create();
    self:addChild(self.show_face_node,2)

    -------------------------------------------常用语聊天-----------------------------
    self.txt_panle = lay_bg:getChildByName("messages")


    if isShowNewsoundeffect then
        local voiceNew = FaceUIPath .."audio/sound_effect/"
        local  txt={
            [1] = "唉呀妈呀，不好意思，我又赢了",
            [2] = "不好意思啊各位，我接个电话",
            [3] ="来啊，互相伤害啊",
            [4] ="老铁嘎哈呢，抓紧啊，都等我撸串呢",
            [5] ="厉害了我的哥",
            [6] ="能不能奔小康就看这三张",
            [7] ="你到底跟不跟啊",
            [8] = "你这牌抓的，没毛病",
            [9] ="你这牌抓的有瑕疵啊",
            [10] ="一路小屁走向胜利",
        }
        local voice=
        {
            [1] = {[1] = voiceNew .."Man_cc_1.mp3",[2] = voiceNew .."Woman_cc_1.mp3"},
            [2] = {[1] = voiceNew .."Man_cc_2.mp3",[2] = voiceNew .."Woman_cc_2.mp3"},
            [3] = {[1] = voiceNew .."Man_cc_3.mp3",[2] = voiceNew .."Woman_cc_3.mp3"},
            [4] = {[1] = voiceNew .."Man_cc_4.mp3",[2] = voiceNew .."Woman_cc_4.mp3"},
            [5] = {[1] = voiceNew .."Man_cc_5.mp3",[2] = voiceNew .."Woman_cc_5.mp3"},
            [6] = {[1] = voiceNew .."Man_cc_6.mp3",[2] = voiceNew .."Woman_cc_6.mp3"},
            [7] = {[1] = voiceNew .."Man_cc_7.mp3",[2] = voiceNew .."Woman_cc_7.mp3"},
            [8] = {[1] = voiceNew .."Man_cc_8.mp3",[2] = voiceNew .."Woman_cc_8.mp3"},
            [9] = {[1] = voiceNew .."Man_cc_9.mp3",[2] = voiceNew .."Woman_cc_9.mp3"},
            [10] = {[1] = voiceNew .."Man_cc_10.mp3",[2] = voiceNew .."Woman_cc_10.mp3"},
        }
        self:changeChatMessage(txt,voice)
    else

        self:changeChatMessage(self.txt,self.voice)

    end

    local chat_box_left = self.rootNodes:getChildByName("chat_box_left")
    chat_box_left:setVisible(false)
    local chat_box_right = self.rootNodes:getChildByName("chat_box_right")
    chat_box_right:setVisible(false)

end

function faceUI:ClickIntemTxt(event)
    if event.name=="ON_SELECTED_ITEM_END" then

        local list_v=event.target
        local _idex_=list_v:getCurSelectedIndex();
        local id=list_v:getItem(_idex_).id

        if sendHandle then
            sendHandle:CLI_MSG_FACE(id)
        end

        self.rootNodes:hide()
    end
end

function faceUI:setHandle(handle)
    sendHandle = handle
end

--设置
-- posType 1：左上 2：右上 3：左下 4：右下
function faceUI:showTxtPanle(pos, posType)

    if posType then
        if posType == 1 then
            pos.x=pos.x - 470
            pos.y=pos.y + 20
        elseif posType == 2 then
            pos.x=pos.x - 235
            pos.y=pos.y + 20
        elseif posType == 3 then
            pos.x=pos.x + 20
            pos.y=pos.y + 20
        elseif posType == 4 then
            pos.x=pos.x + 20
            pos.y=pos.y - 155
        elseif posType == 5 then
            pos.x=pos.x + 20
            pos.y=pos.y - 310
        elseif posType == 6 then
            pos.x=pos.x - 235
            pos.y=pos.y - 310
        elseif posType == 7 then
            pos.x=pos.x - 470
            pos.y=pos.y - 310
        elseif posType == 8 then
            pos.x=pos.x - 470
            pos.y=pos.y - 155
        end
    end

    self.rootNodes:show()

    if self.screenWidth == 960 then
        self.rootNodes:setScale(0.6)
        pos.x = pos.x+65
        pos.y = 90
    elseif self.screenWidth == 1280 then
        -- self.rootNodes:setScale(0.8)  
        pos.y = 50
        pos.x = 680
    end

    self.rootNodes:setPosition(pos);
end

function faceUI:getFaceAniByIdx(idx)
    local info = self.face[idx]
    local filePath = "hall/res/roomCommonUI/image/emoji.plist"
    local ani = require("hall.util.CocosUtil"):playAnimation(filePath, info.key, info.size, 1, 4/25, 0)
    return ani
end

function faceUI:showGetFace(uid,faceid,sex,node_head,isLeft)

    if faceid>=65537 then --机器人发过来

        local faceNum=self.faceData.faceNum
        local txt=self.txt

        local val =faceid-65537
        local val2=0

        if val>7 then --表情

            if val<faceNum then
                val2=50+val
            else
                val2=50+val%faceNum+1
            end

        else --文本
            if val<#txt then
                val2=val

            else
                val2=val%#txt+1
            end
        end

        self:showGetFace(uid,val2,sex)

        return
    end

    if node_head and node_head.sp_face  then
        node_head.sp_face:removeSelf();
        node_head.sp_face=nil
    end

    local pos = node_head:convertToWorldSpaceAR(cc.p(0, 0))

    local sp
    if faceid>=50 then --玩家发过来的表情
        --todo
        -- pos.x=pos.x --+50
        -- pos.y=pos.y +20
        sp=cc.Sprite:create();

        -- local animateList=self.animatePlist.animateList
        -- local v=animateList[faceid-50]

        -- local frameName=self.animatePlist.frameName..(faceid-50).."_"
        -- local frames={}
        -- local animateSpeed=self.animatePlist.animateSpeed

        -- if type(v)=="table" then --自定义整虚列
        --     for key, var in pairs(v) do
        --         local name=frameName..var..".png"
        --         local spriteFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
        --         frames[#frames+1]=spriteFrame
        --     end
        -- else
        --     frames = display.newFrames(frameName.."%d.png", 1, v);
        -- end

        -- local animation = display.newAnimation(frames, animateSpeed)
        -- transition.playAnimationForever(sp,animation)


        node_head.sp_face=sp

        self.show_face_node:addChild(sp)
        sp:setPosition(pos)

        -- local ac=cc.Sequence:create(
        --     cc.DelayTime:create(2),
        --     cc.CallFunc:create(function(args,arg2)  --args = self   arg2 = {node_head}
        --             args:removeSelf();
        --             arg2[1].sp_face=nil
        --     end,{node_head})
        --     )
        local ani = self:getFaceAniByIdx(faceid)
        sp:runAction(ani)

    else --玩家发过来的语音

        local  _sex = sex or 1

        if  _sex == 0 then
            _sex = 1
        end

        self:showGetText(uid,self.txt[faceid],_sex,node_head,isLeft)

        local  strSound = self.voice[faceid][_sex]

        if strSound then
            require("hall.GameCommon"):play2d(strSound)
        end

    end


end

function faceUI:getStringWidth(str,fontSize)

    -- local characterNum = fontSize or 20
    local lenInByte = #str
    local characterNum = 0

    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end

        local char = string.sub(str, i, i+byteCount-1)
        i = i + byteCount -1

        if byteCount == 1 then
            characterNum = characterNum + 0.7
        else
            characterNum = characterNum + 1
        end
    end

    return characterNum
end

function faceUI:sendTextMessage()

    local   textMessage = self.message_input:getString()

    if not textMessage or textMessage == "" then
        return
    end

    textMessage = require("hall.GameCommon"):formatNick(textMessage,60)

    self.message_input:setString("")

    local   textMessage_table = {}
    textMessage_table["uid"] = USER_INFO["uid"]
    textMessage_table["textMessage"] = textMessage
    textMessage_table["msgType"] = "text"

    local currentGameLevel = USER_INFO["GroupLevel"] or 40
    local msg = json.encode(textMessage_table)
    local pack = bm.server:createPacketBuilder(0x801)      --CLIENT_CMD_SEND_MSG_TO_SERVER 协议 
                   :setParameter("level",currentGameLevel)
                   :setParameter("msg", msg)
                   :build()

    bm.server:send(pack)
end

function faceUI:showGetText(uid,textMessage,sex,node_head,isLeft)


    if  textMessage == nil or textMessage == "" then
        return
    end

    if node_head and node_head.sp_face  then
        node_head.sp_face:removeSelf();
        node_head.sp_face=nil
    end

    local pos = node_head:convertToWorldSpace(cc.p(0, 0))

    local sp

    if  pos.x > self.screenWidth/2 then
        isLeft = true
    else
        isLeft = false
    end

    if  pos.y > self.screenHeight/2 then
        pos.y = pos.y + 10
    else
        pos.y = pos.y + 50
    end

    --local widthFix = 45
    local widthFix = 102
	local heightFix = 65

    local txt_lb

    --设置气泡图片大小
    if not isLeft then
        sp=self.rootNodes:getChildByName("chat_box_left"):clone()
        local txt_lb_1 = sp:getChildByName("send_txt")
        txt_lb_1:setString("")

        local txt_lb = display.newTTFLabel({
            text = content,
            font = "hall/res/font/FZY3JW.TTF",
            size = 24,
            color = cc.c3b(166, 59, 6),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            dimensions = cc.size(txtWidth, 0)
        })

        txt_lb:setAnchorPoint(cc.p(0,0.5))
        txt_lb:setString(textMessage)
        sp:addChild(txt_lb)


        local StringWidth = self:getStringWidth(textMessage)

        local oneLineCharacterNum = StringWidth
        if  oneLineCharacterNum > 37 then
            oneLineCharacterNum = 37
        end

        local chat_box_width = oneLineCharacterNum * 11  + widthFix
        local chat_box_height = math.ceil(StringWidth/37)*10 + heightFix
        sp:setContentSize(chat_box_width,chat_box_height)
        txt_lb:setPositionY(chat_box_height/2)
        txt_lb:setPositionX(40)
        pos.x=pos.x+40
    else
        sp=self.rootNodes:getChildByName("chat_box_right"):clone()
        txt_lb_1 = sp:getChildByName("send_txt")
        txt_lb_1:setString("")

        local txt_lb = display.newTTFLabel({
            text = content,
            font = "hall/res/font/FZY3JW.TTF",
            size = 26,
            color = cc.c3b(166, 59, 6),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            dimensions = cc.size(txtWidth, 0)
        })

        txt_lb:setAnchorPoint(cc.p(0,0.5))
        txt_lb:setString(textMessage)
        sp:addChild(txt_lb)

        local StringWidth = self:getStringWidth(textMessage)

        local oneLineCharacterNum = StringWidth
        if  oneLineCharacterNum > 37 then
            oneLineCharacterNum = 37
        end

        local chat_box_width = oneLineCharacterNum * 11  + widthFix
        local chat_box_height = math.ceil(StringWidth/37)*10 + heightFix

        dump(chat_box_width,"chat_box_width")

        sp:setContentSize(chat_box_width,chat_box_height)
        -- txt_lb:setPositionX(chat_box_width - 40)
        txt_lb:setPositionX(40)
        txt_lb:setPositionY(chat_box_height/2)
        pos.x=pos.x- 40
    end

    sp:setVisible(true)
    node_head.sp_face=sp

    self.show_face_node:addChild(sp)
    sp:setPosition(pos)

    local ac=cc.Sequence:create(
            cc.DelayTime:create(2),
            cc.CallFunc:create(function(args,arg2)  --args = self   arg2 = {node_head}
                args:removeSelf();
                arg2[1].sp_face=nil
            end,{node_head})
    )


    sp:runAction(ac)

end
-----------------------------------添加表情方法----------------------------------

function faceUI:onClickFace(event)
    local target = event.target
    local id =target.id
    if sendHandle then
        sendHandle:CLI_MSG_FACE(id)
    end
    self.rootNodes:hide();
end

function faceUI:setBagNode(data)

    local temp=0
    local x=0
    local y=0

    local faceNum=data.tnum
    local hNum=data.hNum
    local faceSize=data.size
    local face_node=data.emojis
    local id_addNum=data.idaddNum or 0
    local scaleNum=data.scaleNum or 1

    local size=face_node:getContentSize();

    faceSize.width= 75*scaleNum
    faceSize.height= 75*scaleNum

    y=size.height-faceSize.height/2+faceSize.height

    for var=0, faceNum-1 do
        local x=(var%hNum)*(faceSize.width+8)+faceSize.width/2;

        if x==faceSize.width/2 then
            y=y-(faceSize.height+8)
            temp=0
        end
        temp=temp+1
        local image=ccui.ImageView:create(FaceUIPath .. "expression_box.png");

        local sp=cc.Sprite:create()
        image:addChild(sp)
        image.sp=sp
        image.id=var+1+id_addNum
        sp:setPosition(35,35)
        image:setPosition(x,y)
        face_node:addChild(image)
        image:setScale(scaleNum)
        image.noScale=true
        image:onClick(handler(self, self.onClickFace))
    end
end
-----------------------------------------------------------------------------------

return faceUI
