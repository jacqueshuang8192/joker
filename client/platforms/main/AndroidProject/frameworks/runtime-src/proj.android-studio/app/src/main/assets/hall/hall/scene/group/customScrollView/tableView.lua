local tableView = class("tableView")

--  dataSource     --{}  数据
--  dataSourceSize = 0   数据规模
--  itemHeight = 0   控件高度
--  scrollView  --原始滚动控件
--  metaItem 	--用于复制的ITEM
--  itemHandler  --ITEM的处理方法

function tableView:ctor()  
end  

--设置tableViewCell样式
function tableView:setMetaItem(_metaItem, oneLineItemCount)  

	self.metaItem = _metaItem

	self.oneLineItemCount = oneLineItemCount or 1
    local widthPadding = 85
    local heightPadding = 30
    self.itemWidth  = self.metaItem:getContentSize().width* self.metaItem:getScale() + widthPadding
    self.itemHeight = self.metaItem:getContentSize().height* self.metaItem:getScale() + heightPadding

end

--设置单条数据的设置方法
function tableView:setItemHandler(func) 
	self.itemHandler = func
	-- dump(string.dump(func),"setItemHandler")
end

--设置数据源 
function tableView:setDataSource(datas)  
	-- dump(datas,"setDataSource")
    self.dataSource = datas
    self.dataSourceSize = #datas
   	self.lineCount = math.ceil(self.dataSourceSize/self.oneLineItemCount)
end

--设置要用tableView替代的对象
function tableView:setScrollView(_scrollView) 
   	self.scrollView = _scrollView
end

function tableView:reload(datas) 
	-- dump(datas,"tableView_reload")
    self:setDataSource(datas)
    if tolua.isnull(self.m_tableView) == false then
    	self.m_tableView:reloadData()
    end
end

function tableView:init(datas) 

	-- dump(self,"dataSourceSize")

	--界面滚动时候的回调
	local function _scrollViewDidScroll(view)  
	end  
	  
	--获取item大小，垂直排列，只需要高度值
	local function _cellSizeForTable(view, idx)   
	    return self.itemWidth, self.itemHeight
	end 
	  
	--获取数据源的条数
	local function _numberOfCellsInTableView(view)  
	    return self.lineCount
	end  
	  
	local function _tableCellAtIndex(view, idx) 

		-- dump(self.dataSource,"self.dataSource")
	    local index = idx + 1;  
	    local cell = view:dequeueCell() or cc.TableViewCell:new();  --复用item

	   	if self.oneLineItemCount == 1 then

	   		local i = 1
        	local tag = 124 - i%2

	    	local itemData = self.dataSource[i]

	    	if itemData then
			    local customItem = cell:getChildByTag(tag) or self.metaItem:clone():addTo(cell); 
		        customItem:setTag(tag);  
			    customItem:setPosition(cc.p( self.itemWidth/2 *(1-i%2) + 10, 0));  
			    customItem.order = i
	    		self.itemHandler(customItem, itemData)
	    	else
	    		local customItem = cell:getChildByTag(tag) 
	    		local removeResult = customItem and customItem:removeFromParent() 
	    	end

	   	elseif self.oneLineItemCount == 2 then

	        for i = index * 2 -1, index * 2 do

	        	local tag = 124 - i%2

		    	local itemData = self.dataSource[i]

		    	if itemData then
				    local customItem = cell:getChildByTag(tag) or self.metaItem:clone():addTo(cell); 
			        customItem:setTag(tag);  
				    customItem:setPosition(cc.p(60, self.itemHeight*(i%2) -30));  
				    customItem.order = i
		    		self.itemHandler(customItem, itemData)
		    	else
		    		local customItem = cell:getChildByTag(tag) 
		    		local removeResult = customItem and customItem:removeFromParent() 
		    	end
		    end

		end

	    return cell  
	end  

	self:setDataSource(datas)

	--tableView未创建的话
    if  tolua.isnull(self.m_tableView) == true then

        --scroll的尺寸  
        local sizeScroll = self.scrollView:getContentSize()  
        --scroll的位置坐标  
        local positionScroll = self.scrollView:getPosition() --cc.p(self.scrollView:getPositionX(), self.scrollView:getPositionY());  
        local panelMain = self.scrollView:getParent()
        local direction = self.scrollView:getDirection()

        --创建TableView  
        self.m_tableView = cc.TableView:create( cc.size( sizeScroll.width, sizeScroll.height) )  
        
        --------------------------界面设置 cc.SCROLLVIEW_DIRECTION_HORIZONTAL
        :addTo(panelMain)
        :setPosition(positionScroll)
        :setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)  --竖直从上往下排列   
        :setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) --设置滚动方向  
        -- self.m_tableView:setAnchorPoint(cc.p(0,1)) --tableView锚点始终为0，0
        -- self.m_tableView:setBounceable(false)
        --------------------------设置代理 
        self.m_tableView:setDelegate() 

        --------------------------注册事件
    	self.m_tableView:registerScriptHandler(_scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)           --滚动时的回掉函数  
		self.m_tableView:registerScriptHandler(_cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)             --列表项的尺寸  
    	self.m_tableView:registerScriptHandler(_tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)             --创建列表项  
    	self.m_tableView:registerScriptHandler(_numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW) --列表项的数量 
    	-------------------------初始化之后重载数据显示界面
    	self.m_tableView:reloadData();  
    end

    return self.m_tableView

end  

function tableView:updateItemContent(itemData, conditionFunc) 

	if tolua.isnull(self.m_tableView) == true then
		return
	end
	
	local container = self.m_tableView:getChildren()[1]

	if tolua.isnull(container) == true or self.dataSource == nil or next(self.dataSource) == nil then
		return
	end

	local cells = container:getChildren()
	for _,cell in ipairs(cells) do
		for i,item in ipairs(cell:getChildren()) do
			if conditionFunc(item) == true then

				-- local idx = cell:getIdx()
			 --    local index = idx + 1;  
			    -- dataSoure[index] = tableData 因为dataSource指向的数据已经被更新过数据，因此不再需要重复更新
		        -- local customItem = cell:getChildByTag(123);  
		        -- local itemData = self.dataSource[index]
		        -- dump(itemData, "tableCellAtIndex_itemData_2")
		        self.itemHandler(item, itemData)
				break
			end
		end
	end

end

function tableView:insert(itemData, index) 

	local preOffset = self.m_tableView:getContentOffset()

	if index == nil then
	 	table.insert(self.dataSource, itemData) 
	else 
		table.insert(self.dataSource, index, itemData)
	end

	self:reload(self.dataSource)
	self.m_tableView:setContentOffset(cc.p(preOffset.x, preOffset.y - self.itemHeight))

end

function tableView:remove(index) 

	local preOffset = self.m_tableView:getContentOffset()

	table.remove(self.dataSource,index)

	self:reload(self.dataSource)
	self.m_tableView:setContentOffset(cc.p(preOffset.x, preOffset.y - self.itemHeight))

end

function tableView:clear() 
	self:reload({})
end

function tableView:finalize() 

	-- self.dataSource = nil
	-- self.dataSourceSize = nil
	-- self.itemHeight = nil
	-- self.scrollView = nil
	-- self.metaItem = nil
	-- self.itemHandler = nil
	-- package.loaded["hall.scene.group.customScrollView.tableView"] = nil

end

return tableView
