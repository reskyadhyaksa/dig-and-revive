--!strict

local PowerBarHelper = {}

local COLOR_EMERALD_GREEN = Color3.fromHex("00FF44")
local COLOR_VIBRANT_LIME = Color3.fromHex("68FF00")
local COLOR_GOLDEN_YELLOW = Color3.fromHex("FFEA00")
local COLOR_AMBER_ORANGE = Color3.fromHex("FF6D00")
local COLOR_DEEP_RED = Color3.fromHex("E51B24")

-- Static ColorSequence for vertical gradient (Keypoint 0 = Top/100%, Keypoint 1 = Bottom/0%)
PowerBarHelper.VerticalColorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, COLOR_EMERALD_GREEN), -- Top (100%): Perfect
	ColorSequenceKeypoint.new(0.25, COLOR_VIBRANT_LIME),   -- 75%: Amazing
	ColorSequenceKeypoint.new(0.50, COLOR_GOLDEN_YELLOW),  -- 50%: Great
	ColorSequenceKeypoint.new(0.75, COLOR_AMBER_ORANGE),   -- 25%: Nice
	ColorSequenceKeypoint.new(1.00, COLOR_DEEP_RED),       -- Bottom (0%): Bad
})

-- Multiplier scales from 1.0X at 0% to 2.5X at 100%
function PowerBarHelper.GetMultiplier(progress: number): number
	local p = math.clamp(progress, 0, 1)
	return 1.0 + (p * 1.5)
end

-- Interpolated active color based on current power (0 = Red, 1 = Green)
function PowerBarHelper.GetDynamicProgressColor(progress: number): Color3
	local p = math.clamp(progress, 0, 1)
	if p < 0.25 then
		local alpha = p / 0.25
		return COLOR_DEEP_RED:Lerp(COLOR_AMBER_ORANGE, alpha)
	elseif p < 0.50 then
		local alpha = (p - 0.25) / 0.25
		return COLOR_AMBER_ORANGE:Lerp(COLOR_GOLDEN_YELLOW, alpha)
	elseif p < 0.75 then
		local alpha = (p - 0.50) / 0.25
		return COLOR_GOLDEN_YELLOW:Lerp(COLOR_VIBRANT_LIME, alpha)
	else
		local alpha = (p - 0.75) / 0.25
		return COLOR_VIBRANT_LIME:Lerp(COLOR_EMERALD_GREEN, alpha)
	end
end

-- Dynamic cutoff transparency for the capsule gradient
function PowerBarHelper.GetProgressTransparency(progress: number): NumberSequence
	local p = math.clamp(progress, 0, 1)
	if p <= 0.001 then
		return NumberSequence.new(1.0)
	elseif p >= 0.999 then
		return NumberSequence.new(0.0)
	else
		local cutoff = math.clamp(1 - p, 0.002, 0.998)
		return NumberSequence.new({
			NumberSequenceKeypoint.new(0.0, 1.0),
			NumberSequenceKeypoint.new(cutoff - 0.001, 1.0),
			NumberSequenceKeypoint.new(cutoff, 0.0),
			NumberSequenceKeypoint.new(1.0, 0.0),
		})
	end
end

-- Tier label text and corresponding color
function PowerBarHelper.GetLuckTier(progress: number): (string, Color3)
	local p = math.clamp(progress, 0, 1)
	if p < 0.20 then
		return "BAD", COLOR_DEEP_RED
	elseif p < 0.45 then
		return "NICE", COLOR_AMBER_ORANGE
	elseif p < 0.70 then
		return "GREAT", COLOR_GOLDEN_YELLOW
	elseif p < 0.90 then
		return "AMAZING", COLOR_VIBRANT_LIME
	else
		return "PERFECT!", COLOR_EMERALD_GREEN
	end
end

return PowerBarHelper
