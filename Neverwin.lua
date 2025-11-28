
local NEVERLOSE = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/SourceCludeLib/refs/heads/main/NerverLoseLibEdited.lua"))()

local Window = NEVERLOSE:AddWindow("NEVERWIN","NEVERLOSE V2 CHEAT CSGO",'original', UDim2.new(0, 670, 470, 0))


Window:AddTabLabel('Aimbot')

local Legitbot = Window:AddTab("LegitBot","crosshair")


Window:AddTabLabel("Visual")
local Player  = Window:AddTab("Player","user")
local Weapon  = Window:AddTab("Weapon","gun")
local World   = Window:AddTab("World","earth")


Window:AddTabLabel("Miscellaneous")
local Main = Window:AddTab("Main","gear")
local Scripts = Window:AddTab("Scripts","code")






local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Draw functions
local function DrawCircle(radius, color)
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Color = color
    circle.Thickness = 1
    circle.Transparency = 1
    circle.Radius = radius
    circle.Filled = false
    return circle
end

-- Aimbot state
local AimbotEnabled = false
local DrawFOV = false
local Smooth = 1.1
local Amount = 10
local DynamicFOV = false
local Multiplier = 220 -- Base FOV radius
local HitSelection = "Head"
local PreferHead = false
local PreferBody = false
local BodyIfLethal = true
local BeforeShotDelay = "None"

-- Drawing
local mainCircle = DrawCircle(Multiplier, Color3.fromRGB(255,255,255))

-- Helper functions
local function IsAlive(player)
    return player.Character and player.Character:FindFirstChild("Head") 
        and player.Character:FindFirstChild("Humanoid") 
        and player.Character.Humanoid.Health > 0
end

local function IsVisible(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin)
    local ray = Ray.new(origin, direction)
    local hitPart, _ = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character}, false, true)
    
    if hitPart then
        return target:IsDescendantOf(hitPart.Parent)
    else
        return true
    end
end

local function GetClosestTarget(fov)
    local closest, dist = nil, fov
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr) then
            local teamCheck = (not plr.Team or not LocalPlayer.Team) or (plr.Team ~= LocalPlayer.Team)
            if not teamCheck then continue end

            local head = plr.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X,pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist and IsVisible(head) then
                    dist = mag
                    closest = head
                end
            end
        end
    end
    return closest
end

local function AimAt(target)
    if target then
        local camPos = Camera.CFrame.Position
        local direction = (target.Position - camPos).Unit
        local smoothAlpha = 1 / (Smooth + 1)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(camPos, camPos + direction), smoothAlpha)
    end
end

-- Main loop
RunService.RenderStepped:Connect(function()
    mainCircle.Visible = DrawFOV

    if not AimbotEnabled then return end

    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    mainCircle.Position = center

    -- Dynamic FOV radius
    local radius = (DynamicFOV and Multiplier) or 220
    mainCircle.Radius = radius

    local target = GetClosestTarget(radius)
    if target then
        AimAt(target)
    end
end)

-- Character reset
LocalPlayer.CharacterAdded:Connect(function()
    repeat task.wait() until LocalPlayer.Character
end)

-- UI integration
local g = Legitbot:AddSection('General',"left")
local aim = Legitbot:AddSection('Aim',"left")
local hg = Legitbot:AddSection('Hit Groups',"right")
local wb = Legitbot:AddSection('Wall Bang',"right")

-- General
g:AddToggle('Enable', false, function(val) AimbotEnabled = val end)

g:AddToggle('Draw FOV', false, function(val) DrawFOV = val end)
g:AddDropdown('Before shot delay', {"None", "Combined", "On shot"}, "None", function(val) BeforeShotDelay = val end)
g:AddSlider('Speed', 1, 20, 1.1, function(val) Smooth = val end)
g:AddSlider('Amount', 1, 30, 10, function(val) Amount = val end)

-- Aim
aim:AddToggle('Dynamic FOV', false, function(val) DynamicFOV = val end)
aim:AddSlider('Multiplier', 10, 500, 220, function(val) Multiplier = val end) -- This slider directly sets FOV radius

-- Hit Groups
hg:AddDropdown('Selection', {"Head", "Chest", "Stomach", "All"}, "Head", function(val) HitSelection = val end)
hg:AddToggle('Prefer head aim', false, function(val) PreferHead = val end)
hg:AddToggle('Prefer body aim', false, function(val) PreferBody = val end)
hg:AddToggle('Body aim if lethal', true, function(val) BodyIfLethal = val end)

local x1, x2, x3 = getgc, game, {}
local s1
for _, v in pairs(x1()) do
    if type(v) == "table" and rawget(v, "ClassName") == "Players" then
        s1 = v
        break
    end
end
local s2
for _, v in pairs(x1()) do
    if type(v) == "table" and rawget(v, "ClassName") == "Workspace" then
        s2 = v
        break
    end
end
local p = s1 or x2:GetService("Players")
local w = s2 or x2:GetService("Workspace")
local c = w.CurrentCamera
local l = p.LocalPlayer
local r = x2:GetService("RunService")

local t0 = false
local f0 = 17
local spd = 50
local tm = true

local circ = Drawing.new("Circle")
circ.Visible = false
circ.Color = Color3.fromRGB(255, 0, 0)
circ.Thickness = 1
circ.Radius = f0
circ.Filled = false
circ.Transparency = 1

local function n0()
    local plr = nil
    local dist0 = f0
    for _, v in pairs(p:GetPlayers()) do
        if v ~= l and v.Character and v.Character:FindFirstChild("Head") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if tm and v.Team == l.Team then
                    continue
                end
                local pos, onscreen = c:WorldToViewportPoint(v.Character.Head.Position)
                if onscreen then
                    local mpos = Vector2.new(c.ViewportSize.X / 2, c.ViewportSize.Y / 2)
                    local d = (Vector2.new(pos.X, pos.Y) - mpos).Magnitude
                    if d < dist0 then
                        dist0 = d
                        plr = v
                    end
                end
            end
        end
    end
    return plr
end

r.RenderStepped:Connect(function()
    circ.Position = Vector2.new(c.ViewportSize.X / 2, c.ViewportSize.Y / 2)
    circ.Visible = t0
    if not t0 then return end

    local tgt = n0()
    if tgt and tgt.Character and tgt.Character:FindFirstChild("Head") then
        local tp = tgt.Character.Head.Position
        local dir = (tp - c.CFrame.Position).Unit
        local newcf = CFrame.new(c.CFrame.Position, c.CFrame.Position + dir)
        c.CFrame = c.CFrame:Lerp(newcf, spd / 100)
    end
end)

