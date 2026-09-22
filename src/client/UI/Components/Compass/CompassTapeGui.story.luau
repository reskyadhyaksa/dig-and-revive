--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ReactRoblox"))

local CompassTapeGui = require(script.Parent:WaitForChild("CompassTapeGui"))
local CompassTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("CompassTypes"))

type ProcessedWaypoint = CompassTypes.ProcessedWaypoint

local function StoryComponent(): any
	local yaw, setYaw = React.useState(0)

	React.useEffect(function()
		local conn = RunService.RenderStepped:Connect(function(dt: number)
			setYaw(function(prev) return (prev + dt * 25) % 360 end)
		end)
		return function() conn:Disconnect() end
	end, {})

	local sampleWaypoints: { ProcessedWaypoint } = {
		{
			id = "1", name = "Spawn Point", color = Color3.fromHex("#FFE082"),
			symbol = "★", distance = 42, deltaAngle = -15, normalizedOffset = 0.42, isVisible = true,
		},
		{
			id = "2", name = "Dig Zone", color = Color3.fromHex("#8CE5B0"),
			symbol = "⛏", distance = 120, deltaAngle = 25, normalizedOffset = 0.61, isVisible = true,
		},
		{
			id = "3", name = "Merchant", color = Color3.fromHex("#FFB7A1"),
			symbol = "🏪", distance = 350, deltaAngle = -35, normalizedOffset = 0.32, isVisible = true,
		},
	}

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(20, 25, 35),
	}, {
		Compass = React.createElement(CompassTapeGui, {
			yawDeg = yaw,
			waypoints = sampleWaypoints,
			visible = true,
		}),
	})
end

return {
	react = React,
	reactRoblox = ReactRoblox,
	story = StoryComponent,
}
