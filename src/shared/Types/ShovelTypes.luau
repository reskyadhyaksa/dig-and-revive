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
	luckBonus: number, -- e.g. 0 for +0%, 15 for +15%, 50 for +50%
	cooldown: number,
	isStarter: boolean,
	assetName: string,
	holsterOffset: CFrame,
}

return nil
