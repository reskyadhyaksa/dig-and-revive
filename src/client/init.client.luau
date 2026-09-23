--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))

local ZoneController = require(script.Controllers.ZoneController)
local DigController = require(script.Controllers.DigController)
local DropVFXController = require(script.Controllers.DropVFXController)
local OverheadController = require(script.Controllers.OverheadController)
local CompassController = require(script.Controllers.CompassController)
local RevivalController = require(script.Controllers.RevivalController)
local App = require(script.UI.App)

local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Disable Roblox default backpack hotbar overlay
task.spawn(function()
	local success = false
	while not success do
		success = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end)
		if not success then task.wait(0.1) end
	end
end)

-- 1. Initialize Controllers
ZoneController.Init()
DigController.Init()
DropVFXController.Init()
OverheadController.Init()
CompassController.Init()
RevivalController.Init()

-- 2. Mount React UI
local root = ReactRoblox.createRoot(Instance.new("Folder"))
root:render(ReactRoblox.createPortal(
	React.createElement(App),
	playerGui
))

print("[Client] Client & UI initialized successfully.")
