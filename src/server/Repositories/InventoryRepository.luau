--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local InventoryTypes = require(Shared:WaitForChild("Types"):WaitForChild("InventoryTypes"))
local DropTypes = require(Shared:WaitForChild("Types"):WaitForChild("DropTypes"))
local PlayerProfileStore = require(script.Parent.PlayerProfileStore)

type InventoryItem = InventoryTypes.InventoryItem
type DropItem = DropTypes.DropItem

local InventoryRepository = {}

local DEFAULT_ICONS: { [string]: string } = {
	Fossils = "rbxassetid://135832742918451",
	Relics = "rbxassetid://135832742918451",
	Secrets = "rbxassetid://135832742918451",
	Items = "rbxassetid://135832742918451",
}

local function SyncAttribute(player: Player, items: { InventoryItem })
	pcall(function()
		player:SetAttribute("InventoryData", HttpService:JSONEncode(items))
	end)
end

function InventoryRepository.GetInventory(player: Player): { InventoryItem }
	local data = PlayerProfileStore.GetProfileData(player)
	if not data then return {} end
	if not data.inventory then
		data.inventory = {}
	end
	local items = data.inventory :: { InventoryItem }
	SyncAttribute(player, items)
	return items
end

function InventoryRepository.AddItem(player: Player, drop: DropItem, amount: number?): InventoryItem?
	local data = PlayerProfileStore.GetProfileData(player)
	if not data then return nil end
	if not data.inventory then data.inventory = {} end

	local items = data.inventory :: { InventoryItem }
	local count = amount or 1
	local cat = drop.category or "Items"

	local newItem: InventoryItem = {
		id = drop.id .. "_" .. tostring(os.time()) .. "_" .. tostring(math.random(100, 999)),
		templateId = drop.id,
		displayName = drop.displayName,
		category = cat,
		tier = drop.tier,
		weight = 1.0,
		amount = count,
		icon = drop.icon or DEFAULT_ICONS[cat] or DEFAULT_ICONS.Items,
		description = drop.description or string.format("A fine %s excavated from %s.", drop.displayName, drop.islandId),
		isEquipped = false,
		isFavorite = false,
		obtainedAt = os.time(),
	}

	table.insert(items, newItem)
	SyncAttribute(player, items)
	return newItem
end

function InventoryRepository.RemoveItem(player: Player, uniqueId: string): boolean
	local data = PlayerProfileStore.GetProfileData(player)
	if not data or not data.inventory then return false end
	local items = data.inventory :: { InventoryItem }

	for i, item in ipairs(items) do
		if item.id == uniqueId then
			table.remove(items, i)
			SyncAttribute(player, items)
			return true
		end
	end
	return false
end

return InventoryRepository
