--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShovelTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("ShovelTypes"))

type ShovelConfigType = ShovelTypes.ShovelConfig

local ShovelHolsterHelper = {}

function ShovelHolsterHelper.GetShovelAsset(assetName: string): Tool?
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local shovels = if assets then assets:FindFirstChild("Shovels") else nil
	local tool = if shovels then shovels:FindFirstChild(assetName) else nil
	return if tool and tool:IsA("Tool") then tool else nil
end

function ShovelHolsterHelper.AttachHolster(character: Model, torso: BasePart, config: ShovelConfigType, holsterName: string)
	local toolAsset = ShovelHolsterHelper.GetShovelAsset(config.assetName)
	if not toolAsset then return end

	local holsterModel = Instance.new("Model")
	holsterModel.Name = holsterName

	local clonedTool = toolAsset:Clone()
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

	for _, child in clonedTool:GetChildren() do
		child.Parent = holsterModel
	end
	clonedTool:Destroy()

	local backholster = holsterModel:FindFirstChild("Backholster", true) :: Attachment?
	local primaryPart: BasePart? = nil
	local c1Offset = CFrame.new()

	if backholster and backholster.Parent and backholster.Parent:IsA("BasePart") then
		primaryPart = backholster.Parent :: BasePart
		c1Offset = backholster.CFrame
	else
		primaryPart = (holsterModel:FindFirstChild("Handle") or holsterModel:FindFirstChildWhichIsA("BasePart", true)) :: BasePart?
	end

	if not primaryPart then
		holsterModel:Destroy()
		return
	end

	holsterModel.PrimaryPart = primaryPart

	local holsterMotor = Instance.new("Motor6D")
	holsterMotor.Name = "HolsterJoint"
	holsterMotor.Part0 = torso
	holsterMotor.Part1 = primaryPart
	holsterMotor.C0 = config.holsterOffset
	holsterMotor.C1 = c1Offset
	holsterMotor.Parent = primaryPart

	holsterModel.Parent = character
end

return ShovelHolsterHelper
