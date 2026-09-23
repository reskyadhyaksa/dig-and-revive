--!strict

local InventoryTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("InventoryTypes"))

type TabConfig = InventoryTypes.TabConfig
type SortConfig = InventoryTypes.SortConfig

local InventoryConfig = {
	MaxCapacityHardCap = 2500,

	Tabs = {
		{ id = "Fossils", displayName = "Fossils", icon = "rbxassetid://135832742918451", order = 1 },
		{ id = "Revival", displayName = "Revival", icon = "rbxassetid://122992611665292", order = 2 },
		{ id = "Shovel", displayName = "Shovels", icon = "rbxassetid://100488739842115", order = 3 },
		{ id = "Potion", displayName = "Potions", icon = "rbxassetid://100488739842115", order = 4 },
		{ id = "Codex", displayName = "Codex", icon = "rbxassetid://100488739842115", order = 5 },
	} :: { TabConfig },

	SortOptions = {
		{ id = "Newest", displayName = "Newest", icon = "🕒" },
		{ id = "Oldest", displayName = "Oldest", icon = "⏳" },
		{ id = "Rarity", displayName = "Rarity", icon = "💎" },
		{ id = "Weight", displayName = "Weight", icon = "⚖️" },
		{ id = "Name", displayName = "Name (A-Z)", icon = "🔤" },
		{ id = "Favorited", displayName = "Favorites", icon = "⭐" },
	} :: { SortConfig },

	RarityWeights = {
		Common = 1,
		Uncommon = 2,
		Epic = 3,
		Legendary = 4,
		Mythic = 5,
		Secret = 6,
	} :: { [string]: number },

	RarityColors = {
		Common = Color3.fromRGB(160, 165, 175),
		Uncommon = Color3.fromRGB(46, 204, 113),
		Epic = Color3.fromRGB(155, 89, 182),
		Legendary = Color3.fromRGB(241, 196, 15),
		Mythic = Color3.fromRGB(231, 76, 60),
		Secret = Color3.fromRGB(26, 188, 156),
	} :: { [string]: Color3 },

	WoodTheme = {
		OuterBorder = Color3.fromHex("#3E2716"),
		PlankFace = Color3.fromHex("#7B4B27"),
		PlankShadow = Color3.fromHex("#523017"),
		PlankHighlight = Color3.fromHex("#945B31"),
		RivetColor = Color3.fromHex("#C8CBD4"),
		InnerBed = Color3.fromHex("#1E2430"),
		SlotBg = Color3.fromHex("#28303F"),
		SlotBorder = Color3.fromHex("#3D485C"),
	},
}

return table.freeze(InventoryConfig)
