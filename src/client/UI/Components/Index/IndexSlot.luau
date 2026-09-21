--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)
local InventoryUtils = require(ReplicatedStorage.Shared.Utils.InventoryUtils)
local IndexTypes = require(ReplicatedStorage.Shared.Types.IndexTypes)

type IndexCatalogItem = IndexTypes.IndexCatalogItem

export type Props = {
	item: IndexCatalogItem,
	isDiscovered: boolean,
	timesFound: number,
	isSelected: boolean,
	onClick: (() -> ())?,
	layoutOrder: number?,
}

local function IndexSlot(props: Props): any
	local item = props.item
	local isDiscovered = props.isDiscovered
	local isSelected = props.isSelected
	local timesFound = props.timesFound
	local rarityColor = if isDiscovered then InventoryUtils.GetRarityColor(item.tier) else Color3.fromRGB(38, 46, 62)
	local bgColor = if isSelected then Color3.fromRGB(40, 50, 70) else if isDiscovered then Color3.fromRGB(28, 34, 46) else Color3.fromRGB(20, 24, 34)

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder or 1,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1 }),

		Button = React.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = bgColor,
			Text = "",
			AutoButtonColor = false,
			[React.Event.Activated] = props.onClick or function() end,
		}, {
			Corner = UIBuilder.Corner(8),
			Stroke = UIBuilder.Stroke(if isSelected then Color3.fromRGB(255, 230, 100) else rarityColor, if isSelected then 2.5 else 1.5),
			Shine = if isDiscovered then UIBuilder.ShineOverlay(7, 0.42, 0.88, 2, rarityColor) else nil,

			Icon = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.72, 0.72),
				BackgroundTransparency = 1,
				Image = item.icon,
				ImageColor3 = if isDiscovered then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(36, 44, 60),
				ImageTransparency = if isDiscovered then 0 else 0.15,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 4,
			}),

			LockOverlay = if not isDiscovered then React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -3, 1, -2),
				Size = UDim2.fromOffset(16, 16),
				BackgroundTransparency = 1,
				Text = "🔒",
				TextSize = 11,
				Font = Enum.Font.FredokaOne,
				ZIndex = 5,
			}) else nil,

			CountBadge = if isDiscovered and timesFound > 0 then React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -3, 1, -2),
				Size = UDim2.fromOffset(36, 14),
				BackgroundTransparency = 1,
				Text = "x" .. tostring(timesFound),
				TextColor3 = Color3.fromRGB(255, 235, 120),
				TextScaled = true,
				Font = Enum.Font.FredokaOne,
				ZIndex = 6,
			}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(15, 20, 28), 1.6) }) else nil,
		}),
	})
end

return IndexSlot
