--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))
local Signal = require(Packages:WaitForChild("Signal"))
local ZonePlus = require(Packages:WaitForChild("ZonePlus"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ZoneTypes = require(Shared:WaitForChild("Types"):WaitForChild("ZoneTypes"))
local SignalTypes = require(Shared:WaitForChild("Types"):WaitForChild("SignalTypes"))
local ZoneConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ZoneConfig"))

type Signal<T...> = SignalTypes.Signal<T...>
type ZoneInfo = ZoneTypes.ZoneInfo
type ZoneConfigType = ZoneTypes.ZoneConfig

type RegisteredZone = {
	config: ZoneConfigType,
	zoneInstance: any, -- ZonePlus instance
	container: Instance,
	trove: any,
}

local ZoneService = {}
ZoneService.__index = ZoneService

local _serviceTrove = Trove.new()
local _registeredZones: { [string]: RegisteredZone } = {}
local _playerZones: { [Player]: ZoneInfo } = {}

ZoneService.PlayerEnteredZone = _serviceTrove:Construct(Signal) :: Signal<Player, ZoneInfo>
ZoneService.PlayerExitedZone = _serviceTrove:Construct(Signal) :: Signal<Player, ZoneInfo>

function ZoneService.Init()
	-- Clean up on player disconnect
	_serviceTrove:Connect(Players.PlayerRemoving, function(player: Player)
		local currentZone = _playerZones[player]
		if currentZone then
			_playerZones[player] = nil
			ZoneService.PlayerExitedZone:Fire(player, currentZone)
		end
	end)

	ZoneService._DiscoverAndRegisterZones()
end

function ZoneService._DiscoverAndRegisterZones()
	local zoneRoot = Workspace:FindFirstChild("Zone")
	if not zoneRoot then
		-- Listen in case Zone folder is loaded asynchronously
		local zoneConn = Workspace.ChildAdded:Connect(function(child)
			if child.Name == "Zone" then
				ZoneService._ScanZoneFolder(child)
			end
		end)
		_serviceTrove:Add(zoneConn)
		return
	end

	ZoneService._ScanZoneFolder(zoneRoot)
end

function ZoneService._ScanZoneFolder(zoneRoot: Instance)
	for _, island in zoneRoot:GetChildren() do
		local zoningContainer = island:FindFirstChild("Zoning")
		if zoningContainer and (zoningContainer:IsA("Model") or zoningContainer:IsA("Folder") or zoningContainer:IsA("BasePart")) then
			local zoneId = string.format("%s_Zoning", island.Name)
			ZoneService.RegisterZone(zoneId, island.Name, zoningContainer)
		end
	end

	-- Listen for new islands/zoning added at runtime
	local childConn = zoneRoot.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "Zoning" and descendant.Parent and descendant.Parent.Parent == zoneRoot then
			local island = descendant.Parent
			local zoneId = string.format("%s_Zoning", island.Name)
			if not _registeredZones[zoneId] then
				ZoneService.RegisterZone(zoneId, island.Name, descendant)
			end
		end
	end)
	_serviceTrove:Add(childConn)
end

function ZoneService.RegisterZone(zoneId: string, islandId: string, container: Instance)
	if _registeredZones[zoneId] then
		return
	end

	local config: ZoneConfigType = ZoneConfig.GetZoneConfig(zoneId) or {
		zoneId = zoneId,
		displayName = string.format("%s Zone", islandId),
		islandId = islandId,
		containerPath = string.format("%s.Zoning", islandId),
		allowedMaterials = {
			Enum.Material.Grass,
			Enum.Material.Sand,
			Enum.Material.Slate,
		},
		dropTableId = string.format("%s_DEFAULT_DROPS", string.upper(islandId)),
		minToolTier = 1,
	}

	local zoneTrove = _serviceTrove:Extend()
	local ZoneConstructor = ZonePlus.new or (ZonePlus.Zone and ZonePlus.Zone.new)
	local zoneInstance = ZoneConstructor(container)
	zoneTrove:Add(function()
		zoneInstance:destroy()
	end)

	local zoneInfo: ZoneInfo = {
		zoneId = zoneId,
		displayName = config.displayName,
		islandId = islandId,
		instance = container,
	}

	local enteredConn = zoneInstance.playerEntered:Connect(function(player: Player)
		_playerZones[player] = zoneInfo
		ZoneService.PlayerEnteredZone:Fire(player, zoneInfo)
	end)
	zoneTrove:Add(function()
		enteredConn:Disconnect()
	end)

	local exitedConn = zoneInstance.playerExited:Connect(function(player: Player)
		if _playerZones[player] and _playerZones[player].zoneId == zoneId then
			_playerZones[player] = nil
			ZoneService.PlayerExitedZone:Fire(player, zoneInfo)
		end
	end)
	zoneTrove:Add(function()
		exitedConn:Disconnect()
	end)

	_registeredZones[zoneId] = {
		config = config,
		zoneInstance = zoneInstance,
		container = container,
		trove = zoneTrove,
	}
end

function ZoneService.GetPlayerCurrentZone(player: Player): ZoneInfo?
	return _playerZones[player]
end

function ZoneService.GetRegisteredZone(zoneId: string): RegisteredZone?
	return _registeredZones[zoneId]
end

function ZoneService.IsPartInZone(part: BasePart, zoneId: string): boolean
	local registered = _registeredZones[zoneId]
	if not registered then
		return false
	end

	-- Check hierarchy first (fast path)
	if part:IsDescendantOf(registered.container) then
		return true
	end

	-- Spatial fallback check via ZonePlus
	return registered.zoneInstance:findPart(part)
end

function ZoneService.GetDiggableMaterial(part: BasePart): Enum.Material?
	local mat = part.Material
	if mat == Enum.Material.Slate or mat == Enum.Material.Sand or mat == Enum.Material.Grass then
		return mat
	end
	return nil
end

function ZoneService.ValidateDigTarget(player: Player, part: BasePart): (boolean, string?)
	local material = ZoneService.GetDiggableMaterial(part)
	if not material then
		return false, "Material is not diggable"
	end

	local currentZone = _playerZones[player]
	if not currentZone then
		return false, "Player is not inside an active dig zone"
	end

	local isDiggableInZone = ZoneConfig.IsMaterialDiggableInZone(currentZone.zoneId, material)
	if not isDiggableInZone then
		return false, "Material cannot be dug in this zone"
	end

	return true, nil
end

function ZoneService.Destroy()
	_serviceTrove:Clean()
	table.clear(_registeredZones)
	table.clear(_playerZones)
end

return ZoneService
