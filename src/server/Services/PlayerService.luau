--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local LevelConfig = require(Shared:WaitForChild("Configs"):WaitForChild("LevelConfig"))
local ShovelConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelConfig"))
local LevelTypes = require(Shared:WaitForChild("Types"):WaitForChild("LevelTypes"))
local ShovelTypes = require(Shared:WaitForChild("Types"):WaitForChild("ShovelTypes"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local PlayerProfileStore = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("PlayerProfileStore"))

type ExpRewardResult = LevelTypes.ExpRewardResult
type ShovelConfigType = ShovelTypes.ShovelConfig

local PlayerService = {}
PlayerService.__index = PlayerService

local _serviceTrove = Trove.new()

function PlayerService.Init()
	_serviceTrove:Connect(Players.PlayerAdded, function(player: Player)
		PlayerService._OnPlayerAdded(player)
	end)

	_serviceTrove:Connect(Players.PlayerRemoving, function(player: Player)
		PlayerService._OnPlayerRemoving(player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			PlayerService._OnPlayerAdded(player)
		end)
	end
end

function PlayerService._OnPlayerAdded(player: Player)
	local profileData = PlayerProfileStore.LoadProfile(player)
	if profileData ~= nil then
		PlayerService.SyncPlayerStats(player)
	end
end

function PlayerService._OnPlayerRemoving(player: Player)
	PlayerProfileStore.ReleaseProfile(player)
end

function PlayerService.GetPlayerLevel(player: Player): number
	local data = PlayerProfileStore.GetProfileData(player)
	return if data then data.level else 1
end

function PlayerService.GetPlayerExp(player: Player): number
	local data = PlayerProfileStore.GetProfileData(player)
	return if data then data.exp else 0
end

function PlayerService.GetCoins(player: Player): number
	return PlayerProfileStore.GetCoins(player)
end

function PlayerService.GetLevelLuck(player: Player): number
	local level = PlayerService.GetPlayerLevel(player)
	return LevelConfig.GetLevelLuckMultiplier(level)
end

function PlayerService.GetEquippedShovelConfig(player: Player): ShovelConfigType?
	local char = player.Character
	if char then
		local tool = char:FindFirstChildWhichIsA("Tool")
		if tool then
			local cfg = ShovelConfig.GetShovelConfig(tool.Name)
			if cfg then return cfg end
		end
	end

	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		local tool = backpack:FindFirstChildWhichIsA("Tool")
		if tool then
			local cfg = ShovelConfig.GetShovelConfig(tool.Name)
			if cfg then return cfg end
		end
	end

	return ShovelConfig.GetStarterShovel()
end

function PlayerService.GetTotalPlayerLuck(player: Player): number
	local level = PlayerService.GetPlayerLevel(player)
	local levelMultiplier = LevelConfig.GetLevelLuckMultiplier(level)
	local shovelCfg = PlayerService.GetEquippedShovelConfig(player)
	local shovelBonus = if shovelCfg then (shovelCfg.luckBonus or 0) else 0
	return levelMultiplier + (shovelBonus / 100)
end

function PlayerService.AddExp(player: Player, amount: number): ExpRewardResult
	local currentLevel = PlayerService.GetPlayerLevel(player)
	local currentExp = PlayerService.GetPlayerExp(player)

	local result = LevelConfig.CalculateExpGain(currentLevel, currentExp, amount)
	PlayerProfileStore.SetLevelAndExp(player, result.newLevel, result.newExp)

	PlayerService.SyncPlayerStats(player)

	return result
end

function PlayerService.AddCoins(player: Player, amount: number): number
	local newTotal = PlayerProfileStore.AddCoins(player, amount)
	PlayerService.SyncPlayerStats(player)
	return newTotal
end

function PlayerService.SyncPlayerStats(player: Player)
	local data = PlayerProfileStore.GetProfileData(player)
	if not data then return end

	local requiredExp = LevelConfig.GetRequiredExp(data.level)
	local totalLuckMultiplier = PlayerService.GetTotalPlayerLuck(player)
	local coins = data.coins or 0

	player:SetAttribute("Level", data.level)
	player:SetAttribute("Coins", coins)

	DigNetwork.PlayerStatsSync.fire(
		player,
		data.level,
		data.exp,
		requiredExp,
		coins,
		totalLuckMultiplier
	)
end

function PlayerService.Destroy()
	_serviceTrove:Clean()
end

return PlayerService
