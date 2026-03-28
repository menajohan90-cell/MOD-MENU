-- Script Mod Menu Mejorado - Versión 3.1 (Drag mejorado y panel movible por título)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local espOn = false
local aimOn = false
local antennaOn = false
local autoShootOn = false
local antiLagOn = false
local noCooldownOn = false
local hitboxOn = false
local aimFOV = 60

local teamColor = Color3.fromRGB(0, 150, 255)
local enemyColor = Color3.fromRGB(255, 0, 0)
local antennas = {}
local hitboxParts = {}

-- ==================== FUNCIONES AUXILIARES ====================
local function isEnemy(player)
    if player == LocalPlayer then return false end
    if not LocalPlayer.Team or not player.Team then return true end
    return LocalPlayer.Team ~= player.Team
end

local function getClosestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return nil end
    local camPos = Camera.CFrame.Position
    local camDir = Camera.CFrame.LookVector
    local best, bestAngle = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character and plr.Character:FindFirstChild("Head") then
            local targetPos = plr.Character.Head.Position
            local dir = (targetPos - camPos).Unit
            local angle = math.deg(math.acos(camDir:Dot(dir)))
            if angle <= aimFOV and angle < bestAngle then
                bestAngle = angle
                best = plr.Character
            end
        end
    end
    return best
end

local function autoShoot()
    if not autoShootOn then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        if tool:FindFirstChild("Activate") then
            tool:Activate()
        elseif tool:FindFirstChild("Fire") then
            tool:Fire()
        elseif tool:FindFirstChild("RemoteEvent") then
            tool.RemoteEvent:FireServer()
        else
            local mouse = LocalPlayer:GetMouse()
            if mouse then
                mouse.Button1Click:Fire()
            end
        end
    end
end

-- ==================== ESP ====================
local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local h = plr.Character:FindFirstChild("ESP_Highlight")
            if espOn then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "ESP_Highlight"
                    h.Adornee = plr.Character
                    h.FillTransparency = 0.4
                    h.OutlineTransparency = 0
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = plr.Character
                end
                h.FillColor = isEnemy(plr) and enemyColor or teamColor
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
            elseif h then
                h:Destroy()
            end
        end
    end
end

-- ==================== ANTENA ====================
local function createAntenna(plr)
    if not plr.Character or antennas[plr] then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 80, 0, 80)
    bill.StudsOffset = Vector3.new(0, 3.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = head

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 70, 0, 40)
    box.Position = UDim2.new(0.5, -35, 0, 30)
    box.BackgroundColor3 = isEnemy(plr) and enemyColor or teamColor
    box.BackgroundTransparency = 0.35
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(255, 255, 255)
    box.Parent = bill

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = plr.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = box

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 0, 35)
    line.Position = UDim2.new(0.5, -1.5, 0, -5)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.Parent = bill

    antennas[plr] = bill
end

local function destroyAntenna(plr)
    if antennas[plr] then
        antennas[plr]:Destroy()
        antennas[plr] = nil
    end
end

local function updateAntennas()
    if not antennaOn then
        for plr, _ in pairs(antennas) do destroyAntenna(plr) end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then createAntenna(plr) else destroyAntenna(plr) end
    end
end

-- ==================== AIMBOT ====================
local function aimbotUpdate()
    if not aimOn then return end
    local target = getClosestEnemy()
    if target and target:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
        if autoShootOn then
            autoShoot()
        end
    end
end

-- ==================== POV ====================
local povGui = nil
local function setPOVVisible(visible)
    if povGui then povGui.Enabled = visible end
end

local function createPOV()
    local gui = Instance.new("ScreenGui")
    gui.Name = "POVCircle"
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, aimFOV * 2, 0, aimFOV * 2)
    circle.Position = UDim2.new(0.5, -aimFOV, 0.5, -aimFOV)
    circle.BackgroundTransparency = 1
    circle.BorderSizePixel = 2
    circle.BorderColor3 = Color3.fromRGB(255, 255, 255)
    circle.BackgroundTransparency = 0.85
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(1, 0)
    uic.Parent = circle
    circle.Parent = gui
    povGui = gui
    setPOVVisible(false)
