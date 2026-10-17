-- Lua | Roblox Executor | Kukrin Life | Xeno
-- toggle GUI: P | zamknij: przycisk X na górze
-- funkcje: freeze (stanie w miejscu), wzrost slider

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- state
local frozen = false
local frozenCF = nil
local guiVisible = true

-- cleanup stary gui jeśli był
if gethui and gethui():FindFirstChild("LarpGUI") then
	gethui():FindFirstChild("LarpGUI"):Destroy()
end

-- GUI BUILD
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LarpGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = gethui and gethui() or lp.PlayerGui

-- główne okno
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 320, 0, 260)
main.Position = UDim2.new(0.5, -160, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(18, 12, 28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- topbar
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 38)
topbar.BackgroundColor3 = Color3.fromRGB(28, 18, 42)
topbar.BorderSizePixel = 0
topbar.Parent = main
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🌸 Larp Client"
title.TextColor3 = Color3.fromRGB(255, 180, 220)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

-- przycisk X
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 120)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topbar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- helper: label
local function makeLabel(parent, text, posY)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -28, 0, 20)
	l.Position = UDim2.new(0, 14, 0, posY)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(200, 170, 230)
	l.TextSize = 13
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

-- helper: toggle button
local function makeToggle(parent, labelText, posY, callback)
	makeLabel(parent, labelText, posY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 28)
	btn.Position = UDim2.new(1, -104, 0, posY - 4)
	btn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
	btn.Text = "WYŁĄCZONY"
	btn.TextColor3 = Color3.fromRGB(180, 140, 210)
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local state = false
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = state and "WŁĄCZONY" or "WYŁĄCZONY"
		btn.BackgroundColor3 = state and Color3.fromRGB(200, 80, 140) or Color3.fromRGB(60, 40, 80)
		callback(state)
	end)
	return btn
end

-- FREEZE toggle
makeToggle(main, "Stanie w miejscu", 58, function(on)
	frozen = on
	if on then
		frozenCF = hrp.CFrame
	end
end)

-- WZROST slider
makeLabel(main, "Wzrost", 108)

local sliderBG = Instance.new("Frame")
sliderBG.Size = UDim2.new(1, -28, 0, 10)
sliderBG.Position = UDim2.new(0, 14, 0, 130)
sliderBG.BackgroundColor3 = Color3.fromRGB(40, 28, 58)
sliderBG.BorderSizePixel = 0
sliderBG.Parent = main
Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(0, 6)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(200, 80, 140)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBG
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 6)

local scaleVal = makeLabel(main, "Wzrost: 1.0x", 146)

local dragging = false
sliderBG.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local rel = (i.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X
		rel = math.clamp(rel, 0, 1)
		sliderFill.Size = UDim2.new(rel, 0, 1, 0)
		local scale = 0.5 + rel * 2.5 -- zakres 0.5x do 3.0x
		scaleVal.Text = string.format("Wzrost: %.1fx", scale)
		local bp = Instance.new("BodyPosition") -- nie działa w każdej grze, fallback przez scale
		char:FindFirstChild("BodyScaleModifier") -- placeholder
		-- właściwy scale przez humanoid
		hum.BodyDepthScale.Value = scale
		hum.BodyHeightScale.Value = scale
		hum.BodyWidthScale.Value = scale
		hum.HeadScale.Value = scale
	end
end)

-- separator
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -28, 0, 1)
sep.Position = UDim2.new(0, 14, 0, 170)
sep.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
sep.BorderSizePixel = 0
sep.Parent = main

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -28, 0, 20)
hint.Position = UDim2.new(0, 14, 0, 180)
hint.BackgroundTransparency = 1
hint.Text = "[P] pokaż/ukryj  •  built by @odil9"
hint.TextColor3 = Color3.fromRGB(120, 90, 150)
hint.TextSize = 11
hint.Font = Enum.Font.Gotham
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = main

-- FREEZE loop
RunService.Heartbeat:Connect(function()
	if frozen and frozenCF then
		local ok, _ = pcall(function()
			char = lp.Character
			hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.CFrame = frozenCF end
		end)
	end
end)

-- respawn update
lp.CharacterAdded:Connect(function(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	hrp = c:WaitForChild("HumanoidRootPart")
	frozen = false
	frozenCF = nil
end)

-- toggle P
UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.P then
		guiVisible = not guiVisible
		main.Visible = guiVisible
	end
end)

print("[larp] absolute larp — gui live, P toggle, X close")
