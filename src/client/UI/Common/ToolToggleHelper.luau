--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)
local DigNetwork = require(script.Parent.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))

type InventoryItem = InventoryTypes.InventoryItem

local ToolToggleHelper = {}

-- Toggles the tool matching the item's UniqueId, or the first shovel when no item is given.
function ToolToggleHelper.Toggle(item: InventoryItem?)
	local p = Players.LocalPlayer
	local char = if p then p.Character else nil
	local bp = if p then p:FindFirstChildOfClass("Backpack") else nil
	local hum = if char then char:FindFirstChildOfClass("Humanoid") else nil
	if not p or not char or not hum or not bp then return end

	if item then
		local heldInChar: Tool? = nil
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("UniqueId") == item.id then heldInChar = child break end
		end
		if heldInChar then hum:UnequipTools() else
			for _, child in ipairs(bp:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("UniqueId") == item.id then hum:EquipTool(child) break end
			end
		end
	else
		local tool = char:FindFirstChildWhichIsA("Tool")
		if tool then hum:UnequipTools() else
			local shovel: Tool? = nil
			for _, child in ipairs(bp:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("ShovelId") then shovel = child break end
			end
			if shovel then hum:EquipTool(shovel) end
		end
	end
end

-- Equips/holsters an inventory shovel, or asks the server to switch the active shovel.
function ToolToggleHelper.ToggleInventoryItem(item: InventoryItem)
	local p = Players.LocalPlayer
	local char = if p then p.Character else nil
	local bp = if p then p:FindFirstChildOfClass("Backpack") else nil
	local hum = if char then char:FindFirstChildOfClass("Humanoid") else nil
	if not p or not char then return end

	if item.skinTargetShovel then
		-- Wear this skin, or fall back to the default model when it is already worn.
		DigNetwork.EquipSkinRequest.fire(item.skinTargetShovel, if item.isEquipped then nil else item.templateId)
	elseif item.category == "Shovel" then
		local toolName = item.templateId or item.displayName
		local inChar = char:FindFirstChild(toolName)
		local inBp = if bp then bp:FindFirstChild(toolName) else nil
		if inChar then
			if hum then hum:UnequipTools() else inChar.Parent = bp end
		elseif inBp then
			if hum then hum:EquipTool(inBp) else inBp.Parent = char end
		elseif item.templateId then
			DigNetwork.SelectShovelRequest.fire(item.templateId)
		end
	else
		DigNetwork.EquipItemRequest.fire(item.id)
	end
end

return ToolToggleHelper
