--
-- Author: zzy
-- Date: 2019-01-07 10:56:42
-- lua头文件，所用到的lua放这里require

require("byzp.logic.CMD_BYZP")
cc.FileUtils:getInstance():addSearchPath("byzp/logic")
cc.FileUtils:getInstance():addSearchPath("byzp/models")
cc.FileUtils:getInstance():addSearchPath("byzp/handle")

cc.FileUtils:getInstance():addSearchPath("byzp/res")
cc.FileUtils:getInstance():addSearchPath("byzp/res/font")
cc.FileUtils:getInstance():addSearchPath("byzp/res/other")
cc.FileUtils:getInstance():addSearchPath("byzp/res/plist")
cc.FileUtils:getInstance():addSearchPath("byzp/res/sound")
cc.FileUtils:getInstance():addSearchPath("byzp/res/setting")

cc.FileUtils:getInstance():addSearchPath("byzp/scenes")
cc.FileUtils:getInstance():addSearchPath("byzp/view")