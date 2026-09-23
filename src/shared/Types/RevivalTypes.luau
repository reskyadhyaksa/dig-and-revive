--!strict

local InventoryTypes = require(script.Parent.InventoryTypes)

export type ItemRarity = InventoryTypes.ItemRarity

export type RevivalRecipe = {
	fossilId: string,
	primeLivingId: string,
	displayName: string,
	islandId: string,
	modelAssetPath: string,
	tier: ItemRarity,
	displayDuration: number,
	expReward: number?,
	coinReward: number?,
	description: string?,
}

export type RevivalResult = {
	success: boolean,
	recipe: RevivalRecipe?,
	errorMsg: string?,
}

export type AltarState = {
	islandId: string,
	altarPart: BasePart,
	prompt: ProximityPrompt,
	currentLivingModel: Model?,
	busy: boolean,
}

return nil