wb:AddToggle("Wallbang Assist", false, function(v)
    t0 = v
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local crosshairRadius = 2
local crosshairColor = Color3.fromRGB(255, 0, 0)
local crosshairEnabled = false

local crosshair = Drawing.new("Circle")
crosshair.Radius = crosshairRadius
crosshair.Thickness = 1
crosshair.Filled = true
crosshair.Color = crosshairColor
crosshair.Visible = false
crosshair.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Specific objects to detect
local breakableMetal
local specialPart

local map = Workspace:FindFirstChild("Map")
if map then
    local regen = map:FindFirstChild("Regen")
    if regen then
        local props = regen:FindFirstChild("Props")
        if props and #props:GetChildren() >= 2 then
            breakableMetal = props:GetChildren()[2]:FindFirstChild("BreakableMetal")
        end
    end

    local geometry = map:FindFirstChild("Geometry")
    if geometry and #geometry:GetChildren() >= 435 then
        specialPart = geometry:GetChildren()[435]
    end
end

-- Function to update crosshair color
local function updateCrosshair()
    if not crosshairEnabled then
        crosshair.Visible = false
        return
    end

    crosshair.Visible = true
    crosshair.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local mouseRay = Camera:ScreenPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local raycastResult = Workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)

    if raycastResult and raycastResult.Instance then
        local hitPart = raycastResult.Instance
        if hitPart.Name:upper():find("CLIP") or hitPart == breakableMetal or hitPart == specialPart then
            crosshair.Color = Color3.fromRGB(0, 255, 0) -- Green
        else
            crosshair.Color = Color3.fromRGB(255, 0, 0) -- Red
        end
    else
        crosshair.Color = Color3.fromRGB(255, 0, 0)
    end
end

RunService.RenderStepped:Connect(updateCrosshair)

wb:AddToggle("Penetration crosshair", false, function(val)
    crosshairEnabled = val
end)

local Fl = Legitbot:AddSection("Flick", "left")

local a = game:GetService("Workspace")
local b = game:GetService("RunService")
local c = game:GetService("UserInputService")
local d = game:GetService("Players")

local e = a.CurrentCamera
local f = d.LocalPlayer
local g = f:WaitForChild("PlayerGui"):WaitForChild("GUI"):WaitForChild("Mobile"):WaitForChild("Shoot")

local h = false
local i = false
local j = 400 -- FOV value
local flickEnabled = false
local fovCircleEnabled = false
local k = e.CFrame

-- create FOV circle (drawn on screen)
local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.NumSides = 64
circle.Radius = j
circle.Filled = false
circle.Color = Color3.fromRGB(255, 255, 255)
circle.Visible = false

local function l(m)
	if not m or not m:IsA("Player") then return false end
	if not m.Character then return false end
	local n = m.Character:FindFirstChild("Humanoid")
	if not n or n.Health <= 0 then return false end
	if f.Team and m.Team and f.Team == m.Team then return false end
	return true
end

local function o(p)
	local q = RaycastParams.new()
	q.FilterType = Enum.RaycastFilterType.Blacklist
	q.FilterDescendantsInstances = {f.Character, e}
	local r = a:Raycast(e.CFrame.Position, (p.Position - e.CFrame.Position).Unit * 5000, q)
	return r and r.Instance:IsDescendantOf(p.Parent)
end

local function s()
	local t, u = nil, j
	for _, v in pairs(d:GetChildren()) do
		if v ~= f and l(v) then
			local w = v.Character
			if w and w.ClassName == "Model" then
				local x = w:FindFirstChild("Head")
				if x then
					local y, z = e:WorldToViewportPoint(x.Position)
					if z then
						local A = (Vector2.new(y.X, y.Y) - Vector2.new(e.ViewportSize.X / 2, e.ViewportSize.Y / 2)).Magnitude
						if A < u and o(x) then
							t = x
							u = A
						end
					end
				end
			end
		end
	end
	return t
end

local function B()
	if not flickEnabled then return end
	if i then return end
	i = true
	k = e.CFrame
	local C = s()
	if C then
		local D = (C.Position - e.CFrame.Position).Unit
		e.CFrame = CFrame.new(e.CFrame.Position, e.CFrame.Position + D)
	end
	i = false
end

-- Button and input binds
g.MouseEnter:Connect(function()
	h = true
	B()
end)
g.MouseLeave:Connect(function()
	h = false
end)
c.InputBegan:Connect(function(E, F)
	if not F and E.UserInputType == Enum.UserInputType.MouseButton1 then
		h = true
		B()
	end
end)
c.InputEnded:Connect(function(E, F)
	if not F and E.UserInputType == Enum.UserInputType.MouseButton1 then
		h = false
	end
end)
b.RenderStepped:Connect(function()
	if fovCircleEnabled then
		circle.Visible = true
		circle.Radius = j
		local center = Vector2.new(e.ViewportSize.X / 2, e.ViewportSize.Y / 2)
		circle.Position = center
	else
		circle.Visible = false
	end
	if h and flickEnabled then
		B()
	end
end)

-- === UI FUNCTIONS ===
Fl:AddToggle("Enable", false, function(val)
	flickEnabled = val
end)

Fl:AddToggle("Fov circle", false, function(val)
	fovCircleEnabled = val
	circle.Visible = val
end)

Fl:AddSlider("Amount", 1, 400, 400, function(val)
	j = val
	circle.Radius = val
end)

local ESP = Player:AddSection("Esp", "left")


-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- STORAGE
local Boxes = {}
local HealthBars = {}
local Names = {}

-- CREATE ESP FOR PLAYER
local function CreateESP(player)
if player == LocalPlayer then return end
if Boxes[player] then return end

-- BOX  
local box = Drawing.new("Square")  
box.Visible = false  
box.Color = Color3.new(1,1,1)  
box.Thickness = 1  
box.Filled = false  
Boxes[player] = box  

-- HEALTH BAR  
local hp = Drawing.new("Square")  
hp.Visible = false  
hp.Filled = true  
hp.Thickness = 1  
HealthBars[player] = hp  

-- NAME TEXT  
local nameText = Drawing.new("Text")  
nameText.Visible = false  
nameText.Color = Color3.new(1,1,1)  
nameText.Size = 8  
nameText.Center = true  
nameText.Outline = true  
nameText.OutlineColor = Color3.new(0,0,0)  
Names[player] = nameText

end

-- REMOVE ESP ON LEAVE
Players.PlayerRemoving:Connect(function(player)
if Boxes[player] then Boxes[player]:Remove() Boxes[player] = nil end
if HealthBars[player] then HealthBars[player]:Remove() HealthBars[player] = nil end
if Names[player] then Names[player]:Remove() Names[player] = nil end
end)

-- ADD EXISTING PLAYERS
for _, p in ipairs(Players:GetPlayers()) do
CreateESP(p)
end

-- ADD NEW PLAYERS
Players.PlayerAdded:Connect(CreateESP)

