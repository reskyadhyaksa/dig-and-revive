--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("UIBuilder"))
local CompassTheme = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("CompassTheme"))

export type Props = {
	icon: string,
	layoutOrder: number?,
	faceColor: Color3?,
	gradientColors: { Color3 }?,
	shadowColor: Color3?,
	strokeColor: Color3?,
	onActivated: (() -> ())?,
}

local function CompassSideButton(props: Props): any
	local isPressed, setIsPressed = React.useState(false)
	local isHovered, setIsHovered = React.useState(false)

	local yOffset = if isPressed then 2 else (if isHovered then -2 else 0)
	local faceColor = props.faceColor or CompassTheme.Frame.faceColor
	local gradientColors = props.gradientColors or CompassTheme.Frame.gradientColors
	local shadowColor = props.shadowColor or CompassTheme.Frame.shadowColor
	local strokeColor = props.strokeColor or CompassTheme.Frame.strokeColor

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder or 1,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1 }),

		Button = React.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromOffset(0, yOffset),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			[React.Event.MouseButton1Down] = function() setIsPressed(true) end,
			[React.Event.MouseButton1Up] = function() setIsPressed(false) end,
			[React.Event.MouseEnter] = function() setIsHovered(true) end,
			[React.Event.MouseLeave] = function()
				setIsHovered(false)
				setIsPressed(false)
			end,
			[React.Event.Activated] = props.onActivated,
		}, {
			Plate = UIBuilder.BevelPlate({
				shadowColor = shadowColor,
				faceColor = faceColor,
				gradientColors = gradientColors,
				borderColor = strokeColor,
				borderThickness = 2,
				cornerRadius = 8,
				shineMinTransparency = 0.50,
				shineMaxTransparency = 0.92,
				children = {
					Icon = React.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.60, 0.60),
						BackgroundTransparency = 1,
						Image = props.icon,
						ScaleType = Enum.ScaleType.Fit,
						ZIndex = 5,
					}, {
						Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1 }),
					}),
				},
			}),
		}),
	})
end

return CompassSideButton
