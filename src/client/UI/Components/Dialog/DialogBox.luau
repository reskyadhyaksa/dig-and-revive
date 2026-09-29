--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local DialogTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("DialogTypes"))
local UIBuilder = require(script.Parent.Parent.Parent.Common.UIBuilder)
local DialogTheme = require(script.Parent.Parent.Parent.Common.DialogTheme)
local useDeviceType = require(script.Parent.Parent.Parent.Hooks.useDeviceType)
local useTypewriter = require(script.Parent.Parent.Parent.Hooks.useTypewriter)
local DialogOptionButton = require(script.Parent.DialogOptionButton)

type DialogOption = DialogTypes.DialogOption

export type Props = {
	npcName: string,
	text: string,
	options: { DialogOption },
	onOption: (option: DialogOption) -> (),
}

local function DialogBox(props: Props): any
	local isMobile = useDeviceType().isMobile
	local shownText = useTypewriter(props.text, DialogTheme.TypewriterCharsPerSecond)

	local optionElements: { [string]: any } = {}
	for i, option in ipairs(props.options) do
		optionElements["Option" .. i] = React.createElement(DialogOptionButton, {
			layoutOrder = i, label = option.label, isMobile = isMobile,
			baseColor = if option.action == "Close" then DialogTheme.CloseOptionColor else DialogTheme.OptionColor,
			onActivated = function() props.onOption(option) end,
		})
	end

	local textSize = if isMobile then 18 else 19
	local function BodyLabel(text: string, transparency: number, size: UDim2, auto: Enum.AutomaticSize): any
		return React.createElement("TextLabel", {
			Size = size, AutomaticSize = auto, BackgroundTransparency = 1, Text = text, TextTransparency = transparency,
			TextColor3 = DialogTheme.TextColor, Font = Enum.Font.GothamBold, TextSize = textSize,
			TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 41,
		})
	end

	-- Panel height follows its content; bottom anchor makes it grow upward.
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.96),
		Size = UDim2.fromScale(if isMobile then 0.94 else 0.5, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = DialogTheme.PanelColor, Active = true, ZIndex = 40,
	}, {
		Corner = UIBuilder.Corner(16), Stroke = UIBuilder.Stroke(DialogTheme.PanelStroke, 3),
		SizeConstraint = React.createElement("UISizeConstraint", { MinSize = Vector2.new(300, 0), MaxSize = Vector2.new(720, math.huge) }),
		Pad = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
			PaddingTop = UDim.new(0, 24), PaddingBottom = UDim.new(0, 14),
		}),
		NameTag = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 4, 0, -24),
			Size = UDim2.fromOffset(170, 32), BackgroundColor3 = DialogTheme.NameTagColor, ZIndex = 41,
		}, {
			Corner = UIBuilder.Corner(10),
			Stroke = UIBuilder.Stroke(DialogTheme.NameTagColor:Lerp(Color3.new(0, 0, 0), 0.55), 2),
			Label = React.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = props.npcName,
				TextColor3 = DialogTheme.TextColor, Font = Enum.Font.FredokaOne, TextSize = 18, ZIndex = 42,
			}),
		}),
		-- NameTag sits outside the list so its absolute position isn't overridden by the layout.
		Content = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }),
			-- Invisible full-text label reserves the final height so the typewriter doesn't make the panel jitter.
			Body = React.createElement("Frame", {
				LayoutOrder = 1, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			}, {
				Sizer = BodyLabel(props.text, 1, UDim2.fromScale(1, 0), Enum.AutomaticSize.Y),
				Visible = BodyLabel(shownText, 0, UDim2.fromScale(1, 1), Enum.AutomaticSize.None),
			}),
			Options = React.createElement("Frame", {
				LayoutOrder = 2, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1, ZIndex = 41,
			}, {
				Layout = React.createElement("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
				Items = React.createElement(React.Fragment, nil, optionElements),
			}),
		}),
	})
end

return DialogBox
