--!strict

local OverheadTagFactory = {}

export type OverheadTagHandle = {
	billboard: BillboardGui,
	updateLevel: (newLevel: number) -> (),
	updateName: (newName: string) -> (),
}

function OverheadTagFactory.CreateOverheadTag(
	targetHead: BasePart,
	initialName: string,
	initialLevel: number
): OverheadTagHandle
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "OverheadTag"
	billboard.Adornee = targetHead
	billboard.Size = UDim2.new(4.5, 0, 1.4, 0)
	billboard.StudsOffset = Vector3.new(0, 3.0, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 65
	billboard.LightInfluence = 0
	billboard.ResetOnSpawn = false

	-- Container Frame (Transparent, clean)
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = billboard

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Padding = UDim.new(0, 1)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = container

	-- 1. Top Line: Player Display Name (-20% size: 0.52 -> 0.41)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.LayoutOrder = 1
	nameLabel.Size = UDim2.new(1, 0, 0.41, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.Text = initialName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Parent = container

	local nameStroke = Instance.new("UIStroke")
	nameStroke.Color = Color3.fromRGB(0, 0, 0)
	nameStroke.Thickness = 1.3
	nameStroke.LineJoinMode = Enum.LineJoinMode.Round
	nameStroke.Parent = nameLabel

	-- 2. Bottom Line: Level (-40% size: 0.44 -> 0.26)
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.LayoutOrder = 2
	levelLabel.Size = UDim2.new(1, 0, 0.26, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Font = Enum.Font.FredokaOne
	levelLabel.Text = string.format("Lv. %d", initialLevel)
	levelLabel.TextColor3 = Color3.fromRGB(255, 217, 0) -- Pure Vibrant Yellow
	levelLabel.TextScaled = true
	levelLabel.Parent = container

	billboard.Parent = targetHead

	return {
		billboard = billboard,
		updateLevel = function(newLevel: number)
			levelLabel.Text = string.format("Lv. %d", newLevel)
		end,
		updateName = function(newName: string)
			nameLabel.Text = newName
		end,
	}
end

return OverheadTagFactory
