--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local ShovelShopConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("ShovelShopConfig"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local ShovelShopService = require(script.Parent.Parent:WaitForChild("Services"):WaitForChild("ShovelShopService"))
local ShovelLoadoutService = require(script.Parent.Parent:WaitForChild("Services"):WaitForChild("ShovelLoadoutService"))

local ShovelShopController = {}
local _trove = Trove.new()
local _lastRequest: { [Player]: number } = {}
local _lastSelect: { [Player]: number } = {}

function ShovelShopController.Init()
	DigNetwork.BuyShovelRequest.on(function(player: Player, shovelId: string)
		local now = os.clock()
		if now - (_lastRequest[player] or 0) < ShovelShopConfig.RequestCooldown then return end
		_lastRequest[player] = now

		local result = ShovelShopService.Purchase(player, shovelId)
		DigNetwork.BuyShovelResult.fire(player, result.ok, result.shovelId, result.reason)
	end)

	DigNetwork.SelectShovelRequest.on(function(player: Player, shovelId: string)
		local now = os.clock()
		if now - (_lastSelect[player] or 0) < ShovelShopConfig.SelectCooldown then return end
		_lastSelect[player] = now
		ShovelLoadoutService.Select(player, shovelId)
	end)

	_trove:Connect(Players.PlayerRemoving, function(player)
		_lastRequest[player] = nil
		_lastSelect[player] = nil
	end)
end

function ShovelShopController.Destroy()
	_trove:Clean()
end

return ShovelShopController
