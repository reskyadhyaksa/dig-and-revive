--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = {}

function UIBuilder.Corner(radius: number)
	return React.createElement("UICorner", { CornerRadius = UDim.new(0, radius) })
end

function UIBuilder.PillCorner()
	return React.createElement("UICorner", { CornerRadius = UDim.new(1, 0) })
end

function UIBuilder.Stroke(color: Color3, thickness: number?, mode: Enum.ApplyStrokeMode?)
	return React.createElement("UIStroke", {
		Color = color, Thickness = thickness or 1.5, ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border,
	})
end

function UIBuilder.TextStroke(color: Color3, thickness: number?)
	return React.createElement("UIStroke", {
		Color = color, Thickness = thickness or 1.5, LineJoinMode = Enum.LineJoinMode.Round,
	})
end

function UIBuilder.LinearGradient(colors: { Color3 }, rotation: number?, transparency: NumberSequence?)
	local keypoints = {}
	local count = #colors
	for i, c in ipairs(colors) do
		local alpha = if count > 1 then (i - 1) / (count - 1) else 0
		table.insert(keypoints, ColorSequenceKeypoint.new(alpha, c))
	end
	return React.createElement("UIGradient", {
		Rotation = rotation or 90, Color = ColorSequence.new(keypoints), Transparency = transparency,
	})
end

function UIBuilder.ShineOverlay(radius: number?, heightRatio: number?, maxT: number?, zIdx: number?, tint: Color3?, minT: number?)
	local base = if tint then tint:Lerp(Color3.fromRGB(255, 255, 255), 0.30) else Color3.fromRGB(255, 255, 255)
	return React.createElement("Frame", {
		Position = UDim2.fromScale(0, 0), Size = UDim2.new(1, 0, heightRatio or 0.45, 0),
		BackgroundColor3 = base, BorderSizePixel = 0, ZIndex = zIdx or 1,
	}, {
		Corner = if radius then UIBuilder.Corner(radius) else UIBuilder.PillCorner(),
		Gradient = React.createElement("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, minT or 0.45), NumberSequenceKeypoint.new(1, maxT or 0.94),
			}),
		}),
	})
end

export type BevelProps = {
	size: UDim2?, position: UDim2?, anchorPoint: Vector2?,
	shadowColor: Color3, shadowYScale: number?, faceColor: Color3, faceYScale: number?,
	gradientColors: { Color3 }?, borderColor: Color3?, borderThickness: number?,
	cornerRadius: number?, zIndex: number?, clipsFace: boolean?,
	shineMinTransparency: number?, shineMaxTransparency: number?, children: { [string]: any }?,
}

function UIBuilder.BevelPlate(props: BevelProps)
	local radius = props.cornerRadius or 7
	local faceChildren = {
		Corner = UIBuilder.Corner(radius),
		Shine = UIBuilder.ShineOverlay(radius - 1, nil, props.shineMaxTransparency, nil, nil, props.shineMinTransparency),
	}
	if props.borderColor then faceChildren.Stroke = UIBuilder.Stroke(props.borderColor, props.borderThickness or 1.4) end
	if props.gradientColors then faceChildren.Gradient = UIBuilder.LinearGradient(props.gradientColors, 90) end
	if props.children then
		for k, v in pairs(props.children) do faceChildren[k] = v end
	end

	return React.createElement("Frame", {
		Size = props.size or UDim2.fromScale(1, 1), Position = props.position or UDim2.fromScale(0, 0),
		AnchorPoint = props.anchorPoint or Vector2.new(0, 0), BackgroundTransparency = 1, ZIndex = props.zIndex or 1,
	}, {
		Shadow = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, props.shadowYScale or 0.53),
			Size = UDim2.fromScale(1, 0.92), BackgroundColor3 = props.shadowColor, BorderSizePixel = 0, ZIndex = 1,
		}, { Corner = UIBuilder.Corner(radius) }),

		Face = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, props.faceYScale or 0.47),
			Size = UDim2.fromScale(1, 0.92), BackgroundColor3 = props.faceColor, BorderSizePixel = 0,
			ClipsDescendants = if props.clipsFace ~= nil then props.clipsFace else true, ZIndex = 2,
		}, faceChildren),
	})
end

return UIBuilder
