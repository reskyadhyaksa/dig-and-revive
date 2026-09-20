--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local ZonePlus = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ZonePlus"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ZoneTypes = require(Shared:WaitForChild("Types"):WaitForChild("ZoneTypes"))
local SignalTypes = require(Shared:WaitForChild("Types"):WaitForChild("SignalTypes"))
local ZoneUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ZoneUtils"))

type Signal<T...> = SignalTypes.Signal<T...>
type ZoneInfo = ZoneTypes.ZoneInfo

local ZoneService = {}
local _trove = Trove.new()
local _registered: { [string]: any } = {}
local _playerZones: { [Player]: ZoneInfo } = {}

ZoneService.PlayerEnteredZone = _trove:Construct(Signal) :: Signal<Player, ZoneInfo>
ZoneService.PlayerExitedZone = _trove:Construct(Signal) :: Signal<Player, ZoneInfo>

function ZoneService.RegisterZone(zoneId: string, islandId: string, container: Instance)
	if _registered[zoneId] then return end
	local cfg = ZoneUtils.GetZoneConfig(zoneId)
	local displayName = if cfg then cfg.displayName else string.format("%s Zone", islandId)

	local zTrove = _trove:Extend()
	local ZoneConstructor = ZonePlus.new or (ZonePlus.Zone and ZonePlus.Zone.new)
	local zoneInstance = ZoneConstructor(container)
	zTrove:Add(function() zoneInstance:destroy() end)

	local info: ZoneInfo = { zoneId = zoneId, displayName = displayName, islandId = islandId, instance = container }

	local enterConn = zoneInstance.playerEntered:Connect(function(p)
		_playerZones[p] = info
		ZoneService.PlayerEnteredZone:Fire(p, info)
	end)
	zTrove:Add(function() enterConn:Disconnect() end)

	local exitConn = zoneInstance.playerExited:Connect(function(p)
		if _playerZones[p] and _playerZones[p].zoneId == zoneId then
			_playerZones[p] = nil
			ZoneService.PlayerExitedZone:Fire(p, info)
		end
	end)
	zTrove:Add(function() exitConn:Disconnect() end)

	for _, p in Players:GetPlayers() do
		task.spawn(function()
			if zoneInstance:findPlayer(p) then
				_playerZones[p] = info
				ZoneService.PlayerEnteredZone:Fire(p, info)
			end
		end)
	end

	_registered[zoneId] = { info = info, instance = zoneInstance, trove = zTrove }
end

local function ScanZones(zoneRoot: Instance)
	for _, island in zoneRoot:GetChildren() do
		local z = island:FindFirstChild("Zoning")
		if z and (z:IsA("Model") or z:IsA("Folder") or z:IsA("BasePart")) then
			ZoneService.RegisterZone(string.format("%s_Zoning", island.Name), island.Name, z)
		end
	end
end

function ZoneService.Init()
	_trove:Connect(Players.PlayerRemoving, function(p)
		local cur = _playerZones[p]
		if cur then
			_playerZones[p] = nil
			ZoneService.PlayerExitedZone:Fire(p, cur)
		end
	end)

	local root = Workspace:FindFirstChild("Zone")
	if root then
		ScanZones(root)
	else
		_trove:Connect(Workspace.ChildAdded, function(c)
			if c.Name == "Zone" then ScanZones(c) end
		end)
	end
end

function ZoneService.GetPlayerCurrentZone(p: Player): ZoneInfo?
	local cur = _playerZones[p]
	if cur then return cur end
	if next(_registered) == nil then
		local fallback: ZoneInfo = {
			zoneId = "Island1_Zoning",
			displayName = "Starter Island Dig Zone",
			islandId = "Island1",
			instance = nil,
		}
		return fallback
	end
	return nil
end

function ZoneService.Destroy()
	_trove:Clean()
	table.clear(_registered)
	table.clear(_playerZones)
end

return ZoneService
