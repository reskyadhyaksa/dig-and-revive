--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local ZoneNotificationBanner = require(script.Parent.Components.ZoneNotificationBanner)
local HoldPowerBar = require(script.Parent.Components.HoldPowerBar)
local DigMinigame = require(script.Parent.Components.DigMinigame)
local StatsHUD = require(script.Parent.Components.StatsHUD)
local Hotbar = require(script.Parent.Components.Hotbar)
local InventoryModal = require(script.Parent.Components.Inventory.InventoryModal)
local IndexModal = require(script.Parent.Components.Index.IndexModal)
local DigController = require(script.Parent.Parent.Controllers.DigController)
local useAppSignals = require(script.Parent.Hooks.useAppSignals)
local DefaultInventoryHelper = require(script.Parent.Common.DefaultInventoryHelper)
local InventoryTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("InventoryTypes"))

type InventoryItem = InventoryTypes.InventoryItem

local function GetAllItems(savedItems: { InventoryItem }?): { InventoryItem }
	local combined: { InventoryItem } = table.clone(savedItems or {})
	for _, shovel in ipairs(DefaultInventoryHelper.GetClientShovelItems()) do
		table.insert(combined, shovel)
	end
	return combined
end

local function App(): any
	local state = useAppSignals()
	local invOpen, setInvOpen = React.useState(false)
	local invTab, setInvTab = React.useState("Items")
	local indexOpen, setIndexOpen = React.useState(false)

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, {
		Banner = React.createElement(ZoneNotificationBanner, {
			title = state.notif.title, subtitle = state.notif.subtitle,
			visible = state.notif.visible, themeColor = state.notif.themeColor,
		}),

		PowerBar = React.createElement(HoldPowerBar, {
			visible = state.power.visible, power = state.power.power,
		}),

		Minigame = React.createElement(DigMinigame, {
			visible = state.minigame.visible, progress = state.minigame.progress,
			remainingTime = state.minigame.remainingTime, onCancel = DigController.CancelDig,
		}),

		Stats = React.createElement(StatsHUD, {
			level = state.stats.level, exp = state.stats.exp,
			requiredExp = state.stats.requiredExp, coins = state.stats.coins,
			luckMultiplier = state.stats.luckMultiplier,
		}),

		Hotbar = React.createElement(Hotbar, {
			onSelectShovel = function()
				if invOpen and invTab == "Shovel" then setInvOpen(false) else
					setInvTab("Shovel") setInvOpen(true) setIndexOpen(false)
				end
			end,
			onOpenInventory = function()
				if invOpen and invTab == "Items" then setInvOpen(false) else
					setInvTab("Items") setInvOpen(true) setIndexOpen(false)
				end
			end,
			onOpenIndex = function()
				setIndexOpen(not indexOpen)
				if not indexOpen then setInvOpen(false) end
			end,
		}),

		Inventory = if invOpen then React.createElement(InventoryModal, {
			visible = true,
			items = GetAllItems(state.inventoryItems),
			playerLevel = state.stats.level or 1,
			defaultTab = invTab,
			onClose = function() setInvOpen(false) end,
		}) else nil,

		Index = if indexOpen then React.createElement(IndexModal, {
			visible = true,
			indexData = state.indexData,
			onClose = function() setIndexOpen(false) end,
		}) else nil,
	})
end

return App
