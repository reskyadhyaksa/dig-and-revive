--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))

local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))

local DropVFXController = {}
DropVFXController.__index = DropVFXController

local _controllerTrove = Trove.new()

function DropVFXController.Init()
	local disconnect = DigNetwork.DigDropVFX.on(function(playerInstance: Instance, dropId: string)
		if playerInstance and dropId then
			DropVFXController.PlayParabolicDrop(playerInstance, dropId)
		end
	end)

	_controllerTrove:Add(disconnect)
end

function DropVFXController.PlayParabolicDrop(playerInstance: Instance, dropId: string)
	local char: Model? = nil
	if playerInstance:IsA("Player") then
		char = playerInstance.Character
	elseif playerInstance:IsA("Model") then
		char = playerInstance
	end

	if not char then return end

	local rootPart: BasePart? = char.PrimaryPart
	if not rootPart then return end

	local upperTorsoPart: Instance? = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or rootPart
	if not upperTorsoPart or not upperTorsoPart:IsA("BasePart") then return end
	local upperTorso: BasePart = upperTorsoPart

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local dropAssetsFolder = assets and assets:FindFirstChild("Drops")
	if not dropAssetsFolder then return end

	-- Find item model in Island folders or root drops folder
	local itemModel: Model? = nil
	for _, folder in dropAssetsFolder:GetChildren() do
		local found = folder:FindFirstChild(dropId)
		if found and found:IsA("Model") then
			itemModel = found
			break
		end
	end

	if not itemModel then
		local found = dropAssetsFolder:FindFirstChild(dropId)
		if found and found:IsA("Model") then
			itemModel = found
		end
	end

	if not itemModel then return end

	local clone = itemModel:Clone()

	-- Ensure PrimaryPart exists
	local foundPart: BasePart? = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
	if not foundPart then
		clone:Destroy()
		return
	end

	local primaryPart: BasePart = foundPart
	clone.PrimaryPart = primaryPart

	-- Weld all parts to primaryPart and configure collision/physics
	local dropParts: { BasePart } = {}
	for _, desc in clone:GetDescendants() do
		if desc:IsA("BasePart") then
			table.insert(dropParts, desc)
			desc.Anchored = false
			desc.CanCollide = true
			desc.CanTouch = false
			desc.CanQuery = false
			desc.CastShadow = true

			if desc ~= primaryPart and not desc:FindFirstChildWhichIsA("WeldConstraint") then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = primaryPart
				weld.Part1 = desc
				weld.Parent = primaryPart
			end
		end
	end

	-- Prevent physical collision with character parts so player isn't pushed
	for _, charChild in char:GetDescendants() do
		if charChild:IsA("BasePart") then
			for _, dropPart in dropParts do
				local noColl = Instance.new("NoCollisionConstraint")
				noColl.Part0 = charChild
				noColl.Part1 = dropPart
				noColl.Parent = clone
			end
		end
	end

	-- Spawn Position: Right behind player's upper torso
	local spawnPos = upperTorso.Position - (rootPart.CFrame.LookVector * 1.5) + Vector3.new(0, 0.8, 0)
	local randomYaw = math.rad(math.random(0, 360))
	clone:PivotTo(CFrame.new(spawnPos) * CFrame.Angles(0, randomYaw, 0))

	clone.Parent = Workspace

	-- Physical launch force: Throw backward and upward with natural ragdoll/tumble spin
	local spreadX = math.random(-30, 30) / 100
	local spreadZ = math.random(-30, 30) / 100
	local backDir = (-rootPart.CFrame.LookVector + Vector3.new(spreadX, 0, spreadZ)).Unit

	local forwardSpeed = math.random(14, 22)
	local upwardSpeed = math.random(22, 32)
	local launchVelocity = (backDir * forwardSpeed) + Vector3.new(0, upwardSpeed, 0)

	local randomTorque = Vector3.new(
		math.random(-25, 25),
		math.random(-25, 25),
		math.random(-25, 25)
	)

	primaryPart.AssemblyLinearVelocity = launchVelocity
	primaryPart.AssemblyAngularVelocity = randomTorque

	local dropTrove = _controllerTrove:Extend()
	dropTrove:Add(clone)

	-- Shrink & Clean up after 6 seconds
	task.delay(5.0, function()
		local shrinkInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		for _, part in dropParts do
			TweenService:Create(part, shrinkInfo, {
				Size = Vector3.new(0.01, 0.01, 0.01),
				Transparency = 1,
			}):Play()
		end

		task.delay(1.0, function()
			dropTrove:Clean()
		end)
	end)
end

function DropVFXController.Destroy()
	_controllerTrove:Clean()
end

return DropVFXController
