--!strict

local DropConfig = require(script.Parent.Parent:WaitForChild("Configs"):WaitForChild("DropConfig"))
local DropTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("DropTypes"))

type DropItem = DropTypes.DropItem

local DropUtils = {}

function DropUtils.GetDropItem(itemId: string): DropItem?
	for _, dropList in pairs(DropConfig) do
		for _, drop in ipairs(dropList) do
			if drop.id == itemId then return drop end
		end
	end
	return nil
end

function DropUtils.GenerateWeight(drop: DropItem): number
	local minW = drop.minWeight or 1.0
	local maxW = drop.maxWeight or (minW * 2.5)
	local rawWeight = minW + math.random() * (maxW - minW)
	return math.round(rawWeight * 10) / 10
end

function DropUtils.CalculateScaleMultiplier(itemId: string, weight: number?): number
	local drop = DropUtils.GetDropItem(itemId)
	if drop and drop.minWeight and drop.maxWeight then
		local w = weight or drop.minWeight
		local ratio = math.clamp((w - drop.minWeight) / math.max(0.01, drop.maxWeight - drop.minWeight), 0, 1)
		local mult = 1.0 + ratio * 1.0
		return math.round(mult * 100) / 100
	end
	return 1.0
end

function DropUtils.RollDrop(islandId: string, totalLuckMultiplier: number): DropItem?
	local dropTable = DropConfig[islandId] :: { DropItem }?
	if not dropTable then return nil end

	local sortedDrops: { DropItem } = table.clone(dropTable)
	table.sort(sortedDrops, function(a: DropItem, b: DropItem)
		return a.baseProbability > b.baseProbability
	end)

	local luck = math.max(1.0, totalLuckMultiplier)
	local randomValue = math.random()

	for _, item in sortedDrops do
		local chance = (1 / item.baseProbability) * luck
		if randomValue <= chance then
			return item
		end
		randomValue -= chance
	end

	return sortedDrops[#sortedDrops]
end

function DropUtils.GetDropByTier(islandId: string?, tier: string?): DropItem?
	if not tier then return nil end
	local dropList = if islandId then DropConfig[islandId] else nil
	if dropList then
		for _, drop in ipairs(dropList) do
			if drop.tier == tier then return drop end
		end
	end
	for _, drops in pairs(DropConfig) do
		for _, drop in ipairs(drops) do
			if drop.tier == tier then return drop end
		end
	end
	return nil
end

return table.freeze(DropUtils)
