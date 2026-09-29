--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("InventoryTypes"))
local PlayerProfileStore = require(script.Parent.PlayerProfileStore)
local InventoryRepository = require(script.Parent.InventoryRepository)

type InventoryItem = InventoryTypes.InventoryItem

local InventoryBatchRepository = {}

-- Removes every item whose id is in the set in a single pass; returns the removed items.
function InventoryBatchRepository.RemoveItems(player: Player, ids: { [string]: boolean }): { InventoryItem }
	local data = PlayerProfileStore.GetProfileData(player)
	if not data or not data.inventory then return {} end

	local items = data.inventory :: { InventoryItem }
	local kept: { InventoryItem } = {}
	local removed: { InventoryItem } = {}
	for _, item in ipairs(items) do
		if ids[item.id] then table.insert(removed, item) else table.insert(kept, item) end
	end

	table.clear(items)
	for _, item in ipairs(kept) do table.insert(items, item) end
	InventoryRepository.GetInventory(player) -- re-syncs the InventoryData attribute
	return removed
end

return InventoryBatchRepository
