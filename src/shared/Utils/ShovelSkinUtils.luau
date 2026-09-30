--!strict

local ShovelSkinConfig = require(script.Parent.Parent:WaitForChild("Configs"):WaitForChild("ShovelSkinConfig"))
local ShovelSkinTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("ShovelSkinTypes"))

type SkinConfig = ShovelSkinTypes.ShovelSkinConfig
type SkinFailReason = ShovelSkinTypes.SkinFailReason

-- Pure skin rules; callers pass plain data so nothing here touches Instances.
local ShovelSkinUtils = {}

function ShovelSkinUtils.GetSkin(skinId: string?): SkinConfig?
	return if skinId then ShovelSkinConfig.Skins[skinId] else nil
end

function ShovelSkinUtils.IsCompatible(skin: SkinConfig, shovelId: string): boolean
	return table.find(skin.compatibleShovels, shovelId) ~= nil
end

function ShovelSkinUtils.IsOwned(skin: SkinConfig, owned: { [string]: boolean }): boolean
	return skin.price <= 0 or owned[skin.id] == true
end

function ShovelSkinUtils.CheckPurchase(skin: SkinConfig?, owned: { [string]: boolean }, level: number, coins: number): SkinFailReason?
	if not skin then return "UnknownSkin" end
	if ShovelSkinUtils.IsOwned(skin, owned) then return "AlreadyOwned" end
	if level < skin.requiredLevel then return "LevelTooLow" end
	if coins < skin.price then return "NotEnoughCoins" end
	return nil
end

-- skin = nil means "back to the default model" and is always allowed for an owned shovel.
function ShovelSkinUtils.CheckEquip(skin: SkinConfig?, shovelId: string, owned: { [string]: boolean }, ownsShovel: boolean): SkinFailReason?
	if not ownsShovel then return "ShovelNotOwned" end
	if not skin then return nil end
	if not ShovelSkinUtils.IsCompatible(skin, shovelId) then return "Incompatible" end
	if not ShovelSkinUtils.IsOwned(skin, owned) then return "NotOwned" end
	return nil
end

-- Returns the skin a shovel should wear, dropping stale or invalid entries.
function ShovelSkinUtils.ResolveEquipped(shovelId: string, equipped: { [string]: string }, owned: { [string]: boolean }): string?
	local skin = ShovelSkinUtils.GetSkin(equipped[shovelId])
	if skin and ShovelSkinUtils.IsCompatible(skin, shovelId) and ShovelSkinUtils.IsOwned(skin, owned) then return skin.id end
	return nil
end

return table.freeze(ShovelSkinUtils)
