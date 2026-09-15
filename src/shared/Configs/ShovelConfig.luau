--!strict

local ShovelTypes = require(script.Parent.Parent.Types.ShovelTypes)

type ShovelConfig = ShovelTypes.ShovelConfig

local ShovelConfigs: { [string]: ShovelConfig } = {
	["WoodenShovel"] = {
		id = "WoodenShovel",
		displayName = "Wooden Shovel",
		tier = 1,
		digPower = 10,
		cooldown = 0.5,
		isStarter = true,
		assetName = "WoodenShovel",
		-- Sits visibly on the back (Z = 0.75 to clear jackets/accessories) with 45 degree diagonal tilt
		holsterOffset = CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(180), math.rad(45)),
	},
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
