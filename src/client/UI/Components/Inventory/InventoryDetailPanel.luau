--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)
local InventoryUtils = require(ReplicatedStorage.Shared.Utils.InventoryUtils)
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type InventoryItem = InventoryTypes.InventoryItem

export type Props = {
	item: InventoryItem?,
	isFavorite: boolean?,
	onEquipToggle: ((item: InventoryItem) -> ())?,
	onToggleFavorite: ((item: InventoryItem) -> ())?,
	onDrop: ((item: InventoryItem) -> ())?,
	onUse: ((item: InventoryItem) -> ())?,
	size: UDim2?, position: UDim2?,
}

local function InventoryDetailPanel(props: Props): any
	local item = props.item
	if not item then
		return React.createElement("Frame", {
			Size = props.size or UDim2.new(0.27, 0, 1, 0), Position = props.position or UDim2.new(0.73, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(25, 30, 42),
		}, {
			Corner = UIBuilder.Corner(10),
			EmptyText = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.8, 0.4),
				BackgroundTransparency = 1, Text = "Select an item to inspect",
				TextColor3 = Color3.fromRGB(130, 140, 160), TextSize = 13, Font = Enum.Font.FredokaOne,
			}),
		})
	end
	local rarityColor = InventoryUtils.GetRarityColor(item.tier)
	local isFav = if props.isFavorite ~= nil then props.isFavorite else (item.isFavorite == true)

	return React.createElement("Frame", {
		Size = props.size or UDim2.new(0.27, 0, 1, 0), Position = props.position or UDim2.new(0.73, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(24, 29, 40),
	}, {
		Corner = UIBuilder.Corner(10), Stroke = UIBuilder.Stroke(Color3.fromRGB(45, 54, 72), 1.6),
		Pad = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		}),
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		Showcase = React.createElement("Frame", {
			LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 78), BackgroundColor3 = Color3.fromRGB(34, 42, 58),
		}, {
			Corner = UIBuilder.Corner(8), Stroke = UIBuilder.Stroke(rarityColor, 2),
			Shine = UIBuilder.ShineOverlay(8, 0.45, 0.85, 2, rarityColor),
			Icon = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.80, 0.80),
				BackgroundTransparency = 1, Image = item.icon, ScaleType = Enum.ScaleType.Fit, ZIndex = 3,
			}),
		}),
		Name = React.createElement("TextLabel", {
			LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
			Text = string.upper(item.displayName), TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14, Font = Enum.Font.FredokaOne,
		}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(15, 20, 30), 1.6) }),
		MetaRow = React.createElement("Frame", {
			LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 6),
			}),
			RarityBadge = React.createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1,
				Text = item.tier, TextColor3 = rarityColor, TextSize = 12, Font = Enum.Font.FredokaOne,
			}),
			WeightBadge = if item.weight and item.weight > 0 then React.createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1,
				Text = "• ⚖️ " .. InventoryUtils.FormatWeight(item.weight),
				TextColor3 = Color3.fromRGB(245, 215, 130), TextSize = 12, Font = Enum.Font.FredokaOne,
			}) else nil,
		}),
		Description = React.createElement("TextLabel", {
			LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1,
			Text = item.description, TextColor3 = Color3.fromRGB(180, 190, 205),
			TextSize = 10, TextWrapped = true, Font = Enum.Font.GothamMedium,
		}),
		Actions = React.createElement("Frame", {
			LayoutOrder = 5, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5) }),
			EquipBtn = React.createElement("TextButton", {
				Size = UDim2.new(1, -74, 1, 0),
				BackgroundColor3 = if item.isEquipped then Color3.fromRGB(231, 76, 60) else Color3.fromRGB(46, 204, 113),
				Text = if item.isEquipped then "UNEQUIP" else "EQUIP",
				TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, Font = Enum.Font.FredokaOne,
				[React.Event.Activated] = function() if props.onEquipToggle then props.onEquipToggle(item) end end,
			}, { Corner = UIBuilder.Corner(6), Stroke = UIBuilder.Stroke(Color3.fromRGB(20, 25, 35), 1.5) }),
			FavBtn = React.createElement("TextButton", {
				Size = UDim2.new(0, 32, 1, 0),
				BackgroundColor3 = if isFav then Color3.fromRGB(60, 50, 25) else Color3.fromRGB(35, 42, 56),
				Text = if isFav then "⭐" else "✩",
				TextColor3 = if isFav then Color3.fromRGB(255, 220, 80) else Color3.fromRGB(160, 175, 195),
				TextSize = 15, Font = Enum.Font.FredokaOne,
				[React.Event.Activated] = function() if props.onToggleFavorite then props.onToggleFavorite(item) end end,
			}, { Corner = UIBuilder.Corner(6), Stroke = UIBuilder.Stroke(if isFav then Color3.fromRGB(200, 160, 40) else Color3.fromRGB(50, 60, 80), 1.5) }),
			DropBtn = React.createElement("TextButton", {
				Size = UDim2.new(0, 32, 1, 0), BackgroundColor3 = Color3.fromRGB(192, 57, 43),
				Text = "🗑️", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15, Font = Enum.Font.FredokaOne,
				[React.Event.Activated] = function() if props.onDrop then props.onDrop(item) end end,
			}, { Corner = UIBuilder.Corner(6), Stroke = UIBuilder.Stroke(Color3.fromRGB(20, 25, 35), 1.5) }),
		}),
	})
end

return InventoryDetailPanel
