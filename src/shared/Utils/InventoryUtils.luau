--!strict

local InventoryConfig = require(script.Parent.Parent:WaitForChild("Configs"):WaitForChild("InventoryConfig"))
local InventoryTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("InventoryTypes"))

type InventoryItem = InventoryTypes.InventoryItem
type ItemCategory = InventoryTypes.ItemCategory

type SortOption = InventoryTypes.SortOption

local InventoryUtils = {}

function InventoryUtils.CalculateMaxCapacity(playerLevel: number): number
	local lvl = math.max(1, math.floor(playerLevel or 1))
	local cap = 100

	if lvl < 100 then
		cap = 100 + math.floor((lvl - 1) / 10) * 25
	elseif lvl < 250 then
		cap = 325 + (1 + math.floor((lvl - 100) / 100)) * 50
	else
		cap = 425 + (1 + math.floor((lvl - 250) / 100)) * 75
	end

	return math.clamp(cap, 100, InventoryConfig.MaxCapacityHardCap)
end

function InventoryUtils.GetRarityColor(tier: string): Color3
	return InventoryConfig.RarityColors[tier] or Color3.fromRGB(180, 185, 195)
end

function InventoryUtils.CalculateUsedCapacity(items: { InventoryItem }): number
	local count = 0
	for _, item in ipairs(items) do
		if item.category == "Items" or item.category == "Potion" then
			count += 1
		end
	end
	return count
end

function InventoryUtils.FormatWeight(weightKg: number?): string
	if not weightKg or weightKg <= 0 then return "0 kg" end
	if weightKg >= 1000 then
		local tons = weightKg / 1000
		return if tons == math.floor(tons) then string.format("%d Ton", tons) else string.format("%.1f Ton", tons)
	end
	return if weightKg == math.floor(weightKg) then string.format("%d kg", weightKg) else string.format("%.1f kg", weightKg)
end

function InventoryUtils.FilterAndSortItems(
	items: { InventoryItem }, activeTab: ItemCategory, search: string?,
	sortType: SortOption?, favoritesMap: { [string]: boolean }?
): { InventoryItem }
	local query = if search then string.lower((string.gsub(search, "%s+", ""))) else ""
	local filtered: { InventoryItem } = {}
	local st: SortOption = sortType or "Newest"
	local rWeights = InventoryConfig.RarityWeights

	for _, item in ipairs(items) do
		local matchTab = (activeTab == "All") or (item.category == activeTab)
		local matchSearch = (query == "") or (string.find(string.lower(item.displayName), query, 1, true) ~= nil)
		if matchTab and matchSearch then table.insert(filtered, item) end
	end

	table.sort(filtered, function(a, b)
		local aFav = if favoritesMap and favoritesMap[a.id] ~= nil then favoritesMap[a.id] else (a.isFavorite == true)
		local bFav = if favoritesMap and favoritesMap[b.id] ~= nil then favoritesMap[b.id] else (b.isFavorite == true)
		if st == "Favorited" then
			if aFav ~= bFav then return aFav end
			return (rWeights[a.tier] or 0) > (rWeights[b.tier] or 0)
		elseif st == "Rarity" then
			local rA, rB = rWeights[a.tier] or 0, rWeights[b.tier] or 0
			if rA ~= rB then return rA > rB end
			return (a.weight or 0) > (b.weight or 0)
		elseif st == "Weight" then
			local wA, wB = a.weight or 0, b.weight or 0
			if wA ~= wB then return wA > wB end
			return (rWeights[a.tier] or 0) > (rWeights[b.tier] or 0)
		elseif st == "Name" then
			return string.lower(a.displayName) < string.lower(b.displayName)
		elseif st == "Oldest" then
			local tA, tB = a.obtainedAt or 0, b.obtainedAt or 0
			if tA ~= tB then return tA < tB end
			return a.id < b.id
		else -- "Newest"
			local tA, tB = a.obtainedAt or 0, b.obtainedAt or 0
			if tA ~= tB then return tA > tB end
			return a.id > b.id
		end
	end)

	return filtered
end

function InventoryUtils.FilterItems(items: { InventoryItem }, activeTab: ItemCategory, search: string?): { InventoryItem }
	return InventoryUtils.FilterAndSortItems(items, activeTab, search, "Newest", nil)
end

return InventoryUtils
