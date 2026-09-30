--!strict

local ShovelShopConfig = {
	ShopTag = "ShovelShop",
	ShovelIdAttribute = "ShovelId",
	MaxPurchaseDistance = 14,
	RequestCooldown = 0.5,
	SelectCooldown = 0.3,
	PromptKey = Enum.KeyCode.E,
	PromptHoldDuration = 0.3,
	CurrencyName = "Coins",

	Messages = {
		Success = "Purchased %s!",
		AlreadyOwned = "You already own this shovel.",
		LevelTooLow = "Requires level %d.",
		NotEnoughCoins = "Not enough coins.",
		TooFar = "Move closer to buy.",
		UnknownShovel = "This shovel is not for sale.",
		NoProfile = "Your data is still loading.",
	} :: { [string]: string },
}

return table.freeze(ShovelShopConfig)