end

-- ==================== ANTI-LAG ====================
local originalShadows
local function setAntiLag(state)
    if state then
        originalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
    elseif originalShadows ~= nil then
        Lighting.GlobalShadows = originalShadows
    end
end

-- ==================== NO COOLDOWN ====================
local noCooldownConnection = nil
local function toggleNoCooldown(state)
    noCooldownOn = state
    if state then
        if noCooldownConnection then noCooldownConnection:Disconnect() end
        noCooldownConnection = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    for _, v in pairs(tool:GetDescendants()) do
                        if v:IsA("NumberValue") or v:IsA("IntValue") then
                            if v.Name:lower():find("cooldown") or v.Name:lower():find("delay") or v.Name:lower():find("reload") then
                                v.Value = 0
                            end
                        end
                    end
                end
            end
        end)
    else
        if noCooldownConnection then
            noCooldownConnection:Disconnect()
            noCooldownConnection = nil
        end
    end
end

-- ==================== HITBOX EXPANDER ====================
local function createHitbox(plr)
    if not plr.Character or hitboxParts[plr] then return end
    local torso = plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("HumanoidRootPart")
    if not torso then return end

    local sphere = Instance.new("Part")
    sphere.Name = "HitboxExpander"
    sphere.Size = Vector3.new(8, 8, 8)
    sphere.Shape = Enum.PartType.Ball
    sphere.Material = Enum.Material.Neon
    sphere.Color = isEnemy(plr) and enemyColor or teamColor
    sphere.Transparency = 0.5
    sphere.CanCollide = false
    sphere.Anchored = true
    sphere.Parent = plr.Character

    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = sphere
    weld.C0 = CFrame.new(0, 0, 0)
    weld.Parent = sphere

    hitboxParts[plr] = sphere
end

local function destroyHitbox(plr)
    if hitboxParts[plr] then
        hitboxParts[plr]:Destroy()
        hitboxParts[plr] = nil
    end
end

local function updateHitboxes()
    if not hitboxOn then
        for plr, _ in pairs(hitboxParts) do destroyHitbox(plr) end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isEnemy(plr) then
            createHitbox(plr)
        else
            destroyHitbox(plr)
        end
    end
end

local function redirectBullets()
    if not hitboxOn then return end
    for _, bullet in ipairs(workspace:GetDescendants()) do
        if bullet:IsA("Part") and bullet:FindFirstChild("Velocity") and not bullet:IsDescendantOf(LocalPlayer.Character) then
            local vel = bullet.Velocity
            if vel.Magnitude > 50 then
                for plr, sphere in pairs(hitboxParts) do
                    if sphere and sphere:IsDescendantOf(workspace) then
                        local distance = (bullet.Position - sphere.Position).Magnitude
                        if distance <= sphere.Size.X / 2 then
                            local target = plr.Character and plr.Character:FindFirstChild("Head")
                            if target then
                                local direction = (target.Position - bullet.Position).Unit
                                bullet.Velocity = direction * vel.Magnitude
                                bullet.CFrame = CFrame.new(bullet.Position, target.Position)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end

