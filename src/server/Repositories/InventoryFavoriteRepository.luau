--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("InventoryTypes"))
local InventoryRepository = require(script.Parent.InventoryRepository)

type InventoryItem = InventoryTypes.InventoryItem

local InventoryFavoriteRepository = {}

-- Flips the saved favorite flag; returns the new value, or nil if the item doesn't exist.
function InventoryFavoriteRepository.ToggleFavorite(player: Player, uniqueId: string): boolean?
	local item = InventoryRepository.FindItem(player, uniqueId)
	if not item then return nil end
	item.isFavorite = not item.isFavorite
	InventoryRepository.GetInventory(player) -- re-syncs the InventoryData attribute
	return item.isFavorite
end

return InventoryFavoriteRepository
