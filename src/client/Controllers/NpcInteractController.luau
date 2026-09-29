--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local SellConfig = require(Shared:WaitForChild("Configs"):WaitForChild("SellConfig"))
local SignalTypes = require(Shared:WaitForChild("Types"):WaitForChild("SignalTypes"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))

type Signal<T...> = SignalTypes.Signal<T...>

local NpcInteractController = {}
local _trove = Trove.new()
local _npcTroves: { [Instance]: any } = {}
local _activePrompt: ProximityPrompt? = nil

NpcInteractController.DialogOpened = _trove:Construct(Signal) :: Signal<string, Instance>
NpcInteractController.DialogClosed = _trove:Construct(Signal) :: Signal<>
NpcInteractController.SellResultReceived = _trove:Construct(Signal) :: Signal<boolean, number, number, string?>

function NpcInteractController.CloseDialog()
	if not _activePrompt then return end
	_activePrompt.Style = Enum.ProximityPromptStyle.Default
	_activePrompt = nil
	NpcInteractController.DialogClosed:Fire()
end

local function GetAnchor(npc: Instance): BasePart?
	local anchor = if npc:IsA("Model") then (npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")) else npc
	return if anchor and anchor:IsA("BasePart") then anchor else nil
end

local function TrySetupPrompt(npc: Instance)
	local watcher = _npcTroves[npc]
	if not watcher or watcher.promptTrove then return end
	local anchor = GetAnchor(npc)
	if not anchor then return end -- parts not streamed in yet; ChildAdded will retry

	local npcTrove = watcher.trove:Extend()
	watcher.promptTrove = npcTrove

	local prompt = npcTrove:Add(Instance.new("ProximityPrompt")) :: ProximityPrompt
	prompt.ActionText = "Talk"
	prompt.ObjectText = npc.Name
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = SellConfig.MaxInteractDistance - 2
	prompt.RequiresLineOfSight = false
	prompt.Parent = anchor

	npcTrove:Connect(prompt.Triggered, function()
		if _activePrompt then return end
		_activePrompt = prompt
		-- Custom style hides the default prompt UI while keeping PromptHidden alive for walk-away detection.
		prompt.Style = Enum.ProximityPromptStyle.Custom
		NpcInteractController.DialogOpened:Fire(SellConfig.NpcTag, npc)
	end)
	npcTrove:Connect(prompt.PromptHidden, function()
		if _activePrompt == prompt then NpcInteractController.CloseDialog() end
	end)
	npcTrove:Add(function()
		if _activePrompt == prompt then NpcInteractController.CloseDialog() end
		watcher.promptTrove = nil
	end)
	-- Anchor streamed out: drop the prompt so it can be rebuilt when the part streams back in.
	npcTrove:Connect(anchor.AncestryChanged, function(_, parent)
		if not parent or not anchor:IsDescendantOf(npc) then npcTrove:Clean() end
	end)
end

local function SetupNpc(npc: Instance)
	if _npcTroves[npc] then return end
	local watcher = { trove = _trove:Extend(), promptTrove = nil :: any }
	_npcTroves[npc] = watcher
	watcher.trove:Connect(npc.DescendantAdded, function(desc)
		if desc:IsA("BasePart") then TrySetupPrompt(npc) end
	end)
	TrySetupPrompt(npc)
end

local function CleanupNpc(npc: Instance)
	local watcher = _npcTroves[npc]
	if not watcher then return end
	_npcTroves[npc] = nil
	watcher.trove:Clean()
end

function NpcInteractController.Init()
	for _, npc in ipairs(CollectionService:GetTagged(SellConfig.NpcTag)) do SetupNpc(npc) end
	_trove:Connect(CollectionService:GetInstanceAddedSignal(SellConfig.NpcTag), SetupNpc)
	_trove:Connect(CollectionService:GetInstanceRemovedSignal(SellConfig.NpcTag), CleanupNpc)
	_trove:Add(DigNetwork.SellResult.on(function(ok, coins, count, reason)
		NpcInteractController.SellResultReceived:Fire(ok, coins, count, reason)
	end))
end

function NpcInteractController.Destroy()
	_trove:Clean()
end

return NpcInteractController
