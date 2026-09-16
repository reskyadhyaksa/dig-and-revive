--!strict

local DigMinigameHelper = {}

-- Generates soft edge fading transparency for the inner bar before the shovel marker
function DigMinigameHelper.GetFadeTransparencySequence(progress: number): NumberSequence
	local p = math.clamp(progress, 0, 1)
	if p <= 0.02 then
		return NumberSequence.new(1.0)
	end

	local fadeLength = math.min(0.06, p * 0.3)
	local p1 = math.clamp(p - fadeLength, 0, 0.995)
	local p2 = math.clamp(p - (fadeLength * 0.5), p1 + 0.001, 0.997)
	local p3 = math.clamp(p - (fadeLength * 0.15), p2 + 0.001, 0.999)
	local pEnd = math.clamp(p, p3 + 0.001, 1.0)

	return NumberSequence.new({
		NumberSequenceKeypoint.new(0.0, 0.0),       -- Fully opaque
		NumberSequenceKeypoint.new(p1, 0.0),        -- Solid up to before shovel marker
		NumberSequenceKeypoint.new(p2, 0.25),       -- Gentle initial fade
		NumberSequenceKeypoint.new(p3, 0.95),       -- 95% transparent
		NumberSequenceKeypoint.new(pEnd, 1.0),      -- Fully transparent at tip
		NumberSequenceKeypoint.new(1.0, 1.0),       -- Transparent remainder
	})
end

return DigMinigameHelper
