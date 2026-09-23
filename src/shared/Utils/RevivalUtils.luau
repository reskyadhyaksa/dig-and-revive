--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RevivalConfig = require(script.Parent.Parent.Configs.RevivalConfig)
local RevivalTypes = require(script.Parent.Parent.Types.RevivalTypes)

type RevivalRecipe = RevivalTypes.RevivalRecipe

local RevivalUtils = {}

function RevivalUtils.GetRecipe(fossilId: string): RevivalRecipe?
	return RevivalConfig.RecipesByFossilId[fossilId]
end

function RevivalUtils.GetAltarDisplayCFrame(altarPart: BasePart, heightOffset: number?): CFrame
	local offset = heightOffset or 2.5
	local topY = altarPart.Position.Y + (altarPart.Size.Y / 2) + offset
	return CFrame.new(altarPart.Position.X, topY, altarPart.Position.Z) * altarPart.CFrame.Rotation
end

function RevivalUtils.FindLivingAsset(islandId: string, modelName: string): Model?
	local assets = ReplicatedStorage:FindFirstChild("Assets") :: Instance?
	if not assets then return nil end

	local revivalFolder = assets:FindFirstChild("Revival") :: Instance?
	if not revivalFolder then return nil end

	local islandFolder = revivalFolder:FindFirstChild(islandId) :: Instance?
	if not islandFolder then return nil end

	local model = islandFolder:FindFirstChild(modelName)
	if model and model:IsA("Model") then
		return model
	end
	return nil
end

return RevivalUtils
