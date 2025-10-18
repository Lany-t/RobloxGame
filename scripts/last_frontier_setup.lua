--[=[
Last Frontier Setup Script

Paste the contents of this file into the Roblox Studio command bar while editing
an empty baseplate to automatically generate all core assets, scripts, and data
structures required to run the "Last Frontier" cooperative survival mode.

The script can be executed multiple times; it removes previous instances of the
same named objects before recreating them to keep the place clean.
]=]

local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    ServerStorage = game:GetService("ServerStorage"),
    ServerScriptService = game:GetService("ServerScriptService"),
    StarterPlayer = game:GetService("StarterPlayer"),
    StarterGui = game:GetService("StarterGui"),
    StarterPack = game:GetService("StarterPack"),
    Lighting = game:GetService("Lighting"),
    RunService = game:GetService("RunService"),
}

local function clearExisting(container, name)
    local existing = container:FindFirstChild(name)
    if existing then
        existing:Destroy()
    end
end

local function create(className, properties)
    local instance = Instance.new(className)
    for key, value in pairs(properties) do
        if key ~= "Parent" then
            instance[key] = value
        end
    end
    instance.Parent = properties.Parent
    return instance
end

local function createFolder(parent, name)
    clearExisting(parent, name)
    return create("Folder", {
        Name = name,
        Parent = parent,
    })
end

--[[
    ENVIRONMENT SETUP
]]

local mapFolder = createFolder(workspace, "LastFrontierMap")
local decorativeFolder = createFolder(mapFolder, "Decor")
local spawnFolder = createFolder(mapFolder, "ZombieSpawns")
local barricadeFolder = createFolder(mapFolder, "Barricades")

-- Clear existing baseplate style objects created by template, if any
for _, item in ipairs(workspace:GetChildren()) do
    if item:IsA("BasePart") and item.Name == "Baseplate" then
        item:Destroy()
    end
end

local ground = create("Part", {
    Name = "Ground",
    Size = Vector3.new(300, 1, 300),
    Anchored = true,
    Position = Vector3.new(0, 0, 0),
    Parent = mapFolder,
    Material = Enum.Material.Concrete,
    Color = Color3.fromRGB(60, 60, 60),
})

local lobbyPad = create("Part", {
    Name = "LobbyPad",
    Size = Vector3.new(40, 1, 40),
    Anchored = true,
    Position = Vector3.new(0, 0.5, 130),
    Parent = mapFolder,
    Material = Enum.Material.Metal,
    Color = Color3.fromRGB(30, 30, 35),
})

local lobbySpawn = create("SpawnLocation", {
    Name = "LobbySpawn",
    Position = lobbyPad.Position + Vector3.new(0, 1, 0),
    Anchored = true,
    Size = Vector3.new(6, 1, 6),
    Parent = mapFolder,
    Duration = 0,
    Transparency = 1,
    CanCollide = false,
})

local battlefieldSpawn = create("SpawnLocation", {
    Name = "BattlefieldSpawn",
    Position = Vector3.new(0, 1, 0),
    Anchored = true,
    Size = Vector3.new(6, 1, 6),
    Parent = mapFolder,
    Duration = 0,
    Transparency = 1,
    CanCollide = false,
})

local lighting = Services.Lighting
lighting.TimeOfDay = "00:30:00"
lighting.Brightness = 1.5
lighting.ClockTime = 0.5
lighting.GeographicLatitude = 45
lighting.Ambient = Color3.fromRGB(40, 40, 60)
lighting.OutdoorAmbient = Color3.fromRGB(12, 12, 20)

clearExisting(lighting, "Atmosphere")
create("Atmosphere", {
    Parent = lighting,
    Density = 0.35,
    Offset = 0.2,
    Color = Color3.fromRGB(180, 200, 255),
    Decay = Color3.fromRGB(30, 30, 60),
})

clearExisting(lighting, "ColorCorrection")
create("ColorCorrectionEffect", {
    Parent = lighting,
    TintColor = Color3.fromRGB(190, 200, 255),
    Brightness = -0.05,
    Contrast = 0.05,
    Saturation = -0.15,
})

-- Barricades
local barricadePositions = {
    Vector3.new(40, 3, -40),
    Vector3.new(-35, 3, -50),
    Vector3.new(55, 3, 25),
    Vector3.new(-60, 3, 10),
}

for i, position in ipairs(barricadePositions) do
    local barricadeModel = create("Model", {
        Name = "Barricade" .. i,
        Parent = barricadeFolder,
    })

    local frame = create("Part", {
        Name = "Frame",
        Size = Vector3.new(12, 6, 1),
        Anchored = true,
        Position = position,
        Orientation = Vector3.new(0, (i * 50) % 180, 0),
        Parent = barricadeModel,
        Material = Enum.Material.Wood,
        Color = Color3.fromRGB(120, 80, 50),
    })

    local healthValue = create("NumberValue", {
        Name = "Health",
        Value = 300,
        Parent = barricadeModel,
    })

    local maxHealthValue = create("NumberValue", {
        Name = "MaxHealth",
        Value = 300,
        Parent = barricadeModel,
    })

    local prompt = create("ProximityPrompt", {
        Name = "RepairPrompt",
        ActionText = "Repair Barricade",
        ObjectText = "50 Coins",
        HoldDuration = 2,
        RequiresLineOfSight = false,
        Parent = frame,
    })

    prompt:SetAttribute("Cost", 50)
