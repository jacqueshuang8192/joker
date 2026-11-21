local listView = class("listView")

--[[三种方案  （1）当数据规模较小时，用listView一次性分帧加载 （2）数据规模中等时，将item都分帧加入到layout中，
layout再添加到listView上 (3)当数据规模较大时，先加载一定量的item，然后对这些item反复使用
]]  

--[[一次性列表（如排行榜），内容动态更新列表（如游戏桌子），可复用无更新列表（一个界面内多种数据，但可以用复用
同一个列表显示）]]

function listView:ctor()  
end

--设置item样式
function listView:setMetaItem(metaItem)  
	self.metaItem = metaItem

    local padding = 5
    self.itemHeight = self.metaItem:getContentSize().height* self.metaItem:getScale() + padding
end

--设置单条数据的设置方法
function listView:setItemHandler(func) 
	self.itemHandler = func
end

--设置数据源
function listView:setDataSource(datas)  
    self.dataSoure = datas
    self.dataSourceSize = #datas
end

function listView:setScrollView(_scrollView) 
   self.scrollView = _scrollView
end

function listView:reload(datas) 

	local metaItem = self.metaItem

	local items = self.scrollView:getChildren()
	local preDataSourceSize = self.dataSourceSize

	self:setDataSource(datas)
	local curDataSourceSize =  self.dataSourceSize
	local curDatas = self.dataSoure
	-- local stepValue = preDataSourceSize > curDataSourceSize and 1 or -1

	local loadedItemNums = 0

	local loadItemCo

	-- dump(#datas,"数据规模")
	loadItemCo = coroutine.create(function(datas)

		for index = 1,curDataSourceSize do

			-- dump("reloadListViewData")
			loadedItemNums = loadedItemNums + 1
			local item = items[index]  
			local itemData = curDatas[index]
			if item == nil then 
				item = metaItem:clone()
				self.scrollView:pushBackCustomItem(item)	
			end

			self.itemHandler(item, index, itemData)
			local yield = coroutine.yield(datas)

		end

	end)

	coroutine.resume(loadItemCo,datas)

	local createItemTimer = nil

	local function update()
	    if loadedItemNums < curDataSourceSize then
	    	-- dump(loadedItemNums, "loadedItemNums")
	        coroutine.resume(loadItemCo)
	    else
			-- dump(#self.scrollView:getChildren(),"容器规模")
	        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(createItemTimer)
	    end
	end

	local function startTimer()
	     if createNodeTimer == nil then
	         createItemTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
	     end
	end

	startTimer()

	for index = curDataSourceSize + 1,preDataSourceSize do
		local item = items[index] 
		if item then
			item:removeFromParent()
		end
	end

	-- for index, itemData in ipairs(curDatas) do
	-- 	local item = items[index] 
	-- 	self.itemHandler(item, index, itemData)
	-- end

end

function listView:init(datas) 

	self:setDataSource(datas)
	local metaItem = self.metaItem
	local dataSourceSize = self.dataSourceSize
	-- local itemHeight = self.itemHeight
	-- local innerContainerSize = self.table_list:getInnerContainerSize()

	-- for i = 1,20 do
	local loadedItemNums = 0

	local loadItemCo = coroutine.create(function(datas)

		for i,data in ipairs(datas) do

			-- local loadItemCo = coroutine.create(function(datas)

			loadedItemNums = loadedItemNums + 1
			local item = metaItem:clone()
			self.itemHandler(item, index, itemData)
			self.scrollView:pushBackCustomItem(item)
			local yield = coroutine.yield(datas)

			-- end)
		end

		-- self.table_list:setInnerContainerSize(cc.size(innerContainerSize.width,itemHeight*loadedItemNums))
	end)
	
	coroutine.resume(loadItemCo,datas)

	local function update()
	    if loadedItemNums <= dataSourceSize then
	        coroutine.resume(loadItemCo)
	    else
	        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(createItemTimer)
	    end
	end

	local createItemTimer = nil

	local function startTimer()
	     if createNodeTimer == nil then
	         createItemTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
	     end
	end

	startTimer()
end  

function listView:updateItemContent(itemData, conditionFunc)

	if tolua.isnull(self.scrollView) == true then
		return
	end 

	local items = self.scrollView:getChildren()
	for _,item in ipairs(items) do
		if conditionFunc(item) == true then
			local index = item:getIndex()
	        self.itemHandler(item, index, itemData)
		end
	end

end

function listView:insert(itemData, index) 
	if index == nil then
	 	table.insert(self.dataSoure, itemData) 
	else 
		table.insert(self.dataSoure, index, itemData)
	end

	local item = metaItem:clone()
	self.scrollView:pushBackCustomItem(item)
	self.itemHandler(item, index, itemData)
end

function listView:remove(index) 
	table.remove(self.dataSoure,index)
	self.crollView:removeChildByTag(index)  --/self.crollView:getChildByTag(index):setVisible(false)
end

function listView:clear() 
	self.dataSoure= {}
	self.scrollView:removeAllChildren()
end

function listView:finalize() 
	-- package.loaded["hall.scene.group.customScrollView.listView"] = nil
end

return listView

-- local function ()