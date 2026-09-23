--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local InventoryTypes = require(Shared:WaitForChild("Types"):WaitForChild("InventoryTypes"))

type InventoryItem = InventoryTypes.InventoryItem

local DefaultInventoryHelper = {}

function DefaultInventoryHelper.GetClientShovelItems(): { InventoryItem }
	local player = Players.LocalPlayer
	local char = if player then player.Character else nil
	local bp = if player then player:FindFirstChildOfClass("Backpack") else nil

	local items: { InventoryItem } = {}
	local starter = ShovelUtils.GetStarterShovel()

	if starter then
		local isEquippedInChar = if char then char:FindFirstChild(starter.assetName) ~= nil else false
		local isInBackpack = if bp then bp:FindFirstChild(starter.assetName) ~= nil else false
		local ownsShovel = isEquippedInChar or isInBackpack or true

		if ownsShovel then
			local shovelItem: InventoryItem = {
				id = "Shovel_" .. starter.id,
				templateId = starter.id,
				displayName = starter.displayName,
				category = "Shovel",
				tier = "Common",
				weight = 2.5,
				amount = 1,
				icon = "rbxassetid://100488739842115",
				description = string.format("Standard %s suitable for excavators.", starter.displayName),
				isEquipped = isEquippedInChar,
				isFavorite = false,
				obtainedAt = os.time(),
				stats = {
					{ name = "Power", value = tostring(starter.digPower) },
					{ name = "Luck", value = string.format("+%d%%", starter.luckBonus) },
					{ name = "Cooldown", value = string.format("%.1fs", starter.cooldown) },
				},
			}
			table.insert(items, shovelItem)
		end
	end

	return items
end

return DefaultInventoryHelper
