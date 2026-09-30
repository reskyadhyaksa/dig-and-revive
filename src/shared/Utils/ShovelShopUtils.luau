--!strict

local ShovelTypes = require(script.Parent.Parent:WaitForChild("Types"):WaitForChild("ShovelTypes"))

type ShovelConfig = ShovelTypes.ShovelConfig
type PurchaseFailReason = ShovelTypes.PurchaseFailReason

local ShovelShopUtils = {}

-- Pure eligibility check; the caller supplies every fact so this stays instance-free.
function ShovelShopUtils.CheckPurchase(
	config: ShovelConfig?,
	alreadyOwned: boolean,
	level: number,
	coins: number,
	distance: number,
	maxDistance: number
): PurchaseFailReason?
	if not config or config.isStarter then return "UnknownShovel" end
	if alreadyOwned then return "AlreadyOwned" end
	if distance > maxDistance then return "TooFar" end
	if level < config.requiredLevel then return "LevelTooLow" end
	if coins < config.price then return "NotEnoughCoins" end
	return nil
end

function ShovelShopUtils.FormatPrice(price: number, currencyName: string): string
	return if price <= 0 then "Free" else string.format("%d %s", price, currencyName)
end

return table.freeze(ShovelShopUtils)
