local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("Script started for", LocalPlayer.Name)

if setfpscap then
    setfpscap(5)
elseif set_fps_cap then
    set_fps_cap(5)
end

local function OnlyWhitelistedInGame()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name ~= "1nedu" and plr.Name ~= "209flaw" and not whitelist[plr.Name] then
            print("Non-whitelisted player detected:", plr.Name)
            return false
        end
    end
    return true
end

repeat 
    task.wait() 
until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
print("LocalPlayer character loaded")

task.spawn(function()
    while task.wait(0.5) do
        print("Loop running...")
        if OnlyWhitelistedInGame() then
            local target = Players:FindFirstChild("1nedu")
            if target then
                print("Found 1nedu")
                local targetChar = target.Character or target.CharacterAdded:Wait()
                local targetHRP = targetChar:WaitForChild("HumanoidRootPart", 5)
                local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and targetHRP then
                    print("Teleporting to 1nedu")
                    myHRP.CFrame = targetHRP.CFrame
                else
                    print("HumanoidRootPart missing for teleport")
                end
            else
                print("1nedu not found in server")
            end
        else
            print("Non-whitelisted players present, teleport paused")
        end
    end
end)
