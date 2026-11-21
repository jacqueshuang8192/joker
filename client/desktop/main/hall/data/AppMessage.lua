
local AppMessage = class("AppMessage")

function AppMessage:ctor()

	dump("初始化应用信息", "-----AppMessage:ctor-----")

	---------------------------------------------------大厅相关代码代码版本号---------------------------------------------------
	code_hall_version = "1.0.10"
	code_3DMahjongCard_version = "1.0.2"

	---------------------------------------------------闲娱游戏---------------------------------------------------
	--应用名称
	appName = "闲娱游戏"

	--资源目录
	resFolder = "singlered"

	--走马灯默认显示
	braodComponentDefaulMessage = ""

	--大厅分享下的文字说明
	hallShareMessage = "简单好玩，欢迎来战"

	--下载页地址
	appDownLoadAddress = "https://ard9nd.mlinks.cc/AeTp"

	--魔窗链接
	moChuanMLink = "https://ard9nd.mlinks.cc/AeTp"

	--是否带比奇商城
	hasBqMarket = true

	--是否显示版号信息
	isShowBanHao = false

	--版号信息
	banHaoMessage = "" --"经营许可证-粤B2-20160369 | 软著-2017SR651972 | 粤网文-（2017）11358-2945号 | 审批文号 新广出审[2018]1141号 | ISBN 978-7-498-04537-9"

	--公司信息
	companyMessage = ""

	--是否包含广告位
	hasAdPlace = true

	--是否包含代理功能
	isAgentMode = false

	--是否包含购买功能
	isBuyCardMode = true

	--是否可以购买金币
	isCanBuyGold = true

	--是否不显示购买房卡
	isNotShowBuyCard = false

	--在购买房卡前是否检查是否绑定代理
	isCheckBindAgentBeforeBuyCard = false

	--是否显示地图logo
	isShowMapLogo = false

	--是有显示互动表情
	isShowAnimView = true

	--是否显示聊天室
	isShowChatRoom = false

	--是否显示赠送房卡
	isShowGiveCard = false

	--是否显示绑定代理
	isShowBindAgent = false

	--是否单一城市模式
	isSingleCityMode = false

	--是否单一游戏模式
	isSingleGame = false

	--是否在设置上显示应用名称
	isSettingShowAppName = true

	--是否去请求带控列表
	isCheckControl = true

	--是否带控版本
	isControl = true

	--显示获取电量
	isShowElectricity = true

	--是否开启代开功能
	isOpenDaiKai = true

	--是否显示 单局结算 false显示
	is_show_zjh_sing = true

	--是否包含VIP房
	isHasVipPalce = false

	--金币场桌子列表
	tableList = {}

	--金币场当前level
	curLevel = 1

	--是否包含分享朋友圈每日送卡
	isSharePyqGiftRoomCard = true

	--苹果使用原生播放音效
	isIosUseAppPlayEffect = true

	--是否包含猜拳
	hasMorra = true

	--大厅外挂图片路径
	WaiGuaPic_path = "hall/scene/res/common/image/ad/waigua1.png"

	--是否检查已经绑定代理
	isCheckBindAgent = false

	--是否带比奇商城
	hasBqMarket = true

	--是否显示代理管理后台按钮
	isShowAgentHandle = false

	--代理管理后台链接
	agentHandle_url = ""

	-- kefuMessage = "请关注微信号：nyqkf_1"
	quickEnterRoom = true

	agentKefu = true

    onlyHasRoomCardMode = false

    shieldRecharging = false

    CommonTipsCsb = true

	HAS_ALIPAY = true

	--弹出绑定
	tipsBind = false    --false 为一次     true为一直弹
	--显示全部桌子
	isShowAllTable = true

	-- isShowBaiRen = true  --显示百人场
	----大厅走马灯的默认显示
	braodComponentDefaulMessage_hall = ""
	isShowChageSceneBg = false--游戏内是否有设置换背景
	IS_TONGC_DUN = 0   --同城的盾  开启为1  不开启就是0
	isShowQuJian = true  --大厅限制 区间  讯游&完美湘西
	isShowDianWei = false   --大厅点位  广西诚信 
	FamilyTableSort = 1  --1玩法桌子在后面，  2玩法桌子在中间，  3未开始在前 玩法桌子在中间 开始在后，false默认玩法桌子在前
	-- 台费设置
	-- isShowStartCost = true
	--老版本的profit传过去的是一个没有*100的整数,现在前端主动乘以100,后端不处理那100,广西诚信使用
	-- PROFIT_MUL_100_2SERVER = true
	-- appmsg_showinscore = true --显示战绩入场积分
	PreviousLevel = 0
	isHideShowBons4Agent = true
	isSkipSendFace = true--true不发送动态表情 false或者不写默认可以发送
	-- isHideBiaoQing = true --true隐藏静态表情 false或者不写默认显示
	
	HasThreeBgm = 1   --是否有三种背景音乐 1有 0无
	hallFamilyPlayerNum = "99+"
end

return AppMessage






