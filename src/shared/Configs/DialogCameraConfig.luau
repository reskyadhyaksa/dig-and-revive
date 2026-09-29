--!strict

-- Three-quarter shot of the NPC, measured from the NPC so framing is stable at any talk distance.
local DialogCameraConfig = {
	Distance = 9, -- studs from the NPC head toward the player
	SideOffset = 5, -- studs sideways so the player's body doesn't block the NPC
	Height = 2, -- studs above the NPC head
	LookHeight = -1, -- aim below the head so the NPC sits above the dialog panel
	FieldOfView = 55,
	PlayerFade = 0.85, -- local-only transparency so the player never blocks the NPC
	FocusTime = 0.45,
	ReturnTime = 0.35,
}

return DialogCameraConfig
