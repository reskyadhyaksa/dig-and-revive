--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelSkinConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelSkinConfig"))
local ShovelSkinUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelSkinUtils"))

-- Builds one skin visual inside a Tool/holster: skin parts joined to the real Handle by Motor6D.
-- Accepts two asset formats in Assets.ShovelSkins:
--   * Tool: same layout as a shovel Tool. Motor6Ds inside its Handle are re-parented onto the real Handle (authored grip kept).
--   * Model: a SkinJoint Motor6D is created (C0 = config.gripOffset, C1 = optional "SkinGrip" attachment).
-- Every change is registered on the given trove, so trove:Clean() restores the default look.
local ShovelSkinRenderer = {}

local function GetSkinAsset(assetName: string): Instance?
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local folder = if assets then assets:FindFirstChild(ShovelSkinConfig.AssetFolder) else nil
	local asset = if folder then folder:FindFirstChild(assetName) else nil
	return if asset and (asset:IsA("Tool") or asset:IsA("Model")) then asset else nil
end

local function PrepareParts(root: Instance)
	for _, desc in root:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Anchored = false
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
			desc.Massless = true
		elseif desc:IsA("LuaSourceContainer") or desc:IsA("TouchTransmitter") then
			desc:Destroy()
		end
	end
end

-- Moves the authored Handle joints (those driving skin parts) onto the real Handle.
local function MoveAuthoredJoints(srcHandle: Instance, visual: Model, handle: BasePart, offset: CFrame, trove: any): number
	local moved = 0
	for _, joint in srcHandle:GetChildren() do
		if joint:IsA("Motor6D") and joint.Part1 and joint.Part1:IsDescendantOf(visual) then
			joint.Name = ShovelSkinConfig.SkinJointName
			joint.Part0 = handle
			joint.C0 = offset * joint.C0
			joint.Parent = handle
			trove:Add(joint)
			moved += 1
		end
	end
	return moved
end

local function CreateJoint(visual: Model, handle: BasePart, offset: CFrame, trove: any)
	local root = visual:FindFirstChild("Primary", true) or visual:FindFirstChildWhichIsA("BasePart", true)
	if not root or not root:IsA("BasePart") then return end
	local grip = root:FindFirstChild(ShovelSkinConfig.SkinGripAttachment)
	local joint = trove:Add(Instance.new("Motor6D")) :: Motor6D
	joint.Name = ShovelSkinConfig.SkinJointName
	joint.Part0 = handle
	joint.Part1 = root
	joint.C0 = offset
	joint.C1 = if grip and grip:IsA("Attachment") then grip.CFrame else CFrame.identity
	joint.Parent = handle
end

-- Hides the default shovel mesh locally (never the Handle, which the joints hang from).
local function HideDefault(container: Instance, handle: BasePart, visual: Model, trove: any)
	for _, desc in container:GetDescendants() do
		if desc:IsA("BasePart") and desc ~= handle and not desc:IsDescendantOf(visual) and desc.Transparency < 1 then
			local original = desc.Transparency
			desc.Transparency = 1
			trove:Add(function() if desc.Parent then desc.Transparency = original end end)
		end
	end
end

function ShovelSkinRenderer.Render(container: Instance, handle: BasePart, skinId: string, trove: any): Model?
	local skin = ShovelSkinUtils.GetSkin(skinId)
	local asset = if skin then GetSkinAsset(skin.assetName) else nil
	if not skin or not asset then
		warn(string.format("[ShovelSkin] Missing asset for skin '%s'", skinId))
		return nil
	end

	local clone = trove:Clone(asset)
	PrepareParts(clone)
	local visual = trove:Add(Instance.new("Model")) :: Model
	visual.Name = ShovelSkinConfig.SkinJointName .. "_Model"
	local srcHandle = clone:FindFirstChild("Handle")
	for _, child in clone:GetChildren() do
		if child ~= srcHandle and (child:IsA("Model") or child:IsA("BasePart") or child:IsA("Folder")) then child.Parent = visual end
	end

	local moved = if srcHandle then MoveAuthoredJoints(srcHandle, visual, handle, skin.gripOffset, trove) else 0
	if moved == 0 then CreateJoint(visual, handle, skin.gripOffset, trove) end
	clone:Destroy()

	visual.Parent = container
	HideDefault(container, handle, visual, trove)
	return visual
end

return ShovelSkinRenderer
