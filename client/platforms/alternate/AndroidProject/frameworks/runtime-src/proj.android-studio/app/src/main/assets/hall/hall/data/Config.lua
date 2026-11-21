
local Config = class("Config")

function Config:ctor()

	dump("初始化配置", "-----Config:ctor-----")

	--是否打开红屏
	isShowErrorScene = true

	--是否显示网络信息
    isShowNetLog = false

    --是否显示调试信息
    showDumpData = true

    --是否显示协议解析信息（要显示解析信息必须先开启dump）
    isDumpProtocol_str = true

    --是否为iOS审核包
	isiOSVerify = false

	--语音视频通过什么发送，1为呀呀，2为游戏服
	mediaSendMode = 2

	--http请求失败，重新请求间隔时间
	request_delayTime = 3

	--是否微信登录
	is_wechat_login = true 

	self:initPath()

	tbErrorCode = {
		[0] = "成功创建新连接",
		[1] = "重连成功",
		[2] = "成功踢其他玩家",
		[3] = "玩家密匙错误",
		[4] = "数据库连接错误",
		[5] = "无此房间",
		[6] = "玩家登录房间错误",
		[7] = "无房间分配",
		[8] = "没有空桌子",
		[9] = "玩家余额不足",
		[10] = "未知错误",
		[11] = "牌型错误",
		[12] = "验证码错误",
		[13] = "比赛房间不存在",
		[14] = "相同IP",
	}

end

