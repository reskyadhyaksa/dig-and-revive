--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("UIBuilder"))

export type Props = {
	title: string,
	subtitle: string?,
	visible: boolean,
	themeColor: Color3?,
}

local function ZoneNotificationBanner(props: Props): any
	local themeColor = props.themeColor or Color3.fromRGB(46, 204, 113)
	local shadowColor = themeColor:Lerp(Color3.fromRGB(0, 0, 0), 0.4)
	local strokeColor = themeColor:Lerp(Color3.fromRGB(0, 0, 0), 0.6)

	local animProgress, setAnimProgress = React.useState(0)

	React.useEffect(function()
		local target = if props.visible then 1 else 0
		local conn = RunService.RenderStepped:Connect(function(dt: number)
			setAnimProgress(function(p) return p + (target - p) * math.clamp(dt * 12, 0, 1) end)
		end)
		return function() conn:Disconnect() end
	end, { props.visible } :: { any })

	if animProgress <= 0.01 and not props.visible then return nil end

	local currentYScale = 0.15 + (0.05 * animProgress)
	local currentTransparency = 1 - animProgress

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, currentYScale),
		Size = UDim2.new(0.85, 0, 0.085, 0),
		BackgroundTransparency = 1,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(260, 52),
			MaxSize = Vector2.new(480, 80),
		}),
		AspectRatio = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 5.2,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
		}),

		Plate = UIBuilder.BevelPlate({
			shadowColor = shadowColor,
			faceColor = themeColor,
			borderColor = strokeColor,
			borderThickness = 2.5,
			cornerRadius = 12,
			children = {
				Content = React.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					ZIndex = 2,
				}, {
					Layout = React.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 2),
					}),
					Pad = React.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 12),
						PaddingRight = UDim.new(0, 12),
					}),

					Subtitle = if props.subtitle then React.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 0.35, 0),
						BackgroundTransparency = 1,
						Text = string.upper(props.subtitle),
						TextColor3 = Color3.fromRGB(240, 255, 245),
						TextTransparency = currentTransparency,
						TextScaled = true,
						Font = Enum.Font.FredokaOne,
					}, { Stroke = UIBuilder.TextStroke(strokeColor, 1.5) }) else nil,

					Title = React.createElement("TextLabel", {
						Size = UDim2.new(1, 0, if props.subtitle then 0.55 else 0.85, 0),
						BackgroundTransparency = 1,
						Text = props.title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextTransparency = currentTransparency,
						TextScaled = true,
						Font = Enum.Font.FredokaOne,
					}, { Stroke = UIBuilder.TextStroke(strokeColor, 2.0) }),
				}),
			},
		}),
	})
end

return ZoneNotificationBanner
