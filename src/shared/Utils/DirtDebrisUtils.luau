--!strict

-- Pure math for dirt debris launches. No Instances involved.

local DirtDigVFXTypes = require(script.Parent.Parent.Types.DirtDigVFXTypes)

type DebrisConfig = DirtDigVFXTypes.DebrisConfig

export type DebrisLaunch = {
	offset: Vector3,
	size: Vector3,
	velocity: Vector3,
	angularVelocity: Vector3,
	color: Color3,
}

local DirtDebrisUtils = {}

local function Lerp(a: number, b: number, rng: Random): number
	return a + (b - a) * rng:NextNumber()
end

-- `up` is the world-space up vector of the dig surface; `spawnRadius` keeps chunks on the surface.
function DirtDebrisUtils.RollLaunch(cfg: DebrisConfig, up: Vector3, spawnRadius: number, rng: Random): DebrisLaunch
	local angle = rng:NextNumber() * math.pi * 2
	local flat = Vector3.new(math.cos(angle), 0, math.sin(angle))
	local out = (flat - up * flat:Dot(up)).Unit

	local base = Lerp(cfg.sizeMin, cfg.sizeMax, rng)
	local size = Vector3.new(base * Lerp(0.7, 1.3, rng), base * Lerp(0.6, 1.1, rng), base * Lerp(0.7, 1.3, rng))

	local spin = cfg.spinMax
	return {
		offset = out * (rng:NextNumber() * spawnRadius) + up * (size.Y * 0.5),
		size = size,
		velocity = up * Lerp(cfg.upSpeedMin, cfg.upSpeedMax, rng) + out * Lerp(cfg.outSpeedMin, cfg.outSpeedMax, rng),
		angularVelocity = Vector3.new(Lerp(-spin, spin, rng), Lerp(-spin, spin, rng), Lerp(-spin, spin, rng)),
		color = cfg.colors[rng:NextInteger(1, #cfg.colors)],
	}
end

function DirtDebrisUtils.RollCount(cfg: DebrisConfig, emitAmount: number, rng: Random): number
	return rng:NextInteger(cfg.countMin, cfg.countMax) * emitAmount
end

return DirtDebrisUtils