function Config:initPath()

	local memory_footprint_before = collectgarbage("count")

	dump("初始化文件访问路径", "-----Config:initPath-----")

	------------------------------------------------------------------------------------------------------------------------------

	--网络相关

	--大厅http请求文件路径
	Request_filePath = "hall.network.Request"

	--大厅Socket相关文件路径
	ServerBase_filePath = "hall.ScoketGame"
	HallServer_filePath = "hall.HallServer"
	HallHandle_filePath = "hall.HallHandle"
	HallProtocol_filePath = "hall.HALL_PROTOCOL"

	------------------------------------------------------------------------------------------------------------------------------

	--数据相关

	--应用设置操作
	GameSetting_filePath = "hall.GameSetting"

	--用户数据处理
	GameData_filePath = "hall.GameData"

	--游戏通用操作
	GameCommon_filePath = "hall.GameCommon"

	--游戏列表
	GameList_filePath = "hall.GameList"

	------------------------------------------------------------------------------------------------------------------------------

	--控件相关

	--加载圈
	NetworkLoadingView_filePath = "hall.NetworkLoadingView.NetworkLoadingView"

	--提示弹框(普通)
	CommonTips_filePath = "hall.tips.CommonTips"
	--CommonTipsCsb_filePath = "hall/scene/res/" .. resFolder .."/tips/LayerTips_new.csb"
	CommonTipsCsb_filePath = "hall/res/csb/tips/LayerTips_new.csb"

	--解散弹框
	DisbandTipsCsb_filePath = "hall/res/csb/tips/LayerTips_disband.csb"
	NewDisbandTipsCsb_filePath = "hall/res/csb/tips/LayerTips_disband_new.csb"
	DisbandPlayerCsb_filePath = "hall/res/csb/tips/Disband_Player_Layer.csb"
	NewDisbandTips_wait_filePath = "hall/scene/res/singlered/image/tip/ic_wait.png"
	NewDisbandTips_agree_filePath = "hall/scene/res/singlered/image/tip/ic_agree.png"

	ScrollTipsCsb_filePath = "hall/scene/res/" .. resFolder .."/tips/LayerTips_scroll.csb"

	------------------------------------------------------------------------------------------------------------------------------

	--资源相关

	--图片
	--默认头像
	DefaultHead_filePath = "hall/scene/res/common/image/defaulthead.png"

	--头像外边框
	HeadFrame_filePath = "hall/scene/res/common/image/head_box1.png"

	--头像圆遮罩
	Stnecil_filePath = "hall/scene/res/common/image/head_lord_man.png"

	--iOS分享小图标
	iOSShareIcon_filePath = "hall/scene/res/common/image/shareicon.png"

	--大厅游戏按钮存放目录
	MoreGameButtons_filePath = "hall/scene/res/" .. resFolder .."/image/hall/moregame/"

	--大厅游戏新版本标记
	newVersionMark_filePath = "hall/scene/res/common/image/main_new.png"

	--大厅游戏更新转圈
	updateGameProgress_filePath = "hall/scene/res/common/image/clock_progress.png"

	--音乐
	--大厅背景音乐
	HallBgm_filePath = "hall/scene/res/common/music/hall_1.mp3"

	--大厅按钮点击音乐
	HallButtonClickVoice_filePath = "hall/scene/res/common/music/Audio_Button_Click.mp3"
	------------------------------------------------------------------------------------------------------------------------------

	--工具类相关

	--数值处理
	NumberUtil_filePath = "hall.util.NumberUtil"

	------------------------------------------------------------------------------------------------------------------------------

	--界面相关

	--登录
	LoginScene_filePath = "hall.login.LoginLayer"
	LoginSceneCsb_filePath = "hall/res/login/loginLayer.csb"
	LoginButtonPic_n_filePath = "hall/res/images/login/fast_bt_n.png"
	LoginButtonPic_c_filePath = "hall/res/images/login/fast_bt_c.png"

	--大厅
	GameScene_filePath = "hall.gameScene"
	GameSceneCsb_filePath = "hall/scene/res/" .. resFolder .."/hall/hallScene.csb"
	GameSceneIOSVerifyCsb_filePath = "hall/scene/res/" .. resFolder .."/hall/hallScene.csb"

	--代理控制
	AgentHandlePic_filePath = "hall/scene/res/" .. resFolder .."/image/hall/main_agenthandle.png"

	--聊天室
	ChatRoomCsb_filePath = "hall/chatRoomView/chatroom_layer.csb"

	--排行榜
	RankCellCsb_filePath = "hall/scene/res/" .. resFolder .."/rank/rankLayer.csb"

	--创建组局
	CreateGroup_filePath = "hall.scene.group.create.group_create"
	CreateGroupCsb_filePath = "hall/scene/res/" .. resFolder .."/group/create/group_create.csb"
	CreateGroupButtonPic_filePath = "hall/scene/res/" .. resFolder .."/image/hall/hall_creat_tb.png"
	BackGroupButtonPic_filePath = "hall/scene/res/" .. resFolder .."/image/hall/hall_creat_tb.png"

	--VIP房间
	CreateVipGroup_filePath = "hall.scene.group.create.group_create_vip"

	CreateGroup_TabType_Csb_filePath = "hall/scene/res/" .. resFolder .."/group/create/tab_typeLayer.csb"
	CreateGroup_TabGame_Csb_filePath = "hall/scene/res/" .. resFolder .."/group/create/tab_gameLayer.csb"
	CreateGroup_TabItem_Csb_filePath = "hall/scene/res/" .. resFolder .."/group/create/tab_item_ly.csb"
	CreateGroup_CircleSelect_Csb_filePath = "hall/scene/res/" .. resFolder .."/group/create/circle_select.csb"
	CreateGroup_TickSelect_Csb_filePath = "hall/scene/res/" .. resFolder .."/group/create/tick_select.csb"
	CreateGroup_ConfigShowName_Csb_filePath = "hall/scene/res/" .. resFolder .."/group/create/configShowNameLayer.csb"

	CreateGroup_TabTypeBg_n_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/gamebt_s.png"
	CreateGroup_TabTypeBg_s_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/gamebt_n.png"
	CreateGroup_TabGameBg_n_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/gamebt_n.png"
	CreateGroup_TabGameBg_s_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/gamebt_s.png"
	CreateGroup_Tab_blank_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/btn_tab_blank.png"

	CreateGroup_TabItemBg_n_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/btn_small_tab01.png"
	CreateGroup_TabItemBg_s_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/btn_small_tab02.png"
	CreateGroup_TabItemBg_blank_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/btn_small_blank.png"

	CreateGroup_ConfigRadio_n_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/creat_point_n.png"
	CreateGroup_ConfigRadio_s_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/creat_point_p.png"

	CreateGroup_ConfigCheck_n_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/point01_n.png"
	CreateGroup_ConfigCheck_s_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/point01_p.png"

	CreateGroup_Spade_5_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/lord_card_club_5.png"
	CreateGroup_Spade_10_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/lord_card_club_10.png"
	CreateGroup_Spade_1_filePath = "hall/scene/res/" .. resFolder .."/image/group/create/lord_card_club_1.png"

	--加入组局
	JoinGroup_filePath = "hall.scene.group.join.group_join"
	JoinGroupCsb_filePath = "hall/scene/res/" .. resFolder .."/group/join/enter_room.csb"

	--组局管理
	GroupSetting_filePath = "hall.scene.group.GroupSetting"

	--分享
	Share_filePath = "hall.common.ShareLayer"
	ShareCsb_filePath = "hall/scene/res/" .. resFolder .."/share/shareLayer.csb"

	--玩家介绍
	Introduce_filePath = "hall.scene.introduce.introduceScene"
	IntroduceCsb_filePath = "hall/scene/res/" .. resFolder .."/introduce/InstructionLayer.csb"

	--战绩
	Result_filePath = "hall.scene.result.HistoryLayer"
	ResultCsb_filePath = "hall/scene/res/" .. resFolder .."/result/HistoryLayer.csb"

	--三公战绩
	SG_Result_filePath ="hall.scene.result.SG_History"
	SG_ResultCsb_filePath = "hall/scene/res/" .. resFolder .."/result/sg_historyLayer.csb"
	--设置
	Setting_filePath = "hall.scene.setting.settingScene"
	SettingCsb_filePath = "hall/scene/res/" .. resFolder .."/setting/LayerSetting.csb"

	--单盘结算
	RoundResultCsb_filePath = "hall/scene/res/" .. resFolder .."/gameResult/roundEndingLayer.csb"

	--总结算
	TotalResultCsb_filePath = "hall/scene/res/" .. resFolder .. "/gameResult/GameResult.csb"
	ResultItemCsb_filePath = "hall/scene/res/" .. resFolder .. "/gameResult/GameResult_Item.csb"

	--商场
    Marketce_filePath = "hall.scene.market.MarketScene"
    MarketCsb_filePath = "hall/scene/res/"..resFolder.."/market/MarketScene.csb"
    exppainCsb_filePath = "hall/scene/res/"..resFolder.."/market/exppainLayer.csb"
    IntergralCsb_filepath = "hall/scene/res/"..resFolder.."/market/intergralLayer.csb"
    boardCsb_filePath = "hall/scene/res/"..resFolder.."/market/boardLayer.csb"
    changerCsb_filePath = "hall/scene/res/"..resFolder.."/market/exchangerLayer.csb"

    --转盘
	Zhuanpan_filePath = "hall.zhuanpan.ZhuanPanLayer"
	ZhuanpanCsb_filePath = "hall/scene/res/" .. resFolder .."/zhuanpan/ZhuanPanLayer.csb"

	--好友推荐
	Recommend_filePath = "hall.scene.recommend.Recommend"
	RecommendCsb_filePath = "hall/scene/res/" .. resFolder .."/recommend/Recommend.csb"

	--赠送房卡
	Gift_filePath = "hall.scene.gift.Gift"
	GiftCsb_filePath = "hall/scene/res/" .. resFolder .."/gift/Gift.csb"

	--校验
	Verify_filePath = "hall.scene.verify.verifyScene"
	VerifyLayer_filePath = "hall/res/csb/verify/verifyLayer.csb"

	--消息
	Message_filePath = "hall.scene.message.Message"
	messageSceneCsb_filePath = "hall/scene/res/" .. resFolder .."/message/messageScene.csb"

	--保险箱
	SafeBoxScene_filePath = "hall.scene.safebox.safeboxScene"
	SafeBoxSceneCsb_filePath = "hall/scene/res/" .. resFolder .."/safebox/safeboxScene.csb"
	SafeBox_Select_S_filePath = "hall/scene/res/" .. resFolder .."/image/safebox/select_s.png"
	SafeBox_Select_N_filePath = "hall/scene/res/" .. resFolder .."/image/safebox/select_n.png"

	--实名认证
	NameCheckScene_filePath = "hall.scene.namecheck.namecheckScene"
	NameCheckSceneCsb_filePath = "hall/scene/res/" .. resFolder .."/namecheck/namecheckScene.csb"

	--任务
	MissionScene_filePath = "hall.scene.mission.missionScene"
	MissionSceneCsb_filePath = "hall/scene/res/" .. resFolder .."/mission/missionScene.csb"
	Mission_TabType_Csb_filePath = "hall/scene/res/" .. resFolder .."/mission/tab_typeLayer.csb"
	Mission_TabTypeBg_n_filePath = "hall/scene/res/" .. resFolder .."/image/mission/gamebt_n.png"
	Mission_TabTypeBg_s_filePath = "hall/scene/res/" .. resFolder .."/image/mission/gamebt_s.png"
	Mission_Blank_filePath = "hall/scene/res/" .. resFolder .."/image/mission/btn_tab_blank.png"

	--提取金币
	GetMoneyScene_filePath = "hall.scene.getmoney.getmoneyScene"
	GetMoneySceneCsb_filePath = "hall/scene/res/" .. resFolder .."/getmoney/getmoney.csb"
	GetMoney_Select_S_filePath = "hall/scene/res/" .. resFolder .."/image/getmoney/getmoney_s.png"
	GetMoney_Select_N_filePath = "hall/scene/res/" .. resFolder .."/image/getmoney/getmoney_n.png"
	Bill_Select_S_filePath = "hall/scene/res/" .. resFolder .."/image/getmoney/bill_s.png"
	Bill_Select_N_filePath = "hall/scene/res/" .. resFolder .."/image/getmoney/bill_n.png"
	DateCellScene_filePath = "hall/scene/res/" .. resFolder .."/getmoney/datecellLayer.csb"
	DateCellBlank_filePath = "hall/scene/res/" .. resFolder .."/image/getmoney/datecellblank.png"
	BillCellScene_filePath = "hall/scene/res/" .. resFolder .."/getmoney/billcellLayer.csb"

	dump(collectgarbage("count") - memory_footprint_before,"定义全局变量后内存占用")

	--战绩
	GameResultScene_filePath = "hall.scene.gameresult.gameresultScene"
	GameResultScene_Long_Csb_filePath = "hall/scene/res/" .. resFolder .."/gameresult_new/gameresult_long_Scene.csb"
	GameResultScene_Long_Cell_Csb_filePath = "hall/scene/res/" .. resFolder .."/gameresult_new/longResultCellLayer.csb"
	GameResultScene_Long_Cell_Bg_W_filePath = "hall/scene/res/" .. resFolder .."/image/gameresult_new/bg_long_w.png"
	GameResultScene_Long_Detail_Cell_Csb_filePath = "hall/scene/res/" .. resFolder .."/gameresult_new/longdetailLayer.csb"
	SETTLEMENT_VIEW = "hall/res/settlement/settlement.csb" --总结算
	GameResultScene_Short_Csb_filePath = "hall/scene/res/" .. resFolder .."/gameresult_new/gameresult_short_Scene.csb"
	GameResultScene_Short_Cell_Csb_filePath = "hall/scene/res/" .. resFolder .."/gameresult_new/shortResultCellLayer.csb"


	--赠送
	GiveScene_filePath = "hall.scene.give.giveScene"
	GiveSceneCsb_filePath = "hall/scene/res/" .. resFolder .."/give/give_scene.csb"
	------------------------------------------------------------------------------------------------------------------------------
end

return Config
