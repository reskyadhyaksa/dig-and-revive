--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))

local ZoneNotificationBanner = require(script.Parent:WaitForChild("ZoneNotificationBanner"))

export type StoryProps = {
	controls: {
		visible: boolean,
		title: string,
		subtitle: string,
		themeColor: Color3,
	},
	target: Instance,
}

local story = {
	summary = "Zone Notification Banner with smooth spring slide-down and 3D bevel aesthetics",
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		visible = true,
		title = "ANCIENT RUINS",
		subtitle = "Deep Digging Zone • Tier 3 Required",
		themeColor = Color3.fromRGB(46, 204, 113),
	},
	story = function(props: StoryProps)
		return React.createElement(ZoneNotificationBanner, {
			visible = props.controls.visible,
			title = props.controls.title,
			subtitle = props.controls.subtitle,
			themeColor = props.controls.themeColor,
		})
	end,
}

return story
