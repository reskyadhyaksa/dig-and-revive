--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))

local Hotbar = require(script.Parent:WaitForChild("Hotbar"))

export type StoryProps = {
	controls: {
		onEquipShovel: () -> (),
		onOpenInventory: () -> (),
		onSelectShovel: () -> (),
	},
	target: Instance,
}

local story = {
	summary = "Pastel 3D tactile Hotbar with Shovel toggle, Inventory, and Shovel selector buttons",
	react = React,
	reactRoblox = ReactRoblox,
	controls = {},
	story = function(_props: StoryProps)
		return React.createElement(Hotbar, {
			onEquipShovel = function()
				print("[Story] Shovel Equip / Unequip Toggled")
			end,
			onOpenInventory = function()
				print("[Story] Opened Inventory")
			end,
			onSelectShovel = function()
				print("[Story] Open Shovel UI")
			end,
		})
	end,
}

return story
