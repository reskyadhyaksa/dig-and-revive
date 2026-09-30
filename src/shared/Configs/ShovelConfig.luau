--!strict

local ShovelTypes = require(script.Parent.Parent.Types.ShovelTypes)

type ShovelConfig = ShovelTypes.ShovelConfig

local ShovelConfig: { [string]: ShovelConfig } = {
	["WoodenShovel"] = {
		id = "WoodenShovel",
		displayName = "Wooden Shovel",
		tier = 1,
		digPower = 10,
		luckBonus = 15,
		cooldown = 1.0,
		isStarter = true,
		price = 0,
		requiredLevel = 1,
		assetName = "WoodenShovel",
		holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	},

	["IronShovel"] = {
		id = "IronShovel",
		displayName = "Iron Shovel",
		tier = 1,
		digPower = 15,
		luckBonus = 20,
		cooldown = 0.8,
		isStarter = false,
		price = 500,
		requiredLevel = 1,
		assetName = "IronShovel",
		holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	},
}

return table.freeze(ShovelConfig)
