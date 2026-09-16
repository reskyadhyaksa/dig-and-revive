--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITypes = require(Shared:WaitForChild("Types"):WaitForChild("UITypes"))
local useDeviceType = require(script.Parent.Parent:WaitForChild("Hooks"):WaitForChild("useDeviceType"))

export type Props = UITypes.StatsHUDProps

local function FormatNumber(num: number): string
	local n = math.floor(num or 0)
	if n >= 1000000 then
		return string.format("%.1fM", n / 1000000)
	elseif n >= 1000 then
		return string.format("%.1fK", n / 1000)
	end
	return tostring(n)
end

local function StatsHUD(props: Props): any
	local deviceInfo = useDeviceType()
	local isMobile = deviceInfo.isMobile

	-- Smooth EXP bar interpolation
	local displayExp, setDisplayExp = React.useState(props.exp or 0)
	local targetRatio = if props.requiredExp > 0 then math.clamp(props.exp / props.requiredExp, 0, 1) else 0
	local displayRatio, setDisplayRatio = React.useState(targetRatio)

	React.useEffect(function()
		local conn: RBXScriptConnection? = nil
		conn = RunService.RenderStepped:Connect(function(dt: number)
			setDisplayRatio(function(prev)
				local diff = targetRatio - prev
				if math.abs(diff) < 0.005 then
					return targetRatio
				end
				return prev + diff * math.clamp(dt * 12, 0, 1)
			end)

			setDisplayExp(function(prev)
				local diff = props.exp - prev
				if math.abs(diff) < 0.5 then
					return props.exp
				end
				return prev + diff * math.clamp(dt * 12, 0, 1)
			end)
		end)

		return function()
			if conn then
				conn:Disconnect()
			end
		end
	end, { props.exp, props.requiredExp } :: { any })

	local totalLuckDisplay = math.floor(props.luckMultiplier * 100 + 0.5)

	-- Generous, responsive container sizing
	local containerSize = if isMobile
		then UDim2.fromScale(0.32, 0.13)
		else UDim2.fromScale(0.22, 0.11)

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0.015, 0.985),
		Size = containerSize,
		BackgroundTransparency = 1,
		ZIndex = 10,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(175, 54),
			MaxSize = Vector2.new(280, 72),
		}),

		ListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 8), -- Clear gap preventing row overlap
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		-- 1. TOP ROW (LayoutOrder 1): Coin & Luck Cards
		TopRow = React.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0.40, 0),
			BackgroundTransparency = 1,
		}, {
			HLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 6),
			}),

			-- 1A. 3D Glossy Coin Card
			CoinCard = React.createElement("Frame", {
				Size = UDim2.new(0.52, 0, 1, 0),
				BackgroundTransparency = 1,
			}, {
				-- Shadow Layer (Bottom)
				Shadow = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.58),
					Size = UDim2.fromScale(1, 0.90),
					BackgroundColor3 = Color3.fromRGB(18, 14, 6),
					BorderSizePixel = 0,
					ZIndex = 1,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
				}),

				-- Top Face Surface Layer
				Face = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.44),
					Size = UDim2.fromScale(1, 0.90),
					BackgroundColor3 = Color3.fromRGB(38, 28, 12),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					ZIndex = 2,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
					Stroke = React.createElement("UIStroke", {
						Color = Color3.fromRGB(241, 196, 15),
						Thickness = 1.2,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					}),

					-- Glossy Shine Overlay
					Shine = React.createElement("Frame", {
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.new(1, 0, 0.45, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						ZIndex = 3,
					}, {
						Corner = React.createElement("UICorner", {
							CornerRadius = UDim.new(0, 6),
						}),
						Gradient = React.createElement("UIGradient", {
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.25),
								NumberSequenceKeypoint.new(1, 0.90),
							}),
						}),
					}),

					-- Coin Icon (Emoji in separate container for perfect font scaling)
					CoinIcon = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0.06, 0.5),
						Size = UDim2.fromScale(0.24, 0.85),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						Text = "🪙",
						TextScaled = true,
						ZIndex = 4,
					}),

					-- Coin Value (Pure Scalable Text)
					CoinValue = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0.32, 0.5),
						Size = UDim2.fromScale(0.62, 0.85),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						Text = FormatNumber(props.coins or 0),
						TextColor3 = Color3.fromRGB(255, 220, 50),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						ZIndex = 4,
					}, {
						Stroke = React.createElement("UIStroke", {
							Color = Color3.fromRGB(0, 0, 0),
							Thickness = 1.2,
							LineJoinMode = Enum.LineJoinMode.Round,
						}),
					}),
				}),
			}),

			-- 1B. 3D Glossy Luck Card
			LuckCard = React.createElement("Frame", {
				Size = UDim2.new(0.44, 0, 1, 0),
				BackgroundTransparency = 1,
			}, {
				-- Shadow Layer (Bottom)
				Shadow = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.58),
					Size = UDim2.fromScale(1, 0.90),
					BackgroundColor3 = Color3.fromRGB(8, 20, 12),
					BorderSizePixel = 0,
					ZIndex = 1,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
				}),

				-- Top Face Surface Layer
				Face = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.44),
					Size = UDim2.fromScale(1, 0.90),
					BackgroundColor3 = Color3.fromRGB(16, 40, 24),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					ZIndex = 2,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
					Stroke = React.createElement("UIStroke", {
						Color = Color3.fromRGB(46, 204, 113),
						Thickness = 1.2,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					}),

					-- Glossy Shine Overlay
					Shine = React.createElement("Frame", {
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.new(1, 0, 0.45, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						ZIndex = 3,
					}, {
						Corner = React.createElement("UICorner", {
							CornerRadius = UDim.new(0, 6),
						}),
						Gradient = React.createElement("UIGradient", {
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.25),
								NumberSequenceKeypoint.new(1, 0.90),
							}),
						}),
					}),

					-- Luck Icon (Emoji in separate container)
					LuckIcon = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0.06, 0.5),
						Size = UDim2.fromScale(0.24, 0.85),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						Text = "🍀",
						TextScaled = true,
						ZIndex = 4,
					}),

					-- Luck Value
					LuckValue = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0.32, 0.5),
						Size = UDim2.fromScale(0.62, 0.85),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						Text = string.format("%d%%", totalLuckDisplay),
						TextColor3 = Color3.fromRGB(80, 240, 140),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						ZIndex = 4,
					}, {
						Stroke = React.createElement("UIStroke", {
							Color = Color3.fromRGB(0, 0, 0),
							Thickness = 1.2,
							LineJoinMode = Enum.LineJoinMode.Round,
						}),
					}),
				}),
			}),
		}),

		-- 2. BOTTOM ROW (LayoutOrder 2): Stylized 3D Capsule Tube EXP Bar & Protruding Level Badge
		BottomRow = React.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0.48, 0),
			BackgroundTransparency = 1,
		}, {
			-- 2A. Main Capsule Tube Track (Hollow Dark Bezel)
			TrackContainer = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.new(1, -12, 0.76, 0),
				BackgroundColor3 = Color3.fromRGB(24, 30, 40),
				BorderSizePixel = 0,
				ZIndex = 1,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				Stroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(14, 18, 25),
					Thickness = 2.0,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				}),

				-- Hollow Dark Inset Bed
				TrackBed = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, -6, 1, -6),
					BackgroundColor3 = Color3.fromRGB(12, 16, 22),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					ZIndex = 2,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),

					-- Progress Fill (Cyan Glass Capsule)
					ExpFill = React.createElement("Frame", {
						Size = UDim2.new(displayRatio, 0, 1, 0),
						BackgroundColor3 = Color3.fromRGB(0, 205, 250),
						BorderSizePixel = 0,
						ClipsDescendants = true,
						ZIndex = 1,
					}, {
						Corner = React.createElement("UICorner", {
							CornerRadius = UDim.new(1, 0),
						}),
						FillGradient = React.createElement("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromHex("3DF6FF")),
								ColorSequenceKeypoint.new(0.4, Color3.fromHex("00D0FF")),
								ColorSequenceKeypoint.new(1, Color3.fromHex("0088DD")),
							}),
						}),

						-- Upper Specular Glass Gloss Highlight
						GlassGloss = React.createElement("Frame", {
							Position = UDim2.fromScale(0, 0),
							Size = UDim2.new(1, 0, 0.50, 0),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							ZIndex = 2,
						}, {
							Corner = React.createElement("UICorner", {
								CornerRadius = UDim.new(1, 0),
							}),
							Gradient = React.createElement("UIGradient", {
								Rotation = 90,
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.15),
									NumberSequenceKeypoint.new(1, 0.85),
								}),
							}),
						}),
					}),

					-- EXP Label Text (Scalable centered fraction)
					ExpLabel = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.56, 0.5),
						Size = UDim2.fromScale(0.78, 0.78),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						Text = string.format("%d / %d", math.floor(displayExp), math.max(1, props.requiredExp or 100)),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						ZIndex = 4,
					}, {
						Stroke = React.createElement("UIStroke", {
							Color = Color3.fromRGB(0, 0, 0),
							Thickness = 1.2,
							LineJoinMode = Enum.LineJoinMode.Round,
						}),
					}),
				}),
			}),

			-- 2B. Protruding Left 3D Lime Green Level Badge
			LevelBadge = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0.30, 0, 1.10, 0),
				BackgroundColor3 = Color3.fromRGB(18, 24, 32),
				BorderSizePixel = 0,
				ZIndex = 10,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				Stroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(12, 16, 22),
					Thickness = 2.0,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				}),

				-- 3D Bottom Shadow Layer
				BadgeShadow = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.56),
					Size = UDim2.new(1, -3, 1, -3),
					BackgroundColor3 = Color3.fromRGB(45, 100, 12),
					BorderSizePixel = 0,
					ZIndex = 1,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),

				-- 3D Top Elevated Lime Face
				BadgeFace = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.44),
					Size = UDim2.new(1, -3, 1, -3),
					BackgroundColor3 = Color3.fromRGB(138, 224, 24),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					ZIndex = 2,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
					Gradient = React.createElement("UIGradient", {
						Rotation = 90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHex("B5FA22")),
							ColorSequenceKeypoint.new(0.4, Color3.fromHex("98E81A")),
							ColorSequenceKeypoint.new(1, Color3.fromHex("68C810")),
						}),
					}),

					-- Specular Top Shine
					BadgeShine = React.createElement("Frame", {
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.new(1, 0, 0.45, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						ZIndex = 3,
					}, {
						Corner = React.createElement("UICorner", {
							CornerRadius = UDim.new(0, 5),
						}),
						Gradient = React.createElement("UIGradient", {
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.20),
								NumberSequenceKeypoint.new(1, 0.90),
							}),
						}),
					}),

					-- Level Text ("LV. 3")
					LevelText = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.92, 0.80),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						Text = string.format("LV. %d", props.level or 1),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						ZIndex = 4,
					}, {
						TextStroke = React.createElement("UIStroke", {
							Color = Color3.fromRGB(15, 22, 10),
							Thickness = 1.8,
							LineJoinMode = Enum.LineJoinMode.Round,
						}),
					}),
				}),
			}),
		}),
	})
end

return StatsHUD
