--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("UIBuilder"))
local CompassTheme = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("CompassTheme"))
local CompassTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("CompassTypes"))
local CompassTapeStrip = require(script.Parent:WaitForChild("CompassTapeStrip"))
local CompassMarker = require(script.Parent:WaitForChild("CompassMarker"))
local CompassSideButton = require(script.Parent:WaitForChild("CompassSideButton"))

type ProcessedWaypoint = CompassTypes.ProcessedWaypoint

local ICONS = { Home = "rbxassetid://120414131422133", Settings = "rbxassetid://89287268052902" }

export type Props = {
	yawDeg: number,
	waypoints: { ProcessedWaypoint },
	visible: boolean?,
	onHomeActivated: (() -> ())?,
	onSettingsActivated: (() -> ())?,
}

local function CompassTapeGui(props: Props): any
	if props.visible == false then return nil end

	local markerElements = {}
	for _, wp in ipairs(props.waypoints) do
		markerElements["WP_" .. wp.id] = React.createElement(CompassMarker, {
			id = wp.id, name = wp.name, color = wp.color, symbol = wp.symbol, icon = wp.icon,
			islandId = wp.islandId, distance = wp.distance, normalizedOffset = wp.normalizedOffset,
			isVisible = wp.isVisible,
		})
	end

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.02, 0),
		Size = UDim2.new(0.38, 0, 0.046, 0), BackgroundTransparency = 1, ClipsDescendants = false, ZIndex = 10,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(240, 32), MaxSize = Vector2.new(380, 38),
		}),
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		HomeBtn = React.createElement(CompassSideButton, {
			layoutOrder = 1, icon = ICONS.Home,
			faceColor = CompassTheme.HomeBtn.faceColor, gradientColors = CompassTheme.HomeBtn.gradientColors,
			shadowColor = CompassTheme.HomeBtn.shadowColor, strokeColor = CompassTheme.HomeBtn.strokeColor,
			onActivated = props.onHomeActivated,
		}),

		TapeHousing = React.createElement("Frame", {
			LayoutOrder = 2, Size = UDim2.new(0.76, 0, 1, 0), BackgroundTransparency = 1, ClipsDescendants = false,
		}, {
			Housing = UIBuilder.BevelPlate({
				shadowColor = CompassTheme.Frame.shadowColor, faceColor = CompassTheme.Frame.faceColor,
				gradientColors = CompassTheme.Frame.gradientColors, borderColor = CompassTheme.Frame.strokeColor,
				borderThickness = 1.8, cornerRadius = 7, clipsFace = false,
				shineMinTransparency = 0.80, shineMaxTransparency = 0.98,
				children = {
					Strip = React.createElement(CompassTapeStrip, { yawDeg = props.yawDeg }),
					Markers = React.createElement("Frame", {
						Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = false, ZIndex = 4,
					}, markerElements),
					Needle = React.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
						Size = UDim2.new(0, 4, 0, 8), BackgroundColor3 = CompassTheme.Needle.color,
						BorderSizePixel = 0, ZIndex = 8,
					}, {
						Corner = UIBuilder.Corner(2),
						Stroke = UIBuilder.Stroke(CompassTheme.Needle.strokeColor, 1),
					}),
				},
			}),
		}),

		SettingsBtn = React.createElement(CompassSideButton, {
			layoutOrder = 3, icon = ICONS.Settings,
			faceColor = CompassTheme.SettingsBtn.faceColor, gradientColors = CompassTheme.SettingsBtn.gradientColors,
			shadowColor = CompassTheme.SettingsBtn.shadowColor, strokeColor = CompassTheme.SettingsBtn.strokeColor,
			onActivated = props.onSettingsActivated,
		}),
	})
end

return CompassTapeGui
