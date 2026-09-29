--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local SellConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("SellConfig"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local SellService = require(script.Parent.Parent:WaitForChild("Services"):WaitForChild("SellService"))

local SellController = {}
local _trove = Trove.new()
local _lastRequest: { [Player]: number } = {}

function SellController.Init()
	DigNetwork.SellRequest.on(function(player: Player, mode: "All" | "Held")
		local now = os.clock()
		if now - (_lastRequest[player] or 0) < SellConfig.RequestCooldown then return end
		_lastRequest[player] = now

		local result = SellService.Sell(player, mode)
		DigNetwork.SellResult.fire(player, result.ok, result.coins, result.count, result.reason)
	end)

	_trove:Connect(Players.PlayerRemoving, function(player)
		_lastRequest[player] = nil
	end)
end

function SellController.Destroy()
	_trove:Clean()
end

return SellController
