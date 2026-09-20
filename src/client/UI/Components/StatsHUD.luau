--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

local UIBuilder = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("UIBuilder"))
local UITypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("UITypes"))
local useDeviceType = require(script.Parent.Parent:WaitForChild("Hooks"):WaitForChild("useDeviceType"))

export type Props = UITypes.StatsHUDProps

-- 🎨 THEME & DIMENSION CONFIG
local THEME = {
	Container = {
		MobileSize = UDim2.fromScale(0.25, 0.12),
		DesktopSize = UDim2.fromScale(0.25, 0.10),
		MinSize = Vector2.new(190, 56),
		MaxSize = Vector2.new(280, 68),
		MobileMinSize = Vector2.new(190, 56) * 0.9,
		MobileMaxSize = Vector2.new(280, 68) * 0.8,
	},
	Icons = {
		Coin = "rbxassetid://122992611665292",
		Luck = "rbxassetid://100488739842115",
		Anchor = Vector2.new(0.15, 0),
		Position = UDim2.new(0.04, 0, -0.5, 0),
		Size = UDim2.fromScale(0.38, 1.45),
	},
	Coin = {
		Colors = { Color3.fromRGB(255, 215, 65), Color3.fromRGB(245, 170, 30), Color3.fromRGB(215, 125, 10) },
		Shadow = Color3.fromRGB(160, 95, 0),
		Border = Color3.fromRGB(255, 220, 80),
		TextStroke = Color3.fromRGB(100, 50, 0),
	},
	Luck = {
		Colors = { Color3.fromRGB(80, 235, 140), Color3.fromRGB(46, 204, 113), Color3.fromRGB(25, 150, 75) },
		Shadow = Color3.fromRGB(18, 110, 50),
		Border = Color3.fromRGB(140, 255, 180),
		TextStroke = Color3.fromRGB(15, 75, 30),
	},
	Exp = {
		ChassisBg = Color3.fromRGB(20, 26, 36),
		Border = Color3.fromRGB(10, 14, 20),
		BedBg = Color3.fromRGB(12, 16, 22),
		LevelBoxBg = Color3.fromRGB(22, 28, 38),
		BadgeColors = { Color3.fromHex("B8FA24"), Color3.fromHex("9CE81C"), Color3.fromHex("68C810") },
		BadgeShadow = Color3.fromRGB(42, 92, 10),
		BadgeBorder = Color3.fromRGB(35, 75, 8),
		FillColors = { Color3.fromHex("45F6FF"), Color3.fromHex("00D2FF"), Color3.fromHex("0088DD") },
	},
}

local function FormatNumber(num: number): string
	local n = math.floor(num or 0)
	if n >= 1000000 then
		return string.format("%.1fM", n / 1000000)
	end
	if n >= 1000 then
		return string.format("%.1fK", n / 1000)
	end
	return tostring(n)
end

-- 🧩 Reusable Card Element
local function StatCard(props: { icon: string, text: string, theme: typeof(THEME.Coin) })
	return React.createElement("Frame", {
		Size = UDim2.new(0.5, -3, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Plate = UIBuilder.BevelPlate({
			shadowColor = props.theme.Shadow,
			faceColor = props.theme.Colors[2],
			gradientColors = props.theme.Colors,
			borderColor = props.theme.Border,
			children = {
				Label = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0.36, 0.5),
					Size = UDim2.fromScale(0.60, 0.82),
					BackgroundTransparency = 1,
					Font = Enum.Font.FredokaOne,
					Text = props.text,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					ZIndex = 4,
				}, { Stroke = UIBuilder.TextStroke(props.theme.TextStroke, 1.6) }),
			},
		}),

		Icon = React.createElement("ImageLabel", {
			AnchorPoint = THEME.Icons.Anchor,
			Position = THEME.Icons.Position,
			Size = THEME.Icons.Size,
			BackgroundTransparency = 1,
			Image = props.icon,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 10,
		}, { Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = 1 }) }),
	})
end

