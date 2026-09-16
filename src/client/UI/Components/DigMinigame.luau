--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITypes = require(Shared:WaitForChild("Types"):WaitForChild("UITypes"))
local DigMinigameHelper = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("DigMinigameHelper"))
local useDeviceType = require(script.Parent.Parent:WaitForChild("Hooks"):WaitForChild("useDeviceType"))

local ASSET_OUTER_CONTAINER = "rbxassetid://77990043906183"
local ASSET_INNER_BAR = "rbxassetid://105807504905048"
local ASSET_COUNTDOWN = "rbxassetid://126607445864603"
local ASSET_TIMER_ICON = "rbxassetid://109376754540674"
local ASSET_SHOVEL = "rbxassetid://83791111239909"

export type Props = UITypes.DigMinigameProps

local function DigMinigame(props: Props): any
	local deviceInfo = useDeviceType()
	local isMobile = deviceInfo.isMobile

	-- Smooth enter / exit transition
	local animProgress, setAnimProgress = React.useState(0)
	-- Smooth progress interpolation for bar and shovel marker
	local displayProgress, setDisplayProgress = React.useState(0)
	-- Micro-animation states
	local tapScale, setTapScale = React.useState(1.0)
	local shovelHitAlpha, setShovelHitAlpha = React.useState(0)
	local timerShakeRotation, setTimerShakeRotation = React.useState(0)
	local isPressed, setIsPressed = React.useState(false)

	local lastProgressRef = React.useRef(props.progress)

	-- Hit pop effect when progress increases
	React.useEffect(function()
		if props.progress > lastProgressRef.current + 0.001 then
			setShovelHitAlpha(1)
		end
		lastProgressRef.current = props.progress
	end, { props.progress } :: { any })

	React.useEffect(function()
		local targetVis = if props.visible then 1 else 0
		local elapsedTimer = 0
		local conn: RBXScriptConnection? = nil

		conn = RunService.RenderStepped:Connect(function(dt: number)
			elapsedTimer += dt

			-- 1. Visibility transition
			setAnimProgress(function(prev)
				local diff = targetVis - prev
				if math.abs(diff) < 0.01 then
					return targetVis
				end
				return prev + diff * math.clamp(dt * 12, 0, 1)
			end)

			-- 2. Bar smooth progress
			setDisplayProgress(function(prev)
				local diff = props.progress - prev
				if math.abs(diff) < 0.005 then
					return props.progress
				end
				return prev + diff * math.clamp(dt * 15, 0, 1)
			end)

			-- 3. Breathing TAP animation (Sine wave)
			local breath = math.sin(elapsedTimer * 4.5) * 0.06
			setTapScale(1.0 + breath)

			-- 4. Hit pop decay for Shovel Marker
			setShovelHitAlpha(function(prev)
				if prev <= 0.01 then return 0 end
				return prev - (dt * 5.0)
			end)

			-- 5. Timer ringing shake loop (shakes periodically every 1.5s)
			local shakePhase = elapsedTimer % 1.5
			if shakePhase < 0.4 then
				local shake = math.sin(shakePhase * 25) * 16 * (1 - (shakePhase / 0.4))
				setTimerShakeRotation(shake)
			else
				setTimerShakeRotation(0)
			end
		end)

		return function()
			if conn then
				conn:Disconnect()
			end
		end
	end, { props.visible, props.progress } :: { any })

	if animProgress <= 0.01 and not props.visible then
		return nil
	end

	local clampedProgress = math.clamp(displayProgress, 0, 1)
	local currentTransparency = 1 - animProgress
	local fadeTransparency = DigMinigameHelper.GetFadeTransparencySequence(clampedProgress)

	-- Responsive Position
	local containerPos = if isMobile
		then UDim2.fromScale(0.5, 0.625)
		else UDim2.fromScale(0.5, 0.70)

	-- Shovel hit bounce dynamic properties
	local shovelScale = 1.0 + (shovelHitAlpha * 0.20)
	local shovelRotation = -10 - (shovelHitAlpha * 14)

	-- Button press scale spring effect
	local buttonScale = if isPressed then 0.98 else 1.0

	local remainingSec = math.max(0, math.ceil(props.remainingTime or 15))

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = containerPos,
		Size = UDim2.fromScale(0.65 * buttonScale, 0.088 * buttonScale),
		BackgroundTransparency = 1,
		ZIndex = 20,
	}, {
		AspectRatio = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 7.05,
			DominantAxis = Enum.DominantAxis.Width,
		}),

		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(280, 40),
			MaxSize = Vector2.new(540, 76),
		}),

		-- OuterContainer (The textured wooden/metal frame button)
		OuterContainer = React.createElement("ImageButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = ASSET_OUTER_CONTAINER,
			ScaleType = Enum.ScaleType.Stretch,
			ImageTransparency = currentTransparency,
			AutoButtonColor = false,
			ZIndex = 1,
			[React.Event.MouseButton1Down] = function()
				setIsPressed(true)
			end,
			[React.Event.MouseButton1Up] = function()
				setIsPressed(false)
			end,
			[React.Event.TouchTap] = function()
				if props.onSwing then
					props.onSwing()
				end
			end,
			[React.Event.Activated] = function()
				if props.onSwing then
					props.onSwing()
				end
			end,
		}, {
			-- Inner Slot Area for Clipping
			InnerSlotFrame = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.938, 0.59),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 2,
			}, {
				-- 1. Clip Frame for dynamic width
				ClipFrame = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.new(clampedProgress, 0, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					ZIndex = 2,
				}, {
					-- Inner Bar Image (Inverse Scaled)
					InnerBarImage = React.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(1 / math.max(clampedProgress, 0.0001), 0, 1, 0),
						BackgroundTransparency = 1,
						Image = ASSET_INNER_BAR,
						ScaleType = Enum.ScaleType.Stretch,
						ImageTransparency = currentTransparency,
						ZIndex = 2,
					}, {
						FadeGradient = React.createElement("UIGradient", {
							Transparency = fadeTransparency,
						}),
					}),
				}),

				-- 2. TAP Text Breathing in center of bar
				TapText = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.36 * tapScale, 0.76 * tapScale),
					BackgroundTransparency = 1,
					Text = "TAP",
					Font = Enum.Font.LuckiestGuy,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextTransparency = currentTransparency,
					TextScaled = true,
					ZIndex = 4,
				}, {
					Stroke = React.createElement("UIStroke", {
						Color = Color3.fromRGB(0, 0, 0),
						Thickness = 2.0,
						Transparency = currentTransparency,
					}),
					AspectRatio = React.createElement("UIAspectRatioConstraint", {
						AspectRatio = 2.5,
					}),
				}),

				-- 3. Shovel Marker (Travels with progress)
				ShovelMarker = React.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(clampedProgress, 0, 0.5, 0),
					Size = UDim2.fromScale(1 * shovelScale, 2.5 * shovelScale),
					Rotation = shovelRotation,
					BackgroundTransparency = 1,
					Image = ASSET_SHOVEL,
					ImageTransparency = currentTransparency,
					ZIndex = 5,
				}, {
					AspectRatio = React.createElement("UIAspectRatioConstraint", {
						AspectRatio = 1.0,
					}),
				}),
			}),
		}),

		-- Countdown Container (Red box with timer & shaking icon)
		CountdownContainer = React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1.575),
			Size = UDim2.fromScale(0.32, 0.58),
			BackgroundTransparency = 1,
			Image = ASSET_COUNTDOWN,
			ImageTransparency = currentTransparency,
			ZIndex = 3,
		}, {
			AspectRatio = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 3.8,
				DominantAxis = Enum.DominantAxis.Height,
			}),

			-- Ringing Alarm Clock Icon
			TimerIcon = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.18, 0.5),
				Size = UDim2.fromScale(0.85, 0.85),
				Rotation = timerShakeRotation,
				BackgroundTransparency = 1,
				Image = ASSET_TIMER_ICON,
				ImageTransparency = currentTransparency,
				ZIndex = 4,
			}, {
				AspectRatio = React.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1.0,
				}),
			}),

			-- Timer Number Text ("15s")
			TimerText = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.60, 0.5),
				Size = UDim2.fromScale(0.65, 0.75),
				BackgroundTransparency = 1,
				Font = Enum.Font.LuckiestGuy,
				Text = string.format("%ds", remainingSec),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextTransparency = currentTransparency,
				TextScaled = true,
				ZIndex = 4,
			}, {
				Stroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(0, 0, 0),
					Thickness = 2.5,
					Transparency = currentTransparency,
				}),
			}),
		}),
	})
end

return DigMinigame
