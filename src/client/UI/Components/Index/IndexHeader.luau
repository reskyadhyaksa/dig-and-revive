--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)

export type Props = {
	title: string?,
	discoveredCount: number,
	totalCount: number,
	activeCategory: string,
	onSelectCategory: (category: string) -> (),
	onClose: (() -> ())?,
}

local CATEGORIES = { "All", "Fossils", "Relics", "Secrets" }

local function IndexHeader(props: Props): any
	local pct = if props.totalCount > 0 then math.clamp(props.discoveredCount / props.totalCount, 0, 1) else 0
	local pctFormatted = math.floor(pct * 100)

	local tabChildren: { [string]: any } = {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for idx, cat in ipairs(CATEGORIES) do
		local isActive = props.activeCategory == cat
		tabChildren[cat] = React.createElement("TextButton", {
			LayoutOrder = idx,
			Size = UDim2.new(0, 72, 1, 0),
			BackgroundColor3 = if isActive then Color3.fromRGB(58, 140, 255) else Color3.fromRGB(30, 36, 48),
			Text = cat,
			TextColor3 = if isActive then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(160, 175, 195),
			TextSize = 12,
			Font = Enum.Font.FredokaOne,
			AutoButtonColor = false,
			[React.Event.Activated] = function() props.onSelectCategory(cat) end,
		}, {
			Corner = UIBuilder.Corner(6),
			Stroke = UIBuilder.Stroke(if isActive then Color3.fromRGB(110, 180, 255) else Color3.fromRGB(45, 54, 70), 1.2),
		})
	end

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 78),
		BackgroundTransparency = 1,
	}, {
		TopRow = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundTransparency = 1,
		}, {
			Title = React.createElement("TextLabel", {
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = props.title or "📖 DISCOVERY INDEX",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 20,
				Font = Enum.Font.FredokaOne,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(10, 14, 20), 1.8) }),

			CloseBtn = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(30, 30),
				BackgroundColor3 = Color3.fromRGB(230, 65, 65),
				Text = "✕",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 16,
				Font = Enum.Font.FredokaOne,
				[React.Event.Activated] = props.onClose or function() end,
			}, { Corner = UIBuilder.Corner(6) }),
		}),

		BottomRow = React.createElement("Frame", {
			Position = UDim2.new(0, 0, 0, 42),
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
		}, {
			Tabs = React.createElement("Frame", {
				Size = UDim2.new(0.55, 0, 1, 0),
				BackgroundTransparency = 1,
			}, tabChildren),

			ProgressContainer = React.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0.40, 0, 0, 22),
				BackgroundColor3 = Color3.fromRGB(20, 25, 34),
			}, {
				Corner = UIBuilder.Corner(5),
				Stroke = UIBuilder.Stroke(Color3.fromRGB(45, 54, 72), 1),
				Fill = React.createElement("Frame", {
					Size = UDim2.new(pct, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(46, 204, 113),
				}, { Corner = UIBuilder.Corner(5) }),
				Label = React.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Text = string.format("%d/%d Discovered (%d%%)", props.discoveredCount, props.totalCount, pctFormatted),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 11,
					Font = Enum.Font.FredokaOne,
					ZIndex = 3,
				}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(15, 20, 28), 1.2) }),
			}),
		}),
	})
end

return IndexHeader
