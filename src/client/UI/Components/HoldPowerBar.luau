--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

export type Props = {
	visible: boolean,
	power: number, -- 0.0 to 1.0
}

local function HoldPowerBar(props: Props): any
	local themeColor = Color3.fromRGB(241, 196, 15) -- Sunflower Yellow
	local shadowColor = themeColor:Lerp(Color3.fromRGB(0, 0, 0), 0.4)
	local strokeColor = themeColor:Lerp(Color3.fromRGB(0, 0, 0), 0.6)
	
	local backColor = Color3.fromRGB(44, 62, 80) -- Dark background for the bar

	-- Spring-like smooth transition state for visibility
	local animProgress, setAnimProgress = React.useState(0)
	
	-- Smooth power bar interpolation
	local displayPower, setDisplayPower = React.useState(0)

	React.useEffect(function()
		local targetVis = if props.visible then 1 else 0
		local isMounted = true
		local conn: RBXScriptConnection? = nil

		conn = RunService.RenderStepped:Connect(function(dt: number)
			setAnimProgress(function(prev)
				local diff = targetVis - prev
				if math.abs(diff) < 0.01 then
					return targetVis
				end
				return prev + diff * math.clamp(dt * 12, 0, 1)
			end)
			
			setDisplayPower(function(prev)
				local diff = props.power - prev
				if math.abs(diff) < 0.01 then
					return props.power
				end
				return prev + diff * math.clamp(dt * 15, 0, 1)
			end)
		end)

		return function()
			isMounted = false
			if conn then
				conn:Disconnect()
			end
		end
	end, { props.visible, props.power } :: { any })

	if animProgress <= 0.01 and not props.visible then
		return nil
	end

	-- Slide in from the right
	local currentXScale = 0.95 + (0.05 * (1 - animProgress))
	local currentTransparency = 1 - animProgress

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), -- Right anchored
		Position = UDim2.fromScale(currentXScale, 0.5),
		Size = UDim2.new(0.06, 0, 0.3, 0),
		BackgroundTransparency = 1,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(40, 200),
			MaxSize = Vector2.new(80, 400),
		}),

		-- 1. Base / Shadow Layer (3D Depth bottom)
		ShadowLayer = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.52),
			Size = UDim2.fromScale(1, 0.98),
			BackgroundColor3 = Color3.fromRGB(20, 30, 40),
			BackgroundTransparency = currentTransparency,
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
		}),

		-- 2. Top Face Surface Layer (Background of bar)
		FaceLayer = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.48),
			Size = UDim2.fromScale(1, 0.98),
			BackgroundColor3 = backColor,
			BackgroundTransparency = currentTransparency,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),

			BorderStroke = React.createElement("UIStroke", {
				Color = strokeColor,
				Thickness = 2.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Transparency = currentTransparency,
			}),

			-- 3. The Fill Bar (Power)
			FillBar = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1), -- Bottom anchored
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromScale(1, displayPower),
				BackgroundColor3 = themeColor,
				BackgroundTransparency = currentTransparency,
				BorderSizePixel = 0,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 12),
				}),
				
				-- 4. Glossy / Shine Overlay (inside the fill bar)
				GlossyOverlay = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 2),
					Size = UDim2.new(1, -6, 1, 0), -- Full height of the fill
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					ZIndex = 2,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 9),
					}),
					Gradient = React.createElement("UIGradient", {
						Rotation = 90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.25),
							NumberSequenceKeypoint.new(0.4, 0.92),
							NumberSequenceKeypoint.new(1, 1),
						}),
					}),
				}),
			}),
		}),
	})
end

return HoldPowerBar
