--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))

local StatsHUD = require(script.Parent:WaitForChild("StatsHUD"))

export type StoryProps = {
	controls: {
		level: number,
		exp: number,
		requiredExp: number,
		coins: number,
		luckMultiplier: number,
	},
	target: Instance,
}

local story = {
	summary = "3D Procedural Bottom-Left Persistent Stats HUD (Level, EXP Bar, Coins, Luck)",
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		level = 3,
		exp = 262,
		requiredExp = 579,
		coins = 12500,
		luckMultiplier = 1.15,
	},
	story = function(props: StoryProps)
		return React.createElement(StatsHUD, {
			level = props.controls.level,
			exp = props.controls.exp,
			requiredExp = props.controls.requiredExp,
			coins = props.controls.coins,
			luckMultiplier = props.controls.luckMultiplier,
		})
	end,
}

return story
