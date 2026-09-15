--!strict

export type DiggableMaterial = Enum.Material

export type MaterialConfig = {
	material: DiggableMaterial,
	displayName: string,
	hardnessTier: number,
	dropTableId: string,
	baseDigDuration: number,
}

export type ZoneConfig = {
	zoneId: string,
	displayName: string,
	islandId: string,
	containerPath: string,
	allowedMaterials: { DiggableMaterial },
	dropTableId: string,
	minToolTier: number,
}

export type ZoneInfo = {
	zoneId: string,
	displayName: string,
	islandId: string,
	instance: Instance,
}

return nil
