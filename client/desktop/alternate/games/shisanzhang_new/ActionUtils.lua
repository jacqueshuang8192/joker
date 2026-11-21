local ActionUtils = class("ActionUtils")
local CardUtils = require(TpackageName..".CardUtils")

local fs = require("hall.tool.utils.fs")

--特殊牌动画
function ActionUtils:setTeShuAnim(type)

    local tal = {
        [CardUtils.TYPE.SanTongHua]= "001_santonghua", --"三同花"
        [CardUtils.TYPE.SanShunZi] = "002_sanshunzi", --"三顺子"
        [CardUtils.TYPE.LiuDuiBan] = "003_liuduiban", --"六对半"
        [CardUtils.TYPE.WuDuiSanTiao] = "004_wuduichongsan", --"五对三条"
        [CardUtils.TYPE.SiTaoSanTiao] = "009_sitaochongsan", --"四套三条"
        [CardUtils.TYPE.QuanXiao] = "007_quanxiao", --"全小"
        [CardUtils.TYPE.QuanDa] = "006_quandan", --"全大"
        [CardUtils.TYPE.CouYiSe] = "005_couyise", --"凑一色"
        [CardUtils.TYPE.SanFenTianZia] = "011_sanfentianxia", --"三分天下"
        [CardUtils.TYPE.SanTongHuaShun] = "012_santonghuashun", --"三同花顺"
        [CardUtils.TYPE.ShiErHuangZhu] = "008_shierhuangzu", --"十二皇族"
        [CardUtils.TYPE.YiTiaoLong] = "013_yitiaolong", --"一条龙"
        [CardUtils.TYPE.QingLong] = "014_zhizunqinlong", --"至尊清龙"
        [CardUtils.TYPE.BaXianGuoHai] = "015_baxianguohai", --"八仙过海"
        [CardUtils.TYPE.QiXinLianZhu] = "016_qixinlianzhu", --"七星连珠"
        [CardUtils.TYPE.SanHuangWuDi] = "018_sanhuangwudi", --"三皇五帝"
        [CardUtils.TYPE.LiuLiuDaShun] = "017_liuliudashun", --"六六大顺"
        -- [CardUtils.TYPE.ShuangGuaiChongSan] = "双怪冲三", --"双怪冲三"
        -- [CardUtils.TYPE.TieZhiPai] = "铁子牌", --"铁子牌"
        -- [CardUtils.TYPE.TongHuaShunBaoDao] = "同花顺报道", --"同花顺报道"
        -- [CardUtils.TYPE.WuTongZuan] = "五同钻", --"五同钻"
    }
  
	local cardType = tal[type]
	if not cardType then
		return
	end
    dump(os.time(),"动画开始-----------")
    local effectManage = ccs.ArmatureDataManager:getInstance() 
    local name = "shisanshui"
    local path = TpackageName .. "/res/layout/roomScene/newAction/shisanshui/"..name
    effectManage:addArmatureFileInfo(path.."0.png", path.."0.plist", path..".ExportJson")
    effectManage:addArmatureFileInfo(path.."1.png", path.."1.plist", path..".ExportJson")
    local Armature = ccs.Armature:create(name)
    local size = SHISANZHANG_GAME_SCENE:getContentSize()
    Armature:addTo(SHISANZHANG_GAME_SCENE):pos(size.width / 2, size.height / 2)
    local anim = Armature:getAnimation()
    anim:playWithNames({cardType}, 0, false);
    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            Armature:removeSelf()
			dump(os.time(),"动画结束-----------")
        end
    end
	anim:setMovementEventCallFunc(handler1)
	
end

--被打枪
function ActionUtils:setToShot(plane,flag)
    if flag and SHISANZHANG_GAME_SCENE and plane then
        local toShotVw = plane.toShotVw
        local name = "dankong"
        local path = TpackageName .. "/res/layout/roomScene/newAction/dankong"
        local effectManage = ccs.ArmatureDataManager:getInstance() 
        effectManage:addArmatureFileInfo(path.."0.png", path.."0.plist", path..".ExportJson");
        local toShot = ccs.Armature:create(name)
        local function handler1(Armature, MovementEventType, handlerName)
            if MovementEventType == ccs.MovementEventType.complete then
                Armature:removeSelf()
            end
        end
        toShot:getAnimation():setMovementEventCallFunc(handler1)
        toShot:getAnimation():playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环

        local posx = 50 + math.random(-20,20)
        local posy = 50 + math.random(-20,20)
        local Angles = math.random(360)
        toShot:setAnchorPoint(0.5,0.5)
        toShot:setPosition( cc.p(posy, posx) )
        toShot:setRotation(Angles)
        toShot:setVisible(flag)
        toShot:addTo(toShotVw)
        dump(cc.p(posy, posx),Angles)
        print("----------------------------")
    end
end

--打枪
function ActionUtils:creatorShotAnimNode(plane)
    if  SHISANZHANG_GAME_SCENE and plane then
        local shot_img = plane.shot_img
        local name = "qiang"
        local path = TpackageName .. "/res/layout/roomScene/newAction/qiang"
        display.addSpriteFrames(path.."0.png", path.."0.plist")
        local effectManage = ccs.ArmatureDataManager:getInstance() 
        effectManage:addArmatureFileInfo(path.."0.png", path.."0.plist", path..".ExportJson");
        local shot = ccs.Armature:create(name)
        shot:addTo(shot_img)
        shot_img.shot = shot
        shot:setName("shot")
    end
end

--开始动画--全垒打
function ActionUtils:setAnim(key, callBack)
	local names = {
		["kaishibipai"] = "kaishibipai",--开始比牌
		["quanleida"] = "quanleida",--全垒打
    }
    dump(key, "-----------动画")
    local size = SHISANZHANG_GAME_SCENE:getContentSize()
	local name = names[key]
    local path = TpackageName .. "/res/layout/roomScene/newAction/"..name
	local effectManage = ccs.ArmatureDataManager:getInstance() 
	local idx = 0
    effectManage:addArmatureFileInfo(path.."0.png", path.."0.plist", path..".ExportJson");
    local Armature = ccs.Armature:create(name)
    Armature:addTo(SHISANZHANG_GAME_SCENE):pos(size.width / 2, size.height / 2)
    Armature:setName("kaishibipai")
    local anim = Armature:getAnimation()
    anim:playWithIndex(idx, -1, 0) --第一个参数是动画表index 第二个是时间间隔 第三个是是否循环

    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
			Armature:removeSelf()
			if callBack then
				callBack()
			end
        end
    end
	anim:setMovementEventCallFunc(handler1)
end

return ActionUtils