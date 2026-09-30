--!strict

export type ShovelSkinConfig = {
	id: string,
	displayName: string,
	assetName: string, -- Model name inside ReplicatedStorage.Assets.ShovelSkins
	compatibleShovels: { string }, -- ShovelIds that may wear this skin (stats never change)
	price: number, -- 0 = free, owned by everyone
	requiredLevel: number,
	gripOffset: CFrame, -- SkinJoint.C0 (Handle space)
}

export type SkinFailReason =
	"NoProfile"
	| "UnknownSkin"
	| "AlreadyOwned"
	| "NotOwned"
	| "Incompatible"
	| "ShovelNotOwned"
	| "LevelTooLow"
	| "NotEnoughCoins"
	| "TooFar"

export type SkinResult = {
	ok: boolean,
	skinId: string,
	reason: SkinFailReason?,
}

return nil
