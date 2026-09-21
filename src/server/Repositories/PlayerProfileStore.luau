--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerPackages = ServerScriptService:WaitForChild("ServerPackages")
local ProfileService = require(ServerPackages:WaitForChild("ProfileService"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local LevelTypes = require(Shared:WaitForChild("Types"):WaitForChild("LevelTypes"))

export type PlayerProfileData = LevelTypes.PlayerProfileData

local ProfileTemplate: PlayerProfileData = {
	level = 1,
	exp = 0,
	coins = 0,
	discoveredIndex = {},
	inventory = {},
}

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData_v1",
	ProfileTemplate
)

local PlayerProfileStore = {}
PlayerProfileStore.__index = PlayerProfileStore

local _profiles: { [Player]: any } = {}

function PlayerProfileStore.LoadProfile(player: Player): PlayerProfileData?
	local profileKey = "Player_" .. tostring(player.UserId)
	local profile = ProfileStore:LoadProfileAsync(profileKey)

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			_profiles[player] = nil
			player:Kick("Sesi Anda dimuat di tempat lain.")
		end)

		if player:IsDescendantOf(Players) then
			_profiles[player] = profile
			return profile.Data
		else
			profile:Release()
			return nil
		end
	else
		player:Kick("Gagal memuat data profil. Silakan hubungkan kembali.")
		return nil
	end
end

function PlayerProfileStore.ReleaseProfile(player: Player)
	local profile = _profiles[player]
	if profile ~= nil then
		profile:Release()
		_profiles[player] = nil
	end
end

function PlayerProfileStore.GetProfileData(player: Player): PlayerProfileData?
	local profile = _profiles[player]
	if profile ~= nil then
		return profile.Data
	end
	return nil
end

function PlayerProfileStore.SetLevelAndExp(player: Player, level: number, exp: number)
	local profile = _profiles[player]
	if profile ~= nil then
		profile.Data.level = level
		profile.Data.exp = exp
	end
end

function PlayerProfileStore.AddCoins(player: Player, amount: number): number
	local profile = _profiles[player]
	if profile ~= nil then
		profile.Data.coins = math.max(0, profile.Data.coins + amount)
		return profile.Data.coins
	end
	return 0
end

function PlayerProfileStore.GetCoins(player: Player): number
	local profile = _profiles[player]
	if profile ~= nil then
		return profile.Data.coins or 0
	end
	return 0
end

return PlayerProfileStore
