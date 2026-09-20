--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))

local DigMinigame = require(script.Parent:WaitForChild("DigMinigame"))

export type StoryProps = {
	controls: {
		visible: boolean,
		progress: number,
		remainingTime: number,
	},
	target: Instance,
}

local story = {
	summary = "Dig Minigame popup with animated shovel meter, tap button, and countdown timer",
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		visible = true,
		progress = 0.45,
		remainingTime = 8.5,
	},
	story = function(props: StoryProps)
		return React.createElement(DigMinigame, {
			visible = props.controls.visible,
			progress = props.controls.progress,
			remainingTime = props.controls.remainingTime,
			onCancel = function()
				print("[UI Labs Story] DigMinigame onCancel triggered")
			end,
			onSwing = function()
				print("[UI Labs Story] DigMinigame onSwing triggered")
			end,
		})
	end,
}

return story
