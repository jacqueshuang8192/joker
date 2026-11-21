local GameUtils = {}


function GameUtils.setNodeNameBindObj(node)
	if node == nil or node.getChildren == nil then return end
    local childs = node:getChildren()
	if #childs>0 then
		for _,child in ipairs(childs) do
			local name = child:getName()
			child._name = name
			if name ~= "" and not node[name] then
				node[name] = GameUtils.setNodeNameBindObj(child)
			else

				--assert(false, name.."命名不合法 或 重复!!!")  --不要在开出来了，会导致骨骼动画不能用
			end
		end
	end
	return node
end

function GameUtils.setNodeNameBindObjDebug(node)
	local childs = node:getChildren()
	node._getName = node:getName()
	node._getContentSize = node:getContentSize()
	-- node._getScale = node:getScale()
	node._getPosition = node:getPosition()
	node._getAnchorPoint = node:getAnchorPoint()
	node._getParent = node:getParent()
	node._gisVisible = node:isVisible()
	node._getChildren = node:getChildren()
	if #childs>0 then
		for _,child in ipairs(childs) do
			local name = child:getName()
			child._gname = name
			child._getContentSize = child:getContentSize()
			-- child._getScale = child:getScale()
			child._getPosition = child:getPosition()
			child._getAnchorPoint = child:getAnchorPoint()
			child._gisVisible = child:isVisible()
			if name ~= "" and not node[name] then
				node[name] = GameUtils.setNodeNameBindObj(child)
			else
				--assert(false, name.."命名不合法 或 重复!!!")
			end
		end
	end
	return node
end

function GameUtils:getParam( node )
	node._childs = node:getChildren()
	node._getName = node:getName()
	node._getContentSize = node:getContentSize()
	-- node._getScale = node:getScale()
	node._getPosition = node:getPosition()
	node._getAnchorPoint = node:getAnchorPoint()
	node._getParent = node:getParent()
	node._gisVisible = node:isVisible()
	node._getChildren = node:getChildren()
    print("------------------")
	dump(node._childs)
	dump(node._getName)
	dump(node._getContentSize)
	dump(node._getPosition)
	dump(node._getAnchorPoint)
	dump(node._getParent)
	dump(node._gisVisible)
	dump(node._getChildren)
    print("------------------")
end

if device.platform == "windows" then
	GameUtils.setNodeNameBindObj = GameUtils.setNodeNameBindObjDebug
end
return GameUtils