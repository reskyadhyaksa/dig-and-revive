--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local DialogCameraConfig = require(Shared:WaitForChild("Configs"):WaitForChild("DialogCameraConfig"))
local DialogCameraUtils = require(Shared:WaitForChild("Utils"):WaitForChild("DialogCameraUtils"))
local NpcInteractController = require(script.Parent.NpcInteractController)

local DialogCameraController = {}
local _trove = Trove.new()
local _shotTrove: any = nil
local _saved: { cframe: CFrame, fov: number }? = nil

local function GetFocusPosition(npc: Instance): Vector3?
	local head = npc:FindFirstChild("Head")
	if head and head:IsA("BasePart") then return head.Position end
	if npc:IsA("Model") then return npc:GetPivot().Position end
	return if npc:IsA("BasePart") then npc.Position else nil
end

-- Local-only fade (LocalTransparencyModifier); the shot trove restores it.
local function FadeCharacter(shot: any, char: Model)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Decal") then
			part.LocalTransparencyModifier = DialogCameraConfig.PlayerFade
			shot:Add(function() part.LocalTransparencyModifier = 0 end)
		end
	end
end

local function StartShot(): any
	if _shotTrove then _shotTrove:Clean() end
	_shotTrove = _trove:Extend()
	return _shotTrove
end

local function Focus(_key: string, npc: Instance)
	local camera = workspace.CurrentCamera
	local char = Players.LocalPlayer.Character
	local root = if char then char:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
	local focusPos = GetFocusPosition(npc)
	if not camera or not root or not focusPos then return end

	local shot = StartShot()
	if not _saved then _saved = { cframe = camera.CFrame, fov = camera.FieldOfView } end
	camera.CameraType = Enum.CameraType.Scriptable
	FadeCharacter(shot, char :: Model)
	local goal = DialogCameraUtils.GetFocusCFrame(root.Position, focusPos, DialogCameraConfig)
	local info = TweenInfo.new(DialogCameraConfig.FocusTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(camera, info, { CFrame = goal, FieldOfView = DialogCameraConfig.FieldOfView })
	shot:Add(tween, "Cancel")
	tween:Play()
end

local function Release()
	local camera = workspace.CurrentCamera
	local saved = _saved
	if not camera or not saved then return end
	_saved = nil

	local shot = StartShot()
	local info = TweenInfo.new(DialogCameraConfig.ReturnTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(camera, info, { CFrame = saved.cframe, FieldOfView = saved.fov })
	shot:Add(tween, "Cancel")
	-- Always hand control back to the default camera, even if the tween is interrupted.
	shot:Add(function() camera.CameraType = Enum.CameraType.Custom end)
	shot:Connect(tween.Completed, function() shot:Clean() end)
	tween:Play()
end

function DialogCameraController.Init()
	_trove:Connect(NpcInteractController.DialogOpened, Focus)
	_trove:Connect(NpcInteractController.DialogClosed, Release)
	_trove:Connect(Players.LocalPlayer.CharacterRemoving, function()
		_saved = nil
		if _shotTrove then _shotTrove:Clean() end
		local camera = workspace.CurrentCamera
		if camera then camera.CameraType = Enum.CameraType.Custom end
	end)
end

function DialogCameraController.Destroy()
	_trove:Clean()
end

return DialogCameraController
