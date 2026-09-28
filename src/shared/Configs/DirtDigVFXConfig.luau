--!strict

local DirtDigVFXTypes = require(script.Parent.Parent.Types.DirtDigVFXTypes)

local DirtDigVFXConfig: DirtDigVFXTypes.DirtDigVFXConfig = {
	defaultEmit = 1,
	emitAttribute = "Emit", -- on the dig Part: bursts per trigger
	burstAttribute = "BurstCount", -- on each ParticleEmitter: particles per burst

	-- Physical low-poly soil chunks thrown around the dig spot (client-only)
	debris = {
		countMin = 5,
		countMax = 8,
		sizeMin = 0.18,
		sizeMax = 0.42,
		upSpeedMin = 14,
		upSpeedMax = 22,
		outSpeedMin = 4,
		outSpeedMax = 9,
		spinMax = 18,
		lifetime = 1.1,
		fadeTime = 0.35,
		colors = {
			Color3.fromRGB(120, 80, 48),
			Color3.fromRGB(98, 64, 38),
			Color3.fromRGB(80, 52, 30),
			Color3.fromRGB(138, 96, 60),
		},
		material = Enum.Material.SmoothPlastic,
	},
}

return table.freeze(DirtDigVFXConfig)
