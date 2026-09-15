--!strict

local ZoneTypes = require(script.Parent.Parent.Types.ZoneTypes)

type ZoneConfig = ZoneTypes.ZoneConfig
type MaterialConfig = ZoneTypes.MaterialConfig

local MaterialConfigs: { [Enum.Material]: MaterialConfig } = {
	[Enum.Material.Grass] = {
		material = Enum.Material.Grass,
		displayName = "Grass Surface",
		hardnessTier = 1,
		dropTableId = "GRASS_COMMON_DROPS",
		baseDigDuration = 0.5,
	},
	[Enum.Material.Sand] = {
		material = Enum.Material.Sand,
		displayName = "Sand Bed",
		hardnessTier = 1,
		dropTableId = "SAND_COMMON_DROPS",
		baseDigDuration = 0.6,
	},
	[Enum.Material.Slate] = {
		material = Enum.Material.Slate,
		displayName = "Slate Bedrock",
		hardnessTier = 2,
		dropTableId = "SLATE_RARE_DROPS",
		baseDigDuration = 1.2,
	},
}

local ZoneConfigs: { [string]: ZoneConfig } = {
	["Island1_Zoning"] = {
		zoneId = "Island1_Zoning",
		displayName = "Starter Island Dig Zone",
		islandId = "Island1",
		containerPath = "Island1.Zoning",
		allowedMaterials = {
			Enum.Material.Grass,
			Enum.Material.Sand,
			Enum.Material.Slate,
		},
		dropTableId = "ISLAND1_MAIN_DROPS",
		minToolTier = 1,
	},
}

local ZoneConfigModule = {
	Zones = ZoneConfigs,
	Materials = MaterialConfigs,
}

function ZoneConfigModule.GetZoneConfig(zoneId: string): ZoneConfig?
	return ZoneConfigs[zoneId]
end

function ZoneConfigModule.GetMaterialConfig(material: Enum.Material): MaterialConfig?
	return MaterialConfigs[material]
end

function ZoneConfigModule.IsMaterialDiggableInZone(zoneId: string, material: Enum.Material): boolean
	local zone = ZoneConfigs[zoneId]
	if not zone then
		return false
	end

	for _, allowedMaterial in zone.allowedMaterials do
		if allowedMaterial == material then
			return true
		end
	end

	return false
end

return table.freeze(ZoneConfigModule)
