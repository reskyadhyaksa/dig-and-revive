--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

export type Props = {
	title: string,
	subtitle: string?,
	visible: boolean,
	themeColor: Color3?,
}

local function ZoneNotificationBanner(props: Props): any
	local themeColor = props.themeColor or Color3.fromRGB(46, 204, 113) -- Default vibrant emerald green
	local shadowColor = themeColor:Lerp(Color3.fromRGB(0, 0, 0), 0.4)
	local strokeColor = themeColor:Lerp(Color3.fromRGB(0, 0, 0), 0.6)

	-- Spring-like smooth transition state
	local animProgress, setAnimProgress = React.useState(0)

	React.useEffect(function()
		local target = if props.visible then 1 else 0
		local isMounted = true
		local conn: RBXScriptConnection? = nil

		conn = RunService.RenderStepped:Connect(function(dt: number)
			setAnimProgress(function(prev)
				local diff = target - prev
				if math.abs(diff) < 0.01 then
					return target
				end
				return prev + diff * math.clamp(dt * 12, 0, 1)
			end)
		end)

		return function()
			isMounted = false
			if conn then
				conn:Disconnect()
			end
		end
	end, { props.visible } :: { any })

	if animProgress <= 0.01 and not props.visible then
		return nil
	end

	-- Y Position centered at 20% (0.2) of screen height with smooth slide down / scale pop
	local currentYScale = 0.15 + (0.05 * animProgress)
	local currentTransparency = 1 - animProgress

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, currentYScale),
		Size = UDim2.new(0.85, 0, 0.085, 0),
		BackgroundTransparency = 1,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(260, 52),
			MaxSize = Vector2.new(480, 80),
		}),

		AspectRatio = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 5.2,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
		}),

		-- 1. Base / Shadow Layer (3D Depth bottom)
		ShadowLayer = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.56),
			Size = UDim2.fromScale(1, 0.95),
			BackgroundColor3 = shadowColor,
			BackgroundTransparency = currentTransparency,
			BorderSizePixel = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
		}),

		-- 2. Top Face Surface Layer (Interactive / Elevated Main Face)
		FaceLayer = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.48),
			Size = UDim2.fromScale(1, 0.95),
			BackgroundColor3 = themeColor,
			BackgroundTransparency = currentTransparency,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),

			BorderStroke = React.createElement("UIStroke", {
				Color = strokeColor,
				Thickness = 2.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Transparency = currentTransparency,
			}),

			-- 3. Glossy / Shine Overlay (Absolute inside container)
			GlossyOverlay = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 2),
				Size = UDim2.new(1, -6, 0.42, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				ZIndex = 1,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 9),
				}),
				Gradient = React.createElement("UIGradient", {
					Rotation = 90,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.25),
						NumberSequenceKeypoint.new(1, 0.92),
					}),
				}),
			}),

			-- Text & Content Container (Isolated from Glossy Overlay)
			ContentContainer = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 2,
			}, {
				ContentList = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Padding = React.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
				}),

				SubTitleLabel = if props.subtitle then React.createElement("TextLabel", {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0.35, 0),
					BackgroundTransparency = 1,
					Text = string.upper(props.subtitle),
					TextColor3 = Color3.fromRGB(240, 255, 245),
					TextTransparency = currentTransparency,
					TextScaled = true,
					Font = Enum.Font.FredokaOne,
				}, {
					Stroke = React.createElement("UIStroke", {
						Color = strokeColor,
						Thickness = 1.5,
						Transparency = currentTransparency,
					}),
				}) else nil,

				TitleLabel = React.createElement("TextLabel", {
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, if props.subtitle then 0.55 else 0.85, 0),
					BackgroundTransparency = 1,
					Text = props.title,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextTransparency = currentTransparency,
					TextScaled = true,
					Font = Enum.Font.FredokaOne,
				}, {
					Stroke = React.createElement("UIStroke", {
						Color = strokeColor,
						Thickness = 2,
						Transparency = currentTransparency,
					}),
				}),
			}),
		}),
	})
end

return ZoneNotificationBanner
