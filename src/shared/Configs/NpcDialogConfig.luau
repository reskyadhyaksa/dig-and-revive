--!strict

local DialogTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("DialogTypes"))

type DialogTree = DialogTypes.DialogTree

local NpcDialogConfig: { [string]: DialogTree } = {
	Merchant = {
		npcName = "Old Merchant",
		start = "greet",
		nodes = {
			greet = {
				text = "Hey digger! Found anything worth selling?",
				options = {
					{ label = "Sell all items", next = "confirmAll" },
					{ label = "Sell held item", action = "SellHeld" },
					{ label = "Nevermind", action = "Close" },
				},
			},
			confirmAll = {
				text = "I'll give you {price} coins for {count} items. Deal?",
				options = {
					{ label = "Deal!", action = "SellAll" },
					{ label = "Hmm, not yet", next = "greet" },
				},
			},
		},
		results = {
			success = "Pleasure doing business! +{price} coins",
			NothingToSell = "You don't have anything I can buy.",
			NoHeldItem = "Hold the fossil you want to sell first.",
			TooFar = "Come closer, I can't hear you!",
			Unsellable = "I can't buy that one.",
		},
	},
}

return table.freeze(NpcDialogConfig)