-- UPDATE LOOP
RunService.RenderStepped:Connect(function()
for player, box in pairs(Boxes) do
local char = player.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local humanoid = char and char:FindFirstChild("Humanoid")
local hpBar = HealthBars[player]
local nameDraw = Names[player]

-- VALID PLAYER CHECK  
    if root and humanoid and humanoid.Health > 0 then  
        -- TEAM CHECK  
        if _G.ESP_TeamCheck then  
            if player.Team ~= nil and LocalPlayer.Team ~= nil then  
                if player.Team == LocalPlayer.Team then  
                    -- same team = hide ESP  
                    if box then box.Visible = false end  
                    if hpBar then hpBar.Visible = false end  
                    if nameDraw then nameDraw.Visible = false end  
                    continue  
                end  
            end  
        end  

        -- ON SCREEN  
        local rootViewport, onScreen = Camera:WorldToViewportPoint(root.Position)  
        if onScreen then  
            -- TOP / BOTTOM OF PLAYER  
            local topViewport = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, humanoid.HipHeight * 2 + 3, 0))  
            local bottomViewport = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, humanoid.HipHeight * 2 + 3, 0))  

            -- HEIGHT / WIDTH  
            local height = math.abs(bottomViewport.Y - topViewport.Y)  
            if height < 6 then height = 6 end  
            local width = height / 2.3  

            --------------------  
            --    BOX ESP     --  
            --------------------  
            if _G.ESP_Box_Enabled then  
                box.Size = Vector2.new(width, height)  
                box.Position = Vector2.new(rootViewport.X - width/2, rootViewport.Y - height/2)  
                box.Visible = true  
            else  
                box.Visible = false  
            end  

            ------------------------  
            --   HEALTH BAR ESP    --  
            ------------------------  
            if _G.ESP_Health_Enabled then  
                local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)  

                local r = 1 - hpPercent  
                local g = hpPercent  
                hpBar.Color = Color3.new(r, g, 0)  

                local barHeight = height * hpPercent  
                if barHeight < 2 then barHeight = 2 end  

                local barX = (rootViewport.X - width/2) - 3  -- left of box  
                local barY = rootViewport.Y - height/2 + (height - barHeight)  

                hpBar.Size = Vector2.new(2, barHeight)      -- thin health bar  
                hpBar.Position = Vector2.new(barX, barY)  
                hpBar.Visible = true  
            else  
                hpBar.Visible = false  
            end  

            --------------------  
            --   NAME ESP     --  
            --------------------  
            if _G.ESP_Name_Enabled then  
                nameDraw.Text = player.Name  
                nameDraw.Position = Vector2.new(rootViewport.X, (rootViewport.Y - height/2) - 15)  
                nameDraw.Visible = true  
            else  
                nameDraw.Visible = false  
            end  

        else  
            box.Visible = false  
            hpBar.Visible = false  
            nameDraw.Visible = false  
        end  

    else  
        -- DEAD OR NO CHARACTER  
        box.Visible = false  
        if hpBar then hpBar.Visible = false end  
        if nameDraw then nameDraw.Visible = false end  
    end  
end

end)
-- Box ESP
ESP:AddToggle("Box", false, function(val)
    _G.ESP_Box_Enabled = val
end)

-- Health Bar ESP
ESP:AddToggle("Health Bar", false, function(val)
    _G.ESP_Health_Enabled = val
end)

-- Name ESP
ESP:AddToggle("Name", false, function(val)
    _G.ESP_Name_Enabled = val
end)
_G.ESP_TeamCheck = true

-- // Safe service locator
local function SafeGetService(name)
    for _, obj in pairs(getnilinstances()) do
        if obj.ClassName == "Players" then
            return obj
        end
    end
    for _, obj in pairs(game:GetChildren()) do
        if obj.ClassName == "Players" then
            return obj
        end
    end
    return game:FindService(name) or game:GetService(name)
end


local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera

local SkeletonESP = {}
local Enabled = false
local Color = Color3.fromRGB(255, 255, 255)

-- Skeleton lines storage
local SkeletonLines = {}

-- Map dropdown colors
local ColorMap = {
    White = Color3.fromRGB(255, 255, 255),
    Blue = Color3.fromRGB(0, 0, 255),
    Skyblue = Color3.fromRGB(135, 206, 235),
    Pink = Color3.fromRGB(255, 20,255),
    Violet = Color3.fromRGB(148, 0, 211),
    Red = Color3.fromRGB(255, 0, 0),
    Yellow = Color3.fromRGB(255, 255, 0),
    Orange = Color3.fromRGB(255, 165, 0),
    Green = Color3.fromRGB(0, 255, 0),
    Black = Color3.fromRGB(0, 0, 0),
}

-- Skeleton bones for R6 & R15
local R6Bones = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local R15Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"UpperTorso", "RightUpperArm"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"RightLowerArm", "RightHand"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"RightLowerLeg", "RightFoot"},
}

-- Function to create line
local function CreateLine()
    local line = Drawing.new("Line")
    line.Color = Color
    line.Thickness = 1.5
    line.Transparency = 1
    return line
end

-- Update skeleton for a player
local function UpdateSkeleton(plr)
    local char = plr.Character
    if not char or not char:FindFirstChildWhichIsA("Humanoid") then return end

    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    local bones = humanoid.RigType == Enum.HumanoidRigType.R6 and R6Bones or R15Bones

    if not SkeletonLines[plr] then
        SkeletonLines[plr] = {}
        for _, bonePair in ipairs(bones) do
            table.insert(SkeletonLines[plr], CreateLine())
        end
    end

    local lines = SkeletonLines[plr]

    for i, bonePair in ipairs(bones) do
        local part0 = char:FindFirstChild(bonePair[1])
        local part1 = char:FindFirstChild(bonePair[2])
        local line = lines[i]

        if part0 and part1 then
            local p0, onScreen0 = Camera:WorldToViewportPoint(part0.Position)
            local p1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
            if onScreen0 and onScreen1 then
                line.Visible = true
                line.From = Vector2.new(p0.X, p0.Y)
                line.To = Vector2.new(p1.X, p1.Y)
                line.Color = Color
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

-- Remove skeleton lines when player leaves
local function ClearSkeleton(plr)
    if SkeletonLines[plr] then
        for _, line in ipairs(SkeletonLines[plr]) do
            line:Remove()
        end
        SkeletonLines[plr] = nil
    end
end

-- ESP main loop
RunService.RenderStepped:Connect(function()
    if not Enabled then return end
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= LocalPlayer then
            local isEnemy = true
            if LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                isEnemy = false
            end
            if isEnemy then
                UpdateSkeleton(plr)
            else
                ClearSkeleton(plr)
            end
        end
    end
end)

-- Auto-update for player join/leave/respawn
game:GetService("Players").PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if Enabled then
            UpdateSkeleton(plr)
        end
    end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(plr)
    ClearSkeleton(plr)
