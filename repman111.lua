local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Don't execute if you're 1nedu
if LocalPlayer.Name == "1nedu" then return end

-- FPS cap
if setfpscap then setfpscap(5) elseif set_fps_cap then set_fps_cap(5) end

-- Check whitelist including special 209flaw
local function OnlyWhitelistedInGame()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name ~= "209flaw" and not whitelist[plr.Name] then
            return false
        end
    end
    return true
end

-- Wait for LocalPlayer character to load
if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    LocalPlayer.CharacterAdded:Wait()
end

-- Teleport loop
task.spawn(function()
    while task.wait(0.5) do
        if OnlyWhitelistedInGame() then
            local target = Players:FindFirstChild("1nedu")
            if target then
                -- Wait for target character
                local targetChar = target.Character or target.CharacterAdded:Wait()
                local targetHRP = targetChar:WaitForChild("HumanoidRootPart", 5)
                local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and targetHRP then
                    -- Teleport
                    myHRP.CFrame = targetHRP.CFrame
                end
            end
        end
        -- Pauses automatically if non-whitelisted present
    end
end)
