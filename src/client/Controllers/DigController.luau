--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))
local Signal = require(Packages:WaitForChild("Signal"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local SignalTypes = require(Shared:WaitForChild("Types"):WaitForChild("SignalTypes"))
local ShovelConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelConfig"))
local PowerBarHelper = require(Shared:WaitForChild("Common"):WaitForChild("PowerBarHelper"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local ZoneController = require(script.Parent:WaitForChild("ZoneController"))

type Signal<T...> = SignalTypes.Signal<T...>

local LocalPlayer = Players.LocalPlayer

local DigController = {}
DigController.__index = DigController

local _controllerTrove = Trove.new()

-- Public Signals for UI
DigController.PowerBarStateChanged = _controllerTrove:Construct(Signal) :: Signal<boolean, number>
DigController.MinigameStateChanged = _controllerTrove:Construct(Signal) :: Signal<boolean, number, number>
DigController.PlayerStatsChanged = _controllerTrove:Construct(Signal) :: Signal<number, number, number, number, number>

local DIG_STATE = {
	IDLE = 0,
	CHARGING = 1,
	PREPARING = 2,
	MINIGAME = 3,
}

local _digState = DIG_STATE.IDLE
local _isMinigameActive = false
local _currentPower = 0
local _minigameProgress = 0
local _minigameRemainingTime = 15.0
local _minigameDuration = 15.0

local _lastDigEndTime = 0
local _renderConn: RBXScriptConnection? = nil
local _minigameTrove: any = nil

-- Configured Speeds
local CHARGE_SPEED = 2.5 -- Oscillation frequency
local SLOW_WALK_SPEED = 6
local NORMAL_WALK_SPEED = 16
local LOCKED_WALK_SPEED = 0

local function GetHumanoid(): Humanoid?
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

local function SetWalkSpeed(speed: number)
	local hum = GetHumanoid()
	if hum then
		hum.WalkSpeed = speed
	end
end

-- Raycast ground check under player's feet
local function CheckGroundValid(): boolean
	local char = LocalPlayer.Character
	if not char then return false end
	local rootPart: BasePart? = char.PrimaryPart
	if not rootPart then return false end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { char }

	local result = Workspace:Raycast(rootPart.Position, Vector3.new(0, -6, 0), rayParams)
	return result ~= nil
end

-- Rarity color mapping for Exclamation Mark '!'
local function GetRarityColor(rarity: string): Color3
	if rarity == "Common" then
		return Color3.fromRGB(200, 200, 200)
	elseif rarity == "Uncommon" then
		return Color3.fromRGB(46, 204, 113)
	elseif rarity == "Epic" then
		return Color3.fromRGB(155, 89, 182)
	elseif rarity == "Legendary" then
		return Color3.fromRGB(241, 196, 15)
	elseif rarity == "Mythic" then
		return Color3.fromRGB(231, 76, 60)
	elseif rarity == "Secret" then
		return Color3.fromRGB(0, 255, 230)
	end
	return Color3.fromRGB(255, 255, 255)
end

-- Spawns Luck Tier Popup Billboard above head
local function ShowLuckTierPopup(progress: number)
	local char = LocalPlayer.Character
	if not char then return end

	local headPart: Instance? = char:FindFirstChild("Head") or char.PrimaryPart
	if not headPart or not headPart:IsA("BasePart") then return end
	local head: BasePart = headPart

	local tierText, tierColor = PowerBarHelper.GetLuckTier(progress)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LuckTierPopup"
	billboard.Adornee = head
	billboard.Size = UDim2.new(4.5, 0, 1.4, 0)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.3, 0.3)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.Text = tierText
	label.TextColor3 = tierColor
	label.Font = Enum.Font.LuckiestGuy
	label.TextScaled = true
	label.Parent = billboard

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 3
	stroke.Parent = label

	billboard.Parent = char

	local popupTrove = Trove.new()
	popupTrove:Add(billboard)

	-- 1. Pop-In Animation (0.25s Back Out)
	local popTween = TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1.0, 1.0),
	})
	popTween:Play()

	-- 2. Hold 0.4s then Float & Fade Out
	task.delay(0.55, function()
		local floatTween = TweenService:Create(billboard, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			StudsOffset = Vector3.new(0, 5.2, 0),
		})
		local fadeLabel = TweenService:Create(label, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1,
		})
		local fadeStroke = TweenService:Create(stroke, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
		})

		floatTween:Play()
		fadeLabel:Play()
		fadeStroke:Play()

		task.delay(0.7, function()
			popupTrove:Clean()
		end)
	end)
end

