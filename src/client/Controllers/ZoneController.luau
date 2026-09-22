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

local function SetActiveZone(newZone: ZoneInfo?)
	if _currentZone == newZone then return end
	if _currentZone and newZone and _currentZone.zoneId == newZone.zoneId then return end
	local prev = _currentZone
	_currentZone = newZone
	if prev ~= nil or newZone ~= nil then
		ZoneController.CurrentZoneChanged:Fire(newZone)
	end
end

function ZoneController.RegisterZone(zoneId: string, islandId: string, container: Instance)
	if _registered[zoneId] then return end
	local cfg = ZoneUtils.GetZoneConfig(zoneId)
	local displayName = if cfg then cfg.displayName else string.format("%s Zone", islandId)

	local zTrove = _trove:Extend()
	local ZoneConstructor = ZonePlus.new or (ZonePlus.Zone and ZonePlus.Zone.new)
	local zoneInstance = ZoneConstructor(container)
	zTrove:Add(function() zoneInstance:destroy() end)

	local zoneInfo: ZoneInfo = { zoneId = zoneId, displayName = displayName, islandId = islandId, instance = container }

	local enterConn = zoneInstance.localPlayerEntered:Connect(function() SetActiveZone(zoneInfo) end)
	zTrove:Add(function() enterConn:Disconnect() end)

	local exitConn = zoneInstance.localPlayerExited:Connect(function()
		if _currentZone and _currentZone.zoneId == zoneId then SetActiveZone(nil) end
	end)
	zTrove:Add(function() exitConn:Disconnect() end)

	task.spawn(function()
		if zoneInstance:findLocalPlayer() then SetActiveZone(zoneInfo) end
	end)

	_registered[zoneId] = { zoneInfo = zoneInfo, instance = zoneInstance, trove = zTrove }
end

local function ScanIsland(island: Instance)
	if not island:IsA("Model") and not island:IsA("Folder") then return end
	local z = island:FindFirstChild("Zoning")
	if z and (z:IsA("Model") or z:IsA("Folder") or z:IsA("BasePart")) then
		ZoneController.RegisterZone(string.format("%s_Zoning", island.Name), island.Name, z)
	else
		local conn: RBXScriptConnection? = nil
		conn = island.ChildAdded:Connect(function(child)
			if child.Name == "Zoning" then
				if conn then conn:Disconnect() conn = nil end
				ZoneController.RegisterZone(string.format("%s_Zoning", island.Name), island.Name, child)
			end
		end)
		_trove:Add(function() if conn then conn:Disconnect() end end)
	end
end

local function ScanZones(zoneRoot: Instance)
	for _, island in zoneRoot:GetChildren() do ScanIsland(island) end
	_trove:Connect(zoneRoot.ChildAdded, ScanIsland)
end

function ZoneController.Init()
	local root = Workspace:FindFirstChild("Zone")
	if root then ScanZones(root) else
		_trove:Connect(Workspace.ChildAdded, function(c) if c.Name == "Zone" then ScanZones(c) end end)
	end
end

function ZoneController.GetCurrentZone(): ZoneInfo?
	if _currentZone then
		local reg = _registered[_currentZone.zoneId]
		if reg and reg.instance then
			local ok, inside = pcall(function() return reg.instance:findLocalPlayer() end)
			if ok and not inside then
				SetActiveZone(nil)
				return nil
			end
		end
		return _currentZone
	end

	for _, reg in pairs(_registered) do
		local ok, inside = pcall(function() return reg.instance:findLocalPlayer() end)
		if ok and inside then
			SetActiveZone(reg.zoneInfo)
			return _currentZone
		end
	end
	return nil
end

function ZoneController.Destroy()
	_trove:Clean()
	table.clear(_registered)
	_currentZone = nil
end

return ZoneController
