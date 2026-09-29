--!strict

export type DialogAction = "SellAll" | "SellHeld" | "Close"

export type DialogOption = {
	label: string,
	next: string?,
	action: DialogAction?,
}

export type DialogNode = {
	text: string,
	options: { DialogOption },
}

export type DialogTree = {
	npcName: string,
	start: string,
	nodes: { [string]: DialogNode },
	results: { [string]: string },
}

export type SellMode = "All" | "Held"

export type SellResult = {
	ok: boolean,
	coins: number,
	count: number,
	reason: string?,
}

return nil
