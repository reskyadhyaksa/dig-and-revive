--!strict

local DropTypes = require(script.Parent.Parent.Types.DropTypes)

type RarityTier = DropTypes.RarityTier

local DigMinigameConfig = {
	TierHp = {
		Common = 12,
		Uncommon = 20,
		Epic = 32,
		Legendary = 48,
		Mythic = 68,
		Secret = 90,
	} :: { [RarityTier]: number },

	Duration = 18.0,
	SwingCooldown = 0.08,

	RegenEvent = {
		chance = 0.18,
		minAmount = 1,
		maxAmount = 3,
		thresholdMinHp = 2,
	},
}

return table.freeze(DigMinigameConfig)