end)

-- ESP toggles
ESP:AddToggle("Skeleton", false, function(val)
    Enabled = val
    if not val then
        for plr, _ in pairs(SkeletonLines) do
            ClearSkeleton(plr)
        end
    end
end)

ESP:AddDropdown("Colors", { "White","Blue","Skyblue","Pink","Violet","Red","Yellow","Orange","Green","Black" }, "White", function(val)
    Color = ColorMap[val] or Color3.fromRGB(255, 255, 255)
end)

local gl = Player:AddSection("Glow", "left")

-- ======= Settings =======
local GlowEnabled = false
local CurrentChamColor = Color3.fromRGB(255,255,255)

local R6Parts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local R15Parts = {
    "Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot",
    "RightUpperLeg","RightLowerLeg","RightFoot"
}

local ColorMap = {
    Toothpaste = Color3.fromRGB(48,213,200),
    Blue = Color3.fromRGB(0,162,255),
    Green = Color3.fromRGB(0,255,0),
    White = Color3.fromRGB(255,255,255),
    Red = Color3.fromRGB(255,0,0),
    Yellow = Color3.fromRGB(255,255,0),
    Pink = Color3.fromRGB(255,0,255),
    Black = Color3.fromRGB(0,0,0)
}

-- ======= Functions =======
local function createGlow(part)
    if part and not part:FindFirstChild("GlowAura") then
        local aura = Instance.new("ParticleEmitter")
        aura.Name = "GlowAura"
        aura.Texture = "rbxassetid://833874434"
        aura.Color = ColorSequence.new(CurrentChamColor)
        aura.Transparency = NumberSequence.new(0.5)
        aura.LightEmission = 1
        aura.Rate = 26
        aura.Lifetime = NumberRange.new(0.5,1)
        aura.Speed = NumberRange.new(0,0)
        aura.Size = NumberSequence.new(1)
        aura.LockedToPart = true
        aura.ZOffset = 1
        aura.Parent = part
    else
        local aura = part:FindFirstChild("GlowAura")
        if aura then
            aura.Color = ColorSequence.new(CurrentChamColor)
        end
    end
end

local function removeGlow(character)
    if not character then return end
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local aura = part:FindFirstChild("GlowAura")
            if aura then aura:Destroy() end
        end
    end
end

local function applyGlow(character)
    if not GlowEnabled then return end
    if not character:FindFirstChild("Humanoid") then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local rigType = humanoid.RigType == Enum.HumanoidRigType.R6 and R6Parts or R15Parts
    for _, partName in ipairs(rigType) do
        local part = character:FindFirstChild(partName)
        if part then createGlow(part) end
    end
end

local function isEnemy(player, LocalPlayer)
    if player == LocalPlayer then return false end
    if LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    return true
end

local function updateEnemyGlow(player, LocalPlayer)
    if not isEnemy(player, LocalPlayer) then
        removeGlow(player.Character)
        return
    end
    if player.Character then
        applyGlow(player.Character)
        player.Character.ChildAdded:Connect(function(child)
            if GlowEnabled and isEnemy(player, LocalPlayer) and child:IsA("BasePart") then
                createGlow(child)
            end
        end)
    end
    player.CharacterAdded:Connect(function(char)
        if GlowEnabled and isEnemy(player, LocalPlayer) then
            applyGlow(char)
        end
    end)
end

-- ======= Detect LocalPlayer via ClassName =======
local LocalPlayer
for _, obj in ipairs(game:GetDescendants()) do
    if obj.ClassName == "Players" then
        LocalPlayer = obj.LocalPlayer
        break
    end
end
if not LocalPlayer then return end

-- ======= UI Integration =======
gl:AddToggle("Enable glow", false, function(val)
    GlowEnabled = val
    for _, obj in ipairs(game:GetDescendants()) do
        if obj.ClassName == "Player" then
            updateEnemyGlow(obj, LocalPlayer)
        end
    end
end)

gl:AddDropdown("Colors", {"Toothpaste","Blue","Green","White","Red","Yellow","Pink","Black"}, "White", function(val)
    CurrentChamColor = ColorMap[val] or Color3.fromRGB(255,255,255)
    if GlowEnabled then
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.ClassName == "Player" then
                updateEnemyGlow(obj, LocalPlayer)
            end
        end
    end
end)

-- ======= Loop to catch new players =======
spawn(function()
    while true do
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.ClassName == "Player" then
                updateEnemyGlow(obj, LocalPlayer)
            end
        end
        wait(2)
    end
end)

local chm = Player:AddSection("Chams","right")

-- Services using ClassName
local Services = {}
for _, service in pairs(game:GetChildren()) do
    if service.ClassName == "Players" then
        Services.Players = service
    elseif service.ClassName == "Workspace" then
        Services.Workspace = service
    end
end

local LocalPlayer = Services.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Settings
local ChamsEnabled = false
local ChamsColor = Color3.fromRGB(255,255,255)
local ThroughWallsColor = Color3.fromRGB(255,255,255)
local TeamCheckEnabled = true

-- GUI
chm:AddToggle("Enable", false, function(val)
    ChamsEnabled = val
    if not val then
        for _, player in pairs(Services.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("ChamsHighlight") then
                player.Character.ChamsHighlight:Destroy()
            end
        end
    end
end)

chm:AddDropdown("Visible", { "Pink","Blue","Toothpaste","Green","Yellow","Red","Orange","White" }, "White", function(val)
    local colors = {
        Pink = Color3.fromRGB(255,20, 255),
        Blue = Color3.fromRGB(0,0,255),
        Toothpaste = Color3.fromRGB(0,255,255),
        Green = Color3.fromRGB(0,255,0),
        Yellow = Color3.fromRGB(255,255,0),
        Red = Color3.fromRGB(255,0,0),
        Orange = Color3.fromRGB(255,165,0),
        White = Color3.fromRGB(255,255,255)
    }
    ChamsColor = colors[val] or Color3.fromRGB(255,255,255)
end)

chm:AddDropdown("Invisible", { "Pink","Blue","Toothpaste","Green","Yellow","Red","Orange","White" }, "White", function(val)
    local colors = {
        Pink = Color3.fromRGB(255,20,255),
        Blue = Color3.fromRGB(0,0,255),
        Toothpaste = Color3.fromRGB(0,255,255),
        Green = Color3.fromRGB(0,255,0),
        Yellow = Color3.fromRGB(255,255,0),
        Red = Color3.fromRGB(255,0,0),
        Orange = Color3.fromRGB(255,165,0),
        White = Color3.fromRGB(255,255,255)
    }
    ThroughWallsColor = colors[val] or Color3.fromRGB(255,255,255)
end)

-- Check if visible
local function isVisible(part)
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (part.Position - origin).Unit * 9999)
    local hit = Services.Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    return hit and hit:IsDescendantOf(part.Parent)
