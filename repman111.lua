local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🛑 Don't execute if you're 1nedu
if LocalPlayer.Name == "1nedu" then
    return
end

-- FPS cap to 5 (executor specific)
if setfpscap then
    setfpscap(5)
elseif set_fps_cap then
    set_fps_cap(5)
end

-- Function: checks if only whitelisted players are in game
local function OnlyWhitelistedInGame()
    for _, plr in ipairs(Players:GetPlayers()) do
        -- Special case: 209flaw is allowed even if not in the loader whitelist
        if plr.Name ~= "209flaw" and not whitelist[plr.Name] then
            return false
        end
    end
    return true
end

-- Teleport loop (to "1nedu")
task.spawn(function()
    while task.wait(0.5) do
        if OnlyWhitelistedInGame() then
            local target = Players:FindFirstChild("1nedu")
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = target.Character.HumanoidRootPart.CFrame
                end
            end
        end
        -- If non-whitelisted player is in game, loop just idles
    end
end)
