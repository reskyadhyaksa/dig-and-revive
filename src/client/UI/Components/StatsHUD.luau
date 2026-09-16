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

	-- Balanced responsive container sizing
	local containerSize = if isMobile
		then UDim2.fromScale(0.32, 0.12)
		else UDim2.fromScale(0.21, 0.10)

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0.015, 0.985),
		Size = containerSize,
		BackgroundTransparency = 1,
		ZIndex = 10,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(190, 56),
			MaxSize = Vector2.new(280, 68),
		}),

		ListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		-- 1. TOP ROW (LayoutOrder 1): Balanced Coin & Luck Cards
		TopRow = React.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0.44, 0),
			BackgroundTransparency = 1,
		}, {
			HLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 6),
			}),

			-- 1A. 3D Glossy Coin Card (50% Width)
			CoinCard = React.createElement("Frame", {
				Size = UDim2.new(0.5, -3, 1, 0),
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

					-- Coin Icon
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

					-- Coin Value
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

			-- 1B. 3D Glossy Luck Card (50% Width)
			LuckCard = React.createElement("Frame", {
				Size = UDim2.new(0.5, -3, 1, 0),
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

					-- Luck Icon
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

		-- 2. BOTTOM ROW (LayoutOrder 2): Left Level Box (ZIndex 2) + Underlapping Right Track Tube (ZIndex 1 / -z1)
		BottomRow = React.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0.50, 0),
			BackgroundTransparency = 1,
		}, {
			-- 2A. Kontainer Bar Level di Kanan (Nyambung ke kontainer hijau di belakang / -z1)
			TrackContainer = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 44, 0.5, 0),
				Size = UDim2.new(1, -44, 0.76, 0),
				BackgroundColor3 = Color3.fromRGB(20, 26, 36),
				BorderSizePixel = 0,
				ZIndex = 1,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				Stroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(10, 14, 20),
					Thickness = 2.5,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				}),

				-- Top Rim Specular Lens Gleam
				TopFlare = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.38, 0),
					Size = UDim2.new(0.28, 0, 0, 3),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					ZIndex = 8,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),
					Gradient = React.createElement("UIGradient", {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0.5, 0.25),
							NumberSequenceKeypoint.new(1, 1),
						}),
					}),
				}),

				-- Hollow Dark Recessed Bed
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

					-- Cyan Glass Capsule Progress Fill
					ExpFill = React.createElement("Frame", {
						Size = UDim2.new(displayRatio, 0, 1, 0),
						BackgroundColor3 = Color3.fromRGB(0, 210, 255),
						BorderSizePixel = 0,
						ClipsDescendants = true,
						ZIndex = 2,
					}, {
						Corner = React.createElement("UICorner", {
							CornerRadius = UDim.new(1, 0),
						}),
						FillGradient = React.createElement("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromHex("45F6FF")),
								ColorSequenceKeypoint.new(0.35, Color3.fromHex("00D2FF")),
								ColorSequenceKeypoint.new(1, Color3.fromHex("0088DD")),
							}),
						}),

						-- Upper Glass Gloss Capsule Highlight
						GlassGloss = React.createElement("Frame", {
							Position = UDim2.fromScale(0, 0),
							Size = UDim2.new(1, 0, 0.50, 0),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							ZIndex = 3,
						}, {
							Corner = React.createElement("UICorner", {
								CornerRadius = UDim.new(1, 0),
							}),
							Gradient = React.createElement("UIGradient", {
								Rotation = 90,
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.12),
									NumberSequenceKeypoint.new(1, 0.82),
								}),
							}),
						}),
					}),

					-- EXP Label Text ("262 / 579")
					ExpLabel = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.56, 0.5),
						Size = UDim2.fromScale(0.78, 0.75),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						Text = string.format("%d / %d", math.floor(displayExp), math.max(1, props.requiredExp or 100)),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						ZIndex = 4,
					}, {
						Stroke = React.createElement("UIStroke", {
							Color = Color3.fromRGB(0, 0, 0),
							Thickness = 1.4,
							LineJoinMode = Enum.LineJoinMode.Round,
						}),
					}),
				}),
			}),

			-- 2B. Kotak Hijau di Kiri yang Dibalut ke Dalam Kontainer (ZIndex 2 / di atas track tube)
			LevelBoxContainer = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0, 58, 1, 0),
				BackgroundColor3 = Color3.fromRGB(22, 28, 38),
				BorderSizePixel = 0,
				ZIndex = 2,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				Stroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(10, 14, 20),
					Thickness = 2.5,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				}),

				-- 3D Green Bottom Shadow Layer (Di dalam kontainer hitam)
				BadgeShadow = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.58),
					Size = UDim2.new(1, -6, 1, -6),
					BackgroundColor3 = Color3.fromRGB(42, 92, 10),
					BorderSizePixel = 0,
					ZIndex = 1,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
				}),

				-- 3D Green Elevated Face (Di dalam kontainer hitam)
				BadgeFace = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.44),
					Size = UDim2.new(1, -6, 1, -6),
					BackgroundColor3 = Color3.fromRGB(148, 235, 25),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					ZIndex = 2,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
					Stroke = React.createElement("UIStroke", {
						Color = Color3.fromRGB(35, 75, 8),
						Thickness = 1.2,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					}),
					Gradient = React.createElement("UIGradient", {
						Rotation = 90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHex("B8FA24")),
							ColorSequenceKeypoint.new(0.35, Color3.fromHex("9CE81C")),
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
								NumberSequenceKeypoint.new(0, 0.18),
								NumberSequenceKeypoint.new(1, 0.85),
							}),
						}),
					}),

					-- Level Text ("LV. 3")
					LevelText = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.92, 0.82),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						Text = string.format("LV. %d", props.level or 1),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						ZIndex = 4,
					}, {
						TextStroke = React.createElement("UIStroke", {
							Color = Color3.fromRGB(12, 18, 8),
							Thickness = 2.0,
							LineJoinMode = Enum.LineJoinMode.Round,
						}),
					}),
				}),
			}),
		}),
	})
end


return StatsHUD
