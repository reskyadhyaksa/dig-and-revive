--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelSkinConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelSkinConfig"))
local ShovelSkinUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelSkinUtils"))

-- Builds one skin visual inside a Tool/holster: skin model welded to the Handle by a Motor6D.
-- Every change it makes is registered on the given trove, so trove:Clean() restores the default look.
local ShovelSkinRenderer = {}

local function GetSkinAsset(assetName: string): Model?
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local folder = if assets then assets:FindFirstChild(ShovelSkinConfig.AssetFolder) else nil
	local model = if folder then folder:FindFirstChild(assetName) else nil
	return if model and model:IsA("Model") then model else nil
end

local function PrepareParts(model: Model)
	for _, desc in model:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Anchored = false
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
			desc.Massless = true
		elseif desc:IsA("LuaSourceContainer") then
			desc:Destroy()
		end
	end
end

-- Hides the default shovel mesh locally (never the Handle, which the joints hang from).
local function HideDefault(container: Instance, handle: BasePart, skin: Model, trove: any)
	for _, desc in container:GetDescendants() do
		if desc:IsA("BasePart") and desc ~= handle and not desc:IsDescendantOf(skin) and desc.Transparency < 1 then
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

	local model = trove:Clone(asset) :: Model
	local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if not root then return nil end
	PrepareParts(model)

	local grip = root:FindFirstChild(ShovelSkinConfig.SkinGripAttachment)
	local joint = trove:Add(Instance.new("Motor6D")) :: Motor6D
	joint.Name = ShovelSkinConfig.SkinJointName
	joint.Part0 = handle
	joint.Part1 = root
	joint.C0 = skin.gripOffset
	joint.C1 = if grip and grip:IsA("Attachment") then grip.CFrame else CFrame.identity
	joint.Parent = handle

	model.Name = ShovelSkinConfig.SkinJointName .. "_Model"
	model.Parent = container
	HideDefault(container, handle, model, trove)
	return model
end

return ShovelSkinRenderer
