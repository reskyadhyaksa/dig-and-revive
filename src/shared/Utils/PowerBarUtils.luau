--!strict

local PowerBarUtils = {}

local COLOR_EMERALD_GREEN = Color3.fromHex("00FF44")
local COLOR_VIBRANT_LIME = Color3.fromHex("68FF00")
local COLOR_GOLDEN_YELLOW = Color3.fromHex("FFEA00")
local COLOR_AMBER_ORANGE = Color3.fromHex("FF6D00")
local COLOR_DEEP_RED = Color3.fromHex("E51B24")

PowerBarUtils.VerticalColorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, COLOR_EMERALD_GREEN),
	ColorSequenceKeypoint.new(0.25, COLOR_VIBRANT_LIME),
	ColorSequenceKeypoint.new(0.50, COLOR_GOLDEN_YELLOW),
	ColorSequenceKeypoint.new(0.75, COLOR_AMBER_ORANGE),
	ColorSequenceKeypoint.new(1.00, COLOR_DEEP_RED),
})

function PowerBarUtils.GetMultiplier(progress: number): number
	local p = math.clamp(progress, 0, 1)
	return 1.0 + (p * 1.5)
end

function PowerBarUtils.GetDynamicProgressColor(progress: number): Color3
	local p = math.clamp(progress, 0, 1)
	if p < 0.25 then
		return COLOR_DEEP_RED:Lerp(COLOR_AMBER_ORANGE, p / 0.25)
	elseif p < 0.50 then
		return COLOR_AMBER_ORANGE:Lerp(COLOR_GOLDEN_YELLOW, (p - 0.25) / 0.25)
	elseif p < 0.75 then
		return COLOR_GOLDEN_YELLOW:Lerp(COLOR_VIBRANT_LIME, (p - 0.50) / 0.25)
	else
		return COLOR_VIBRANT_LIME:Lerp(COLOR_EMERALD_GREEN, (p - 0.75) / 0.25)
	end
end

function PowerBarUtils.GetProgressTransparency(progress: number): NumberSequence
	local p = math.clamp(progress, 0, 1)
	if p <= 0.001 then return NumberSequence.new(1.0) end
	if p >= 0.999 then return NumberSequence.new(0.0) end
	local cutoff = math.clamp(1 - p, 0.002, 0.998)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0.0, 1.0),
		NumberSequenceKeypoint.new(cutoff - 0.001, 1.0),
		NumberSequenceKeypoint.new(cutoff, 0.0),
		NumberSequenceKeypoint.new(1.0, 0.0),
	})
end

function PowerBarUtils.GetLuckTier(progress: number): (string, Color3)
	local p = math.clamp(progress, 0, 1)
	if p < 0.20 then return "BAD", COLOR_DEEP_RED end
	if p < 0.45 then return "NICE", COLOR_AMBER_ORANGE end
	if p < 0.70 then return "GREAT", COLOR_GOLDEN_YELLOW end
	if p < 0.90 then return "AMAZING", COLOR_VIBRANT_LIME end
	return "PERFECT!", COLOR_EMERALD_GREEN
end

return table.freeze(PowerBarUtils)
