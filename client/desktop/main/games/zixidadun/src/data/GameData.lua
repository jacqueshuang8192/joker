
local GameData  = class("GameData")
-- g_zxddGameData.upHight

Game_status_CHIBING=4
Game_status_BIDUN=5


function GameData:ctor()
    self.placeCardType_disperse = 1		--展开
    self.placeCardType_fold = 2
    self.placeCardType = self.placeCardType_disperse

    self.cardOriginY = 150  --手牌的初始高度 
    self.cardHigher = 100   --手牌高度差 
    self.cardInterval = 50  --手牌的间隙
    self.cardLineMax = 25   --一行最多多少张牌
    self.upHight = 30       --抬起高度
    self.LastType=0		--前面的出牌类型
    self.curOutCardUser = -1		--当前出牌用户
    self.LastMaxCard=0			--记录本轮出牌类型的最大牌值
    self.LastCardData={}			--出的牌的数组
    self.LastChangeCard={}				--来自变换的牌组
    self.LastUser=-1			--s本轮出牌最大用户
    self.laiziList={}
    self.IsOver=false
    self.IsOverData={}
    self.IsRoundEnd=false
    self.Select_510k=false
    self.TipIndex=1
    self.IsSortByScore=false
--    self.testData = true
end

function GameData:init()

end

function GameData:initSomeData()
	self.LastType=0		--前面的出牌类型
    self.LastMaxCard=0			--记录本轮出牌类型的最大牌值
    self.LastCardData={}			--出的牌的数组
    self.LastChangeCard={}
    self.IsSortByScore=false				--赖子变换的牌组
    --self.LastUser=-1			--s本轮出牌最大用户
end

function GameData:get()
    
end

return GameData