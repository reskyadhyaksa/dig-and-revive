--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local DropUtils = require(Shared:WaitForChild("Utils"):WaitForChild("DropUtils"))
local LevelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("LevelUtils"))
local PowerBarHelper = require(Shared:WaitForChild("Common"):WaitForChild("PowerBarHelper"))
local DropTypes = require(Shared:WaitForChild("Types"):WaitForChild("DropTypes"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local ZoneService = require(script.Parent:WaitForChild("ZoneService"))
local PlayerService = require(script.Parent:WaitForChild("PlayerService"))
local IndexService = require(script.Parent:WaitForChild("IndexService"))
local InventoryRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("InventoryRepository"))

type DropItem = DropTypes.DropItem
type DigSession = {
	player: Player, islandId: string, power: number, drop: DropItem,
	currentHp: number, maxHp: number, expireTime: number, lastSwingTime: number,
}

local DigService = {}
local _trove = Trove.new()
local _playerLastDigEndTime: { [Player]: number } = {}
local _activeSessions: { [Player]: DigSession } = {}
local DEFAULT_DURATION = 15.0

local TIER_HP: { [DropTypes.RarityTier]: number } = {
	Common = 3, Uncommon = 4, Epic = 5, Legendary = 6, Mythic = 8, Secret = 10,
}

local function SendFail(p: Player, msg: string)
	DigNetwork.MinigameComplete.fire(p, false, nil, 0, 0, PlayerService.GetPlayerLevel(p), PlayerService.GetPlayerExp(p), msg)
end

function DigService.Init()
	_trove:Connect(Players.PlayerRemoving, function(p)
		_playerLastDigEndTime[p] = nil
		_activeSessions[p] = nil
	end)

	_trove:Add(DigNetwork.StartDigRequest.on(function(p: Player, power: number, islandId: string)
		local char = p.Character
		if not char or not char:FindFirstChildOfClass("Humanoid") then return end
		local tool = char:FindFirstChildWhichIsA("Tool")
		local shovelCfg = if tool then ShovelUtils.GetShovelConfig(tool.Name) else nil
		if not shovelCfg then SendFail(p, "No valid shovel equipped!") return end

		local now = os.clock()
		if now - (_playerLastDigEndTime[p] or 0) < shovelCfg.cooldown then
			SendFail(p, "Please wait before digging again!") return
		end

		local zone = ZoneService.GetPlayerCurrentZone(p)
		if not zone or zone.islandId ~= islandId then SendFail(p, "Invalid zone!") return end

		local powerMult = PowerBarHelper.GetMultiplier(math.clamp(power or 0, 0, 1))
		local totalLuck = powerMult * PlayerService.GetTotalPlayerLuck(p)
		local drop = DropUtils.RollDrop(zone.islandId, totalLuck)
		if not drop then _playerLastDigEndTime[p] = now SendFail(p, "No item found.") return end

		local hp = TIER_HP[drop.tier] or 3
		_activeSessions[p] = {
			player = p, islandId = islandId, power = power, drop = drop,
			currentHp = hp, maxHp = hp, expireTime = now + DEFAULT_DURATION, lastSwingTime = 0,
		}
		DigNetwork.StartMinigame.fire(p, drop.tier, hp, DEFAULT_DURATION)
	end))

	_trove:Add(DigNetwork.SwingRequest.on(function(p: Player)
		local s = _activeSessions[p]
		if not s then return end
		local now = os.clock()
		if now > s.expireTime then
			_activeSessions[p] = nil _playerLastDigEndTime[p] = now
			SendFail(p, "Minigame time expired!") return
		end

		if now - s.lastSwingTime < 0.08 then return end
		s.lastSwingTime = now
		s.currentHp = math.max(0, s.currentHp - 1)
		DigNetwork.MinigameHit.fire(p, s.currentHp, s.maxHp)

		if s.currentHp <= 0 then
			local won = s.drop
			_activeSessions[p] = nil
			_playerLastDigEndTime[p] = now
			InventoryRepository.AddItem(p, won, 1)
			IndexService.RecordDiscovery(p, won.id)
			local expRes = PlayerService.AddExp(p, LevelUtils.GetTierExp(won.tier))
			DigNetwork.MinigameComplete.fire(p, true, won.id, 1, expRes.gainedExp, expRes.newLevel, expRes.newExp, nil)
			DigNetwork.DigDropVFX.fireAll(p, won.id)
		end
	end))
end

function DigService.Destroy()
	_trove:Clean()
	table.clear(_playerLastDigEndTime)
	table.clear(_activeSessions)
end

return DigService
