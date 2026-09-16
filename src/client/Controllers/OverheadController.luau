--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))

local OverheadTagFactory = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("Common"):WaitForChild("OverheadTagFactory"))

local OverheadController = {}
OverheadController.__index = OverheadController

local _controllerTrove = Trove.new()
local _playerTroves: { [Player]: any } = {}

function OverheadController.Init()
	_controllerTrove:Connect(Players.PlayerAdded, function(player: Player)
		OverheadController._OnPlayerAdded(player)
	end)

	_controllerTrove:Connect(Players.PlayerRemoving, function(player: Player)
		OverheadController._OnPlayerRemoving(player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			OverheadController._OnPlayerAdded(player)
		end)
	end
end

function OverheadController._OnPlayerAdded(player: Player)
	local playerTrove = _controllerTrove:Extend()
	_playerTroves[player] = playerTrove

	local function onCharacterAdded(character: Model)
		local charTrove = playerTrove:Extend()

		local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
		local head = character:WaitForChild("Head", 10) :: BasePart?

		if not humanoid or not head then
			return
		end

		-- Hide default Roblox overhead names to prevent visual collision
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		-- Clean up overhead when character dies
		charTrove:Connect(humanoid.Died, function()
			charTrove:Clean()
		end)

		local initialLevel = player:GetAttribute("Level")
		local currentLevel = if typeof(initialLevel) == "number" then initialLevel else 1
		local displayName = player.DisplayName or player.Name

		local tagHandle = OverheadTagFactory.CreateOverheadTag(head, displayName, currentLevel)
		charTrove:Add(tagHandle.billboard)

		-- Listen for live level updates via replicated player attributes
		charTrove:Connect(player:GetAttributeChangedSignal("Level"), function()
			local newLvl = player:GetAttribute("Level")
			if typeof(newLvl) == "number" then
				tagHandle.updateLevel(newLvl)
			end
		end)
	end

	playerTrove:Connect(player.CharacterAdded, onCharacterAdded)
	if player.Character then
		task.spawn(function()
			onCharacterAdded(player.Character :: Model)
		end)
	end
end

function OverheadController._OnPlayerRemoving(player: Player)
	local trove = _playerTroves[player]
	if trove then
		trove:Clean()
		_playerTroves[player] = nil
	end
end

function OverheadController.Destroy()
	_controllerTrove:Clean()
	table.clear(_playerTroves)
end

return OverheadController
