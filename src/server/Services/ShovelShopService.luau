--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelShopConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelShopConfig"))
local ShovelShopUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelShopUtils"))
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local ShovelTypes = require(Shared:WaitForChild("Types"):WaitForChild("ShovelTypes"))
local Repositories = script.Parent.Parent:WaitForChild("Repositories")
local PlayerProfileStore = require(Repositories:WaitForChild("PlayerProfileStore"))
local ShovelOwnershipRepository = require(Repositories:WaitForChild("ShovelOwnershipRepository"))
local PlayerService = require(script.Parent:WaitForChild("PlayerService"))

type PurchaseResult = ShovelTypes.PurchaseResult
type PurchaseFailReason = ShovelTypes.PurchaseFailReason

local ShovelShopService = {}

local function GetShopPosition(instance: Instance): Vector3?
	if instance:IsA("BasePart") then return instance.Position end
	if instance:IsA("Model") then return instance:GetPivot().Position end
	return nil
end

local function DistanceToNearestShop(player: Player, shovelId: string): number
	local char = player.Character
	local root = if char then char:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
	if not root then return math.huge end

	local nearest = math.huge
	for _, shop in CollectionService:GetTagged(ShovelShopConfig.ShopTag) do
		local id = shop:GetAttribute(ShovelShopConfig.ShovelIdAttribute) or shop.Name
		local pos = if id == shovelId then GetShopPosition(shop) else nil
		if pos then nearest = math.min(nearest, (pos - root.Position).Magnitude) end
	end
	return nearest
end

local function Fail(shovelId: string, reason: PurchaseFailReason): PurchaseResult
	return { ok = false, shovelId = shovelId, reason = reason }
end

function ShovelShopService.Purchase(player: Player, shovelId: string): PurchaseResult
	if not PlayerProfileStore.GetProfileData(player) then return Fail(shovelId, "NoProfile") end

	local config = ShovelUtils.GetShovelConfig(shovelId)
	local reason = ShovelShopUtils.CheckPurchase(
		config,
		ShovelOwnershipRepository.Owns(player, shovelId),
		PlayerService.GetPlayerLevel(player),
		PlayerService.GetCoins(player),
		DistanceToNearestShop(player, shovelId),
		ShovelShopConfig.MaxPurchaseDistance
	)
	if reason or not config then return Fail(shovelId, reason or "UnknownShovel") end

	if not PlayerProfileStore.TrySpendCoins(player, config.price) then return Fail(shovelId, "NotEnoughCoins") end
	ShovelOwnershipRepository.SetSelected(player, shovelId)
	ShovelOwnershipRepository.Grant(player, shovelId)
	PlayerService.SyncPlayerStats(player)
	return { ok = true, shovelId = shovelId, reason = nil }
end

return ShovelShopService