local function ExpTubeBar(props: { level: number, exp: number, requiredExp: number, ratio: number })
	local isMobile = useDeviceType().isMobile
	local theme = THEME.Exp
	return React.createElement("Frame", {
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0.50, 0),
		BackgroundTransparency = 1,
	}, {
		-- Right Track Tube (ZIndex 1 / -z1)
		Track = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 44, 0.5, 0),
			Size = UDim2.new(1, -44, 0.75, 0),
			BackgroundColor3 = theme.ChassisBg,
			BorderSizePixel = 0,
			ZIndex = 1,
		}, {
			Corner = UIBuilder.PillCorner(),
			Stroke = UIBuilder.Stroke(theme.Border, 2.5),
			Bed = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -6, 1, -6),
				BackgroundColor3 = theme.BedBg,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				ZIndex = 2,
			}, {
				Corner = UIBuilder.PillCorner(),
				Fill = React.createElement("Frame", {
					Size = UDim2.new(props.ratio, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(0, 210, 255),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					ZIndex = 2,
				}, {
					Corner = UIBuilder.PillCorner(),
					Gradient = UIBuilder.LinearGradient(theme.FillColors, 90),
					Shine = UIBuilder.ShineOverlay(nil, 0.50, 0.82),
				}),
				Label = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.56, 0.5),
					Size = UDim2.fromScale(1, 1.2),
					BackgroundTransparency = 1,
					Font = Enum.Font.FredokaOne,
					Text = string.format("%d / %d", math.floor(props.exp), math.max(1, props.requiredExp)),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					ZIndex = 4,
				}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(0, 0, 0), 1) }),
			}),
		}),

		-- Left Level Box (ZIndex 2)
		LevelBox = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = if isMobile then UDim2.new(0.25, 10, 1, 0) else UDim2.new(0.1, 58, 1, 0),
			BackgroundColor3 = theme.LevelBoxBg,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {
			Corner = UIBuilder.Corner(8),
			Stroke = UIBuilder.Stroke(theme.Border, 2.5),
			Badge = UIBuilder.BevelPlate({
				position = UDim2.fromScale(0.5, 0.5),
				anchorPoint = Vector2.new(0.5, 0.5),
				size = UDim2.new(1, -6, 1, -6),
				cornerRadius = 6,
				shadowColor = theme.BadgeShadow,
				faceColor = theme.BadgeColors[2],
				gradientColors = theme.BadgeColors,
				borderColor = theme.BadgeBorder,
				children = {
					Text = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.92, 0.82),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						Text = string.format("LV. %d", props.level),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						ZIndex = 4,
					}, { Stroke = UIBuilder.TextStroke(Color3.fromRGB(12, 18, 8), if isMobile then 1.25 else 1.3) }),
				},
			}),
		}),
	})
end

local function StatsHUD(props: Props): any
	local isMobile = useDeviceType().isMobile
	local displayExp, setDisplayExp = React.useState(props.exp or 0)
	local targetRatio = if props.requiredExp > 0 then math.clamp(props.exp / props.requiredExp, 0, 1) else 0
	local displayRatio, setDisplayRatio = React.useState(targetRatio)

	React.useEffect(function()
		local conn = RunService.RenderStepped:Connect(function(dt: number)
			setDisplayRatio(function(prev)
				return prev + (targetRatio - prev) * math.clamp(dt * 14, 0, 1)
			end)
			setDisplayExp(function(prev)
				return prev + (props.exp - prev) * math.clamp(dt * 12, 0, 1)
			end)
		end)
		return function()
			conn:Disconnect()
		end
	end, { props.exp, props.requiredExp } :: { any })

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0.015, 0.985),
		Size = if isMobile then THEME.Container.MobileSize else THEME.Container.DesktopSize,
		BackgroundTransparency = 1,
		ZIndex = 10,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = if isMobile then THEME.Container.MobileMinSize else THEME.Container.MinSize,
			MaxSize = if isMobile then THEME.Container.MobileMaxSize else THEME.Container.MaxSize,
		}),
		ListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		TopRow = React.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0.44, 0),
			BackgroundTransparency = 1,
		}, {
			HLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
			}),
			Coin = React.createElement(StatCard, {
				icon = THEME.Icons.Coin,
				text = FormatNumber(props.coins or 0),
				theme = THEME.Coin,
			}),
			Luck = React.createElement(StatCard, {
				icon = THEME.Icons.Luck,
				text = string.format("%d%%", math.floor((props.luckMultiplier or 1.0) * 100 + 0.5)),
				theme = THEME.Luck,
			}),
		}),
		BottomRow = React.createElement(ExpTubeBar, {
			level = props.level or 1,
			exp = displayExp,
			requiredExp = props.requiredExp or 100,
			ratio = displayRatio,
		}),
	})
end

return StatsHUD
