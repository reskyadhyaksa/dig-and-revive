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
local App = require(script.UI.App)

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- 1. Initialize Controllers
ZoneController.Init()
DigController.Init()
DropVFXController.Init()
OverheadController.Init()

-- 2. Mount React UI
local root = ReactRoblox.createRoot(Instance.new("Folder"))
root:render(ReactRoblox.createPortal(
	React.createElement(App),
	playerGui
))

print("[Client] Client & UI initialized successfully.")
