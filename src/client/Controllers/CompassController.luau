--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local CompassTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("CompassTypes"))
local SignalTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("SignalTypes"))
local WaypointConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("WaypointConfig"))
local CompassMath = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("Components"):WaitForChild("Compass"):WaitForChild("CompassMath"))
local ZoneController = require(script.Parent:WaitForChild("ZoneController"))

type Waypoint = CompassTypes.Waypoint
type ProcessedWaypoint = CompassTypes.ProcessedWaypoint
type Signal<T...> = SignalTypes.Signal<T...>

local CompassController = {}
local _trove = Trove.new()
local _waypoints: { [string]: Waypoint } = {}
local _currentYaw = 0
local _processedList: { ProcessedWaypoint } = {}

CompassController.Updated = _trove:Construct(Signal) :: Signal<number, { ProcessedWaypoint }>

function CompassController.RegisterWaypoint(waypoint: Waypoint)
	_waypoints[waypoint.id] = waypoint
end

function CompassController.UnregisterWaypoint(id: string)
	_waypoints[id] = nil
end

local function GetPlayerRootPos(): Vector3?
	local lp = Players.LocalPlayer
	local char = if lp then lp.Character else nil
	local root = if char then char:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
	return if root then root.Position else nil
end

local function UpdateCompass()
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local yaw = CompassMath.GetYawFromVector(cam.CFrame.LookVector)
	_currentYaw = yaw

	local playerPos = GetPlayerRootPos() or cam.CFrame.Position
	local currentZone = ZoneController.GetCurrentZone()
	local currentIslandId: string? = if currentZone then currentZone.islandId else nil

	local processed: { ProcessedWaypoint } = {}

	for _, wp in pairs(_waypoints) do
		-- 1. Hide macro island waypoint if player is already inside that island
		local isCurrentIsland = (wp.targetIslandId ~= nil) and (currentIslandId == wp.targetIslandId)

		-- 2. Scope sub-waypoints to their specific island
		local isIslandMatch = (wp.islandId == nil) or (currentIslandId ~= nil and wp.islandId == currentIslandId)

		if not isCurrentIsland and isIslandMatch then
			local dist = CompassMath.GetDistance(wp.position, playerPos)
			local maxDist = wp.maxDistance or WaypointConfig.MaxTrackDistance

			if dist <= maxDist then
				local delta = CompassMath.GetDeltaAngle(wp.position, playerPos, yaw)
				local normOffset, isVis = CompassMath.ComputeNormalizedOffset(delta, WaypointConfig.VisibleFOV)
				table.insert(processed, {
					id = wp.id,
					name = wp.name,
					color = wp.color,
					symbol = wp.symbol,
					icon = wp.icon,
					islandId = wp.islandId,
					distance = dist,
					deltaAngle = delta,
					normalizedOffset = normOffset,
					isVisible = isVis,
				})
			end
		end
	end

	_processedList = processed
	CompassController.Updated:Fire(_currentYaw, _processedList)
end

function CompassController.Init()
	for _, wp in ipairs(WaypointConfig.Defaults) do
		CompassController.RegisterWaypoint(wp)
	end
	_trove:Connect(RunService.RenderStepped, UpdateCompass)
end

function CompassController.GetState(): (number, { ProcessedWaypoint })
	return _currentYaw, _processedList
end

function CompassController.Destroy()
	_trove:Clean()
	table.clear(_waypoints)
	table.clear(_processedList)
end

return CompassController
