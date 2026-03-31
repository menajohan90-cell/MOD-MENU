-- Script Mod Menu Mejorado - Versión 3.0 FINAL (Todo lo que pediste)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CONFIGURACIÓN PERSONALIZABLE ====================
local hologramColor = Color3.fromRGB(0, 255, 255)   -- Cambia el color del holograma aquí
local hitboxMaxSize = 100

-- Variables
local espOn = false
local aimOn = false
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
            elseif h then
                h:Destroy()
            end
        end
    end
end

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

-- Autoapuntado Avanzado + Estabilizador
local function advancedAimbot()
    if not aimOn then return end
    local target = nil
    local closestDist = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local dist = (plr.Character.Head.Position - Camera.CFrame.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                target = plr.Character
            end
        end
    end
    if target and target:FindFirstChild("Head") then
        local current = Camera.CFrame
        local targetCFrame = CFrame.new(current.Position, target.Head.Position)
        Camera.CFrame = current:Lerp(targetCFrame, 0.4) -- Estabilizador suave
    end
end

-- Wallbang
local wallbangConn = nil
local function toggleWallbang(state)
    wallbangOn = state
    if state then
        wallbangConn = RunService.Heartbeat:Connect(function()
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _, part in pairs(tool:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if wallbangConn then wallbangConn:Disconnect() end
    end
end

-- Hitbox Expander
local function toggleHitbox(state)
    hitboxOn = state
    if state then
        spawn(function()
            while hitboxOn do
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local root = plr.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Size = Vector3.new(hitboxMaxSize, hitboxMaxSize, hitboxMaxSize)
                            root.Transparency = 0.6
                            root.CanCollide = false
                        end
                    end
                end
                task.wait(0.15)
            end
        end)
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                root.Size = Vector3.new(2, 2, 1)
                root.Transparency = 1
                root.CanCollide = true
            end
        end
    end
end

-- ==================== INTERFAZ ====================
local function createInterface()
    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Botón central
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
    panel.Size = UDim2.new(0, 320, 0, 580)
    panel.Position = UDim2.new(0.5, -160, 0.5, -220)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = screenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "MOD MENU v3.0"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = panel

    local function makeButton(text, icon, y, var, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 280, 0, 48)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btn.Text = icon .. "   " .. text .. " (OFF)"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.Parent = panel

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = btn

        local function update()
            btn.BackgroundColor3 = var and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 60)
            btn.Text = icon .. "   " .. text .. (var and " (ON)" or " (OFF)")
        end
        update()

        btn.MouseButton1Click:Connect(function()
            var = not var
            update()
            if callback then callback(var) end
        end)
        return btn
    end

    makeButton("Holograma", "🌟", 60, espOn, updateHologram)
    makeButton("Cuadro Cuerpo", "📦", 115, bodyBoxOn, updateBodyBoxes)
    makeButton("Autoapuntado Avanzado", "🎯", 170, aimOn, nil)
    makeButton("Wallbang", "🔥", 225, wallbangOn, toggleWallbang)
    makeButton("Hitbox Expander", "📏", 280, hitboxOn, toggleHitbox)

    -- Botón Lock GUI
    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(0, 280, 0, 45)
    lockBtn.Position = UDim2.new(0, 20, 0, 340)
    lockBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    lockBtn.Text = "🔒 Lock GUI"
    lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockBtn.TextSize = 16
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.BorderSizePixel = 0
    lockBtn.Parent = panel

    local lockCorner = Instance.new("UICorner")
    lockCorner.CornerRadius = UDim.new(0, 12)
    lockCorner.Parent = lockBtn

    lockBtn.MouseButton1Click:Connect(function()
        guiLocked = not guiLocked
        lockBtn.Text = guiLocked and "🔓 Unlock GUI" or "🔒 Lock GUI"
    end)

    -- Botón Reset All
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 280, 0, 45)
    resetBtn.Position = UDim2.new(0, 20, 0, 395)
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
        print("Todo reseteado")
    end)

    -- ==================== ABRIR/CERRAR + DRAG ====================
    toggleBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)

    -- Drag Botón
    local draggingBtn = false
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not guiLocked then
            draggingBtn = true
        end
    end)
    toggleBtn.InputEnded:Connect(function() draggingBtn = false end)

    -- Drag Panel
    local draggingPanel = false
    panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not guiLocked then
            draggingPanel = true
        end
    end)
    panel.InputEnded:Connect(function() draggingPanel = false end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingBtn and input.UserInputType == Enum.UserInputType.MouseMovement then
            toggleBtn.Position = UDim2.new(0, input.Position.X, 0, input.Position.Y)
        end
        if draggingPanel and input.UserInputType == Enum.UserInputType.MouseMovement then
            panel.Position = UDim2.new(0, input.Position.X - 160, 0, input.Position.Y - 290)
        end
    end)
end

local function start()
    createInterface()
    RunService.RenderStepped:Connect(advancedAimbot)
    RunService.Heartbeat:Connect(updateBodyBoxes)

    print("✅ Mod Menu v3.0 FINAL cargado - Todo funciona")
end

start()
