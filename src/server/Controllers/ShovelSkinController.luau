--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local ShovelSkinConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("ShovelSkinConfig"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local ShovelSkinService = require(script.Parent.Parent:WaitForChild("Services"):WaitForChild("ShovelSkinService"))

-- Network edge for skins: rate-limits requests and routes them to ShovelSkinService.
local ShovelSkinController = {}
local _trove = Trove.new()
local _lastRequest: { [Player]: number } = {}

local function Allow(player: Player): boolean
	local now = os.clock()
	if now - (_lastRequest[player] or 0) < ShovelSkinConfig.RequestCooldown then return false end
	_lastRequest[player] = now
	return true
end

function ShovelSkinController.Init()
	_trove:Add(DigNetwork.BuySkinRequest.on(function(player: Player, skinId: string)
		if not Allow(player) then return end
		local result = ShovelSkinService.Purchase(player, skinId)
		DigNetwork.SkinResult.fire(player, result.ok, result.skinId, result.reason or "Purchased")
	end))

	_trove:Add(DigNetwork.EquipSkinRequest.on(function(player: Player, shovelId: string, skinId: string?)
		if not Allow(player) then return end
		local result = ShovelSkinService.Equip(player, shovelId, skinId)
		DigNetwork.SkinResult.fire(player, result.ok, result.skinId, result.reason or (if skinId then "Equipped" else "Unequipped"))
	end))

	_trove:Connect(Players.PlayerRemoving, function(player) _lastRequest[player] = nil end)
end

function ShovelSkinController.Destroy()
	_trove:Clean()
end

return ShovelSkinController
