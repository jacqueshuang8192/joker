-- CardConfig
-- Author: zzy
-- Date: 2019-01-08 10:21:15

local CardConfig = class("CardConfig")

function CardConfig:ctor()
end

function CardConfig:getCardInfoByid(id)
	if id == nil then return nil end
	if CardInfos[id] then	
		return CardInfos[id]
	end
	return nil
end

local Card_Path_Litter = "ldfpaofa/res/CardLitter/"
local Card_Path_Big = "ldfpaofa/res/CardBig/"
local Card_Path_Music = "ldfpaofa/res/sound/"

CardInfos={}
CardInfos[0x00]={CardId=0x00,Mousic=Card_Path_Music.."1.mp3",CardIndex=-1, Name="无",Color=0,Value=0, CardIconA=Card_Path_Litter.."Card_miniature_000",CardIconB=Card_Path_Litter.."Card_miniature_000",CardIconC=Card_Path_Big.."Card_Big_000"}
CardInfos[0x01]={CardId=0x01,Mousic=Card_Path_Music.."1.mp3",CardIndex=0, Name="一",Color=0,Value=1, CardIconA=Card_Path_Litter.."Card_miniature_Small_1",CardIconB=Card_Path_Litter.."Card_half_Small_1",CardIconC=Card_Path_Big.."Card_Small_1"}
CardInfos[0x02]={CardId=0x02,Mousic=Card_Path_Music.."2.mp3",CardIndex=1, Name="二",Color=0,Value=2, CardIconA=Card_Path_Litter.."Card_miniature_Small_2",CardIconB=Card_Path_Litter.."Card_half_Small_2",CardIconC=Card_Path_Big.."Card_Small_2"}
CardInfos[0x03]={CardId=0x03,Mousic=Card_Path_Music.."3.mp3",CardIndex=2, Name="三",Color=0,Value=3, CardIconA=Card_Path_Litter.."Card_miniature_Small_3",CardIconB=Card_Path_Litter.."Card_half_Small_3",CardIconC=Card_Path_Big.."Card_Small_3"}
CardInfos[0x04]={CardId=0x04,Mousic=Card_Path_Music.."4.mp3",CardIndex=3, Name="四",Color=0,Value=4, CardIconA=Card_Path_Litter.."Card_miniature_Small_4",CardIconB=Card_Path_Litter.."Card_half_Small_4",CardIconC=Card_Path_Big.."Card_Small_4"}
CardInfos[0x05]={CardId=0x05,Mousic=Card_Path_Music.."5.mp3",CardIndex=4, Name="五",Color=0,Value=5, CardIconA=Card_Path_Litter.."Card_miniature_Small_5",CardIconB=Card_Path_Litter.."Card_half_Small_5",CardIconC=Card_Path_Big.."Card_Small_5"}
CardInfos[0x06]={CardId=0x06,Mousic=Card_Path_Music.."6.mp3",CardIndex=5, Name="六",Color=0,Value=6, CardIconA=Card_Path_Litter.."Card_miniature_Small_6",CardIconB=Card_Path_Litter.."Card_half_Small_6",CardIconC=Card_Path_Big.."Card_Small_6"}
CardInfos[0x07]={CardId=0x07,Mousic=Card_Path_Music.."7.mp3",CardIndex=6, Name="七",Color=0,Value=7, CardIconA=Card_Path_Litter.."Card_miniature_Small_7",CardIconB=Card_Path_Litter.."Card_half_Small_7",CardIconC=Card_Path_Big.."Card_Small_7"}
CardInfos[0x08]={CardId=0x08,Mousic=Card_Path_Music.."8.mp3",CardIndex=7, Name="八",Color=0,Value=8, CardIconA=Card_Path_Litter.."Card_miniature_Small_8",CardIconB=Card_Path_Litter.."Card_half_Small_8",CardIconC=Card_Path_Big.."Card_Small_8"}
CardInfos[0x09]={CardId=0x09,Mousic=Card_Path_Music.."9.mp3",CardIndex=8, Name="九",Color=0,Value=9, CardIconA=Card_Path_Litter.."Card_miniature_Small_9",CardIconB=Card_Path_Litter.."Card_half_Small_9",CardIconC=Card_Path_Big.."Card_Small_9"}
CardInfos[0x0A]={CardId=0x0A,Mousic=Card_Path_Music.."10.mp3",CardIndex=9, Name="十",Color=0,Value=10,CardIconA=Card_Path_Litter.."Card_miniature_Small_10",CardIconB=Card_Path_Litter.."Card_half_Small_10",CardIconC=Card_Path_Big.."Card_Small_10"}

