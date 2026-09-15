--!strict

export type RarityTier = "Common" | "Uncommon" | "Epic" | "Legendary" | "Mythic" | "Secret"

export type DropItem = {
	id: string,
	displayName: string,
	tier: RarityTier,
	islandId: string,
	baseProbability: number,
}

export type DropResult = {
	success: boolean,
	dropId: string?,
	amount: number,
	errorMsg: string?,
}

return nil
