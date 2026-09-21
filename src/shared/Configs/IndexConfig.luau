--!strict

local DropConfig = require(script.Parent.DropConfig)
local DropTypes = require(script.Parent.Parent.Types.DropTypes)
local IndexTypes = require(script.Parent.Parent.Types.IndexTypes)

type DropItem = DropTypes.DropItem
type IndexCatalogItem = IndexTypes.IndexCatalogItem

local DEFAULT_ICON = "rbxassetid://135832742918451"

local function InferCategory(id: string, tier: string): string
	if tier == "Secret" or string.find(id, "Core") then
		return "Secrets"
	elseif string.find(id, "Pot") or string.find(id, "Bottle") or string.find(id, "Arm") then
		return "Relics"
	else
		return "Fossils"
	end
end

local function BuildCatalog(): { IndexCatalogItem }
	local catalog: { IndexCatalogItem } = {}
	for _, dropList: { DropItem } in pairs(DropConfig) do
		for _, drop: DropItem in ipairs(dropList) do
			local cat = drop.category or InferCategory(drop.id, drop.tier)
			local item: IndexCatalogItem = {
				id = drop.id,
				displayName = drop.displayName,
				category = cat,
				tier = drop.tier,
				icon = drop.icon or DEFAULT_ICON,
				description = drop.description or string.format("Ancient %s discovered in %s excavations.", drop.displayName, drop.islandId),
				islandId = drop.islandId,
			}
			table.insert(catalog, item)
		end
	end
	return catalog
end

return table.freeze(BuildCatalog())
