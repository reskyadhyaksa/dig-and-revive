--!strict

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

local RevivalController = {}
local _trove = Trove.new()
local _activeTroves: { [Model]: any } = {}

local function AnimatePrimeLiving(model: Model)
	if _activeTroves[model] then return end
	local rootPart = (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")) :: BasePart?
	if not rootPart then return end

	local mTrove = _trove:Extend()
	_activeTroves[model] = mTrove

	local initialCFrame = model:GetPivot()
	local startTime = os.clock()

	local conn = RunService.RenderStepped:Connect(function()
		if not model.Parent or not rootPart.Parent then
			mTrove:Clean()
			_activeTroves[model] = nil
			return
		end

		local elapsed = os.clock() - startTime
		local floatY = math.sin(elapsed * 2.5) * 0.4
		local rotY = (elapsed * 35) % 360

		local targetCFrame = initialCFrame * CFrame.Angles(0, math.rad(rotY), 0) + Vector3.new(0, floatY, 0)
		model:PivotTo(targetCFrame)
	end)

	mTrove:Add(conn)
	mTrove:Add(model.Destroying:Connect(function()
		mTrove:Clean()
		_activeTroves[model] = nil
	end))
end

local function CheckModel(child: Instance)
	if child:IsA("Model") and child:GetAttribute("IsPrimeLiving") == true then
		AnimatePrimeLiving(child)
	end
end

function RevivalController.Init()
	for _, child in Workspace:GetChildren() do CheckModel(child) end

	_trove:Connect(Workspace.ChildAdded, function(child)
		if child:IsA("Model") then
			if child:GetAttribute("IsPrimeLiving") == true then
				AnimatePrimeLiving(child)
			else
				local conn: RBXScriptConnection? = nil
				conn = child:GetAttributeChangedSignal("IsPrimeLiving"):Connect(function()
					if child:GetAttribute("IsPrimeLiving") == true then
						if conn then conn:Disconnect() conn = nil end
						AnimatePrimeLiving(child)
					end
				end)
				_trove:Add(function() if conn then conn:Disconnect() end end)
			end
		end
	end)
end

function RevivalController.Destroy()
	_trove:Clean()
	table.clear(_activeTroves)
end

return RevivalController
