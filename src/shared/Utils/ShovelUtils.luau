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

return table.freeze(ShovelUtils)
