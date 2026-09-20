--!strict

export type ItemCategory = "Items" | "Shovel" | "Potion" | string
export type ItemRarity = "Common" | "Uncommon" | "Epic" | "Legendary" | "Mythic" | "Secret"
export type SortOption = "Newest" | "Oldest" | "Rarity" | "Weight" | "Name" | "Favorited"

export type SortConfig = {
	id: SortOption,
	displayName: string,
	icon: string,
}

export type ItemStat = {
	name: string,
	value: string,
	icon: string?,
}

export type InventoryItem = {
	id: string,
	templateId: string?,
	displayName: string,
	category: ItemCategory,
	tier: ItemRarity,
	weight: number?,
	amount: number?,
	icon: string,
	description: string,
	isEquipped: boolean?,
	isFavorite: boolean?,
	obtainedAt: number?,
	stats: { ItemStat }?,
}

export type TabConfig = {
	id: ItemCategory,
	displayName: string,
	icon: string,
	order: number,
}

export type InventoryState = {
	items: { InventoryItem },
	maxCapacity: number,
	usedCapacity: number,
	activeTab: ItemCategory,
	searchQuery: string,
	sortOption: SortOption,
	selectedItem: InventoryItem?,
}

return nil
