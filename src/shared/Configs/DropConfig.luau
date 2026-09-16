--!strict

local DropTypes = require(script.Parent.Parent.Types.DropTypes)

type DropItem = DropTypes.DropItem

-- Probabilitas dari Excel direpresentasikan sebagai "1 in X". 
-- Semakin besar X, semakin kecil peluangnya.
local Island1Drops: { DropItem } = {
	{ id = "BrokenMudPot", displayName = "Broken Mud Pot", tier = "Common", islandId = "Island1", baseProbability = 2 },
	{ id = "ChippedBottle", displayName = "Chipped Bottle", tier = "Common", islandId = "Island1", baseProbability = 5 },
	{ id = "HareSkeleton", displayName = "Hare Skeleton", tier = "Uncommon", islandId = "Island1", baseProbability = 10 },
	{ id = "EchoRavenSkeleton", displayName = "Echo Raven Skeleton", tier = "Uncommon", islandId = "Island1", baseProbability = 150 },
	{ id = "CaveMoleSkeleton", displayName = "Cave Mole Skeleton", tier = "Uncommon", islandId = "Island1", baseProbability = 250 },
	{ id = "FennecFoxSkeleton", displayName = "Fennec Fox Skeleton", tier = "Epic", islandId = "Island1", baseProbability = 750 },
	{ id = "PlatypusSkeleton", displayName = "Platypus Skeleton", tier = "Epic", islandId = "Island1", baseProbability = 1000 },
	{ id = "MountainGoatSkeleton", displayName = "Mountain Goat Skeleton", tier = "Epic", islandId = "Island1", baseProbability = 5000 },
	{ id = "SpottedHyenaSkeleton", displayName = "Spotted Hyena Skeleton", tier = "Legendary", islandId = "Island1", baseProbability = 25000 },
	{ id = "TriceratopsSkeleton", displayName = "Triceratops Skeleton", tier = "Mythic", islandId = "Island1", baseProbability = 200000 },
	{ id = "GolemLeftArm", displayName = "Golem Left Arm", tier = "Mythic", islandId = "Island1", baseProbability = 250000 },
	{ id = "GolemCore", displayName = "Golem Core", tier = "Secret", islandId = "Island1", baseProbability = 750000 },
}

local DropTables: { [string]: { DropItem } } = {
	Island1 = Island1Drops,
}

local DropConfigModule = {
	Island1 = Island1Drops,
}

-- Fungsi murni untuk menghitung hasil galian (RNG)
-- totalLuckMultiplier: Nilai pengali total (misal 1.0X hingga 5.0X+)
function DropConfigModule.RollDrop(islandId: string, totalLuckMultiplier: number): DropItem?
	local dropTable: { DropItem }? = DropTables[islandId]
	if not dropTable then
		return nil
	end

	-- Urutkan dari yang paling langka (Probability X paling besar) ke paling umum
	-- Untuk memastikan item langka di-roll terlebih dahulu
	local sortedDrops: { DropItem } = table.clone(dropTable)
	table.sort(sortedDrops, function(a: DropItem, b: DropItem): boolean
		return a.baseProbability > b.baseProbability
	end)

	local luck = math.max(1.0, totalLuckMultiplier)
	local randomValue = math.random()

	for _, item in sortedDrops do
		-- Peluang efektif: (1 / baseProbability) * luck
		local chance = (1 / item.baseProbability) * luck

		if randomValue <= chance then
			return item
		end

		-- Kurangi pool probabilitas yang tersisa
		randomValue = randomValue - chance
	end

	-- Fallback jika roll tidak mengenai item langka
	return sortedDrops[#sortedDrops]
end

return table.freeze(DropConfigModule)
