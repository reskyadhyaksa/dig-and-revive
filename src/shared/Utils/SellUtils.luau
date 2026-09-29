--!strict

local Shared = script.Parent.Parent
local SellConfig = require(Shared:WaitForChild("Configs"):WaitForChild("SellConfig"))
local InventoryTypes = require(Shared:WaitForChild("Types"):WaitForChild("InventoryTypes"))

type InventoryItem = InventoryTypes.InventoryItem

local SellUtils = {}

function SellUtils.CalculatePrice(tier: string, weight: number?, amount: number?): number
	local base = SellConfig.TierPrices[tier] or SellConfig.TierPrices.Common
	local weightBonus = 1 + (weight or 0) * SellConfig.WeightPriceFactor
	return math.floor(base * weightBonus) * (amount or 1)
end

function SellUtils.IsSellable(item: InventoryItem): boolean
	return not SellConfig.UnsellableCategories[item.category]
end

-- Sell-all skips favorites and hotbar-equipped items to prevent accidental loss.
function SellUtils.FilterSellAll(items: { InventoryItem }): { InventoryItem }
	local result: { InventoryItem } = {}
	for _, item in ipairs(items) do
		if SellUtils.IsSellable(item) and not item.isFavorite and not item.isEquipped then
			table.insert(result, item)
		end
	end
	return result
end

function SellUtils.TotalPrice(items: { InventoryItem }): number
	local total = 0
	for _, item in ipairs(items) do
		total += SellUtils.CalculatePrice(item.tier, item.weight, item.amount)
	end
	return total
end

function SellUtils.IsWithinRange(a: Vector3, b: Vector3, maxDistance: number): boolean
	return (a - b).Magnitude <= maxDistance
end

function SellUtils.FormatText(template: string, vars: { [string]: string | number }): string
	return (string.gsub(template, "{(%w+)}", function(key)
		local v = vars[key]
		return if v ~= nil then tostring(v) else "{" .. key .. "}"
	end))
end

return SellUtils
