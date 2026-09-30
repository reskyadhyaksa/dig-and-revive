--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelSkinConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelSkinConfig"))
local ShovelSkinUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelSkinUtils"))
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local InventoryTypes = require(Shared:WaitForChild("Types"):WaitForChild("InventoryTypes"))
local SkinAttributeReader = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("SkinAttributeReader"))

type InventoryItem = InventoryTypes.InventoryItem

-- One inventory entry per (owned skin x owned compatible shovel), shown in the Shovel tab.
local SkinInventoryHelper = {}

function SkinInventoryHelper.GetSkinItems(ownedShovelIds: { string }): { InventoryItem }
	local owned = SkinAttributeReader.GetOwned()
	local equipped = SkinAttributeReader.GetEquipped()
	local items: { InventoryItem } = {}

	for skinId, skin in ShovelSkinConfig.Skins do
		if not ShovelSkinUtils.IsOwned(skin, owned) then continue end
		for _, shovelId in ownedShovelIds do
			local shovel = ShovelUtils.GetShovelConfig(shovelId)
			if not shovel or not ShovelSkinUtils.IsCompatible(skin, shovelId) then continue end
			table.insert(items, {
				id = string.format("Skin_%s_%s", skinId, shovelId),
				templateId = skinId,
				skinTargetShovel = shovelId,
				displayName = string.format("%s (%s)", skin.displayName, shovel.displayName),
				category = "Shovel",
				tier = "Epic",
				amount = 1,
				icon = "rbxassetid://100488739842115",
				description = string.format("Cosmetic skin for %s. Stats stay the same.", shovel.displayName),
				isEquipped = equipped[shovelId] == skinId,
				isFavorite = false,
				stats = { { name = "Type", value = "Skin" } },
			})
		end
	end
	return items
end

return SkinInventoryHelper
