--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local ZoneNotificationBanner = require(script.Parent.Components.ZoneNotificationBanner)
local CompassTapeGui = require(script.Parent.Components.Compass.CompassTapeGui)
local HoldPowerBar = require(script.Parent.Components.HoldPowerBar)
local DigMinigame = require(script.Parent.Components.DigMinigame)
local StatsHUD = require(script.Parent.Components.StatsHUD)
local Hotbar = require(script.Parent.Components.Hotbar)
local InventoryModal = require(script.Parent.Components.Inventory.InventoryModal)
local IndexModal = require(script.Parent.Components.Index.IndexModal)
local DialogBox = require(script.Parent.Components.Dialog.DialogBox)
local DigController = require(script.Parent.Parent.Controllers.DigController)
local useAppSignals = require(script.Parent.Hooks.useAppSignals)
local useCompass = require(script.Parent.Hooks.useCompass)
local useNpcDialog = require(script.Parent.Hooks.useNpcDialog)
local DefaultInventoryHelper = require(script.Parent.Common.DefaultInventoryHelper)
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))
local InventoryTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("InventoryTypes"))

type InventoryItem = InventoryTypes.InventoryItem

local function GetAllItems(savedItems: { InventoryItem }?): { InventoryItem }
	local combined: { InventoryItem } = table.clone(savedItems or {})
	for _, shovel in ipairs(DefaultInventoryHelper.GetClientShovelItems()) do table.insert(combined, shovel) end
	return combined
end

local function HandleEquipToggle(item: InventoryItem)
	local p = Players.LocalPlayer
	local char = if p then p.Character else nil
	local bp = if p then p:FindFirstChildOfClass("Backpack") else nil
	local hum = if char then char:FindFirstChildOfClass("Humanoid") else nil
	if not p or not char then return end

	if item.category == "Shovel" then
		local toolName = item.templateId or item.displayName
		local inChar = char:FindFirstChild(toolName) or char:FindFirstChildWhichIsA("Tool")
		local inBp = if bp then (bp:FindFirstChild(toolName) or bp:FindFirstChildWhichIsA("Tool")) else nil
		if inChar then
			if hum then hum:UnequipTools() else inChar.Parent = bp end
		elseif inBp then
			if hum then hum:EquipTool(inBp) else inBp.Parent = char end
		end
	else
		DigNetwork.EquipItemRequest.fire(item.id)
	end
end

local function App(): any
	local state = useAppSignals()
	local compass = useCompass()
	local invOpen, setInvOpen = React.useState(false)
	local invTab, setInvTab = React.useState("Fossils")
	local indexOpen, setIndexOpen = React.useState(false)
	local dialog = useNpcDialog(state.inventoryItems)

	React.useEffect(function()
		if dialog.isOpen then setInvOpen(false) setIndexOpen(false) end
	end, { dialog.isOpen })

	local equippedItems = React.useMemo(function()
		local list: { InventoryItem } = {}
		for _, it in ipairs(state.inventoryItems or {}) do
			if it.isEquipped and it.category ~= "Shovel" then table.insert(list, it) end
		end
		return list
	end, { state.inventoryItems } :: { any })

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
	}, {
		Compass = React.createElement(CompassTapeGui, {
			yawDeg = compass.yawDeg, waypoints = compass.waypoints, visible = true,
			onIndexActivated = function()
				if indexOpen then setIndexOpen(false) else setIndexOpen(true) setInvOpen(false) end
			end,
		}),
		Banner = React.createElement(ZoneNotificationBanner, {
			title = state.notif.title, subtitle = state.notif.subtitle,
			visible = state.notif.visible, themeColor = state.notif.themeColor,
		}),
		PowerBar = React.createElement(HoldPowerBar, { visible = state.power.visible, power = state.power.power }),
		Minigame = React.createElement(DigMinigame, {
			visible = state.minigame.visible, progress = state.minigame.progress,
			remainingTime = state.minigame.remainingTime, onCancel = DigController.CancelDig,
		}),
		Stats = React.createElement(StatsHUD, {
			level = state.stats.level, exp = state.stats.exp,
			requiredExp = state.stats.requiredExp, coins = state.stats.coins, luckMultiplier = state.stats.luckMultiplier,
		}),
		Dialog = if dialog.isOpen then React.createElement(DialogBox, {
			npcName = dialog.npcName, text = dialog.text, options = dialog.options, onOption = dialog.onOption,
		}) else nil,
		Hotbar = if dialog.isOpen then nil else React.createElement(Hotbar, {
			equippedItems = equippedItems,
			onSelectShovel = function()
				if invOpen and invTab == "Shovel" then setInvOpen(false) else setInvTab("Shovel") setInvOpen(true) setIndexOpen(false) end
			end,
			onOpenInventory = function()
				if invOpen and invTab == "Fossils" then setInvOpen(false) else setInvTab("Fossils") setInvOpen(true) setIndexOpen(false) end
			end,
			onRemoveSlotItem = function(it) DigNetwork.EquipItemRequest.fire(it.id) end,
		}),
		Inventory = if invOpen then React.createElement(InventoryModal, {
			visible = true, items = GetAllItems(state.inventoryItems), playerLevel = state.stats.level or 1,
			defaultTab = invTab, onClose = function() setInvOpen(false) end,
			onOpenCodex = function() setIndexOpen(true) setInvOpen(false) end, onEquipToggle = HandleEquipToggle,
		}) else nil,
		Index = if indexOpen then React.createElement(IndexModal, {
			visible = true, indexData = state.indexData, onClose = function() setIndexOpen(false) end,
		}) else nil,
	})
end

return App
