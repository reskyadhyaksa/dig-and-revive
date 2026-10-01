--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local DropTypes = require(Shared:WaitForChild("Types"):WaitForChild("DropTypes"))
local DigMinigameConfig = require(Shared:WaitForChild("Configs"):WaitForChild("DigMinigameConfig"))

type DropItem = DropTypes.DropItem

export type DigSession = {
	player: Player,
	islandId: string,
	power: number,
	drop: DropItem,
	currentHp: number,
	maxHp: number,
	expireTime: number,
	lastSwingTime: number,
	digDamage: number,
}

local DigSessionHelper = {}
local _activeSessions: { [Player]: DigSession } = {}

function DigSessionHelper.Create(p: Player, islandId: string, power: number, drop: DropItem, duration: number, damage: number): DigSession
	local baseHp = DigMinigameConfig.TierHp[drop.tier] or 12
	local session: DigSession = {
		player = p,
		islandId = islandId,
		power = power,
		drop = drop,
		currentHp = baseHp,
		maxHp = baseHp,
		expireTime = os.clock() + duration,
		lastSwingTime = 0,
		digDamage = damage,
	}
	_activeSessions[p] = session
	return session
end

function DigSessionHelper.Get(p: Player): DigSession?
	return _activeSessions[p]
end

function DigSessionHelper.Remove(p: Player)
	_activeSessions[p] = nil
end

function DigSessionHelper.Clear()
	table.clear(_activeSessions)
end

function DigSessionHelper.ProcessSwing(s: DigSession, now: number): (boolean, boolean)
	if now - s.lastSwingTime < DigMinigameConfig.SwingCooldown then
		return false, false
	end
	s.lastSwingTime = now
	s.currentHp = math.max(0, s.currentHp - s.digDamage)

	local regenCfg = DigMinigameConfig.RegenEvent
	if s.currentHp > 0 and s.currentHp >= regenCfg.thresholdMinHp and s.currentHp < s.maxHp then
		if math.random() < regenCfg.chance then
			s.currentHp = math.min(s.maxHp, s.currentHp + math.random(regenCfg.minAmount, regenCfg.maxAmount))
		end
	end

	local isComplete = s.currentHp <= 0
	return true, isComplete
end

return DigSessionHelper
