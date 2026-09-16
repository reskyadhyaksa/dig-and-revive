--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local ZoneNotificationBanner = require(script.Parent.Components.ZoneNotificationBanner)
local HoldPowerBar = require(script.Parent.Components.HoldPowerBar)
local DigMinigame = require(script.Parent.Components.DigMinigame)
local StatsHUD = require(script.Parent.Components.StatsHUD)
local ZoneController = require(script.Parent.Parent.Controllers.ZoneController)
local DigController = require(script.Parent.Parent.Controllers.DigController)

type NotificationState = {
	title: string,
	subtitle: string?,
	visible: boolean,
	themeColor: Color3?,
}

local function App(): any
	local notifState, setNotifState = React.useState({
		title = "",
		subtitle = nil :: string?,
		visible = false,
		themeColor = nil :: Color3?,
	})

	local holdPowerState, setHoldPowerState = React.useState({
		visible = false,
		power = 0,
	})

	local minigameState, setMinigameState = React.useState({
		visible = false,
		progress = 0,
		remainingTime = 15,
	})

	local playerStats, setPlayerStats = React.useState({
		level = 1,
		exp = 0,
		requiredExp = 100,
		coins = 0,
		luckMultiplier = 1.0,
	})

	React.useEffect(function()
		local timerThread: thread? = nil

		local conn = ZoneController.CurrentZoneChanged:Connect(function(zoneInfo)
			if timerThread then
				task.cancel(timerThread)
				timerThread = nil
			end

			if zoneInfo then
				setNotifState({
					title = zoneInfo.displayName,
					subtitle = "MEMASUKI AREA",
					visible = true,
					themeColor = Color3.fromRGB(46, 204, 113),
				})

				timerThread = task.delay(3.5, function()
					setNotifState(function(prev)
						return {
							title = prev.title,
							subtitle = prev.subtitle,
							visible = false,
							themeColor = prev.themeColor,
						}
					end)
				end)
			else
				setNotifState({
					title = "Area Terbuka",
					subtitle = "KELUAR ZONA",
					visible = true,
					themeColor = Color3.fromRGB(230, 126, 34),
				})

				timerThread = task.delay(2.5, function()
					setNotifState(function(prev)
						return {
							title = prev.title,
							subtitle = prev.subtitle,
							visible = false,
							themeColor = prev.themeColor,
						}
					end)
				end)
			end
		end)

		local powerConn = DigController.PowerBarStateChanged:Connect(function(visible: boolean, power: number)
			setHoldPowerState({
				visible = visible,
				power = power,
			})
		end)

		local minigameConn = DigController.MinigameStateChanged:Connect(function(visible: boolean, progress: number, remainingTime: number)
			setMinigameState({
				visible = visible,
				progress = progress,
				remainingTime = remainingTime,
			})
		end)

		local statsConn = DigController.PlayerStatsChanged:Connect(function(
			level: number,
			exp: number,
			requiredExp: number,
			coins: number,
			luckMultiplier: number
		)
			setPlayerStats({
				level = level,
				exp = exp,
				requiredExp = requiredExp,
				coins = coins,
				luckMultiplier = luckMultiplier,
			})
		end)

		return function()
			conn:Disconnect()
			powerConn:Disconnect()
			minigameConn:Disconnect()
			statsConn:Disconnect()
			if timerThread then
				task.cancel(timerThread)
			end
		end
	end, {})

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, {
		Banner = React.createElement(ZoneNotificationBanner, {
			title = notifState.title,
			subtitle = notifState.subtitle,
			visible = notifState.visible,
			themeColor = notifState.themeColor,
		}),

		HoldPowerBar = React.createElement(HoldPowerBar, {
			visible = holdPowerState.visible,
			power = holdPowerState.power,
		}),

		DigMinigame = React.createElement(DigMinigame, {
			visible = minigameState.visible,
			progress = minigameState.progress,
			remainingTime = minigameState.remainingTime,
			onSwing = function()
				DigController.Swing()
			end,
		}),

		StatsHUD = React.createElement(StatsHUD, {
			level = playerStats.level,
			exp = playerStats.exp,
			requiredExp = playerStats.requiredExp,
			coins = playerStats.coins,
			luckMultiplier = playerStats.luckMultiplier,
		}),
	})
end

return App
