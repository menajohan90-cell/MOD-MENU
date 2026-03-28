-- Script de pruebas con botón visible desde el inicio
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

-- Funciones auxiliares
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

-- ESP
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

-- Antena (cuadro con línea)
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

-- Autoapuntado
local function aimbotUpdate()
    if not aimOn then return end
    local target = getClosestEnemy()
    if target and target:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
        if autoShootOn then
            -- Simulación de disparo (en Studio solo imprime)
            print("[AUTO] Disparando a", target.Parent.Name)
        end
    end
end

-- POV: círculo en pantalla
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

-- Anti-lag
local originalShadows
local function setAntiLag(state)
    if state then
        originalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
    elseif originalShadows ~= nil then
        Lighting.GlobalShadows = originalShadows
    end
end

-- Reinicio de ronda (ejemplo)
local function resetRound()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        print("Ronda reiniciada")
    end
end

-- Crear interfaz (botón y panel)
local function createInterface()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TestGUI"
    screenGui.Parent = playerGui

    -- Botón flotante (siempre visible)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 10, 0, 10)
    toggleBtn.Text = "🔧"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BorderSizePixel = 1
    toggleBtn.Parent = screenGui

    -- Panel (inicialmente oculto)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 250, 0, 380)
    panel.Position = UDim2.new(0, 70, 0, 10)
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    panel.BackgroundTransparency = 0.1
    panel.BorderSizePixel = 1
    panel.Visible = false
    panel.Parent = screenGui

    local function makeButton(text, y, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 220, 0, 32)
        btn.Position = UDim2.new(0, 15, 0, y)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.Parent = panel
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local espBtn = makeButton("ESP (OFF)", 40, function()
        espOn = not espOn
        espBtn.Text = espOn and "ESP (ON)" or "ESP (OFF)"
        updateESP()
    end)

    local aimBtn = makeButton("Autoapuntado (OFF)", 80, function()
        aimOn = not aimOn
        aimBtn.Text = aimOn and "Autoapuntado (ON)" or "Autoapuntado (OFF)"
        setPOVVisible(aimOn)
    end)

    local antBtn = makeButton("Antena (OFF)", 120, function()
        antennaOn = not antennaOn
        antBtn.Text = antennaOn and "Antena (ON)" or "Antena (OFF)"
        updateAntennas()
    end)

    local shootBtn = makeButton("Autodisparo (OFF)", 160, function()
        autoShootOn = not autoShootOn
        shootBtn.Text = autoShootOn and "Autodisparo (ON)" or "Autodisparo (OFF)"
    end)

    local lagBtn = makeButton("Anti-Lag (OFF)", 200, function()
        antiLagOn = not antiLagOn
        lagBtn.Text = antiLagOn and "Anti-Lag (ON)" or "Anti-Lag (OFF)"
        setAntiLag(antiLagOn)
    end)

    -- Control FOV
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(0, 220, 0, 20)
    fovLabel.Position = UDim2.new(0, 15, 0, 245)
    fovLabel.Text = "FOV: " .. aimFOV .. "°"
    fovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Parent = panel

    local fovBtn = Instance.new("TextButton")
    fovBtn.Size = UDim2.new(0, 100, 0, 25)
    fovBtn.Position = UDim2.new(0, 15, 0, 270)
    fovBtn.Text = "+10°"
    fovBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    fovBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovBtn.Parent = panel
    fovBtn.MouseButton1Click:Connect(function()
        aimFOV = math.min(120, aimFOV + 10)
        fovLabel.Text = "FOV: " .. aimFOV .. "°"
        updatePOVCircle()
    end)

    local fovMinus = Instance.new("TextButton")
    fovMinus.Size = UDim2.new(0, 100, 0, 25)
    fovMinus.Position = UDim2.new(0, 135, 0, 270)
    fovMinus.Text = "-10°"
    fovMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    fovMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovMinus.Parent = panel
    fovMinus.MouseButton1Click:Connect(function()
        aimFOV = math.max(10, aimFOV - 10)
        fovLabel.Text = "FOV: " .. aimFOV .. "°"
        updatePOVCircle()
    end)

    -- Botón reinicio
    local resetBtn = makeButton("Reiniciar Ronda", 310, resetRound)
    resetBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)

    -- Botón cerrar panel
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = panel
    closeBtn.MouseButton1Click:Connect(function()
        panel.Visible = false
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)
end

-- Crear círculo POV
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
    -- Eventos para actualizar cuando aparezcan jugadores
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
    print("Script cargado. Botón visible en la esquina superior izquierda.")
end

start()
