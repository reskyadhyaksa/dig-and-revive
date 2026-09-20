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
			setAnimProgress(function(p)
				return p + (target - p) * math.clamp(dt * 12, 0, 1)
			end)
		end)
		return function()
			conn:Disconnect()
		end
	end, { props.visible } :: { any })

	if animProgress <= 0.01 and not props.visible then return nil end

	local currentYScale = 0.12 + (0.05 * animProgress)
	local currentTransparency = 1 - animProgress

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, currentYScale),
		Size = UDim2.new(0.85, 0, 0.09, 0),
		BackgroundTransparency = 1,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(240, 52),
			MaxSize = Vector2.new(420, 80),
		}),
		AspectRatio = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 4.8,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
		}),
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		PlateContainer = React.createElement("Frame", {
			LayoutOrder = 1,
			Size = if props.subtitle then UDim2.new(1, 0, 0.72, 0) else UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			Plate = UIBuilder.BevelPlate({
				shadowColor = shadowColor,
				faceColor = themeColor,
				borderColor = strokeColor,
				borderThickness = 2.5,
				cornerRadius = 10,
				children = {
					Title = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -20, 0.85, 0),
						BackgroundTransparency = 1,
						Text = props.title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextTransparency = currentTransparency,
						TextScaled = true,
						Font = Enum.Font.FredokaOne,
						ZIndex = 4,
					}, { Stroke = UIBuilder.TextStroke(strokeColor, 2.0) }),
				},
			}),
		}),

		Subtitle = if props.subtitle then React.createElement("TextLabel", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0.24, 0),
			BackgroundTransparency = 1,
			Text = string.upper(props.subtitle),
			TextColor3 = Color3.fromRGB(225, 45, 45),
			TextTransparency = currentTransparency,
			TextScaled = true,
			Font = Enum.Font.FredokaOne,
		}, {
			Stroke = UIBuilder.TextStroke(Color3.fromRGB(20, 0, 0), 1.6),
			SizeConstraint = React.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(1000, 15),
			}),
		}) else nil,
	})
end

return ZoneNotificationBanner
