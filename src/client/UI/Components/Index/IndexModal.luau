--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)
local IndexTypes = require(ReplicatedStorage.Shared.Types.IndexTypes)
local IndexUtils = require(ReplicatedStorage.Shared.Utils.IndexUtils)
local IndexHeader = require(script.Parent.IndexHeader)
local IndexSlot = require(script.Parent.IndexSlot)
local IndexDetailPanel = require(script.Parent.IndexDetailPanel)

type PlayerIndexData = IndexTypes.PlayerIndexData

export type Props = {
	visible: boolean,
	indexData: PlayerIndexData?,
	onClose: (() -> ())?,
}

local function IndexModal(props: Props): any
	if not props.visible then return nil end

	local catalog = IndexUtils.GetCatalog()
	local activeCat, setActiveCat = React.useState("All")
	local selectedId, setSelectedId = React.useState(if catalog[1] then catalog[1].id else nil)

	local progress = IndexUtils.CalculateProgress(catalog, props.indexData, activeCat)
	local selectedItem = if selectedId then IndexUtils.GetCatalogItem(selectedId) else nil
	local selectedRecord = if props.indexData and selectedId then props.indexData[selectedId] else nil

	local gridChildren: { [string]: any } = {
		Corner = UIBuilder.Corner(8),
		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
		}),
		Grid = React.createElement("UIGridLayout", {
			CellSize = UDim2.fromOffset(72, 72),
			CellPadding = UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for idx, item in ipairs(catalog) do
		if activeCat == "All" or item.category == activeCat then
			local isDiscovered = IndexUtils.IsDiscovered(props.indexData, item.id)
			local count = IndexUtils.GetTimesFound(props.indexData, item.id)
			gridChildren[item.id] = React.createElement(IndexSlot, {
				item = item,
				isDiscovered = isDiscovered,
				timesFound = count,
				isSelected = item.id == selectedId,
				layoutOrder = idx,
				onClick = function() setSelectedId(item.id) end,
			})
		end
	end

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(680, 420),
		BackgroundColor3 = Color3.fromRGB(15, 18, 25),
		Active = true,
		ZIndex = 50,
	}, {
		Corner = UIBuilder.Corner(10),
		Stroke = UIBuilder.Stroke(Color3.fromRGB(48, 58, 80), 2),
		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
		}),

		Header = React.createElement(IndexHeader, {
			discoveredCount = progress.discovered,
			totalCount = progress.total,
			activeCategory = activeCat,
			onSelectCategory = setActiveCat,
			onClose = props.onClose,
		}),

		Content = React.createElement("Frame", {
			Position = UDim2.new(0, 0, 0, 86),
			Size = UDim2.new(1, 0, 1, -86),
			BackgroundTransparency = 1,
		}, {
			GridScroll = React.createElement("ScrollingFrame", {
				Size = UDim2.new(0.68, -8, 1, 0),
				BackgroundColor3 = Color3.fromRGB(20, 24, 32),
				ScrollBarThickness = 5,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			}, gridChildren),

			Detail = React.createElement("Frame", {
				Position = UDim2.new(0.68, 0, 0, 0),
				Size = UDim2.new(0.32, 0, 1, 0),
				BackgroundTransparency = 1,
			}, {
				Panel = React.createElement(IndexDetailPanel, {
					item = selectedItem,
					record = selectedRecord,
				}),
			}),
		}),
	})
end

return IndexModal
