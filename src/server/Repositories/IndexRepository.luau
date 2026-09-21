--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local IndexTypes = require(Shared:WaitForChild("Types"):WaitForChild("IndexTypes"))
local PlayerProfileStore = require(script.Parent.PlayerProfileStore)

type PlayerIndexData = IndexTypes.PlayerIndexData
type DiscoveredItemRecord = IndexTypes.DiscoveredItemRecord

local IndexRepository = {}

local function SyncAttribute(player: Player, indexMap: PlayerIndexData)
	pcall(function()
		player:SetAttribute("IndexData", HttpService:JSONEncode(indexMap))
	end)
end

function IndexRepository.GetPlayerIndex(player: Player): PlayerIndexData
	local data = PlayerProfileStore.GetProfileData(player)
	if not data then return {} end
	if not data.discoveredIndex then
		data.discoveredIndex = {}
	end
	local indexMap = data.discoveredIndex :: PlayerIndexData
	SyncAttribute(player, indexMap)
	return indexMap
end

function IndexRepository.RecordDiscovery(player: Player, itemId: string): (boolean, number)
	local data = PlayerProfileStore.GetProfileData(player)
	if not data then return false, 0 end
	if not data.discoveredIndex then
		data.discoveredIndex = {}
	end

	local indexMap = data.discoveredIndex :: PlayerIndexData
	local record = indexMap[itemId]
	local isFirst = record == nil

	if isFirst then
		local newRecord: DiscoveredItemRecord = {
			timesFound = 1,
			firstDiscoveredAt = os.time(),
			isRewardClaimed = false,
		}
		indexMap[itemId] = newRecord
		SyncAttribute(player, indexMap)
		return true, 1
	else
		record.timesFound += 1
		SyncAttribute(player, indexMap)
		return false, record.timesFound
	end
end

function IndexRepository.ClaimReward(player: Player, itemId: string): boolean
	local data = PlayerProfileStore.GetProfileData(player)
	if not data or not data.discoveredIndex then return false end
	local indexMap = data.discoveredIndex :: PlayerIndexData
	local record = indexMap[itemId]
	if record and not record.isRewardClaimed then
		record.isRewardClaimed = true
		SyncAttribute(player, indexMap)
		return true
	end
	return false
end

return IndexRepository
