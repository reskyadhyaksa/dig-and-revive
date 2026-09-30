--!strict

local ShovelSkinTypes = require(script.Parent.Parent.Types.ShovelSkinTypes)

type ShovelSkinConfig = ShovelSkinTypes.ShovelSkinConfig

local Skins: { [string]: ShovelSkinConfig } = {
	["KatanaSkin"] = {
		id = "KatanaSkin",
		displayName = "Katana",
		assetName = "KatanaSkin",
		compatibleShovels = { "IronShovel" },
		price = 1000,
		requiredLevel = 1,
		gripOffset = CFrame.new(0, 0, 0),
	},
}

local ShovelSkinConfig = {
	Skins = table.freeze(Skins),

	AssetFolder = "ShovelSkins", -- ReplicatedStorage.Assets.ShovelSkins
	RenderTag = "ShovelSkinRender", -- Server tags tools/holsters, client renders them
	SkinIdAttribute = "SkinId",
	SkinJointName = "SkinJoint", -- Motor6D in Handle: Handle -> skin root part
	SkinGripAttachment = "SkinGrip", -- Optional Attachment on the skin root = SkinJoint.C1
	ArmJointName = "ToolGrip", -- Motor6D in Handle: RightHand -> Handle (replaces RightGrip)
	RequestCooldown = 0.3,
	ShopTag = "ShovelSkinShop", -- Tag a part + set its SkinId attribute to sell a skin
	MaxPurchaseDistance = 14,
	PromptKey = Enum.KeyCode.E,
	PromptHoldDuration = 0.3,
	CurrencyName = "Coins",

	Messages = {
		Purchased = "Unlocked %s skin!",
		Equipped = "Equipped %s skin.",
		Unequipped = "Default skin restored.",
		UnknownSkin = "This skin does not exist.",
		AlreadyOwned = "You already own this skin.",
		NotOwned = "You do not own this skin.",
		Incompatible = "This skin does not fit that shovel.",
		ShovelNotOwned = "You do not own that shovel.",
		LevelTooLow = "Requires level %d.",
		NotEnoughCoins = "Not enough coins.",
		TooFar = "Move closer to buy.",
		NoProfile = "Your data is still loading.",
	} :: { [string]: string },
}

return table.freeze(ShovelSkinConfig)
