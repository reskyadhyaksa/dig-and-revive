--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PowerBarHelper = require(Shared:WaitForChild("Common"):WaitForChild("PowerBarHelper"))
local UITypes = require(Shared:WaitForChild("Types"):WaitForChild("UITypes"))
local useDeviceType = require(script.Parent.Parent:WaitForChild("Hooks"):WaitForChild("useDeviceType"))

export type Props = UITypes.HoldPowerBarProps

local function HoldPowerBar(props: Props): any
	local deviceInfo = useDeviceType()
	local isMobile = deviceInfo.isMobile

	-- Smooth transition animation state (Fade + Slide)
	local animProgress, setAnimProgress = React.useState(0)
	-- Smooth power display
	local displayPower, setDisplayPower = React.useState(0)

	React.useEffect(function()
		local targetVis = if props.visible then 1 else 0
		local conn: RBXScriptConnection? = nil

		conn = RunService.RenderStepped:Connect(function(dt: number)
			setAnimProgress(function(prev)
				local diff = targetVis - prev
				if math.abs(diff) < 0.01 then
					return targetVis
				end
				return prev + diff * math.clamp(dt * 14, 0, 1)
			end)

			setDisplayPower(function(prev)
				local diff = props.power - prev
				if math.abs(diff) < 0.005 then
					return props.power
				end
				return prev + diff * math.clamp(dt * 20, 0, 1)
			end)
		end)

		return function()
			if conn then
				conn:Disconnect()
			end
		end
	end, { props.visible, props.power } :: { any })

	if animProgress <= 0.01 and not props.visible then
		return nil
	end

	local currentTransparency = 1 - animProgress
	local multiplier = PowerBarHelper.GetMultiplier(displayPower)
	local dynamicColor = PowerBarHelper.GetDynamicProgressColor(displayPower)
	local transparencyCutoff = PowerBarHelper.GetProgressTransparency(displayPower)

	-- Responsive sizing and positioning
	local wrapperSize = if isMobile
		then UDim2.fromScale(0.10, 0.32)
		else UDim2.fromScale(0.06, 0.28)

	-- Subtle slide in from right
	local baseX = 0.64
	local currentX = baseX + (0.04 * (1 - animProgress))
	local wrapperPos = UDim2.fromScale(currentX, 0.44)

	local luckLabelPos = if isMobile
		then UDim2.fromScale(0.10, 0.69)
		else UDim2.fromScale(0.18, 0.67)

	local luckLabelSize = if isMobile
		then UDim2.fromScale(2.0, 0.10)
		else UDim2.fromScale(2.0, 0.09)

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = wrapperPos,
		Size = wrapperSize,
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

		-- 1. MultiplierLabel ("1.0X" to "2.5X")
		MultiplierLabel = React.createElement("TextLabel", {
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
		}, {
			Stroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 2,
				Transparency = currentTransparency,
			}),
		}),

		-- 2. LuckBoostLabel ("LUCK BOOST" vertical rotated label)
		LuckBoostLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = luckLabelPos,
			Size = luckLabelSize,
			Rotation = -90,
			BackgroundTransparency = 1,
			Font = Enum.Font.LuckiestGuy,
			Text = "LUCK BOOST",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextTransparency = currentTransparency,
			TextScaled = true,
			ZIndex = 4,
		}, {
			Stroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1.5,
				Transparency = currentTransparency,
			}),
		}),

		-- 3. CapsuleContainer (Outer Dark Capsule)
		CapsuleContainer = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.35, 0.82),
			BackgroundColor3 = Color3.fromRGB(20, 25, 35),
			BackgroundTransparency = math.clamp(0.5 + (0.5 * currentTransparency), 0, 1),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 2,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),

			BorderStroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 2.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Transparency = currentTransparency,
			}),

			-- 4. FillBar (Vertical Full Layer with Dynamic Gradient Cutoff)
			FillBar = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = currentTransparency,
				BorderSizePixel = 0,
				ZIndex = 3,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),

				ColorGradient = React.createElement("UIGradient", {
					Rotation = 90,
					Color = PowerBarHelper.VerticalColorSequence,
					Transparency = transparencyCutoff,
				}),
			}),
		}),
	})
end

return HoldPowerBar
