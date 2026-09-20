--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local ASSETS = {
	CloseIcon = "rbxassetid://113708218281357",
}

export type CancelButtonProps = {
	transparency: number,
	onActivated: (() -> ())?,
}

local function DigMinigameCancelButton(props: CancelButtonProps)
	local isHovered, setIsHovered = React.useState(false)
	local isPressed, setIsPressed = React.useState(false)

	local scale = if isPressed then 0.90 else (if isHovered then 1.10 else 1.0)

	return React.createElement("ImageButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 0, -8),
		Size = UDim2.fromScale(0.15 * scale, 0.75 * scale),
		BackgroundTransparency = 1,
		Image = ASSETS.CloseIcon,
		ImageTransparency = props.transparency,
		AutoButtonColor = false,
		ZIndex = 6,
		[React.Event.MouseEnter] = function()
			setIsHovered(true)
		end,
		[React.Event.MouseLeave] = function()
			setIsHovered(false)
			setIsPressed(false)
		end,
		[React.Event.MouseButton1Down] = function()
			setIsPressed(true)
		end,
		[React.Event.MouseButton1Up] = function()
			setIsPressed(false)
		end,
		[React.Event.Activated] = function()
			if props.onActivated then
				props.onActivated()
			end
		end,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1,
			DominantAxis = Enum.DominantAxis.Height,
		}),
	})
end

return DigMinigameCancelButton
