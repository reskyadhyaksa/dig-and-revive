--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local MOBILE_BREAKPOINT_WIDTH = 700

export type DeviceInfo = {
	isMobile: boolean,
	viewportSize: Vector2,
}

local function useDeviceType(): DeviceInfo
	local currentCamera = Workspace.CurrentCamera
	local initialSize = if currentCamera then currentCamera.ViewportSize else Vector2.new(1920, 1080)

	local deviceInfo, setDeviceInfo = React.useState({
		isMobile = initialSize.X < MOBILE_BREAKPOINT_WIDTH,
		viewportSize = initialSize,
	})

	React.useEffect(function()
		local camera = Workspace.CurrentCamera
		if not camera then return end

		local function updateSize()
			local vp = camera.ViewportSize
			local mobile = vp.X < MOBILE_BREAKPOINT_WIDTH
			setDeviceInfo(function(prev)
				if prev.isMobile == mobile and prev.viewportSize == vp then
					return prev
				end
				return {
					isMobile = mobile,
					viewportSize = vp,
				}
			end)
		end

		updateSize()
		local conn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateSize)

		return function()
			conn:Disconnect()
		end
	end, {})

	return deviceInfo
end

return useDeviceType