end

-- Apply chams (one highlight per character)
local function applyChams(player)
    if player == LocalPlayer then return end
    if TeamCheckEnabled and player.Team == LocalPlayer.Team then return end
    local char = player.Character
    if not char then return end

    local highlight = char:FindFirstChild("ChamsHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ChamsHighlight"
        highlight.FillTransparency = 0
        highlight.OutlineTransparency = 1
        highlight.Parent = char
    end

    local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
    if head then
        if isVisible(head) then
            highlight.FillColor = ChamsColor
        else
            highlight.FillColor = ThroughWallsColor
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not ChamsEnabled then return end
    for _, player in pairs(Services.Players:GetPlayers()) do
        applyChams(player)
    end
end)

local wESP = Weapon:AddSection("Esp", "left")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local folder = workspace:WaitForChild("Debris")
local espObjects = {}

local espEnabled = false
local showBox = false
local showName = false
local showDistance = false

local function createESP(part)
	if espObjects[part] then return espObjects[part] end

	local esp = {}

	local box = Drawing.new("Square")
	box.Visible = false
	box.Color = Color3.new(1,1,1)
	box.Thickness = 1
	box.Filled = false
	esp.box = box

	local name = Drawing.new("Text")
	name.Visible = false
	name.Color = Color3.new(1,1,1)
	name.Center = true
	name.Size = 14
	name.Text = part.Name
	esp.name = name

	local distance = Drawing.new("Text")
	distance.Visible = false
	distance.Color = Color3.new(1,1,1)
	distance.Center = true
	distance.Size = 14
	distance.Text = ""
	esp.distance = distance

	espObjects[part] = esp
	return esp
end

RunService.RenderStepped:Connect(function()
	-- Cleanup removed parts
	for part, esp in pairs(espObjects) do
		if not part or not part.Parent then
			esp.box:Remove()
			esp.name:Remove()
			esp.distance:Remove()
			espObjects[part] = nil
		end
	end

	for _, part in pairs(folder:GetChildren()) do
		if not part:IsA("BasePart") then continue end

		local esp = createESP(part)

		if not espEnabled then
			esp.box.Visible = false
			esp.name.Visible = false
			esp.distance.Visible = false
		else
			local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
			if onScreen then
				-- Calculate box size based on part size and distance
				local sizeScale = 500 / (Camera.CFrame.Position - part.Position).Magnitude
				local boxSize = Vector2.new(part.Size.X * sizeScale, part.Size.Y * sizeScale)

				if showBox then
					esp.box.Size = boxSize
					esp.box.Position = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
					esp.box.Visible = true
				else
					esp.box.Visible = false
				end

				if showName then
					esp.name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y/2 - 10)
					esp.name.Visible = true
				else
					esp.name.Visible = false
				end

				if showDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					local dist = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
					esp.distance.Text = string.format("%.1f", dist) .. " studs"
					esp.distance.Position = Vector2.new(pos.X, pos.Y + boxSize.Y/2 + 10)
					esp.distance.Visible = true
				else
					esp.distance.Visible = false
				end
			else
				esp.box.Visible = false
				esp.name.Visible = false
				esp.distance.Visible = false
			end
		end
	end
end)

wESP:AddToggle("Enable", false, function(val)
	espEnabled = val
end)

wESP:AddToggle("Box", false, function(val)
	showBox = val
end)

wESP:AddToggle("Name", false, function(val)
	showName = val
end)

wESP:AddToggle("Distance", false, function(val)
	showDistance = val
end)

local wChm = Weapon:AddSection("Chams", "right")

local folder = workspace:WaitForChild("Debris")

local chamsEnabled = false
local chamsColor = Color3.fromRGB(255, 255, 255)

local colorMap = {
	Pink = Color3.fromRGB(255, 20, 255),
	Blue = Color3.fromRGB(0, 162, 255),
	Toothpaste = Color3.fromRGB(0, 255, 255),
	Green = Color3.fromRGB(0, 255, 0),
	Yellow = Color3.fromRGB(255, 255, 0),
	Red = Color3.fromRGB(255, 0, 0),
	Orange = Color3.fromRGB(255, 165, 0),
	White = Color3.fromRGB(255, 255, 255)
}

-- Apply highlight recursively
local function applyHighlightRecursive(object)
	for _, child in ipairs(object:GetChildren()) do
		if child:IsA("BasePart") then
			local highlight = child:FindFirstChild("herehighlight")
			if not highlight then
				highlight = Instance.new("Highlight")
				highlight.Name = "herehighlight"
				highlight.Adornee = child
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 1
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Parent = child
			end
			highlight.FillColor = chamsColor
			highlight.Enabled = chamsEnabled
		end
		-- Recursive call for nested models
		applyHighlightRecursive(child)
	end
end

-- Update all existing objects
local function updateChams()
	for _, obj in ipairs(folder:GetChildren()) do
		applyHighlightRecursive(obj)
	end
end

-- Auto-apply to new children
folder.ChildAdded:Connect(function(obj)
	applyHighlightRecursive(obj)
end)

-- GUI connections
wChm:AddToggle("Enable chams", false, function(val)
	chamsEnabled = val
	updateChams()
end)

wChm:AddDropdown("Color", { "Pink","Blue","Toothpaste","Green","Yellow","Red","Orange","White" }, "White", function(val)
	chamsColor = colorMap[val] or Color3.fromRGB(255, 255, 255)
	updateChams()
end)

-- Initial apply
updateChams()


local ma = World:AddSection("Main","left")
local fo = World:AddSection("Fog","left")
local wmisc = World:AddSection("Misc","right")


--// Lighting System Script
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

--// Original values
local originalAmbient = Lighting.Ambient
local originalClockTime = Lighting.ClockTime
local originalBrightness = Lighting.Brightness
local fogEnabled = false
local fogStart = 100
local fogEnd = 1000
local nightModeEnabled = false

--// Smooth ambient change
local function setAmbient(color)
    local tween = TweenService:Create(Lighting, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Ambient = color})
    tween:Play()
end

--// Night Mode Toggle
ma:AddToggle("Night mode", false, function(val)
    nightModeEnabled = val
    if val then
        setAmbient(Color3.fromRGB(0, 0, 255))
    else
        setAmbient(originalAmbient)
    end
end)

--// Auto Ambient Update
spawn(function()
    while true do
        if nightModeEnabled then
            Lighting.Ambient = Color3.fromRGB(0, 0, 255)
        else
            originalAmbient = Lighting.Ambient -- Keep track of manual changes
        end
        task.wait(0.1)
    end
end)

--// Clock Time Slider (0–24)
ma:AddSlider("Clock Time", 0, 24, originalClockTime, function(val)
    Lighting.ClockTime = val
end)

