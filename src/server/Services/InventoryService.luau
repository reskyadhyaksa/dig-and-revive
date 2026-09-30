--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local InventoryRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("InventoryRepository"))
local ItemToolHelper = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("ItemToolHelper"))
local InventoryFavoriteRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("InventoryFavoriteRepository"))
local ToolRemovalHelper = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("ToolRemovalHelper"))
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type InventoryItem = InventoryTypes.InventoryItem

local InventoryService = {}
local _trove = Trove.new()
local MAX_HOTBAR_ITEMS = 4

local RemoveToolByUniqueId = ToolRemovalHelper.RemoveByUniqueId

local function GetEquippedCount(player: Player): ({ InventoryItem }, number)
	local items = InventoryRepository.GetInventory(player)
	local equipped: { InventoryItem } = {}
	for _, it in ipairs(items) do
		if it.isEquipped and it.category ~= "Shovel" then
			table.insert(equipped, it)
		end
	end
	return equipped, #equipped
end

function InventoryService.Init()
	DigNetwork.EquipItemRequest.on(function(player: Player, uniqueId: string)
		local item = InventoryRepository.FindItem(player, uniqueId)
		if not item then return end

		local bp = player:FindFirstChildOfClass("Backpack")
		local char = player.Character

		if item.isEquipped then
			RemoveToolByUniqueId(player, uniqueId)
			InventoryRepository.SetItemEquipped(player, uniqueId, false)
		else
			local equippedList, count = GetEquippedCount(player)
			if count >= MAX_HOTBAR_ITEMS and equippedList[1] then
				RemoveToolByUniqueId(player, equippedList[1].id)
				InventoryRepository.SetItemEquipped(player, equippedList[1].id, false)
			end

			InventoryRepository.SetItemEquipped(player, uniqueId, true)
			local tool = ItemToolHelper.CreateItemTool(item)
			tool.Parent = bp or char
		end
	end)

	DigNetwork.ToggleFavoriteRequest.on(function(player: Player, uniqueId: string)
		InventoryFavoriteRepository.ToggleFavorite(player, uniqueId)
	end)

	_trove:Connect(Players.PlayerRemoving, function(player)
		local items = InventoryRepository.GetInventory(player)
		for _, it in ipairs(items) do
			if it.isEquipped then RemoveToolByUniqueId(player, it.id) end
		end
	end)
end

function InventoryService.Destroy()
	_trove:Clean()
end

return InventoryService
