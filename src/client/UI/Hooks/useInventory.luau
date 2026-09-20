--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local InventoryUtils = require(ReplicatedStorage.Shared.Utils.InventoryUtils)
local InventoryTypes = require(ReplicatedStorage.Shared.Types.InventoryTypes)

type InventoryItem = InventoryTypes.InventoryItem
type ItemCategory = InventoryTypes.ItemCategory
type SortOption = InventoryTypes.SortOption

export type UseInventoryProps = {
	initialItems: { InventoryItem },
	playerLevel: number,
	defaultTab: ItemCategory?,
}

local SORT_ORDER: { SortOption } = { "Newest", "Oldest", "Rarity", "Weight", "Name", "Favorited" }

local function useInventory(props: UseInventoryProps)
	local activeTab, setActiveTab = React.useState(props.defaultTab or "Items")
	local searchQuery, setSearchQuery = React.useState("")
	local sortOption: SortOption, setSortOption: any = React.useState("Newest" :: any)
	local favorites, setFavorites = React.useState({} :: { [string]: boolean })
	local selectedItem: InventoryItem?, setSelectedItem: any = React.useState(nil :: any)
	local maxCapacity = InventoryUtils.CalculateMaxCapacity(props.playerLevel)

	React.useEffect(function()
		if props.defaultTab then
			setActiveTab(props.defaultTab)
			setSelectedItem(nil)
		end
	end, { props.defaultTab } :: { any })

	local filteredItems = React.useMemo(function()
		return InventoryUtils.FilterAndSortItems(props.initialItems, activeTab, searchQuery, sortOption, favorites)
	end, { props.initialItems, activeTab, searchQuery, sortOption, favorites } :: { any })

	local handleSelectTab = React.useCallback(function(tab: ItemCategory)
		setActiveTab(tab)
		setSelectedItem(nil)
	end, {})

	local handleSearchChange = React.useCallback(function(text: string)
		setSearchQuery(text)
	end, {})

	local handleSelectItem = React.useCallback(function(item: InventoryItem)
		setSelectedItem(item)
	end, {})

	local handleToggleFavorite = React.useCallback(function(item: InventoryItem)
		setFavorites(function(prev)
			local next = table.clone(prev)
			local current = if next[item.id] ~= nil then next[item.id] else (item.isFavorite == true)
			next[item.id] = not current
			return next
		end)
	end, {})

	local handleCycleSort = React.useCallback(function()
		setSortOption(function(prev: any)
			local current = prev or "Newest"
			local idx = table.find(SORT_ORDER, current) or 1
			local nextIdx = (idx % #SORT_ORDER) + 1
			return SORT_ORDER[nextIdx] or "Newest"
		end)
	end, {})

	local usedCapacity = React.useMemo(function()
		return InventoryUtils.CalculateUsedCapacity(props.initialItems)
	end, { props.initialItems } :: { any })

	return {
		activeTab = activeTab,
		searchQuery = searchQuery,
		sortOption = sortOption,
		favorites = favorites,
		selectedItem = selectedItem,
		filteredItems = filteredItems,
		maxCapacity = maxCapacity,
		usedCapacity = usedCapacity,
		setActiveTab = handleSelectTab,
		setSearchQuery = handleSearchChange,
		setSortOption = setSortOption,
		cycleSortOption = handleCycleSort,
		setSelectedItem = handleSelectItem,
		toggleFavorite = handleToggleFavorite,
	}
end

return useInventory
