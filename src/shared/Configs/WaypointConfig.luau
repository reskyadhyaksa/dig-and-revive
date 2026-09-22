--!strict

local CompassTypes = require(script.Parent.Parent.Types.CompassTypes)

type Waypoint = CompassTypes.Waypoint

local DefaultWaypoints: { Waypoint } = {
	-- Macro Island Waypoints (Hidden when already inside that specific island)
	{
		id = "Zone_Island1",
		name = "Island 1",
		position = Vector3.new(0, 5, 0),
		color = Color3.fromHex("#FFE082"),
		symbol = "🏝",
		targetIslandId = "Island1",
	},
	{
		id = "Zone_Island2",
		name = "Island 2",
		position = Vector3.new(450, 15, 300),
		color = Color3.fromHex("#8EE3F5"),
		symbol = "🏝",
		targetIslandId = "Island2",
	},

	-- Island 1 Local Sub-Waypoints (Visible inside Island 1; displays 'Here' when < 15m)
	{
		id = "Island1_Buy",
		name = "Buy",
		position = Vector3.new(105, 4.599, -36),
		color = Color3.fromHex("#FFB7A1"),
		symbol = "🛒",
		islandId = "Island1",
		maxDistance = 600,
	},
	{
		id = "Island1_Sell",
		name = "Sell",
		position = Vector3.new(89, 4.599, -59),
		color = Color3.fromHex("#8CE5B0"),
		symbol = "💰",
		islandId = "Island1",
		maxDistance = 600,
	},
}

local WaypointConfig = {
	Defaults = DefaultWaypoints,
	VisibleFOV = 75,
	MaxTrackDistance = 2500,
}

return table.freeze(WaypointConfig)
