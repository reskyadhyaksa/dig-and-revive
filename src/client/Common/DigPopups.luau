--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local PowerBarHelper = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Common"):WaitForChild("PowerBarHelper"))

local LocalPlayer = Players.LocalPlayer

local RARITY_COLORS: { [string]: Color3 } = {
	Common = Color3.fromRGB(200, 200, 200),
	Uncommon = Color3.fromRGB(46, 204, 113),
	Epic = Color3.fromRGB(155, 89, 182),
	Legendary = Color3.fromRGB(241, 196, 15),
	Mythic = Color3.fromRGB(231, 76, 60),
	Secret = Color3.fromRGB(0, 255, 230),
}

local DigPopups = {}

local function CreatePopupBillboard(head: BasePart, name: string, size: UDim2, offset: Vector3)
	local b = Instance.new("BillboardGui")
	b.Name = name
	b.Adornee = head
	b.Size = size
	b.StudsOffset = offset
	b.AlwaysOnTop = true
	b.LightInfluence = 0
	return b
end

function DigPopups.ShowLuckTier(progress: number)
	local char = LocalPlayer.Character
	local head = if char then (char:FindFirstChild("Head") or char.PrimaryPart) :: BasePart? else nil
	if not head then return end

	local text, color = PowerBarHelper.GetLuckTier(progress)
	local b = CreatePopupBillboard(head, "LuckTierPopup", UDim2.new(4.5, 0, 1.4, 0), Vector3.new(0, 3.5, 0))

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.3, 0.3)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.Font = Enum.Font.LuckiestGuy
	label.TextScaled = true
	label.Parent = b

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 3
	stroke.Parent = label
	b.Parent = char

	local t = Trove.new()
	t:Add(b)
	TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromScale(1, 1) }):Play()

	task.delay(0.55, function()
		TweenService:Create(b, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffset = Vector3.new(0, 5.2, 0) }):Play()
		TweenService:Create(label, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
		task.delay(0.7, function() t:Clean() end)
	end)
end

function DigPopups.ShowExclamation(rarity: string)
	local char = LocalPlayer.Character
	local head = if char then (char:FindFirstChild("Head") or char.PrimaryPart) :: BasePart? else nil
	if not head then return end

	local color = RARITY_COLORS[rarity] or Color3.fromRGB(255, 255, 255)
	local b = CreatePopupBillboard(head, "ExclamationIndicator", UDim2.new(2.5, 0, 2.5, 0), Vector3.new(0, 4.2, 0))

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.2, 0.2)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.Text = "!"
	label.TextColor3 = color
	label.Font = Enum.Font.LuckiestGuy
	label.TextScaled = true
	label.Parent = b

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 3
	stroke.Parent = label
	b.Parent = char

	local t = Trove.new()
	t:Add(b)
	TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromScale(1, 1) }):Play()

	task.delay(0.65, function()
		TweenService:Create(label, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
		task.delay(0.4, function() t:Clean() end)
	end)
end

return DigPopups
