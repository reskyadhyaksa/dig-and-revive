--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local LevelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("LevelUtils"))
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local LevelTypes = require(Shared:WaitForChild("Types"):WaitForChild("LevelTypes"))
local ShovelTypes = require(Shared:WaitForChild("Types"):WaitForChild("ShovelTypes"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local PlayerProfileStore = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("PlayerProfileStore"))
local IndexRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("IndexRepository"))
local InventoryRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("InventoryRepository"))
local ShovelOwnershipRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("ShovelOwnershipRepository"))

type ExpRewardResult = LevelTypes.ExpRewardResult
type ShovelConfigType = ShovelTypes.ShovelConfig

local PlayerService = {}
local _trove = Trove.new()

function PlayerService.Init()
	_trove:Connect(Players.PlayerAdded, function(p)
		if PlayerProfileStore.LoadProfile(p) then PlayerService.SyncPlayerStats(p) end
	end)
	_trove:Connect(Players.PlayerRemoving, function(p)
		PlayerProfileStore.ReleaseProfile(p)
	end)
	for _, p in Players:GetPlayers() do
		task.spawn(function()
			if PlayerProfileStore.LoadProfile(p) then PlayerService.SyncPlayerStats(p) end
		end)
	end
end

function PlayerService.GetPlayerLevel(p: Player): number
	local data = PlayerProfileStore.GetProfileData(p)
	return if data then data.level else 1
end

function PlayerService.GetPlayerExp(p: Player): number
	local data = PlayerProfileStore.GetProfileData(p)
	return if data then data.exp else 0
end

function PlayerService.GetCoins(p: Player): number
	return PlayerProfileStore.GetCoins(p)
end

function PlayerService.GetEquippedShovelConfig(p: Player): ShovelConfigType?
	local function checkTool(container: Instance?): ShovelConfigType?
		if not container then return nil end
		local tool = container:FindFirstChildWhichIsA("Tool")
		return if tool then ShovelUtils.GetShovelConfig(ShovelUtils.ResolveToolShovelId(tool:GetAttribute("ShovelId"), tool.Name)) else nil
	end
	return checkTool(p.Character) or checkTool(p:FindFirstChildOfClass("Backpack")) or ShovelUtils.GetStarterShovel()
end

function PlayerService.GetTotalPlayerLuck(p: Player): number
	local levelMult = LevelUtils.GetLevelLuckMultiplier(PlayerService.GetPlayerLevel(p))
	local shovelCfg = PlayerService.GetEquippedShovelConfig(p)
	local bonus = if shovelCfg then (shovelCfg.luckBonus or 0) else 0
	return levelMult + (bonus / 100)
end

function PlayerService.AddExp(p: Player, amount: number): ExpRewardResult
	local result = LevelUtils.CalculateExpGain(PlayerService.GetPlayerLevel(p), PlayerService.GetPlayerExp(p), amount)
	PlayerProfileStore.SetLevelAndExp(p, result.newLevel, result.newExp)
	PlayerService.SyncPlayerStats(p)
	return result
end

function PlayerService.AddCoins(p: Player, amount: number): number
	local total = PlayerProfileStore.AddCoins(p, amount)
	PlayerService.SyncPlayerStats(p)
	return total
end

function PlayerService.SyncPlayerStats(p: Player)
	local data = PlayerProfileStore.GetProfileData(p)
	if not data then return end
	local requiredExp = LevelUtils.GetRequiredExp(data.level)
	local luck = PlayerService.GetTotalPlayerLuck(p)
	p:SetAttribute("Level", data.level)
	p:SetAttribute("Coins", data.coins or 0)
	IndexRepository.GetPlayerIndex(p)
	InventoryRepository.GetInventory(p)
	ShovelOwnershipRepository.GetOwned(p)
	DigNetwork.PlayerStatsSync.fire(p, data.level, data.exp, requiredExp, data.coins or 0, luck)
end

function PlayerService.Destroy()
	_trove:Clean()
end

return PlayerService
