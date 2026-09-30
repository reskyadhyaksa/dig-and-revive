--!strict

local ToolRemovalHelper = {}

-- Destroys every Tool carrying the given UniqueId in the character and backpack.
function ToolRemovalHelper.RemoveByUniqueId(player: Player, uniqueId: string)
	local function check(parent: Instance?)
		if not parent then return end
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("UniqueId") == uniqueId then child:Destroy() end
		end
	end
	check(player.Character)
	check(player:FindFirstChildOfClass("Backpack"))
end

return ToolRemovalHelper
