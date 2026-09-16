--!strict

local LevelConfig = require(script.Parent.Parent:WaitForChild("Configs"):WaitForChild("LevelConfig"))
local LevelTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("LevelTypes"))
local DropTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("DropTypes"))

type RarityTier = DropTypes.RarityTier
type ExpRewardResult = LevelTypes.ExpRewardResult

local LevelUtils = {}

function LevelUtils.GetRequiredExp(level: number): number
	local lvl = math.max(1, math.floor(level))
	return math.floor(100 * (lvl ^ 1.6))
end

function LevelUtils.GetLevelBonusLuck(level: number): number
	local lvl = math.max(1, math.floor(level))
	if lvl <= 10 then
		return (lvl - 1) * (100 / 9)
	else
		return 100 + ((lvl - 10) * (800 / 90))
	end
end

function LevelUtils.GetBaseLuck(level: number): number
	return 100 + LevelUtils.GetLevelBonusLuck(level)
end

function LevelUtils.GetLevelLuckMultiplier(level: number): number
	return LevelUtils.GetBaseLuck(level) / 100
end

function LevelUtils.GetTierExp(tier: RarityTier): number
	return LevelConfig.TierExpRewards[tier] or 15
end

function LevelUtils.CalculateExpGain(currentLevel: number, currentExp: number, gainedExp: number): ExpRewardResult
	local level = math.max(1, math.floor(currentLevel))
	local exp = math.max(0, math.floor(currentExp + gainedExp))
	local initialLevel = level

	local requiredExp = LevelUtils.GetRequiredExp(level)
	while exp >= requiredExp do
		exp -= requiredExp
		level += 1
		requiredExp = LevelUtils.GetRequiredExp(level)
	end

	local levelsGained = level - initialLevel

	return {
		gainedExp = gainedExp,
		newLevel = level,
		newExp = exp,
		requiredExp = requiredExp,
		didLevelUp = levelsGained > 0,
		levelsGained = levelsGained,
	}
end

return table.freeze(LevelUtils)
