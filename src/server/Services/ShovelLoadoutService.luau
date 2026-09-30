--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local ShovelTypes = require(Shared:WaitForChild("Types"):WaitForChild("ShovelTypes"))
local ShovelHolsterHelper = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("ShovelHolsterHelper"))
local ShovelOwnershipRepository = require(script.Parent.Parent:WaitForChild("Repositories"):WaitForChild("ShovelOwnershipRepository"))
local ShovelSkinService = require(script.Parent:WaitForChild("ShovelSkinService"))

type ShovelConfigType = ShovelTypes.ShovelConfig

-- Guarantees a player carries exactly one shovel: the one they selected.
local ShovelLoadoutService = {}

local function IsShovelTool(inst: Instance): boolean
	return inst:IsA("Tool") and (inst:GetAttribute("ShovelId") ~= nil or ShovelUtils.GetShovelConfig(inst.Name) ~= nil)
end

-- Destroys every shovel in the container except one copy of keepName, which is returned.
local function Sweep(container: Instance?, keepName: string?): Tool?
	if not container then return nil end
	local kept: Tool? = nil
	for _, child in container:GetChildren() do
		if IsShovelTool(child) then
			if child.Name == keepName and not kept then kept = child :: Tool else child:Destroy() end
		end
	end
	return kept
end

local function CreateTool(config: ShovelConfigType, parent: Instance): Tool
	local tool = ShovelHolsterHelper.GetOrCreateShovelAsset(config)
	tool:SetAttribute("ShovelId", config.id)
	tool.Parent = parent
	return tool
end

-- Skin is visual only: the server stamps SkinId, each client renders it (see ShovelSkinRenderController).
local function StampSkin(tool: Tool?, skinId: string?)
	if not tool then return end
	ShovelHolsterHelper.MarkSkin(tool, skinId)
end

-- Removes non-selected shovels from character, backpack and StarterGear, then grants the selected one.
function ShovelLoadoutService.Apply(player: Player): Tool?
	local config = ShovelUtils.ResolveSelectedShovel(
		ShovelOwnershipRepository.GetSelected(player),
		ShovelOwnershipRepository.GetOwned(player)
	)
	if not config then return nil end
	player:SetAttribute("SelectedShovel", config.id)

	local backpack = player:FindFirstChildOfClass("Backpack")
	local held = Sweep(player.Character, config.assetName)
	local stored = Sweep(backpack, if held then nil else config.assetName)
	local tool = held or stored
	if not tool and backpack then tool = CreateTool(config, backpack) end

	local starterGear = player:FindFirstChild("StarterGear")
	local gearTool = if starterGear then Sweep(starterGear, config.assetName) or CreateTool(config, starterGear) else nil

	local skinId = ShovelSkinService.GetSkinFor(player, config.id)
	StampSkin(tool, skinId)
	StampSkin(gearTool, skinId)
	return tool
end

-- Switches the active shovel and puts it in the player's hand.
function ShovelLoadoutService.Select(player: Player, shovelId: string): boolean
	local config = ShovelUtils.GetShovelConfig(shovelId)
	if not config then return false end
	if not config.isStarter and not ShovelOwnershipRepository.Owns(player, shovelId) then return false end
	if not ShovelOwnershipRepository.SetSelected(player, shovelId) then return false end

	local tool = ShovelLoadoutService.Apply(player)
	local char = player.Character
	local hum = if char then char:FindFirstChildOfClass("Humanoid") else nil
	if tool and hum and hum.Health > 0 and tool.Parent ~= char then hum:EquipTool(tool) end
	return true
end

return ShovelLoadoutService
