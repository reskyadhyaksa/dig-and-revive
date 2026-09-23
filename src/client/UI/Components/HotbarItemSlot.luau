--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Common.UIBuilder)
local InventoryUtils = require(ReplicatedStorage.Shared.Utils.InventoryUtils)
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type InventoryItem = InventoryTypes.InventoryItem

export type Props = {
	layoutOrder: number?,
	slotNumber: number,
	keybind: string?,
	item: InventoryItem,
	isHeld: boolean,
	onSelect: () -> (),
	onRemove: () -> (),
}

local function HotbarItemSlot(props: Props): any
	local item = props.item
	local isHovered, setIsHovered = React.useState(false)
	local isPressed, setIsPressed = React.useState(false)

	local rarityColor = InventoryUtils.GetRarityColor(item.tier)
	local yOffset = if isPressed then 2 else (if isHovered then -2 else 0)

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder or props.slotNumber,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1.05 }),

		SlotBtn = React.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromOffset(0, yOffset),
			BackgroundTransparency = 1,
			Text = "",
			[React.Event.MouseButton1Down] = function() setIsPressed(true) end,
			[React.Event.MouseButton1Up] = function() setIsPressed(false) end,
			[React.Event.MouseEnter] = function() setIsHovered(true) end,
			[React.Event.MouseLeave] = function() setIsHovered(false) setIsPressed(false) end,
			[React.Event.Activated] = props.onSelect,
		}, {
			Plate = UIBuilder.BevelPlate({
				shadowColor = if props.isHeld then Color3.fromRGB(12, 16, 24) else Color3.fromRGB(18, 22, 30),
				shadowYScale = 0.6,
				faceColor = if props.isHeld then Color3.fromRGB(45, 58, 80) else Color3.fromRGB(34, 42, 58),
				borderColor = if props.isHeld then Color3.fromRGB(255, 255, 255) else rarityColor,
				borderThickness = if props.isHeld then 2.8 else 2.0,
				cornerRadius = 12,
				children = {
					Shine = UIBuilder.ShineOverlay(12, 0.35, 0.85, 2, rarityColor),
					Content = React.createElement("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 4 }, {
						Icon = React.createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.68, 0.68), BackgroundTransparency = 1,
							Image = item.icon, ScaleType = Enum.ScaleType.Fit, ZIndex = 5,
						}),
					}),
				},
			}),

			KeybindBadge = if props.keybind then React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, -2, 0, -4),
				Size = UDim2.fromOffset(18, 18), BackgroundColor3 = Color3.fromRGB(35, 40, 52), ZIndex = 10,
			}, {
				Corner = UIBuilder.Corner(5), Stroke = UIBuilder.Stroke(Color3.fromRGB(80, 90, 110), 1.2),
				Text = React.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = props.keybind,
					TextColor3 = Color3.fromRGB(240, 245, 255), TextScaled = true, Font = Enum.Font.FredokaOne, ZIndex = 11,
				}),
			}) else nil,

			CloseBtn = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 4, 0, -4),
				Size = UDim2.fromOffset(18, 18), BackgroundColor3 = Color3.fromRGB(231, 76, 60),
				Text = "✕", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.FredokaOne,
				TextSize = 11, ZIndex = 12,
				[React.Event.Activated] = function() props.onRemove() end,
			}, { Corner = UIBuilder.Corner(9), Stroke = UIBuilder.Stroke(Color3.fromRGB(150, 40, 30), 1.2) }),
		}),
	})
end

return HotbarItemSlot
