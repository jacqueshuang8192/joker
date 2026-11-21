local SimilarText = {}

--[[
参考：
1.字符串相似度算法,http://www.cnblogs.com/ivanyb/archive/2011/11/25/2263356.html
2.编辑距离(Levenshtein_distance),https://en.m.wikipedia.org/wiki/Levenshtein_distance
]]

function SimilarText:calcDistance(lhs, rhs)
	local length1 = string.len(lhs)
	local length2 = string.len(rhs)
	if length1 == 0 then return length2 end
	if length2 == 0 then return length1 end	
	local row = length1 + 1
	local column = length2 + 1
	local mat = self:createMat(row, column)
	local temp = 0
	for r = 2, row do
		for c = 2, column do
			if string.byte(lhs, r - 1) == string.byte(rhs, c - 1) then
				temp = 0
			else
				temp = 1
			end
			mat[r][c] = math.min(mat[r - 1][c] + 1,
			mat[r][c - 1] + 1, mat[r - 1][c - 1] + temp)
		end		
	end
	return mat[row][column]
end

function SimilarText:createMat(row, column)
	local mat = {}	
	for r = 1, row do
		mat[r] = {}
		for c = 1, column do
			if r == 1 then mat[r][c] = c - 1 end
			if c == 1 then mat[r][c] = r - 1 end
		end
	end
	return mat
end

function SimilarText:similarity(lhs, rhs)
	local length1 = string.len(lhs)
	local length2 = string.len(rhs)	
	local dist = self:calcDistance(lhs, rhs)
	return 1 - dist / math.max(length1, length2)
end

return SimilarText