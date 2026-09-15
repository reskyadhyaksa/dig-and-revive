--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local ZoneNotificationBanner = require(script.Parent.Components.ZoneNotificationBanner)
local HoldPowerBar = require(script.Parent.Components.HoldPowerBar)
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
	
	local digUIState, setDigUIState = React.useState({
		visible = false,
		power = 0,
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
		
		local digConn = DigController.UIStateChanged:Connect(function(visible: boolean, power: number)
			setDigUIState({
				visible = visible,
				power = power,
			})
		end)

		return function()
			conn:Disconnect()
			digConn:Disconnect()
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
		
		DigPowerBar = React.createElement(HoldPowerBar, {
			visible = digUIState.visible,
			power = digUIState.power,
		}),
	})
end

return App
