--!strict

local React = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("React"))
local ZoneController = require(script.Parent.Parent.Parent:WaitForChild("Controllers"):WaitForChild("ZoneController"))
local DigController = require(script.Parent.Parent.Parent:WaitForChild("Controllers"):WaitForChild("DigController"))

export type AppState = {
	notif: { title: string, subtitle: string?, visible: boolean, themeColor: Color3? },
	power: { visible: boolean, power: number },
	minigame: { visible: boolean, progress: number, remainingTime: number },
	stats: { level: number, exp: number, requiredExp: number, coins: number, luckMultiplier: number },
}

local function useAppSignals(): AppState
	local notif, setNotif = React.useState({ title = "", subtitle = nil :: string?, visible = false, themeColor = nil :: Color3? })
	local power, setPower = React.useState({ visible = false, power = 0 })
	local minigame, setMinigame = React.useState({ visible = false, progress = 0, remainingTime = 15 })
	local stats, setStats = React.useState({ level = 1, exp = 0, requiredExp = 100, coins = 0, luckMultiplier = 1.0 })

	React.useEffect(function()
		local timer: thread? = nil

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

		return function()
			zConn:Disconnect() pConn:Disconnect() mConn:Disconnect() sConn:Disconnect()
			if timer then task.cancel(timer) end
		end
	end, {})

	return { notif = notif, power = power, minigame = minigame, stats = stats }
end

return useAppSignals