CardInfos[0x11]={CardId=0x11,Mousic=Card_Path_Music.."101.mp3",CardIndex=10,Name="壹",Color=1,Value=1, CardIconA=Card_Path_Litter.."Card_miniature_Big_1",CardIconB=Card_Path_Litter.."Card_half_Big_1",CardIconC=Card_Path_Big.."Card_Big_1"}
CardInfos[0x12]={CardId=0x12,Mousic=Card_Path_Music.."102.mp3",CardIndex=11,Name="贰",Color=1,Value=2, CardIconA=Card_Path_Litter.."Card_miniature_Big_2",CardIconB=Card_Path_Litter.."Card_half_Big_2",CardIconC=Card_Path_Big.."Card_Big_2"}
CardInfos[0x13]={CardId=0x13,Mousic=Card_Path_Music.."103.mp3",CardIndex=12,Name="叁",Color=1,Value=3, CardIconA=Card_Path_Litter.."Card_miniature_Big_3",CardIconB=Card_Path_Litter.."Card_half_Big_3",CardIconC=Card_Path_Big.."Card_Big_3"}
CardInfos[0x14]={CardId=0x14,Mousic=Card_Path_Music.."104.mp3",CardIndex=13,Name="肆",Color=1,Value=4, CardIconA=Card_Path_Litter.."Card_miniature_Big_4",CardIconB=Card_Path_Litter.."Card_half_Big_4",CardIconC=Card_Path_Big.."Card_Big_4"}
CardInfos[0x15]={CardId=0x15,Mousic=Card_Path_Music.."105.mp3",CardIndex=14,Name="伍",Color=1,Value=5, CardIconA=Card_Path_Litter.."Card_miniature_Big_5",CardIconB=Card_Path_Litter.."Card_half_Big_5",CardIconC=Card_Path_Big.."Card_Big_5"}
CardInfos[0x16]={CardId=0x16,Mousic=Card_Path_Music.."106.mp3",CardIndex=15,Name="陆",Color=1,Value=6, CardIconA=Card_Path_Litter.."Card_miniature_Big_6",CardIconB=Card_Path_Litter.."Card_half_Big_6",CardIconC=Card_Path_Big.."Card_Big_6"}
CardInfos[0x17]={CardId=0x17,Mousic=Card_Path_Music.."107.mp3",CardIndex=16,Name="柒",Color=1,Value=7, CardIconA=Card_Path_Litter.."Card_miniature_Big_7",CardIconB=Card_Path_Litter.."Card_half_Big_7",CardIconC=Card_Path_Big.."Card_Big_7"}
CardInfos[0x18]={CardId=0x18,Mousic=Card_Path_Music.."108.mp3",CardIndex=17,Name="捌",Color=1,Value=8, CardIconA=Card_Path_Litter.."Card_miniature_Big_8",CardIconB=Card_Path_Litter.."Card_half_Big_8",CardIconC=Card_Path_Big.."Card_Big_8"}
CardInfos[0x19]={CardId=0x19,Mousic=Card_Path_Music.."109.mp3",CardIndex=18,Name="玖",Color=1,Value=9, CardIconA=Card_Path_Litter.."Card_miniature_Big_9",CardIconB=Card_Path_Litter.."Card_half_Big_9",CardIconC=Card_Path_Big.."Card_Big_9"}
CardInfos[0x1A]={CardId=0x1A,Mousic=Card_Path_Music.."110.mp3",CardIndex=19,Name="拾",Color=1,Value=10,CardIconA=Card_Path_Litter.."Card_miniature_Big_10",CardIconB=Card_Path_Litter.."Card_half_Big_10",CardIconC=Card_Path_Big.."Card_Big_10"}

return CardConfig