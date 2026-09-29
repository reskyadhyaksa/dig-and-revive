--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)
local DialogTheme = require(script.Parent.Parent.Parent.Common.DialogTheme)

export type Props = {
	layoutOrder: number,
	label: string,
	baseColor: Color3,
	isMobile: boolean,
	onActivated: () -> (),
}

local function DialogOptionButton(props: Props): any
	local isHovered, setIsHovered = React.useState(false)
	local isPressed, setIsPressed = React.useState(false)
	local yOffset = if isPressed then 2 else (if isHovered then -2 else 0)
	local base = props.baseColor

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(1, 0, 0, if props.isMobile then 48 else 42),
		BackgroundTransparency = 1,
	}, {
		Button = React.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(0, yOffset),
			BackgroundTransparency = 1, Text = "",
			[React.Event.MouseButton1Down] = function() setIsPressed(true) end,
			[React.Event.MouseButton1Up] = function() setIsPressed(false) end,
			[React.Event.MouseEnter] = function() setIsHovered(true) end,
			[React.Event.MouseLeave] = function() setIsHovered(false) setIsPressed(false) end,
			[React.Event.Activated] = props.onActivated,
		}, {
			Plate = UIBuilder.BevelPlate({
				shadowColor = base:Lerp(Color3.new(0, 0, 0), 0.35),
				faceColor = base,
				borderColor = base:Lerp(Color3.new(0, 0, 0), 0.55),
				borderThickness = 2,
				cornerRadius = 10,
				children = {
					Label = React.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 4,
						Text = string.format("%d.  %s", props.layoutOrder, props.label),
						TextColor3 = DialogTheme.TextColor, Font = Enum.Font.FredokaOne,
						TextSize = if props.isMobile then 18 else 17,
						TextXAlignment = Enum.TextXAlignment.Left,
					}, {
						Pad = React.createElement("UIPadding", { PaddingLeft = UDim.new(0, 14) }),
					}),
				},
			}),
		}),
	})
end

return DialogOptionButton
