--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Common.UIBuilder)

export type Props = {
	layoutOrder: number?,
	icon: string,
	label: string,
	keybind: string?,
	isActive: boolean?,
	faceColor: Color3,
	gradientColors: { Color3 },
	shadowColor: Color3,
	strokeColor: Color3,
	onActivated: () -> (),
}

local function HotbarButton(props: Props): any
	local isPressed, setIsPressed = React.useState(false)
	local isHovered, setIsHovered = React.useState(false)

	local yOffset = if isPressed then 2 else (if isHovered then -2 else 0)

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder or 1,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1.05 }),

		Button = React.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromOffset(0, yOffset),
			BackgroundTransparency = 1,
			Text = "",
			[React.Event.MouseButton1Down] = function()
				setIsPressed(true)
			end,
			[React.Event.MouseButton1Up] = function()
				setIsPressed(false)
			end,
			[React.Event.MouseEnter] = function()
				setIsHovered(true)
			end,
			[React.Event.MouseLeave] = function()
				setIsHovered(false)
				setIsPressed(false)
			end,
			[React.Event.Activated] = props.onActivated,
		}, {
			Plate = UIBuilder.BevelPlate({
				shadowColor = props.shadowColor,
				shadowYScale = 0.6,
				faceColor = props.faceColor,
				gradientColors = props.gradientColors,
				borderColor = props.strokeColor,
				borderThickness = 2.2,
				cornerRadius = 12,
				children = {
					Content = React.createElement("Frame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						ZIndex = 4,
					}, {
						Icon = React.createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.40),
							Size = UDim2.fromScale(0.52, 0.52),
							BackgroundTransparency = 1,
							Image = props.icon,
							ScaleType = Enum.ScaleType.Fit,
							ZIndex = 5,
						}, { Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1 }) }),

						Label = React.createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 1),
							Position = UDim2.new(0.5, 0, 1, -3),
							Size = UDim2.new(1, -6, 0, 16),
							BackgroundTransparency = 1,
							Text = string.upper(props.label),
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 11,
							TextWrapped = true,
							Font = Enum.Font.FredokaOne,
							ZIndex = 5,
						}, { Stroke = UIBuilder.TextStroke(props.strokeColor, 1.4) }),
					}),
				},
			}),

			KeybindBadge = if props.keybind
				then React.createElement("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 4, 0, -4),
					Size = UDim2.fromOffset(18, 18),
					BackgroundColor3 = Color3.fromRGB(35, 40, 52),
					ZIndex = 10,
				}, {
					Corner = UIBuilder.Corner(5),
					Stroke = UIBuilder.Stroke(Color3.fromRGB(80, 90, 110), 1.2),
					Text = React.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Text = props.keybind,
						TextColor3 = Color3.fromRGB(240, 245, 255),
						TextScaled = true,
						Font = Enum.Font.FredokaOne,
						ZIndex = 11,
					}),
				})
				else nil,
		}),
	})
end

return HotbarButton
