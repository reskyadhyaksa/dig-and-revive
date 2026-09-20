--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local PowerBarHelper = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Common"):WaitForChild("PowerBarHelper"))
local UITypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("UITypes"))
local UIBuilder = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("UIBuilder"))
local useDeviceType = require(script.Parent.Parent:WaitForChild("Hooks"):WaitForChild("useDeviceType"))

export type Props = UITypes.HoldPowerBarProps

local function HoldPowerBar(props: Props): any
	local isMobile = useDeviceType().isMobile
	local animProgress, setAnimProgress = React.useState(if props.visible then 1 else 0)
	local displayPower, setDisplayPower = React.useState(props.power or 0)

	React.useEffect(function()
		local targetVis = if props.visible then 1 else 0
		local stepSignal = if RunService:IsClient() and RunService:IsRunning() then RunService.RenderStepped else RunService.Heartbeat
		local conn = stepSignal:Connect(function(dt: number)
			setAnimProgress(function(p) return p + (targetVis - p) * math.clamp(dt * 14, 0, 1) end)
			setDisplayPower(function(p) return p + (props.power - p) * math.clamp(dt * 20, 0, 1) end)
		end)
		return function() conn:Disconnect() end
	end, { props.visible, props.power } :: { any })

	if animProgress <= 0.01 and not props.visible then return nil end

	local currentTransparency = 1 - animProgress
	local multiplier = PowerBarHelper.GetMultiplier(displayPower)
	local dynamicColor = PowerBarHelper.GetDynamicProgressColor(displayPower)
	local transparencyCutoff = PowerBarHelper.GetProgressTransparency(displayPower)

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.64 + (0.04 * (1 - animProgress)), 0.44),
		Size = if isMobile then UDim2.fromScale(0.10, 0.32) else UDim2.fromScale(0.06, 0.28),
		BackgroundTransparency = 1,
		ZIndex = 15,
	}, {
		AspectRatio = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.364,
			DominantAxis = Enum.DominantAxis.Height,
		}),
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(32, 130),
			MaxSize = Vector2.new(90, 360),
		}),

		-- 1. Multiplier Label ("1.0X" to "2.5X")
		Multiplier = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.08),
			Size = UDim2.fromScale(1.0, 0.12),
			BackgroundTransparency = 1,
			Font = Enum.Font.LuckiestGuy,
			Text = string.format("%.1fX", multiplier),
			TextColor3 = dynamicColor,
			TextTransparency = currentTransparency,
			TextScaled = true,
			ZIndex = 5,
		}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(0, 0, 0), 2) }),

		-- 2. Vertical Luck Boost Label
		LuckBoost = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = if isMobile then UDim2.fromScale(0.10, 0.69) else UDim2.fromScale(0.18, 0.67),
			Size = if isMobile then UDim2.fromScale(2.0, 0.10) else UDim2.fromScale(2.0, 0.09),
			Rotation = -90,
			BackgroundTransparency = 1,
			Font = Enum.Font.LuckiestGuy,
			Text = "LUCK BOOST",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextTransparency = currentTransparency,
			TextScaled = true,
			ZIndex = 4,
		}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(0, 0, 0), 1.5) }),

		-- 3. Outer Capsule & Fill
		Capsule = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.35, 0.82),
			BackgroundColor3 = Color3.fromRGB(20, 25, 35),
			BackgroundTransparency = math.clamp(0.5 + (0.5 * currentTransparency), 0, 1),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 2,
		}, {
			Corner = UIBuilder.PillCorner(),
			Stroke = UIBuilder.Stroke(Color3.fromRGB(255, 255, 255), 2.5),
			Fill = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = currentTransparency,
				BorderSizePixel = 0,
				ZIndex = 3,
			}, {
				Corner = UIBuilder.PillCorner(),
				Gradient = React.createElement("UIGradient", {
					Rotation = 90,
					Color = PowerBarHelper.VerticalColorSequence,
					Transparency = transparencyCutoff,
				}),
			}),
		}),
	})
end

return HoldPowerBar
