--!strict

export type HolsterOffset = {
	cframe: CFrame,
	attachmentName: string?,
}

export type ShovelConfig = {
	id: string,
	displayName: string,
	tier: number,
	digPower: number,
	cooldown: number,
	isStarter: boolean,
	assetName: string,
	holsterOffset: CFrame,
}

return nil
