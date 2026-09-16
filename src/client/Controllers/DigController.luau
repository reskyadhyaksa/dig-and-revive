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
local LocalPlayer = Players.LocalPlayer

local DigController = {}
local _trove = Trove.new()

DigController.PowerBarStateChanged = _trove:Construct(Signal) :: Signal<boolean, number>
DigController.MinigameStateChanged = _trove:Construct(Signal) :: Signal<boolean, number, number>
DigController.PlayerStatsChanged = _trove:Construct(Signal) :: Signal<number, number, number, number, number>

local _isBusy = false
local _minigameTrove: any = nil
local _remainingTime = 15.0

local function EndMinigame()
	if _minigameTrove then _minigameTrove:Clean() _minigameTrove = nil end
	_isBusy = false
	DigController.MinigameStateChanged:Fire(false, 0, 0)
end

function DigController.Init()
	DigInputController.BindChargeInput({
		onChargeStart = function()
			if _isBusy then return false end
			_isBusy = true
			DigController.PowerBarStateChanged:Fire(true, 0)
			return true
		end,
		onChargeStep = function(power)
			DigController.PowerBarStateChanged:Fire(true, power)
		end,
		onChargeEnd = function(finalPower)
			DigController.PowerBarStateChanged:Fire(false, finalPower)
			DigPopups.ShowLuckTier(finalPower)
			local zone = ZoneController.GetCurrentZone()
			if zone then DigNetwork.StartDigRequest.fire(finalPower, zone.islandId) else _isBusy = false end
		end,
	})

	_trove:Add(DigNetwork.StartMinigame.on(function(rarity, nodeHp, duration)
		DigPopups.ShowExclamation(rarity)
		if _minigameTrove then _minigameTrove:Clean() end
		_minigameTrove = _trove:Extend()
		_remainingTime = duration

		_minigameTrove:Connect(RunService.RenderStepped, function(dt)
			_remainingTime = math.max(0, _remainingTime - dt)
			DigController.MinigameStateChanged:Fire(true, 0, _remainingTime)
			if _remainingTime <= 0 then EndMinigame() end
		end)
	end))

	_trove:Add(DigNetwork.MinigameHit.on(function(hp, maxHp)
		local progress = 1 - (hp / math.max(1, maxHp))
		DigController.MinigameStateChanged:Fire(true, progress, _remainingTime)
	end))

	_trove:Add(DigNetwork.MinigameComplete.on(function(success)
		EndMinigame()
	end))

	_trove:Add(DigNetwork.PlayerStatsSync.on(function(lvl, exp, reqExp, coins, luck)
		DigController.PlayerStatsChanged:Fire(lvl, exp, reqExp, coins, luck)
	end))
end

function DigController.Swing()
	DigNetwork.SwingRequest.fire()
end

function DigController.Destroy()
	_trove:Clean()
	DigInputController.Destroy()
end

return DigController
