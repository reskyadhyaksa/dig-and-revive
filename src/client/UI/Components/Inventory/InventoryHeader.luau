--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)

local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type SortOption = InventoryTypes.SortOption

export type Props = {
	title: string,
	searchQuery: string,
	onSearchChange: (text: string) -> (),
	sortOption: SortOption?,
	onCycleSort: (() -> ())?,
	usedCapacity: number,
	maxCapacity: number,
	onClose: () -> (),
}

local SORT_ICONS: { [SortOption]: string } = {
	Newest = "🕒 New", Oldest = "⏳ Old", Rarity = "💎 Tier",
	Weight = "⚖️ Mass", Name = "🔤 A-Z", Favorited = "⭐ Fav",
}

local function InventoryHeader(props: Props): any
	local sortLabel = if props.sortOption and SORT_ICONS[props.sortOption] then SORT_ICONS[props.sortOption] else "💎 Sort"

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
	}, {
		Title = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 4, 0.5, 0),
			Size = UDim2.new(0, 85, 1, 0), BackgroundTransparency = 1,
			Text = string.upper(props.title), TextColor3 = Color3.fromRGB(255, 235, 205),
			TextSize = 15, Font = Enum.Font.FredokaOne, TextXAlignment = Enum.TextXAlignment.Left,
		}, { Stroke = UIBuilder.TextStroke(Color3.fromHex("#2B1506"), 1.8) }),

		SearchBox = React.createElement("TextBox", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.33, 0.5),
			Size = UDim2.new(0.24, 0, 0, 28), BackgroundColor3 = Color3.fromRGB(25, 30, 42),
			PlaceholderText = "Search...", PlaceholderColor3 = Color3.fromRGB(120, 130, 150),
			Text = props.searchQuery, TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12, Font = Enum.Font.FredokaOne, ClearTextOnFocus = false,
			[React.Change.Text] = function(rbx: TextBox) props.onSearchChange(rbx.Text) end,
		}, { Corner = UIBuilder.Corner(6), Stroke = UIBuilder.Stroke(Color3.fromRGB(45, 55, 75), 1.2) }),

		SortBtn = React.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.57, 0.5),
			Size = UDim2.new(0.20, 0, 0, 28), BackgroundColor3 = Color3.fromRGB(35, 42, 58),
			Text = sortLabel, TextColor3 = Color3.fromRGB(255, 230, 130),
			TextSize = 11, Font = Enum.Font.FredokaOne,
			[React.Event.Activated] = props.onCycleSort or function() end,
		}, {
			Corner = UIBuilder.Corner(6), Stroke = UIBuilder.Stroke(Color3.fromRGB(60, 75, 105), 1.2),
			Shine = UIBuilder.ShineOverlay(6, 0.45, 0.90),
		}),

		Capacity = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -36, 0.5, 0),
			Size = UDim2.new(0, 110, 1, 0), BackgroundTransparency = 1,
			Text = string.format("Slots: %d / %d", props.usedCapacity, props.maxCapacity),
			TextColor3 = if props.usedCapacity >= props.maxCapacity then Color3.fromRGB(231, 76, 60) else Color3.fromRGB(220, 230, 245),
			TextSize = 11, Font = Enum.Font.FredokaOne, TextXAlignment = Enum.TextXAlignment.Right,
		}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(20, 25, 35), 1.4) }),

		CloseBtn = React.createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(28, 28), BackgroundColor3 = Color3.fromRGB(192, 57, 43),
			Text = "X", TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14, Font = Enum.Font.FredokaOne, [React.Event.Activated] = props.onClose,
		}, {
			Corner = UIBuilder.Corner(8), Stroke = UIBuilder.Stroke(Color3.fromHex("#5E1911"), 1.8),
			Shine = UIBuilder.ShineOverlay(8, 0.45, 0.85),
		}),
	})
end

return InventoryHeader
