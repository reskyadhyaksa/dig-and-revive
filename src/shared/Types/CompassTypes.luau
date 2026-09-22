--!strict

export type Waypoint = {
	id: string,
	name: string,
	position: Vector3,
	color: Color3,
	symbol: string?,
	icon: string?,
	islandId: string?,
	targetIslandId: string?,
	minDistance: number?,
	maxDistance: number?,
}

export type ProcessedWaypoint = {
	id: string,
	name: string,
	color: Color3,
	symbol: string?,
	icon: string?,
	islandId: string?,
	distance: number,
	deltaAngle: number,
	normalizedOffset: number,
	isVisible: boolean,
}

export type CompassState = {
	yawDeg: number,
	waypoints: { ProcessedWaypoint },
	visible: boolean,
}

return nil
