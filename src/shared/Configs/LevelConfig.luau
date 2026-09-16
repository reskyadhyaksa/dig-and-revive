--!strict

local Shared = script.Parent.Parent
local DropTypes = require(Shared:WaitForChild("Types"):WaitForChild("DropTypes"))
local LevelTypes = require(Shared:WaitForChild("Types"):WaitForChild("LevelTypes"))

type RarityTier = DropTypes.RarityTier
type ExpRewardResult = LevelTypes.ExpRewardResult

local LevelConfig = {}

-- Base EXP Curve Formula: math.floor(100 * (level ^ 1.6))
function LevelConfig.GetRequiredExp(level: number): number
	local lvl = math.max(1, math.floor(level))
	return math.floor(100 * (lvl ^ 1.6))
end

-- Scaling Level Bonus Luck (%):
-- Lv 1: +0%
-- Lv 1-10: Scales from +0% up to +100% (~11.11% per level)
-- Lv 10-100: Scales from +100% up to +900% (~8.89% per level)
-- Lv 100+: Continues scaling (+8.89% per level)
function LevelConfig.GetLevelBonusLuck(level: number): number
	local lvl = math.max(1, math.floor(level))
	if lvl <= 10 then
		return (lvl - 1) * (100 / 9)
	else
		return 100 + ((lvl - 10) * (800 / 90))
	end
end

-- Base Luck: 100 at Lv 1 (+Bonus Luck from level)
function LevelConfig.GetBaseLuck(level: number): number
	return 100 + LevelConfig.GetLevelBonusLuck(level)
end

-- Scaling Luck Multiplier: Base 1.0x at Lv 1 (Lv 10 = 2.0x, Lv 100 = 10.0x)
function LevelConfig.GetLevelLuckMultiplier(level: number): number
	return LevelConfig.GetBaseLuck(level) / 100
end

-- Fixed EXP Rewards per Rarity Tier
LevelConfig.TierExpRewards = table.freeze({
	Common = 15,
	Uncommon = 35,
	Epic = 100,
	Legendary = 350,
	Mythic = 1500,
	Secret = 5000,
} :: { [RarityTier]: number })

function LevelConfig.GetTierExp(tier: RarityTier): number
	return LevelConfig.TierExpRewards[tier] or 15
end

-- Calculates level up progression with multiple level gains and leftover EXP
function LevelConfig.CalculateExpGain(currentLevel: number, currentExp: number, gainedExp: number): ExpRewardResult
	local level = math.max(1, math.floor(currentLevel))
	local exp = math.max(0, math.floor(currentExp + gainedExp))
	local initialLevel = level

	local requiredExp = LevelConfig.GetRequiredExp(level)

	while exp >= requiredExp do
		exp -= requiredExp
		level += 1
		requiredExp = LevelConfig.GetRequiredExp(level)
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

return table.freeze(LevelConfig)
