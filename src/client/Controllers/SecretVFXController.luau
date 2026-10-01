--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local SecretVFXController = {}
local _activeTroves: { [Instance]: any } = {}

local function FindSecretTemplate(): Instance?
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local vfx = if assets then assets:FindFirstChild("Vfx") else nil
	return if vfx then (vfx:FindFirstChild("Secret") or vfx:FindFirstChild("Secret1")) else nil
end

local function GetGroundPosition(char: Model): (Vector3, CFrame)
	local root = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return Vector3.zero, CFrame.identity end
	local flatLook = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
	local frontPos = root.Position + (flatLook * 3.2)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	local res = Workspace:Raycast(frontPos + Vector3.new(0, 4, 0), Vector3.new(0, -15, 0), params)
	local hitPos = if res then res.Position else frontPos - Vector3.new(0, 2.5, 0)
	local surfacePos = hitPos + Vector3.new(0, 0.10, 0)
	return surfacePos, CFrame.lookAt(surfacePos, surfacePos + flatLook)
end

local function SetBranchEmitters(branch: Instance?, enabled: boolean)
	if not branch then return end
	for _, desc in branch:GetDescendants() do
		if desc:IsA("ParticleEmitter") then
			desc.Enabled = enabled
			if enabled then pcall(function() desc:Emit(1) end) end
		end
	end
	if branch:IsA("ParticleEmitter") then
		branch.Enabled = enabled
		if enabled then pcall(function() branch:Emit(1) end) end
	end
end

function SecretVFXController.PlaySecretDropVFX(playerInst: Instance)
	local char = if playerInst:IsA("Player") then playerInst.Character elseif playerInst:IsA("Model") then playerInst else nil
	if not char or not char.PrimaryPart then return end
	local template = FindSecretTemplate()
	if not template then return end

	local clone = template:Clone()
	local vfxTrove = Trove.new()
	_activeTroves[clone] = vfxTrove

	for _, desc in clone:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Anchored = true
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
		elseif desc:IsA("ParticleEmitter") then
			desc.Enabled = false
			desc.ZOffset = math.max(desc.ZOffset, 0.5)
		elseif desc:IsA("Light") then
			desc.Enabled = false
		end
	end
	local surfacePos, rotCFrame = GetGroundPosition(char)
	local floor = clone:FindFirstChild("Floor", true)
	if floor and floor:IsA("Attachment") then
		local parentPart = floor:FindFirstAncestorWhichIsA("BasePart") or clone:FindFirstChildWhichIsA("BasePart", true)
		if parentPart then
			parentPart.CFrame = rotCFrame * floor.CFrame:Inverse()
			floor.WorldCFrame = rotCFrame
		end
	elseif floor and floor:IsA("BasePart") then
		floor.CFrame = rotCFrame
	elseif clone:IsA("Model") then
		clone:PivotTo(rotCFrame)
	elseif clone:IsA("BasePart") then
		clone.CFrame = rotCFrame
	end
	clone.Parent = Workspace
	vfxTrove:Add(clone)
	task.spawn(function()
		local floorObj = clone:FindFirstChild("Floor", true)
		if floorObj then
			SetBranchEmitters(floorObj:FindFirstChild("1"), true)
			SetBranchEmitters(floorObj:FindFirstChild("2"), true)
		end
		task.wait(5)
		if not clone.Parent then return end

		for _, desc in clone:GetDescendants() do
			if desc:IsA("ParticleEmitter") then
				desc.Enabled = true
				pcall(function() desc:Emit(1) end)
			elseif desc:IsA("Light") then
				desc.Enabled = true
			end
		end
		task.wait(6)
		if not clone.Parent then return end

		for _, desc in clone:GetDescendants() do
			if desc:IsA("ParticleEmitter") or desc:IsA("Light") then desc.Enabled = false end
		end
		task.wait(2.5)
		_activeTroves[clone] = nil
		vfxTrove:Clean()
	end)
end

function SecretVFXController.Init() end
function SecretVFXController.Destroy()
	for _, t in pairs(_activeTroves) do t:Clean() end
	table.clear(_activeTroves)
end

return SecretVFXController
