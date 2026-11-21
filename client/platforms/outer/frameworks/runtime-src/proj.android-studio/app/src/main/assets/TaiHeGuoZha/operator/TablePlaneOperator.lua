local TablePlaneOperator = class("TablePlaneOperator")
local Card  = require("TaiHeGuoZha.Card")

function TablePlaneOperator:init()
	self.audience_brand = cardScene:getChildByName("audience_brand")
end

function TablePlaneOperator:clearGameDatas()

    local layout_effect = cardScene:getChildByName("layout_effect")
    local sp = layout_effect:getChildByName("shunanim")
    if sp then
        sp:stopAllActions()
        layout_effect:removeChildByName("shunanim")
    end

    self:hideDeicideCard()
end

function TablePlaneOperator:showTaiFeiTips(value)
	
    --添加扣除台费显示
    local taiFeiTxt
    if  value < 0 then
        taiFeiTxt = "扣除台费"..math.abs(value)
    end

    local lbVersion = cc.Label:createWithTTF(taiFeiTxt, TpackageName .."/res/font/fzcs.ttf",50)
          lbVersion:addTo(cardScene,9999)
          lbVersion:setScale(1280/1920)
          lbVersion:setColor(cc.c3b(0xBF, 0xBF, 0xBF))
          lbVersion:setPosition(cc.p(cardScene:getContentSize().width/2,100))
          lbVersion:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() lbVersion:removeFromParent() end)))
end

function TablePlaneOperator:hideDeicideCard()
  local decidecard = cardScene:getChildByName("decidecard")
    if decidecard then
      decidecard:removeSelf()
    end
end

function TablePlaneOperator:showDeicideCard(value, callBack)

  callBack = callBack or function() end

  if not value or value <= 0 then return end
  self:hideDeicideCard()
  local decidecard = Card:getCard(Card:getCardValueAndColor(value))
  decidecard:addTo(cardScene)
  decidecard:setName("decidecard")
  decidecard:setPosition(cc.p(640, 360))

  local ac = cc.Sequence:create(
      cc.DelayTime:create(0.5),
      cc.Spawn:create(
          cc.ScaleTo:create(0.4, 0.5),
          cc.MoveTo:create(0.4, cc.p(80,585))
        ),
      cc.CallFunc:create(callBack)
    )
  decidecard:runAction(ac)
end

return TablePlaneOperator