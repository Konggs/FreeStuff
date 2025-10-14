script_key="kuZRfTRFtCwHfhbbQzjoRrhQQMEqLizr";
getgenv().YuukiHub = {
    ["Performance"] = {["FPS Lock"] = 2, ["Low CPU"] = true},
    ["Buy Seed"] = {
        "King Limone Seed","Mango Seed","Shroombino Seed","Tomatrio Seed","Mr Carrot Seed","Carnivorous Plant Seed","Grape Seed","Cocotank Seed","Watermelon Seed",
        ["Eggplant Seed"] = 5,["Dragon Fruit Seed"] = 5,["Sunflower Seed"] = 5,["Pumpkin Seed"] = 5,["Strawberry Seed"] = 5,["Cactus Seed"] = 5},
    ["Buy Gears"] = {"Water Bucket","Frost Grenade"},
    ["Auto Rebirth"] = 6,
    ["Ignore Sell"] = {},
    ["Use Frost Grenade HP"] = 100000,  -- Brainrot HP >= 100k will use Frost Grenade (0 = off) or BOSS
    ["Use Frost Grenade For"] = {},
    ["Use Water Bucket For"] = { "Mythic","Godly","Limited","Secret"},
    ["Equip Card"] = {
        "Doom Bloom","Bloom Ascendant","Plant Frenzy","Overgrowth","Brainrot Blessing","Epic Collection",
        "Home Run","Batter Up","Time Blossom","Chain Lightning","Toxic Cloud","Frozen Blast",
        "Secret Slayer","Solar Burst","Whirlwind","Rare Collection",
        "Petal Storm","Inferno Petal","Tile Trio","Secret Collection","Limited Collection","Rizzrot Manifestation",
        "Cactus Flurry","Sunflower Flurry","Pumpkin Flurry","Common Collection"
    },
    ["Auto Redeem Quest Event"] = true,
    ["Delays Arrange Plant"] = 300,
    ["Ignore Keep Until Max Rebirth"] = true,
    ["Keep Plant Rarity"] = { "Secret", "Limited", "Godly" },
    ["Keep Brainrot Money Per Second"] = 20000, -- Keep Brainrot with $/s ≥ 20k
    ["Start Delete Plant At"] = 100,
    ["Start Delete Brainrot At"] = 100,
}
repeat wait()spawn(function()loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/2c0716d3a841a2f1ed0569a57ff337f8.lua"))()end)wait(20)until getgenv().Loaded
