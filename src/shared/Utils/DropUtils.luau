--!strict

local DropConfig = require(script.Parent.Parent:WaitForChild("Configs"):WaitForChild("DropConfig"))
local DropTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("DropTypes"))

type DropItem = DropTypes.DropItem

local DropUtils = {}

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

return table.freeze(DropUtils)