--// Exposure Slider (Brightness 1–10)
ma:AddSlider("Exposure", 1, 10, originalBrightness, function(val)
    Lighting.Brightness = val
end)

--// FOG SYSTEM
fo:AddToggle("Enable", false, function(val)
    fogEnabled = val
    if val then
        Lighting.FogStart = fogStart
        Lighting.FogEnd = fogEnd
    else
        Lighting.FogStart = 0
        Lighting.FogEnd = math.huge
    end
end)

fo:AddSlider("Start distance", 1, 10000, fogStart, function(val)
    fogStart = val
    if fogEnabled then
        Lighting.FogStart = fogStart
    end
end)

fo:AddSlider("End distance", 1, 10000, fogEnd, function(val)
    fogEnd = val
    if fogEnabled then
        Lighting.FogEnd = fogEnd
    end
end)

--// Optional: Auto-update ClockTime and Brightness smoothly
spawn(function()
    while true do
        if not nightModeEnabled then
            Lighting.ClockTime = Lighting.ClockTime -- keeps it live if external scripts modify
            Lighting.Brightness = Lighting.Brightness
        end
        task.wait(0.1)
    end
end)

fo:AddSlider("Fog density", 0, 100, 30, function(val)
	if fogEnabled then
		local density = val / 100
		Lighting.FogColor = Color3.fromRGB(120 - val, 120 - val, 130)
		Lighting.FogEnd = fogEnd * (1 - density / 2)
	end
end)

wmisc:AddToggle("No scope crosshair", false, function(val)
    local player = game:GetService("Players").LocalPlayer

    spawn(function()
        while true do
            wait(0.1) -- small delay to avoid performance issues
            local success, innerScope = pcall(function()
                return player:WaitForChild("PlayerGui"):WaitForChild("GUI")
                    :WaitForChild("Crosshairs")
                    :WaitForChild("Scope")
                    :WaitForChild("Scope")
            end)

            if success and innerScope then
                innerScope.Visible = not val
            end
        end
    end)
end)

local Workspace = game:GetService("Workspace")
local removeConnection

wmisc:AddToggle("Remove smoke", false, function(val)
    if val then
        -- Remove existing ones first
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("MeshPart") and part.Name == "Smoke" then
                part:Destroy()
            end
        end

        -- Keep removing new ones
        removeConnection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("MeshPart") and obj.Name == "Smoke" then
                obj:Destroy()
            end
        end)
    else
        -- Stop removing
        if removeConnection then
            removeConnection:Disconnect()
            removeConnection = nil
        end
    end
end)

wmisc:AddToggle("Remove flashbang", false, function(val)
    if val then
        task.spawn(function()
            while val do
                for _, gui in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
                    if gui:IsA("Frame") and (gui.Name == "FlashBang" or gui.Name == "Flashbang" or gui.Name == "flashbang") then
                        gui:Destroy()
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

local movement = Main:AddSection("Movement","left")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local HRP = char:WaitForChild("HumanoidRootPart")

local Movement = {
    AutoJump = false,
    CircleStrafe = false,
    QuickStop = false,
    EdgeJump = false,
    JumpBug = false
}

-----------------------------------------------------
-- PC MOVEMENT KEYS
-----------------------------------------------------
local moveKeys = {W=false, A=false, S=false, D=false}

UserInputService.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.W then moveKeys.W = true end
    if key.KeyCode == Enum.KeyCode.A then moveKeys.A = true end
    if key.KeyCode == Enum.KeyCode.S then moveKeys.S = true end
    if key.KeyCode == Enum.KeyCode.D then moveKeys.D = true end
end)

UserInputService.InputEnded:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.W then moveKeys.W = false end
    if key.KeyCode == Enum.KeyCode.A then moveKeys.A = false end
    if key.KeyCode == Enum.KeyCode.S then moveKeys.S = false end
    if key.KeyCode == Enum.KeyCode.D then moveKeys.D = false end
end)

-----------------------------------------------------
-- MOBILE MOVEMENT (THUMBSTICK)
-----------------------------------------------------
-- Roblox mobile thumbstick exposes movement direction via:
-- Humanoid.MoveDirection (vector3)

local function isMovingMobile()
    return hum.MoveDirection.Magnitude > 0.1 -- detects thumbstick movement
end

-----------------------------------------------------
-- MAIN MOVEMENT LOOP
-----------------------------------------------------
RunService.RenderStepped:Connect(function(dt)

    if not hum or hum.Health <= 0 then return end

    -----------------------------------------------------
    -- AUTO JUMP (PC + MOBILE)
    -----------------------------------------------------
    if Movement.AutoJump then
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end

    -----------------------------------------------------
    -- CIRCLE STRAFE (PC + MOBILE)
    -----------------------------------------------------
    if Movement.CircleStrafe then
        HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(3), 0)
        hum:Move(Vector3.new(1,0,0), true)
    end

    -----------------------------------------------------
    -- QUICK STOP (PC + MOBILE)
    -----------------------------------------------------
    if Movement.QuickStop then
        local usingKeyboard = (moveKeys.W or moveKeys.A or moveKeys.S or moveKeys.D)
        local usingMobile = isMovingMobile()

        if not usingKeyboard and not usingMobile then
            hum:Move(Vector3.new(0,0,0), true)
        end
    end

    -----------------------------------------------------
    -- EDGE JUMP (PC + MOBILE)
    -----------------------------------------------------
    if Movement.EdgeJump then
        local ray = Ray.new(HRP.Position, Vector3.new(0, -5, 0))
        local hit = workspace:FindPartOnRay(ray, char)

        if not hit then
            hum.Jump = true
        end
    end

    -----------------------------------------------------
    -- JUMP BUG (PC + MOBILE)
    -----------------------------------------------------
    if Movement.JumpBug then
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum.HipHeight = 0
            task.wait()
            hum.HipHeight = 0
            hum.Jump = false
        end
    end

end)

movement:AddToggle("Auto Jump", false, function(v) Movement.AutoJump = v end)

--// GLOBALS
getgenv().AirStrafeEnabled = false
getgenv().AirStrafeStrength = 20

--// UI
movement:AddToggle("Auto strafe", false, function(val)
    getgenv().AirStrafeEnabled = val
end)

movement:AddSlider("Smoothing", 1, 200, 20, function(val)
    getgenv().AirStrafeStrength = val
end)

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    if not getgenv().AirStrafeEnabled then return end

    local character = LocalPlayer.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")

    if not rootPart or not humanoid then return end

    -- MUST be in the air
    if humanoid.FloorMaterial == Enum.Material.Air then
        local moveDir = humanoid.MoveDirection

        if moveDir.Magnitude > 0 then
            -- YOUR EXACT AIR STRAFE SYSTEM
            rootPart.Velocity = Vector3.new(
                moveDir.X * getgenv().AirStrafeStrength,
                rootPart.Velocity.Y,
                moveDir.Z * getgenv().AirStrafeStrength
            )
        end
    end
