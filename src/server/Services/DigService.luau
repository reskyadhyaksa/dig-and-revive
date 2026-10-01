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
local DigMinigameConfig = require(Shared:WaitForChild("Configs"):WaitForChild("DigMinigameConfig"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local ZoneService = require(script.Parent:WaitForChild("ZoneService"))
local PlayerService = require(script.Parent:WaitForChild("PlayerService"))
local IndexService = require(script.Parent:WaitForChild("IndexService"))
local InventoryRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("InventoryRepository"))
local DigSessionHelper = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("DigSessionHelper"))

type DropItem = DropTypes.DropItem

local DigService = {}
local _trove = Trove.new()
local _playerLastDigEndTime: { [Player]: number } = {}
local _forcedNextTier: { [Player]: string } = {}

local function SendFail(p: Player, msg: string)
	DigNetwork.MinigameComplete.fire(p, false, nil, 0, 0, PlayerService.GetPlayerLevel(p), PlayerService.GetPlayerExp(p), msg)
end

function DigService.SetForcedNextTier(p: Player, tier: string?)
	_forcedNextTier[p] = tier
end

function DigService.GetForcedNextTier(p: Player): string?
	return _forcedNextTier[p]
end

function DigService.Init()
	_trove:Connect(Players.PlayerRemoving, function(p)
		_playerLastDigEndTime[p] = nil
		_forcedNextTier[p] = nil
		DigSessionHelper.Remove(p)
	end)

	_trove:Add(DigNetwork.StartDigRequest.on(function(p: Player, power: number, islandId: string)
		local char = p.Character
		if not char or not char:FindFirstChildOfClass("Humanoid") then return end
		local forcedTier = _forcedNextTier[p]
		if forcedTier then _forcedNextTier[p] = nil end

		local tool = char:FindFirstChildWhichIsA("Tool")
		local shovelCfg = if tool then ShovelUtils.GetShovelConfig(ShovelUtils.ResolveToolShovelId(tool:GetAttribute("ShovelId"), tool.Name)) else nil
		if not shovelCfg and not forcedTier then
			SendFail(p, "No valid shovel equipped!")
			return
		end

		local now = os.clock()
		if not forcedTier and shovelCfg and (now - (_playerLastDigEndTime[p] or 0) < shovelCfg.cooldown) then
			SendFail(p, "Please wait before digging again!")
			return
		end

		local zone = ZoneService.GetPlayerCurrentZone(p)
		local targetIslandId: string = if zone then zone.islandId else islandId
		local drop: DropItem? = if typeof(forcedTier) == "string" then DropUtils.GetDropByTier(targetIslandId, forcedTier)
			else DropUtils.RollDrop(targetIslandId, PowerBarHelper.GetMultiplier(math.clamp(power or 0, 0, 1)) * PlayerService.GetTotalPlayerLuck(p))
		if not drop then
			_playerLastDigEndTime[p] = now
			SendFail(p, "No item found.")
			return
		end

		local validDrop: DropItem = drop
		local duration = if forcedTier then 60.0 else DigMinigameConfig.Duration
		local damage = if forcedTier then 999 else math.max(1, math.floor((if shovelCfg then shovelCfg.digPower else 100) / 10))
		local session = DigSessionHelper.Create(p, targetIslandId, power, validDrop, duration, damage)
		DigNetwork.StartMinigame.fire(p, tostring(validDrop.tier), session.maxHp, duration)
	end))

	_trove:Add(DigNetwork.SwingRequest.on(function(p: Player)
		local s = DigSessionHelper.Get(p)
		if not s then return end
		local now = os.clock()
		if now > s.expireTime then
			DigSessionHelper.Remove(p)
			_playerLastDigEndTime[p] = now
			SendFail(p, "Minigame time expired!")
			return
		end

		local swung, isComplete = DigSessionHelper.ProcessSwing(s, now)
		if not swung then return end

		DigNetwork.MinigameHit.fire(p, s.currentHp, s.maxHp)
		if isComplete then
			local won = s.drop
			DigSessionHelper.Remove(p)
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
	table.clear(_forcedNextTier)
	DigSessionHelper.Clear()
end

return DigService
