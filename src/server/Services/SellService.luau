--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local SellConfig = require(Shared:WaitForChild("Configs"):WaitForChild("SellConfig"))
local SellUtils = require(Shared:WaitForChild("Utils"):WaitForChild("SellUtils"))
local DialogTypes = require(Shared:WaitForChild("Types"):WaitForChild("DialogTypes"))
local InventoryTypes = require(Shared:WaitForChild("Types"):WaitForChild("InventoryTypes"))
local InventoryRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("InventoryRepository"))
local InventoryBatchRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("InventoryBatchRepository"))
local PlayerService = require(script.Parent.PlayerService)

type SellMode = DialogTypes.SellMode
type SellResult = DialogTypes.SellResult
type InventoryItem = InventoryTypes.InventoryItem

local SellService = {}

local function Fail(reason: string): SellResult
	return { ok = false, coins = 0, count = 0, reason = reason }
end

local function GetRootPosition(player: Player): Vector3?
	local char = player.Character
	local root = if char then char:FindFirstChild("HumanoidRootPart") else nil
	return if root and root:IsA("BasePart") then root.Position else nil
end

local function IsNearMerchant(position: Vector3): boolean
	for _, npc in ipairs(CollectionService:GetTagged(SellConfig.NpcTag)) do
		local pivot = if npc:IsA("Model") then npc:GetPivot().Position elseif npc:IsA("BasePart") then npc.Position else nil
		if pivot and SellUtils.IsWithinRange(position, pivot, SellConfig.MaxInteractDistance) then return true end
	end
	return false
end

-- Held item is resolved from the server's view of the character, never from a client-sent id.
local function GetHeldItem(player: Player): (InventoryItem?, Tool?)
	local char = player.Character
	local tool = if char then char:FindFirstChildWhichIsA("Tool") else nil
	local uniqueId = if tool then tool:GetAttribute("UniqueId") else nil
	if not tool or typeof(uniqueId) ~= "string" then return nil, nil end
	return InventoryRepository.FindItem(player, uniqueId), tool
end

local function Commit(player: Player, items: { InventoryItem }): SellResult
	local ids: { [string]: boolean } = {}
	for _, item in ipairs(items) do ids[item.id] = true end
	local removed = InventoryBatchRepository.RemoveItems(player, ids)
	local coins = SellUtils.TotalPrice(removed)
	if coins > 0 then PlayerService.AddCoins(player, coins) end
	return { ok = true, coins = coins, count = #removed, reason = nil }
end

function SellService.Sell(player: Player, mode: SellMode): SellResult
	local position = GetRootPosition(player)
	if not position or not IsNearMerchant(position) then return Fail("TooFar") end

	if mode == "Held" then
		local item, tool = GetHeldItem(player)
		if not item or not tool then return Fail("NoHeldItem") end
		if not SellUtils.IsSellable(item) then return Fail("Unsellable") end
		tool:Destroy()
		return Commit(player, { item })
	end

	local sellable = SellUtils.FilterSellAll(InventoryRepository.GetInventory(player))
	if #sellable == 0 then return Fail("NothingToSell") end
	return Commit(player, sellable)
end

return SellService
