--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelConfig"))
local DropConfig = require(Shared:WaitForChild("Configs"):WaitForChild("DropConfig"))
local LevelConfig = require(Shared:WaitForChild("Configs"):WaitForChild("LevelConfig"))
local PowerBarHelper = require(Shared:WaitForChild("Common"):WaitForChild("PowerBarHelper"))
local DropTypes = require(Shared:WaitForChild("Types"):WaitForChild("DropTypes"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local ZoneService = require(script.Parent:WaitForChild("ZoneService"))
local PlayerService = require(script.Parent:WaitForChild("PlayerService"))

type DropItem = DropTypes.DropItem

type DigSession = {
	player: Player,
	islandId: string,
	power: number,
	drop: DropItem,
	currentHp: number,
	maxHp: number,
	expireTime: number,
	lastSwingTime: number,
}

local DigService = {}
DigService.__index = DigService

local _serviceTrove = Trove.new()
local _playerLastDigEndTime: { [Player]: number } = {}
local _activeSessions: { [Player]: DigSession } = {}

local DEFAULT_MINIGAME_DURATION = 15.0 -- 15 seconds

local function GetNodeHpByTier(tier: DropTypes.RarityTier): number
	if tier == "Common" then
		return 3
	elseif tier == "Uncommon" then
		return 4
	elseif tier == "Epic" then
		return 5
	elseif tier == "Legendary" then
		return 6
	elseif tier == "Mythic" then
		return 8
	elseif tier == "Secret" then
		return 10
	end
	return 3
end

function DigService.Init()
	_serviceTrove:Connect(Players.PlayerRemoving, function(player: Player)
		_playerLastDigEndTime[player] = nil
		_activeSessions[player] = nil
	end)

	-- 1. Handle Start Dig Request from Client
	local disconnectStart = DigNetwork.StartDigRequest.on(function(player: Player, power: number, islandId: string)
		local char = player.Character
		if not char then return end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end

		local tool = char:FindFirstChildWhichIsA("Tool")
		if not tool then
			local curLevel = PlayerService.GetPlayerLevel(player)
			local curExp = PlayerService.GetPlayerExp(player)
			DigNetwork.MinigameComplete.fire(player, false, nil, 0, 0, curLevel, curExp, "Tidak memegang sekop!")
			return
		end

		local shovelCfg = ShovelConfig.GetShovelConfig(tool.Name)
		if not shovelCfg then
			local curLevel = PlayerService.GetPlayerLevel(player)
			local curExp = PlayerService.GetPlayerExp(player)
			DigNetwork.MinigameComplete.fire(player, false, nil, 0, 0, curLevel, curExp, "Sekop tidak valid!")
			return
		end

		-- Validasi Cooldown delay setelah cycle dig sebelumnya selesai
		local now = os.clock()
		local lastEndTime = _playerLastDigEndTime[player] or 0
		if now - lastEndTime < shovelCfg.cooldown then
			local curLevel = PlayerService.GetPlayerLevel(player)
			local curExp = PlayerService.GetPlayerExp(player)
			DigNetwork.MinigameComplete.fire(player, false, nil, 0, 0, curLevel, curExp, "Harap tunggu sebelum menggali lagi!")
			return
		end

		-- Validasi Zona
		local currentZone = ZoneService.GetPlayerCurrentZone(player)
		if not currentZone or currentZone.islandId ~= islandId then
			local curLevel = PlayerService.GetPlayerLevel(player)
			local curExp = PlayerService.GetPlayerExp(player)
			DigNetwork.MinigameComplete.fire(player, false, nil, 0, 0, curLevel, curExp, "Zona tidak valid!")
			return
		end

		-- Hitung Total Luck: PowerBarMultiplier * (BaseLuck(100) + LevelBonus + ShovelBonus) / 100
		local normalizedPower = math.clamp(power or 0, 0, 1)
		local powerMultiplier = PowerBarHelper.GetMultiplier(normalizedPower)
		local levelMultiplier = PlayerService.GetLevelLuck(player)
		local shovelLuckBonus = shovelCfg.luckBonus or 0
		local playerLuckMultiplier = levelMultiplier + (shovelLuckBonus / 100)
		local totalLuck = powerMultiplier * playerLuckMultiplier

		-- Roll RNG Drop
		local drop = DropConfig.RollDrop(currentZone.islandId, totalLuck)

		if not drop then
			_playerLastDigEndTime[player] = now
			local curLevel = PlayerService.GetPlayerLevel(player)
			local curExp = PlayerService.GetPlayerExp(player)
			DigNetwork.MinigameComplete.fire(player, false, nil, 0, 0, curLevel, curExp, "Tidak ada item yang ditemukan.")
			return
		end

		local nodeHp = GetNodeHpByTier(drop.tier)

		local session: DigSession = {
			player = player,
			islandId = islandId,
			power = normalizedPower,
			drop = drop,
			currentHp = nodeHp,
			maxHp = nodeHp,
			expireTime = now + DEFAULT_MINIGAME_DURATION,
			lastSwingTime = 0,
		}

		_activeSessions[player] = session

		-- Send minigame start parameters to client
		DigNetwork.StartMinigame.fire(player, drop.tier, nodeHp, DEFAULT_MINIGAME_DURATION)
	end)

	-- 2. Handle Player Tap / Swing Request
	local disconnectSwing = DigNetwork.SwingRequest.on(function(player: Player)
		local session = _activeSessions[player]
		if not session then return end

		local now = os.clock()

		-- Check if session expired
		if now > session.expireTime then
			_activeSessions[player] = nil
			_playerLastDigEndTime[player] = now
			local curLevel = PlayerService.GetPlayerLevel(player)
			local curExp = PlayerService.GetPlayerExp(player)
			DigNetwork.MinigameComplete.fire(player, false, nil, 0, 0, curLevel, curExp, "Waktu minigame habis!")
			return
		end

		-- Debounce anti-spam swing (minimum 0.08s between clicks)
		if now - session.lastSwingTime < 0.08 then
			return
		end
		session.lastSwingTime = now

		-- Reduce Node HP
		session.currentHp = math.max(0, session.currentHp - 1)

		DigNetwork.MinigameHit.fire(player, session.currentHp, session.maxHp)

		-- Check Win condition
		if session.currentHp <= 0 then
			local wonDrop = session.drop
			_activeSessions[player] = nil
			_playerLastDigEndTime[player] = now

			-- Award EXP based on item rarity tier
			local expReward = LevelConfig.GetTierExp(wonDrop.tier)
			local expResult = PlayerService.AddExp(player, expReward)

			-- Notify client that minigame is won with updated level & exp
			DigNetwork.MinigameComplete.fire(
				player,
				true,
				wonDrop.id,
				1,
				expResult.gainedExp,
				expResult.newLevel,
				expResult.newExp,
				nil
			)

			-- Broadcast 3D Drop VFX simulation to all clients
			DigNetwork.DigDropVFX.fireAll(player, wonDrop.id)
		end
	end)

	_serviceTrove:Add(disconnectStart)
	_serviceTrove:Add(disconnectSwing)
end

function DigService.Destroy()
	_serviceTrove:Clean()
	table.clear(_playerLastDigEndTime)
	table.clear(_activeSessions)
end

return DigService
