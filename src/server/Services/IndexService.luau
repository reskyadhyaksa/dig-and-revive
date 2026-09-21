--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local IndexTypes = require(Shared:WaitForChild("Types"):WaitForChild("IndexTypes"))
local IndexUtils = require(Shared:WaitForChild("Utils"):WaitForChild("IndexUtils"))
local IndexRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("IndexRepository"))

type PlayerIndexData = IndexTypes.PlayerIndexData

local IndexService = {}
local _trove = Trove.new()

function IndexService.Init()
	-- Ready for incoming index network events if needed
end

function IndexService.RecordDiscovery(player: Player, itemId: string): (boolean, number)
	local isFirst, count = IndexRepository.RecordDiscovery(player, itemId)
	local catalogItem = IndexUtils.GetCatalogItem(itemId)

	if isFirst and catalogItem then
		print(string.format("[IndexService] Player %s discovered new item: %s (%s)", player.Name, catalogItem.displayName, catalogItem.tier))
	end

	return isFirst, count
end

function IndexService.GetPlayerIndex(player: Player): PlayerIndexData
	return IndexRepository.GetPlayerIndex(player)
end

function IndexService.Destroy()
	_trove:Clean()
end

return IndexService
