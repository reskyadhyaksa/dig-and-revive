--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local ShovelSkinConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("ShovelSkinConfig"))
local ShovelSkinRenderer = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("ShovelSkinRenderer"))

-- Renders skins for every tagged shovel/holster (all players), reacting to SkinId changes.
local ShovelSkinRenderController = {}
local _trove = Trove.new()
local _targets: { [Instance]: any } = {}

local function Track(target: Instance)
	if _targets[target] then return end
	local targetTrove = _trove:Extend()
	_targets[target] = targetTrove
	local visualTrove = targetTrove:Extend()

	local function rebuild()
		visualTrove:Clean()
		local skinId = target:GetAttribute(ShovelSkinConfig.SkinIdAttribute)
		local handle = target:FindFirstChild("Handle")
		if typeof(skinId) ~= "string" or not handle or not handle:IsA("BasePart") then return end
		ShovelSkinRenderer.Render(target, handle, skinId, visualTrove)
	end

	targetTrove:Connect(target:GetAttributeChangedSignal(ShovelSkinConfig.SkinIdAttribute), rebuild)
	-- StreamingEnabled / holster build order: the Handle can arrive after the tag.
	targetTrove:Connect(target.ChildAdded, function(child) if child.Name == "Handle" then rebuild() end end)
	rebuild()
end

local function Untrack(target: Instance)
	local targetTrove = _targets[target]
	if not targetTrove then return end
	_targets[target] = nil
	_trove:Remove(targetTrove)
end

function ShovelSkinRenderController.Init()
	for _, target in CollectionService:GetTagged(ShovelSkinConfig.RenderTag) do Track(target) end
	_trove:Connect(CollectionService:GetInstanceAddedSignal(ShovelSkinConfig.RenderTag), Track)
	_trove:Connect(CollectionService:GetInstanceRemovedSignal(ShovelSkinConfig.RenderTag), Untrack)
end

function ShovelSkinRenderController.Destroy()
	_trove:Clean()
	table.clear(_targets)
end

return ShovelSkinRenderController
