local Lighting = game:GetService("Lighting")
local Terrain = game:GetService("Terrain")

pcall(function()
    Lighting.Brightness = 1
    Lighting.FogEnd = 1e6
    Lighting.GlobalShadows = false
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.ClockTime = 14
    Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end
    for _, obj in ipairs(Lighting:GetDescendants()) do
        pcall(function()
            if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BlurEffect") then
                obj.Enabled = false
            end
        end)
    end
end)

local function optimizeObject(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = 1
        elseif obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.fromRGB(128,128,128)
            obj.CastShadow = false
            if obj:IsA("MeshPart") then
                obj.TextureID = ""
            end
        end
    end)
end

for _, obj in ipairs(game:GetDescendants()) do
    optimizeObject(obj)
end

game.DescendantAdded:Connect(function(obj)
    optimizeObject(obj)
end)
local function DisableAnimation(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop() end
            animator.AnimationPlayed:Connect(function(track) track:Stop() end)
        end
    end
    local animController = model:FindFirstChildOfClass("AnimationController")
    if animController then
        local animator = animController:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
            animator.AnimationPlayed:Connect(function(track)
                track:Stop()
            end)
        end
    end
end
local function DisableMeshPart(meshPart) meshPart.Transparency = 1 meshPart.CanCollide = false meshPart.CanTouch = false meshPart.CanQuery = false end
local function DisableParticle(emitter) emitter.Enabled = false end
for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
    if obj:IsA("Model") then
        DisableAnimation(obj)
    elseif obj:IsA("MeshPart") then
        DisableMeshPart(obj)
    elseif obj:IsA("ParticleEmitter") then
        DisableParticle(obj)
    end
end
game:GetService("Workspace").DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        DisableAnimation(obj)
    elseif obj:IsA("Humanoid") or obj:IsA("AnimationController") then
        local model = obj.Parent
        if model and model:IsA("Model") then
            DisableAnimation(model)
        end
    elseif obj:IsA("MeshPart") then
        DisableMeshPart(obj)
    elseif obj:IsA("ParticleEmitter") then
        DisableParticle(obj)
    end
end)
for _, obj in ipairs(game:GetService("Workspace"):GetChildren()) do
    if obj:IsA("Part") or obj:IsA("MeshPart") then
        obj:Destroy()
    end
end
game:GetService("Workspace").ChildAdded:Connect(function(obj)
    if obj:IsA("Part") or obj:IsA("MeshPart") then
        obj:Destroy()
    end
end)
