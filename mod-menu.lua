-- Script Mod Menu Mejorado - Versión 2.1 (Panel movible + Verde ON)
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
local aimFOV = 60

-- Colores
local teamColor = Color3.fromRGB(0, 150, 255)
local enemyColor = Color3.fromRGB(255, 0, 0)

local antennas = {}

-- ==================== FUNCIONES ORIGINALES (NO SE TOCARON) ====================
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

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("ESP_Highlight")
            if espOn and plr ~= LocalPlayer then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "ESP_Highlight"
                    h.Adornee = plr.Character
                    h.FillTransparency = 0.5
                    h.Parent = plr.Character
                end
                h.FillColor = isEnemy(plr) and enemyColor or teamColor
                h.OutlineColor = h.FillColor
            elseif h then
                h:Destroy()
            end
        end
    end
end

local function createAntenna(plr)
    if not plr.Character or antennas[plr] then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 70, 0, 55)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = head

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 60, 0, 30)
    box.Position = UDim2.new(0.5, -30, 0, 20)
    box.BackgroundColor3 = isEnemy(plr) and enemyColor or teamColor
    box.BackgroundTransparency = 0.4
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
    line.Size = UDim2.new(0, 2, 0, 20)
    line.Position = UDim2.new(0.5, -1, 0, 0)
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

local function aimbotUpdate()
    if not aimOn then return end
    local target = getClosestEnemy()
    if target and target:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
        if autoShootOn then
            print("[AUTO] Disparando a", target.Parent.Name)
        end
    end
end

local povGui = nil
local function updatePOVCircle()
    if povGui then
        local circ = povGui:FindFirstChild("Circle")
        if circ then
            circ.Size = UDim2.new(0, aimFOV * 2, 0, aimFOV * 2)
            circ.Position = UDim2.new(0.5, -aimFOV, 0.5, -aimFOV)
        end
    end
end

local function setPOVVisible(visible)
    if povGui then povGui.Enabled = visible end
end

local originalShadows
local function setAntiLag(state)
    if state then
        originalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
    elseif originalShadows ~= nil then
        Lighting.GlobalShadows = originalShadows
    end
end

local function resetRound()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        print("Ronda reiniciada")
    end
end

-- ==================== NUEVA INTERFAZ (TODO LO QUE PEDISTE) ====================
local function createInterface()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModMenuRing"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Botón central movible
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

    -- Panel movible (más abajo)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 300, 0, 460)
    panel.Position = UDim2.new(0.5, -150, 0.5, -180)  -- Más abajo
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = screenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = panel

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "MOD MENU"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = panel

    -- Función para crear botones con color verde cuando está ON
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
                btn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)  -- Verde
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
            callback()
        end)

        return btn
    end

    -- Secciones
    makeSectionButton("ESP", "👁️", 60, espOn, updateESP)
    makeSectionButton("Aimbot", "🎯", 115, aimOn, function() setPOVVisible(aimOn) end)
    makeSectionButton("Antena", "📡", 170, antennaOn, updateAntennas)
    makeSectionButton("Auto Disparo", "🔫", 225, autoShootOn, function() end)
    makeSectionButton("Anti-Lag", "⚡", 280, antiLagOn, function() setAntiLag(antiLagOn) end)
    makeSectionButton("Reiniciar Ronda", "🔄", 335, false, resetRound)

    -- Versión
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, 0, 0, 30)
    versionLabel.Position = UDim2.new(0, 0, 1, -30)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "Versión 2.1 - by menajohan90-cell"
    versionLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
    versionLabel.TextSize = 13
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.Parent = panel

    -- Botón Rejoin
    local rejoinBtn = Instance.new("TextButton")
    rejoinBtn.Size = UDim2.new(0, 260, 0, 40)
    rejoinBtn.Position = UDim2.new(0, 20, 1, -75)
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

    -- Botón cerrar
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

    -- Hacer el botón central movible
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = toggleBtn.Position
        end
    end)

    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Hacer el panel movible
    local panelDragging = false
    local panelDragStart
    local panelStartPos

    panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            panelDragging = true
            panelDragStart = input.Position
            panelStartPos = panel.Position
        end
    end)

    panel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            panelDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if panelDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - panelDragStart
            panel.Position = UDim2.new(panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X, panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y)
        end
    end)

    -- Abrir/Cerrar
    toggleBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)
end

-- Crear POV
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
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BackgroundTransparency = 0.85
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(1, 0)
    uic.Parent = circle
    circle.Parent = gui
    povGui = gui
    setPOVVisible(false)
end

-- Inicializar
local function start()
    createInterface()
    createPOV()
    RunService.RenderStepped:Connect(aimbotUpdate)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if espOn then updateESP() end
            if antennaOn then updateAntennas() end
        end)
    end)

    Players.PlayerRemoving:Connect(destroyAntenna)

    print("✅ Mod Menu v2.1 cargado - Panel movible activado")
end

start()
