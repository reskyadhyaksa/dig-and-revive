--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelShopConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelShopConfig"))
local ShovelShopUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelShopUtils"))
local ShovelUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelUtils"))
local SignalTypes = require(Shared:WaitForChild("Types"):WaitForChild("SignalTypes"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))

type Signal<T...> = SignalTypes.Signal<T...>

local ShovelShopController = {}
local _trove = Trove.new()
local _shopTroves: { [Instance]: any } = {}
local _prompts: { [ProximityPrompt]: string } = {}

ShovelShopController.PurchaseResult = _trove:Construct(Signal) :: Signal<boolean, string, string>

local function OwnsShovel(shovelId: string): boolean
	local raw = Players.LocalPlayer:GetAttribute("OwnedShovels")
	if typeof(raw) ~= "string" then return false end
	local ok, owned = pcall(HttpService.JSONDecode, HttpService, raw)
	return ok and typeof(owned) == "table" and owned[shovelId] == true
end

local function RefreshPrompt(prompt: ProximityPrompt, shovelId: string)
	local config = ShovelUtils.GetShovelConfig(shovelId)
	if not config then return end
	local owned = OwnsShovel(shovelId)
	prompt.Enabled = not owned
	prompt.ObjectText = config.displayName
	prompt.ActionText = "Buy " .. ShovelShopUtils.FormatPrice(config.price, ShovelShopConfig.CurrencyName)
end

local function SetupShop(shop: Instance)
	if _shopTroves[shop] or not shop:IsA("BasePart") then return end
	local shovelId = tostring(shop:GetAttribute(ShovelShopConfig.ShovelIdAttribute) or shop.Name)
	if not ShovelUtils.GetShovelConfig(shovelId) then
		warn(string.format("[ShovelShop] '%s' has no ShovelConfig entry for '%s'", shop:GetFullName(), shovelId))
		return
	end

	local shopTrove = _trove:Extend()
	_shopTroves[shop] = shopTrove
	local prompt = shopTrove:Add(Instance.new("ProximityPrompt")) :: ProximityPrompt
	prompt.KeyboardKeyCode = ShovelShopConfig.PromptKey
	prompt.HoldDuration = ShovelShopConfig.PromptHoldDuration
	prompt.MaxActivationDistance = ShovelShopConfig.MaxPurchaseDistance - 2
	prompt.RequiresLineOfSight = false
	prompt.Parent = shop
	_prompts[prompt] = shovelId
	shopTrove:Add(function() _prompts[prompt] = nil end)

	RefreshPrompt(prompt, shovelId)
	shopTrove:Connect(prompt.Triggered, function() DigNetwork.BuyShovelRequest.fire(shovelId) end)
end

local function CleanupShop(shop: Instance)
	local shopTrove = _shopTroves[shop]
	if not shopTrove then return end
	_shopTroves[shop] = nil
	_trove:Remove(shopTrove)
end

local function GetMessage(ok: boolean, shovelId: string, reason: string?): string
	local config = ShovelUtils.GetShovelConfig(shovelId)
	local messages = ShovelShopConfig.Messages
	if ok then return string.format(messages.Success, if config then config.displayName else shovelId) end
	if reason == "LevelTooLow" then return string.format(messages.LevelTooLow, if config then config.requiredLevel else 0) end
	return messages[reason or "UnknownShovel"] or messages.UnknownShovel
end

function ShovelShopController.Init()
	for _, shop in CollectionService:GetTagged(ShovelShopConfig.ShopTag) do SetupShop(shop) end
	_trove:Connect(CollectionService:GetInstanceAddedSignal(ShovelShopConfig.ShopTag), SetupShop)
	_trove:Connect(CollectionService:GetInstanceRemovedSignal(ShovelShopConfig.ShopTag), CleanupShop)
	_trove:Connect(Players.LocalPlayer:GetAttributeChangedSignal("OwnedShovels"), function()
		for prompt, shovelId in _prompts do RefreshPrompt(prompt, shovelId) end
	end)
	_trove:Add(DigNetwork.BuyShovelResult.on(function(ok, shovelId, reason)
		ShovelShopController.PurchaseResult:Fire(ok, shovelId, GetMessage(ok, shovelId, reason))
	end))
end

function ShovelShopController.Destroy()
	_trove:Clean()
end

return ShovelShopController
