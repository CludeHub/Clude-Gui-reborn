

local NEVERLOSE = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/SourceCludeLib/refs/heads/main/NerverLoseLibEdited.lua"))()

local Window = NEVERLOSE:AddWindow("NEVERWIN","NEVERLOSE V2 CHEAT CSGO",'original')

local UserInputService = game:GetService("UserInputService")
local Frame = game.CoreGui:WaitForChild("NEVERLOSE"):WaitForChild("Frame")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ignore if typing in chat or GUI
    if input.KeyCode == Enum.KeyCode.H then
        Frame.Visible = not Frame.Visible
    end
end)


Window:AddTabLabel('Aimbot')

local Legitbot = Window:AddTab("LegitBot","crosshair")


Window:AddTabLabel("Visual")
local Player  = Window:AddTab("Player","user")
local Weapon  = Window:AddTab("Weapon","gun")
local World   = Window:AddTab("World","earth")

Window:AddTabLabel("Miscellaneous")
local Main = Window:AddTab("Main","gear")
local Scripts = Window:AddTab("Scripts","code")



do

local camera = Main:AddSection("Camera","left")

local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local CAMERA_RANGE = 10 -- default distance
local Enabled = false


local REMOVE_HANDS = true
local function ForceThirdPersonCamera()
    if not Enabled then return end

    local PlayerArms = Camera:FindFirstChild("Arms")
    
    if PlayerArms and REMOVE_HANDS then
        for _, part in ipairs(PlayerArms:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                if part.Name == "StatClock" then 
                    part:ClearAllChildren()
                end
                part.Transparency = 1
            end
        end
    end

    LocalPlayer.CameraMaxZoomDistance = CAMERA_RANGE
    LocalPlayer.CameraMinZoomDistance = CAMERA_RANGE
end

RunService.RenderStepped:Connect(ForceThirdPersonCamera)

-- GUI Integration
camera:AddToggle("Enable thirdperson", false, function(val)
    Enabled = val
end)

camera:AddSlider("Distance", 5, 20, CAMERA_RANGE, function(val)
    CAMERA_RANGE = val
end)


local gameService = game
local workspaceService = workspace
local players = game:GetService("Players")

local localPlayer = players.LocalPlayer
local cam = workspaceService.CurrentCamera

-- Aimbot prediction constants
local bulletSpeed = 3000
local gravity = 196.2
local maxRange = 1500
local accuracy = 0
local predictionMultiplier = 1

-- Teleport spin vars
local spinAngle = 0
local radius = 7
local speed = 10

-- Settings
local settings = {
    INSTANT_TP = true,
    FLOAT_HEIGHT = 1,
    BACK_DISTANCE = 1,
    AIMBOT_ACTIVE = true,
    UPDATE_RATE = 0.001,
    BYPASS_PHYSICS = true,
    NOCLIP_ENABLED = true,
    AIMBOT_PART = "Head"
}

-- Noclip Module
local noclip = {}

function noclip:enable_noclip(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    char.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then
            child.CanCollide = false
        end
    end)
end

-- Disable world collisions
function noclip:disable_world_collision()
    local function disable(part)
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    workspaceService.ChildAdded:Connect(function(child)
        disable(child)
    end)

    for _, part in ipairs(workspaceService:GetChildren()) do
        disable(part)
    end
end


-- Kill physics module
local physics = {}

function physics:kill_character_physics(char)
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Velocity = Vector3.new(0,0,0)
            part.RotVelocity = Vector3.new(0,0,0)
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum.AutoRotate = false
        hum.JumpPower = 0
        hum.WalkSpeed = 0
    end
end

-- Enemy finder
local enemy = {}

function enemy:get_enemies()
    local list = {}
    local myChar = localPlayer.Character
    if not myChar then return list end

    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return list end

    for _, plr in ipairs(players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            -- Team check
            local alive = true
            if localPlayer.Team and plr.Team then
                if localPlayer.Team == plr.Team then
                    alive = false
                end
            end

            if alive then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local head = plr.Character:FindFirstChild("Head")
                local vel = root and root.AssemblyLinearVelocity or Vector3.new(0,0,0)

                if root and hum and head and hum.Health > 0 then
                    table.insert(list, {
                        player = plr,
                        root = root,
                        head = head,
                        humanoid = hum,
                        velocity = vel,
                        distance = (myRoot.Position - root.Position).Magnitude
                    })
                end
            end
        end
    end

    table.sort(list, function(a,b) return a.distance < b.distance end)
    return list
end

-- Instant TP
function enemy:instant_teleport(pos)
    if not pos then return false end

    local char = localPlayer.Character
    if not char then return false end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    root.CFrame = CFrame.new(pos)
    root.Velocity = Vector3.new(0,0,0)
    root.RotVelocity = Vector3.new(0,0,0)

    return true
end


-- Prediction module
local aim = {}

function aim:predict(startPos, targetPos, targetVel, speed, grav)
    local iterations = 20
    local time = (targetPos - startPos).Magnitude / speed
    local result = targetPos

    for i = 1, iterations do
        local predicted = targetPos + targetVel * time
        local drop = 0.5 * grav * time^2
        predicted = predicted - Vector3.new(0, drop, 0)

        local newTime = (predicted - startPos).Magnitude / speed
        if math.abs(newTime - time) < 0.001 then
            result = predicted
            break
        end

        time = newTime
        result = predicted
    end

    return result
end

function aim:get_target_part(enemyData)
    if settings.AIMBOT_PART == "Head" then
        return enemyData.head
    else
        return enemyData.root
    end
end

function aim:update()
    if not settings.AIMBOT_ACTIVE then return end
    local char = localPlayer.Character
    if not char then return end

    local enemies = enemy:get_enemies()
    if #enemies == 0 then return end

    local targetData = enemies[1]
    local targetPart = aim:get_target_part(targetData)

    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not targetPart or not myRoot then return end

    if targetData.humanoid.Health <= 0 then return end
    if targetData.distance > maxRange then return end

    local shooterPos = cam.CFrame.Position
    local targetPos = targetPart.Position

    local predicted = aim:predict(shooterPos, targetPos, targetData.velocity, bulletSpeed, gravity)

    -- small right offset
    local offset = cam.CFrame.RightVector * (predictionMultiplier * accuracy)
    predicted += offset

    cam.CFrame = CFrame.new(shooterPos, predicted)
end


-- Updating loops
local aimbotConnection = nil
local tpLoop = nil

local function startAimbot()
    if aimbotConnection then return end
    aimbotConnection = game:GetService("RunService").Stepped:Connect(function()
        if settings.AIMBOT_ACTIVE then
            aim:update()
        end
    end)
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

local function startTP()
    if tpLoop then return end
    startAimbot()

    tpLoop = task.spawn(function()
        while task.wait(settings.UPDATE_RATE) do
            if not tpLoop then break end

            local enemies = enemy:get_enemies()
            if #enemies > 0 then
                local data = enemies[1]
                local root = data.root

                if root and data.humanoid.Health > 0 then
                    spinAngle += settings.UPDATE_RATE * speed

                    local x = root.Position.X
                    local y = root.Position.Y + settings.FLOAT_HEIGHT
                    local z = root.Position.Z

                    local orbitX = x + radius * math.cos(spinAngle)
                    local orbitZ = z + radius * math.sin(spinAngle)

                    enemy:instant_teleport(Vector3.new(orbitX, y, orbitZ))
                end
            end
        end
    end)
end

local function stopTP()
    stopAimbot()
    tpLoop = nil
end


-- Character setup
local function setupChar(char)
    task.wait(1)
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")

    if root and hum then
        physics:kill_character_physics(char)
        noclip:enable_noclip(char)

        hum.PlatformStand = true
        hum.AutoRotate = false
    end
end

local function init()
    noclip:disable_world_collision()

    if localPlayer.Character then
        setupChar(localPlayer.Character)
    end

    localPlayer.CharacterAdded:Connect(setupChar)
end

init()




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


local enabled = false

g:AddToggle("Kill all", false, function(val)
enabled = not enabled

    if enabled then
        
        startTP()
    else
        
        stopTP()
    end

end)

local SilentAimConnection
local OldNameCall
local Hooked = false

local FOV = 600
local silentAim = false

g:AddToggle("Silent aim", false, function(val)
	silentAim = val
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer
	local Camera = workspace.CurrentCamera
	local Mouse = LocalPlayer:GetMouse()
	local BodyPart = nil

	local function WTS(Object)
		local ObjectVector = Camera:WorldToScreenPoint(Object.Position)
		return Vector2.new(ObjectVector.X, ObjectVector.Y)
	end

	local function PositionToRay(Origin, Target)
		return Ray.new(Origin, (Target - Origin).Unit * 600)
	end

	local function MousePositionToVector2()
		return Vector2.new(Mouse.X, Mouse.Y)
	end

	local function IsOnScreen(Object)
		local OnScreen, _ = Camera:WorldToScreenPoint(Object.Position)
		return OnScreen
	end

	local function IsVisible(Head)
		local RayOrigin = Camera.CFrame.Position
		local RayDirection = (Head.Position - RayOrigin).Unit * 600
		local RaycastParams = RaycastParams.new()
		RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

		local Result = workspace:Raycast(RayOrigin, RayDirection, RaycastParams)
		if Result then
			local hitPart = Result.Instance
			-- if we hit wall (CLIP or BreakMetal), stop visibility
			if hitPart.Name == "CLIP" or hitPart.Name == "BreakMetal" then
				return false
			end
			return hitPart:IsDescendantOf(Head.Parent)
		end
		return false
	end

	local function GetClosestHeadFromCursor()
		local ClosestDistance = math.huge
		BodyPart = nil
		for _, Player in pairs(Players:GetPlayers()) do
			if Player ~= LocalPlayer and Player.Team ~= LocalPlayer.Team and Player.Character and Player.Character:FindFirstChild("Humanoid") then
				local Humanoid = Player.Character:FindFirstChild("Humanoid")
				local Head = Player.Character:FindFirstChild("Head")
				if Humanoid and Humanoid.Health > 0 and Head and IsOnScreen(Head) and IsVisible(Head) then
					local Distance = (WTS(Head) - MousePositionToVector2()).Magnitude
					if Distance < ClosestDistance and Distance <= FOV then
						ClosestDistance = Distance
						BodyPart = Head
					end
				end
			end
		end
	end

	if silentAim then
		SilentAimConnection = RunService:BindToRenderStep("DynamicSilentAim", 120, GetClosestHeadFromCursor)

		if not Hooked then
			Hooked = true
			OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
				local Method = getnamecallmethod()
				local Args = {...}
				if Method == "FindPartOnRayWithIgnoreList" and BodyPart then
					Args[1] = PositionToRay(Camera.CFrame.Position, BodyPart.Position)
					return OldNameCall(Self, unpack(Args))
				end
				return OldNameCall(Self, ...)
			end)
		end
	else
		if SilentAimConnection then
			RunService:UnbindFromRenderStep("DynamicSilentAim")
			SilentAimConnection = nil
		end
	end
end)

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
end

do
local recoil = Legitbot:AddSection("Exploit","right")

local g = recoil

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local originalSpreads = {}
local norecoil = false
local spreads = 0

g:AddToggle("No recoil", false, function(state)
    norecoil = state

    for _, weapon in pairs(ReplicatedStorage.Weapons:GetChildren()) do
        local spread = weapon:FindFirstChild("Spread")
        if spread then

            if state then
                -- Save original values once
                if not originalSpreads[weapon.Name] then
                    originalSpreads[weapon.Name] = {
                        SpreadValue = spread.Value,
                        Children = {}
                    }

                    for _, v in pairs(spread:GetChildren()) do
                        originalSpreads[weapon.Name].Children[v.Name] = v.Value
                    end
                end

                -- Apply modified spread
                spread.Value = spreads
                for _, v in pairs(spread:GetChildren()) do
                    v.Value = 0
                end

            else
                -- Restore original values
                local data = originalSpreads[weapon.Name]
                if data then
                    spread.Value = data.SpreadValue
                    for _, v in pairs(spread:GetChildren()) do
                        if data.Children[v.Name] then
                            v.Value = data.Children[v.Name]
                        end
                    end
                end
            end
        end
    end
end)


-- SLIDER
g:AddSlider("Spread", 0, 73.4, 73.4, function(val)
    spreads = val

    -- If recoil is ON, apply instantly
    if norecoil then
        for _, weapon in pairs(ReplicatedStorage.Weapons:GetChildren()) do
            local spread = weapon:FindFirstChild("Spread")
            if spread then
                spread.Value = spreads
                for _, v in pairs(spread:GetChildren()) do
                    v.Value = 0
                end
            end
        end
    end
end)


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local originalAmmo = {}
local infiniteAmmo = false

g:AddToggle("Infinite Ammo", false, function(state)
    infiniteAmmo = state

    for _, weapon in pairs(ReplicatedStorage.Weapons:GetChildren()) do
        if weapon:FindFirstChild("Ammo") then
            if state then
                -- Save original ammo if not already saved
                if not originalAmmo[weapon.Name] then
                    originalAmmo[weapon.Name] = weapon.Ammo.Value
                end
                weapon.Ammo.Value = 99999999
            else
                -- Restore original ammo
                if originalAmmo[weapon.Name] then
                    weapon.Ammo.Value = originalAmmo[weapon.Name]
                end
            end
        end
    end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local originalFireRates = {}
local noFireRate = false

g:AddToggle("Rapid fire", false, function(state)
    noFireRate = state

    for _, weapon in pairs(ReplicatedStorage.Weapons:GetChildren()) do
        if weapon:FindFirstChild("FireRate") then
            if state then
                -- Save original FireRate if not already saved
                if not originalFireRates[weapon.Name] then
                    originalFireRates[weapon.Name] = weapon.FireRate.Value
                end
                weapon.FireRate.Value = 0
            else
                -- Restore original FireRate
                if originalFireRates[weapon.Name] then
                    weapon.FireRate.Value = originalFireRates[weapon.Name]
                end
            end
        end
    end
end)

g:AddSlider("Weapon Bullets", 1,50, 1, function(val)
    local weapons = game:GetService("ReplicatedStorage").Weapons

    for _, weapon in pairs(weapons:GetChildren()) do
        if weapon:FindFirstChild("Bullets") then
            weapon.Bullets.Value = val
        end
    end
end)

end
do
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

local Boxes, HealthBars, Names = {}, {}, {}

-- CONFIG DEFAULTS
_G.ESP_TeamCheck = true
_G.ESP_Box_Enabled = false
_G.ESP_Health_Enabled = false
_G.ESP_Name_Enabled = false
_G.ESP_MaxDistance = 500 -- how far ESP shows

local function CreateESP(player)
    if player == LocalPlayer then return end
    if Boxes[player] then return end

    Boxes[player] = Drawing.new("Square")
    Boxes[player].Thickness = 1
    Boxes[player].Filled = false
    Boxes[player].Visible = false
    Boxes[player].Color = Color3.fromRGB(255,255,255)

    HealthBars[player] = Drawing.new("Square")
    HealthBars[player].Filled = true
    HealthBars[player].Visible = false

    Names[player] = Drawing.new("Text")
    Names[player].Size = 8
    Names[player].Center = true
    Names[player].Outline = true
    Names[player].OutlineColor = Color3.new(0,0,0)
    Names[player].Visible = false
end

local function RemoveESP(player)
    if Boxes[player] then Boxes[player]:Remove() Boxes[player] = nil end
    if HealthBars[player] then HealthBars[player]:Remove() HealthBars[player] = nil end
    if Names[player] then Names[player]:Remove() Names[player] = nil end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

local tickLimiter = 0
RunService.RenderStepped:Connect(function(dt)
    tickLimiter += dt
    if tickLimiter < 0.05 then return end -- updates 20x per second (smooth & lag-free)
    tickLimiter = 0

    for player, box in pairs(Boxes) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local hpBar = HealthBars[player]
        local nameDraw = Names[player]

        if not (root and humanoid and humanoid.Health > 0) then
            box.Visible, hpBar.Visible, nameDraw.Visible = false,false,false
            continue
        end

        if _G.ESP_TeamCheck and player.Team == LocalPlayer.Team then
            box.Visible, hpBar.Visible, nameDraw.Visible = false,false,false
            continue
        end

        local distance = (root.Position - Camera.CFrame.Position).Magnitude
        if distance > _G.ESP_MaxDistance then
            box.Visible, hpBar.Visible, nameDraw.Visible = false,false,false
            continue
        end

        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            box.Visible, hpBar.Visible, nameDraw.Visible = false,false,false
            continue
        end

        local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local height = math.abs(bottom.Y - top.Y)
        local width = height / 2.3

        if _G.ESP_Box_Enabled then
            box.Size = Vector2.new(width, height)
            box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
            box.Visible = true
        else
            box.Visible = false
        end

        if _G.ESP_Health_Enabled then
            local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            hpBar.Color = Color3.fromRGB(255 - (hpPercent * 255), hpPercent * 255, 0)
            local barHeight = height * hpPercent
            local barX = (rootPos.X - width/2) - 3
            local barY = rootPos.Y - height/2 + (height - barHeight)
            hpBar.Size = Vector2.new(2, barHeight)
            hpBar.Position = Vector2.new(barX, barY)
            hpBar.Visible = true
        else
            hpBar.Visible = false
        end

        if _G.ESP_Name_Enabled then
            nameDraw.Text = player.Name
            nameDraw.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 12)
            nameDraw.Visible = true
        else
            nameDraw.Visible = false
        end
    end
end)

-- 🟢 UI TOGGLES (same as your old code)
ESP:AddToggle("Box", false, function(val)
    _G.ESP_Box_Enabled = val
end)

ESP:AddToggle("Health Bar", false, function(val)
    _G.ESP_Health_Enabled = val
end)

ESP:AddToggle("Name", false, function(val)
    _G.ESP_Name_Enabled = val
end)

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

-- Cache
local Highlights = {}

-- GUI setup (you can keep your chm:AddToggle / AddDropdown as-is)
chm:AddToggle("Enable", false, function(val)
    ChamsEnabled = val
    if not val then
        for _, h in pairs(Highlights) do
            if h and h.Parent then h:Destroy() end
        end
        Highlights = {}
    end
end)

chm:AddDropdown("Visible", { "Pink","Blue","Toothpaste","Green","Yellow","Red","Orange","White" }, "White", function(val)
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

-- Visibility check (used less often)
local function isVisible(part)
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (part.Position - origin).Unit * 9999)
    local hit = Services.Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    return hit and hit:IsDescendantOf(part.Parent)
end

-- Create highlight once
local function createHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ChamsHighlight"
    highlight.FillTransparency = 0
    highlight.OutlineTransparency = 1
    highlight.Parent = character
    return highlight
end

-- Refresh every 0.2s (5 times per second, instead of 60)
task.spawn(function()
    while true do
        task.wait(0.2)
        if not ChamsEnabled then continue end

        for _, player in pairs(Services.Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if TeamCheckEnabled and player.Team == LocalPlayer.Team then continue end

            local char = player.Character
            if char then
                local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
                if head then
                    if not Highlights[player] or not Highlights[player].Parent then
                        Highlights[player] = createHighlight(char)
                    end
                    local highlight = Highlights[player]
                    local visible = isVisible(head)
                    highlight.FillColor = visible and ChamsColor or ThroughWallsColor
                end
            end
        end
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
local text = World:AddSection("Texture","right")


local decalIDs = {
    ["Glass tile"] = 3343069422,
    ["Snow"] = 20664426,
    ["Rock"] = 204384940,
    ["Sand"] = 204384960
}

local worldEnabled = false
local currentSelection = "Default"

text:AddToggle("World texture", false, function(val)
    worldEnabled = val
    if worldEnabled then
        applyDecal(currentSelection)
    else
        removeDecals()
    end
end)

text:AddDropdown("Texture", { "Default", "No texture","Glass tile","Snow","Rock","Sand" }, "Default", function(val)
    currentSelection = val
    if worldEnabled then
        removeDecals()
        applyDecal(currentSelection)
    end
end)

function applyDecal(selection)
    if selection == "Default" or selection == "No texture" then return end
    local id = decalIDs[selection]
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            if not part:FindFirstChild("WorldDecal") then
                local decal = Instance.new("Decal")
                decal.Name = "WorldDecal"
                decal.Texture = "rbxassetid://"..id
                decal.Face = Enum.NormalId.Top
                decal.Parent = part
            else
                part.WorldDecal.Texture = "rbxassetid://"..id
            end
        end
    end
end

function removeDecals()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChild("WorldDecal") then
            part.WorldDecal:Destroy()
        end
    end
end


local worldEnabled = false
local currentMaterial = "Default"

-- Store original materials to revert later
local originalMaterials = {}
for _, part in pairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") then
        originalMaterials[part] = part.Material
    end
end

local materialMap = {
    ["Default"] = nil, -- will revert to original
    ["Snow"] = Enum.Material.Snow,
    ["Metal"] = Enum.Material.Metal,
    ["Glass"] = Enum.Material.Glass
}

text:AddToggle("World material", false, function(val)
    worldEnabled = val
    if worldEnabled then
        applyMaterial(currentMaterial)
    else
        -- revert to original materials
        for part, mat in pairs(originalMaterials) do
            if part and part:IsA("BasePart") then
                part.Material = mat
            end
        end
    end
end)

text:AddDropdown("World material", { "Default", "Snow","Metal","Glass"}, "Default", function(val)
    currentMaterial = val
    if worldEnabled then
        applyMaterial(currentMaterial)
    end
end)

function applyMaterial(selection)
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            if selection == "Default" then
                part.Material = originalMaterials[part] or Enum.Material.Plastic
            else
                part.Material = materialMap[selection] or part.Material
            end
        end
    end
end

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

local Lighting = game:GetService("Lighting")

-- Create BloomEffect if it doesn't exist
local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
if not bloom then
    bloom = Instance.new("BloomEffect")
    bloom.Parent = Lighting
    bloom.Enabled = false
    bloom.Intensity = 0.1
end

-- Toggle
ma:AddToggle("Bloom", false, function(val)
    bloom.Enabled = val
end)

-- Slider
ma:AddSlider("Bloom value", 1, 100, 10, function(val)
    bloom.Intensity = val / 10 -- scale from 0.1 to 10
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

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// PLAYER
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local HRP = char:WaitForChild("HumanoidRootPart")

--// MOVEMENT SETTINGS
local Movement = {
    AutoJump = false,
    CircleStrafe = false,
    QuickStop = false,
    EdgeJump = false,
    JumpBug = false
}

--// PC KEYS
local moveKeys = {W=false, A=false, S=false, D=false}

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then moveKeys.W = true end
    if input.KeyCode == Enum.KeyCode.A then moveKeys.A = true end
    if input.KeyCode == Enum.KeyCode.S then moveKeys.S = true end
    if input.KeyCode == Enum.KeyCode.D then moveKeys.D = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then moveKeys.W = false end
    if input.KeyCode == Enum.KeyCode.A then moveKeys.A = false end
    if input.KeyCode == Enum.KeyCode.S then moveKeys.S = false end
    if input.KeyCode == Enum.KeyCode.D then moveKeys.D = false end
end)

--// MOBILE CHECK
local function isMovingMobile()
    return hum and hum.MoveDirection.Magnitude > 0.1
end

--// AIR STRAFE GLOBALS
getgenv().AirStrafeEnabled = false
getgenv().AirStrafeStrength = 20

--// CHARACTER UPDATE FUNCTION
local function updateCharacter(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart")
end

lp.CharacterAdded:Connect(function(newChar)
    updateCharacter(newChar)
end)

--// MAIN MOVEMENT LOOP
RunService.RenderStepped:Connect(function()
    if not hum or hum.Health <= 0 then return end

    local onGround = hum:GetState() == Enum.HumanoidStateType.Running or hum:GetState() == Enum.HumanoidStateType.Landed
    local usingKeyboard = moveKeys.W or moveKeys.A or moveKeys.S or moveKeys.D
    local usingMobile = isMovingMobile()

    if Movement.AutoJump and onGround then
        hum.Jump = true
    end

    if Movement.CircleStrafe and HRP then
        HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(3), 0)
        hum:Move(Vector3.new(1,0,0), true)
    end

    if Movement.QuickStop and not usingKeyboard and not usingMobile then
        hum:Move(Vector3.new(0,0,0), true)
    end

    if Movement.EdgeJump and HRP then
        local ray = Ray.new(HRP.Position, Vector3.new(0,-5,0))
        local hit = workspace:FindPartOnRay(ray, char)
        if not hit then
            hum.Jump = true
        end
    end

    if Movement.JumpBug and onGround then
        hum.HipHeight = 0
        task.wait(0.01)
        hum.HipHeight = 0
        hum.Jump = false
    end
end)

--// AIR STRAFE LOOP
RunService.RenderStepped:Connect(function()
    if not getgenv().AirStrafeEnabled then return end
    if not hum or hum.Health <= 0 then return end

    local rootPart = HRP
    if hum.FloorMaterial == Enum.Material.Air and rootPart then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            rootPart.Velocity = Vector3.new(
                moveDir.X * getgenv().AirStrafeStrength,
                rootPart.Velocity.Y,
                moveDir.Z * getgenv().AirStrafeStrength
            )
        end
    end
end)

--// GUI TOGGLES EXAMPLES
movement:AddToggle("Auto Jump", false, function(v)
    Movement.AutoJump = v
end)

movement:AddToggle("Circle Strafe", false, function(v)
    Movement.CircleStrafe = v
end)

movement:AddToggle("Quick Stop", false, function(v)
    Movement.QuickStop = v
end)

movement:AddToggle("Edge Jump", false, function(v)
    Movement.EdgeJump = v
end)

movement:AddToggle("Jump Bug", false, function(v)
    Movement.JumpBug = v
end)

movement:AddToggle("Air Strafe", false, function(v)
    getgenv().AirStrafeEnabled = v
end)

movement:AddSlider("Smoothing", 1, 200, 20, function(v)
    getgenv().AirStrafeStrength = v
end)



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

snd:AddButton("Unlock all skin", function()
local LocalPlayer = game:GetService("Players").LocalPlayer local Client = getsenv(game:GetService("Players").LocalPlayer.PlayerGui.Client) local ReplicatedStorage = game:GetService("ReplicatedStorage")  local allSkins = {    {'AK47_Ace'},    {'AK47_Bloodboom'},    {'AK47_Clown'},    {'AK47_Code Orange'},    {'AK47_Eve'},    {'AK47_Gifted'},    {'AK47_Glo'},    {'AK47_Godess'},    {'AK47_Hallows'},    {'AK47_Halo'},    {'AK47_Hypersonic'},    {'AK47_Inversion'},    {'AK47_Jester'},    {'AK47_Maker'},    {'AK47_Mean Green'},    {'AK47_Outlaws'},    {'AK47_Outrunner'},    {'AK47_Patch'},    {'AK47_Plated'},    {'AK47_Precision'},    {'AK47_Quantum'},    {'AK47_Quicktime'},    {'AK47_Scapter'},    {'AK47_Secret Santa'},    {'AK47_Shooting Star'},    {'AK47_Skin Committee'},    {'AK47_Survivor'},    {'AK47_Ugly Sweater'},    {'AK47_VAV'},    {'AK47_Variant Camo'},    {'AK47_Yltude'},    {'AUG_Chilly Night'},    {'AUG_Dream Hound'},    {'AUG_Enlisted'},    {'AUG_Graffiti'},    {'AUG_Homestead'},    {'AUG_Maker'},    {'AUG_NightHawk'},    {'AUG_Phoenix'},    {'AUG_Sunsthetic'},    {'AWP_Abaddon'},    {'AWP_Autumness'},    {'AWP_Blastech'},    {'AWP_Bloodborne'},    {'AWP_Coffin Biter'},    {'AWP_Desert Camo'},    {'AWP_Difference'},    {'AWP_Dragon'},    {'AWP_Forever'},    {'AWP_Grepkin'},    {'AWP_Hika'},    {'AWP_Illusion'},    {'AWP_Instinct'},    {'AWP_JTF2'},    {'AWP_Lunar'},    {'AWP_Nerf'},    {'AWP_Northern Lights'},    {'AWP_Pear Tree'},    {'AWP_Pink Vision'},    {'AWP_Pinkie'},    {'AWP_Quicktime'},    {'AWP_Racer'},    {'AWP_Regina'},    {'AWP_Retroactive'},    {'AWP_Scapter'},    {'AWP_Silence'},    {'AWP_Venomus'},    {'AWP_Weeb'},    {'Banana_Stock'},    {'Bayonet_Aequalis'},    {'Bayonet_Banner'},    {'Bayonet_Candy Cane'},    {'Bayonet_Consumed'},    {'Bayonet_Cosmos'},    {'Bayonet_Crimson Tiger'},    {'Bayonet_Crow'},    {'Bayonet_Delinquent'},    {'Bayonet_Digital'},    {'Bayonet_Easy-Bake'},    {'Bayonet_Egg Shell'},    {'Bayonet_Festive'},    {'Bayonet_Frozen Dream'},    {'Bayonet_Geo Blade'},    {'Bayonet_Ghastly'},    {'Bayonet_Goo'},    {'Bayonet_Hallows'},    {'Bayonet_Intertwine'},    {'Bayonet_Marbleized'},    {'Bayonet_Mariposa'},    {'Bayonet_Naval'},    {'Bayonet_Neonic'},    {'Bayonet_RSL'},    {'Bayonet_Racer'},    {'Bayonet_Sapphire'},    {'Bayonet_Silent Night'},    {'Bayonet_Splattered'},    {'Bayonet_Stock'},    {'Bayonet_Topaz'},    {'Bayonet_Tropical'},    {'Bayonet_Twitch'},    {'Bayonet_UFO'},    {'Bayonet_Wetland'},    {'Bayonet_Worn'},    {'Bayonet_Wrapped'},    {'Bearded Axe_Beast'},    {'Bearded Axe_Splattered'},    {'Bizon_Autumic'},    {'Bizon_Festive'},    {'Bizon_Oblivion'},    {'Bizon_Saint Nick'},    {'Bizon_Sergeant'},    {'Bizon_Shattered'},    {'Butterfly Knife_Aurora'},    {'Butterfly Knife_Bloodwidow'},    {'Butterfly Knife_Consumed'},    {'Butterfly Knife_Cosmos'},    {'Butterfly Knife_Crimson Tiger'},    {'Butterfly Knife_Crippled Fade'},    {'Butterfly Knife_Digital'},    {'Butterfly Knife_Egg Shell'},    {'Butterfly Knife_Freedom'},    {'Butterfly Knife_Frozen Dream'},    {'Butterfly Knife_Goo'},    {'Butterfly Knife_Hallows'},    {'Butterfly Knife_Icicle'},    {'Butterfly Knife_Inversion'},    {'Butterfly Knife_Jade Dream'},    {'Butterfly Knife_Marbleized'},    {'Butterfly Knife_Naval'},    {'Butterfly Knife_Neonic'},    {'Butterfly Knife_Reaper'},    {'Butterfly Knife_Ruby'},    {'Butterfly Knife_Scapter'},    {'Butterfly Knife_Splattered'},    {'Butterfly Knife_Stock'},    {'Butterfly Knife_Topaz'},    {'Butterfly Knife_Tropical'},    {'Butterfly Knife_Twitch'},    {'Butterfly Knife_Wetland'},    {'Butterfly Knife_White Boss'},    {'Butterfly Knife_Worn'},    {'Butterfly Knife_Wrapped'},    {'CZ_Designed'},    {'CZ_Festive'},    {'CZ_Holidays'},    {'CZ_Lightning'},    {'CZ_Orange Web'},    {'CZ_Spectre'},    {'Cleaver_Spider'},    {'Cleaver_Splattered'},    {'DesertEagle_Cold Truth'},    {'DesertEagle_Cool Blue'},    {'DesertEagle_DropX'},    {'DesertEagle_Glittery'},    {'DesertEagle_Grim'},    {'DesertEagle_Heat'},    {'DesertEagle_Honor-bound'},    {'DesertEagle_Independence'},    {'DesertEagle_Krystallos'},    {'DesertEagle_Pumpkin Buster'},    {'DesertEagle_ROLVe'},    {'DesertEagle_Racer'},    {'DesertEagle_Scapter'},    {'DesertEagle_Skin Committee'},    {'DesertEagle_Survivor'},    {'DesertEagle_Weeb'},    {'DesertEagle_Xmas'},    {'DualBerettas_Carbonized'},    {'DualBerettas_Dusty Manor'},    {'DualBerettas_Floral'},    {'DualBerettas_Hexline'},    {'DualBerettas_Neon web'},    {'DualBerettas_Old Fashioned'},    {'DualBerettas_Xmas'},    {'Falchion Knife_Bloodwidow'},    {'Falchion Knife_Chosen'},    {'Falchion Knife_Coal'},    {'Falchion Knife_Consumed'},    {'Falchion Knife_Cosmos'},    {'Falchion Knife_Crimson Tiger'},    {'Falchion Knife_Crippled Fade'},    {'Falchion Knife_Digital'},    {'Falchion Knife_Egg Shell'},    {'Falchion Knife_Festive'},    {'Falchion Knife_Freedom'},    {'Falchion Knife_Frozen Dream'},    {'Falchion Knife_Goo'},    {'Falchion Knife_Hallows'},    {'Falchion Knife_Inversion'},    {'Falchion Knife_Late Night'},    {'Falchion Knife_Marbleized'},    {'Falchion Knife_Naval'},    {'Falchion Knife_Neonic'},    {'Falchion Knife_Racer'},    {'Falchion Knife_Ruby'},    {'Falchion Knife_Splattered'},    {'Falchion Knife_Stock'},    {'Falchion Knife_Topaz'},    {'Falchion Knife_Tropical'},    {'Falchion Knife_Wetland'},    {'Falchion Knife_Worn'},    {'Falchion Knife_Wrapped'},    {'Falchion Knife_Zombie'},    {'Famas_Abstract'},    {'Famas_Centipede'},    {'Famas_Cogged'},    {'Famas_Goliath'},    {'Famas_Haunted Forest'},    {'Famas_KugaX'},    {'Famas_MK11'},    {'Famas_Medic'},    {'Famas_Redux'},    {'Famas_Shocker'},    {'Famas_Toxic Rain'},    {'FiveSeven_Autumn Fade'},    {'FiveSeven_Danjo'},    {'FiveSeven_Fluid'},    {'FiveSeven_Gifted'},    {'FiveSeven_Midnight Ride'},    {'FiveSeven_Mr. Anatomy'},    {'FiveSeven_Stigma'},    {'FiveSeven_Sub Zero'},    {'FiveSeven_Summer'},    {'Flip Knife_Stock'},    {'G3SG1_Amethyst'},    {'G3SG1_Autumn'},    {'G3SG1_Foliage'},    {'G3SG1_Hex'},    {'G3SG1_Holly Bound'},    {'G3SG1_Mahogany'},    {'Galil_Frosted'},    {'Galil_Hardware 2'},    {'Galil_Hardware'},    {'Galil_Toxicity'},    {'Galil_Worn'},    {'Glock_Angler'},    {'Glock_Anubis'},    {'Glock_Biotrip'},    {'Glock_Day Dreamer'},    {'Glock_Desert Camo'},    {'Glock_Gravestomper'},    {'Glock_Midnight Tiger'},    {'Glock_Money Maker'},    {'Glock_RSL'},    {'Glock_Rush'},    {'Glock_Scapter'},    {'Glock_Spacedust'},    {'Glock_Tarnish'},    {'Glock_Underwater'},    {'Glock_Wetland'},    {'Glock_White Sauce'},    {'Gut Knife_Banner'},    {'Gut Knife_Bloodwidow'},    {'Gut Knife_Consumed'},    {'Gut Knife_Cosmos'},    {'Gut Knife_Crimson Tiger'},    {'Gut Knife_Crippled Fade'},    {'Gut Knife_Digital'},    {'Gut Knife_Egg Shell'},    {'Gut Knife_Frozen Dream'},    {'Gut Knife_Geo Blade'},    {'Gut Knife_Goo'},    {'Gut Knife_Hallows'},    {'Gut Knife_Lurker'},    {'Gut Knife_Marbleized'},    {'Gut Knife_Naval'},    {'Gut Knife_Neonic'},    {'Gut Knife_Present'},    {'Gut Knife_Ruby'},    {'Gut Knife_Rusty'},    {'Gut Knife_Splattered'},    {'Gut Knife_Topaz'},    {'Gut Knife_Tropical'},    {'Gut Knife_Wetland'},    {'Gut Knife_Worn'},    {'Gut Knife_Wrapped'},    {'Huntsman Knife_Aurora'},    {'Huntsman Knife_Bloodwidow'},    {'Huntsman Knife_Consumed'},    {'Huntsman Knife_Cosmos'},    {'Huntsman Knife_Cozy'},    {'Huntsman Knife_Crimson Tiger'},    {'Huntsman Knife_Crippled Fade'},    {'Huntsman Knife_Digital'},    {'Huntsman Knife_Egg Shell'},    {'Huntsman Knife_Frozen Dream'},    {'Huntsman Knife_Geo Blade'},    {'Huntsman Knife_Goo'},    {'Huntsman Knife_Hallows'},    {'Huntsman Knife_Honor Fade'},    {'Huntsman Knife_Marbleized'},    {'Huntsman Knife_Monster'},    {'Huntsman Knife_Naval'},    {'Huntsman Knife_Ruby'},    {'Huntsman Knife_Splattered'},    {'Huntsman Knife_Stock'},    {'Huntsman Knife_Tropical'},    {'Huntsman Knife_Twitch'},    {'Huntsman Knife_Wetland'},    {'Huntsman Knife_Worn'},    {'Huntsman Knife_Wrapped'},    {'Karambit_Bloodwidow'},    {'Karambit_Consumed'},    {'Karambit_Cosmos'},    {'Karambit_Crimson Tiger'},    {'Karambit_Crippled Fade'},    {'Karambit_Death Wish'},    {'Karambit_Digital'},    {'Karambit_Egg Shell'},    {'Karambit_Festive'},    {'Karambit_Frozen Dream'},    {'Karambit_Glossed'},    {'Karambit_Gold'},    {'Karambit_Goo'},    {'Karambit_Hallows'},    {'Karambit_Jade Dream'},    {'Karambit_Jester'},    {'Karambit_Lantern'},    {'Karambit_Liberty Camo'},    {'Karambit_Marbleized'},    {'Karambit_Naval'},    {'Karambit_Neonic'},    {'Karambit_Pizza'},    {'Karambit_Quicktime'},    {'Karambit_Racer'},    {'Karambit_Ruby'},    {'Karambit_Scapter'},    {'Karambit_Splattered'},    {'Karambit_Stock'},    {'Karambit_Topaz'},    {'Karambit_Tropical'},    {'Karambit_Twitch'},    {'Karambit_Wetland'},    {'Karambit_Worn'},    {'M249_Aggressor'},    {'M249_P2020'},    {'M249_Spooky'},    {'M249_Wolf'},    {'M4A1_Animatic'},    {'M4A1_Burning'},    {'M4A1_Desert Camo'},    {'M4A1_Heavens Gate'},    {'M4A1_Impulse'},    {'M4A1_Jester'},    {'M4A1_Lunar'},    {'M4A1_Necropolis'},    {'M4A1_Tecnician'},    {'M4A1_Toucan'},    {'M4A1_Wastelander'},    {'M4A4_BOT[S]'},    {'M4A4_Candyskull'},    {'M4A4_Delinquent'},    {'M4A4_Desert Camo'},    {'M4A4_Devil'},    {'M4A4_Endline'},    {'M4A4_Flashy Ride'},    {'M4A4_Ice Cap'},    {'M4A4_Jester'},    {'M4A4_King'},    {'M4A4_Mistletoe'},    {'M4A4_Pinkie'},    {'M4A4_Pinkvision'},    {'M4A4_Pondside'},    {'M4A4_Precision'},    {'M4A4_Quicktime'},    {'M4A4_Racer'},    {'M4A4_RayTrack'},    {'M4A4_Scapter'},    {'M4A4_Stardust'},    {'M4A4_Toy Soldier'},    {'MAC10_Artists Intent'},    {'MAC10_Blaze'},    {'MAC10_Golden Rings'},    {'MAC10_Pimpin'},    {'MAC10_Skeleboney'},    {'MAC10_Toxic'},    {'MAC10_Turbo'},    {'MAC10_Wetland'},    {'MAG7_Bombshell'},    {'MAG7_C4UTION'},    {'MAG7_Frosty'},    {'MAG7_Molten'},    {'MAG7_Outbreak'},    {'MAG7_Striped'},    {'MP7_Calaxian'},    {'MP7_Cogged'},    {'MP7_Goo'},    {'MP7_Holiday'},    {'MP7_Industrial'},    {'MP7_Reindeer'},    {'MP7_Silent Ops'},    {'MP7_Sunshot'},    {'MP9_Blueroyal'},    {'MP9_Cob Web'},    {'MP9_Cookie Man'},    {'MP9_Decked Halls'},    {'MP9_SnowTime'},    {'MP9_Vaporwave'},    {'MP9_Velvita'},    {'MP9_Wilderness'},    {'Negev_Default'},    {'Negev_Midnightbones'},    {'Negev_Quazar'},    {'Negev_Striped'},    {'Negev_Wetland'},    {'Negev_Winterfell'},    {'Nova_Black Ice'},    {'Nova_Cookie'},    {'Nova_Paradise'},    {'Nova_Sharkesh'},    {'Nova_Starry Night'},    {'Nova_Terraformer'},    {'Nova_Tiger'},    {'P2000_Apathy'},    {'P2000_Camo Dipped'},    {'P2000_Candycorn'},    {'P2000_Comet'},    {'P2000_Dark Beast'},    {'P2000_Golden Age'},    {'P2000_Lunar'},    {'P2000_Pinkie'},    {'P2000_Ruby'},    {'P2000_Silence'},    {'P250_Amber'},    {'P250_Bomber'},    {'P250_Equinox'},    {'P250_Frosted'},    {'P250_Goldish'},    {'P250_Green Web'},    {'P250_Shark'},    {'P250_Solstice'},    {'P250_TC250'},    {'P90_Demon Within'},    {'P90_Elegant'},    {'P90_Krampus'},    {'P90_Northern Lights'},    {'P90_P-Chan'},    {'P90_Pine'},    {'P90_Redcopy'},    {'P90_Skulls'},    {'R8_Exquisite'},    {'R8_Hunter'},    {'R8_Spades'},    {'R8_TG'},    {'R8_Violet'},    {'SG_DropX'},    {'SG_Dummy'},    {'SG_Kitty Cat'},    {'SG_Knighthood'},    {'SG_Magma'},    {'SG_Variant Camo'},    {'SG_Yltude'},    {'SawedOff_Casino'},    {'SawedOff_Colorboom'},    {'SawedOff_Executioner'},    {'SawedOff_Opal'},    {'SawedOff_Spooky'},    {'SawedOff_Sullys Blacklight'},    {'Scout_Coffin Biter'},    {'Scout_Flowing Mists'},    {'Scout_Hellborn'},    {'Scout_Hot Cocoa'},    {'Scout_Monstruo'},    {'Scout_Neon Regulation'},    {'Scout_Posh'},    {'Scout_Pulse'},    {'Scout_Railgun'},    {'Scout_Theory'},    {'Scout_Xmas'},    {'Sickle_Mummy'},    {'Sickle_Splattered'},    {'Tec9_Charger'},    {'Tec9_Gift Wrapped'},    {'Tec9_Ironline'},    {'Tec9_Performer'},    {'Tec9_Phol'},    {'Tec9_Samurai'},    {'Tec9_Skintech'},    {'Tec9_Stocking Stuffer'},    {'UMP_Death Grip'},    {'UMP_Gum Drop'},    {'UMP_Magma'},    {'UMP_Militia Camo'},    {'UMP_Molten'},    {'UMP_Redline'},    {'USP_Crimson'},    {'USP_Dizzy'},    {'USP_Frostbite'},    {'USP_Holiday'},    {'USP_Jade Dream'},    {'USP_Kraken'},    {'USP_Nighttown'},    {'USP_Paradise'},    {'USP_Racing'},    {'USP_Skull'},    {'USP_Unseen'},    {'USP_Worlds Away'},    {'USP_Yellowbelly'},    {'XM_Artic'},    {'XM_Atomic'},    {'XM_Campfire'},    {'XM_Endless Night'},    {'XM_MK11'},    {'XM_Predator'},    {'XM_Red'},    {'XM_Spectrum'},    {'Handwraps_Wraps'},    {'Sports Glove_Hazard'},    {'Sports Glove_Hallows'},    {'Sports Glove_Majesty'},    {'Strapped Glove_Racer'},    {'trapped Glove_Grim'},    {'trapped Glove_Wisk'},    {'Fingerless Glove_Scapter'},    {'Fingerless Glove_Digital'},    {'Fingerless Glove_Patch'},    {'Handwraps_Guts'},    {'Handwraps_Wetland'},    {'trapped Glove_Molten'},    {'Fingerless_Crystal'},    {'Sports Glove_Royal'},    {'Strapped Glove_Kringle'},    {'Handwraps_MMA'},    {'Sports Glove_Weeb'},    {'Sports Glove_CottonTail'},    {'Sports Glove_RSL'},    {'Handwraps_Ghoul Hex'},    {'Handwraps_Phantom Hex'},    {'Handwraps_Spector Hex'},    {'Handwraps_Orange Hex'},    {'Handwraps_Purple Hex'},    {'Handwraps_Green Hex'}, }  local isUnlocked  local mt = getrawmetatable(game) local oldNamecall = mt.__namecall setreadonly(mt, false)  local isUnlocked  mt.__namecall = newcclosure(function(self, ...)    local args = {...}    if getnamecallmethod() == "InvokeServer" and tostring(self) == "Hugh" then        return    end    if getnamecallmethod() == "FireServer" then        if args[1] == LocalPlayer.UserId then            return        end        if string.len(tostring(self)) == 38 then            if not isUnlocked then                isUnlocked = true                for i,v in pairs(allSkins) do                    local doSkip                    for i2,v2 in pairs(args[1]) do                        if v[1] == v2[1] then                            doSkip = true                        end                    end                    if not doSkip then                        table.insert(args[1], v)                    end                end            end            return        end        if tostring(self) == "DataEvent" and args[1][4] then            local currentSkin = string.split(args[1][4][1], "_")[2]            if args[1][2] == "Both" then                LocalPlayer["SkinFolder"]["CTFolder"][args[1][3]].Value = currentSkin                LocalPlayer["SkinFolder"]["TFolder"][args[1][3]].Value = currentSkin            else                LocalPlayer["SkinFolder"][args[1][2] .. "Folder"][args[1][3]].Value = currentSkin            end        end    end    return oldNamecall(self, ...) end)     setreadonly(mt, true)  Client.CurrentInventory = allSkins  local TClone, CTClone = LocalPlayer.SkinFolder.TFolder:Clone(), game:GetService("Players").LocalPlayer.SkinFolder.CTFolder:Clone() LocalPlayer.SkinFolder.TFolder:Destroy() LocalPlayer.SkinFolder.CTFolder:Destroy() TClone.Parent = LocalPlayer.SkinFolder CTClone.Parent = LocalPlayer.SkinFolder
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

AddScript("Best legit config", "11/27/25", UDim2.new(0.02,0,0.01,0), function()
noFireRate = false
infiniteAmmo = true
 norecoil = true
-- Aimbot / Legitbot
AimbotEnabled = fse
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
t0 = false
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
j = 60  -- Flick FOV

-- ESP
_G.ESP_Box_Enabled = false
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
getgenv().AirStrafeStrength = 29

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
AddScript("Legit no miss cheat", "11/27/25", UDim2.new(0.02000000700354576,0,0.12,0), function()
norecoil = true
noFireRate = false
infiniteAmmo = true

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

AddScript("Hvh legit", "11/27/25", UDim2.new(0.02000000700354576,0,0.23,0), function()
    -- Aimbot / Legitbot
infiniteAmmo = true
noFireRate = true
 norecoil = true
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

AddScript("Hvh config by gerald", "11/31/25", UDim2.new(0.02000000700354576,0,0.34,0), function()

 CAMERA_RANGE = 10 -- default distance
 Enabled = true
 AimbotEnabled = false
 DrawFOV = false
 Smooth = 1.1
 Amount = 10
 DynamicFOV = false
 Multiplier = 220 -- Base FOV radius
 HitSelection = "Head"
 PreferHead = false
 PreferBody = false
 BodyIfLethal = true
 BeforeShotDelay = "None"
 silentAim = true

t0 = true
f0 = 14
spd = 50
crosshairEnabled = true


 norecoil = true
 spreads = 0
 noFireRate = true
 infiniteAmmo = true

_G.ESP_Health_Enabled = true
_G.ESP_Name_Enabled = true
_G.ESP_Box_Enabled = false

 GlowEnabled = true
 CurrentChamColor = Color3.fromRGB(255,255,255)

 ChamsEnabled = true
 ChamsColor = Color3.fromRGB(255,255,255)
 ThroughWallsColor = Color3.fromRGB(255,0,255)

 espEnabled = true
 showBox = false
 showName = true
showDistance = false

chamsEnabled = true
chamsColor = Color3.fromRGB(255, 0, 255)

originalAmbient = Lighting.Ambient
originalClockTime = Lighting.ClockTime
originalBrightness = Lighting.Brightness
fogEnabled = false
fogStart = 100
fogEnd = 1000
nightModeEnabled = true

Movement = {
    AutoJump = true,
    CircleStrafe = false,
    QuickStop = true,
    EdgeJump = true,
    JumpBug = false
}

getgenv().AirStrafeEnabled = true

getgenv().AirStrafeStrength = 50

end)
end)
end
