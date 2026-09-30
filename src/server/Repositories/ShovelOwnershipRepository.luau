--!strict

local HttpService = game:GetService("HttpService")
local PlayerProfileStore = require(script.Parent.PlayerProfileStore)

local ShovelOwnershipRepository = {}

local function GetOwnedMap(player: Player): { [string]: boolean }?
	local data = PlayerProfileStore.GetProfileData(player)
	if not data then return nil end
	if not data.ownedShovels then data.ownedShovels = {} end
	return data.ownedShovels :: { [string]: boolean }
end

local function SyncAttribute(player: Player, owned: { [string]: boolean })
	pcall(function() player:SetAttribute("OwnedShovels", HttpService:JSONEncode(owned)) end)
end

function ShovelOwnershipRepository.GetOwned(player: Player): { [string]: boolean }
	local owned = GetOwnedMap(player)
	if not owned then return {} end
	SyncAttribute(player, owned)
	return owned
end

function ShovelOwnershipRepository.Owns(player: Player, shovelId: string): boolean
	local owned = GetOwnedMap(player)
	return owned ~= nil and owned[shovelId] == true
end

function ShovelOwnershipRepository.Grant(player: Player, shovelId: string): boolean
	local owned = GetOwnedMap(player)
	if not owned then return false end
	owned[shovelId] = true
	SyncAttribute(player, owned)
	return true
end

function ShovelOwnershipRepository.GetSelected(player: Player): string?
	local data = PlayerProfileStore.GetProfileData(player)
	return if data then data.selectedShovel else nil
end

function ShovelOwnershipRepository.SetSelected(player: Player, shovelId: string): boolean
	local data = PlayerProfileStore.GetProfileData(player)
	if not data then return false end
	data.selectedShovel = shovelId
	return true
end

return ShovelOwnershipRepository
