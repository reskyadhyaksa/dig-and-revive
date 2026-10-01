--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local DigService = require(script.Parent:WaitForChild("DigService"))

local AdminService = {}
local _trove = Trove.new()

local ADMIN_USER_IDS: { [number]: boolean } = {
	-- Add any designated admin user IDs here
}

local function IsAdmin(player: Player): boolean
	if RunService:IsStudio() then return true end
	if player.UserId == game.CreatorId then return true end
	if ADMIN_USER_IDS[player.UserId] then return true end
	return false
end

local function FindPlayerByName(query: string): Player?
	local lower = string.lower(query)
	for _, p in ipairs(Players:GetPlayers()) do
		if string.lower(p.Name) == lower or string.lower(p.DisplayName) == lower then
			return p
		end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if string.find(string.lower(p.Name), lower, 1, true) then
			return p
		end
	end
	return nil
end

local function HandleCommand(sender: Player, message: string)
	if not IsAdmin(sender) then return end
	local tokens = string.split(string.gsub(message, "^%s*(.-)%s*$", "%1"), " ")
	if #tokens == 0 then return end

	local cmd = string.lower(tokens[1])
	if cmd == "/secret" or cmd == ";secret" or cmd == "!secret" or cmd == "/forcesecret" then
		local target = sender
		if tokens[2] then
			local found = FindPlayerByName(tokens[2])
			if found then target = found end
		end
		DigService.SetForcedNextTier(target, "Secret")
		print(string.format("[Admin] Forced next dig drop for '%s' to Secret tier (All requirements bypassed)!", target.Name))
	elseif cmd == "/unsecret" or cmd == ";unsecret" or cmd == "!unsecret" then
		local target = sender
		if tokens[2] then
			local found = FindPlayerByName(tokens[2])
			if found then target = found end
		end
		DigService.SetForcedNextTier(target, nil)
		print(string.format("[Admin] Cleared forced drop for '%s'.", target.Name))
	end
end

function AdminService.Init()
	-- Listen for legacy Player.Chatted
	_trove:Connect(Players.PlayerAdded, function(p: Player)
		p.Chatted:Connect(function(msg: string)
			HandleCommand(p, msg)
		end)
	end)

	for _, p in ipairs(Players:GetPlayers()) do
		p.Chatted:Connect(function(msg: string)
			HandleCommand(p, msg)
		end)
	end

	-- Listen for modern TextChatService incoming messages
	pcall(function()
		TextChatService.MessageReceived:Connect(function(textChatMessage: TextChatMessage)
			local src = textChatMessage.TextSource
			if src then
				local p = Players:GetPlayerByUserId(src.UserId)
				if p then HandleCommand(p, textChatMessage.Text) end
			end
		end)
	end)
end

function AdminService.Destroy()
	_trove:Clean()
end

return AdminService
