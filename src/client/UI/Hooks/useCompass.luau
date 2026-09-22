--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local CompassController = require(script.Parent.Parent.Parent:WaitForChild("Controllers"):WaitForChild("CompassController"))
local CompassTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("CompassTypes"))

type ProcessedWaypoint = CompassTypes.ProcessedWaypoint

export type CompassHookState = {
	yawDeg: number,
	waypoints: { ProcessedWaypoint },
}

local function useCompass(): CompassHookState
	local initialYaw, initialWaypoints = CompassController.GetState()
	local state, setState = React.useState({
		yawDeg = initialYaw,
		waypoints = initialWaypoints,
	})

	React.useEffect(function()
		local conn = CompassController.Updated:Connect(function(yaw, waypoints)
			setState({ yawDeg = yaw, waypoints = waypoints })
		end)
		return function()
			conn:Disconnect()
		end
	end, {})

	return state
end

return useCompass
