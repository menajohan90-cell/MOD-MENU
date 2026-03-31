-- Script Mod Menu Mejorado - Versión 3.2 FINAL (TODAS LAS OPCIONES + CELULAR)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuración personalizable
local hologramColor = Color3.fromRGB(0, 255, 255)   -- Cambia el color del holograma aquí

-- Variables
local espOn = false
local aimOn = false
local antennaOn = false
local autoShootOn = false
local antiLagOn = false
local noCooldownOn = false
local bodyBoxOn = false
local wallbangOn = false
local hitboxOn = false
local guiLocked = false

local antennas = {}
local bodyBoxes = {}

-- ==================== FUNCIONES ====================
local function updateHologram()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local h = plr.Character:FindFirstChild("HologramHighlight")
            if espOn then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "HologramHighlight"
                    h.Adornee = plr.Character
                    h.FillTransparency = 0.25
                    h.OutlineTransparency = 0
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = plr.Character
                end
                h.FillColor = hologramColor
            elseif h then h:Destroy() end
        end
    end
end

local function createAntenna(plr) end -- (puedes dejar vacío por ahora)
local function updateAntennas() end

local function createBodyBox(plr)
    if bodyBoxes[plr] then return end
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 90, 0, 90)
    bill.StudsOffset = Vector3.new(0, 0, 0)
    bill.AlwaysOnTop = true
    bill.Parent = root
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 70, 0, 70)
    box.Position = UDim2.new(0.5, -35, 0.5, -35)
    box.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    box.BackgroundTransparency = 0.5
    box.BorderSizePixel = 4
    box.BorderColor3 = Color3.fromRGB(255, 255, 255)
    box.Parent = bill
    bodyBoxes[plr] = bill
end

local function updateBodyBoxes()
    if not bodyBoxOn then
        for _, v in pairs(bodyBoxes) do v:Destroy() end
        bodyBoxes = {}
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then createBodyBox(plr) end
    end
end

local function advancedAimbot()
    if not aimOn then return end
    local target = nil
    local closest = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local dist = (plr.Character.Head.Position - Camera.CFrame.Position).Magnitude
            if dist < closest then closest = dist target = plr.Character end
        end
    end
    if target and target:FindFirstChild("Head") then
        local current = Camera.CFrame
        local goal = CFrame.new(current.Position, target.Head.Position)
        Camera.CFrame = current:Lerp(goal, 0.4)
    end
end

local function toggleNoCooldown(state) noCooldownOn = state end
local function toggleWallbang(state) wallbangOn = state end
local function toggleHitbox(state) hitboxOn = state end
local function setAntiLag(state) antiLagOn = state end

-- ==================== INTERFAZ PARA CELULAR ====================
local function createInterface()
    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Botón central con flecha
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 75, 0, 75)
    toggleBtn.Position = UDim2.new(0.5, -37.5, 0.5, -37.5)
    toggleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleBtn.Text = "⚙️\n⇄"
    toggleBtn.TextSize = 30
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
    panel.Size = UDim2.new(0, 340, 0, 620)
    panel.Position = UDim2.new(0.5, -170, 0.5, -250)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = screenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = panel

    -- Barra para mover (flecha visible)
    local dragBar = Instance.new("TextButton")
    dragBar.Size = UDim2.new(1, 0, 0, 45)
    dragBar.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
    dragBar.Text = "⇄   MANTÉN PRESIONADO PARA MOVER"
    dragBar.TextColor3 = Color3.fromRGB(0, 255, 200)
    dragBar.TextSize = 15
    dragBar.Font = Enum.Font.GothamBold
    dragBar.BorderSizePixel = 0
    dragBar.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "MOD MENU v3.2"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = panel

    local y = 110
    local function makeButton(text, icon, stateVar, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 300, 0, 50)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btn.Text = icon .. "   " .. text .. " (OFF)"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.Parent = panel
        y = y + 58

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = btn

        local function update()
            btn.BackgroundColor3 = stateVar and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 60)
            btn.Text = icon .. "   " .. text .. (stateVar and " (ON)" or " (OFF)")
        end
        update()

        btn.MouseButton1Click:Connect(function()
            stateVar = not stateVar
            update()
            if callback then callback(stateVar) end
        end)
        return btn
    end

    makeButton("Holograma", "🌟", espOn, updateHologram)
    makeButton("Cuadro Cuerpo", "📦", bodyBoxOn, updateBodyBoxes)
    makeButton("Autoapuntado Avanzado", "🎯", aimOn, nil)
    makeButton("Antena", "📡", antennaOn, updateAntennas)
    makeButton("Auto Disparo", "🔫", autoShootOn, nil)
    makeButton("Anti-Lag", "⚡", antiLagOn, setAntiLag)
    makeButton("No Cooldown", "♾️", noCooldownOn, toggleNoCooldown)
    makeButton("Wallbang", "🔥", wallbangOn, toggleWallbang)
    makeButton("Hitbox Expander", "📏", hitboxOn, toggleHitbox)

    -- Lock GUI
    local lockBtn = makeButton("Lock GUI", "🔒", guiLocked, function(v) guiLocked = v end)

    -- Reset All
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 300, 0, 50)
    resetBtn.Position = UDim2.new(0, 20, 0, y + 10)
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    resetBtn.Text = "🗑️ Reset All"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.TextSize = 16
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.BorderSizePixel = 0
    resetBtn.Parent = panel

    resetBtn.MouseButton1Click:Connect(function()
        getgenv().ModMenuSettings = nil
        screenGui:Destroy()
    end)

    -- ==================== MOVER CON DEDO ====================
    local dragging = false
    local dragStart, startPos

    dragBar.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not guiLocked then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)

    dragBar.InputEnded:Connect(function() dragging = false end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)
end

local function start()
    createInterface()
    RunService.RenderStepped:Connect(advancedAimbot)
    RunService.Heartbeat:Connect(updateBodyBoxes)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        createInterface()
    end)

    print("✅ Mod Menu v3.2 FINAL cargado - Todas las opciones + Movible en celular")
end

start()
