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
		assetName = "WoodenShovel",
		holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	},
}

return table.freeze(ShovelConfig)
