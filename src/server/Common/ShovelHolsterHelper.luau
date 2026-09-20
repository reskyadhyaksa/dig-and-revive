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

function ShovelHolsterHelper.CreateFallbackTool(config: ShovelConfigType): Tool
	local tool = Instance.new("Tool")
	tool.Name = config.assetName
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool:SetAttribute("ShovelId", config.id)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.5, 3.2, 0.5)
	handle.Material = Enum.Material.Wood
	handle.Color = Color3.fromRGB(139, 90, 43)
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	return tool
end

function ShovelHolsterHelper.GetOrCreateShovelAsset(config: ShovelConfigType): Tool
	local asset = ShovelHolsterHelper.GetShovelAsset(config.assetName)
	return if asset then asset:Clone() else ShovelHolsterHelper.CreateFallbackTool(config)
end

function ShovelHolsterHelper.AttachHolster(character: Model, torso: BasePart, config: ShovelConfigType, holsterName: string)
	local holsterModel = Instance.new("Model")
	holsterModel.Name = holsterName

	local clonedTool = ShovelHolsterHelper.GetOrCreateShovelAsset(config)
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
	local primaryPart: BasePart? = if backholster and backholster.Parent and backholster.Parent:IsA("BasePart")
		then backholster.Parent :: BasePart
		else (holsterModel:FindFirstChild("Handle") or holsterModel:FindFirstChildWhichIsA("BasePart", true)) :: BasePart?

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
	holsterMotor.C1 = if backholster then backholster.CFrame else CFrame.new()
	holsterMotor.Parent = primaryPart
	holsterModel.Parent = character
end

return ShovelHolsterHelper
