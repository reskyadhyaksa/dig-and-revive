--!strict

local HotbarTheme = {
	Shovel = {
		faceColor = Color3.fromHex("#8CE5B0"),
		gradientColors = { Color3.fromHex("#A8F2C7"), Color3.fromHex("#73D49C") },
		shadowColor = Color3.fromHex("#246B42"),
		strokeColor = Color3.fromHex("#184D2F"),
		icon = "rbxassetid://100488739842115",
	},
	Inventory = {
		faceColor = Color3.fromHex("#C7B2F8"),
		gradientColors = { Color3.fromHex("#DDD0FC"), Color3.fromHex("#B398F2") },
		shadowColor = Color3.fromHex("#4E338F"),
		strokeColor = Color3.fromHex("#331F63"),
		icon = "rbxassetid://122992611665292",
	},
	SelectShovel = {
		faceColor = Color3.fromHex("#FFB7A1"),
		gradientColors = { Color3.fromHex("#FFCFC0"), Color3.fromHex("#FA9E84") },
		shadowColor = Color3.fromHex("#8F3821"),
		strokeColor = Color3.fromHex("#612312"),
		icon = "rbxassetid://100488739842115",
	},
}

return table.freeze(HotbarTheme)
