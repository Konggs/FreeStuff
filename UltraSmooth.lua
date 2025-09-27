task.wait(10)
for i,v in next, workspace:GetDescendants() do pcall(function() v.Transparency = 1 end) end
a = workspace
a.DescendantAdded:Connect(function(v) pcall(function() v.Transparency = 1 end) end)
workspace.ClientAnimatorThrottling = Enum.ClientAnimatorThrottlingMode.Enabled
workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Enabled
settings():GetService("RenderSettings").EagerBulkExecution = false
workspace.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
game:GetService("Lighting").GlobalShadows = false
settings().Rendering.QualityLevel = "Level01"
local g = game
local w = g.Workspace
local l = g.Lighting
local t = w.Terrain
t.WaterWaveSize = 0
t.WaterWaveSpeed = 0
t.WaterReflectance = 0
t.WaterTransparency = 0
l.GlobalShadows = false
l.FogEnd = 9e9
l.Brightness = 0
for i, v in pairs(g:GetDescendants()) do
    if v.ClassName == "WedgePart"
    or v.ClassName == "Terrain"
    or v.ClassName == "MeshPart" then
        v.BrickColor = BrickColor.new(155, 155, 155)
        v.Material = "Plastic"
        v.Transparency = 1
    end
    if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then 
        v.Material = "Plastic"
        v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.TextureID = 10385902758728957
    end
end
game.Workspace.ChildAdded:Connect(function()
    pcall(function()
        if v.ClassName == "WedgePart"
        or v.ClassName == "Terrain"
        or v.ClassName == "MeshPart" then
            v.BrickColor = BrickColor.new(155, 155, 155)
            v.Material = "Plastic"
            v.Transparency = 1
        end
        if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then 
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
            v.TextureID = 10385902758728957
        end
    end)
end)
for i, e in pairs(l:GetChildren()) do
    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
        e.Enabled = false
    end
end
game.Lighting.ChildAdded:Connect(function(v)
    if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
        v.Enabled = false
    end
end)
game:GetService("RunService"):Set3dRenderingEnabled(false)

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
