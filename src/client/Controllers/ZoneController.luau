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

local ZoneController = {}
ZoneController.__index = ZoneController

local _controllerTrove = Trove.new()
local _currentZone: ZoneInfo? = nil
local _registeredZones: { [string]: any } = {}

ZoneController.CurrentZoneChanged = _controllerTrove:Construct(Signal) :: Signal<ZoneInfo?>

function ZoneController.Init()
	ZoneController._DiscoverAndRegisterZones()
end

function ZoneController._DiscoverAndRegisterZones()
	local zoneRoot = Workspace:FindFirstChild("Zone")
	if not zoneRoot then
		local zoneConn = Workspace.ChildAdded:Connect(function(child)
			if child.Name == "Zone" then
				ZoneController._ScanZoneFolder(child)
			end
		end)
		_controllerTrove:Add(zoneConn)
		return
	end

	ZoneController._ScanZoneFolder(zoneRoot)
end

function ZoneController._ScanZoneFolder(zoneRoot: Instance)
	for _, island in zoneRoot:GetChildren() do
		local zoningContainer = island:FindFirstChild("Zoning")
		if zoningContainer and (zoningContainer:IsA("Model") or zoningContainer:IsA("Folder") or zoningContainer:IsA("BasePart")) then
			local zoneId = string.format("%s_Zoning", island.Name)
			ZoneController.RegisterZone(zoneId, island.Name, zoningContainer)
		end
	end

	local childConn = zoneRoot.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "Zoning" and descendant.Parent and descendant.Parent.Parent == zoneRoot then
			local island = descendant.Parent
			local zoneId = string.format("%s_Zoning", island.Name)
			if not _registeredZones[zoneId] then
				ZoneController.RegisterZone(zoneId, island.Name, descendant)
			end
		end
	end)
	_controllerTrove:Add(childConn)
end

function ZoneController.RegisterZone(zoneId: string, islandId: string, container: Instance)
	if _registeredZones[zoneId] then
		return
	end

	local config = ZoneConfig.GetZoneConfig(zoneId)
	local displayName = if config then config.displayName else string.format("%s Zone", islandId)

	local zoneTrove = _controllerTrove:Extend()
	local ZoneConstructor = ZonePlus.new or (ZonePlus.Zone and ZonePlus.Zone.new)
	local zoneInstance = ZoneConstructor(container)
	zoneTrove:Add(function()
		zoneInstance:destroy()
	end)

	local zoneInfo: ZoneInfo = {
		zoneId = zoneId,
		displayName = displayName,
		islandId = islandId,
		instance = container,
	}

	local enteredConn = zoneInstance.localPlayerEntered:Connect(function()
		_currentZone = zoneInfo
		ZoneController.CurrentZoneChanged:Fire(zoneInfo)
	end)
	zoneTrove:Add(function()
		enteredConn:Disconnect()
	end)

	local exitedConn = zoneInstance.localPlayerExited:Connect(function()
		if _currentZone and _currentZone.zoneId == zoneId then
			_currentZone = nil
			ZoneController.CurrentZoneChanged:Fire(nil)
		end
	end)
	zoneTrove:Add(function()
		exitedConn:Disconnect()
	end)

	_registeredZones[zoneId] = {
		zoneInfo = zoneInfo,
		zoneInstance = zoneInstance,
		trove = zoneTrove,
	}
end

function ZoneController.GetCurrentZone(): ZoneInfo?
	return _currentZone
end

function ZoneController.Destroy()
	_controllerTrove:Clean()
	table.clear(_registeredZones)
	_currentZone = nil
end

return ZoneController
