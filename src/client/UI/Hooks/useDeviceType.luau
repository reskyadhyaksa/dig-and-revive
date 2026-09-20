--!strict

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

export type DeviceType = "Mobile" | "Tablet" | "Console" | "PC"

export type DeviceInfo = {
	deviceType: DeviceType,
	isMobile: boolean,
	isTablet: boolean,
	isConsole: boolean,
	isPC: boolean,
	isTouch: boolean,
	viewportSize: Vector2,
}

local function getDeviceType(viewport: Vector2): (DeviceType, boolean)
	if GuiService:IsTenFootInterface() then
		return ("Console" :: DeviceType), false
	end

	local isTouch = if RunService:IsStudio()
		then UserInputService.TouchEnabled
		else (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)

	if isTouch then
		if math.min(viewport.X, viewport.Y) >= 600 then
			return ("Tablet" :: DeviceType), true
		else
			return ("Mobile" :: DeviceType), true
		end
	end

	return ("PC" :: DeviceType), false
end

local function computeDeviceInfo(viewport: Vector2): DeviceInfo
	local dtype: DeviceType, isTouch: boolean = getDeviceType(viewport)
	local info: DeviceInfo = {
		deviceType = dtype,
		isMobile = dtype == "Mobile",
		isTablet = dtype == "Tablet",
		isConsole = dtype == "Console",
		isPC = dtype == "PC",
		isTouch = isTouch,
		viewportSize = viewport,
	}
	return info
end

local function useDeviceType(): DeviceInfo
	local currentCamera = Workspace.CurrentCamera
	local initialSize = if currentCamera then currentCamera.ViewportSize else Vector2.new(1920, 1080)

	local deviceInfo, setDeviceInfo = React.useState(function()
		return computeDeviceInfo(initialSize)
	end)

	React.useEffect(function()
		local camera = Workspace.CurrentCamera
		if not camera then return end

		local function updateSize()
			local vp = camera.ViewportSize
			local newInfo = computeDeviceInfo(vp)
			setDeviceInfo(function(prev)
				if prev.deviceType == newInfo.deviceType and prev.viewportSize == vp then
					return prev
				end
				return newInfo
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
