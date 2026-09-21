--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))

local IndexModal = require(script.Parent.IndexModal)
local IndexTypes = require(ReplicatedStorage.Shared.Types.IndexTypes)

type PlayerIndexData = IndexTypes.PlayerIndexData

local MOCK_INDEX_DATA: PlayerIndexData = {
	BrokenMudPot = { timesFound = 8, firstDiscoveredAt = 1700000000 },
	ChippedBottle = { timesFound = 3, firstDiscoveredAt = 1700000100 },
	HareSkeleton = { timesFound = 2, firstDiscoveredAt = 1700000200 },
	FennecFoxSkeleton = { timesFound = 1, firstDiscoveredAt = 1700000300 },
	GolemLeftArm = { timesFound = 1, firstDiscoveredAt = 1700000400 },
}

local story = {
	summary = "Discovery Index / Codex modal showcasing discovered items and dark mystery silhouettes.",
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		visible = true,
	},
	story = function(props: { controls: { visible: boolean }, target: Instance })
		return React.createElement(IndexModal, {
			visible = if props.controls.visible ~= nil then props.controls.visible else true,
			indexData = MOCK_INDEX_DATA,
			onClose = function() print("[Story] IndexModal closed") end,
		})
	end,
}

return story
