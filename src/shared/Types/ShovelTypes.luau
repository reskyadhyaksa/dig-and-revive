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
	price: number,
	requiredLevel: number,
	assetName: string,
	holsterOffset: CFrame,
}

export type PurchaseFailReason = "NoProfile" | "UnknownShovel" | "AlreadyOwned" | "LevelTooLow" | "NotEnoughCoins" | "TooFar"

export type PurchaseResult = {
	ok: boolean,
	shovelId: string,
	reason: PurchaseFailReason?,
}

return nil
