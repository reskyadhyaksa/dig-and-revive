--!strict

local IndexTypes = require(script.Parent.Parent.Types.IndexTypes)
local IndexConfig = require(script.Parent.Parent.Configs.IndexConfig)

type PlayerIndexData = IndexTypes.PlayerIndexData
type IndexCatalogItem = IndexTypes.IndexCatalogItem
type IndexCategoryProgress = IndexTypes.IndexCategoryProgress

local IndexUtils = {}

function IndexUtils.GetCatalog(): { IndexCatalogItem }
	return IndexConfig
end

function IndexUtils.GetCatalogItem(itemId: string): IndexCatalogItem?
	for _, item in IndexConfig do
		if item.id == itemId then
			return item
		end
	end
	return nil
end

function IndexUtils.IsDiscovered(indexData: PlayerIndexData?, itemId: string): boolean
	if not indexData then return false end
	local record = indexData[itemId]
	return record ~= nil and record.timesFound > 0
end

function IndexUtils.GetTimesFound(indexData: PlayerIndexData?, itemId: string): number
	if not indexData then return 0 end
	local record = indexData[itemId]
	return if record then record.timesFound else 0
end

function IndexUtils.CalculateProgress(
	catalog: { IndexCatalogItem },
	indexData: PlayerIndexData?,
	categoryFilter: string?
): IndexCategoryProgress
	local total = 0
	local discovered = 0

	for _, item in catalog do
		if categoryFilter == nil or categoryFilter == "All" or item.category == categoryFilter or item.islandId == categoryFilter then
			total += 1
			if IndexUtils.IsDiscovered(indexData, item.id) then
				discovered += 1
			end
		end
	end

	local pct = if total > 0 then math.floor((discovered / total) * 100) else 0
	return {
		total = total,
		discovered = discovered,
		percentage = pct,
	}
end

return IndexUtils
