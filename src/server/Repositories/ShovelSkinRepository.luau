--!strict

local HttpService = game:GetService("HttpService")
local PlayerProfileStore = require(script.Parent.PlayerProfileStore)

-- Only layer that reads/writes skin data in the profile. Mirrors it to attributes for the client.
local ShovelSkinRepository = {}

local function GetData(player: Player): PlayerProfileStore.PlayerProfileData?
	local data = PlayerProfileStore.GetProfileData(player)
	if not data then return nil end
	if not data.ownedSkins then data.ownedSkins = {} end
	if not data.equippedSkins then data.equippedSkins = {} end
	return data
end

local function Sync(player: Player, name: string, value: any)
	pcall(function() player:SetAttribute(name, HttpService:JSONEncode(value)) end)
end

function ShovelSkinRepository.GetOwned(player: Player): { [string]: boolean }
	local data = GetData(player)
	local owned = if data then data.ownedSkins :: { [string]: boolean } else {}
	Sync(player, "OwnedSkins", owned)
	return owned
end

function ShovelSkinRepository.Grant(player: Player, skinId: string): boolean
	local data = GetData(player)
	if not data then return false end
	local owned = data.ownedSkins :: { [string]: boolean }
	owned[skinId] = true
	Sync(player, "OwnedSkins", owned)
	return true
end

function ShovelSkinRepository.GetEquipped(player: Player): { [string]: string }
	local data = GetData(player)
	local equipped = if data then data.equippedSkins :: { [string]: string } else {}
	Sync(player, "EquippedSkins", equipped)
	return equipped
end

-- skinId = nil restores the shovel's default model.
function ShovelSkinRepository.SetEquipped(player: Player, shovelId: string, skinId: string?): boolean
	local data = GetData(player)
	if not data then return false end
	local equipped = data.equippedSkins :: { [string]: string }
	equipped[shovelId] = skinId
	Sync(player, "EquippedSkins", equipped)
	return true
end

return ShovelSkinRepository
