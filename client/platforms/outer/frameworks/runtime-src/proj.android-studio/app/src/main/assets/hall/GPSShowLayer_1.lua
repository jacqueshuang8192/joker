--[[
* author:   zwm
* date:     2019-03-21
* describe: 设置界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local GPSShowLayer = class("GPSShowLayer", NewViewBaseLayer)

function GPSShowLayer:showSetting(data)
    if SCENENOW["scene"]:getChildByTag(1000) ~= nil then
        SCENENOW["scene"]:removeChildByTag(1000)
    end
    self.new(data):addTo(SCENENOW["scene"], 1000)
end

function GPSShowLayer:ctor()
    local csbPath = "hall/res/gps/GPSShowLayer.csb"
    GPSShowLayer.super.ctor(self, csbPath)
    self:enableMask(true)
    self:setClickMaskClose()
    self:initUI()
    self:setVisible(false)
    -- self.root:onClick(handler(self,self.onClick))
end

function GPSShowLayer:initUI()
    for i=1,4 do
        self.gpsBg:getChildByName("Panel_Head"..i):setVisible(false)
        for j=i+1,4 do
            self.gpsBg:getChildByName("Text_km_"..i.."_"..j):setVisible(false)
        end
    end
end

function GPSShowLayer:setInfo(userInfos)
    dump(userInfos,"userInfos")
    if not userInfos or #userInfos == 0 then
        self:removeSelf()
        return
    end

    -- userInfos[1].latitude =  "28.101102"
    -- userInfos[2].latitude =  "28.101121"

    -- userInfos[1].longitude =  "113.018365"
    -- userInfos[2].longitude =  "113.018464"

    for i=1,#userInfos do
        local panelHead = self.gpsBg:getChildByName("Panel_Head"..i)
        panelHead:getChildByName("Text_name"):setString( userInfos[i].nick or userInfos[i].nickName or " ")
        panelHead:getChildByName("Text_ip"):setString(userInfos[i].ip or "")
        panelHead:setVisible(true)

        for j=i+1,#userInfos do
            local km = calculateDistance(userInfos[i].latitude,userInfos[j].latitude,userInfos[i].longitude,userInfos[j].longitude)
            km = string.format("%.1f",km)
            km = tonumber(km)

            local disStr = km.."米"
            if km >1000 then
                km = km/1000
                
                km = string.format("%.2f",km)
                km = tonumber(km)

                disStr = km.."千米"
            end
            self.gpsBg:getChildByName("Text_km_"..i.."_"..j):setString(disStr)
            self.gpsBg:getChildByName("Text_km_"..i.."_"..j):setVisible(true)
        end
    end
    self:setVisible(true)
end

function GPSShowLayer:onClick(sender, event)
    self:removeSelf()
end

return GPSShowLayer