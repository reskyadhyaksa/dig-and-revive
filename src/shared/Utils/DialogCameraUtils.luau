--!strict

local DialogCameraUtils = {}

export type Framing = {
	Distance: number,
	SideOffset: number,
	Height: number,
	LookHeight: number,
}

-- Pure: camera CFrame on the player's side of the NPC, offset sideways, looking at the NPC.
function DialogCameraUtils.GetFocusCFrame(playerPos: Vector3, focusPos: Vector3, framing: Framing): CFrame
	local flat = Vector3.new(playerPos.X - focusPos.X, 0, playerPos.Z - focusPos.Z)
	local toPlayer = if flat.Magnitude > 1e-3 then flat.Unit else Vector3.new(0, 0, 1)
	local side = Vector3.yAxis:Cross(toPlayer)
	local camPos = focusPos + toPlayer * framing.Distance + side * framing.SideOffset + Vector3.yAxis * framing.Height
	return CFrame.lookAt(camPos, focusPos + Vector3.yAxis * framing.LookHeight)
end

return DialogCameraUtils