-- Spawns Exclamation Mark '!' Billboard above head
local function ShowExclamationIndicator(rarity: string)
	local char = LocalPlayer.Character
	if not char then return end

	local headPart: Instance? = char:FindFirstChild("Head") or char.PrimaryPart
	if not headPart or not headPart:IsA("BasePart") then return end
	local head: BasePart = headPart

	local color = GetRarityColor(rarity)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ExclamationIndicator"
	billboard.Adornee = head
	billboard.Size = UDim2.new(2.5, 0, 2.5, 0)
	billboard.StudsOffset = Vector3.new(0, 4.2, 0)
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.2, 0.2)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.Text = "!"
	label.TextColor3 = color
	label.Font = Enum.Font.LuckiestGuy
	label.TextScaled = true
	label.Parent = billboard

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 3
	stroke.Parent = label

	billboard.Parent = char

	local exclTrove = Trove.new()
	exclTrove:Add(billboard)

	local popTween = TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1.0, 1.0),
	})
	popTween:Play()

	task.delay(0.65, function()
		local fadeTween = TweenService:Create(label, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1,
		})
		local strokeFade = TweenService:Create(stroke, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
		})
		fadeTween:Play()
		strokeFade:Play()

		task.delay(0.4, function()
			exclTrove:Clean()
		end)
	end)
end

