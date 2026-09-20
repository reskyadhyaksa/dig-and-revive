--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Common.UIBuilder)
local HotbarTheme = require(script.Parent.Parent.Common.HotbarTheme)
local useDeviceType = require(script.Parent.Parent.Hooks.useDeviceType)
local HotbarButton = require(script.Parent.HotbarButton)

export type Props = {
	onEquipShovel: (() -> ())?,
	onOpenInventory: (() -> ())?,
	onSelectShovel: (() -> ())?,
}

local function ToggleShovelTool()
	local player = Players.LocalPlayer
	local char = if player then player.Character else nil
	if not player or not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local tool = char:FindFirstChildWhichIsA("Tool")
	if tool then
		if hum then
			hum:UnequipTools()
		else
			tool.Parent = player:FindFirstChildOfClass("Backpack")
		end
	else
		local bp = player:FindFirstChildOfClass("Backpack")
		local bTool = if bp then bp:FindFirstChildWhichIsA("Tool") else nil
		if bTool then
			if hum then
				hum:EquipTool(bTool)
			else
				bTool.Parent = char
			end
		end
	end
end

local function Hotbar(props: Props): any
	local isMobile = useDeviceType().isMobile
	local MinSize = if isMobile then Vector2.new(220, 62) else Vector2.new(200, 56)
	local MaxSize = if isMobile then Vector2.new(352, 80) else Vector2.new(320, 72)
	local handleEquip = props.onEquipShovel or ToggleShovelTool
	local handleInv = props.onOpenInventory or function() print("Opened Inventory") end
	local handleSelect = props.onSelectShovel or function() print("Open Shovel UI") end

	React.useEffect(function()
		local conn = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.KeyCode == Enum.KeyCode.One or input.KeyCode == Enum.KeyCode.E then
				handleEquip()
			elseif input.KeyCode == Enum.KeyCode.Two then
				handleSelect()
			elseif input.KeyCode == Enum.KeyCode.Three or input.KeyCode == Enum.KeyCode.B or input.KeyCode == Enum.KeyCode.I then
				handleInv()
			end
		end)
		return function() conn:Disconnect() end
	end, { handleEquip, handleInv, handleSelect } :: { any })

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.985),
		Size = if isMobile then UDim2.fromScale(0.52, 0.11) else UDim2.fromScale(0.4, 0.085),
		BackgroundColor3 = Color3.fromRGB(18, 22, 30),
		BackgroundTransparency = 1,
		ZIndex = 10,
	}, {
		Corner = UIBuilder.PillCorner(),
		Pad = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
		}),
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		SizeConstraint = React.createElement("UISizeConstraint", { MinSize = MinSize, MaxSize = MaxSize }),

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
			layoutOrder = 3, icon = HotbarTheme.SelectShovel.icon, label = "Items",
			keybind = if isMobile then nil else "3", faceColor = HotbarTheme.SelectShovel.faceColor,
			gradientColors = HotbarTheme.SelectShovel.gradientColors, shadowColor = HotbarTheme.SelectShovel.shadowColor,
			strokeColor = HotbarTheme.SelectShovel.strokeColor, onActivated = handleInv,
		}),
	})
end

return Hotbar
