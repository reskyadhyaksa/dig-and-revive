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

DigInputController.CHARGE_SPEED = 2.5
DigInputController.SLOW_SPEED = 4
DigInputController.NORMAL_SPEED = 16

local function GetHum(): Humanoid?
	local char = LocalPlayer.Character
	return if char then char:FindFirstChildOfClass("Humanoid") else nil
end

function DigInputController.SetSpeed(s: number)
	local hum = GetHum()
	if hum then hum.WalkSpeed = s end
end

local function CheckGround(): boolean
	local char = LocalPlayer.Character
	local root: BasePart? = if char then (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")) :: BasePart? else nil
	if not root then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	return Workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params) ~= nil
end

local function IsPointerOverGui(pos: Vector3): boolean
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return false end
	for _, gui in ipairs(playerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)) do
		if gui.Visible and (gui:IsA("GuiButton") or gui.Active or gui:IsA("TextBox") or gui:IsA("ScrollingFrame")) then
			return true
		end
	end
	return false
end

function DigInputController.BindChargeInput(callbacks: {
	onChargeStart: () -> boolean,
	onChargeStep: (power: number) -> (),
	onChargeEnd: (finalPower: number) -> (),
	onTap: (() -> ())?,
})
	local isCharging = false
	local renderConn: RBXScriptConnection? = nil
	local currentPower = 0

	local function stop()
		if not isCharging then return end
		isCharging = false
		if renderConn then renderConn:Disconnect() renderConn = nil end
		callbacks.onChargeEnd(currentPower)
	end

	local function start()
		if isCharging or not CheckGround() then return end
		local zone = ZoneController.GetCurrentZone()
		if not zone then return end
		local char = LocalPlayer.Character
		local tool = if char then char:FindFirstChildWhichIsA("Tool") else nil
		local shovelId = if tool then (tool:GetAttribute("ShovelId") or tool.Name) else nil
		if not shovelId or not ShovelUtils.GetShovelConfig(tostring(shovelId)) then return end

		if not callbacks.onChargeStart() then return end
		isCharging = true
		DigInputController.SetSpeed(DigInputController.SLOW_SPEED)

		local startTime = os.clock()
		renderConn = RunService.RenderStepped:Connect(function()
			local t = (os.clock() - startTime) * DigInputController.CHARGE_SPEED
			local cycle = t % 2
			currentPower = if cycle < 1 then cycle else 2 - cycle
			callbacks.onChargeStep(currentPower)
		end)
	end

	_trove:Connect(UserInputService.InputBegan, function(input, gpe)
		if gpe or UserInputService:GetFocusedTextBox() ~= nil then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if IsPointerOverGui(input.Position) then return end
			if callbacks.onTap then callbacks.onTap() end
			start()
		end
	end)

	_trove:Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			stop()
		end
	end)

	local function bindChar(char: Model)
		char.ChildRemoved:Connect(function(child) if child:IsA("Tool") then stop() end end)
	end
	if LocalPlayer.Character then bindChar(LocalPlayer.Character) end
	_trove:Connect(LocalPlayer.CharacterAdded, bindChar)
end

function DigInputController.Destroy()
	_trove:Clean()
end

return DigInputController
