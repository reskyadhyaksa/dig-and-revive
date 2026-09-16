--!strict

export type PlayerProfileData = {
	level: number,
	exp: number,
	coins: number,
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
