--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)
local useDeviceType = require(script.Parent.Parent.Parent.Hooks.useDeviceType)
local useInventory = require(script.Parent.Parent.Parent.Hooks.useInventory)
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)
local InventoryHeader = require(script.Parent.InventoryHeader)
local InventoryTabList = require(script.Parent.InventoryTabList)
local InventorySlot = require(script.Parent.InventorySlot)
local InventoryDetailPanel = require(script.Parent.InventoryDetailPanel)

type InventoryItem = InventoryTypes.InventoryItem
type ItemCategory = InventoryTypes.ItemCategory

export type Props = {
	visible: boolean,
	items: { InventoryItem },
	playerLevel: number,
	defaultTab: ItemCategory?,
	onClose: () -> (),
	onEquipToggle: ((item: InventoryItem) -> ())?,
	onDrop: ((item: InventoryItem) -> ())?,
}

local function InventoryModal(props: Props): any
	local isMobile = useDeviceType().isMobile
	local inv = useInventory({
		initialItems = props.items,
		playerLevel = props.playerLevel,
		defaultTab = props.defaultTab,
	})

	if not props.visible then
		return nil
	end

	local gridChildren: { [string]: any } = {
		Corner = UIBuilder.Corner(8),
		Stroke = UIBuilder.Stroke(Color3.fromHex("#3D485C"), 1.2),
		Pad = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
		}),
		Layout = React.createElement("UIGridLayout", {
			CellSize = if isMobile then UDim2.fromOffset(44, 44) else UDim2.fromOffset(50, 50),
			CellPadding = UDim2.fromOffset(6, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for i, item in ipairs(inv.filteredItems) do
		local isFav = if inv.favorites[item.id] ~= nil then inv.favorites[item.id] else item.isFavorite
		gridChildren[item.id .. "_" .. i] = React.createElement(InventorySlot, {
			layoutOrder = i, item = item, isSelected = inv.selectedItem == item,
			isFavorite = isFav, onClick = function() inv.setSelectedItem(item) end,
		})
	end

	local selFav = if inv.selectedItem then (if inv.favorites[inv.selectedItem.id] ~= nil then inv.favorites[inv.selectedItem.id] else inv.selectedItem.isFavorite) else nil

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = if isMobile then UDim2.fromScale(0.92, 0.88) else UDim2.fromScale(0.70, 0.72),
		BackgroundColor3 = Color3.fromHex("#523017"), ZIndex = 30,
	}, {
		Corner = UIBuilder.Corner(14), Stroke = UIBuilder.Stroke(Color3.fromHex("#3E2716"), 3.5),
		Shine = UIBuilder.ShineOverlay(14, 0.22, 0.92, 1),
		SizeConstraint = React.createElement("UISizeConstraint", { MinSize = Vector2.new(380, 260), MaxSize = Vector2.new(840, 560) }),
		Pad = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		}),

		Header = React.createElement(InventoryHeader, {
			title = "Inventory", searchQuery = inv.searchQuery, onSearchChange = inv.setSearchQuery,
			sortOption = inv.sortOption, onCycleSort = inv.cycleSortOption,
			usedCapacity = inv.usedCapacity, maxCapacity = inv.maxCapacity, onClose = props.onClose,
		}),
		Body = React.createElement("Frame", {
			Position = UDim2.new(0, 0, 0, 42),
			Size = UDim2.new(1, 0, 1, -42),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			Tabs = React.createElement(InventoryTabList, { activeTab = inv.activeTab, onSelectTab = inv.setActiveTab }),
			GridContainer = React.createElement("ScrollingFrame", {
				Position = UDim2.new(0.19, 6, 0, 0),
				Size = UDim2.new(0.53, -12, 1, 0),
				BackgroundColor3 = Color3.fromHex("#1E2430"),
				BorderSizePixel = 0,
				ScrollBarThickness = 5,
				ScrollBarImageColor3 = Color3.fromHex("#523017"),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			}, gridChildren),
			Detail = React.createElement(InventoryDetailPanel, {
				item = inv.selectedItem,
				isFavorite = selFav,
				onToggleFavorite = inv.toggleFavorite,
				onEquipToggle = props.onEquipToggle,
				onDrop = props.onDrop,
			}),
		}),
	})
end

return InventoryModal