end

-- Zombie spawn points
local spawnPositions = {
    Vector3.new(120, 2, 0),
    Vector3.new(-120, 2, 15),
    Vector3.new(0, 2, -120),
    Vector3.new(85, 2, 110),
    Vector3.new(-90, 2, -105),
}

for index, position in ipairs(spawnPositions) do
    create("Part", {
        Name = "SpawnPoint" .. index,
        Size = Vector3.new(4, 1, 4),
        Anchored = true,
        Transparency = 1,
        CanCollide = false,
        Position = position,
        Parent = spawnFolder,
    })
end

-- Shop terminal
local shopModel = create("Model", {
    Name = "ShopTerminal",
    Parent = mapFolder,
})

local shopBase = create("Part", {
    Name = "Base",
    Size = Vector3.new(6, 6, 6),
    Anchored = true,
    Position = Vector3.new(0, 3, 35),
    Color = Color3.fromRGB(25, 25, 30),
    Material = Enum.Material.Metal,
    Parent = shopModel,
})

local shopScreen = create("Part", {
    Name = "Screen",
    Size = Vector3.new(4, 3, 0.5),
    Anchored = true,
    Position = shopBase.Position + Vector3.new(0, 2, -3),
    Color = Color3.fromRGB(30, 150, 200),
    Material = Enum.Material.Glass,
    Parent = shopModel,
})

local shopPrompt = create("ProximityPrompt", {
    Name = "ShopPrompt",
    ActionText = "Open Shop",
    ObjectText = "Survival Kiosk",
    HoldDuration = 0,
    RequiresLineOfSight = false,
    Parent = shopScreen,
})

-- Decorative lighting
for i = 1, 6 do
    local lamp = create("Part", {
        Name = "StreetLamp" .. i,
        Size = Vector3.new(0.6, 14, 0.6),
        Anchored = true,
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(50, 50, 55),
        Parent = decorativeFolder,
        Position = Vector3.new(-60 + (i - 1) * 20, 7, -20 + (i % 2) * 30),
    })

    local light = create("PointLight", {
        Parent = lamp,
        Range = 35,
        Brightness = 2,
        Color = Color3.fromRGB(255, 220, 170),
    })
end

--[[
    STORAGE STRUCTURE SETUP
]]

local replicated = Services.ReplicatedStorage
local serverStorage = Services.ServerStorage
local sss = Services.ServerScriptService
local starterPlayer = Services.StarterPlayer
local starterGui = Services.StarterGui
local starterPack = Services.StarterPack

local lfFolder = createFolder(replicated, "LastFrontier")
local remoteFolder = createFolder(lfFolder, "Remotes")
local modulesFolder = createFolder(lfFolder, "Modules")
local weaponsFolder = createFolder(lfFolder, "Weapons")
local enemiesFolder = createFolder(lfFolder, "Enemies")

local enemyTemplates = createFolder(serverStorage, "LastFrontierEnemies")
local weaponTemplates = createFolder(serverStorage, "LastFrontierWeapons")

local function createRemoteEvent(name)
    local remote = remoteFolder:FindFirstChild(name)
    if remote then
        remote:Destroy()
    end
    return create("RemoteEvent", {
        Name = name,
        Parent = remoteFolder,
    })
end

local function createRemoteFunction(name)
    local remote = remoteFolder:FindFirstChild(name)
    if remote then
        remote:Destroy()
    end
    return create("RemoteFunction", {
        Name = name,
        Parent = remoteFolder,
    })
end

createRemoteEvent("RequestShot")
createRemoteEvent("ReloadWeapon")
createRemoteEvent("EquipWeapon")
createRemoteEvent("PurchaseItem")
createRemoteEvent("UpdateUi")
createRemoteFunction("GetPlayerData")

--[[
    MODULE SCRIPTS
]]

local function createModule(name, source)
    clearExisting(modulesFolder, name)
    local module = create("ModuleScript", {
        Name = name,
        Parent = modulesFolder,
    })
    module.Source = source
    return module
end

createModule("Config", [[
local Config = {}

Config.MaxPlayers = 6
Config.RoundIntermission = 20
Config.RespawnDelay = 5
Config.StartingCoins = 250
Config.RepairAmount = 150
Config.RepairCost = 50
Config.BarricadeHealPerSecond = 45
Config.ZombieSpawnCap = 15
Config.BaseWalkSpeed = 16
Config.SprintMultiplier = 1.35
Config.WaveReward = {
    Base = 100,
    Increment = 50,
}

return Config
]])

createModule("WeaponsConfig", [[
local Weapons = {
    Pistol = {
        DisplayName = "Guardian Pistol",
        Damage = 18,
        HeadshotMultiplier = 1.8,
        FireRate = 0.25,
        Magazine = 12,
        Reserve = 72,
        ReloadTime = 1.6,
        Range = 200,
        Automatic = false,
        Cost = 0,
    },
    SMG = {
        DisplayName = "Cyclone SMG",
        Damage = 12,
        HeadshotMultiplier = 1.5,
        FireRate = 0.08,
        Magazine = 32,
        Reserve = 160,
        ReloadTime = 1.9,
        Range = 160,
        Automatic = true,
        Cost = 850,
    },
    Shotgun = {
        DisplayName = "Warden Shotgun",
        Damage = 9,
        Pellets = 8,
        HeadshotMultiplier = 1.3,
        FireRate = 0.9,
        Magazine = 6,
        Reserve = 48,
        ReloadTime = 2.5,
        Range = 120,
        Automatic = false,
        Cost = 1100,
    },
    Rifle = {
        DisplayName = "Vanguard Rifle",
        Damage = 30,
        HeadshotMultiplier = 2.0,
        FireRate = 0.3,
        Magazine = 24,
        Reserve = 120,
        ReloadTime = 2.1,
        Range = 250,
        Automatic = true,
        Cost = 1400,
    }
}

return Weapons
]])