end)

movement:AddToggle("Circle Strafe", false, function(v) Movement.CircleStrafe = v end)
movement:AddToggle("Quick Stop", false, function(v) Movement.QuickStop = v end)
movement:AddToggle("Edge Jump", false, function(v) Movement.EdgeJump = v end)
movement:AddToggle("Jump Bug", false, function(v) Movement.JumpBug = v end)

local snd = Main:AddSection("Others","right")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Anti Untrusted Toggle
snd:AddToggle("Anti Untrusted", false, function(val)
    -- Anti Untrusted logic here
end)

-- Filter server ads Toggle
snd:AddToggle("Filter server ads", false, function(val)
    -- Server ad filtering logic here
end)

-- Filter Console Toggle
snd:AddToggle("Filter Console", false, function(val)
    if val then
        local oldprint = print
        getgenv().FilteredPrint = function(...)
            local msg = table.concat({...}, " ")
            if not msg:match("useless message pattern") then
                oldprint(...)
            end
        end
        print = getgenv().FilteredPrint
    else
        if getgenv().FilteredPrint then
            print = print
        end
    end
end)

-- Unlock Cvars Toggle
snd:AddToggle("Unlock Cvars", false, function(val)
    -- Unlock hidden cvars logic here
end)

-- Fake Ping Slider
snd:AddSlider("Fake Ping", 0, 300, 50, function(val)
    getgenv().FakePingValue = val
end)


local script = Scripts:AddSection("Activation","left")

script:AddButton("Activate", function()

script:Hide()

function AddScript(Name, Date, position, RunButtonCallback)
    -- Main script frame
    local Script1 = Instance.new('Frame')
    Script1.Name = Name or "Script"
    Script1.Position = position
    Script1.Size = UDim2.new(0.9599997401237488,0,0.08999998867511749,0)
    Script1.AnchorPoint = Vector2.new(0,0)
    Script1.BackgroundColor3 = Color3.fromRGB(15,15,15)
    Script1.BorderSizePixel = 0
    Script1.ZIndex = 11
    Script1.Parent = game:GetService("CoreGui").NEVERLOSE.Frame.TabHose:GetChildren()[6]

    -- Created label
    local Created = Instance.new('TextLabel')
    Created.Name = "Date"
    Created.Position = UDim2.new(0.10000000149011612,0,0.5,0)
    Created.Size = UDim2.new(0.10000071674585342,0,0.4000001549720764,0)
    Created.AnchorPoint = Vector2.new(0,0)
    Created.BackgroundTransparency = 1
    Created.Text = Date
    Created.TextColor3 = Color3.fromRGB(0,170,255)
    Created.TextScaled = true
    Created.Font = Enum.Font.ArialBold
    Created.ZIndex = 11
    Created.TextXAlignment = Enum.TextXAlignment.Left
    Created.Parent = Script1

    -- Corner & stroke
    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0,3)
    UICorner.Parent = Script1

    local UIStroke = Instance.new('UIStroke')
    UIStroke.Color = Color3.fromRGB(26,26,26)
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    UIStroke.Parent = Script1

    -- Name label
    local Label = Instance.new('TextLabel')
    Label.Name = "Label"
    Label.Position = UDim2.new(0,0,0,0)
    Label.Size = UDim2.new(0.4,0,0.4,0)
    Label.BackgroundTransparency = 1
    Label.Text = Name
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.TextScaled = true
    Label.Font = Enum.Font.ArialBold
    Label.ZIndex = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Script1

    -- Created label text
    local Created_2 = Instance.new('TextLabel')
    Created_2.Name = "Created"
    Created_2.Position = UDim2.new(0,0,0.5,0)
    Created_2.Size = UDim2.new(0.1,0,0.4,0)
    Created_2.BackgroundTransparency = 1
    Created_2.Text = "Created:"
    Created_2.TextColor3 = Color3.fromRGB(160,160,160)
    Created_2.TextScaled = true
    Created_2.Font = Enum.Font.ArialBold
    Created_2.ZIndex = 11
    Created_2.TextXAlignment = Enum.TextXAlignment.Left
    Created_2.Parent = Script1

    -- Run frame
    local Run = Instance.new('Frame')
    Run.Name = "Run"
    Run.Position = UDim2.new(0.78,0,0.19,0)
    Run.Size = UDim2.new(0.2,0,0.63,0)
    Run.BackgroundColor3 = Color3.fromRGB(19,176,243)
    Run.ZIndex = 11
    Run.Parent = Script1

    local UICorner_2 = Instance.new('UICorner')
    UICorner_2.CornerRadius = UDim.new(0,3)
    UICorner_2.Parent = Run

    -- Run icon
    local RunIcon = Instance.new('ImageLabel')
    RunIcon.Name = "RunIcon"
    RunIcon.Position = UDim2.new(0.05,0,0.06,0)
    RunIcon.Size = UDim2.new(0.3,0,0.78,0)
    RunIcon.BackgroundTransparency = 1
    RunIcon.Image = "rbxassetid://101432810803389"
    RunIcon.ImageColor3 = Color3.fromRGB(255,255,255)
    RunIcon.ZIndex = 12
    RunIcon.Parent = Run

    -- Run text
    local Text = Instance.new('TextLabel')
    Text.Name = "Text"
    Text.Position = UDim2.new(0.4,0,0.1,0)
    Text.Size = UDim2.new(0.4,0,0.8,0)
    Text.BackgroundTransparency = 1
    Text.Text = "Load"
    Text.TextColor3 = Color3.fromRGB(255,255,255)
    Text.TextScaled = true
    Text.Font = Enum.Font.ArialBold
    Text.ZIndex = 12
    Text.Parent = Run

    -- Run button
    local RunButton = Instance.new('TextButton')
    RunButton.Name = "RunButton"
    RunButton.Size = UDim2.new(1,0,1,0)
    RunButton.BackgroundTransparency = 1
    RunButton.Text = ""
    RunButton.ZIndex = 13
    RunButton.Parent = Run

    RunButton.MouseButton1Click:Connect(function()
    if RunButtonCallback then
        RunButtonCallback()  -- call the function you passed in
    end
end)

end

