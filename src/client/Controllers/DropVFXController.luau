--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages:WaitForChild("Trove"))

local DigNetwork = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("DigNetwork"))

local DropVFXController = {}
DropVFXController.__index = DropVFXController

local _controllerTrove = Trove.new()

-- Quadratic Bezier Curve Math
local function quadraticBezier(t: number, p0: Vector3, p1: Vector3, p2: Vector3): Vector3
	return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

function DropVFXController.Init()
	local disconnect = DigNetwork.DigResult.on(function(success: boolean, dropId: string?, amount: number, errorMsg: string?, player: Instance)
		if success and dropId and player then
			DropVFXController.PlayParabolicDrop(player, dropId)
		end
	end)
	
	_controllerTrove:Add(disconnect)
end

function DropVFXController.PlayParabolicDrop(player: Instance, dropId: string)
	if not player:IsA("Player") then return end
	local char = player.Character
	if not char or not char.PrimaryPart then return end
	
	local rootPart = char.PrimaryPart
	local upperTorso = (char:FindFirstChild("UpperTorso") or rootPart) :: BasePart
	
	local dropAssetsFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Drops")
	if not dropAssetsFolder then return end
	
	-- Cari item di semua island (atau Island1)
	local island1Drops = dropAssetsFolder:FindFirstChild("Island1")
	if not island1Drops then return end
	
	local itemModel = island1Drops:FindFirstChild(dropId)
	if not itemModel or not itemModel:IsA("Model") then return end
	
	local clone = itemModel:Clone()
	
	-- Pastikan model memiliki PrimaryPart
	local primaryPart = clone.PrimaryPart
	if not primaryPart then
		local firstPart = clone:FindFirstChildWhichIsA("BasePart", true)
		if firstPart then
			clone.PrimaryPart = firstPart
			primaryPart = firstPart
		else
			clone:Destroy()
			return
		end
	end
	
	-- Set semua part ke CanCollide = false & Anchored = true agar tidak ada physics server 
	for _, desc in clone:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.CanCollide = false
			desc.Anchored = true
		end
	end
	
	clone.Parent = Workspace
	
	-- Titik Awal: Punggung Player
	local p0 = upperTorso.CFrame.Position - (upperTorso.CFrame.LookVector * 1.5)
	
	-- Titik Akhir: Acak di belakang/samping punggung player di tanah
	local randomAngle = math.rad(math.random(-60, 60))
	local dropDistance = math.random(4, 7)
	local backDir = (CFrame.new(Vector3.zero, rootPart.CFrame.LookVector) * CFrame.Angles(0, randomAngle + math.pi, 0)).LookVector
	
	local p2 = p0 + (backDir * dropDistance)
	
	-- Raycast ke bawah untuk memastikan jatuh ke tanah
	local ray = RaycastParams.new()
	ray.FilterType = Enum.RaycastFilterType.Exclude
	ray.FilterDescendantsInstances = {char, clone}
	local hit = Workspace:Raycast(p2 + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), ray)
	if hit then
		p2 = hit.Position + Vector3.new(0, primaryPart.Size.Y / 2, 0)
	else
		p2 = p2 - Vector3.new(0, 3, 0) -- fallback
	end
	
	-- Control Point: Tengah-tengah p0 dan p2, dinaikkan ke atas (arch)
	local p1 = (p0 + p2) / 2 + Vector3.new(0, math.random(5, 8), 0)
	
	local dropTrove = _controllerTrove:Extend()
	dropTrove:Add(clone)
	
	local duration = 0.8 -- durasi animasi
	local startTime = os.clock()
	local randRotationSpeed = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
	
	local conn; conn = RunService.RenderStepped:Connect(function()
		local elapsed = os.clock() - startTime
		local t = math.clamp(elapsed / duration, 0, 1)
		
		local currentPos = quadraticBezier(t, p0, p1, p2)
		local currentRot = CFrame.Angles(
			randRotationSpeed.X * elapsed, 
			randRotationSpeed.Y * elapsed, 
			randRotationSpeed.Z * elapsed
		)
		
		clone:PivotTo(CFrame.new(currentPos) * currentRot)
		
		if t >= 1 then
			conn:Disconnect()
			
			-- Hapus setelah 5 detik diam di tanah
			task.delay(5, function()
				dropTrove:Clean()
			end)
		end
	end)
	
	dropTrove:Add(function()
		conn:Disconnect()
	end)
end

function DropVFXController.Destroy()
	_controllerTrove:Clean()
end

return DropVFXController
