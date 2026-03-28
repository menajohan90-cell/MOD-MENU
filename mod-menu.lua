-- Script Mod Menu Mejorado - Versión con Panel Central y Estilo Ring
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

-- Diccionario para antenas
local antennas = {}

-- Funciones auxiliares (NO se tocaron)
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

-- ESP (sin cambios)
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

-- Antena (sin cambios)
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

-- Autoapuntado (sin cambios)
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

-- POV Circle (sin cambios)
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

-- Anti-lag (sin cambios)
local originalShadows
local function setAntiLag(state)
    if state then
        originalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
    elseif originalShadows ~= nil then
        Lighting.GlobalShadows = originalShadows
    end
end

-- Reinicio de ronda (sin cambios)
local function resetRound()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        print("Ronda reiniciada")
    end
end

-- ==================== NUEVA INTERFAZ MODERNA (LO QUE PEDISTE) ====================
local function createInterface()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModMenuRing"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Botón central flotante (estilo Ring)
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

    -- Panel central
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 300, 0, 420)
    panel.Position = UDim2.new(0.5, -150, 0.5, -210)
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

    local function makeSectionButton(text, icon, y, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 260, 0, 48)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = icon .. "   " .. text
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.Parent = panel

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Secciones con iconos
    makeSectionButton("ESP", "👁️", 60, function()
        espOn = not espOn
        updateESP()
    end)

    makeSectionButton("Aimbot", "🎯", 115, function()
        aimOn = not aimOn
        setPOVVisible(aimOn)
    end)

    makeSectionButton("Antena", "📡", 170, function()
        antennaOn = not antennaOn
        updateAntennas()
    end)

    makeSectionButton("Auto Disparo", "🔫", 225, function()
        autoShootOn = not autoShootOn
    end)

    makeSectionButton("Anti-Lag", "⚡", 280, function()
        antiLagOn = not antiLagOn
        setAntiLag(antiLagOn)
    end)

    -- Botón Reiniciar Ronda
    makeSectionButton("Reiniciar Ronda", "🔄", 335, resetRound)

    -- Botón Cerrar
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

    -- Abrir/Cerrar panel
    toggleBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)
end

-- Crear círculo POV (sin cambios)
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

-- Inicializar todo
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

    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        if espOn then updateESP() end
        if antennaOn then updateAntennas() end
    end)

    print("✅ Mod Menu cargado - Botón central activado")
end

start()
