--!strict

local ShovelConfig = require(script.Parent.Parent:WaitForChild("Configs"):WaitForChild("ShovelConfig"))
local ShovelTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("ShovelTypes"))

type ShovelConfigType = ShovelTypes.ShovelConfig

local ShovelUtils = {}

function ShovelUtils.GetShovelConfig(shovelId: string): ShovelConfigType?
	return ShovelConfig[shovelId]
end

function ShovelUtils.GetStarterShovel(): ShovelConfigType?
	for _, config in ShovelConfig do
		if config.isStarter then
			return config
		end
	end
	return nil
end

-- Returns the selected shovel if the player may use it, otherwise the starter shovel.
function ShovelUtils.ResolveSelectedShovel(selectedId: string?, owned: { [string]: boolean }): ShovelConfigType?
	local config = if selectedId then ShovelConfig[selectedId] else nil
	if config and (config.isStarter or owned[config.id] == true) then return config end
	return ShovelUtils.GetStarterShovel()
end

-- A tool's identity comes from its ShovelId attribute (skins never rename it); name is the legacy fallback.
function ShovelUtils.ResolveToolShovelId(attributeValue: any, toolName: string): string
	return if typeof(attributeValue) == "string" then attributeValue else toolName
end

return table.freeze(ShovelUtils)
