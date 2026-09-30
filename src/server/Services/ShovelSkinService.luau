--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelSkinConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelSkinConfig"))
local ShovelSkinUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelSkinUtils"))
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local ShovelSkinTypes = require(Shared:WaitForChild("Types"):WaitForChild("ShovelSkinTypes"))
local Repositories = script.Parent.Parent:WaitForChild("Repositories")
local PlayerProfileStore = require(Repositories:WaitForChild("PlayerProfileStore"))
local ShovelSkinRepository = require(Repositories:WaitForChild("ShovelSkinRepository"))
local ShovelOwnershipRepository = require(Repositories:WaitForChild("ShovelOwnershipRepository"))
local PlayerService = require(script.Parent:WaitForChild("PlayerService"))

type SkinResult = ShovelSkinTypes.SkinResult
type SkinFailReason = ShovelSkinTypes.SkinFailReason

-- Business rules for buying and equipping cosmetic shovel skins. Stats never depend on skins.
local ShovelSkinService = {}

local function Result(skinId: string, reason: SkinFailReason?): SkinResult
	return { ok = reason == nil, skinId = skinId, reason = reason }
end

local function DistanceToShop(player: Player, skinId: string): number
	local char = player.Character
	local root = if char then char:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
	if not root then return math.huge end
	local nearest = math.huge
	for _, shop in CollectionService:GetTagged(ShovelSkinConfig.ShopTag) do
		if shop:IsA("BasePart") and shop:GetAttribute(ShovelSkinConfig.SkinIdAttribute) == skinId then
			nearest = math.min(nearest, (shop.Position - root.Position).Magnitude)
		end
	end
	return nearest
end

local function OwnsShovel(player: Player, shovelId: string): boolean
	local config = ShovelUtils.GetShovelConfig(shovelId)
	return config ~= nil and (config.isStarter or ShovelOwnershipRepository.Owns(player, shovelId))
end

-- The skin a given shovel should currently render, or nil for the default model.
function ShovelSkinService.GetSkinFor(player: Player, shovelId: string): string?
	return ShovelSkinUtils.ResolveEquipped(shovelId, ShovelSkinRepository.GetEquipped(player), ShovelSkinRepository.GetOwned(player))
end

function ShovelSkinService.Purchase(player: Player, skinId: string): SkinResult
	if not PlayerProfileStore.GetProfileData(player) then return Result(skinId, "NoProfile") end
	local skin = ShovelSkinUtils.GetSkin(skinId)
	local reason = ShovelSkinUtils.CheckPurchase(skin, ShovelSkinRepository.GetOwned(player),
		PlayerService.GetPlayerLevel(player), PlayerService.GetCoins(player))
	if not reason and DistanceToShop(player, skinId) > ShovelSkinConfig.MaxPurchaseDistance then reason = "TooFar" end
	if reason or not skin then return Result(skinId, reason or "UnknownSkin") end

	if not PlayerProfileStore.TrySpendCoins(player, skin.price) then return Result(skinId, "NotEnoughCoins") end
	ShovelSkinRepository.Grant(player, skinId)
	PlayerService.SyncPlayerStats(player)
	return Result(skinId, nil)
end

-- skinId = nil restores the default model for that shovel.
function ShovelSkinService.Equip(player: Player, shovelId: string, skinId: string?): SkinResult
	if not PlayerProfileStore.GetProfileData(player) then return Result(skinId or "", "NoProfile") end
	local skin = ShovelSkinUtils.GetSkin(skinId)
	if skinId and not skin then return Result(skinId, "UnknownSkin") end
	local reason = ShovelSkinUtils.CheckEquip(skin, shovelId, ShovelSkinRepository.GetOwned(player), OwnsShovel(player, shovelId))
	if reason then return Result(skinId or "", reason) end
	ShovelSkinRepository.SetEquipped(player, shovelId, skinId)
	return Result(skinId or "", nil)
end

return ShovelSkinService
