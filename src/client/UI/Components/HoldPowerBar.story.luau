--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))

local HoldPowerBar = require(script.Parent:WaitForChild("HoldPowerBar"))

export type StoryProps = {
	controls: {
		visible: boolean,
		power: number,
		multiplier: number,
	},
	target: Instance,
}

local story = {
	summary = "Hold Charge / Power Bar with dynamic multipliers and spring bounce",
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		visible = true,
		power = 0.75,
		multiplier = 2.0,
	},
	story = function(props: StoryProps)
		return React.createElement(HoldPowerBar, {
			visible = props.controls.visible,
			power = props.controls.power,
			multiplier = props.controls.multiplier,
		})
	end,
}

return story
