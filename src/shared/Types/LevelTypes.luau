--!strict

local IndexTypes = require(script.Parent.IndexTypes)
local InventoryTypes = require(script.Parent.InventoryTypes)

export type DiscoveredItemRecord = IndexTypes.DiscoveredItemRecord
export type PlayerIndexData = IndexTypes.PlayerIndexData
export type InventoryItem = InventoryTypes.InventoryItem

export type PlayerProfileData = {
	level: number,
	exp: number,
	coins: number,
	discoveredIndex: PlayerIndexData?,
	inventory: { InventoryItem }?,
}

export type PlayerStatsData = {
	level: number,
	exp: number,
	requiredExp: number,
	coins: number,
	luckMultiplier: number,
}

export type ExpRewardResult = {
	gainedExp: number,
	newLevel: number,
	newExp: number,
	requiredExp: number,
	didLevelUp: boolean,
	levelsGained: number,
}

return nil
