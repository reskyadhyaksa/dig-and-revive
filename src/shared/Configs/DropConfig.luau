--!strict

local DropTypes = require(script.Parent.Parent.Types.DropTypes)

type DropItem = DropTypes.DropItem

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

local DropConfig: { [string]: { DropItem } } = {
	Island1 = Island1Drops,
}

return table.freeze(DropConfig)
