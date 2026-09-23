--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DropUtils = require(ReplicatedStorage.Shared.Utils.DropUtils)
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type InventoryItem = InventoryTypes.InventoryItem

local ItemToolHelper = {}

local function SearchFolder(folder: Instance?, name: string): Instance?
	if not folder then return nil end
	local direct = folder:FindFirstChild(name)
	if direct then return direct end

	for _, sub in ipairs(folder:GetChildren()) do
		local found = sub:FindFirstChild(name)
		if found then return found end
	end
	return nil
end

function ItemToolHelper.FindItemAsset(itemId: string): Instance?
	local assets = ReplicatedStorage:FindFirstChild("Assets") :: Instance?
	if not assets then return nil end

	local dropAsset = SearchFolder(assets:FindFirstChild("Drops"), itemId)
	if dropAsset then return dropAsset end

	local revivalAsset = SearchFolder(assets:FindFirstChild("Revival"), itemId)
	if revivalAsset then return revivalAsset end

	local itemAsset = SearchFolder(assets:FindFirstChild("Items"), itemId)
	if itemAsset then return itemAsset end

	return assets:FindFirstChild(itemId)
end

local function PrepPartsForTool(parent: Instance, handle: BasePart)
	for _, desc in ipairs(parent:GetDescendants()) do
		if desc:IsA("LuaSourceContainer") or desc:IsA("TouchTransmitter") then
			desc:Destroy()
		elseif desc:IsA("BasePart") then
			desc.Anchored = false
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
			desc.Massless = true
			if desc ~= handle then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = handle
				weld.Part1 = desc
				weld.Parent = handle
			end
		end
	end
end

function ItemToolHelper.CreateItemTool(item: InventoryItem): Tool
	local tool = Instance.new("Tool")
	tool.Name = item.displayName
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool:SetAttribute("UniqueId", item.id)
	tool:SetAttribute("ItemId", item.templateId or item.id)

	local mult = DropUtils.CalculateScaleMultiplier(item.templateId or item.id, item.weight)
	local asset = ItemToolHelper.FindItemAsset(item.templateId or item.id)

	local baseScale = 1.0
	if asset and asset:IsA("Model") then
		pcall(function() baseScale = (asset :: any):GetScale() or 1.0 end)
	end
	local finalScale = baseScale * mult

	tool:SetAttribute("Scale", finalScale)
	tool:SetAttribute("ScaleMultiplier", mult)
	tool:SetAttribute("Weight", item.weight or 1.0)

	local handle: BasePart

	if asset and asset:IsA("Model") then
		local cloned = asset:Clone()
		pcall(function() cloned:ScaleTo(finalScale) end)

		local primary = cloned:FindFirstChild("Handle") or cloned.PrimaryPart or cloned:FindFirstChildWhichIsA("BasePart")
		if primary and primary:IsA("BasePart") then
			primary.Name = "Handle"
			handle = primary
		else
			handle = Instance.new("Part")
			handle.Name = "Handle"
			handle.Size = Vector3.new(0.5, 0.5, 0.5) * finalScale
			handle.Transparency = 1
			handle.Parent = cloned
		end

		PrepPartsForTool(cloned, handle)
		for _, child in ipairs(cloned:GetChildren()) do child.Parent = tool end
		cloned:Destroy()
	elseif asset and asset:IsA("BasePart") then
		local cloned = asset:Clone()
		cloned.Name = "Handle"
		cloned.Size = cloned.Size * finalScale
		PrepPartsForTool(cloned, cloned)
		cloned.Parent = tool
	else
		handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(1, 1, 1) * finalScale
		handle.Material = Enum.Material.SmoothPlastic
		handle.Color = Color3.fromRGB(200, 185, 160)
		PrepPartsForTool(handle, handle)
		handle.Parent = tool
	end

	return tool
end

return ItemToolHelper
