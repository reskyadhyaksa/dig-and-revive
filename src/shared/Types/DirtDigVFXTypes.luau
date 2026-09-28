--!strict

export type DebrisConfig = {
	countMin: number,
	countMax: number,
	sizeMin: number,
	sizeMax: number,
	upSpeedMin: number,
	upSpeedMax: number,
	outSpeedMin: number,
	outSpeedMax: number,
	spinMax: number,
	lifetime: number,
	fadeTime: number,
	colors: { Color3 },
	material: Enum.Material,
}

export type DirtDigVFXConfig = {
	defaultEmit: number,
	emitAttribute: string,
	burstAttribute: string,
	debris: DebrisConfig,
}

return nil
