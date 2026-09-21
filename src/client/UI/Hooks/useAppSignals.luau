--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local ZoneController = require(script.Parent.Parent.Parent:WaitForChild("Controllers"):WaitForChild("ZoneController"))
local DigController = require(script.Parent.Parent.Parent:WaitForChild("Controllers"):WaitForChild("DigController"))
local IndexTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("IndexTypes"))
local InventoryTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("InventoryTypes"))

type PlayerIndexData = IndexTypes.PlayerIndexData
type InventoryItem = InventoryTypes.InventoryItem

export type AppState = {
	notif: { title: string, subtitle: string?, visible: boolean, themeColor: Color3? },
	power: { visible: boolean, power: number },
	minigame: { visible: boolean, progress: number, remainingTime: number },
	stats: { level: number, exp: number, requiredExp: number, coins: number, luckMultiplier: number },
	indexData: PlayerIndexData,
	inventoryItems: { InventoryItem },
}

local function ParseJsonAttribute<T>(attributeName: string): T?
	local lp = Players.LocalPlayer
	if not lp then return nil end
	local raw = lp:GetAttribute(attributeName)
	if raw and typeof(raw) == "string" then
		local ok, result = pcall(HttpService.JSONDecode, HttpService, raw)
		if ok and typeof(result) == "table" then return result :: any end
	end
	return nil
end

local function useAppSignals(): AppState
	local notif, setNotif = React.useState({ title = "", subtitle = nil :: string?, visible = false, themeColor = nil :: Color3? })
	local power, setPower = React.useState({ visible = false, power = 0 })
	local minigame, setMinigame = React.useState({ visible = false, progress = 0, remainingTime = 15 })
	local stats, setStats = React.useState({ level = 1, exp = 0, requiredExp = 100, coins = 0, luckMultiplier = 1.0 })
	local indexData, setIndexData = React.useState((ParseJsonAttribute("IndexData") or {}) :: PlayerIndexData)
	local inventoryItems, setInventoryItems = React.useState((ParseJsonAttribute("InventoryData") or {}) :: { InventoryItem })

	React.useEffect(function()
		local timer: thread? = nil
		local lp = Players.LocalPlayer

		local zConn = ZoneController.CurrentZoneChanged:Connect(function(zone)
			if timer then task.cancel(timer) end
			if zone then
				setNotif({ title = zone.displayName, subtitle = "MEMASUKI AREA", visible = true, themeColor = Color3.fromRGB(46, 204, 113) })
				timer = task.delay(3.5, function() setNotif(function(p) return { title = p.title, subtitle = p.subtitle, visible = false, themeColor = p.themeColor } end) end)
			else
				setNotif({ title = "Area Terbuka", subtitle = "KELUAR ZONA", visible = true, themeColor = Color3.fromRGB(230, 126, 34) })
				timer = task.delay(2.5, function() setNotif(function(p) return { title = p.title, subtitle = p.subtitle, visible = false, themeColor = p.themeColor } end) end)
			end
		end)

		local pConn = DigController.PowerBarStateChanged:Connect(function(vis, pwr) setPower({ visible = vis, power = pwr }) end)
		local mConn = DigController.MinigameStateChanged:Connect(function(vis, prog, rem) setMinigame({ visible = vis, progress = prog, remainingTime = rem }) end)
		local sConn = DigController.PlayerStatsChanged:Connect(function(lvl, exp, req, coins, luck)
			setStats({ level = lvl, exp = exp, requiredExp = req, coins = coins, luckMultiplier = luck })
		end)

		local idxConn = if lp then lp:GetAttributeChangedSignal("IndexData"):Connect(function()
			setIndexData((ParseJsonAttribute("IndexData") or {}) :: PlayerIndexData)
		end) else nil

		local invConn = if lp then lp:GetAttributeChangedSignal("InventoryData"):Connect(function()
			setInventoryItems((ParseJsonAttribute("InventoryData") or {}) :: { InventoryItem })
		end) else nil

		return function()
			zConn:Disconnect() pConn:Disconnect() mConn:Disconnect() sConn:Disconnect()
			if idxConn then idxConn:Disconnect() end
			if invConn then invConn:Disconnect() end
			if timer then task.cancel(timer) end
		end
	end, {})

	return {
		notif = notif, power = power, minigame = minigame, stats = stats,
		indexData = indexData, inventoryItems = inventoryItems,
	}
end

return useAppSignals
