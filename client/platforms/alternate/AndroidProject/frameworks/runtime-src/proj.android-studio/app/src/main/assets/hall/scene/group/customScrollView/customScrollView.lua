--author: 张鸿鹏   
--date: 2018/5/24

-----根据传入的列表数据，根据数据规模自动选择tableView和listView，数据规模在10个以上就会开启分帧加载
local customScrollView = class("customScrollView")

function customScrollView:ctor(typ)

	self.viewType = typ or "tableView"     -- "tableView"和"listView"

	dump(self.viewType,"viewType")

	if self.viewType == "tableView" then
		local tableView = require("hall.scene.group.customScrollView.tableView")
		self.scrollView = tableView.new()
	else
		local listView = require("hall.scene.group.customScrollView.listView")
		self.scrollView = listView.new()
	end
end

-- --设置容器类型
-- function customScrollView:setType(typ)
	
-- end

--设置数据源
function customScrollView:init(datas, typ)
	return self.scrollView:init(datas)
end

function customScrollView:reload(datas)
	self.scrollView:reload(datas)
end

function customScrollView:insert(itemData, index, ifSelected)   --ifSelected:插入后是否跳转到该ITEM
	self.scrollView:insert(itemData, index, ifSelected)
end

function customScrollView:updateItemContent(itemData, conditionFunc) 
	self.scrollView:updateItemContent(itemData, conditionFunc) 
end

function customScrollView:remove(index, ifToTop)
	self.scrollView:remove(index)
end


--设置单条数据的处理方法
function customScrollView:setItemHandler(func)
	self.scrollView:setItemHandler(func)
end

function customScrollView:setMetaItem(metaItem, oneLineItemCount)
	self.scrollView:setMetaItem(metaItem, oneLineItemCount)
end

function customScrollView:setScrollView(scrollView)
	self.scrollView:setScrollView(scrollView)
end

function customScrollView:finalize()

	self = nil
	-- self.scrollView:finalize()
	-- self.scrollView = nil	
	-- self.viewType = nil
	collectgarbage("collect")  --手动清除垃圾

end

return customScrollView