-- Example usage:
AddScript("Best legit config", "11/27/25", UDim2.new(0.02,0,0.01,0), function()

-- Aimbot / Legitbot
AimbotEnabled = true
DrawFOV = false
Smooth = 9
Amount = 30
DynamicFOV = false
Multiplier = 220
HitSelection = "Head"
PreferHead = true
PreferBody = false
BodyIfLethal = true
BeforeShotDelay = "None"

-- Wallbang Assist
t0 = true
f0 = 17
spd = 50
tm = true

-- Crosshair (penetration detection)
crosshairEnabled = true
crosshairRadius = 2
crosshairColor = Color3.fromRGB(255, 0, 0)

-- Flickbot
flickEnabled = true
fovCircleEnabled = true
j = 100  -- Flick FOV

-- ESP
_G.ESP_Box_Enabled = true
_G.ESP_Health_Enabled = true
_G.ESP_Name_Enabled = true
_G.ESP_TeamCheck = true

-- Skeleton ESP
Enabled = true
Color = Color3.fromRGB(255, 0, 255)

-- Glow ESP
GlowEnabled = true
CurrentChamColor = Color3.fromRGB(255,0,255)

-- Chams (Player)
ChamsEnabled = true
ChamsColor = Color3.fromRGB(255,0,255)
ThroughWallsColor = Color3.fromRGB(255,255,255)
TeamCheckEnabled = true

-- Weapon ESP
espEnabled = true
showBox = false
showName = true
showDistance = false

-- Weapon Chams
chamsEnabled = true
chamsColor = Color3.fromRGB(255,0,255)

-- Lighting / World
nightModeEnabled = true
originalAmbient = game:GetService("Lighting").Ambient
originalClockTime = game:GetService("Lighting").ClockTime
originalBrightness = game:GetService("Lighting").Brightness
fogEnabled = false
fogStart = 100
fogEnd = 1000

-- Movement
Movement = {
    AutoJump = false,
    CircleStrafe = false,
    QuickStop = true,
    EdgeJump = true,
    JumpBug = false
}

-- Auto Strafe
getgenv().AirStrafeEnabled = true
getgenv().AirStrafeStrength = 23

-- Misc / Scripts tab
getgenv().FakePingValue = 50
getgenv().FilteredPrint = nil

-- Toggles under wmisc
NoScopeCrosshair = true
RemoveSmoke = true

-- Flashbang removal
RemoveFlashbang = true
    
end)

-- Additional scripts, stacked below the first
AddScript("Legit no miss cheat", "11/27/26", UDim2.new(0.02000000700354576,0,0.12,0), function()

-- Aimbot / Legitbot
AimbotEnabled = true
DrawFOV = false
Smooth = 1
Amount = 30
DynamicFOV = false
Multiplier = 220
HitSelection = "Head"
PreferHead = true
PreferBody = false
BodyIfLethal = true
BeforeShotDelay = "None"

-- Wallbang Assist
t0 = true
f0 = 17
spd = 50
tm = true

-- Crosshair (penetration detection)
crosshairEnabled = true
crosshairRadius = 2
crosshairColor = Color3.fromRGB(255, 0, 0)

-- Flickbot
flickEnabled = false
fovCircleEnabled = false
j = 220  -- Flick FOV

-- ESP
_G.ESP_Box_Enabled = true
_G.ESP_Health_Enabled = true
_G.ESP_Name_Enabled = true
_G.ESP_TeamCheck = true

-- Skeleton ESP
Enabled = true
Color = Color3.fromRGB(255, 0, 255)

-- Glow ESP
GlowEnabled = true
CurrentChamColor = Color3.fromRGB(255,0,255)

-- Chams (Player)
ChamsEnabled = true
ChamsColor = Color3.fromRGB(255,0,255)
ThroughWallsColor = Color3.fromRGB(255,255,255)
TeamCheckEnabled = true

-- Weapon ESP
espEnabled = true
showBox = false
showName = true
showDistance = false

-- Weapon Chams
chamsEnabled = true
chamsColor = Color3.fromRGB(255,0,255)

-- Lighting / World
nightModeEnabled = true
originalAmbient = game:GetService("Lighting").Ambient
originalClockTime = game:GetService("Lighting").ClockTime
originalBrightness = game:GetService("Lighting").Brightness
fogEnabled = false
fogStart = 100
fogEnd = 1000

-- Movement
Movement = {
    AutoJump = false,
    CircleStrafe = false,
    QuickStop = true,
    EdgeJump = true,
    JumpBug = false
}

-- Auto Strafe
getgenv().AirStrafeEnabled = true
getgenv().AirStrafeStrength = 23

-- Misc / Scripts tab
getgenv().FakePingValue = 50
getgenv().FilteredPrint = nil

-- Toggles under wmisc
NoScopeCrosshair = true
RemoveSmoke = true

-- Flashbang removal
RemoveFlashbang = true
    
end)

AddScript("Hvh legit", "11/27/27", UDim2.new(0.02000000700354576,0,0.23,0), function()
    -- Aimbot / Legitbot
AimbotEnabled = true
DrawFOV = false
Smooth = 5
Amount = 30
DynamicFOV = false
Multiplier = 220
HitSelection = "Head"
PreferHead = true
PreferBody = false
BodyIfLethal = true
BeforeShotDelay = "None"

-- Wallbang Assist
t0 = true
f0 = 17
spd = 50
tm = true

-- Crosshair (penetration detection)
crosshairEnabled = true
crosshairRadius = 2
crosshairColor = Color3.fromRGB(255, 0, 0)

-- Flickbot
flickEnabled = true
fovCircleEnabled = false
j = 400  -- Flick FOV

-- ESP
_G.ESP_Box_Enabled = true
_G.ESP_Health_Enabled = true
_G.ESP_Name_Enabled = true
_G.ESP_TeamCheck = true

-- Skeleton ESP
Enabled = true
Color = Color3.fromRGB(255, 0, 255)

-- Glow ESP
GlowEnabled = true
CurrentChamColor = Color3.fromRGB(255,0,255)

-- Chams (Player)
ChamsEnabled = true
ChamsColor = Color3.fromRGB(255,0,255)
ThroughWallsColor = Color3.fromRGB(255,255,255)
TeamCheckEnabled = true

-- Weapon ESP
espEnabled = true
showBox = false
showName = true
showDistance = false

-- Weapon Chams
chamsEnabled = true
chamsColor = Color3.fromRGB(255,0,255)

-- Lighting / World
nightModeEnabled = true
originalAmbient = game:GetService("Lighting").Ambient
originalClockTime = game:GetService("Lighting").ClockTime
originalBrightness = game:GetService("Lighting").Brightness
fogEnabled = false
fogStart = 100
fogEnd = 1000

-- Movement
Movement = {
    AutoJump = true,
    CircleStrafe = false,
    QuickStop = true,
    EdgeJump = true,
    JumpBug = false
}

-- Auto Strafe
getgenv().AirStrafeEnabled = true
getgenv().AirStrafeStrength = 90

-- Misc / Scripts tab
getgenv().FakePingValue = 50
getgenv().FilteredPrint = nil

-- Toggles under wmisc
NoScopeCrosshair = true
RemoveSmoke = true

-- Flashbang removal
RemoveFlashbang = true
end)
end)
