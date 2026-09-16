--!strict

local ShovelTypes = require(script.Parent.Parent.Types.ShovelTypes)

type ShovelConfig = ShovelTypes.ShovelConfig

local ShovelConfigs: { [string]: ShovelConfig } = {
	["WoodenShovel"] = {
		id = "WoodenShovel",
		displayName = "Wooden Shovel",
		tier = 1,
		digPower = 10,
		luckBonus = 15, -- +15% bonus luck (Starter)
		cooldown = 1.0,
		isStarter = true,
		assetName = "WoodenShovel",
		holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	},
	-- ["StoneShovel"] = {
	-- 	id = "StoneShovel",
	-- 	displayName = "Stone Shovel",
	-- 	tier = 2,
	-- 	digPower = 15,
	-- 	luckBonus = 60, -- +60% bonus luck
	-- 	cooldown = 0.9,
	-- 	isStarter = false,
	-- 	assetName = "StoneShovel",
	-- 	holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	-- },
	-- ["IronShovel"] = {
	-- 	id = "IronShovel",
	-- 	displayName = "Iron Shovel",
	-- 	tier = 3,
	-- 	digPower = 25,
	-- 	luckBonus = 140, -- +140% bonus luck
	-- 	cooldown = 0.8,
	-- 	isStarter = false,
	-- 	assetName = "IronShovel",
	-- 	holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	-- },
	-- ["GoldShovel"] = {
	-- 	id = "GoldShovel",
	-- 	displayName = "Golden Shovel",
	-- 	tier = 4,
	-- 	digPower = 40,
	-- 	luckBonus = 250, -- +250% bonus luck
	-- 	cooldown = 0.7,
	-- 	isStarter = false,
	-- 	assetName = "GoldShovel",
	-- 	holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	-- },
	-- ["DiamondShovel"] = {
	-- 	id = "DiamondShovel",
	-- 	displayName = "Diamond Shovel",
	-- 	tier = 5,
	-- 	digPower = 65,
	-- 	luckBonus = 380, -- +380% bonus luck
	-- 	cooldown = 0.6,
	-- 	isStarter = false,
	-- 	assetName = "DiamondShovel",
	-- 	holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	-- },
	-- ["MythicShovel"] = {
	-- 	id = "MythicShovel",
	-- 	displayName = "Mythic Celestial Shovel",
	-- 	tier = 6,
	-- 	digPower = 100,
	-- 	luckBonus = 500, -- +500% bonus luck (High Tier)
	-- 	cooldown = 0.5,
	-- 	isStarter = false,
	-- 	assetName = "MythicShovel",
	-- 	holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	-- },
}

local ShovelConfigModule = {
	Shovels = ShovelConfigs,
}

function ShovelConfigModule.GetShovelConfig(shovelId: string): ShovelConfig?
	return ShovelConfigs[shovelId]
end

function ShovelConfigModule.GetStarterShovel(): ShovelConfig?
	for _, config in ShovelConfigs do
		if config.isStarter then
			return config
		end
	end
	return nil
end

return table.freeze(ShovelConfigModule)
