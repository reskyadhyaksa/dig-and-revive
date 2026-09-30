--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Reads the server-mirrored skin data (OwnedSkins / EquippedSkins JSON attributes) of the local player.
local SkinAttributeReader = {}

local function Decode(name: string): { [string]: any }
	local raw = Players.LocalPlayer:GetAttribute(name)
	if typeof(raw) ~= "string" then return {} end
	local ok, value = pcall(HttpService.JSONDecode, HttpService, raw)
	return if ok and typeof(value) == "table" then value else {}
end

function SkinAttributeReader.GetOwned(): { [string]: boolean }
	return Decode("OwnedSkins") :: { [string]: boolean }
end

function SkinAttributeReader.GetEquipped(): { [string]: string }
	return Decode("EquippedSkins") :: { [string]: string }
end

return SkinAttributeReader
