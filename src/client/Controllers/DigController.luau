--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local SignalTypes = require(Shared:WaitForChild("Types"):WaitForChild("SignalTypes"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local ZoneController = require(script.Parent:WaitForChild("ZoneController"))
local DigInputController = require(script.Parent:WaitForChild("DigInputController"))
local DigPopups = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("DigPopups"))

type Signal<T...> = SignalTypes.Signal<T...>
type DigState = "IDLE" | "CHARGING" | "WAITING_EXCLAMATION" | "EXCLAMATION" | "MINIGAME" | "COOLDOWN"
local DigController = {}
local _trove = Trove.new()
DigController.PowerBarStateChanged = _trove:Construct(Signal) :: Signal<boolean, number>
DigController.MinigameStateChanged = _trove:Construct(Signal) :: Signal<boolean, number, number>
DigController.PlayerStatsChanged = _trove:Construct(Signal) :: Signal<number, number, number, number, number>
local _state: DigState = "IDLE"
local _minigameTrove: any = nil
local _remainingTime, _currentProgress, _cooldownUntil = 15.0, 0.0, 0

local function GetState(): DigState return _state end
local function SetState(s: DigState) _state = s end

local function EndMinigame()
	if _minigameTrove then _minigameTrove:Clean() _minigameTrove = nil end
	SetState("COOLDOWN")
	_currentProgress = 0.0
	DigController.MinigameStateChanged:Fire(false, 0, 0)
	DigInputController.SetSpeed(DigInputController.NORMAL_SPEED)
	_cooldownUntil = os.clock() + 1.4
	task.delay(1.4, function()
		if GetState() == "COOLDOWN" then SetState("IDLE") end
	end)
end

function DigController.Init()
	DigInputController.BindChargeInput({
		onChargeStart = function()
			if GetState() ~= "IDLE" or os.clock() < _cooldownUntil then return false end
			SetState("CHARGING")
			DigInputController.SetSpeed(DigInputController.SLOW_SPEED)
			DigController.PowerBarStateChanged:Fire(true, 0)
			return true
		end,
		onChargeStep = function(power)
			if GetState() == "CHARGING" then DigController.PowerBarStateChanged:Fire(true, power) end
		end,
		onChargeEnd = function(finalPower)
			if GetState() ~= "CHARGING" then return end
			SetState("WAITING_EXCLAMATION")
			DigController.PowerBarStateChanged:Fire(false, finalPower)
			DigPopups.ShowLuckTier(finalPower)
			local zone = ZoneController.GetCurrentZone()
			if zone then DigNetwork.StartDigRequest.fire(finalPower, zone.islandId) else
				SetState("IDLE")
				DigInputController.SetSpeed(DigInputController.NORMAL_SPEED)
			end
		end,
		onTap = function() if GetState() == "MINIGAME" then DigController.Swing() end end,
	})

	_trove:Add(DigNetwork.StartMinigame.on(function(rarity, nodeHp, duration)
		if GetState() ~= "WAITING_EXCLAMATION" then return end
		if _minigameTrove then _minigameTrove:Clean() end
		local mTrove = _trove:Extend()
		_minigameTrove = mTrove

		local waitDelay = math.random(15, 25) / 10
		task.delay(waitDelay, function()
			if GetState() ~= "WAITING_EXCLAMATION" or _minigameTrove ~= mTrove then return end
			SetState("EXCLAMATION")
			DigPopups.ShowExclamation(rarity)

			task.delay(1.0, function()
				if GetState() ~= "EXCLAMATION" or _minigameTrove ~= mTrove then return end
				SetState("MINIGAME")
				_remainingTime = duration
				_currentProgress = 0.0
				DigController.MinigameStateChanged:Fire(true, 0, _remainingTime)

				mTrove:Connect(RunService.RenderStepped, function(dt)
					_remainingTime = math.max(0, _remainingTime - dt)
					DigController.MinigameStateChanged:Fire(true, _currentProgress, _remainingTime)
					if _remainingTime <= 0 then EndMinigame() end
				end)
			end)
		end)
	end))

	_trove:Add(DigNetwork.MinigameHit.on(function(hp, maxHp)
		if GetState() ~= "MINIGAME" then return end
		_currentProgress = 1 - (hp / math.max(1, maxHp))
		DigController.MinigameStateChanged:Fire(true, _currentProgress, _remainingTime)
	end))

	_trove:Add(DigNetwork.MinigameComplete.on(function(success) EndMinigame() end))
	_trove:Add(DigNetwork.PlayerStatsSync.on(function(lvl, exp, reqExp, coins, luck)
		DigController.PlayerStatsChanged:Fire(lvl, exp, reqExp, coins, luck)
	end))
end

function DigController.Swing()
	if GetState() == "MINIGAME" then DigNetwork.SwingRequest.fire() end
end

function DigController.CancelDig()
	local s = GetState()
	if s == "MINIGAME" or s == "EXCLAMATION" or s == "WAITING_EXCLAMATION" then EndMinigame() end
end

function DigController.Destroy()
	_trove:Clean()
	DigInputController.Destroy()
end

return DigController
