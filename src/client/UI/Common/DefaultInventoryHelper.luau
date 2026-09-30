--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local InventoryTypes = require(Shared:WaitForChild("Types"):WaitForChild("InventoryTypes"))

type InventoryItem = InventoryTypes.InventoryItem

local DefaultInventoryHelper = {}

local function GetOwnedShovelIds(): { string }
	local ids: { string } = {}
	local starter = ShovelUtils.GetStarterShovel()
	if starter then table.insert(ids, starter.id) end
	local raw = Players.LocalPlayer:GetAttribute("OwnedShovels")
	if typeof(raw) ~= "string" then return ids end
	local ok, owned = pcall(HttpService.JSONDecode, HttpService, raw)
	if not ok or typeof(owned) ~= "table" then return ids end
	for shovelId, isOwned in owned do
		if isOwned == true and not table.find(ids, shovelId) then table.insert(ids, shovelId) end
	end
	return ids
end

function DefaultInventoryHelper.GetClientShovelItems(): { InventoryItem }
	local player = Players.LocalPlayer
	local char = if player then player.Character else nil

	local items: { InventoryItem } = {}
	for _, shovelId in GetOwnedShovelIds() do
		local config = ShovelUtils.GetShovelConfig(shovelId)
		if not config then continue end
		local shovelItem: InventoryItem = {
			id = "Shovel_" .. config.id,
			templateId = config.id,
			displayName = config.displayName,
			category = "Shovel",
			tier = "Common",
			weight = 2.5,
			amount = 1,
			icon = "rbxassetid://100488739842115",
			description = string.format("Standard %s suitable for excavators.", config.displayName),
			isEquipped = if char then char:FindFirstChild(config.assetName) ~= nil else false,
			isFavorite = false,
			obtainedAt = os.time(),
			stats = {
				{ name = "Power", value = tostring(config.digPower) },
				{ name = "Luck", value = string.format("+%d%%", config.luckBonus) },
				{ name = "Cooldown", value = string.format("%.1fs", config.cooldown) },
			},
		}
		table.insert(items, shovelItem)
	end

	return items
end

return DefaultInventoryHelper
