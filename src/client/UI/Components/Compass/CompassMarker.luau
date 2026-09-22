--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("UIBuilder"))
local CompassMath = require(script.Parent:WaitForChild("CompassMath"))

export type Props = {
	id: string,
	name: string,
	color: Color3,
	symbol: string?,
	icon: string?,
	islandId: string?,
	distance: number,
	normalizedOffset: number,
	isVisible: boolean,
	onActivated: (() -> ())?,
}

local function CompassMarker(props: Props): any
	if not props.isVisible then return nil end

	local isHere = props.distance < 15
	local shadowColor = props.color:Lerp(Color3.new(0, 0, 0), 0.45)
	local strokeColor = props.color:Lerp(Color3.new(0, 0, 0), 0.65)
	local distText = CompassMath.FormatDistance(props.distance)
	local labelText = if isHere then "Here" else string.format("%s %s", props.name, distText)

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(props.normalizedOffset, 0, 0.46, 0),
		Size = UDim2.new(0, 22, 0, 22),
		BackgroundTransparency = 1,
		ZIndex = 5,
	}, {
		Badge = UIBuilder.BevelPlate({
			shadowColor = shadowColor,
			faceColor = props.color,
			borderColor = strokeColor,
			borderThickness = 1.2,
			cornerRadius = 5,
			shineMinTransparency = 0.55,
			shineMaxTransparency = 0.95,
			children = {
				Symbol = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.9, 0.9),
					BackgroundTransparency = 1,
					Text = props.symbol or "★",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					Font = Enum.Font.FredokaOne,
					ZIndex = 4,
				}, { Stroke = UIBuilder.TextStroke(strokeColor, 1.2) }),
			},
		}),

		-- External Waypoint Name & Distance Label (Rendered outside below the tape)
		ExternalLabel = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 1, 7),
			Size = UDim2.new(0, if isHere then 42 else 64, 0, 16),
			BackgroundColor3 = Color3.fromRGB(15, 21, 29),
			BackgroundTransparency = 0.25,
			ZIndex = 7,
		}, {
			Corner = UIBuilder.Corner(4),
			Stroke = UIBuilder.Stroke(strokeColor, 1.0),
			Text = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -4, 1, -2),
				BackgroundTransparency = 1,
				Text = labelText,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				Font = Enum.Font.FredokaOne,
				ZIndex = 8,
			}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(8, 12, 16), 1.2) }),
		}),
	})
end

return CompassMarker
