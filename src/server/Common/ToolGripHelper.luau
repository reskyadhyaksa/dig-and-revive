--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShovelSkinConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("ShovelSkinConfig"))

-- Swaps the Humanoid's RightGrip Weld for a Motor6D (RightHand -> Handle) so animations can move the tool.
-- Runs on the server so the joint exists on every client; the Animator drives it by Part1 name ("Handle").
local ToolGripHelper = {}

local function FindArmJoint(handle: BasePart): Motor6D
	local named = handle:FindFirstChild(ShovelSkinConfig.ArmJointName)
	if named and named:IsA("Motor6D") then return named end
	-- Reuse the asset's pre-built arm joint (Part1 = Handle, Part0 empty) when it exists.
	for _, child in handle:GetChildren() do
		if child:IsA("Motor6D") and child.Part1 == handle then
			child.Name = ShovelSkinConfig.ArmJointName
			return child
		end
	end
	local motor = Instance.new("Motor6D")
	motor.Name = ShovelSkinConfig.ArmJointName
	motor.Part1 = handle
	motor.Parent = handle
	return motor
end

-- Call once RightGrip exists. Keeps the exact grip pose so un-animated tools look identical.
function ToolGripHelper.ReplaceGrip(grip: Weld, tool: Tool)
	local handle = tool:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") or grip.Part1 ~= handle then return end
	local motor = FindArmJoint(handle)
	motor.Part0 = grip.Part0
	motor.C0 = grip.C0
	motor.C1 = grip.C1
	grip:Destroy()
end

-- Tool left the hand: detach the joint so the Handle is free for the holster/backpack.
function ToolGripHelper.Release(tool: Tool)
	local handle = tool:FindFirstChild("Handle")
	local motor = if handle then handle:FindFirstChild(ShovelSkinConfig.ArmJointName) else nil
	if motor and motor:IsA("Motor6D") then motor.Part0 = nil end
end

return ToolGripHelper
