--!strict

local CompassTheme = {
	Frame = {
		faceColor = Color3.fromHex("#8EE3F5"),
		gradientColors = { Color3.fromHex("#B5F2FD"), Color3.fromHex("#6ED4E8") },
		shadowColor = Color3.fromHex("#1F6274"),
		strokeColor = Color3.fromHex("#144350"),
	},
	HomeBtn = {
		faceColor = Color3.fromHex("#8CE5B0"),
		gradientColors = { Color3.fromHex("#A8F2C7"), Color3.fromHex("#73D49C") },
		shadowColor = Color3.fromHex("#246B42"),
		strokeColor = Color3.fromHex("#184D2F"),
	},
	SettingsBtn = {
		faceColor = Color3.fromHex("#C7B2F8"),
		gradientColors = { Color3.fromHex("#DDD0FC"), Color3.fromHex("#B398F2") },
		shadowColor = Color3.fromHex("#4E338F"),
		strokeColor = Color3.fromHex("#331F63"),
	},
	Tape = {
		backgroundColor = Color3.fromHex("#DCF2FB"),
		tickMajor = Color3.fromHex("#144350"),
		tickMinor = Color3.fromHex("#5B92B6"),
		cardinalNorth = Color3.fromHex("#FF5E57"),
		cardinalMajor = Color3.fromHex("#103348"),
		cardinalMinor = Color3.fromHex("#3E7295"),
		cardinalNorthShadow = Color3.fromHex("#7F1D1D"),
		cardinalMajorShadow = Color3.fromHex("#0B2230"),
	},
	Needle = {
		color = Color3.fromHex("#FF5E57"),
		shadowColor = Color3.fromHex("#C73E3E"),
		strokeColor = Color3.fromHex("#7A1A1A"),
	},
	Waypoints = {
		labelBackground = Color3.fromHex("#173748"),
		labelStroke = Color3.fromHex("#3A718F"),
		textColor = Color3.fromHex("#FFFFFF"),
		textShadow = Color3.fromHex("#091C26"),
	},
}

return table.freeze(CompassTheme)