createModule("EnemiesConfig", [[
local Enemies = {
    Walker = {
        MaxHealth = 100,
        Damage = 8,
        Speed = 12,
        Coins = 40,
    },
    Runner = {
        MaxHealth = 80,
        Damage = 10,
        Speed = 18,
        Coins = 45,
    },
    Brute = {
        MaxHealth = 220,
        Damage = 20,
        Speed = 10,
        Coins = 80,
    },
}

return Enemies
]])

createModule("WaveConfig", [[
local Waves = {
    [1] = {
        total = 12,
        units = {
            Walker = 12,
        },
    },
    [2] = {
        total = 16,
        units = {
            Walker = 14,
            Runner = 2,
        },
    },
    [3] = {
        total = 18,
        units = {
            Walker = 14,
            Runner = 4,
        },
    },
    [4] = {
        total = 22,
        units = {
            Walker = 16,
            Runner = 4,
            Brute = 2,
        },
    },
    [5] = {
        total = 28,
        units = {
            Walker = 18,
            Runner = 6,
            Brute = 4,
        },
    },
}

setmetatable(Waves, {
    __index = function(self, index)
        local lastWave = rawget(self, index - 1) or self[5]
        local multiplier = 1 + math.min(0.02 * (index - 5), 0.6)
        local generated = {
            total = math.floor(lastWave.total * (1.15 + 0.02 * (index - 5))),
            units = {}
        }
        for enemyType, amount in pairs(lastWave.units) do
            generated.units[enemyType] = math.floor(amount * multiplier)
        end
        return generated
    end
})

return Waves
]])

