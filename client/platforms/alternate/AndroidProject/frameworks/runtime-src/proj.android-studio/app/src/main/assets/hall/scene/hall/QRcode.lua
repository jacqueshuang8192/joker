local QRcode = {}
-- local qr = require("hall.util.luaqrcode.qrencode")

function QRcode:showScene()

	-- qr = qrcode.QRCode(
	--     version=2,
	--     error_correction=qrcode.constants.ERROR_CORRECT_L,
	--     box_size=10,
	--     border=1
	-- )
	-- qr.add_data("http://jb51.net/")
	-- qr.make(fit=True)
	-- img = qr.make_image()
	-- img.save("dhqme_qrcode.png")

	local bindAgentUrl = moChuanMLink
	.."?invitationCode=agent&activityId="
	..USER_INFO["uid"]
	.."&level=xxx&DO_NOT_TRACKING=1"

	local generated_qrCode_result = "hall/scene/res/" .. resFolder .."/image/hall/download_qrcode.png"
	-- dump(qr:encode(bindAgentUrl),"bindAgentUrl")
	self._scene = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/hall/qrCode.csb"):addTo(SCENENOW["scene"]):setName("QRcode")
	local logo_img = self._scene:getChildByName("logo_img")
	local qrCode_img = self._scene:getChildByName("qrCode_img")
	local share_bt = self._scene:getChildByName("share_bt")
	local close_bt = self._scene:getChildByName("close_bt")

	logo_img:ignoreContentAdaptWithSize(true)
	qrCode_img:loadTexture(generated_qrCode_result)

	share_bt:addTouchEventListener(function(sender,event)

        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
        	sender:setScale(0.72)
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
        	sender:setScale(0.66)
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then
        	sender:setScale(0.66)

            require("hall.common.ShareLayer"):captureScreenAndShare(
            	"qrcode.png","wx","下载二维码","","screen")

        end

	end)

	close_bt:addTouchEventListener(function(sender,event)

        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
        	sender:setScale(1.1)
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
        	sender:setScale(1)
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then
        	sender:setScale(1)
        	self:removeScene()
        end

	end)

end

function QRcode:removeScene()

	if tolua.isnull(self._scene) == false then
		self._scene:removeFromParent()
	end

end

return QRcode



