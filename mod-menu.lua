-- MOD MENU PRO LIMPIO COMPLETO

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CONFIG ====================
local hologramColor = Color3.fromRGB(0,255,200)
local hitboxMaxSize = 40
local hitboxColor = Color3.fromRGB(255,0,0)

-- Toggles
local espOn = false
local bodyBoxOn = false
local aimAssist = false
local triggerAssist = false
local recoilControl = false
local hitboxOn = false

local bodyBoxes = {}

-- ==================== HOLOGRAMA ====================
local function updateHologram()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local h = char:FindFirstChild("HL")

            if espOn then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "HL"
                    h.Adornee = char
                    h.FillColor = hologramColor
                    h.FillTransparency = 0.2
                    h.OutlineColor = Color3.fromRGB(255,0,255)
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = char
                end
            elseif h then
                h:Destroy()
            end
        end
    end
end

-- ==================== BODY BOX ====================
local function createBodyBox(plr)
    if bodyBoxes[plr] then return end
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local bill = Instance.new("BillboardGui", root)
    bill.Size = UDim2.new(0,80,0,80)
    bill.AlwaysOnTop = true

    local frame = Instance.new("Frame", bill)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.fromRGB(255,0,255)

    bodyBoxes[plr] = bill
end

local function updateBodyBoxes()
    if not bodyBoxOn then
        for _,v in pairs(bodyBoxes) do v:Destroy() end
        bodyBoxes = {}
        return
    end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then createBodyBox(plr) end
    end
end

-- ==================== AIM ASSIST ====================
local function aimAssistFunc()
    if not aimAssist then return end

    local closest,dist = nil,math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local pos,onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local d = (Vector2.new(pos.X,pos.Y)-center).Magnitude
                if d < dist then
                    dist = d
                    closest = plr
                end
            end
        end
    end

    if closest then
        local head = closest.Character.Head
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position,head.Position),
            0.1
        )
    end
end

-- ==================== TRIGGER ====================
RunService.RenderStepped:Connect(function()
    if triggerAssist then
        local mouse = LocalPlayer:GetMouse()
        local t = mouse.Target
        if t and t.Parent:FindFirstChild("Humanoid") then
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end
    end
end)

-- ==================== RECOIL CONTROL ====================
RunService.RenderStepped:Connect(function()
    if recoilControl then
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Camera.CFrame.LookVector),
            0.08
        )
    end
end)

-- ==================== HITBOX ====================
local function toggleHitbox(state)
    hitboxOn = state

    if state then
        spawn(function()
            while hitboxOn do
                for _,plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local root = plr.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Size = Vector3.new(hitboxMaxSize,hitboxMaxSize,hitboxMaxSize)
                            root.Color = hitboxColor
                            root.Material = Enum.Material.Neon
                            root.Transparency = 0.4
                            root.CanCollide = false
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    end
end

-- ==================== FOV ====================
local fov = Drawing.new("Circle")
fov.Radius = 150
fov.Color = Color3.fromRGB(0,255,200)
fov.Thickness = 2
fov.Filled = false

RunService.RenderStepped:Connect(function()
    fov.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
end)

-- ==================== UI ====================
local function createInterface()
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0,60,0,60)
    btn.Position = UDim2.new(0.5,-30,0.5,-30)
    btn.Text = "⚙️"

    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.new(0,300,0,400)
    panel.Position = UDim2.new(0.5,-150,0.5,-200)
    panel.Visible = false

    btn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)

    local function makeButton(name,y,callback)
        local b = Instance.new("TextButton", panel)
        b.Size = UDim2.new(0,260,0,40)
        b.Position = UDim2.new(0,20,0,y)
        b.Text = name.." OFF"

        local state=false
        b.MouseButton1Click:Connect(function()
            state = not state
            b.Text = name.." "..(state and "ON" or "OFF")
            callback(state)
        end)
    end

    makeButton("Holograma",20,function(v) espOn=v updateHologram() end)
    makeButton("BodyBox",70,function(v) bodyBoxOn=v end)
    makeButton("Aim Assist",120,function(v) aimAssist=v end)
    makeButton("Trigger",170,function(v) triggerAssist=v end)
    makeButton("Recoil",220,function(v) recoilControl=v end)
    makeButton("Hitbox",270,toggleHitbox)
end

-- ==================== START ====================
createInterface()
RunService.RenderStepped:Connect(aimAssistFunc)
RunService.Heartbeat:Connect(updateBodyBoxes)

print("✅ MOD MENU PRO LIMPIO CARGADO")
