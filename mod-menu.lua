-- 🔥 SOLO HITBOX EXPANDER - Versión Simple
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local hitboxSize = 100          -- Cambia este número si quieres más o menos
local hitboxOn = false
local connection = nil

-- Función principal
local function toggleHitbox()
    hitboxOn = not hitboxOn
    
    if hitboxOn then
        print("✅ Hitbox Activado (Tamaño: "..hitboxSize..")")
        
        connection = RunService.Heartbeat:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        root.Transparency = 0.7
                        root.CanCollide = false
                    end
                end
            end
        end)
    else
        print("❌ Hitbox Desactivado")
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        -- Restaurar tamaño normal
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

-- ==================== BOTÓN FLOTANTE SIMPLE ====================
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0, 20, 0, 20)
btn.Text = "📏\nHITBOX"
btn.TextSize = 18
btn.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.BorderSizePixel = 0
btn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = btn

-- Al tocar el botón se activa/desactiva
btn.MouseButton1Click:Connect(toggleHitbox)

print("✅ Script Solo Hitbox cargado. Toca el botón rojo para activar/desactivar.")
