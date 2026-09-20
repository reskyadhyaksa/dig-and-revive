--!strict

export type DeviceType = "Mobile" | "Desktop"

export type DeviceInfo = {
	isMobile: boolean,
	viewportSize: Vector2,
}

export type HoldPowerBarProps = {
	visible: boolean,
	power: number, -- 0.0 to 1.0
}

export type DigMinigameProps = {
	visible: boolean,
	progress: number, -- 0.0 to 1.0 (digging completed percentage)
	remainingTime: number?, -- seconds remaining in countdown
	onSwing: (() -> ())?,
	onCancel: (() -> ())?,
}

export type StatsHUDProps = {
	level: number,
	exp: number,
	requiredExp: number,
	coins: number,
	luckMultiplier: number,
}

return {}
