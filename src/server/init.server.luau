--!strict

local ZoneService = require(script.Services.ZoneService)
local ShovelService = require(script.Services.ShovelService)
local PlayerService = require(script.Services.PlayerService)
local DigService = require(script.Services.DigService)

-- 1. Initialize Core Services
PlayerService.Init()
ZoneService.Init()
ShovelService.Init()
DigService.Init()

ZoneService.PlayerEnteredZone:Connect(function(player, zoneInfo)
	print(string.format("[ZoneService] Player '%s' entered zone: %s (%s)", player.Name, zoneInfo.displayName, zoneInfo.zoneId))
end)

ZoneService.PlayerExitedZone:Connect(function(player, zoneInfo)
	print(string.format("[ZoneService] Player '%s' exited zone: %s (%s)", player.Name, zoneInfo.displayName, zoneInfo.zoneId))
end)

print("[Server] Server initialized successfully.")
