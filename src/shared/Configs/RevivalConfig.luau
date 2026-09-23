--!strict

local RevivalTypes = require(script.Parent.Parent.Types.RevivalTypes)

type RevivalRecipe = RevivalTypes.RevivalRecipe

local Island1Recipes: { [string]: RevivalRecipe } = {
	HareSkeleton = {
		fossilId = "HareSkeleton",
		primeLivingId = "Hare",
		displayName = "Prime Hare",
		islandId = "Island1",
		modelAssetPath = "Hare",
		tier = "Uncommon",
		displayDuration = 5,
		expReward = 50,
		coinReward = 100,
		description = "Revived prime hare from ancient skeletal remains.",
	},
	EchoRavenSkeleton = {
		fossilId = "EchoRavenSkeleton",
		primeLivingId = "EchoRaven",
		displayName = "Prime Echo Raven",
		islandId = "Island1",
		modelAssetPath = "EchoRaven",
		tier = "Uncommon",
		displayDuration = 5,
		expReward = 120,
		coinReward = 250,
		description = "A mythical prime echo raven brought back to life on the altar.",
	},
	CaveMoleSkeleton = {
		fossilId = "CaveMoleSkeleton",
		primeLivingId = "CaveMole",
		displayName = "Prime Cave Mole",
		islandId = "Island1",
		modelAssetPath = "CaveMole",
		tier = "Uncommon",
		displayDuration = 5,
		expReward = 150,
		coinReward = 300,
	},
	FennecFoxSkeleton = {
		fossilId = "FennecFoxSkeleton",
		primeLivingId = "FennecFox",
		displayName = "Prime Fennec Fox",
		islandId = "Island1",
		modelAssetPath = "FennecFox",
		tier = "Epic",
		displayDuration = 5,
		expReward = 400,
		coinReward = 800,
	},
	PlatypusSkeleton = {
		fossilId = "PlatypusSkeleton",
		primeLivingId = "Platypus",
		displayName = "Prime Platypus",
		islandId = "Island1",
		modelAssetPath = "Platypus",
		tier = "Epic",
		displayDuration = 5,
		expReward = 500,
		coinReward = 1000,
	},
	MountainGoatSkeleton = {
		fossilId = "MountainGoatSkeleton",
		primeLivingId = "MountainGoat",
		displayName = "Prime Mountain Goat",
		islandId = "Island1",
		modelAssetPath = "MountainGoat",
		tier = "Epic",
		displayDuration = 5,
		expReward = 750,
		coinReward = 1500,
	},
	SpottedHyenaSkeleton = {
		fossilId = "SpottedHyenaSkeleton",
		primeLivingId = "SpottedHyena",
		displayName = "Prime Spotted Hyena",
		islandId = "Island1",
		modelAssetPath = "SpottedHyena",
		tier = "Legendary",
		displayDuration = 5,
		expReward = 2500,
		coinReward = 5000,
	},
	TriceratopsSkeleton = {
		fossilId = "TriceratopsSkeleton",
		primeLivingId = "Triceratops",
		displayName = "Prime Triceratops",
		islandId = "Island1",
		modelAssetPath = "Triceratops",
		tier = "Mythic",
		displayDuration = 5,
		expReward = 10000,
		coinReward = 25000,
	},
}

local RevivalConfig = {
	RecipesByFossilId = Island1Recipes,
	DefaultAltarHoldDuration = 1.5,
	DefaultAltarDisplayDuration = 5,
	DefaultPromptActionText = "Revive Fossil",
	DefaultPromptObjectText = "Altar of Revival",
}

return table.freeze(RevivalConfig)
