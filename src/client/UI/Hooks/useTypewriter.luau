--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))

-- Reveals `text` progressively; restarts whenever the text changes.
local function useTypewriter(text: string, charsPerSecond: number): string
	local count, setCount = React.useState(0)

	React.useEffect(function()
		setCount(0)
		local total = utf8.len(text) or #text
		local thread = task.spawn(function()
			local shown = 0
			while shown < total do
				task.wait(1 / charsPerSecond)
				shown += 1
				setCount(shown)
			end
		end)
		return function() task.cancel(thread) end
	end, { text })

	local byteEnd = utf8.offset(text, count + 1)
	return if byteEnd then string.sub(text, 1, byteEnd - 1) else text
end

return useTypewriter
