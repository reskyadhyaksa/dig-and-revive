--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))

local InventoryModal = require(script.Parent.Inventory.InventoryModal)
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type InventoryItem = InventoryTypes.InventoryItem

local MOCK_ITEMS: { InventoryItem } = {}
local TIERS: { InventoryTypes.ItemRarity } = { "Common", "Uncommon", "Epic", "Legendary", "Mythic", "Secret" }
local CATEGORIES = { "Items", "Shovel", "Potion" }
local ICONS = {
	Items = "rbxassetid://122992611665292",
	Shovel = "rbxassetid://100488739842115",
	Potion = "rbxassetid://100488739842115",
}

for i = 1, 100 do
	local cat = CATEGORIES[((i - 1) % #CATEGORIES) + 1]
	local tier: InventoryTypes.ItemRarity = TIERS[((i - 1) % #TIERS) + 1]
	local weight = if cat == "Shovel" then (2 + (i % 8) * 1.5)
		elseif cat == "Potion" then (0.5 + (i % 4) * 0.5)
		else (if (i % 12) == 0 then (1200 + (i % 5) * 600) else (1 + (i % 25) * 2.5))

	local item: InventoryItem = {
		id = "inst_" .. string.format("%06d", i),
		templateId = string.lower(cat) .. "_" .. tostring((i % 8) + 1),
		displayName = string.format("%s #%d", if cat == "Shovel" then "Pickaxe" else (if cat == "Potion" then "Elixir" else "Ore"), i),
		category = cat,
		tier = tier,
		weight = weight,
		amount = 1,
		icon = ICONS[cat],
		description = "A powerful resource found deep within ancient excavation ruins.",
		isEquipped = i == 2,
		isFavorite = (i % 7 == 0),
		obtainedAt = 1700000000 + i * 10,
	}
	table.insert(MOCK_ITEMS, item)
end

local story = {
	summary = "Wooden-themed RPG Inventory Modal with 100 items covering all rarity tiers",
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		visible = true,
		playerLevel = 125,
	},
	story = function(props: { controls: { visible: boolean, playerLevel: number }, target: Instance })
		return React.createElement(InventoryModal, {
			visible = if props.controls.visible ~= nil then props.controls.visible else true,
			items = MOCK_ITEMS,
			playerLevel = props.controls.playerLevel or 125,
			defaultTab = "Items",
			onClose = function() print("[Story] Close clicked") end,
			onEquipToggle = function(item) print("[Story] Equip toggle on:", item.displayName) end,
			onDrop = function(item) print("[Story] Drop item:", item.displayName) end,
		})
	end,
}

return story
