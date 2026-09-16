--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))

local DropVFXController = {}
local _trove = Trove.new()

local function FindDropModel(dropId: string): Model?
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local drops = if assets then assets:FindFirstChild("Drops") else nil
	if not drops then return nil end
	for _, f in drops:GetChildren() do
		local m = f:FindFirstChild(dropId)
		if m and m:IsA("Model") then return m end
	end
	local direct = drops:FindFirstChild(dropId)
	return if direct and direct:IsA("Model") then direct else nil
end

local function SetupDropParts(clone: Model, primaryPart: BasePart, char: Model): { BasePart }
	local parts: { BasePart } = {}
	for _, desc in clone:GetDescendants() do
		if desc:IsA("BasePart") then
			table.insert(parts, desc)
			desc.Anchored = false
			desc.CanCollide = true
			desc.CanTouch = false
			desc.CanQuery = false
			if desc ~= primaryPart and not desc:FindFirstChildWhichIsA("WeldConstraint") then
				local w = Instance.new("WeldConstraint")
				w.Part0 = primaryPart
				w.Part1 = desc
				w.Parent = primaryPart
			end
		end
	end
	for _, c in char:GetDescendants() do
		if c:IsA("BasePart") then
			for _, p in parts do
				local noColl = Instance.new("NoCollisionConstraint")
				noColl.Part0 = c
				noColl.Part1 = p
				noColl.Parent = clone
			end
		end
	end
	return parts
end

function DropVFXController.PlayParabolicDrop(playerInst: Instance, dropId: string)
	local char = if playerInst:IsA("Player") then playerInst.Character elseif playerInst:IsA("Model") then playerInst else nil
	if not char or not char.PrimaryPart then return end
	local root = char.PrimaryPart
	local torso = (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or root) :: BasePart

	local model = FindDropModel(dropId)
	if not model then return end

	local clone = model:Clone()
	local primary = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
	if not primary then clone:Destroy() return end
	clone.PrimaryPart = primary

	local parts = SetupDropParts(clone, primary, char)
	local spawnPos = torso.Position - (root.CFrame.LookVector * 1.5) + Vector3.new(0, 0.8, 0)
	clone:PivotTo(CFrame.new(spawnPos) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0))
	clone.Parent = Workspace

	local spread = Vector3.new(math.random(-30, 30) / 100, 0, math.random(-30, 30) / 100)
	local backDir = (-root.CFrame.LookVector + spread).Unit
	primary.AssemblyLinearVelocity = (backDir * math.random(14, 22)) + Vector3.new(0, math.random(22, 32), 0)
	primary.AssemblyAngularVelocity = Vector3.new(math.random(-25, 25), math.random(-25, 25), math.random(-25, 25))

	task.delay(5.0, function()
		local tInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		for _, p in parts do
			TweenService:Create(p, tInfo, { Size = Vector3.new(0.01, 0.01, 0.01), Transparency = 1 }):Play()
		end
		task.delay(1.0, function() clone:Destroy() end)
	end)
end

function DropVFXController.Init()
	_trove:Add(DigNetwork.DigDropVFX.on(function(p, dropId)
		if p and dropId then DropVFXController.PlayParabolicDrop(p, dropId) end
	end))
end

function DropVFXController.Destroy()
	_trove:Clean()
end

return DropVFXController
