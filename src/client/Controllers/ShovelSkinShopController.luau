--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShovelSkinConfig = require(Shared:WaitForChild("Configs"):WaitForChild("ShovelSkinConfig"))
local ShovelSkinUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelSkinUtils"))
local ShovelShopUtils = require(Shared:WaitForChild("Utils"):WaitForChild("ShovelShopUtils"))
local SignalTypes = require(Shared:WaitForChild("Types"):WaitForChild("SignalTypes"))
local SkinAttributeReader = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("SkinAttributeReader"))
local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))

type Signal<T...> = SignalTypes.Signal<T...>

-- Buy prompts on parts tagged ShovelSkinShop, plus a readable SkinResult signal for the UI.
local ShovelSkinShopController = {}
local _trove = Trove.new()
local _shopTroves: { [Instance]: any } = {}
local _prompts: { [ProximityPrompt]: string } = {}

ShovelSkinShopController.SkinResult = _trove:Construct(Signal) :: Signal<boolean, string>

local function RefreshPrompt(prompt: ProximityPrompt, skinId: string)
	local skin = ShovelSkinUtils.GetSkin(skinId)
	if not skin then return end
	prompt.Enabled = not ShovelSkinUtils.IsOwned(skin, SkinAttributeReader.GetOwned())
	prompt.ObjectText = skin.displayName .. " Skin"
	prompt.ActionText = "Buy " .. ShovelShopUtils.FormatPrice(skin.price, ShovelSkinConfig.CurrencyName)
end

local function SetupShop(shop: Instance)
	if _shopTroves[shop] or not shop:IsA("BasePart") then return end
	local skinId = shop:GetAttribute(ShovelSkinConfig.SkinIdAttribute)
	if typeof(skinId) ~= "string" or not ShovelSkinUtils.GetSkin(skinId) then
		warn(string.format("[ShovelSkinShop] '%s' has no valid SkinId attribute", shop:GetFullName()))
		return
	end

	local shopTrove = _trove:Extend()
	_shopTroves[shop] = shopTrove
	local prompt = shopTrove:Add(Instance.new("ProximityPrompt")) :: ProximityPrompt
	prompt.KeyboardKeyCode = ShovelSkinConfig.PromptKey
	prompt.HoldDuration = ShovelSkinConfig.PromptHoldDuration
	prompt.MaxActivationDistance = ShovelSkinConfig.MaxPurchaseDistance - 2
	prompt.RequiresLineOfSight = false
	prompt.Parent = shop
	_prompts[prompt] = skinId
	shopTrove:Add(function() _prompts[prompt] = nil end)

	RefreshPrompt(prompt, skinId)
	shopTrove:Connect(prompt.Triggered, function() DigNetwork.BuySkinRequest.fire(skinId) end)
end

local function CleanupShop(shop: Instance)
	local shopTrove = _shopTroves[shop]
	if not shopTrove then return end
	_shopTroves[shop] = nil
	_trove:Remove(shopTrove)
end

local function GetMessage(skinId: string, key: string?): string
	local skin = ShovelSkinUtils.GetSkin(skinId)
	local name = if skin then skin.displayName else skinId
	local template = ShovelSkinConfig.Messages[key or "UnknownSkin"] or ShovelSkinConfig.Messages.UnknownSkin
	if key == "LevelTooLow" then return string.format(template, if skin then skin.requiredLevel else 0) end
	return if string.find(template, "%s", 1, true) then string.format(template, name) else template
end

function ShovelSkinShopController.Init()
	for _, shop in CollectionService:GetTagged(ShovelSkinConfig.ShopTag) do SetupShop(shop) end
	_trove:Connect(CollectionService:GetInstanceAddedSignal(ShovelSkinConfig.ShopTag), SetupShop)
	_trove:Connect(CollectionService:GetInstanceRemovedSignal(ShovelSkinConfig.ShopTag), CleanupShop)
	_trove:Connect(Players.LocalPlayer:GetAttributeChangedSignal("OwnedSkins"), function()
		for prompt, skinId in _prompts do RefreshPrompt(prompt, skinId) end
	end)
	_trove:Add(DigNetwork.SkinResult.on(function(ok, skinId, key)
		ShovelSkinShopController.SkinResult:Fire(ok, GetMessage(skinId, key))
	end))
end

function ShovelSkinShopController.Destroy()
	_trove:Clean()
end

return ShovelSkinShopController
