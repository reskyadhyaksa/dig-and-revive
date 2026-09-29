--!strict

local SellConfig = {
	NpcTag = "Merchant",
	MaxInteractDistance = 14,
	RequestCooldown = 0.5,
	WeightPriceFactor = 0.05,

	TierPrices = {
		Common = 10,
		Uncommon = 25,
		Epic = 120,
		Legendary = 450,
		Mythic = 1500,
		Secret = 5000,
	} :: { [string]: number },

	UnsellableCategories = {
		Shovel = true,
		Codex = true,
	} :: { [string]: boolean },
}

return table.freeze(SellConfig)