function DigController.Init()
	-- 1. Start Charging Power
	local function StartCharging()
		-- Strictly only allow charging when completely Idle
		if _digState ~= DIG_STATE.IDLE then return end

		local currentZone = ZoneController.GetCurrentZone()
		if not currentZone then return end

		local char = LocalPlayer.Character
		if not char then return end

		local tool = char:FindFirstChildWhichIsA("Tool")
		if not tool then return end

		local shovelCfg = ShovelConfig.GetShovelConfig(tool.Name)
		if not shovelCfg then return end

		local now = os.clock()
		-- Must wait for cooldown delay after previous digging cycle finished
		if now - _lastDigEndTime < shovelCfg.cooldown then
			return
		end

		_digState = DIG_STATE.CHARGING
		_currentPower = 0
		SetWalkSpeed(SLOW_WALK_SPEED)

		DigController.PowerBarStateChanged:Fire(true, 0)

		local startTime = os.clock()
		if _renderConn then
			_renderConn:Disconnect()
			_renderConn = nil
		end

		_renderConn = RunService.RenderStepped:Connect(function()
			if _digState ~= DIG_STATE.CHARGING then
				if _renderConn then
					_renderConn:Disconnect()
					_renderConn = nil
				end
				return
			end

			local elapsed = os.clock() - startTime
			-- Triangular oscillation between 0.0 and 1.0
			local cycle = (elapsed * CHARGE_SPEED) % 2.0
			_currentPower = if cycle > 1.0 then 2.0 - cycle else cycle

			DigController.PowerBarStateChanged:Fire(true, _currentPower)
		end)
	end

	-- 2. Stop Charging & Release
	local function StopCharging()
		if _digState ~= DIG_STATE.CHARGING then return end

		if _renderConn then
			_renderConn:Disconnect()
			_renderConn = nil
		end

		local finalPower = _currentPower
		_currentPower = 0
		DigController.PowerBarStateChanged:Fire(false, 0)

		-- Validate Ground
		if not CheckGroundValid() then
			_digState = DIG_STATE.IDLE
			_lastDigEndTime = os.clock()
			SetWalkSpeed(NORMAL_WALK_SPEED)
			return
		end

		local currentZone = ZoneController.GetCurrentZone()
		if not currentZone then
			_digState = DIG_STATE.IDLE
			_lastDigEndTime = os.clock()
			SetWalkSpeed(NORMAL_WALK_SPEED)
			return
		end

		local char = LocalPlayer.Character
		local tool = char and char:FindFirstChildWhichIsA("Tool")
		local shovelCfg = tool and ShovelConfig.GetShovelConfig(tool.Name)

		if not shovelCfg then
			_digState = DIG_STATE.IDLE
			_lastDigEndTime = os.clock()
			SetWalkSpeed(NORMAL_WALK_SPEED)
			return
		end

		-- Transition to Preparing state (prevents re-triggering hold power)
		_digState = DIG_STATE.PREPARING

		-- Show Luck Tier on Head & Lock Movement
		ShowLuckTierPopup(finalPower)
		SetWalkSpeed(LOCKED_WALK_SPEED)

		-- Request server to start digging session
		DigNetwork.StartDigRequest.fire(finalPower, currentZone.islandId)
	end

	-- 3. Server sends Minigame parameters
	local disconnectStartMinigame = DigNetwork.StartMinigame.on(function(rarity: string, maxHp: number, duration: number)
		if _digState ~= DIG_STATE.PREPARING then
			_digState = DIG_STATE.PREPARING
		end

		_isMinigameActive = false
		_minigameProgress = 0
		_minigameRemainingTime = duration
		_minigameDuration = duration

		if _minigameTrove then
			_minigameTrove:Clean()
		end
		_minigameTrove = _controllerTrove:Extend()

		-- Step 1: Wait random interval 1.5s - 2.5s before showing '!'
		local preWait = math.random(150, 250) / 100

		task.delay(preWait, function()
			if _digState ~= DIG_STATE.PREPARING then return end

			-- Step 2: Show '!' Exclamation Mark indicator
			ShowExclamationIndicator(rarity)

			-- Step 3: Wait another 1.0s after '!' before mounting Digging Minigame UI
			task.delay(1.0, function()
				if _digState ~= DIG_STATE.PREPARING then return end

				_digState = DIG_STATE.MINIGAME
				_isMinigameActive = true

				-- Mount Minigame UI
				DigController.MinigameStateChanged:Fire(true, 0, _minigameRemainingTime)

				-- Countdown Loop
				local startMinigameTime = os.clock()
				local timerConn = RunService.Heartbeat:Connect(function()
					if _digState ~= DIG_STATE.MINIGAME then return end

					local elapsed = os.clock() - startMinigameTime
					local remaining = math.max(0, _minigameDuration - elapsed)
					_minigameRemainingTime = remaining

					DigController.MinigameStateChanged:Fire(true, _minigameProgress, remaining)

					if remaining <= 0 then
						DigController._EndMinigame()
					end
				end)

				if _minigameTrove then
					_minigameTrove:Add(timerConn)
				end
			end)
		end)
	end)

	-- 4. Node Hit Response from Server
	local disconnectHit = DigNetwork.MinigameHit.on(function(currentHp: number, maxHp: number)
		if _digState ~= DIG_STATE.MINIGAME then return end
		_minigameProgress = math.clamp(1.0 - (currentHp / math.max(maxHp, 1)), 0, 1)
		DigController.MinigameStateChanged:Fire(true, _minigameProgress, _minigameRemainingTime)
	end)

	-- 5. Minigame Finished (Win / Timeout / Cancel)
	local disconnectComplete = DigNetwork.MinigameComplete.on(function(
		success: boolean,
		dropId: string?,
		amount: number,
		gainedExp: number,
		newLevel: number,
		newExp: number,
		errorMsg: string?
	)
		DigController._EndMinigame()
	end)

	-- 6. Player Level, EXP, Coins & Stats Sync
	local disconnectStatsSync = DigNetwork.PlayerStatsSync.on(function(
		level: number,
		exp: number,
		requiredExp: number,
		coins: number,
		luckMultiplier: number
	)
		DigController.PlayerStatsChanged:Fire(level, exp, requiredExp, coins, luckMultiplier)
	end)

	-- 7. User Inputs (Hold / Release & Free Screen Tap)
	local function OnInputBegan(input: InputObject, gameProcessed: boolean)
		if gameProcessed then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if _digState == DIG_STATE.MINIGAME then
				DigController.Swing()
			elseif _digState == DIG_STATE.IDLE then
				StartCharging()
			end
		end
	end

	local function OnInputEnded(input: InputObject, gameProcessed: boolean)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if _digState == DIG_STATE.CHARGING then
				StopCharging()
			end
		end
	end

	_controllerTrove:Add(UserInputService.InputBegan:Connect(OnInputBegan))
	_controllerTrove:Add(UserInputService.InputEnded:Connect(OnInputEnded))
	_controllerTrove:Add(disconnectStartMinigame)
	_controllerTrove:Add(disconnectHit)
	_controllerTrove:Add(disconnectComplete)
	_controllerTrove:Add(disconnectStatsSync)
end

function DigController.Swing()
	if _digState ~= DIG_STATE.MINIGAME then return end
	DigNetwork.SwingRequest.fire()
end

function DigController._EndMinigame()
	_digState = DIG_STATE.IDLE
	_isMinigameActive = false
	_minigameProgress = 0
	_minigameRemainingTime = 0
	_lastDigEndTime = os.clock()

	if _minigameTrove then
		_minigameTrove:Clean()
		_minigameTrove = nil
	end

	SetWalkSpeed(NORMAL_WALK_SPEED)
	DigController.MinigameStateChanged:Fire(false, 0, 0)
end

function DigController.Destroy()
	DigController._EndMinigame()
	_controllerTrove:Clean()
	if _renderConn then
		_renderConn:Disconnect()
		_renderConn = nil
	end
end

return DigController
