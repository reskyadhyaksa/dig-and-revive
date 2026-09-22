--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("UIBuilder"))
local CompassTheme = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("CompassTheme"))
local WaypointConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("WaypointConfig"))

type Props = {
	yawDeg: number,
}

local CARDINALS: { [number]: { text: string, isNorth: boolean, isMajor: boolean } } = {
	[0] = { text = "N", isNorth = true, isMajor = true },
	[45] = { text = "NE", isNorth = false, isMajor = false },
	[90] = { text = "E", isNorth = false, isMajor = true },
	[135] = { text = "SE", isNorth = false, isMajor = false },
	[180] = { text = "S", isNorth = false, isMajor = true },
	[225] = { text = "SW", isNorth = false, isMajor = false },
	[270] = { text = "W", isNorth = false, isMajor = true },
	[315] = { text = "NW", isNorth = false, isMajor = false },
}

local function CompassTapeStrip(props: Props): any
	local halfFov = WaypointConfig.VisibleFOV / 2
	local elements = {}

	for deg = 0, 345, 15 do
		local delta = (deg - props.yawDeg + 540) % 360 - 180
		if math.abs(delta) <= halfFov then
			local normOffset = 0.5 + ((delta / halfFov) * 0.44)
			local cardInfo = CARDINALS[deg]

			if cardInfo then
				local textColor = if cardInfo.isNorth
					then CompassTheme.Tape.cardinalNorth
					elseif cardInfo.isMajor then CompassTheme.Tape.cardinalMajor
					else CompassTheme.Tape.cardinalMinor
				local textShadow = if cardInfo.isNorth
					then CompassTheme.Tape.cardinalNorthShadow
					else CompassTheme.Tape.cardinalMajorShadow

				elements["Card_" .. deg] = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(normOffset, 0, 0.46, 0),
					Size = UDim2.new(0, 24, 0, if cardInfo.isNorth then 18 else 14),
					BackgroundTransparency = 1,
					Text = cardInfo.text,
					TextColor3 = textColor,
					TextScaled = true,
					Font = Enum.Font.FredokaOne,
					ZIndex = 3,
				}, {
					Stroke = UIBuilder.TextStroke(textShadow, 1.5),
				})
			else
				local isThirty = (deg % 30 == 0)
				elements["Tick_" .. deg] = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(normOffset, 0, 0.48, 0),
					Size = UDim2.new(0, 2, 0, if isThirty then 10 else 6),
					BackgroundColor3 = if isThirty then CompassTheme.Tape.tickMajor else CompassTheme.Tape.tickMinor,
					BorderSizePixel = 0,
					ZIndex = 2,
				}, {
					Corner = UIBuilder.Corner(1),
				})
			end
		end
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, elements)
end

return CompassTapeStrip
