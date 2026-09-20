--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)
local InventoryUtils = require(ReplicatedStorage.Shared.Utils.InventoryUtils)
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type InventoryItem = InventoryTypes.InventoryItem

export type Props = {
	item: InventoryItem?,
	isSelected: boolean,
	isFavorite: boolean?,
	onClick: (() -> ())?,
	layoutOrder: number?,
}

local function InventorySlot(props: Props): any
	local item = props.item
	local isSelected = props.isSelected
	local isFav = props.isFavorite or (if item then item.isFavorite else false)
	local rarityColor = if item then InventoryUtils.GetRarityColor(item.tier) else Color3.fromRGB(50, 60, 75)
	local badgeText = if item and item.weight and item.weight > 0 then InventoryUtils.FormatWeight(item.weight) else nil

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder or 1,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1 }),

		Button = React.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = if isSelected then Color3.fromRGB(45, 55, 75) else Color3.fromRGB(30, 36, 48),
			Text = "",
			AutoButtonColor = false,
			[React.Event.Activated] = props.onClick or function() end,
		}, {
			Corner = UIBuilder.Corner(8),
			Stroke = UIBuilder.Stroke(if isSelected then Color3.fromRGB(255, 230, 100) else rarityColor, if isSelected then 2.5 else 1.8),
			Shine = UIBuilder.ShineOverlay(7, 0.42, 0.88, 2, if item then rarityColor else nil),

			Icon = if item and item.icon ~= "" then React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.46),
				Size = UDim2.fromScale(0.70, 0.70),
				BackgroundTransparency = 1,
				Image = item.icon,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 4,
			}) else nil,

			CountBadge = if badgeText then React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -3, 1, -2),
				Size = UDim2.fromOffset(32, 13),
				BackgroundTransparency = 1,
				Text = badgeText,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				Font = Enum.Font.FredokaOne,
				ZIndex = 6,
			}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(15, 20, 28), 1.6) }) else nil,

			EquippedTag = if item and item.isEquipped then React.createElement("Frame", {
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.fromOffset(8, 8),
				BackgroundColor3 = Color3.fromRGB(46, 204, 113),
				ZIndex = 7,
			}, { Corner = UIBuilder.Corner(4) }) else nil,

			FavTag = if isFav then React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -2, 0, 2),
				Size = UDim2.fromOffset(12, 12),
				BackgroundTransparency = 1,
				Text = "⭐",
				TextSize = 10,
				Font = Enum.Font.FredokaOne,
				ZIndex = 7,
			}) else nil,
		}),
	})
end

return InventorySlot
