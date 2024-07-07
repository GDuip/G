--load hitbox module
_G.HitboxEnabled = false
_G.HSize = 20
_G.Size = 5
_G.HitboxType = 1
_G.Transparency = 0.7
game:GetService('RunService').RenderStepped:connect(function()
    if _G.HitboxEnabled then
        for i,v in next, game:GetService('Players'):GetPlayers() do
        if v.Name ~= game:GetService('Players').LocalPlayer.Name then
        pcall(function()
        if _G.HitboxType == 1 then
            v.Character.Head.Size = Vector3.new(1.2,1.2,1.2)
            v.Character.HumanoidRootPart.Size = Vector3.new(_G.HSize,_G.HSize,_G.HSize)
            v.Character.HumanoidRootPart.Transparency = _G.Transparency
            v.Character.HumanoidRootPart.BrickColor = v.TeamColor
            v.Character.HumanoidRootPart.Material = "Neon"
            v.Character.HumanoidRootPart.CanCollide = false
        elseif _G.HitboxType == 2 then
            v.Character.HumanoidRootPart.Transparency = 1
            v.Character.Head.Size = Vector3.new(_G.Size,_G.Size,_G.Size)
            v.Character.Head.Transparency = _G.Transparency
            v.Character.Head.BrickColor = v.TeamColor
            v.Character.Head.Material = "Neon"
            v.Character.Head.CanCollide = false
        end
        end)
        end
        end
    end
end)

function ClearHitBox()
    for i,v in next, game:GetService('Players'):GetPlayers() do
        if v.Name ~= game:GetService('Players').LocalPlayer.Name then
            pcall(function()
                v.Character.Head.Size = Vector3.new(1.2,1.2,1.2)
                v.Character.Head.Transparency = 0
                v.Character.HumanoidRootPart.Transparency = 1
            end)
            end
        end     
end
print("Hit Box Module Loaded!")