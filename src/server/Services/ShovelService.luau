--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelConfig"))
local ShovelTypes = require(Shared:WaitForChild("Types"):WaitForChild("ShovelTypes"))

type ShovelConfigType = ShovelTypes.ShovelConfig

local ShovelService = {}
ShovelService.__index = ShovelService

local _serviceTrove = Trove.new()
local _playerTroves: { [Player]: any } = {}

local HOLSTER_MODEL_TAG = "BackHolster_"

function ShovelService.Init()
	_serviceTrove:Connect(Players.PlayerAdded, function(player: Player)
		ShovelService._OnPlayerAdded(player)
	end)

	_serviceTrove:Connect(Players.PlayerRemoving, function(player: Player)
		ShovelService._OnPlayerRemoving(player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			ShovelService._OnPlayerAdded(player)
		end)
	end
end

function ShovelService._OnPlayerAdded(player: Player)
	local playerTrove = _serviceTrove:Extend()
	_playerTroves[player] = playerTrove

	local function onCharacterAdded(character: Model)
		local charTrove = playerTrove:Extend()

		-- Wait for humanoid and torso
		local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
		local torso = (character:WaitForChild("UpperTorso", 5) or character:WaitForChild("Torso", 5)) :: BasePart?

		if not humanoid or not torso then
			return
		end

		-- Clean up character trove on death
		charTrove:Connect(humanoid.Died, function()
			charTrove:Clean()
		end)

		-- Give Starter Shovel to Backpack if player doesn't have one
		local starterConfig = ShovelConfig.GetStarterShovel()
		if starterConfig then
			ShovelService._EnsurePlayerHasShovel(player, character, starterConfig)
		end

		-- Setup Shovel Tracking (Equip / Unequip Holster)
		ShovelService._BindPlayerShovels(player, character, charTrove)
	end

	playerTrove:Connect(player.CharacterAdded, onCharacterAdded)
	if player.Character then
		task.spawn(function()
			onCharacterAdded(player.Character :: Model)
		end)
	end
end

function ShovelService._OnPlayerRemoving(player: Player)
	local trove = _playerTroves[player]
	if trove then
		trove:Clean()
		_playerTroves[player] = nil
	end
end

function ShovelService._GetShovelAsset(assetName: string): Tool?
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	if not assets then
		return nil
	end

	local shovels = assets:FindFirstChild("Shovels")
	if not shovels then
		return nil
	end

	local tool = shovels:FindFirstChild(assetName)
	if tool and tool:IsA("Tool") then
		return tool
	end

	return nil
end

function ShovelService._EnsurePlayerHasShovel(player: Player, character: Model, config: ShovelConfigType)
	local backpack = player:WaitForChild("Backpack", 5)
	if not backpack then
		return
	end

	-- Check if player already has this shovel in backpack or character
	local hasInBackpack = backpack:FindFirstChild(config.assetName)
	local hasInCharacter = character:FindFirstChild(config.assetName)

	if not hasInBackpack and not hasInCharacter then
		local shovelAsset = ShovelService._GetShovelAsset(config.assetName)
		if shovelAsset then
			local clonedTool = shovelAsset:Clone()
			clonedTool:SetAttribute("ShovelId", config.id)
			clonedTool.Parent = backpack
		else
			-- Listen in case Assets folder loads dynamically
			local assetsConn: RBXScriptConnection? = nil
			assetsConn = ReplicatedStorage.DescendantAdded:Connect(function(descendant)
				if descendant.Name == config.assetName and descendant:IsA("Tool") then
					if not backpack:FindFirstChild(config.assetName) and not character:FindFirstChild(config.assetName) then
						local cloned = descendant:Clone()
						cloned:SetAttribute("ShovelId", config.id)
						cloned.Parent = backpack
					end
					if assetsConn then
						assetsConn:Disconnect()
						assetsConn = nil
					end
				end
			end)
		end
	end
end

function ShovelService._BindPlayerShovels(player: Player, character: Model, charTrove: any)
	local backpack = player:WaitForChild("Backpack", 5) :: Backpack?
	if not backpack then
		return
	end

	local function onToolStateChanged()
		ShovelService._UpdateHolsterState(player, character)
		local PlayerService = require(script.Parent:WaitForChild("PlayerService"))
		PlayerService.SyncPlayerStats(player)
	end

	-- Listen for tools moving between Backpack and Character
	charTrove:Connect(backpack.ChildAdded, onToolStateChanged)
	charTrove:Connect(backpack.ChildRemoved, onToolStateChanged)
	charTrove:Connect(character.ChildAdded, onToolStateChanged)
	charTrove:Connect(character.ChildRemoved, onToolStateChanged)

	-- Initial update
	task.defer(function()
		ShovelService._UpdateHolsterState(player, character)
	end)
end

function ShovelService._UpdateHolsterState(player: Player, character: Model)
	local torso = (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")) :: BasePart?
	if not torso or not character.Parent then
		return
	end

	local backpack = player:FindFirstChildOfClass("Backpack")

	-- Check each configured shovel
	for shovelId, config in ShovelConfig.Shovels do
		local holsterName = HOLSTER_MODEL_TAG .. shovelId
		local existingHolster = character:FindFirstChild(holsterName)

		local isEquippedInCharacter = character:FindFirstChild(config.assetName) ~= nil
		local isInBackpack = backpack and backpack:FindFirstChild(config.assetName) ~= nil

		if isEquippedInCharacter then
			-- Shovel is currently held in hand -> Remove back holster
			if existingHolster then
				existingHolster:Destroy()
			end
		elseif isInBackpack then
			-- Shovel is unequipped in backpack -> Attach to back if not present
			if not existingHolster then
				ShovelService._AttachHolster(character, torso, config, holsterName)
			end
		else
			-- Player does not have this shovel at all -> Remove holster
			if existingHolster then
				existingHolster:Destroy()
			end
		end
	end
end

function ShovelService._AttachHolster(character: Model, torso: BasePart, config: ShovelConfigType, holsterName: string)
	local toolAsset = ShovelService._GetShovelAsset(config.assetName)
	if not toolAsset then
		return
	end

	local holsterModel = Instance.new("Model")
	holsterModel.Name = holsterName

	local clonedTool = toolAsset:Clone()

	-- Clean up scripts and make visual parts non-collidable
	for _, desc in clonedTool:GetDescendants() do
		if desc:IsA("LuaSourceContainer") or desc:IsA("TouchTransmitter") then
			desc:Destroy()
		elseif desc:IsA("BasePart") then
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
			desc.Massless = true
			desc.CastShadow = false
			desc.Anchored = false
		end
	end

	-- Move all visual elements to holsterModel
	for _, child in clonedTool:GetChildren() do
		child.Parent = holsterModel
	end
	clonedTool:Destroy()

	-- Find Backholster Attachment inside tool hierarchy (defines center pivot of the shovel)
	local backholsterAttachment = holsterModel:FindFirstChild("Backholster", true) :: Attachment?

	local primaryPart: BasePart? = nil
	local c1Offset = CFrame.new()

	if backholsterAttachment then
		if backholsterAttachment.Parent and backholsterAttachment.Parent:IsA("BasePart") then
			primaryPart = backholsterAttachment.Parent :: BasePart
		end
		c1Offset = backholsterAttachment.CFrame
	end

	if not primaryPart then
		primaryPart = (holsterModel:FindFirstChild("Handle") or holsterModel:FindFirstChildWhichIsA("BasePart", true)) :: BasePart?
	end

	if not primaryPart then
		holsterModel:Destroy()
		return
	end

	holsterModel.PrimaryPart = primaryPart

	-- Attach to torso using Motor6D with Backholster Attachment C1 offset
	local holsterMotor = Instance.new("Motor6D")
	holsterMotor.Name = "HolsterJoint"
	holsterMotor.Part0 = torso
	holsterMotor.Part1 = primaryPart
	holsterMotor.C0 = config.holsterOffset
	holsterMotor.C1 = c1Offset
	holsterMotor.Parent = primaryPart

	holsterModel.Parent = character
end

function ShovelService.Destroy()
	_serviceTrove:Clean()
	table.clear(_playerTroves)
end

return ShovelService
