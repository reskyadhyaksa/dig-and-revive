--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NpcDialogConfig = require(Shared:WaitForChild("Configs"):WaitForChild("NpcDialogConfig"))
local SellUtils = require(Shared:WaitForChild("Utils"):WaitForChild("SellUtils"))
local DialogTypes = require(Shared:WaitForChild("Types"):WaitForChild("DialogTypes"))
local InventoryTypes = require(Shared:WaitForChild("Types"):WaitForChild("InventoryTypes"))
local Controllers = script.Parent.Parent.Parent:WaitForChild("Controllers")
local NpcInteractController = require(Controllers:WaitForChild("NpcInteractController"))
local DigNetwork = require(script.Parent.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))

type DialogOption = DialogTypes.DialogOption
type InventoryItem = InventoryTypes.InventoryItem

export type NpcDialogState = {
	isOpen: boolean,
	npcName: string,
	text: string,
	options: { DialogOption },
	onOption: (option: DialogOption) -> (),
}

type ResultState = { ok: boolean, coins: number, reason: string? }

local EMPTY_OPTIONS: { DialogOption } = {}

local function useNpcDialog(inventoryItems: { InventoryItem }): NpcDialogState
	local npcKey, setNpcKey = React.useState(nil :: string?)
	local nodeId, setNodeId = React.useState("")
	local result, setResult = React.useState(nil :: ResultState?)

	local tree = if npcKey then NpcDialogConfig[npcKey] else nil

	React.useEffect(function()
		local openConn = NpcInteractController.DialogOpened:Connect(function(key)
			local t = NpcDialogConfig[key]
			if not t then return end
			setNpcKey(key) setNodeId(t.start) setResult(nil)
		end)
		local closeConn = NpcInteractController.DialogClosed:Connect(function() setNpcKey(nil) end)
		local resultConn = NpcInteractController.SellResultReceived:Connect(function(ok, coins, _count, reason)
			setResult({ ok = ok, coins = coins, reason = reason })
		end)
		return function() openConn:Disconnect() closeConn:Disconnect() resultConn:Disconnect() end
	end, {})

	local preview = React.useMemo(function()
		local sellable = SellUtils.FilterSellAll(inventoryItems or {})
		return { price = SellUtils.TotalPrice(sellable), count = #sellable }
	end, { inventoryItems } :: { any })

	local onOption = React.useCallback(function(option: DialogOption)
		if option.action == "Close" then NpcInteractController.CloseDialog() return end
		if option.action == "SellAll" then DigNetwork.SellRequest.fire("All") return end
		if option.action == "SellHeld" then DigNetwork.SellRequest.fire("Held") return end
		if option.next then setNodeId(option.next) setResult(nil) end
	end, {})

	if not tree then
		return { isOpen = false, npcName = "", text = "", options = EMPTY_OPTIONS, onOption = onOption }
	end

	if result then
		local key = if result.ok then "success" else (result.reason or "NothingToSell")
		local template = tree.results[key] or tree.results.NothingToSell
		return {
			isOpen = true, npcName = tree.npcName, onOption = onOption,
			text = SellUtils.FormatText(template, { price = result.coins }),
			options = { { label = "Back", next = tree.start }, { label = "Bye!", action = "Close" } },
		}
	end

	local node = tree.nodes[nodeId] or tree.nodes[tree.start]
	return {
		isOpen = true, npcName = tree.npcName, onOption = onOption,
		text = SellUtils.FormatText(node.text, { price = preview.price, count = preview.count }),
		options = node.options,
	}
end

return useNpcDialog
