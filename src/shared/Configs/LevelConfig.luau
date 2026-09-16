--!strict

local Shared = script.Parent.Parent
local DropTypes = require(Shared:WaitForChild("Types"):WaitForChild("DropTypes"))

type RarityTier = DropTypes.RarityTier

local LevelConfig = {
	TierExpRewards = {
		Common = 15,
		Uncommon = 35,
		Epic = 100,
		Legendary = 350,
		Mythic = 1500,
		Secret = 5000,
	} :: { [RarityTier]: number },
}

return table.freeze(LevelConfig)
