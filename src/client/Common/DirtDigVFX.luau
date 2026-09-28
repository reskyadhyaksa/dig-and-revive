--!strict

-- Reusable dirt dig VFX. Client-only (Server is Blind).
-- Part attribute "Emit" = bursts per trigger (default 1).
-- Each ParticleEmitter child's "BurstCount" attribute = particles per burst (default 1).
-- Also throws small physical soil chunks (DirtDebrisUtils) that fade and get destroyed.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local Config = require(Shared:WaitForChild("Configs"):WaitForChild("DirtDigVFXConfig"))
local DirtDebrisUtils = require(Shared:WaitForChild("Utils"):WaitForChild("DirtDebrisUtils"))

local DirtDigVFX = {}
local _rng = Random.new()

local function ReadPositiveInt(inst: Instance, name: string, default: number): number
	local value = inst:GetAttribute(name)
	if typeof(value) == "number" and value > 0 then
		return math.floor(value)
	end
	return default
end

local function SpawnChunk(origin: CFrame, launch: DirtDebrisUtils.DebrisLaunch, trove: any)
	local chunk = trove:Add(Instance.new("Part"))
	chunk.Name = "DirtChunk"
	chunk.Size = launch.size
	chunk.Color = launch.color
	chunk.Material = Config.debris.material
	chunk.CastShadow = false
	chunk.CanQuery = false
	chunk.CanTouch = false
	chunk.Massless = true
	chunk.CFrame = CFrame.new(origin.Position + launch.offset) * CFrame.Angles(
		_rng:NextNumber() * 6.28, _rng:NextNumber() * 6.28, _rng:NextNumber() * 6.28)
	chunk.AssemblyLinearVelocity = launch.velocity
	chunk.AssemblyAngularVelocity = launch.angularVelocity
	chunk.Parent = Workspace
	return chunk
end

local function ThrowDebris(target: BasePart, emitAmount: number)
	local cfg = Config.debris
	local trove = Trove.new()
	local origin = target.CFrame * CFrame.new(0, target.Size.Y * 0.5, 0)
	local up = target.CFrame.UpVector
	local radius = math.min(target.Size.X, target.Size.Z) * 0.25

	local chunks = {}
	for _ = 1, DirtDebrisUtils.RollCount(cfg, emitAmount, _rng) do
		table.insert(chunks, SpawnChunk(origin, DirtDebrisUtils.RollLaunch(cfg, up, radius, _rng), trove))
	end

	local fadeInfo = TweenInfo.new(cfg.fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	-- The timer thread owns the trove (not added to it) so cleanup never cancels itself.
	task.delay(cfg.lifetime, function()
		for _, chunk in chunks do
			trove:Add(TweenService:Create(chunk, fadeInfo, { Transparency = 1, Size = chunk.Size * 0.3 })):Play()
		end
		task.wait(cfg.fadeTime)
		trove:Destroy()
	end)
end

function DirtDigVFX.GetEmitAmount(part: BasePart): number
	return ReadPositiveInt(part, Config.emitAttribute, Config.defaultEmit)
end

-- Triggers the dirt dig VFX on `part` (defaults to Workspace.Part).
function DirtDigVFX.Play(part: BasePart?)
	local target = part or Workspace:FindFirstChild("Part")
	if not target or not target:IsA("BasePart") then return end

	local emitAmount = DirtDigVFX.GetEmitAmount(target)
	for _, child in target:GetChildren() do
		if child:IsA("ParticleEmitter") then
			child:Emit(emitAmount * ReadPositiveInt(child, Config.burstAttribute, 1))
		end
	end
	ThrowDebris(target, emitAmount)
end

return DirtDigVFX
