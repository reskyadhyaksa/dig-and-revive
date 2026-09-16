--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelConfig"))
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local ShovelTypes = require(Shared:WaitForChild("Types"):WaitForChild("ShovelTypes"))
local ShovelHolsterHelper = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("ShovelHolsterHelper"))

type ShovelConfigType = ShovelTypes.ShovelConfig

local ShovelService = {}
local _trove = Trove.new()
local _playerTroves: { [Player]: any } = {}
local HOLSTER_TAG = "BackHolster_"

local function UpdateHolster(player: Player, character: Model)
	local torso = (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")) :: BasePart?
	if not torso or not character.Parent then return end
	local backpack = player:FindFirstChildOfClass("Backpack")

	for shovelId, config in ShovelConfig do
		local holsterName = HOLSTER_TAG .. shovelId
		local existing = character:FindFirstChild(holsterName)
		local equipped = character:FindFirstChild(config.assetName) ~= nil
		local inBackpack = backpack and backpack:FindFirstChild(config.assetName) ~= nil

		if equipped then
			if existing then existing:Destroy() end
		elseif inBackpack then
			if not existing then ShovelHolsterHelper.AttachHolster(character, torso, config, holsterName) end
		else
			if existing then existing:Destroy() end
		end
	end
end

local function EnsureStarterShovel(player: Player, character: Model, config: ShovelConfigType)
	local backpack = player:WaitForChild("Backpack", 5) :: Backpack?
	if not backpack then return end
	if backpack:FindFirstChild(config.assetName) or character:FindFirstChild(config.assetName) then return end

	local asset = ShovelHolsterHelper.GetShovelAsset(config.assetName)
	if asset then
		local clone = asset:Clone()
		clone:SetAttribute("ShovelId", config.id)
		clone.Parent = backpack
	end
end

function ShovelService.Init()
	_trove:Connect(Players.PlayerAdded, function(p) ShovelService._OnPlayerAdded(p) end)
	_trove:Connect(Players.PlayerRemoving, function(p)
		if _playerTroves[p] then _playerTroves[p]:Clean() _playerTroves[p] = nil end
	end)
	for _, p in Players:GetPlayers() do task.spawn(function() ShovelService._OnPlayerAdded(p) end) end
end

function ShovelService._OnPlayerAdded(player: Player)
	local pTrove = _trove:Extend()
	_playerTroves[player] = pTrove

	local function onChar(char: Model)
		local cTrove = pTrove:Extend()
		local hum = char:WaitForChild("Humanoid", 10) :: Humanoid?
		if hum then cTrove:Connect(hum.Died, function() cTrove:Clean() end) end

		local starter = ShovelUtils.GetStarterShovel()
		if starter then EnsureStarterShovel(player, char, starter) end

		local backpack = player:WaitForChild("Backpack", 5) :: Backpack?
		if backpack then
			local function onChange()
				UpdateHolster(player, char)
				local PlayerService = require(script.Parent:WaitForChild("PlayerService"))
				PlayerService.SyncPlayerStats(player)
			end
			cTrove:Connect(backpack.ChildAdded, onChange)
			cTrove:Connect(backpack.ChildRemoved, onChange)
			cTrove:Connect(char.ChildAdded, onChange)
			cTrove:Connect(char.ChildRemoved, onChange)
			task.defer(onChange)
		end
	end

	pTrove:Connect(player.CharacterAdded, onChar)
	if player.Character then task.spawn(function() onChar(player.Character :: Model) end) end
end

function ShovelService.Destroy()
	_trove:Clean()
	table.clear(_playerTroves)
end

return ShovelService
