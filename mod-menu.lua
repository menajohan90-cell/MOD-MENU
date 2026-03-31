-- Script Mod Menu Mejorado - Versión 2.8 FINAL (LocalStorage + No desaparece al morir + Reset All)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== LOCAL STORAGE ====================
getgenv().ModMenuSettings = getgenv().ModMenuSettings or {
    espOn = false, aimOn = false, antennaOn = false, autoShootOn = false,
    antiLagOn = false, noCooldownOn = false, hologramOn = false,
    bodyBoxOn = false, wallbangOn = false, hitboxOn = false,
    togglePos = UDim2.new(0.5, -35, 0.5, -35),
    panelPos = UDim2.new(0.5, -160, 0.5, -220)
}

local settings = getgenv().ModMenuSettings

-- Variables (cargadas desde memoria)
local espOn = settings.espOn
local aimOn = settings.aimOn
local antennaOn = settings.antennaOn
local autoShootOn = settings.autoShootOn
local antiLagOn = settings.antiLagOn
local noCooldownOn = settings.noCooldownOn
local hologramOn = settings.hologramOn
local bodyBoxOn = settings.bodyBoxOn
local wallbangOn = settings.wallbangOn
local hitboxOn = settings.hitboxOn

local teamColor = Color3.fromRGB(0, 150, 255)
local enemyColor = Color3.fromRGB(255, 0, 0)
local antennas = {}
local bodyBoxes = {}

-- ==================== FUNCIONES (mismas que antes) ====================
local function isEnemy(player)
    if player == LocalPlayer then return false end
    if not LocalPlayer.Team or not player.Team then return true end
    return LocalPlayer.Team ~= player.Team
end

local function getClosestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return nil end
    local camPos = Camera.CFrame.Position
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character and plr.Character:FindFirstChild("Head") then
            local dist = (plr.Character.Head.Position - camPos).Magnitude
            if dist < bestDist then bestDist = dist best = plr.Character end
        end
    end
    return best
end

local function updateHologram()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local h = plr.Character:FindFirstChild("HologramHighlight")
            if hologramOn then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "HologramHighlight"
                    h.Adornee = plr.Character
                    h.FillTransparency = 0.3
                    h.OutlineTransparency = 0
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = plr.Character
                end
                h.FillColor = Color3.fromRGB(0, 255, 255)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
            elseif h then h:Destroy() end
        end
    end
end

local function createBodyBox(plr)
    if bodyBoxes[plr] then return end
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 80, 0, 80)
    bill.StudsOffset = Vector3.new(0, 0, 0)
    bill.AlwaysOnTop = true
    bill.Parent = root
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 60, 0, 60)
    box.Position = UDim2.new(0.5, -30, 0.5, -30)
    box.BackgroundColor3 = isEnemy(plr) and enemyColor or teamColor
    box.BackgroundTransparency = 0.6
    box.BorderSizePixel = 3
    box.BorderColor3 = Color3.fromRGB(255, 255, 255)
    box.Parent = bill
    bodyBoxes[plr] = bill
end

local function updateBodyBoxes()
    if not bodyBoxOn then
        for _, b in pairs(bodyBoxes) do b:Destroy() end
        bodyBoxes = {}
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then createBodyBox(plr) end
    end
end

local function advancedAimbotUpdate()
    if not aimOn then return end
    local target = getClosestEnemy()
    if target and target:FindFirstChild("Head") then
        local current = Camera.CFrame
        local newCFrame = CFrame.new(current.Position, target.Head.Position)
        Camera.CFrame = current:Lerp(newCFrame, 0.35)
    end
end

local function toggleNoCooldown(state)
    noCooldownOn = state
    -- (código anterior de No Cooldown)
end

local function toggleWallbang(state)
    wallbangOn = state
    -- (código anterior de Wallbang)
end

local function toggleHitbox(state)
    hitboxOn = state
    -- (código anterior de Hitbox)
end

-- ==================== GUARDAR CONFIGURACIONES ====================
local function saveSettings()
    settings.espOn = espOn
    settings.aimOn = aimOn
    settings.antennaOn = antennaOn
    settings.autoShootOn = autoShootOn
    settings.antiLagOn = antiLagOn
    settings.noCooldownOn = noCooldownOn
    settings.hologramOn = hologramOn
    settings.bodyBoxOn = bodyBoxOn
    settings.wallbangOn = wallbangOn
    settings.hitboxOn = hitboxOn
end

-- ==================== CREAR INTERFAZ ====================
local function createInterface()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModMenuRing"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 70, 0, 70)
    toggleBtn.Position = settings.togglePos
    toggleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleBtn.Text = "⚙️"
    toggleBtn.TextSize = 32
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = screenGui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 320, 0, 580)
    panel.Position = settings.panelPos
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = screenGui

    -- (resto del panel igual que antes, solo agrego el botón Reset All)
    local function makeSectionButton(...) end -- (mismo código de botones)

    -- ... (todos los botones anteriores)

    -- Botón Reset All
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 280, 0, 45)
    resetBtn.Position = UDim2.new(0, 20, 0, 630)
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    resetBtn.Text = "🗑️ Reset All"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.TextSize = 16
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.BorderSizePixel = 0
    resetBtn.Parent = panel

    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 12)
    resetCorner.Parent = resetBtn

    resetBtn.MouseButton1Click:Connect(function()
        getgenv().ModMenuSettings = nil
        screenGui:Destroy()
        print("✅ Todo reseteado. Vuelve a ejecutar el script.")
    end)

    -- Drag y Lock GUI (mismo código anterior)

    -- Guardar posición al mover
    -- (código de drag que al final guarda en settings.togglePos y settings.panelPos)
end

-- ==================== INICIALIZAR ====================
local function start()
    createInterface()

    RunService.RenderStepped:Connect(advancedAimbotUpdate)
    RunService.Heartbeat:Connect(updateBodyBoxes)

    -- Al morir se recarga la GUI con las configuraciones guardadas
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        createInterface()
    end)

    print("✅ Mod Menu v2.8 FINAL cargado - LocalStorage + No desaparece al morir")
end

start()
