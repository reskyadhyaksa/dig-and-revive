--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)
local InventoryConfig = require(ReplicatedStorage.Shared.Configs.InventoryConfig)
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type ItemCategory = InventoryTypes.ItemCategory
type TabConfig = InventoryTypes.TabConfig

export type Props = {
	activeTab: ItemCategory,
	onSelectTab: (tabId: ItemCategory) -> (),
	customTabs: { TabConfig }?,
	size: UDim2?,
	position: UDim2?,
}

local function InventoryTabList(props: Props): any
	local tabs = props.customTabs or InventoryConfig.Tabs
	local tabElements = {}

	tabElements.Layout = React.createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for _, tab in ipairs(tabs) do
		local isActive = props.activeTab == tab.id
		tabElements[tab.id] = React.createElement("TextButton", {
			LayoutOrder = tab.order,
			Size = UDim2.new(1, 0, 0, 42),
			BackgroundColor3 = if isActive then Color3.fromHex("#945B31") else Color3.fromHex("#523017"),
			Text = "",
			AutoButtonColor = false,
			[React.Event.Activated] = function()
				props.onSelectTab(tab.id)
			end,
		}, {
			Corner = UIBuilder.Corner(8),
			Stroke = UIBuilder.Stroke(if isActive then Color3.fromHex("#FFD285") else Color3.fromHex("#3E2716"), 1.8),
			Shine = UIBuilder.ShineOverlay(8, 0.45, 0.85),

			Icon = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 6, 0.5, 0),
				Size = UDim2.fromOffset(24, 24),
				BackgroundTransparency = 1,
				Image = tab.icon,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 3,
			}),

			Label = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 34, 0.5, 0),
				Size = UDim2.new(1, -38, 0, 20),
				BackgroundTransparency = 1,
				Text = tab.displayName,
				TextColor3 = if isActive then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(210, 195, 180),
				TextSize = 13,
				Font = Enum.Font.FredokaOne,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3,
			}, { Stroke = UIBuilder.TextStroke(Color3.fromHex("#2B1506"), 1.4) }),
		})
	end

	return React.createElement("Frame", {
		Size = props.size or UDim2.new(0.18, 0, 1, 0),
		Position = props.position or UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
	}, tabElements)
end

return InventoryTabList
