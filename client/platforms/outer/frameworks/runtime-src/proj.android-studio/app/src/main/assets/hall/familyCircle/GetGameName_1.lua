local GetGameName = class("GetGameName")
function GetGameName:getName(_level)
    _level = tonumber(_level)
    local strName = ""
    if _level == 342 then
        strName = "常德字牌"
    elseif _level == 0 then
        strName = "全部"
    elseif _level == 101 then
        strName = "百人龙虎"
    elseif _level == 102 then
        strName = "百人神兽"
    elseif _level == 501 then
        strName = "汉寿跑胡子"
	elseif _level == 353 or _level == 618 then
		strName = "邵阳剥皮"
    elseif _level == 345 then
        strName = "娄底放炮罚"
    elseif _level == 398 then
        strName = "新化跑胡子"
    elseif _level == 325 then
        strName = "跑得快"
    elseif _level == 340 then
        strName = "比鸡"
    elseif _level == 302 or 395 == _level then
        strName = "明牌抢庄"
    elseif _level == 303 then
        strName = "自由上庄"
    elseif _level == 304 then
        strName = "轮庄斗牛"
    elseif _level == 305 then
        strName = "定庄斗牛"
    elseif _level == 306 then
        strName = "疯狂斗牛"
    elseif _level == 307 then
        strName = "牛牛上庄"
    elseif _level == 317 then ----诈金花
        strName = "欢乐金花"
    elseif _level == 347 then
        strName = "超级三加一"
    elseif _level == 308 then
        strName = "红中麻将"
    elseif _level == 348 then
        strName = "闷胡血流"
    elseif _level == 324 then
        strName = "斗地主"
    elseif _level == 309 then
        strName = "广东麻将"
    elseif _level == 329 then
        strName = "柳州麻将"
    elseif _level == 120 then
        strName = "三公"
    elseif _level == 320 then
        strName = "长沙麻将"
    elseif _level == 357 then
        strName = "转转麻将"
    elseif _level == 358 then
        strName = "沅江麻将"
    elseif _level == 359 then
        strName = "八一字牌"
    elseif _level == 360 then
        strName = "快乐三公"
    elseif _level == 361 then
        strName = "蒲城打炸"
    elseif _level == 362 then
        strName = "金州水鱼"
    elseif _level == 364 then
        strName = "济宁麻将"
    elseif _level == 363 then
        strName = "十三水"
    elseif _level == 315 then --经典牌九
        strName = "牌九"
    elseif _level == 318 then
        strName = "推锅牌九"
    elseif _level == 365 then
        strName = "新十三水"
    elseif _level == 366 then
        strName = "梅州红中宝"
    elseif _level == 368 then
        strName = "无限斗公牛"
	elseif _level == 369 then
        strName = "新余510K"
	elseif _level == 372 then
        strName = "郴州字牌"
    elseif _level == 370 then
        strName = "十堰卡五星"
    elseif _level == 371 then
        strName = "新余麻将"
    elseif _level == 373 then
        strName = "湖南碗碗"
    elseif _level == 374 then
        strName = "翻三皮"
	elseif _level == 375 then
        strName = "碰碰胡"
	elseif _level == 379 then
        strName = "沅江鬼胡子"
    elseif _level == 380 then
        strName = "孝感卡五星"
    elseif _level == 382 then
        strName = "随州卡五星"
    elseif _level == 376 then
        strName = "版纳卡二条"
    elseif _level == 385 then
        strName = "泰顺麻将"
    elseif _level == 386 then
        strName = "贺州麻将"
    elseif _level == 381 then
        strName = "泰和过炸"
    elseif _level == 387 then
        strName = "红中麻将"
    elseif _level == 384 then
        strName = "96扑克"
    elseif _level == 383 then
        strName = "沅江千分"
    elseif _level == 388 then
        strName = "荆楚花牌"
    elseif _level == 390 then
        strName = "襄阳卡五星"
    elseif _level == 389 or _level == 619 then
        strName = "戳虾子"
    elseif _level == 392 then
        strName = "溆浦跑胡子"
    elseif _level == 393 then
        strName = "新长沙麻将"
    elseif _level == 391 then
        strName = "溆浦老牌"
    elseif _level == 396 then
        strName = "河池字牌"
    elseif _level ==394 then
        strName = "河池麻将"
    elseif _level ==399 then
        strName = "转转麻将"
    elseif _level ==400 then
        strName = "资溪麻将"
    elseif _level == 403 then
        strName = "玉林麻将"
    elseif _level == 397 then
        strName = "新化打炸"
    else
        strName = ""
    end
    return strName
end
function GetGameName:getPath(level)
    local game = {
        [302]	= "niuniu",
        [308]	= "hz_majiang",
        [315]	= "paijiu",
        [317]	= "zhajinhua_jb",
        [318]	= "paijiu_tg",
        [325]	= "pdk",
        [329]	= "gxlz_majiang_new",
        [340]	= "biji",
        [342]	= "cdpaohuzi",
        [345]	= "ldfpaofa",
        [353]	= "shaoyangbopi",
        [358]	= "yj_majiang",
        [359]	= "byzp",
        [360]	= "sangong",
        [365]	= "shisanzhang_new",
        [368]	= "Dougongniu",
        [369]	= "xinyu510k",
        [371]	= "xinyu_majiang",
        [372]	= "chenzhouzp",
        [374]	= "FanSanPi",
        [375]	= "pengpengzp",
        [379]	= "yuanjiangguihz",
        [381]	= "TaiHeGuoZha",
        [383]	= "yuanjiangqianfen",
        [384]	= "96game",
        [388]	= "jchuapai",
        [389]	= "cxz_majiang",
        [391]	= "xplp_majiang",
        [392]	= "xupuphz",
        [393]	= "cs_majiang_new",
        [397]	= "xinhuadazha",
        [101]	= "longhu100",
        [102]	= "shenshou100",
        [501]	= "hanshouphz",
    }
    return game[level]
end
-- require("hall.familyCircle.GetGameName"):getName(_level)
function GetGameName:existPath(level)
    local path = (self:getPath(level) or "")..'/gameScene.lua'
    if device.platform == "ios" and (not isiOSVerify )then
        path = cc.FileUtils:getInstance():getWritablePath() .. path
    end
    if not io.exists(path) then
        return true
    end
    return false
end
function GetGameName:isBidTable(level)
    if level == 373
    or level == 101
    or level == 102
    or level == 103
    then
        return true
    end
    return false
end
return GetGameName