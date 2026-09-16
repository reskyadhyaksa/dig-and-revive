--!strict

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

local ZoneController = {}
local _trove = Trove.new()
local _currentZone: ZoneInfo? = nil
local _registered: { [string]: any } = {}

ZoneController.CurrentZoneChanged = _trove:Construct(Signal) :: Signal<ZoneInfo?>

function ZoneController.RegisterZone(zoneId: string, islandId: string, container: Instance)
	if _registered[zoneId] then return end
	local cfg = ZoneUtils.GetZoneConfig(zoneId)
	local displayName = if cfg then cfg.displayName else string.format("%s Zone", islandId)

	local zTrove = _trove:Extend()
	local ZoneConstructor = ZonePlus.new or (ZonePlus.Zone and ZonePlus.Zone.new)
	local zoneInstance = ZoneConstructor(container)
	zTrove:Add(function() zoneInstance:destroy() end)

	local zoneInfo: ZoneInfo = {
		zoneId = zoneId, displayName = displayName, islandId = islandId, instance = container,
	}

	zTrove:Connect(zoneInstance.localPlayerEntered, function()
		_currentZone = zoneInfo
		ZoneController.CurrentZoneChanged:Fire(zoneInfo)
	end)

	zTrove:Connect(zoneInstance.localPlayerExited, function()
		if _currentZone and _currentZone.zoneId == zoneId then
			_currentZone = nil
			ZoneController.CurrentZoneChanged:Fire(nil)
		end
	end)

	_registered[zoneId] = { zoneInfo = zoneInfo, trove = zTrove }
end

local function ScanZones(zoneRoot: Instance)
	for _, island in zoneRoot:GetChildren() do
		local z = island:FindFirstChild("Zoning")
		if z and (z:IsA("Model") or z:IsA("Folder") or z:IsA("BasePart")) then
			ZoneController.RegisterZone(string.format("%s_Zoning", island.Name), island.Name, z)
		end
	end
end

function ZoneController.Init()
	local root = Workspace:FindFirstChild("Zone")
	if root then
		ScanZones(root)
	else
		_trove:Connect(Workspace.ChildAdded, function(c)
			if c.Name == "Zone" then ScanZones(c) end
		end)
	end
end

function ZoneController.GetCurrentZone(): ZoneInfo?
	return _currentZone
end

function ZoneController.Destroy()
	_trove:Clean()
	table.clear(_registered)
	_currentZone = nil
end

return ZoneController
