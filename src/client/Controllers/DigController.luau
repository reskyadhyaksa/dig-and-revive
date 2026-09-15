--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))
local Signal = require(Packages:WaitForChild("Signal"))
local Promise = require(Packages:WaitForChild("Promise"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local SignalTypes = require(Shared:WaitForChild("Types"):WaitForChild("SignalTypes"))
local ShovelConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelConfig"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local ZoneController = require(script.Parent:WaitForChild("ZoneController"))

type Signal<T...> = SignalTypes.Signal<T...>

local LocalPlayer = Players.LocalPlayer

local DigController = {}
DigController.__index = DigController

local _controllerTrove = Trove.new()

-- State UI Minigame
DigController.UIStateChanged = _controllerTrove:Construct(Signal) :: Signal<boolean, number>

local _isHolding = false
local _currentPower = 0
local _lastDigTime = 0
local _chargeThread: thread? = nil
local _renderConn: RBXScriptConnection? = nil

-- Konfigurasi Minigame
local MAX_CHARGE_TIME = 1.0 -- Butuh 1 detik untuk penuh (1.0 power)

function DigController.Init()
	local function StartCharging()
		local currentZone = ZoneController.GetCurrentZone()
		if not currentZone then return end
		
		-- Cek apakah pakai shovel (Cek Tool di Character)
		local char = LocalPlayer.Character
		if not char then return end
		
		local tool = char:FindFirstChildWhichIsA("Tool")
		if not tool then return end
		
		local shovelCfg = ShovelConfig.GetShovelConfig(tool.Name)
		if not shovelCfg then return end -- Bukan shovel yang terdaftar
		
		-- Cek Cooldown
		local now = os.clock()
		if now - _lastDigTime < shovelCfg.cooldown then
			return -- Masih cooldown
		end

		_isHolding = true
		_currentPower = 0
		
		-- Animasi Bar di UI (Fire true dan 0 power awal)
		DigController.UIStateChanged:Fire(true, _currentPower)
		
		local startTime = os.clock()
		
		local existingConn = _renderConn
		if existingConn then
			_renderConn = nil
			existingConn:Disconnect()
		end
		
		_renderConn = RunService.RenderStepped:Connect(function()
			if not _isHolding then
				local conn = _renderConn
				if conn then
					_renderConn = nil
					conn:Disconnect()
				end
				return
			end
			
			local elapsed = os.clock() - startTime
			_currentPower = math.clamp(elapsed / MAX_CHARGE_TIME, 0, 1)
			
			DigController.UIStateChanged:Fire(true, _currentPower)
		end)
	end

	local function StopCharging()
		if not _isHolding then return end
		_isHolding = false
		
		local conn = _renderConn
		if conn then
			_renderConn = nil
			conn:Disconnect()
		end
		
		local finalPower = _currentPower
		_currentPower = 0
		DigController.UIStateChanged:Fire(false, 0)
		
		local currentZone = ZoneController.GetCurrentZone()
		if currentZone then
			local char = LocalPlayer.Character
			local tool = char and char:FindFirstChildWhichIsA("Tool")
			local shovelCfg = tool and ShovelConfig.GetShovelConfig(tool.Name)
			
			if shovelCfg then
				_lastDigTime = os.clock()
				DigController.SendDigRequest(currentZone.islandId, finalPower)
			end
		end
	end

	local function OnInputBegan(input: InputObject, gameProcessed: boolean)
		if gameProcessed then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			StartCharging()
		end
	end

	local function OnInputEnded(input: InputObject, gameProcessed: boolean)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			StopCharging()
		end
	end

	_controllerTrove:Add(UserInputService.InputBegan:Connect(OnInputBegan))
	_controllerTrove:Add(UserInputService.InputEnded:Connect(OnInputEnded))
end

function DigController.SendDigRequest(islandId: string, power: number)
	DigNetwork.DigRequest.fire(power, islandId)
end

function DigController.Destroy()
	_controllerTrove:Clean()
	_isHolding = false
end

return DigController