createModule("EnemyBehaviour", [[
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local EnemyBehaviour = {}
EnemyBehaviour.__index = EnemyBehaviour

function EnemyBehaviour.new(model, stats)
    local self = setmetatable({}, EnemyBehaviour)
    self.Model = model
    self.Humanoid = model:FindFirstChildWhichIsA("Humanoid")
    self.Stats = stats
    self.Target = nil
    self.LastAttack = 0
    self.AttackCooldown = 1.25
    self.Humanoid.WalkSpeed = stats.Speed
    return self
end

function EnemyBehaviour:GetClosestTarget()
    local closest
    local closestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character.PrimaryPart then
            local distance = (player.Character.PrimaryPart.Position - self.Model.PrimaryPart.Position).Magnitude
            if distance < closestDistance then
                closest = player.Character
                closestDistance = distance
            end
        end
    end
    return closest
end

function EnemyBehaviour:Attack(target)
    if not target or not target.PrimaryPart then
        return
    end
    local now = tick()
    if now - self.LastAttack < self.AttackCooldown then
        return
    end
    self.LastAttack = now
    local humanoid = target:FindFirstChildWhichIsA("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:TakeDamage(self.Stats.Damage)
    end
end

function EnemyBehaviour:Step()
    if not self.Model.PrimaryPart or self.Humanoid.Health <= 0 then
        return
    end

    local targetCharacter = self:GetClosestTarget()
    if not targetCharacter or not targetCharacter.PrimaryPart then
        self.Humanoid:Move(Vector3.zero, false)
        return
    end

    local distance = (targetCharacter.PrimaryPart.Position - self.Model.PrimaryPart.Position).Magnitude

    if distance <= 4 then
        self:Attack(targetCharacter)
        self.Humanoid:Move(Vector3.zero, false)
    else
        local targetPosition = targetCharacter.PrimaryPart.Position
        local direction = (targetPosition - self.Model.PrimaryPart.Position).Unit
        self.Humanoid:Move(direction * self.Stats.Speed, false)
    end
end

return EnemyBehaviour
]])

createModule("EnemyFactory", [[
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnemiesConfig = require(ReplicatedStorage.LastFrontier.Modules.EnemiesConfig)

local EnemyFactory = {}

function EnemyFactory:Create(enemyType)
    local templateFolder = ServerStorage:WaitForChild("LastFrontierEnemies")
    local template = templateFolder:FindFirstChild(enemyType)
    if not template then
        error("Enemy template not found: " .. tostring(enemyType))
    end
    local clone = template:Clone()
    clone.Name = enemyType
    local humanoid = clone:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid.MaxHealth = EnemiesConfig[enemyType].MaxHealth
        humanoid.Health = humanoid.MaxHealth
    end
    return clone
end

return EnemyFactory
]])

createModule("WeaponFactory", [[
local ServerStorage = game:GetService("ServerStorage")

local WeaponFactory = {}

function WeaponFactory:Create(weaponName)
    local templateFolder = ServerStorage:WaitForChild("LastFrontierWeapons")
    local template = templateFolder:FindFirstChild(weaponName)
    if not template then
        error("Weapon template missing: " .. tostring(weaponName))
    end
    local clone = template:Clone()
    clone.Name = weaponName
    return clone
end

return WeaponFactory
]])

--[[
    ENEMY MODELS
]]

local function createEnemyModel(name, color)
    clearExisting(enemyTemplates, name)
    local model = create("Model", {
        Name = name,
        Parent = enemyTemplates,
    })

    local root = create("Part", {
        Name = "HumanoidRootPart",
        Size = Vector3.new(2, 2, 1),
        Position = Vector3.new(0, 3, 0),
        Anchored = false,
        Parent = model,
        Color = color,
        Material = Enum.Material.Slate,
    })

    local torso = create("Part", {
        Name = "Torso",
        Size = Vector3.new(2, 2, 1),
        Position = root.Position,
        Anchored = false,
        Parent = model,
        Color = color,
        Material = Enum.Material.Slate,
    })

    local head = create("Part", {
        Name = "Head",
        Size = Vector3.new(1.5, 1.5, 1.5),
        Position = torso.Position + Vector3.new(0, 1.75, 0),
        Anchored = false,
        Parent = model,
        Color = color * 0.8,
        Material = Enum.Material.SmoothPlastic,
        Shape = Enum.PartType.Ball,
    })

    create("WeldConstraint", {
        Part0 = root,
        Part1 = torso,
        Parent = root,
    })

    create("WeldConstraint", {
        Part0 = torso,
        Part1 = head,
        Parent = torso,
    })

    local humanoid = create("Humanoid", {
        Parent = model,
        WalkSpeed = 12,
        MaxHealth = 100,
        Health = 100,
        RigType = Enum.HumanoidRigType.R6,
        HipHeight = 2,
    })

    model.PrimaryPart = root
    root:SetNetworkOwner(nil)
    return model
end

createEnemyModel("Walker", Color3.fromRGB(90, 180, 90))
createEnemyModel("Runner", Color3.fromRGB(120, 200, 120))
createEnemyModel("Brute", Color3.fromRGB(70, 120, 70))

--[[
    WEAPON MODELS
]]

local function createWeaponTemplate(name, properties)
    clearExisting(weaponTemplates, name)
    local tool = create("Tool", {
        Name = name,
        Parent = weaponTemplates,
        RequiresHandle = true,
        CanBeDropped = false,
    })

    local handle = create("Part", {
        Name = "Handle",
        Size = Vector3.new(1.2, 0.4, 2.2),
        Color = properties.Color,
        Material = Enum.Material.Metal,
        Parent = tool,
    })
    handle.Position = Vector3.new(0, 3, 0)

    local attachment = create("Attachment", {
        Name = "Muzzle",
        Position = Vector3.new(0, 0, -1.2),
        Parent = handle,
    })

    local emitter = create("ParticleEmitter", {
        Parent = attachment,
        Speed = NumberRange.new(0),
        Lifetime = NumberRange.new(0.1),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 0)}),
        Texture = "rbxasset://textures/particles/sparkles_main.dds",
        EmissionDirection = Enum.NormalId.Front,
        LightEmission = 0.7,
        Rate = 0,
    })

    local gui = create("BillboardGui", {
        Name = "AmmoDisplay",
        Size = UDim2.new(0, 80, 0, 30),
        StudsOffsetWorldSpace = Vector3.new(0, 1.8, 0),
        AlwaysOnTop = true,
        Parent = handle,
    })

    create("TextLabel", {
        Name = "AmmoLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        TextScaled = true,
        TextColor3 = Color3.new(1, 1, 1),
        Parent = gui,
        Text = "--",
    })

    return tool
end

createWeaponTemplate("Pistol", { Color = Color3.fromRGB(60, 60, 80) })
createWeaponTemplate("SMG", { Color = Color3.fromRGB(40, 120, 180) })
createWeaponTemplate("Shotgun", { Color = Color3.fromRGB(120, 70, 50) })
createWeaponTemplate("Rifle", { Color = Color3.fromRGB(30, 150, 120) })

--[[
    SERVER SCRIPTS
]]

clearExisting(sss, "LastFrontierServer")
local serverScript = create("Script", {
    Name = "LastFrontierServer",
    Parent = sss,
})

serverScript.Source = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local LastFrontier = ReplicatedStorage:WaitForChild("LastFrontier")
local Config = require(LastFrontier.Modules.Config)
local Weapons = require(LastFrontier.Modules.WeaponsConfig)
local Waves = require(LastFrontier.Modules.WaveConfig)
local EnemiesConfig = require(LastFrontier.Modules.EnemiesConfig)
local EnemyBehaviour = require(LastFrontier.Modules.EnemyBehaviour)
local EnemyFactory = require(LastFrontier.Modules.EnemyFactory)
local WeaponFactory = require(LastFrontier.Modules.WeaponFactory)

local Remotes = LastFrontier:WaitForChild("Remotes")
local requestShot = Remotes:WaitForChild("RequestShot")
local reloadWeapon = Remotes:WaitForChild("ReloadWeapon")
local equipWeapon = Remotes:WaitForChild("EquipWeapon")
local purchaseItem = Remotes:WaitForChild("PurchaseItem")
local updateUi = Remotes:WaitForChild("UpdateUi")
local getPlayerData = Remotes:WaitForChild("GetPlayerData")

