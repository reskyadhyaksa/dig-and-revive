--!strict

local DropTypes = require(script.Parent.Parent.Types.DropTypes)

type DropItem = DropTypes.DropItem

local Island1Drops: { DropItem } = {
	{ id = "BrokenMudPot", displayName = "Broken Mud Pot", tier = "Common", islandId = "Island1", baseProbability = 2, minWeight = 1.0, maxWeight = 4.0 },
	{ id = "ChippedBottle", displayName = "Chipped Bottle", tier = "Common", islandId = "Island1", baseProbability = 5, minWeight = 0.5, maxWeight = 2.5 },
	{ id = "HareSkeleton", displayName = "Hare Skeleton", tier = "Uncommon", islandId = "Island1", baseProbability = 10, minWeight = 2.0, maxWeight = 8.0 },
	{ id = "EchoRavenSkeleton", displayName = "Echo Raven Skeleton", tier = "Uncommon", islandId = "Island1", baseProbability = 150, minWeight = 5.0, maxWeight = 20.0 },
	{ id = "CaveMoleSkeleton", displayName = "Cave Mole Skeleton", tier = "Uncommon", islandId = "Island1", baseProbability = 250, minWeight = 8.0, maxWeight = 30.0 },
	{ id = "FennecFoxSkeleton", displayName = "Fennec Fox Skeleton", tier = "Epic", islandId = "Island1", baseProbability = 750, minWeight = 12.0, maxWeight = 45.0 },
	{ id = "PlatypusSkeleton", displayName = "Platypus Skeleton", tier = "Epic", islandId = "Island1", baseProbability = 1000, minWeight = 15.0, maxWeight = 55.0 },
	{ id = "MountainGoatSkeleton", displayName = "Mountain Goat Skeleton", tier = "Epic", islandId = "Island1", baseProbability = 5000, minWeight = 50.0, maxWeight = 200.0 },
	{ id = "SpottedHyenaSkeleton", displayName = "Spotted Hyena Skeleton", tier = "Legendary", islandId = "Island1", baseProbability = 25000, minWeight = 70.0, maxWeight = 280.0 },
	{ id = "TriceratopsSkeleton", displayName = "Triceratops Skeleton", tier = "Mythic", islandId = "Island1", baseProbability = 200000, minWeight = 800.0, maxWeight = 4000.0 },
	{ id = "GolemLeftArm", displayName = "Golem Left Arm", tier = "Mythic", islandId = "Island1", baseProbability = 250000, minWeight = 400.0, maxWeight = 1800.0 },
	{ id = "GolemCore", displayName = "Golem Core", tier = "Secret", islandId = "Island1", baseProbability = 750000, minWeight = 1200.0, maxWeight = 6000.0 },
}

local DropConfig: { [string]: { DropItem } } = {
	Island1 = Island1Drops,
}

return table.freeze(DropConfig)
