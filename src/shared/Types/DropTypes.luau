--!strict

local InventoryTypes = require(script.Parent.InventoryTypes)

export type RarityTier = InventoryTypes.ItemRarity

export type DropItem = {
	id: string,
	displayName: string,
	tier: RarityTier,
	islandId: string,
	baseProbability: number,
	minWeight: number?,
	maxWeight: number?,
	weight: number?,
	category: string?,
	description: string?,
	icon: string?,
}

export type DropResult = {
	success: boolean,
	dropId: string?,
	amount: number,
	errorMsg: string?,
}

return nil
