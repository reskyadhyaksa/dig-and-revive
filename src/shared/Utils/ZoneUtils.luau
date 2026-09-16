--!strict

local ZoneConfig = require(script.Parent.Parent:WaitForChild("Configs"):WaitForChild("ZoneConfig"))
local ZoneTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("ZoneTypes"))

type ZoneConfig = ZoneTypes.ZoneConfig
type MaterialConfig = ZoneTypes.MaterialConfig

local ZoneUtils = {}

function ZoneUtils.GetZoneConfig(zoneId: string): ZoneConfig?
	return ZoneConfig.Zones[zoneId]
end

function ZoneUtils.GetMaterialConfig(material: Enum.Material): MaterialConfig?
	return ZoneConfig.Materials[material]
end

function ZoneUtils.IsMaterialDiggableInZone(zoneId: string, material: Enum.Material): boolean
	local zone = ZoneConfig.Zones[zoneId]
	if not zone then return false end
	for _, allowed in zone.allowedMaterials do
		if allowed == material then return true end
	end
	return false
end

return table.freeze(ZoneUtils)
