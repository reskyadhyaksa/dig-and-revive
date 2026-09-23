--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RevivalConfig = require(Shared:WaitForChild("Configs"):WaitForChild("RevivalConfig"))
local RevivalTypes = require(Shared:WaitForChild("Types"):WaitForChild("RevivalTypes"))
local RevivalUtils = require(Shared:WaitForChild("Utils"):WaitForChild("RevivalUtils"))
local DropUtils = require(Shared:WaitForChild("Utils"):WaitForChild("DropUtils"))
local InventoryRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("InventoryRepository"))
local PlayerService = require(script.Parent:WaitForChild("PlayerService"))
local IndexService = require(script.Parent:WaitForChild("IndexService"))

type RevivalRecipe = RevivalTypes.RevivalRecipe
type AltarState = RevivalTypes.AltarState

local RevivalService = {}
local _trove = Trove.new()
local _altars: { [BasePart]: AltarState } = {}

local function RemovePlayerTool(player: Player, uniqueId: string)
	local char = player.Character
	local bp = player:FindFirstChildOfClass("Backpack")
	local function check(parent: Instance?)
		if not parent then return end
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("UniqueId") == uniqueId then
				child:Destroy()
			end
		end
	end
	check(char)
	check(bp)
end

local function FindRevivableFossil(player: Player): (string?, string?)
	local char = player.Character
	if char then
		local heldTool = char:FindFirstChildOfClass("Tool")
		if heldTool then
			local template = (heldTool:GetAttribute("ItemId") or heldTool.Name) :: string
			if RevivalUtils.GetRecipe(template) then return template, heldTool:GetAttribute("UniqueId") :: string? end
		end
	end

	for _, item in ipairs(InventoryRepository.GetInventory(player)) do
		local tId = item.templateId or item.id
		if RevivalUtils.GetRecipe(tId) then return tId, item.id end
	end
	return nil, nil
end

local function HandleRevival(player: Player, state: AltarState)
	if state.busy then return end
	local fossilId, uniqueId = FindRevivableFossil(player)
	if not fossilId then return end

	local recipe = RevivalUtils.GetRecipe(fossilId)
	if not recipe then return end

	local fossilItem = if uniqueId then InventoryRepository.FindItem(player, uniqueId) else nil
	local fossilWeight = if fossilItem then fossilItem.weight else 1.0
	local mult = DropUtils.CalculateScaleMultiplier(fossilId, fossilWeight)

	state.busy = true
	state.prompt.Enabled = false

	if uniqueId then
		RemovePlayerTool(player, uniqueId)
		InventoryRepository.RemoveItem(player, uniqueId)
	end

	InventoryRepository.AddRevivalItem(player, recipe.primeLivingId, recipe.displayName, recipe.tier, fossilWeight, recipe.description)

	if recipe.expReward then PlayerService.AddExp(player, recipe.expReward) end
	if recipe.coinReward then PlayerService.AddCoins(player, recipe.coinReward) end
	IndexService.RecordDiscovery(player, recipe.primeLivingId)

	local assetTemplate = RevivalUtils.FindLivingAsset(state.islandId, recipe.modelAssetPath)
	if assetTemplate then
		local altarTrove = _trove:Extend()
		local baseScale = 1.0
		pcall(function() baseScale = (assetTemplate :: any):GetScale() or 1.0 end)
		local finalScale = baseScale * mult

		local livingModel = assetTemplate:Clone()
		pcall(function() livingModel:ScaleTo(finalScale) end)
		livingModel:SetAttribute("IsPrimeLiving", true)
		livingModel:SetAttribute("IslandId", state.islandId)
		livingModel:SetAttribute("Scale", finalScale)
		livingModel:SetAttribute("Weight", fossilWeight)
		livingModel:PivotTo(RevivalUtils.GetAltarDisplayCFrame(state.altarPart, 2.5 * finalScale))
		livingModel.Parent = Workspace
		state.currentLivingModel = livingModel

		state.altarPart:SetAttribute("RevivingLivingName", recipe.primeLivingId)
		state.altarPart:SetAttribute("RevivalTriggered", os.clock())

		task.delay(recipe.displayDuration, function()
			altarTrove:Clean()
			state.currentLivingModel = nil
			state.altarPart:SetAttribute("RevivingLivingName", nil)
			state.busy = false
			state.prompt.Enabled = true
		end)
	else
		state.busy = false
		state.prompt.Enabled = true
	end
end

local function SetupAltar(islandId: string, altar: Instance)
	local part = (if altar:IsA("BasePart") then altar else altar:FindFirstChildWhichIsA("BasePart")) :: BasePart?
	if not part or _altars[part] then return end

	local prompt = part:FindFirstChildOfClass("ProximityPrompt") or Instance.new("ProximityPrompt")
	prompt.ActionText = RevivalConfig.DefaultPromptActionText
	prompt.ObjectText = RevivalConfig.DefaultPromptObjectText
	prompt.HoldDuration = RevivalConfig.DefaultAltarHoldDuration
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 12
	prompt.Parent = part

	local state: AltarState = { islandId = islandId, altarPart = part, prompt = prompt, currentLivingModel = nil, busy = false }
	_altars[part] = state
	_trove:Connect(prompt.Triggered, function(p) HandleRevival(p, state) end)
end

function RevivalService.Init()
	local function scan(zoneRoot: Instance)
		for _, island in zoneRoot:GetChildren() do
			local altar = island:FindFirstChild("Altar")
			if altar then SetupAltar(island.Name, altar) else
				_trove:Connect(island.ChildAdded, function(c) if c.Name == "Altar" then SetupAltar(island.Name, c) end end)
			end
		end
	end

	local zone = Workspace:FindFirstChild("Zone")
	if zone then scan(zone) else
		_trove:Connect(Workspace.ChildAdded, function(c) if c.Name == "Zone" then scan(c) end end)
	end
end

function RevivalService.Destroy()
	_trove:Clean()
	table.clear(_altars)
end

return RevivalService