local MapFolder = workspace:WaitForChild("LastFrontierMap")
local SpawnFolder = MapFolder:WaitForChild("ZombieSpawns")
local Barricades = MapFolder:WaitForChild("Barricades")
local BattlefieldSpawn = MapFolder:WaitForChild("BattlefieldSpawn")
local LobbySpawn = MapFolder:WaitForChild("LobbySpawn")

local activeEnemies = {}
local enemyBehaviours = {}
local playerStates = {}
local currentWave = 0
local intermission = true
local intermissionTimer = Config.RoundIntermission
local alivePlayers = {}
local waveRemaining = 0
local spawnQueue = {}
local enemyConnections = {}

local function debugPrint(...)
    print("[LastFrontier]", ...)
end

local function setupLeaderstats(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = Config.StartingCoins
    coins.Parent = leaderstats

    local wave = Instance.new("IntValue")
    wave.Name = "Wave"
    wave.Value = 0
    wave.Parent = leaderstats

    local kills = Instance.new("IntValue")
    kills.Name = "Kills"
    kills.Value = 0
    kills.Parent = leaderstats

    return leaderstats
end

local function notifyPlayer(player, payload)
    updateUi:FireClient(player, payload)
end

local function teleportToLobby(character)
    if character and LobbySpawn then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = LobbySpawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

local function teleportToBattlefield(character)
    if character and BattlefieldSpawn then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = BattlefieldSpawn.CFrame + Vector3.new(math.random(-3, 3), 3, math.random(-3, 3))
        end
    end
end

local function resetPlayerState(player)
    playerStates[player] = {
        Coins = Config.StartingCoins,
        Weapons = {},
        ActiveWeapon = nil,
        Ammo = {},
    }
end

local function giveWeapon(player, weaponName)
    local state = playerStates[player]
    if not state then
        return
    end

    if state.Weapons[weaponName] then
        return
    end

    local weaponTool = WeaponFactory:Create(weaponName)
    weaponTool.Parent = player:WaitForChild("Backpack")
    state.Weapons[weaponName] = true
    state.ActiveWeapon = state.ActiveWeapon or weaponName

    local config = Weapons[weaponName]
    state.Ammo[weaponName] = {
        Magazine = config.Magazine,
        Reserve = config.Reserve,
    }

    notifyPlayer(player, {
        Type = "WeaponObtained",
        Weapon = weaponName,
    })
end

local function updateCoins(player)
    local state = playerStates[player]
    if not state then
        return
    end
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local coinsValue = leaderstats:FindFirstChild("Coins")
        if coinsValue then
            coinsValue.Value = state.Coins
        end
    end
    notifyPlayer(player, {
        Type = "Coins",
        Amount = state.Coins,
    })
end

local function adjustCoins(player, delta)
    local state = playerStates[player]
    if not state then
        return false
    end
    state.Coins = math.max(0, state.Coins + delta)
    updateCoins(player)
    return true
end

local function awardKill(player, coins)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local kills = leaderstats:FindFirstChild("Kills")
        if kills then
            kills.Value = kills.Value + 1
        end
    end
    adjustCoins(player, coins)
end

local function cleanEnemy(enemy)
    if enemyConnections[enemy] then
        enemyConnections[enemy]:Disconnect()
        enemyConnections[enemy] = nil
    end
    activeEnemies[enemy] = nil
    enemyBehaviours[enemy] = nil
    if enemy and enemy.Parent then
        enemy:Destroy()
    end
end

local function onEnemyDied(enemy, humanoid, killer)
    local stats = EnemiesConfig[enemy.Name]
    waveRemaining = waveRemaining - 1
    if killer and killer.Parent then
        local player = Players:GetPlayerFromCharacter(killer.Parent)
        if player then
            awardKill(player, stats.Coins)
        end
    end
    cleanEnemy(enemy)
end

local function spawnEnemy(enemyType)
    local template = EnemyFactory:Create(enemyType)
    local spawnPoints = SpawnFolder:GetChildren()
    if #spawnPoints == 0 then
        warn("No spawn points available")
        return
    end
    local spawnPoint = spawnPoints[math.random(1, #spawnPoints)]
    template:SetPrimaryPartCFrame(spawnPoint.CFrame + Vector3.new(math.random(-4, 4), 2, math.random(-4, 4)))
    template.Parent = workspace

    local humanoid = template:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        activeEnemies[template] = enemyType
        local behaviour = EnemyBehaviour.new(template, EnemiesConfig[enemyType])
        enemyBehaviours[template] = behaviour
        enemyConnections[template] = humanoid.Died:Connect(function()
            onEnemyDied(template, humanoid, humanoid:FindFirstChild("creator"))
        end)
    else
        template:Destroy()
    end
end

local function queueEnemies(waveConfig)
    spawnQueue = {}
    for enemyType, quantity in pairs(waveConfig.units) do
        for i = 1, quantity do
            table.insert(spawnQueue, enemyType)
        end
    end
    table.sort(spawnQueue, function()
        return math.random() < 0.5
    end)
    waveRemaining = #spawnQueue
end

local function startWave()
    currentWave = currentWave + 1
    intermission = false
    debugPrint("Starting wave", currentWave)
    for _, player in ipairs(Players:GetPlayers()) do
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local waveValue = leaderstats:FindFirstChild("Wave")
            if waveValue then
                waveValue.Value = currentWave
            end
        end
        notifyPlayer(player, {
            Type = "Wave",
            Wave = currentWave,
        })
    end

    local waveConfig = Waves[currentWave]
    queueEnemies(waveConfig)
end

local function endWave()
    debugPrint("Wave", currentWave, "complete")
    intermission = true
    intermissionTimer = Config.RoundIntermission
    for _, player in ipairs(Players:GetPlayers()) do
        adjustCoins(player, Config.WaveReward.Base + currentWave * Config.WaveReward.Increment)
        notifyPlayer(player, {
            Type = "Intermission",
            Duration = intermissionTimer,
        })
    end
end

local function resetBarricades()
    for _, barricade in ipairs(Barricades:GetChildren()) do
        local health = barricade:FindFirstChild("Health")
        local maxHealth = barricade:FindFirstChild("MaxHealth")
        if health and maxHealth then
            health.Value = maxHealth.Value
        end
        local frame = barricade:FindFirstChild("Frame")
        if frame then
            frame.Transparency = 0
        end
    end
end

local function beginMatch()
    currentWave = 0
    waveRemaining = 0
    activeEnemies = {}
    enemyBehaviours = {}
    spawnQueue = {}
    resetBarricades()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character or player.CharacterAdded:Wait()
        teleportToBattlefield(character)
        resetPlayerState(player)
        giveWeapon(player, "Pistol")
        updateCoins(player)
    end
    startWave()
end

local function performSpawnStep()
    if intermission then
        return
    end
    if #spawnQueue == 0 then
        return
    end
    local activeCount = 0
    for enemy in pairs(activeEnemies) do
        if enemy.Parent then
            activeCount = activeCount + 1
        end
    end
    if activeCount >= Config.ZombieSpawnCap then
        return
    end
    local enemyType = table.remove(spawnQueue, 1)
    spawnEnemy(enemyType)
end

local function performEnemyAiStep()
    for enemy, behaviour in pairs(enemyBehaviours) do
        if enemy and enemy.Parent then
            behaviour:Step()
        else
            cleanEnemy(enemy)
        end
    end
end

local function checkWaveCompletion()
    if intermission then
        return
    end
    if waveRemaining <= 0 and #spawnQueue == 0 then
        endWave()
    end
end

local function onPlayerAdded(player)
    setupLeaderstats(player)
    resetPlayerState(player)

    player.CharacterAdded:Connect(function(character)
        teleportToLobby(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            alivePlayers[player] = nil
            if not intermission then
                local allDown = true
                for _, alive in pairs(alivePlayers) do
                    if alive then
                        allDown = false
                        break
                    end
                end
                if allDown then
                    notifyPlayer(player, {
                        Type = "MatchEnded",
                        Wave = currentWave,
                    })
                    beginMatch()
                end
            end
        end)
        alivePlayers[player] = true
    end)

    notifyPlayer(player, {
        Type = "Welcome",
        Message = "Prepare for survival!",
    })

    task.delay(2, function()
        local character = player.Character or player.CharacterAdded:Wait()
        teleportToLobby(character)
    end)
end

local function onPlayerRemoving(player)
    playerStates[player] = nil
    alivePlayers[player] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

getPlayerData.OnServerInvoke = function(player)
    local state = playerStates[player]
    if not state then
        return nil
    end
    local leaderstats = player:FindFirstChild("leaderstats")
    local coins = leaderstats and leaderstats:FindFirstChild("Coins") and leaderstats.Coins.Value or 0
    return {
        Coins = coins,
        Weapons = state.Weapons,
        Ammo = state.Ammo,
        Wave = currentWave,
        Intermission = intermission,
        IntermissionTimer = intermissionTimer,
    }
end

requestShot.OnServerEvent:Connect(function(player, data)
    local state = playerStates[player]
    if not state or not data then
        return
    end

    local weaponName = data.Weapon
    local weaponConfig = Weapons[weaponName]
    if not weaponConfig then
        return
    end

    local ammoState = state.Ammo[weaponName]
    if not ammoState or ammoState.Magazine <= 0 then
        notifyPlayer(player, {
            Type = "DryFire",
        })
        return
    end

    ammoState.Magazine = ammoState.Magazine - 1
    notifyPlayer(player, {
        Type = "Ammo",
        Weapon = weaponName,
        Ammo = ammoState,
    })

    local hitPart = data.HitPart
    if hitPart and hitPart.Parent then
        local enemyModel = hitPart:FindFirstAncestorOfClass("Model")
        if enemyModel and activeEnemies[enemyModel] then
            local humanoid = enemyModel:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local damage = weaponConfig.Damage
                if data.IsHeadshot then
                    damage *= weaponConfig.HeadshotMultiplier or 1.5
                end
                humanoid:TakeDamage(damage)
                local creator = Instance.new("ObjectValue")
                creator.Name = "creator"
                creator.Value = player
                creator.Parent = humanoid
                game:GetService("Debris"):AddItem(creator, 1)
            end
        end
    end
end)

reloadWeapon.OnServerEvent:Connect(function(player, weaponName)
    local state = playerStates[player]
    if not state then
        return
    end

    local ammoState = state.Ammo[weaponName]
    local config = Weapons[weaponName]
    if not ammoState or not config then
        return
    end

    local needed = config.Magazine - ammoState.Magazine
    if needed <= 0 or ammoState.Reserve <= 0 then
        return
    end

    local transfer = math.min(needed, ammoState.Reserve)
    ammoState.Magazine = ammoState.Magazine + transfer
    ammoState.Reserve = ammoState.Reserve - transfer

    notifyPlayer(player, {
        Type = "Ammo",
        Weapon = weaponName,
        Ammo = ammoState,
    })
end)

equipWeapon.OnServerEvent:Connect(function(player, weaponName)
    local state = playerStates[player]
    if not state then
        return
    end
    if not state.Weapons[weaponName] then
        return
    end
    state.ActiveWeapon = weaponName
end)

purchaseItem.OnServerEvent:Connect(function(player, itemName)
    local state = playerStates[player]
    if not state then
        return
    end

    local weaponConfig = Weapons[itemName]
    if not weaponConfig then
        return
    end

    if state.Weapons[itemName] then
        notifyPlayer(player, {
            Type = "Error",
            Message = "Already owned",
        })
        return
    end

    if state.Coins < weaponConfig.Cost then
        notifyPlayer(player, {
            Type = "Error",
            Message = "Not enough coins",
        })
        return
    end

    adjustCoins(player, -weaponConfig.Cost)
    giveWeapon(player, itemName)
end)

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

spawn(function()
    task.wait(3)
    beginMatch()
end)

RunService.Heartbeat:Connect(function(step)
    performSpawnStep()
    performEnemyAiStep()
    checkWaveCompletion()
    if intermission then
        intermissionTimer = intermissionTimer - step
        if intermissionTimer <= 0 then
            for _, player in ipairs(Players:GetPlayers()) do
                notifyPlayer(player, {
                    Type = "Intermission",
                    Duration = 0,
                })
            end
            startWave()
        end
    end
end)

for _, barricade in ipairs(Barricades:GetChildren()) do
    local frame = barricade:FindFirstChild("Frame")
    local health = barricade:FindFirstChild("Health")
    local maxHealth = barricade:FindFirstChild("MaxHealth")
    local prompt = barricade:FindFirstChild("RepairPrompt", true)
    if frame and health and maxHealth and prompt then
        prompt.Triggered:Connect(function(player)
            local state = playerStates[player]
            if not state or state.Coins < Config.RepairCost then
                notifyPlayer(player, {
                    Type = "Error",
                    Message = "Need more coins",
                })
                return
            end
            adjustCoins(player, -Config.RepairCost)
            health.Value = math.min(maxHealth.Value, health.Value + Config.RepairAmount)
            frame.Transparency = 0
        end)
    end
end

local shopModel = workspace:FindFirstChild("LastFrontierMap") and workspace.LastFrontierMap:FindFirstChild("ShopTerminal")
if shopModel then
    local prompt = shopModel:FindFirstChild("ShopPrompt", true)
    if prompt then
        prompt.Triggered:Connect(function(player)
            notifyPlayer(player, {
                Type = "Shop",
                Open = true,
            })
        end)
    end
end
]]

--[[
    LOCAL PLAYER SCRIPTS
]]

local starterScripts = starterPlayer:FindFirstChild("StarterPlayerScripts")
if not starterScripts then
    starterScripts = create("Folder", {
        Name = "StarterPlayerScripts",
        Parent = starterPlayer,
    })
end

clearExisting(starterScripts, "LastFrontierClient")
local clientScript = create("LocalScript", {
    Name = "LastFrontierClient",
    Parent = starterScripts,
})

clientScript.Source = [[
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local LastFrontier = ReplicatedStorage:WaitForChild("LastFrontier")
local Remotes = LastFrontier:WaitForChild("Remotes")
local requestShot = Remotes:WaitForChild("RequestShot")
local reloadWeapon = Remotes:WaitForChild("ReloadWeapon")
local equipWeapon = Remotes:WaitForChild("EquipWeapon")
local purchaseItem = Remotes:WaitForChild("PurchaseItem")
local updateUi = Remotes:WaitForChild("UpdateUi")
local getPlayerData = Remotes:WaitForChild("GetPlayerData")
local Weapons = require(LastFrontier.Modules.WeaponsConfig)

local gui = Instance.new("ScreenGui")
gui.Name = "LastFrontierGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function createLabel(text, position)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 0.35
    label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    label.BorderSizePixel = 0
    label.Size = UDim2.new(0, 240, 0, 36)
    label.Position = position
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Text = text
    label.Parent = gui
    return label
end

local waveLabel = createLabel("Wave: 0", UDim2.new(0, 20, 0, 20))
local coinsLabel = createLabel("Coins: 0", UDim2.new(0, 20, 0, 60))
local statusLabel = createLabel("Status: Preparing", UDim2.new(0, 20, 0, 100))
local ammoLabel = createLabel("Ammo: --", UDim2.new(1, -260, 1, -60))
ammoLabel.TextXAlignment = Enum.TextXAlignment.Right

local shopFrame = Instance.new("Frame")
shopFrame.BackgroundTransparency = 0.1
shopFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
shopFrame.Size = UDim2.new(0, 420, 0, 320)
shopFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
shopFrame.Visible = false
shopFrame.Parent = gui

local shopTitle = createLabel("Armory", UDim2.new(0, 10, 0, 10))
shopTitle.Size = UDim2.new(1, -20, 0, 40)
shopTitle.Parent = shopFrame
shopTitle.TextScaled = true

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 120, 0, 32)
closeButton.Position = UDim2.new(1, -130, 0, 15)
closeButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
closeButton.Text = "Close"
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = shopFrame

local shopList = Instance.new("Frame")
shopList.BackgroundTransparency = 1
shopList.Size = UDim2.new(1, -20, 1, -70)
shopList.Position = UDim2.new(0, 10, 0, 60)
shopList.Parent = shopFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = shopList

local buttons = {}

local function refreshShop()
    for _, button in ipairs(buttons) do
        button:Destroy()
    end
    buttons = {}

    local data = getPlayerData:InvokeServer()
    for weaponName, config in pairs(Weapons) do
        if weaponName ~= "Pistol" then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 42)
            button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.TextScaled = true
            button.Font = Enum.Font.GothamBold
            button.Text = string.format("%s - %d Coins", config.DisplayName, config.Cost)
            button.Parent = shopList
            table.insert(buttons, button)

            if data.Weapons and data.Weapons[weaponName] then
                button.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                button.Text = string.format("Owned: %s", config.DisplayName)
                button.AutoButtonColor = false
            else
                button.MouseButton1Click:Connect(function()
                    purchaseItem:FireServer(weaponName)
                end)
            end
        end
    end
end

closeButton.MouseButton1Click:Connect(function()
    shopFrame.Visible = false
end)

local inputState = {
    Firing = false,
    LastShot = 0,
    Weapon = "Pistol",
}

local function getEquippedWeapon()
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                return tool
            end
        end
    end
    return nil
end

local function attemptShoot()
    local tool = getEquippedWeapon()
    if not tool then
        return
    end

    local weaponName = tool.Name
    local config = Weapons[weaponName]
    if not config then
        return
    end

    local now = tick()
    if now - inputState.LastShot < config.FireRate then
        return
    end
    inputState.LastShot = now

    local muzzle = tool:FindFirstChild("Handle") and tool.Handle:FindFirstChild("Muzzle")
    local origin = muzzle and muzzle.WorldPosition or camera.CFrame.Position
    local target = mouse.Hit.Position
    local direction = (target - origin).Unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ignore = { player.Character }
    raycastParams.FilterDescendantsInstances = ignore
    local result = workspace:Raycast(origin, direction * config.Range, raycastParams)

    local hitPart
    local isHeadshot = false
    if result then
        hitPart = result.Instance
        if hitPart and hitPart.Name == "Head" then
            isHeadshot = true
        end
    end

    requestShot:FireServer({
        Weapon = weaponName,
        HitPart = hitPart,
        IsHeadshot = isHeadshot,
    })

    local emitter = muzzle and muzzle:FindFirstChildWhichIsA("ParticleEmitter")
    if emitter then
        emitter:Emit(1)
    end
end

local function onInputBegan(input, processed)
    if processed then
        return
    end

    local tool = getEquippedWeapon()
    if not tool then
        return
    end
    local weaponName = tool.Name
    local config = Weapons[weaponName]
    if not config then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        inputState.Firing = true
        attemptShoot()
    elseif input.KeyCode == Enum.KeyCode.R then
        reloadWeapon:FireServer(weaponName)
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        inputState.Firing = false
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

local function onEquipped(tool)
    equipWeapon:FireServer(tool.Name)
end

player.CharacterAdded:Connect(function(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            child.Equipped:Connect(onEquipped)
        end
    end)
end)

updateUi.OnClientEvent:Connect(function(data)
    if data.Type == "Wave" then
        waveLabel.Text = string.format("Wave: %d", data.Wave)
        statusLabel.Text = "Status: Wave in progress"
    elseif data.Type == "Coins" then
        coinsLabel.Text = string.format("Coins: %d", data.Amount)
    elseif data.Type == "Intermission" then
        if data.Duration and data.Duration > 0 then
            statusLabel.Text = string.format("Status: Next wave in %d", math.ceil(data.Duration))
        else
            statusLabel.Text = "Status: Prepare!"
        end
    elseif data.Type == "Ammo" and data.Ammo then
        ammoLabel.Text = string.format("Ammo: %d / %d", data.Ammo.Magazine, data.Ammo.Reserve)
    elseif data.Type == "WeaponObtained" then
        statusLabel.Text = string.format("Status: Purchased %s", data.Weapon)
        refreshShop()
    elseif data.Type == "Error" then
        statusLabel.Text = string.format("Status: %s", data.Message)
    elseif data.Type == "Shop" then
        if data.Open then
            refreshShop()
            shopFrame.Visible = true
        else
            shopFrame.Visible = false
        end
    elseif data.Type == "DryFire" then
        statusLabel.Text = "Status: Reload!"
    elseif data.Type == "MatchEnded" then
        statusLabel.Text = string.format("Status: Team fell on wave %d", data.Wave)
    elseif data.Type == "Welcome" then
        statusLabel.Text = data.Message or "Status: Ready"
    end
end)

while task.wait(0.05) do
    if inputState.Firing then
        attemptShoot()
    end
end
]]

--[[
    HUD / GUI CLEANUP
]]

clearExisting(starterGui, "LastFrontierHUD")

--[[
    STARTER PACK
]]

starterPack:ClearAllChildren()
local pistolTemplate = weaponTemplates:FindFirstChild("Pistol")
if pistolTemplate then
    pistolTemplate:Clone().Parent = starterPack
end

print("[LastFrontier] Setup complete. Press Play to test the game mode.")
