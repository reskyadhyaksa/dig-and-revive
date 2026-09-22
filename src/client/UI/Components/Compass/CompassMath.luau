--!strict

local CompassMath = {}

function CompassMath.GetYawFromVector(lookVector: Vector3): number
	local angle = math.deg(math.atan2(lookVector.X, -lookVector.Z))
	return (angle + 360) % 360
end

function CompassMath.GetDeltaAngle(targetPos: Vector3, originPos: Vector3, cameraYaw: number): number
	local dx = targetPos.X - originPos.X
	local dz = targetPos.Z - originPos.Z
	local targetBearing = (math.deg(math.atan2(dx, -dz)) + 360) % 360
	local diff = (targetBearing - cameraYaw + 540) % 360 - 180
	return diff
end

function CompassMath.GetDistance(targetPos: Vector3, originPos: Vector3): number
	local dx = targetPos.X - originPos.X
	local dz = targetPos.Z - originPos.Z
	return math.sqrt(dx * dx + dz * dz)
end

function CompassMath.FormatDistance(studs: number): string
	if studs < 1000 then
		return string.format("%dm", math.round(studs))
	end
	return string.format("%.1fkm", studs / 1000)
end

function CompassMath.ComputeNormalizedOffset(deltaAngle: number, visibleFov: number): (number, boolean)
	local halfFov = visibleFov / 2
	local isVisible = math.abs(deltaAngle) <= halfFov
	local clampedDelta = math.clamp(deltaAngle, -halfFov, halfFov)
	local normalized = 0.5 + ((clampedDelta / halfFov) * 0.44)
	return normalized, isVisible
end

return table.freeze(CompassMath)
