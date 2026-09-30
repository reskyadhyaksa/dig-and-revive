--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local ToolGripHelper = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("ToolGripHelper"))

-- Converts every shovel's RightGrip into an animatable Motor6D for all characters.
local ToolGripService = {}
local _trove = Trove.new()
local _playerTroves: { [Player]: any } = {}

local function IsShovel(inst: Instance?): boolean
	return inst ~= nil and inst:IsA("Tool") and inst:GetAttribute("ShovelId") ~= nil
end

local function OnGripAdded(char: Model, grip: Instance)
	if grip.Name ~= "RightGrip" or not grip:IsA("Weld") then return end
	local handle = (grip :: Weld).Part1
	local tool = if handle then handle.Parent else nil
	if tool and tool.Parent == char and IsShovel(tool) then
		-- Defer so the Humanoid finishes its own equip step before the weld is swapped.
		task.defer(ToolGripHelper.ReplaceGrip, grip :: Weld, tool :: Tool)
	end
end

local function OnCharacter(pTrove: any, char: Model)
	local cTrove = pTrove:Extend()
	cTrove:Connect(char.AncestryChanged, function(_, parent) if not parent then pTrove:Remove(cTrove) end end)

	local function watchHand(hand: Instance)
		if hand.Name ~= "RightHand" and hand.Name ~= "Right Arm" then return end
		cTrove:Connect(hand.ChildAdded, function(child) OnGripAdded(char, child) end)
	end
	for _, part in char:GetChildren() do watchHand(part) end
	cTrove:Connect(char.ChildAdded, watchHand)
	cTrove:Connect(char.ChildRemoved, function(child)
		if IsShovel(child) then ToolGripHelper.Release(child :: Tool) end
	end)
end

local function OnPlayerAdded(player: Player)
	local pTrove = _trove:Extend()
	_playerTroves[player] = pTrove
	pTrove:Connect(player.CharacterAdded, function(char) OnCharacter(pTrove, char) end)
	if player.Character then OnCharacter(pTrove, player.Character) end
end

function ToolGripService.Init()
	_trove:Connect(Players.PlayerAdded, OnPlayerAdded)
	_trove:Connect(Players.PlayerRemoving, function(player)
		local pTrove = _playerTroves[player]
		_playerTroves[player] = nil
		if pTrove then _trove:Remove(pTrove) end
	end)
	for _, player in Players:GetPlayers() do OnPlayerAdded(player) end
end

function ToolGripService.Destroy()
	_trove:Clean()
	table.clear(_playerTroves)
end

return ToolGripService
