--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local UIBuilder = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("UIBuilder"))

local ASSETS = {
	Countdown = "rbxassetid://126607445864603",
	TimerIcon = "rbxassetid://109376754540674",
}

export type CountdownBadgeProps = {
	seconds: number,
	rotation: number,
	transparency: number,
}

local function DigMinigameCountdown(props: CountdownBadgeProps)
	return React.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 0, -12),
		Size = UDim2.fromScale(0.32, 0.58),
		BackgroundTransparency = 1,
		Image = ASSETS.Countdown,
		ImageTransparency = props.transparency,
		ZIndex = 3,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 3.8,
			DominantAxis = Enum.DominantAxis.Height,
		}),
		Icon = React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.18, 0.25),
			Size = UDim2.fromScale(1.2, 1.2),
			Rotation = props.rotation,
			BackgroundTransparency = 1,
			Image = ASSETS.TimerIcon,
			ImageTransparency = props.transparency,
			ZIndex = 4,
		}, { Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1 }) }),
		Text = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.60, 0.5),
			Size = UDim2.fromScale(0.65, 0.75),
			BackgroundTransparency = 1,
			Font = Enum.Font.LuckiestGuy,
			Text = string.format("%ds", props.seconds),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextTransparency = props.transparency,
			TextScaled = true,
			ZIndex = 4,
		}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(0, 0, 0), 2.5) }),
	})
end

return DigMinigameCountdown
