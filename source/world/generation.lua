function World:preSetLayer(layer, heightMap)
	local width, height = Env:getWorldBlocks()
	local dir = layer.dir
	local overwrite = layer.overwrite
	local isExclusive = layer.exclusive
	
	local pre = self.pre
	
	local ys = math.max(dir.min or 1, 1) -- Y Start
	local ye = math.min(dir.max or height, height) -- Y End
	
	local template = dir[1]
	local depth = 1
	
	local hmys -- Height Map Y Start
	
	for x = 1, width do
		depth = 1
		template = dir[depth]
		hmys = (heightMap and heightMap[x] or 1)
		for y = math.max(ys, hmys), ye do
			template = dir[depth] or template
			
			if template.type == -1 then
				break
			end
			
			if overwrite or pre[y][x].type == 0 then
				pre:assignTemplate(x, y, template)
			end
			
			depth = depth + 1
		end
	end
end

function World:preSetHeightMap(mapInfo)
	local dir = mapInfo.dir
	local heightMap = mapInfo.heightMap
	local loops = mapInfo.loops
	
	local pre = self.pre
	
	local width, height = Env:getWorldBlocks()
	
	local xs = mapInfo.xStart or 1 -- X Start
	local xe = mapInfo.xEnd or math.min(xs + #heightMap, width) -- X End
	
	local xo -- X Offset
	local yo -- Y Offset
	
	local ys -- Y Start
	
	local mod
	
	if loops then
		mod = 1
		for k, v in next, dir do
			mod = math.max(k, mod)
		end
	end
	
	local template = {type = 0, tangible = false}
	
	for x = xs, xe do
		xo = (x - xs) + 1
		
		ys = heightMap[xo] or 1
		
		template = {type = 0, tangible = false}
		
		for y = ys, height do
			yo = loops and ((y - ys) % mod) or (y - ys) + 1
			
			template = dir[yo] or template
			
			if template.type == -1 then
				break
			end
			
			pre:assignTemplate(x, y, template)
		end
	end
end

-- To Do: Add 2D Noise parser

function World:preSetNoiseMap(mapInfo)
	local noiseMap = mapInfo.noiseMap
	local dir = mapInfo.dir
	
	local pre = self.pre
	
	local width, height = Env:getWorldBlocks()
	
	local xs = math.range(dir.xStart or 1, 1, width)
	local xe = math.range(dir.xEnd or width, 1, width)
	
	local ys = math.range(dir.yStart or 1, 1, height)
	local ye = math.range(dir.yEnd or height, 1, height)
	
	local xo, yo
	
	local threshold = dir.threshold or 0.5
	
	local sqr = 1
	
	for y = ys, ye do
		yo = (y - ys) + 1
		
		if noiseMap[yo] then
			for x = xs, xe do
				xo = (x - xs) + 1
				
				sqr = noiseMap[yo][xo] or 0
				
				if sqr > threshold then
					pre:assignTemplate(x, y, dir)
				end
			end
		end
	end
end