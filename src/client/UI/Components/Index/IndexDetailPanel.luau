--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)
local InventoryUtils = require(ReplicatedStorage.Shared.Utils.InventoryUtils)
local IndexTypes = require(ReplicatedStorage.Shared.Types.IndexTypes)

type IndexCatalogItem = IndexTypes.IndexCatalogItem
type DiscoveredItemRecord = IndexTypes.DiscoveredItemRecord

export type Props = {
	item: IndexCatalogItem?,
	record: DiscoveredItemRecord?,
}

local function IndexDetailPanel(props: Props): any
	local item = props.item
	local record = props.record
	local timesFound = if record then record.timesFound else 0
	local isDiscovered = timesFound > 0

	if not item then
		return React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(24, 29, 40),
		}, {
			Corner = UIBuilder.Corner(8),
			Prompt = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.8, 0.5), BackgroundTransparency = 1,
				Text = "Select an item to view its Codex entry.",
				TextColor3 = Color3.fromRGB(130, 145, 165), TextSize = 13,
				Font = Enum.Font.FredokaOne, TextWrapped = true,
			}),
		})
	end

	local rarityColor = if isDiscovered then InventoryUtils.GetRarityColor(item.tier) else Color3.fromRGB(50, 60, 80)
	local displayName = if isDiscovered then item.displayName else "???"
	local description = if isDiscovered then item.description else "Undiscovered mystery item. Keep excavating the islands to discover its secrets!"

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(24, 29, 40),
	}, {
		Corner = UIBuilder.Corner(8),
		Stroke = UIBuilder.Stroke(Color3.fromRGB(42, 50, 68), 1.5),
		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		}),
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Preview = React.createElement("Frame", {
			LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 90),
			BackgroundColor3 = Color3.fromRGB(18, 22, 30),
		}, {
			Corner = UIBuilder.Corner(6),
			Stroke = UIBuilder.Stroke(rarityColor, 1.5),
			Icon = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(70, 70), BackgroundTransparency = 1,
				Image = item.icon, ScaleType = Enum.ScaleType.Fit,
				ImageColor3 = if isDiscovered then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(45, 55, 75),
				ImageTransparency = if isDiscovered then 0 else 0.1,
			}),
		}),

		Name = React.createElement("TextLabel", {
			LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
			Text = displayName, Font = Enum.Font.FredokaOne, TextSize = 16,
			TextColor3 = if isDiscovered then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(170, 180, 195),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		TierBadge = React.createElement("TextLabel", {
			LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
			Text = if isDiscovered then string.format("[%s • %s]", item.tier, item.category) else string.format("[Locked • %s]", item.category),
			TextColor3 = rarityColor, TextSize = 12, Font = Enum.Font.FredokaOne,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		Description = React.createElement("TextLabel", {
			LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1,
			Text = description, TextColor3 = Color3.fromRGB(175, 190, 210),
			TextSize = 11, Font = Enum.Font.FredokaOne, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		}),

		StatsRow = React.createElement("TextLabel", {
			LayoutOrder = 5, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
			Text = string.format("Times Discovered: %d", timesFound),
			TextColor3 = Color3.fromRGB(255, 225, 100), TextSize = 12,
			Font = Enum.Font.FredokaOne, TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
end

return IndexDetailPanel
