--!strict

local InventoryTypes = require(script.Parent.InventoryTypes)

export type ItemRarity = InventoryTypes.ItemRarity

export type DiscoveredItemRecord = {
	timesFound: number,
	firstDiscoveredAt: number,
	isRewardClaimed: boolean?,
}

export type PlayerIndexData = {
	[string]: DiscoveredItemRecord,
}

export type IndexCatalogItem = {
	id: string,
	displayName: string,
	category: string,
	tier: ItemRarity,
	icon: string,
	description: string,
	islandId: string,
}

export type IndexCategoryProgress = {
	total: number,
	discovered: number,
	percentage: number,
}

return nil
