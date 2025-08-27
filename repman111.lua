local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if setfpscap then setfpscap(5) elseif set_fps_cap then set_fps_cap(5) end

local function OnlyWhitelistedInGame()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name ~= "1nedu" and plr.Name ~= "209flaw" and not whitelist[plr.Name] then
            return false
        end
    end
    return true
end

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

task.spawn(function()
    while task.wait(0.5) do
        if OnlyWhitelistedInGame() then
            local target = Players:FindFirstChild("1nedu")
            if target then
                local targetChar = target.Character or target.CharacterAdded:Wait()
                local targetHRP = targetChar:WaitForChild("HumanoidRootPart", 5)
                local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and targetHRP then
                    myHRP.CFrame = targetHRP.CFrame
                end
            end
        end
    end
end)
