--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local DigMinigameHelper = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("DigMinigameHelper"))
local UITypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("UITypes"))
local UIBuilder = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("UIBuilder"))
local useDeviceType = require(script.Parent.Parent:WaitForChild("Hooks"):WaitForChild("useDeviceType"))
local DigMinigameCountdown = require(script:WaitForChild("DigMinigameCountdown"))
local DigMinigameCancelButton = require(script:WaitForChild("DigMinigameCancelButton"))

local ASSETS = {
	OuterContainer = "rbxassetid://77990043906183",
	InnerBar = "rbxassetid://105807504905048",
	Shovel = "rbxassetid://83791111239909",
}

export type Props = UITypes.DigMinigameProps

local function DigMinigame(props: Props): any
	local isMobile = useDeviceType().isMobile
	local animProgress, setAnimProgress = React.useState(if props.visible then 1 else 0)
	local displayProgress, setDisplayProgress = React.useState(props.progress or 0)
	local tapScale, setTapScale = React.useState(1.0)
	local shovelHitAlpha, setShovelHitAlpha = React.useState(0)
	local timerShakeRotation, setTimerShakeRotation = React.useState(0)
	local isPressed, setIsPressed = React.useState(false)

	local lastProgressRef = React.useRef(props.progress)

	React.useEffect(function()
		if props.progress > lastProgressRef.current + 0.001 then setShovelHitAlpha(1) end
		lastProgressRef.current = props.progress
	end, { props.progress } :: { any })

	React.useEffect(function()
		local targetVis = if props.visible then 1 else 0
		local elapsed = 0
		local stepSignal = if RunService:IsClient() and RunService:IsRunning() then RunService.RenderStepped else RunService.Heartbeat
		local conn = stepSignal:Connect(function(dt: number)
			elapsed += dt
			setAnimProgress(function(p) return p + (targetVis - p) * math.clamp(dt * 12, 0, 1) end)
			setDisplayProgress(function(p) return p + (props.progress - p) * math.clamp(dt * 15, 0, 1) end)
			setTapScale(1.0 + math.sin(elapsed * 4.5) * 0.06)
			setShovelHitAlpha(function(p) return if p <= 0.01 then 0 else p - (dt * 5.0) end)
			local phase = elapsed % 1.5
			setTimerShakeRotation(if phase < 0.4 then math.sin(phase * 25) * 16 * (1 - (phase / 0.4)) else 0)
		end)
		return function() conn:Disconnect() end
	end, { props.visible, props.progress } :: { any })

	if animProgress <= 0.01 and not props.visible then return nil end

	local progress = math.clamp(displayProgress, 0, 1)
	local currentTransparency = 1 - animProgress
	local buttonScale = if isPressed then 0.98 else 1.0

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = if isMobile then UDim2.fromScale(0.5, 0.625) else UDim2.fromScale(0.5, 0.70),
		Size = UDim2.fromScale(0.65 * buttonScale, 0.088 * buttonScale),
		BackgroundTransparency = 1,
		ZIndex = 20,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 7.05, DominantAxis = Enum.DominantAxis.Width }),
		SizeConstraint = React.createElement("UISizeConstraint", { MinSize = Vector2.new(280, 40), MaxSize = Vector2.new(540, 76) }),

		OuterBtn = React.createElement("ImageButton", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = ASSETS.OuterContainer,
			ImageTransparency = currentTransparency, AutoButtonColor = false, ZIndex = 1,
			[React.Event.MouseButton1Down] = function() setIsPressed(true) end,
			[React.Event.MouseButton1Up] = function() setIsPressed(false) end,
		}, {
			Slot = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.938, 0.59), BackgroundTransparency = 1, ZIndex = 2,
			}, {
				Clip = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.new(progress, 0, 1, 0), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2,
				}, {
					Bar = React.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(1 / math.max(progress, 0.0001), 0, 1, 0), BackgroundTransparency = 1,
						Image = ASSETS.InnerBar, ImageTransparency = currentTransparency, ZIndex = 2,
					}, { Fade = React.createElement("UIGradient", { Transparency = DigMinigameHelper.GetFadeTransparencySequence(progress) }) }),
				}),
				Tap = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.36 * tapScale, 0.76 * tapScale), BackgroundTransparency = 1,
					Text = "TAP", Font = Enum.Font.LuckiestGuy, TextColor3 = Color3.fromRGB(255, 255, 255),
					TextTransparency = currentTransparency, TextScaled = true, ZIndex = 4,
				}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(0, 0, 0), 2.0) }),
				Shovel = React.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(progress, 0, 0.5, 0),
					Size = UDim2.fromScale(1 * (1 + shovelHitAlpha * 0.2), 2.5 * (1 + shovelHitAlpha * 0.2)),
					Rotation = -10 - (shovelHitAlpha * 14), BackgroundTransparency = 1, Image = ASSETS.Shovel,
					ImageTransparency = currentTransparency, ZIndex = 5,
				}, { Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1 }) }),
			}),
		}),

		Timer = React.createElement(DigMinigameCountdown, {
			seconds = math.max(0, math.ceil(props.remainingTime or 15)),
			rotation = timerShakeRotation,
			transparency = currentTransparency,
		}),

		CancelBtn = React.createElement(DigMinigameCancelButton, {
			transparency = currentTransparency,
			onActivated = props.onCancel,
		}),
	})
end

return DigMinigame
