--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Common.UIBuilder)
local HotbarTheme = require(script.Parent.Parent.Common.HotbarTheme)
local useDeviceType = require(script.Parent.Parent.Hooks.useDeviceType)
local HotbarButton = require(script.Parent.HotbarButton)
local HotbarItemSlot = require(script.Parent.HotbarItemSlot)
local ToolToggleHelper = require(script.Parent.Parent.Common.ToolToggleHelper)
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type InventoryItem = InventoryTypes.InventoryItem

export type Props = {
	equippedItems: { InventoryItem }?,
	onEquipShovel: (() -> ())?,
	onOpenInventory: (() -> ())?,
	onSelectShovel: (() -> ())?,
	onSelectSlotItem: ((item: InventoryItem) -> ())?,
	onRemoveSlotItem: ((item: InventoryItem) -> ())?,
}

local function Hotbar(props: Props): any
	local isMobile = useDeviceType().isMobile
	local items = props.equippedItems or {}
	local totalButtons = 3 + #items
	local baseWidth = if isMobile then math.clamp(0.12 * totalButtons + 0.1, 0.45, 0.95) else math.clamp(0.08 * totalButtons + 0.08, 0.35, 0.65)
	local minWidth = if isMobile then 70 * totalButtons + 20 else 80 * totalButtons + 20

	local handleEquip = props.onEquipShovel or function() ToolToggleHelper.Toggle(nil) end
	local handleSelect = props.onSelectShovel or function() end
	local handleInv = props.onOpenInventory or function() end
	local handleSelectSlot = props.onSelectSlotItem or function(it) ToolToggleHelper.Toggle(it) end
	local handleRemoveSlot = props.onRemoveSlotItem or function() end

	React.useEffect(function()
		local conn = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			local key = input.KeyCode
			if key == Enum.KeyCode.One or key == Enum.KeyCode.E then handleEquip()
			elseif key == Enum.KeyCode.Two then handleSelect()
			elseif key == Enum.KeyCode.Three or key == Enum.KeyCode.B then handleInv()
			elseif key == Enum.KeyCode.Four and items[1] then handleSelectSlot(items[1])
			elseif key == Enum.KeyCode.Five and items[2] then handleSelectSlot(items[2])
			elseif key == Enum.KeyCode.Six and items[3] then handleSelectSlot(items[3])
			elseif key == Enum.KeyCode.Seven and items[4] then handleSelectSlot(items[4])
			end
		end)
		return function() conn:Disconnect() end
	end, { handleEquip, handleInv, handleSelect, handleSelectSlot, items } :: { any })

	local char = Players.LocalPlayer and Players.LocalPlayer.Character
	local slotElements: { [string]: any } = {}

	for i, item in ipairs(items) do
		local slotNum = i + 3
		local isHeld = false
		if char then
			for _, child in ipairs(char:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("UniqueId") == item.id then isHeld = true break end
			end
		end
		slotElements["Slot" .. slotNum] = React.createElement(HotbarItemSlot, {
			layoutOrder = slotNum, slotNumber = slotNum, keybind = if isMobile then nil else tostring(slotNum),
			item = item, isHeld = isHeld,
			onSelect = function() handleSelectSlot(item) end, onRemove = function() handleRemoveSlot(item) end,
		})
	end

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.985),
		Size = if isMobile then UDim2.fromScale(baseWidth, 0.11) else UDim2.fromScale(baseWidth, 0.085),
		BackgroundColor3 = Color3.fromRGB(18, 22, 30), BackgroundTransparency = 1, ZIndex = 10,
	}, {
		Corner = UIBuilder.PillCorner(),
		Pad = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
		}),
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(minWidth, if isMobile then 62 else 56),
			MaxSize = Vector2.new(minWidth + 80, if isMobile then 80 else 72),
		}),
		ShovelBtn = React.createElement(HotbarButton, {
			layoutOrder = 1, icon = HotbarTheme.Shovel.icon, label = "Equip",
			keybind = if isMobile then nil else "1", faceColor = HotbarTheme.Shovel.faceColor,
			gradientColors = HotbarTheme.Shovel.gradientColors, shadowColor = HotbarTheme.Shovel.shadowColor,
			strokeColor = HotbarTheme.Shovel.strokeColor, onActivated = handleEquip,
		}),
		InventoryBtn = React.createElement(HotbarButton, {
			layoutOrder = 2, icon = HotbarTheme.Inventory.icon, label = "Shovel",
			keybind = if isMobile then nil else "2", faceColor = HotbarTheme.Inventory.faceColor,
			gradientColors = HotbarTheme.Inventory.gradientColors, shadowColor = HotbarTheme.Inventory.shadowColor,
			strokeColor = HotbarTheme.Inventory.strokeColor, onActivated = handleSelect,
		}),
		SelectShovelBtn = React.createElement(HotbarButton, {
			layoutOrder = 3, icon = HotbarTheme.SelectShovel.icon, label = "Fossils",
			keybind = if isMobile then nil else "3", faceColor = HotbarTheme.SelectShovel.faceColor,
			gradientColors = HotbarTheme.SelectShovel.gradientColors, shadowColor = HotbarTheme.SelectShovel.shadowColor,
			strokeColor = HotbarTheme.SelectShovel.strokeColor, onActivated = handleInv,
		}),
		ItemSlots = React.createElement(React.Fragment, nil, slotElements),
	})
end

return Hotbar
