--!strict

local React = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("React"))

local ZoneNotificationBanner = require(script.Parent.Components.ZoneNotificationBanner)
local HoldPowerBar = require(script.Parent.Components.HoldPowerBar)
local DigMinigame = require(script.Parent.Components.DigMinigame)
local StatsHUD = require(script.Parent.Components.StatsHUD)
local DigController = require(script.Parent.Parent.Controllers.DigController)
local useAppSignals = require(script.Parent.Hooks.useAppSignals)

local function App(): any
	local state = useAppSignals()

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, {
		Banner = React.createElement(ZoneNotificationBanner, {
			title = state.notif.title,
			subtitle = state.notif.subtitle,
			visible = state.notif.visible,
			themeColor = state.notif.themeColor,
		}),

		PowerBar = React.createElement(HoldPowerBar, {
			visible = state.power.visible,
			power = state.power.power,
		}),

		Minigame = React.createElement(DigMinigame, {
			visible = state.minigame.visible,
			progress = state.minigame.progress,
			remainingTime = state.minigame.remainingTime,
			onSwing = function()
				DigController.Swing()
			end,
		}),

		Stats = React.createElement(StatsHUD, {
			level = state.stats.level,
			exp = state.stats.exp,
			requiredExp = state.stats.requiredExp,
			coins = state.stats.coins,
			luckMultiplier = state.stats.luckMultiplier,
		}),
	})
end

return App
