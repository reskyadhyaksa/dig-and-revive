--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelConfig"))
local DropConfig = require(Shared:WaitForChild("Configs"):WaitForChild("DropConfig"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local ZoneService = require(script.Parent:WaitForChild("ZoneService"))

local DigService = {}
DigService.__index = DigService

local _serviceTrove = Trove.new()
local _playerLastDigTime: { [Player]: number } = {}

function DigService.Init()
	_serviceTrove:Connect(Players.PlayerRemoving, function(player)
		_playerLastDigTime[player] = nil
	end)

	local disconnect = DigNetwork.DigRequest.on(function(player: Player, power: number, islandId: string)
		-- 1. Validasi Keberadaan Tool
		local char = player.Character
		if not char then return end
		
		local tool = char:FindFirstChildWhichIsA("Tool")
		if not tool then return end
		
		local shovelCfg = ShovelConfig.GetShovelConfig(tool.Name)
		if not shovelCfg then return end -- Bukan shovel valid
		
		-- 2. Validasi Cooldown (Server-Side Debounce Anti Exploit)
		local now = os.clock()
		local lastTime = _playerLastDigTime[player] or 0
		if now - lastTime < shovelCfg.cooldown then
			DigNetwork.DigResult.fire(player, false, nil, 0, "Menggali terlalu cepat!", player)
			return
		end
		
		-- 3. Validasi Zona
		local currentZone = ZoneService.GetPlayerCurrentZone(player)
		if not currentZone or currentZone.islandId ~= islandId then
			DigNetwork.DigResult.fire(player, false, nil, 0, "Zona tidak valid", player)
			return
		end
		
		-- Catat waktu valid
		_playerLastDigTime[player] = now
		
		-- 4. Roll RNG dengan Bonus Power
		local normalizedPower = math.clamp(power or 0, 0, 1)
		local drop = DropConfig.RollDrop(currentZone.islandId, normalizedPower)
		
		if drop then
			-- (Di masa depan: Tambahkan item ke Inventory via DataStore / Reflex State)
			
			-- 5. Broadcast VFX ke Semua Client
			-- VFX dimainkan di semua client agar pemain lain melihat item meloncat dari punggung pemain yang menggali
			DigNetwork.DigResult.fireAll(true, drop.id, 1, nil, player)
		else
			DigNetwork.DigResult.fire(player, false, nil, 0, "Tidak mendapatkan apa-apa", player)
		end
	end)

	_serviceTrove:Add(disconnect)
end

function DigService.Destroy()
	_serviceTrove:Clean()
	table.clear(_playerLastDigTime)
end

return DigService
