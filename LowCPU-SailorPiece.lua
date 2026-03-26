getgenv().LowCPU = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
for _,v in ipairs(Players:GetPlayers()) do if v ~= plr then if v.Character then v.Character:Destroy() end v:Destroy() end end
Players.ChildAdded:Connect(function(v) if v ~= plr then v:Destroy() end end)
Workspace.ChildAdded:Connect(function(v)
    if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then
        local p = Players:GetPlayerFromCharacter(v)
        if p and p ~= plr then task.delay(5,function() v:Destroy() end) end
    end
end)
local AbilitySystem = ReplicatedStorage:FindFirstChild("AbilitySystem")
if AbilitySystem then for _, v in pairs(AbilitySystem:GetChildren()) do if v.Name == "Animations" or v.Name == "Backups" or v.Name == "VFX" or v.Name == "VFXHandlers" then v:Destroy() end end end
local CombatSystem = ReplicatedStorage:FindFirstChild("CombatSystem")
if CombatSystem then for _, v in pairs(CombatSystem:GetChildren()) do if v.Name == "Animations" or v.Name == "VFX" then v:Destroy() end end end
for _,v in pairs({"SoundEffects","VFXAssets","VFXAssetsAbilities"}) do local f = ReplicatedStorage:FindFirstChild(v) if f then f:Destroy() end end
local Effects = Workspace:FindFirstChild("Effects")
if Effects then Effects:Destroy() end
local Terrain = Workspace.Terrain
Lighting:ClearAllChildren()
local AnimConn = {}
local function optimize(v)
    if v:IsA("BasePart") then v.Material = Enum.Material.Plastic v.Reflectance = 0 v.Transparency = 1 v.CastShadow = false end
    if v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0) v.Enabled = false
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1 v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("SpotLight") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic v.Reflectance = 0 v.TextureID = "" v.Transparency = 1
    elseif v:IsA("SpecialMesh") then
        v.TextureId = ""
    elseif v:IsA("SurfaceAppearance") then
        v:Destroy()
    elseif v:IsA("Sound") then
        v:Destroy()
    elseif v:IsA("Animator") then
        for _,track in ipairs(v:GetPlayingAnimationTracks()) do track:Stop() end
        if not AnimConn[v] then AnimConn[v] = v.AnimationPlayed:Connect(function(track) track:Stop() end) end
    elseif v:IsA("Humanoid") or v:IsA("AnimationController") then
        local animator = v:FindFirstChildOfClass("Animator")
        if animator then
            for _,track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop() end
            if not AnimConn[animator] then AnimConn[animator] = animator.AnimationPlayed:Connect(function(track) track:Stop() end) end
        end
    end
end
for i, v in pairs(game:GetDescendants()) do
    if v.ClassName == "WedgePart" or v.ClassName == "Terrain" or v.ClassName == "MeshPart" then v.BrickColor = BrickColor.new(155, 155, 155) v.Material = "Plastic" v.Transparency = 1 end
    if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then v.Material = "Plastic" v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then v.BlastPressure = 1 v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = false
    elseif v:IsA("MeshPart") then v.Material = "Plastic" v.Reflectance = 0 v.TextureID = 10385902758728957 end
end
for i1,v1 in ipairs(Workspace:GetChildren()) do if v1.Name == "Model" or v1.Name == "Npc Circle" or v1.Name == "Trees" then v1:Destroy() end end
for _,v in ipairs(Workspace:GetDescendants()) do pcall(optimize,v) end
Workspace.DescendantAdded:Connect(function(v) pcall(optimize,v) end)
for _,v in ipairs(SoundService:GetDescendants()) do if v:IsA("Sound") then v:Destroy() end end
SoundService.DescendantAdded:Connect(function(v) if v:IsA("Sound") then v:Destroy() end end)
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 0
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
for _,v in Lighting:GetChildren() do if v:IsA("PostEffect") then v.Enabled = false end end
Lighting.ChildAdded:Connect(function(v) if v:IsA("PostEffect") then v.Enabled = false end end)
Terrain.WaterWaveSize = 0
Terrain.WaterWaveSpeed = 0
Terrain.WaterReflectance = 0
Terrain.WaterTransparency = 0
Workspace.ClientAnimatorThrottling = Enum.ClientAnimatorThrottlingMode.Enabled
Workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Enabled
Workspace.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
settings():GetService("RenderSettings").EagerBulkExecution = false
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
getgenv().LowCPU_Loaded = true
