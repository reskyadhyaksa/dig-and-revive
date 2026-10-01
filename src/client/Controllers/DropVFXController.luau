--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local DropUtils = require(Shared:WaitForChild("Utils"):WaitForChild("DropUtils"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local SecretVFXController = require(script.Parent:WaitForChild("SecretVFXController"))

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

local function GetGroundPosition(char: Model): Vector3
	local root = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return Vector3.zero end
	local frontPos = root.Position + (root.CFrame.LookVector * 2.8)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	local res = Workspace:Raycast(frontPos + Vector3.new(0, 3, 0), Vector3.new(0, -10, 0), params)
	return if res then res.Position else frontPos - Vector3.new(0, 2.5, 0)
end

function DropVFXController.PlaySurfaceRiseDrop(playerInst: Instance, dropId: string)
	local char = if playerInst:IsA("Player") then playerInst.Character elseif playerInst:IsA("Model") then playerInst else nil
	if not char or not char.PrimaryPart then return end

	local model = FindDropModel(dropId)
	if not model then return end

	local clone = model:Clone()
	local primary = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
	if not primary then
		clone:Destroy()
		return
	end
	clone.PrimaryPart = primary

	for _, p in clone:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
		end
	end

	local groundPos = GetGroundPosition(char)
	local initialScale = clone:GetScale()
	clone:ScaleTo(math.max(0.01, initialScale * 0.05))
	clone:PivotTo(CFrame.new(groundPos))
	clone.Parent = Workspace

	local startTime = os.clock()
	local conn: RBXScriptConnection? = nil

	conn = RunService.RenderStepped:Connect(function()
		local elapsed = os.clock() - startTime
		if elapsed < 0.85 then
			local alpha = math.clamp(elapsed / 0.85, 0, 1)
			local easeY = TweenService:GetValue(alpha, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local easeScale = TweenService:GetValue(alpha, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local currentY = groundPos.Y + (easeY * 2.5)
			local rotAngle = alpha * (math.pi * 4)
			clone:PivotTo(CFrame.new(groundPos.X, currentY, groundPos.Z) * CFrame.Angles(0, rotAngle, 0))
			clone:ScaleTo(math.max(0.01, initialScale * (0.05 + (0.95 * easeScale))))
		elseif elapsed < 1.40 then
			local popElapsed = elapsed - 0.85
			local popAlpha = math.clamp(popElapsed / 0.55, 0, 1)
			local popScale = if popAlpha < 0.20
				then (1.0 + ((popAlpha / 0.20) * 0.20))
				else math.max(0.01, 1.20 * (1 - TweenService:GetValue((popAlpha - 0.20) / 0.80, Enum.EasingStyle.Back, Enum.EasingDirection.In)))
			local rotAngle = (math.pi * 4) + (popAlpha * math.pi * 2)
			local currentY = groundPos.Y + 2.5 + (math.sin(popAlpha * math.pi) * 0.35)
			clone:PivotTo(CFrame.new(groundPos.X, currentY, groundPos.Z) * CFrame.Angles(0, rotAngle, 0))
			clone:ScaleTo(math.max(0.01, initialScale * popScale))
		else
			if conn then
				conn:Disconnect()
				conn = nil
			end
			clone:Destroy()
		end
	end)
end

function DropVFXController.Init()
	_trove:Add(DigNetwork.DigDropVFX.on(function(p, dropId)
		if p and dropId then
			DropVFXController.PlaySurfaceRiseDrop(p, dropId)
			local drop = DropUtils.GetDropItem(dropId)
			if drop and drop.tier == "Secret" then
				SecretVFXController.PlaySecretDropVFX(p)
			end
		end
	end))
end

function DropVFXController.Destroy()
	_trove:Clean()
end

return DropVFXController
