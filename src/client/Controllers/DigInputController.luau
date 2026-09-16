--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local ZoneController = require(script.Parent:WaitForChild("ZoneController"))

local LocalPlayer = Players.LocalPlayer

local DigInputController = {}
local _trove = Trove.new()

local CHARGE_SPEED = 2.5
local SLOW_SPEED = 6
local NORMAL_SPEED = 16

local function GetHum(): Humanoid?
	local char = LocalPlayer.Character
	return if char then char:FindFirstChildOfClass("Humanoid") else nil
end

local function SetSpeed(s: number)
	local hum = GetHum()
	if hum then hum.WalkSpeed = s end
end

local function CheckGround(): boolean
	local char = LocalPlayer.Character
	local root: BasePart? = if char then char.PrimaryPart else nil
	if not root then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	return Workspace:Raycast(root.Position, Vector3.new(0, -6, 0), params) ~= nil
end

function DigInputController.BindChargeInput(callbacks: {
	onChargeStart: () -> boolean,
	onChargeStep: (power: number) -> (),
	onChargeEnd: (finalPower: number) -> (),
})
	local isCharging = false
	local renderConn: RBXScriptConnection? = nil
	local currentPower = 0

	local function stop()
		if not isCharging then return end
		isCharging = false
		if renderConn then renderConn:Disconnect() renderConn = nil end
		SetSpeed(NORMAL_SPEED)
		callbacks.onChargeEnd(currentPower)
	end

	local function start()
		if isCharging then return end
		if not CheckGround() then return end
		local zone = ZoneController.GetCurrentZone()
		if not zone then return end
		local char = LocalPlayer.Character
		local tool = if char then char:FindFirstChildWhichIsA("Tool") else nil
		if not tool or not ShovelUtils.GetShovelConfig(tool.Name) then return end

		if not callbacks.onChargeStart() then return end
		isCharging = true
		SetSpeed(SLOW_SPEED)

		local startTime = os.clock()
		renderConn = RunService.RenderStepped:Connect(function()
			local t = (os.clock() - startTime) * CHARGE_SPEED
			local cycle = t % 2
			currentPower = if cycle < 1 then cycle else 2 - cycle
			callbacks.onChargeStep(currentPower)
		end)
	end

	_trove:Connect(UserInputService.InputBegan, function(input, gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			start()
		end
	end)

	_trove:Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			stop()
		end
	end)
end

function DigInputController.Destroy()
	_trove:Clean()
end

return DigInputController