-- ==================== INTERFAZ CON DRAG MEJORADO ====================
local function createInterface()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModMenuRing"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Botón central (arrastrable desde cualquier parte)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 70, 0, 70)
    toggleBtn.Position = UDim2.new(0.5, -35, 0.5, -35)
    toggleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleBtn.Text = "⚙️"
    toggleBtn.TextSize = 32
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = screenGui

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn

    -- Panel
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 300, 0, 500)
    panel.Position = UDim2.new(0.5, -150, 0.5, -250)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = screenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = panel

    -- Barra de título (arrastrable)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    titleBar.BackgroundTransparency = 0.5
    titleBar.BorderSizePixel = 0
    titleBar.Parent = panel

    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 16)
    titleBarCorner.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "MOD MENU"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = titleBar

    -- Cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0, 8)
    closeBtn.Text = "✕"
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = panel

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        panel.Visible = false
    end)

    local function makeSectionButton(text, icon, y, stateVar, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 260, 0, 48)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = icon .. "   " .. text .. " (OFF)"
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.Parent = panel

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = btn

        local function updateButton()
            if stateVar then
                btn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
                btn.Text = icon .. "   " .. text .. " (ON)"
            else
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                btn.Text = icon .. "   " .. text .. " (OFF)"
            end
        end

        updateButton()

        btn.MouseButton1Click:Connect(function()
            stateVar = not stateVar
            updateButton()
            if callback then callback(stateVar) end
        end)
        return btn
    end

    makeSectionButton("ESP", "👁️", 60, espOn, updateESP)
    makeSectionButton("Aimbot", "🎯", 115, aimOn, function(state) setPOVVisible(state) end)
    makeSectionButton("Antena", "📡", 170, antennaOn, updateAntennas)
    makeSectionButton("Auto Disparo", "🔫", 225, autoShootOn, nil)
    makeSectionButton("Anti-Lag", "⚡", 280, antiLagOn, setAntiLag)
    makeSectionButton("No Cooldown", "♾️", 335, noCooldownOn, toggleNoCooldown)
    makeSectionButton("Hitbox Expander", "🎯", 390, hitboxOn, function(state)
        hitboxOn = state
        updateHitboxes()
    end)

    if LocalPlayer.Name == "Jxmena67" then
        local rejoinBtn = Instance.new("TextButton")
        rejoinBtn.Size = UDim2.new(0, 260, 0, 40)
        rejoinBtn.Position = UDim2.new(0, 20, 0, 445)
        rejoinBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        rejoinBtn.Text = "🔄 Rejoin Server"
        rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        rejoinBtn.TextSize = 15
        rejoinBtn.Font = Enum.Font.GothamBold
        rejoinBtn.BorderSizePixel = 0
        rejoinBtn.Parent = panel

        local rejoinCorner = Instance.new("UICorner")
        rejoinCorner.CornerRadius = UDim.new(0, 12)
        rejoinCorner.Parent = rejoinBtn

        rejoinBtn.MouseButton1Click:Connect(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
    end

    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, 0, 0, 30)
    versionLabel.Position = UDim2.new(0, 0, 1, -35)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "Versión 3.1"
    versionLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
    versionLabel.TextSize = 13
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.Parent = panel

    -- ==================== DRAG MEJORADO ====================
    -- Drag para la bolita
    local draggingBtn = false
    local dragStartBtn, startPosBtn

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingBtn = true
            dragStartBtn = input.Position
            startPosBtn = toggleBtn.Position
        end
    end)

    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingBtn = false
        end
    end)

    -- Drag para el panel (SOLO por la barra de título)
    local draggingPanel = false
    local dragStartPanel, startPosPanel

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingPanel = true
            dragStartPanel = input.Position
            startPosPanel = panel.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingPanel = false
        end
    end)

    -- Efecto visual en la barra de título
    titleBar.MouseEnter:Connect(function()
        titleBar.BackgroundTransparency = 0.2
    end)
    titleBar.MouseLeave:Connect(function()
        titleBar.BackgroundTransparency = 0.5
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingBtn and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartBtn
            toggleBtn.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
        end

        if draggingPanel and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartPanel
            panel.Position = UDim2.new(startPosPanel.X.Scale, startPosPanel.X.Offset + delta.X, startPosPanel.Y.Scale, startPosPanel.Y.Offset + delta.Y)
        end
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)
end

-- ==================== INICIO ====================
local function start()
    createInterface()
    createPOV()
    RunService.RenderStepped:Connect(aimbotUpdate)
    RunService.Heartbeat:Connect(redirectBullets)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(0.8)
            if espOn then updateESP() end
            if antennaOn then updateAntennas() end
            if hitboxOn then updateHitboxes() end
        end)
    end)

    Players.PlayerRemoving:Connect(function(p)
        destroyAntenna(p)
        destroyHitbox(p)
    end)

    print("✅ Mod Menu v3.1 cargado - Drag mejorado (bolita + panel por título)")
end

start()
