-- ==============================================================================
-- Game  : Driving Empire [🎃HALLOWEEN EVENT🎃] (PlaceId: 3351674303, UniverseId: 1202096104)
-- Script: Cellular HUB | Driving Empire Edition (Tactile Obsidian 3D Engine)
-- Author: Cellular HUB Development Team
-- Engine: 100% Reliable Auto-Run, Physics Stabilizer, Anti-Crash, WindUI Suite
-- ==============================================================================

-- ==============================================================================
-- 1. CLEANUP PREVIOUS SESSIONS (Run first before anything loads)
-- ==============================================================================
print("CELLULAR_HUB_STARTING_LOAD")
_G.__CellularHub_DrivingEmpire_Cleanup = nil
_G.__WindUI = nil

pcall(
    function()
        local CoreGui = game:GetService("CoreGui")
        local target = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or CoreGui
        if target then
            for _, c in ipairs(target:GetChildren()) do
                if c.Name:find("WindUI") or c.Name:find("CellularHUB") or c.Name:find("Cellular_") then
                    c:Destroy()
                end
            end
        end
    end
)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid", 5)
local RootPart = Character:WaitForChild("HumanoidRootPart", 5)

local ActiveConnections = {}
local function trackConnect(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(ActiveConnections, conn)
    return conn
end

trackConnect(
    LocalPlayer.CharacterAdded,
    function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid", 5)
        RootPart = char:WaitForChild("HumanoidRootPart", 5)
    end
)

-- Safe Remotes Reference
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5) or ReplicatedStorage:FindFirstChild(
    "Remotes"
)
local function getRemote(name)
    if not RemotesFolder then
        return nil
    end
    return RemotesFolder:FindFirstChild(name)
end

local VehicleEventRemote = getRemote("VehicleEvent")
local CollectibleCollectRemote = getRemote("CollectibleSpawnerCollect")
local ClaimRewardsRemote = getRemote("ClaimRewards")
local ClaimQuestRewardRemote = getRemote("ClaimQuestReward")
local QuestClaimedRemote = getRemote("QuestClaimed")
local PinQuestRemote = getRemote("PinQuest")
local SetTrackedQuestRemote = getRemote("SetTrackedQuest")
local MilestoneRewardRemote = getRemote("ClaimWeeklyMilestoneRewards")
local RaceQueueRemote = getRemote("RaceQueue")
local RaceStartTimeTrialRemote = getRemote("RaceStartTimeTrial")
local RaceCheckpointRemote = getRemote("RaceCheckpoint")
local RaceFinishLineRemote = getRemote("RaceFinishLine")
local RaceLeaderboardClaimRemote = getRemote("RaceLeaderboardClaimRewards")

-- Safe Require helper
local function safeRequire(path)
    local ok, res = pcall(require, path)
    if ok then
        return res
    end
    return nil
end

local CollectibleSpawnerController = safeRequire(
    ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild(
        "Client"
    ) and ReplicatedStorage.Modules.Client:FindFirstChild("CollectibleSpawner") and ReplicatedStorage.Modules.Client.CollectibleSpawner:FindFirstChild(
        "CollectibleSpawnerController"
    )
)

local PlayerActionController = safeRequire(
    ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild(
        "Client"
    ) and ReplicatedStorage.Modules.Client:FindFirstChild("DailyChallenges") and ReplicatedStorage.Modules.Client.DailyChallenges:FindFirstChild(
        "PlayerActionController"
    )
)

local CurrencyData = safeRequire(
    ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild(
        "Shared"
    ) and ReplicatedStorage.Modules.Shared:FindFirstChild("DataManager") and ReplicatedStorage.Modules.Shared.DataManager:FindFirstChild(
        "Data"
    ) and ReplicatedStorage.Modules.Shared.DataManager.Data:FindFirstChild("CurrencyData")
)

local QuestController = safeRequire(
    ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild(
        "Client"
    ) and ReplicatedStorage.Modules.Client:FindFirstChild("Quests") and ReplicatedStorage.Modules.Client.Quests:FindFirstChild(
        "QuestController"
    )
)

local QuestUtil = safeRequire(
    ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild(
        "Shared"
    ) and ReplicatedStorage.Modules.Shared:FindFirstChild("Quests") and ReplicatedStorage.Modules.Shared.Quests:FindFirstChild(
        "QuestUtil"
    )
)

local RaceQueuesController = safeRequire(
    ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild(
        "Client"
    ) and ReplicatedStorage.Modules.Client:FindFirstChild("Races") and ReplicatedStorage.Modules.Client.Races:FindFirstChild(
        "RaceQueuesController"
    )
)

local RaceController = safeRequire(
    ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild(
        "Client"
    ) and ReplicatedStorage.Modules.Client:FindFirstChild("Races") and ReplicatedStorage.Modules.Client.Races:FindFirstChild(
        "RaceController"
    )
)

local RaceUtil = safeRequire(
    ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild(
        "Shared"
    ) and ReplicatedStorage.Modules.Shared:FindFirstChild("Races") and ReplicatedStorage.Modules.Shared.Races:FindFirstChild(
        "RaceUtil"
    )
)

-- ==============================================================================
-- 2. STATE & CONFIGURATION
-- ==============================================================================
local Settings = {
    -- Auto Drive (AFK Money & Miles)
    AutoFarmMiles = false,
    AutoDriveMode = "Highway Straightaway (100% Smooth / Anti-Crash / AFK Money)", -- "Highway Straightaway (100% Smooth / Anti-Crash / AFK Money)", "Smart Street Cruise"
    TargetFarmSpeed = 200, -- Studs/s (~135 mph)
     ObstacleAvoidance = true, AvoidanceDistance = 50, AntiWaterProtection = true,
    AutoUprightOnFarm = true,

    -- Quests & Milestones Automation (Full Bot)
    AutoTakeQuests = true, AutoClaimQuests = true, AutoClaimMilestones = true,
    AutoSolveRaceQuests = true, AutoClaimRewards = true,

    -- Event Farm (Halloween)
    AutoCollectCandies = false, CollectInterval = 0.35,

    -- Vehicle Spawner
    SelectedVehicleToSpawn = "Ford-MustangDarkHorse", AutoSitOnSpawn = true,

    -- Vehicle Mods
    CustomSpeedEnabled = false, VehicleMaxSpeed = 300, TorqueMultiplierEnabled = false,
    TorqueMultiplier = 3.0, EnhancedSteerEnabled = false, SteerMultiplier = 1.8, VehicleFly = false,
    VehicleFlySpeed = 160, VehicleNoclip = false, AutoAntiRoll = true,

    -- Character Mods
    CustomWalkSpeedEnabled = false, CustomWalkSpeed = 65, CustomJumpPowerEnabled = false,
    CustomJumpPower = 90, InfiniteJump = false, PlayerNoclip = false, AntiAFK = true,

    -- Visuals & ESP
    PlayerESP = false, VehicleESP = false, CandyESP = false, Fullbright = false, NoFog = false,

    -- UI Config
    CurrentTheme = "Dark",
}

local CONFIG_FOLDER = "CellularHUB_Config"
local CONFIG_FILE = CONFIG_FOLDER .. "/DrivingEmpire_settings.json"

local function SaveSettings(notify)
    pcall(
        function()
            if typeof(makefolder) == "function" then
                pcall(makefolder, CONFIG_FOLDER)
            end
            if typeof(writefile) == "function" then
                writefile(CONFIG_FILE, HttpService:JSONEncode(Settings))
            end
        end
    )
    if notify and _G.__WindUI then
        _G.__WindUI:Notify(
            {
                Title = "Settings Saved", Content = "Configuration saved successfully!",
                Duration = 2.5, Icon = "save"
            }
        )
    end
end

local function LoadSettings(notify)
    local loaded = false
    pcall(
        function()
            if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(
                CONFIG_FILE
            ) then
                local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
                if type(data) == "table" then
                    for k, v in pairs(data) do
                        if Settings[k] ~= nil then
                            Settings[k] = v
                        end
                    end
                    loaded = true
                end
            end
        end
    )
    if notify and _G.__WindUI then
        _G.__WindUI:Notify(
            {
                Title = loaded and "Settings Loaded" or "Notice",
                Content = loaded and "Configuration loaded successfully!" or "No saved profile found.",
                Duration = 2.5, Icon = loaded and "check" or "info"
            }
        )
    end
    return loaded
end

-- ==============================================================================
-- 3. VEHICLE HELPER ENGINE
-- ==============================================================================
local function getMyVehicle()
    local vehFolder = Workspace:FindFirstChild("Vehicles")
    if vehFolder then
        local myCar = vehFolder:FindFirstChild(LocalPlayer.Name)
        if myCar then
            return myCar
        end
        for _, v in ipairs(vehFolder:GetChildren()) do
            if v:IsA("Model") and v:GetAttribute("Owner") == LocalPlayer.Name then
                return v
            end
        end
    end
    for _, v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character and (v:GetAttribute("Owner") == LocalPlayer.Name or (v:FindFirstChildWhichIsA(
            "VehicleSeat", true
        ) and v:FindFirstChildWhichIsA("VehicleSeat", true).Occupant == Humanoid)) then
            return v
        end
    end
    return nil
end

local function getVehicleSeat(veh)
    veh = veh or getMyVehicle()
    if not veh then
        return nil
    end
    local seat = veh:FindFirstChildWhichIsA("VehicleSeat") or veh:FindFirstChild("VehicleSeat")
    if not seat then
        for _, d in ipairs(veh:GetDescendants()) do
            if d:IsA("VehicleSeat") then
                seat = d
                break
            end
        end
    end
    return seat
end

local function getVehicleRoot(veh)
    veh = veh or getMyVehicle()
    if not veh then
        return nil
    end
    local seat = getVehicleSeat(veh)
    if seat and seat.AssemblyRootPart then
        return seat.AssemblyRootPart
    end
    return veh:FindFirstChild("Weight") or veh:FindFirstChild("CenterOfGravity") or veh:FindFirstChild(
        "KeepAwakePart"
    ) or veh.PrimaryPart or seat
end

local function isDriving()
    local seat = getVehicleSeat()
    if seat and Humanoid and Humanoid.SeatPart == seat then
        return true
    end
    return false
end

local function enterMyVehicle()
    local seat = getVehicleSeat()
    if seat and Humanoid and RootPart then
        RootPart.CFrame = seat.CFrame + Vector3.new(0, 2.0, 0)
        task.wait(0.15)
        pcall(
            function()
                seat:Sit(Humanoid)
            end
        )
        return true
    end
    return false
end

local function emergencyStop()
    local veh = getMyVehicle()
    if veh then
        for _, desc in ipairs(veh:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.AssemblyLinearVelocity = Vector3.zero
                desc.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end

local function uprightVehicle()
    local veh = getMyVehicle()
    local root = getVehicleRoot(veh)
    if root then
        local currentPos = root.Position
        local look = root.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z).Unit
        if flatLook.Magnitude < 0.1 then
            flatLook = Vector3.new(0, 0, -1)
        end
        local newCFrame = CFrame.lookAt(
            currentPos + Vector3.new(0, 3, 0), currentPos + Vector3.new(0, 3, 0) + flatLook
        )
        pcall(
            function()
                root.CFrame = newCFrame
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        )
    end
end

-- Detect Owned Vehicles list from Player Stats JSON & Inventory
local function getOwnedVehiclesList()
    local cars = {}
    pcall(
        function()
            local stats = LocalPlayer.PlayerGui:FindFirstChild(LocalPlayer.Name .. "'s Stats") or (ReplicatedStorage:FindFirstChild(
                "Modules"
            ) and require(ReplicatedStorage.Modules.Shared.Data).GetStatsFolderIfLoaded(LocalPlayer))
            local ownedVal = stats and stats:FindFirstChild("OwnedVehicles")
            if ownedVal and ownedVal.Value ~= "" then
                local data = game:GetService("HttpService"):JSONDecode(ownedVal.Value)
                for carId, _ in pairs(data) do
                    table.insert(cars, carId)
                end
            end
        end
    )
    if #cars == 0 then
        cars = {
            "Ford-MustangDarkHorse", "Nissan-GTR2017", "GM-2024Tahoe-Police", "Porsche-718BoxsterS",
            "McLaren-600LTCoupe"
        }
    else
        table.sort(cars)
    end
    return cars
end

local function spawnVehicle(carName)
    if not VehicleEventRemote then
        return false
    end
    pcall(
        function()
            local camera = Workspace.CurrentCamera
            local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
            local unit = Vector3.new(look.X, 0, look.Z).Unit
            VehicleEventRemote:FireServer("Spawn", carName, nil, nil, unit)
        end
    )
    if Settings.AutoSitOnSpawn then
        task.spawn(
            function()
                task.wait(0.7)
                enterMyVehicle()
            end
        )
    end
    return true
end

local function despawnVehicle()
    pcall(
        function()
            if PlayerActionController and PlayerActionController.commitAction then
                PlayerActionController.commitAction(LocalPlayer, "DespawnVehicle")
            end
        end
    )
    pcall(
        function()
            if VehicleEventRemote then
                VehicleEventRemote:FireServer("Despawn")
            end
        end
    )
end

-- Live Currency Getters
local function getPlayerCandy()
    if CurrencyData and CurrencyData.GetCurrency then
        local ok, val = pcall(CurrencyData.GetCurrency, LocalPlayer, "Spookfest2026Candy")
        if ok and val ~= nil then
            return tonumber(val) or 0
        end
    end
    local stats = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(
        LocalPlayer.Name .. "'s Stats"
    )
    local cur = stats and stats:FindFirstChild("LiveOps") and stats.LiveOps:FindFirstChild(
        "Currency"
    ) and stats.LiveOps.Currency:FindFirstChild("Spookfest2026")
    if cur and cur:IsA("ValueBase") then
        return tonumber(cur.Value) or 0
    end
    return 0
end

local function getPlayerCash()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local c = ls and ls:FindFirstChild("Cash")
    if c then
        return tonumber(c.Value) or 0
    end
    if CurrencyData and CurrencyData.GetCurrency then
        local ok, val = pcall(CurrencyData.GetCurrency, LocalPlayer, "Cash")
        if ok and val ~= nil then
            return tonumber(val) or 0
        end
    end
    return 0
end

local function getPlayerMiles()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local m = ls and ls:FindFirstChild("Miles")
    if m then
        return tonumber(m.Value) or 0
    end
    return 0
end

-- Quests & Milestones Helper
local function getPlayerQuestsData()
    local questsList = {}
    pcall(
        function()
            if QuestController and QuestController.getQuestsForLocalPlayer then
                local q = QuestController.getQuestsForLocalPlayer()
                if q and #q > 0 then
                    questsList = q
                end
            end
        end
    )
    if #questsList == 0 then
        pcall(
            function()
                local qVal = LocalPlayer.PlayerGui:FindFirstChild(LocalPlayer.Name .. "'s Stats") and LocalPlayer.PlayerGui[LocalPlayer.Name .. "'s Stats"]:FindFirstChild(
                    "Quests"
                ) and LocalPlayer.PlayerGui[LocalPlayer.Name .. "'s Stats"].Quests:FindFirstChild(
                    "Quests"
                )
                if qVal and qVal.Value ~= "" then
                    questsList = game:GetService("HttpService"):JSONDecode(qVal.Value)
                end
            end
        )
    end
    return questsList
end

local function autoPinAndTrackQuests()
    pcall(
        function()
            local quests = getPlayerQuestsData()
            local firstIncomplete = nil
            for _, q in ipairs(quests) do
                local qId = q.QuestId or q.Name
                if qId then
                    local isDone = (QuestController and QuestController.hasCompletedQuest(qId))
                    local isClaimed = (QuestUtil and QuestUtil.isQuestClaimed(LocalPlayer, qId)) or q.IsClaimed == true

                    if not isClaimed then
                        if QuestController and QuestController.setQuestIsPinned then
                            pcall(
                                function()
                                    QuestController.setQuestIsPinned(qId, true)
                                end
                            )
                        end
                        if PinQuestRemote then
                            pcall(
                                function()
                                    PinQuestRemote:FireServer(qId, true)
                                end
                            )
                        end
                        if not isDone and not firstIncomplete then
                            firstIncomplete = qId
                        end
                    end
                end
            end
            if firstIncomplete then
                if QuestController and QuestController.setTrackedQuestId then
                    pcall(
                        function()
                            QuestController.setTrackedQuestId(firstIncomplete)
                        end
                    )
                end
                if SetTrackedQuestRemote then
                    pcall(
                        function()
                            SetTrackedQuestRemote:FireServer(firstIncomplete)
                        end
                    )
                end
            end
        end
    )
end

local isAutoSolvingRace = false
local function autoSolveActiveRace()
    if isAutoSolvingRace then
        return
    end
    isAutoSolvingRace = true

    pcall(
        function()
            if not (RaceController and RaceController.isRacing and RaceController.isRacing()) then
                isAutoSolvingRace = false
                return
            end

            local veh = getMyVehicle()
            local root = getVehicleRoot(veh)
            if not (veh and root) then
                isAutoSolvingRace = false
                return
            end

            local race = RaceController.getCurrentRace and RaceController.getCurrentRace()
            local trackName = race and race.GetTrackName and race:GetTrackName() or "Drag"

            -- Collect race checkpoints
            local checkpoints = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("BasePart") or obj:IsA("Model")) and (obj.Name:lower():find(
                    "checkpoint"
                ) or obj.Name:lower():find("finish")) then
                    table.insert(checkpoints, obj)
                end
            end

            -- If Drag race or no explicit checkpoints, drive at high speed along track vector
            if trackName == "Drag" or #checkpoints == 0 then
                for step = 1, 8 do
                    if not (RaceController.isRacing and RaceController.isRacing()) then
                        break
                    end
                    root.AssemblyLinearVelocity = root.CFrame.LookVector * 280
                    task.wait(0.25)
                end
            else
                for i, cp in ipairs(checkpoints) do
                    if not (RaceController.isRacing and RaceController.isRacing()) then
                        break
                    end
                    local pos = nil
                    if cp:IsA("BasePart") then
                        pos = cp.Position
                    elseif cp:IsA("Model") then
                        pos = cp:GetPivot().Position
                    end
                    if pos then
                        veh:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 100)
                        if RaceCheckpointRemote then
                            pcall(
                                function()
                                    RaceCheckpointRemote:InvokeServer(i)
                                end
                            )
                        end
                        task.wait(0.2)
                    end
                end
            end

            -- Cross Finish Line
            if RaceFinishLineRemote then
                pcall(
                    function()
                        RaceFinishLineRemote:InvokeServer(nil, false)
                    end
                )
            end
        end
    )

    task.wait(1.0)
    isAutoSolvingRace = false
end

local function checkAndClaimQuests()
    local claimedCount = 0
    pcall(
        function()
            local quests = getPlayerQuestsData()
            for _, q in ipairs(quests) do
                local qId = q.QuestId or q.Name
                if qId then
                    local cfg = QuestUtil and QuestUtil.getQuestConfig(qId)
                    local target = cfg and cfg.Target or q.Target
                    local isDone = (QuestController and QuestController.hasCompletedQuest(qId)) or (q.Progress and target and q.Progress >= target)
                    local isClaimed = (QuestUtil and QuestUtil.isQuestClaimed(LocalPlayer, qId)) or q.IsClaimed == true

                    if isDone and not isClaimed then
                        if QuestController and QuestController.claimQuest then
                            pcall(
                                function()
                                    QuestController.claimQuest(qId)
                                end
                            )
                        end
                        if QuestClaimedRemote then
                            pcall(
                                function()
                                    QuestClaimedRemote:FireServer(qId, false)
                                end
                            )
                        end
                        if ClaimQuestRewardRemote then
                            pcall(
                                function()
                                    ClaimQuestRewardRemote:FireServer(qId)
                                end
                            )
                        end
                        claimedCount = claimedCount + 1
                    end
                end
            end
            if Settings.AutoClaimMilestones and MilestoneRewardRemote then
                pcall(
                    function()
                        MilestoneRewardRemote:FireServer()
                    end
                )
            end
            if Settings.AutoClaimRewards then
                if ClaimRewardsRemote then
                    pcall(
                        function()
                            ClaimRewardsRemote:FireServer()
                        end
                    )
                end
                if RaceLeaderboardClaimRemote then
                    pcall(
                        function()
                            RaceLeaderboardClaimRemote:FireServer()
                        end
                    )
                end
            end
        end
    )
    return claimedCount
end

local function getActiveQuestsSummary()
    local text = ""
    pcall(
        function()
            local quests = getPlayerQuestsData()
            for _, q in ipairs(quests) do
                local qId = q.QuestId or q.Name
                if qId then
                    local desc = QuestUtil and QuestUtil.getQuestDescription(LocalPlayer, qId) or qId
                    local prog = QuestController and QuestController.getQuestProgressionString(qId) or ""
                    local isDone = (QuestController and QuestController.hasCompletedQuest(qId)) or (prog ~= "" and (prog:find(
                        "%(1/1%)"
                    ) or prog:find("%(2/2%)") or prog:find("%(5/5%)") or prog:find("%(7/7%)")))
                    local isClaimed = (QuestUtil and QuestUtil.isQuestClaimed(LocalPlayer, qId)) or q.IsClaimed == true

                    local status = ""
                    if isClaimed then
                        status = "🎉 CLAIMED (Reward Received)"
                    elseif isDone then
                        status = "✨ COMPLETED (Auto-Claiming...)"
                    else
                        status = "⏳ In Progress " .. tostring(prog)
                    end
                    text = text .. string.format("• %s\n  Status: %s\n\n", desc, status)
                end
            end
        end
    )
    if text == "" then
        text = "No active daily quests detected."
    end
    return text
end

-- ==============================================================================
-- 4. TELEPORT COORDINATES DATABASE (Official Driving Empire Positions)
-- ==============================================================================
local TeleportLocations = {
    Races = {
        ["Race Hub (Main Plaza)"] = Vector3.new(55, 13, -2170),
        ["Circuit Race"] = Vector3.new(110, 13, -2281),
        ["Highway Sprint (Farm Start)"] = Vector3.new(135, 17, -2000),
        ["Drag Strip (1/4 Mile)"] = Vector3.new(85, 13, -2092),
        ["Cross Country (CC)"] = Vector3.new(161, 13, -2268),
        ["Sandy Shores"] = Vector3.new(59, 13, -2268), ["Rush Hour"] = Vector3.new(20, 13, -2233),
        ["Sofia Bay"] = Vector3.new(208, 13, -2176),
        ["Drawbridge Jump"] = Vector3.new(180, 13, -2128),
        ["Lightning Loop"] = Vector3.new(231, 15, -2174),
    },
    Dealerships = {
        ["Main Supercar Dealership"] = Vector3.new(-330, 13, -1793),
        ["Aviation Dealership (Airfield)"] = Vector3.new(407, 13, 3124),
        ["Boat Dealership & Marina"] = Vector3.new(-2580, 52, -1225),
        ["Real Estate Office"] = Vector3.new(-1715, 11, 1709),
    },
    Jobs = {
        ["The Central Bank (Heist)"] = Vector3.new(-1124, 12, 2163),
        ["Police Department HQ"] = Vector3.new(-75, 23, -942),
        ["Criminal Underworld Hideout"] = Vector3.new(-2460, 16, 3956),
        ["Delivery Hub (Cargo Service)"] = Vector3.new(779, 26, 2242),
    },
    Halloween = {
        ["🎃 Spookfest Pumpkin Farm"] = Vector3.new(5404, 112, -2655),
        ["🎃 Spookfest Farm Race"] = Vector3.new(5276, 114, -2740),
        ["🎃 Spookfest Haunted Circus"] = Vector3.new(-2460, 16, 3956),
        ["🎃 Spookfest Maze Exit"] = Vector3.new(-1996, 71, -4172),
        ["🎃 Spookfest Event Plaza"] = Vector3.new(-1917, 75, 642),
    },
    CarMeets = {
        ["Beach Race Island"] = Vector3.new(6794, -18, 3135),
        ["Mountain Summit Bar"] = Vector3.new(3668, 329, -4167),
        ["Chinatown District"] = Vector3.new(566, 54, 1733),
        ["Ridgeline Pier Parking"] = Vector3.new(-2405, 13, 2504),
        ["Lighthouse Overlook"] = Vector3.new(-13211, 293, -5714),
        ["Restin Grand Hotel"] = Vector3.new(-422, 54, 2092),
        ["Residential Neighborhood"] = Vector3.new(796, 95, -3326),
    }
}

local function safeTeleportTarget(pos)
    pcall(
        function()
            if isDriving() then
                local veh = getMyVehicle()
                local root = getVehicleRoot(veh)
                if root then
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            else
                if RootPart then
                    RootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                end
            end
        end
    )
end

-- ==============================================================================
-- 5. WORKER ENGINES (Highway Auto Farm, Candy Sweep, Physics, ESP)
-- ==============================================================================

-- A. Intelligent Auto Drive Engine (AFK Money Farming, Anti-Water, Anti-Nabrak, Anti-Nyasar)
local stuckTimer = 0
local highwayDirection = 1 -- 1 = towards +Z (-3100), -1 = towards -Z (-3750)
local HW_X = -1109
local HW_MIN_Z = -3750
local HW_MAX_Z = -3100
local HW_Y = 26.5

task.spawn(
    function()
        while true do
            task.wait(0.03)
            if Settings.AutoFarmMiles then
                pcall(
                    function()
                        -- 1. Ensure player is seated in a spawned vehicle
                        if not isDriving() then
                            local veh = getMyVehicle()
                            if not veh then
                                local carToSpawn = Settings.SelectedVehicleToSpawn or "Ford-MustangDarkHorse"
                                spawnVehicle(carToSpawn)
                                task.wait(0.9)
                            end
                            enterMyVehicle()
                            task.wait(0.4)
                        end

                        local veh = getMyVehicle()
                        local seat = getVehicleSeat(veh)
                        local root = getVehicleRoot(veh)

                        if veh and seat and root and isDriving() then
                            local curPos = root.Position
                            local look = root.CFrame.LookVector
                            local right = root.CFrame.RightVector
                            local speed = math.clamp(Settings.TargetFarmSpeed or 200, 80, 350)

                            -- Anti-Fall & Re-Seat Keeper: Ensures character never slips out of driver seat
                            if Character and Character:FindFirstChild("Humanoid") and seat.Occupant ~= Character.Humanoid then
                                seat:Sit(Character.Humanoid)
                            end

                            if Settings.AutoDriveMode ~= "Smart Street Cruise" then
                                -- ==========================================================
                                -- MODE 1: HIGHWAY STRAIGHTAWAY (100% SMOOTH, AFK MONEY, ZERO WATER, ANTI-CRASH)
                                -- ==========================================================
                                local distX = math.abs(curPos.X - HW_X)
                                local isOutOfBounds = curPos.Y < 20 or curPos.Z > (HW_MAX_Z + 100) or curPos.Z < (HW_MIN_Z - 100) or distX > 30

                                if isOutOfBounds then
                                    veh:PivotTo(
                                        CFrame.new(HW_X, HW_Y, -3450) * CFrame.Angles(0, 0, 0)
                                    )
                                    root.AssemblyLinearVelocity = Vector3.zero
                                    root.AssemblyAngularVelocity = Vector3.zero
                                    highwayDirection = 1
                                    task.wait(0.2)
                                    return
                                end

                                -- Smooth turnaround at highway endpoints
                                if curPos.Z >= HW_MAX_Z and highwayDirection == 1 then
                                    highwayDirection = -1
                                    veh:PivotTo(
                                        CFrame.new(HW_X, HW_Y, HW_MAX_Z) * CFrame.Angles(
                                            0, math.pi, 0
                                        )
                                    )
                                    root.AssemblyLinearVelocity = Vector3.new(0, 0, -speed * 0.5)
                                    task.wait(0.08)
                                    return
                                elseif curPos.Z <= HW_MIN_Z and highwayDirection == -1 then
                                    highwayDirection = 1
                                    veh:PivotTo(
                                        CFrame.new(HW_X, HW_Y, HW_MIN_Z) * CFrame.Angles(0, 0, 0)
                                    )
                                    root.AssemblyLinearVelocity = Vector3.new(0, 0, speed * 0.5)
                                    task.wait(0.08)
                                    return
                                end

                                local rotY = highwayDirection == 1 and 0 or math.pi

                                -- Smooth natural physics velocity driving
                                seat.Throttle = 1
                                seat.Steer = 0
                                root.AssemblyLinearVelocity = Vector3.new(
                                    0, 0, highwayDirection * speed
                                )
                                root.AssemblyAngularVelocity = Vector3.zero

                                -- Gentle lane & altitude stabilization (prevents clipping through ground)
                                if math.abs(curPos.X - HW_X) > 2.0 or math.abs(curPos.Y - HW_Y) > 2.0 then
                                    veh:PivotTo(
                                        CFrame.new(HW_X, HW_Y, curPos.Z) * CFrame.Angles(0, rotY, 0)
                                    )
                                end

                                if Settings.AutoUprightOnFarm and root.CFrame.UpVector.Y < 0.75 then
                                    uprightVehicle()
                                end
                            else
                                -- ==========================================================
                                -- MODE 2: SMART STREET CRUISE (ANTI-WATER & OBSTACLE AVOIDANCE)
                                -- ==========================================================
                                local sensorOrigin = curPos + Vector3.new(0, 1.5, 0)
                                local sensorDist = Settings.AvoidanceDistance or 40

                                local obsParams = RaycastParams.new()
                                obsParams.FilterType = Enum.RaycastFilterType.Exclude
                                obsParams.FilterDescendantsInstances = {veh, Character}

                                -- 1. Anti-Water Sensor (Look 28 studs ahead downward)
                                if Settings.AntiWaterProtection then
                                    local forwardGroundRay = Workspace:Raycast(
                                        curPos + look * 28 + Vector3.new(0, 5, 0),
                                        Vector3.new(0, -35, 0), obsParams
                                    )
                                    if not forwardGroundRay or forwardGroundRay.Position.Y < 14 or forwardGroundRay.Material == Enum.Material.Water then
                                        seat.Throttle = -1
                                        seat.Steer = 1
                                        root.AssemblyLinearVelocity = -look * 70
                                        task.wait(0.7)
                                        root.CFrame = root.CFrame * CFrame.Angles(
                                            0, math.rad(90), 0
                                        )
                                        return
                                    end
                                end

                                -- 2. Anti-Void Ground Clamping
                                local groundRay = Workspace:Raycast(
                                    curPos + Vector3.new(0, 4, 0), Vector3.new(0, -35, 0), obsParams
                                )
                                if groundRay and curPos.Y < (groundRay.Position.Y + 1.2) then
                                    root.CFrame = CFrame.new(
                                        curPos.X, groundRay.Position.Y + 2.0, curPos.Z
                                    ) * root.CFrame.Rotation
                                    root.AssemblyLinearVelocity = Vector3.new(
                                        root.AssemblyLinearVelocity.X, 0,
                                        root.AssemblyLinearVelocity.Z
                                    )
                                end

                                -- 3. Obstacle Steering Sensors
                                local centerRay = Workspace:Raycast(
                                    sensorOrigin, look * sensorDist, obsParams
                                )
                                local leftRay = Workspace:Raycast(
                                    sensorOrigin, (look - right * 0.45).Unit * (sensorDist * 0.85),
                                    obsParams
                                )
                                local rightRay = Workspace:Raycast(
                                    sensorOrigin, (look + right * 0.45).Unit * (sensorDist * 0.85),
                                    obsParams
                                )

                                local steer = 0
                                if leftRay and not rightRay then
                                    steer = 0.85
                                elseif rightRay and not leftRay then
                                    steer = -0.85
                                elseif centerRay then
                                    local lDist = leftRay and leftRay.Distance or sensorDist
                                    local rDist = rightRay and rightRay.Distance or sensorDist
                                    if lDist > rDist then
                                        steer = -1.0
                                    else
                                        steer = 1.0
                                    end
                                end

                                -- Emergency Soft-Noclip if obstacle is closer than 8 studs (prevents getting wedged)
                                if centerRay and centerRay.Distance < 8 then
                                    local colPart = veh:FindFirstChild("__collide")
                                    if colPart then
                                        colPart.CanCollide = false
                                        task.delay(
                                            0.4,
                                            function()
                                                pcall(
                                                    function()
                                                        colPart.CanCollide = true
                                                    end
                                                )
                                            end
                                        )
                                    end
                                end

                                -- 4. Anti-Stuck & Reverse Recovery
                                local actualSpeed = root.AssemblyLinearVelocity.Magnitude
                                if actualSpeed < 6 then
                                    stuckTimer = stuckTimer + 0.03
                                    if stuckTimer > 1.8 then
                                        seat.Throttle = -1
                                        seat.Steer = 1
                                        root.AssemblyLinearVelocity = -look * 60
                                        task.wait(0.7)
                                        root.CFrame = root.CFrame * CFrame.Angles(
                                            0, math.rad(45), 0
                                        )
                                        stuckTimer = 0
                                        return
                                    end
                                else
                                    stuckTimer = 0
                                end

                                -- 5. Drive & Steer
                                seat.Throttle = 1
                                local forwardVel = look * speed
                                root.AssemblyLinearVelocity = Vector3.new(
                                    forwardVel.X, root.AssemblyLinearVelocity.Y, forwardVel.Z
                                )

                                if math.abs(steer) > 0 then
                                    seat.Steer = steer
                                    root.AssemblyAngularVelocity = Vector3.new(0, -steer * 2.4, 0)
                                else
                                    seat.Steer = 0
                                    root.AssemblyAngularVelocity = Vector3.new(
                                        0, root.AssemblyAngularVelocity.Y * 0.6, 0
                                    )
                                end

                                if Settings.AutoUprightOnFarm and root.CFrame.UpVector.Y < 0.65 then
                                    uprightVehicle()
                                end
                            end
                        end
                    end
                )
            end
        end
    end
)

-- Quests Automation Worker (Auto-Take, Auto-Claim, Auto-Solve Races & Milestones)
task.spawn(
    function()
        while true do
            task.wait(1.5)
            pcall(
                function()
                    -- 1. Auto Accept, Track, and Pin Quests
                    if Settings.AutoTakeQuests then
                        autoPinAndTrackQuests()
                    end

                    -- 2. Auto Claim Completed Quests, Milestones & Gifts
                    if Settings.AutoClaimQuests then
                        checkAndClaimQuests()
                    end

                    -- 3. Auto Solve Active Race or Queue into Race for Pending Quests
                    if Settings.AutoSolveRaceQuests then
                        if RaceController and RaceController.isRacing and RaceController.isRacing() then
                            autoSolveActiveRace()
                        else
                            local quests = getPlayerQuestsData()
                            local needsRace = false
                            for _, q in ipairs(quests) do
                                local qId = q.QuestId or q.Name
                                if qId and qId:lower():find("race") then
                                    local isDone = (QuestController and QuestController.hasCompletedQuest(
                                        qId
                                    ))
                                    local isClaimed = (QuestUtil and QuestUtil.isQuestClaimed(
                                        LocalPlayer, qId
                                    )) or q.IsClaimed == true
                                    if not isDone and not isClaimed then
                                        needsRace = true
                                        break
                                    end
                                end
                            end
                            if needsRace and RaceQueuesController and RaceQueuesController.getQueueingForRaceTrackName then
                                local currentQueue = RaceQueuesController.getQueueingForRaceTrackName(
                                )
                                if not currentQueue then
                                    RaceQueuesController.joinQueue("Drag")
                                end
                            end
                        end
                    end
                end
            )
        end
    end
)

-- B. Intelligent Spookfest 2026 Candy Harvest Engine (Rate-Limit Compliant & Real Proximity)
local isHarvesting = false
local totalCandiesHarvested = 0

local function harvestNearestCandy()
    if isHarvesting then
        return false
    end
    isHarvesting = true

    local refPart = RootPart or (Character and Character:FindFirstChild("HumanoidRootPart"))
    if not refPart then
        isHarvesting = false
        return false
    end

    local curPos = refPart.Position
    local targetPos = nil
    local targetMesh = nil

    -- 1. Check physical mesh items currently rendered in Workspace.CollectibleSpawner
    local col = Workspace:FindFirstChild("CollectibleSpawner")
    if col then
        local closestDist = 999999
        for _, item in ipairs(col:GetChildren()) do
            local p = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            if p and item.Name ~= "Spookfest2026CandyCollect" then
                local d = (p.Position - curPos).Magnitude
                if d < closestDist then
                    closestDist = d
                    targetPos = p.Position
                    targetMesh = p
                end
            end
        end
    end

    -- 2. Fallback to CollectibleSpawnerController nearest candy point
    if not targetPos and CollectibleSpawnerController and CollectibleSpawnerController.GetNearestAvailable then
        local near = CollectibleSpawnerController.GetNearestAvailable("Spookfest2026Candy", curPos)
        if near then
            targetPos = near
        end
    end

    -- 3. Teleport and collect
    if targetPos then
        pcall(
            function()
                if isDriving() then
                    local veh = getMyVehicle()
                    local root = getVehicleRoot(veh)
                    if root then
                        -- Noclip vehicle during candy run
                        for _, desc in ipairs(veh:GetDescendants()) do
                            if desc:IsA("BasePart") then
                                desc.CanCollide = false
                            end
                        end
                        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 2.5, 0))
                        root.AssemblyLinearVelocity = Vector3.zero
                    end
                else
                    refPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 2.0, 0))
                end

                task.wait(0.18)

                -- Touch interest trigger
                if targetMesh and firetouchinterest then
                    firetouchinterest(targetMesh, refPart, 0)
                    task.wait(0.02)
                    firetouchinterest(targetMesh, refPart, 1)
                end

                -- Fire collectible collect remote within safe rate limits
                if CollectibleCollectRemote and CollectibleSpawnerController then
                    local upvals = getupvalues and getupvalues(
                        CollectibleSpawnerController.GetNearestAvailable
                    )
                    local hunts = upvals and upvals[1]
                    if hunts and hunts["Spookfest2026Candy"] then
                        for k, itm in pairs(hunts["Spookfest2026Candy"].shown) do
                            if itm.position and (itm.position - targetPos).Magnitude < 35 then
                                CollectibleCollectRemote:FireServer("Spookfest2026Candy", k)
                                totalCandiesHarvested = totalCandiesHarvested + 1
                                break
                            end
                        end
                    end
                end
            end
        )
    end

    isHarvesting = false
    return targetPos ~= nil
end

task.spawn(
    function()
        while true do
            task.wait(Settings.CollectInterval or 0.35)
            if Settings.AutoCollectCandies then
                pcall(harvestNearestCandy)
            end
        end
    end
)

-- C. Auto Claim Playtime Rewards
task.spawn(
    function()
        while true do
            task.wait(15)
            if Settings.AutoClaimRewards and ClaimRewardsRemote then
                pcall(
                    function()
                        ClaimRewardsRemote:FireServer()
                    end
                )
            end
        end
    end
)

-- D. Vehicle Modifiers (Heartbeat Hook - Speed & Torque Boost)
trackConnect(
    RunService.Heartbeat,
    function()
        pcall(
            function()
                local veh = getMyVehicle()
                local seat = getVehicleSeat(veh)
                local root = getVehicleRoot(veh)

                if seat and seat.Occupant and root and isDriving() then
                    -- Custom Driving Speed Boost (applies forward force when W is pressed)
                    if Settings.CustomSpeedEnabled and seat.ThrottleFloat > 0 then
                        local lv = root.CFrame.LookVector
                        local targetSpeed = Settings.VehicleMaxSpeed or 300
                        root.AssemblyLinearVelocity = Vector3.new(
                            lv.X * targetSpeed, root.AssemblyLinearVelocity.Y, lv.Z * targetSpeed
                        )
                    end

                    -- Enhanced Steering Agility
                    if Settings.EnhancedSteerEnabled and math.abs(seat.SteerFloat) > 0 then
                        local steerMult = Settings.SteerMultiplier or 1.8
                        root.AssemblyAngularVelocity = Vector3.new(
                            root.AssemblyAngularVelocity.X, -seat.SteerFloat * steerMult * 2.5,
                            root.AssemblyAngularVelocity.Z
                        )
                    end

                    -- Vehicle Noclip (drive through walls/trees)
                    if Settings.VehicleNoclip then
                        for _, desc in ipairs(veh:GetDescendants()) do
                            if desc:IsA("BasePart") then
                                desc.CanCollide = false
                            end
                        end
                    end

                    -- Auto Anti-Roll (keep upright)
                    if Settings.AutoAntiRoll then
                        local up = root.CFrame.UpVector
                        if up.Y < 0.65 then
                            local currentPos = root.Position
                            local look = root.CFrame.LookVector
                            local flatLook = Vector3.new(look.X, 0, look.Z).Unit
                            if flatLook.Magnitude < 0.1 then
                                flatLook = Vector3.new(0, 0, -1)
                            end
                            root.CFrame = CFrame.lookAt(
                                currentPos + Vector3.new(0, 2.0, 0),
                                currentPos + Vector3.new(0, 2.0, 0) + flatLook
                            )
                            root.AssemblyAngularVelocity = Vector3.zero
                        end
                    end
                end

                -- Vehicle Fly Engine
                if Settings.VehicleFly and isDriving() then
                    local veh = getMyVehicle()
                    local root = getVehicleRoot(veh)
                    if root then
                        local flySpeed = Settings.VehicleFlySpeed or 160
                        local moveDir = Vector3.zero
                        local cam = Workspace.CurrentCamera
                        local lv = cam.CFrame.LookVector
                        local rv = cam.CFrame.RightVector

                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            moveDir = moveDir + lv
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            moveDir = moveDir - lv
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            moveDir = moveDir + rv
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            moveDir = moveDir - rv
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            moveDir = moveDir + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            moveDir = moveDir - Vector3.new(0, 1, 0)
                        end

                        if moveDir.Magnitude > 0 then
                            root.AssemblyLinearVelocity = moveDir.Unit * flySpeed
                        else
                            root.AssemblyLinearVelocity = Vector3.zero
                        end
                        root.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        )
    end
)

-- E. Character Modifiers (WalkSpeed, JumpPower, Noclip)
trackConnect(
    RunService.Stepped,
    function()
        pcall(
            function()
                if Character and Humanoid then
                    if Settings.CustomWalkSpeedEnabled then
                        Humanoid.WalkSpeed = Settings.CustomWalkSpeed
                    end
                    if Settings.CustomJumpPowerEnabled then
                        Humanoid.UseJumpPower = true
                        Humanoid.JumpPower = Settings.CustomJumpPower
                    end
                end

                if Settings.PlayerNoclip and Character then
                    for _, desc in ipairs(Character:GetDescendants()) do
                        if desc:IsA("BasePart") then
                            desc.CanCollide = false
                        end
                    end
                end
            end
        )
    end
)

-- Infinite Jump Hook
trackConnect(
    UserInputService.JumpRequest,
    function()
        pcall(
            function()
                if Settings.InfiniteJump and Humanoid and not isDriving() then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        )
    end
)

-- Instant Emergency Handbrake Keybind (Hotkey: X)
trackConnect(
    UserInputService.InputBegan,
    function(input, gpe)
        if gpe then
            return
        end
        if input.KeyCode == Enum.KeyCode.X then
            pcall(
                function()
                    if isDriving() then
                        emergencyStop()
                        if _G.__WindUI then
                            _G.__WindUI:Notify(
                                {Title = "Handbrake", Content = "Vehicle stopped dead!", Duration = 1.2, Icon = "octagon"}
                            )
                        end
                    end
                end
            )
        end
    end
)

-- Anti-AFK Hook
trackConnect(
    LocalPlayer.Idled,
    function()
        pcall(
            function()
                if Settings.AntiAFK then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.zero)
                end
            end
        )
    end
)

-- ESP System
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "CellularHUB_ESP"
pcall(
    function()
        local target = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or CoreGui
        ESPFolder.Parent = target
    end
)

local function clearESP()
    pcall(
        function()
            for _, c in ipairs(ESPFolder:GetChildren()) do
                c:Destroy()
            end
        end
    )
end

local function updateESP()
    clearESP()
    if not (Settings.PlayerESP or Settings.VehicleESP or Settings.CandyESP) then
        return
    end

    -- Player ESP
    if Settings.PlayerESP then
        pcall(
            function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(
                        "HumanoidRootPart"
                    ) then
                        local hrp = p.Character.HumanoidRootPart
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "ESP_Player_" .. p.Name
                        bb.Adornee = hrp
                        bb.Size = UDim2.fromOffset(120, 40)
                        bb.AlwaysOnTop = true
                        bb.Parent = ESPFolder

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.fromScale(1, 1)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = string.format(
                            "👤 %s\n[%d m]", p.DisplayName or p.Name,
                            math.floor(
                                (hrp.Position - (RootPart and RootPart.Position or Vector3.zero)).Magnitude / 3.57
                            )
                        )
                        lbl.TextColor3 = Color3.fromRGB(0, 220, 255)
                        lbl.TextStrokeTransparency = 0.2
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 11
                        lbl.Parent = bb
                    end
                end
            end
        )
    end

    -- Candy ESP
    if Settings.CandyESP then
        pcall(
            function()
                local col = Workspace:FindFirstChild("CollectibleSpawner")
                if col then
                    for _, item in ipairs(col:GetChildren()) do
                        local p = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA(
                            "BasePart"
                        )
                        if p and item.Name ~= "Spookfest2026CandyCollect" then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "ESP_Candy_" .. item.Name
                            bb.Adornee = p
                            bb.Size = UDim2.fromOffset(80, 30)
                            bb.AlwaysOnTop = true
                            bb.Parent = ESPFolder

                            local lbl = Instance.new("TextLabel")
                            lbl.Size = UDim2.fromScale(1, 1)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = "🍬 " .. item.Name
                            lbl.TextColor3 = Color3.fromRGB(255, 170, 0)
                            lbl.TextStrokeTransparency = 0.2
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 10
                            lbl.Parent = bb
                        end
                    end
                end
            end
        )
    end
end

task.spawn(
    function()
        while true do
            task.wait(2.0)
            pcall(updateESP)
        end
    end
)

-- ==============================================================================
-- 6. WINDUI INTERFACE IMPLEMENTATION
-- ==============================================================================
local WindUI = loadstring(
    game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
)()
_G.__WindUI = WindUI

if WindUI and WindUI.Notify then
    local origNotify = WindUI.Notify
    WindUI.Notify = function(self, data)
        pcall(
            function()
                origNotify(self, data)
            end
        )
    end
end

local Window = WindUI:CreateWindow(
    {
        Title = "Cellular HUB", Author = "Driving Empire [🎃 Spookfest Edition]", Icon = "car",
        Folder = "CellularHUB_Config", Size = UDim2.fromOffset(630, 490),
        Theme = Settings.CurrentTheme or "Dark", ToggleKey = Enum.KeyCode.RightControl,
    }
)

-- TAB 1: AUTO FARM & ECONOMY
local TabFarm = Window:Tab({Title = "Auto Farm", Icon = "zap"})

local StatParagraph = TabFarm:Paragraph(
    {Title = "📊 Live Player Economy & Event Stats", Desc = "Calculating live balances..."}
)

-- Background Worker: Live Economy Telemetry Producer
task.spawn(
    function()
        while true do
            task.wait(1.5)
            pcall(
                function()
                    local candy = getPlayerCandy()
                    local cash = getPlayerCash()
                    local miles = getPlayerMiles()
                    local formattedCash = tostring(cash):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
                        "^,", ""
                    )
                    _G.__Cellular_LiveStatSummary = string.format(
                        "🍬 Event Candy: %d  |  💵 Cash: $%s  |  🛣️ Miles Driven: %d mi",
                        candy, formattedCash, miles
                    )
                end
            )
        end
    end
)

TabFarm:Section({Title = "AFK Auto Drive & Cash Farm"})

TabFarm:Toggle(
    {
        Title = "Auto Drive (AFK Money Farmer)",
        Desc = "Vehicle drives autonomously with obstacle avoidance and anti-void ground clamping. Earns cash while AFK.",
        Value = Settings.AutoFarmMiles,
        Callback = function(v)
            Settings.AutoFarmMiles = v
            if v and not isDriving() then
                enterMyVehicle()
            end
            SaveSettings(false)
        end
    }
)

TabFarm:Slider(
    {
        Title = "Cruising Drive Speed", Desc = "Target forward velocity (Studs/s)", Step = 10,
        Value = {Min = 80, Max = 350, Default = Settings.TargetFarmSpeed,},
        Callback = function(v)
            Settings.TargetFarmSpeed = v
            SaveSettings(false)
        end
    }
)

TabFarm:Toggle(
    {
        Title = "Obstacle Detection & Avoidance",
        Desc = "Scans front & sides with raycasts to automatically steer around walls, trees, and obstacles",
        Value = Settings.ObstacleAvoidance,
        Callback = function(v)
            Settings.ObstacleAvoidance = v
            SaveSettings(false)
        end
    }
)

TabFarm:Slider(
    {
        Title = "Obstacle Sensor Distance",
        Desc = "Forward scan range for obstacle detection (studs)", Step = 5,
        Value = {Min = 20, Max = 60, Default = Settings.AvoidanceDistance,},
        Callback = function(v)
            Settings.AvoidanceDistance = v
            SaveSettings(false)
        end
    }
)

TabFarm:Dropdown(
    {
        Title = "Auto Drive Navigation Mode",
        Desc = "Select navigation route (Highway Straightaway is 100% Smooth & Crash-Free)",
        Values = {
            "Highway Straightaway (100% Smooth / Anti-Crash / AFK Money)", "Smart Street Cruise"
        }, Value = Settings.AutoDriveMode,
        Callback = function(v)
            Settings.AutoDriveMode = v
            SaveSettings(false)
        end
    }
)

TabFarm:Toggle(
    {
        Title = "Anti-Water Protection Sensor",
        Desc = "Scans ahead for ocean/water and automatically reverses to prevent drowning",
        Value = Settings.AntiWaterProtection,
        Callback = function(v)
            Settings.AntiWaterProtection = v
            SaveSettings(false)
        end
    }
)

TabFarm:Toggle(
    {
        Title = "Auto Anti-Roll / Keep Upright",
        Desc = "Keeps vehicle horizontally level and flips car upright if overturned",
        Value = Settings.AutoUprightOnFarm,
        Callback = function(v)
            Settings.AutoUprightOnFarm = v
            SaveSettings(false)
        end
    }
)

TabFarm:Button(
    {
        Title = "Teleport to Highway Straightaway (Farm Lane)",
        Desc = "Instantly aligns vehicle to the smooth 4-lane highway farming lane",
        Callback = function()
            local veh = getMyVehicle()
            if veh then
                veh:PivotTo(CFrame.new(-1109, 26.5, -3450) * CFrame.Angles(0, 0, 0))
                WindUI:Notify(
                    {
                        Title = "Highway Farm", Content = "Teleported to Highway Straightaway!",
                        Duration = 2.0, Icon = "map-pin"
                    }
                )
            else
                WindUI:Notify(
                    {
                        Title = "Highway Farm", Content = "Spawn a vehicle first!", Duration = 2.0,
                        Icon = "alert-triangle"
                    }
                )
            end
        end
    }
)

TabFarm:Section({Title = "🎃 Spookfest 2026 Event"})

TabFarm:Toggle(
    {
        Title = "Auto Harvest Halloween Candies (Real Proximity)",
        Desc = "Auto-teleports through nearest candies and drops within server rate limits to genuinely fill candy bag",
        Value = Settings.AutoCollectCandies,
        Callback = function(v)
            Settings.AutoCollectCandies = v
            SaveSettings(false)
        end
    }
)

TabFarm:Slider(
    {
        Title = "Harvest Rate Delay",
        Desc = "Safe stepping delay between candy collections (seconds)", Step = 0.05,
        Value = {Min = 0.20, Max = 1.50, Default = Settings.CollectInterval,},
        Callback = function(v)
            Settings.CollectInterval = v
            SaveSettings(false)
        end
    }
)

TabFarm:Button(
    {
        Title = "Harvest 10 Nearest Candies Instantly",
        Desc = "Performs a quick burst harvest of 10 nearby candies with genuine server validation",
        Callback = function()
            task.spawn(
                function()
                    local collected = 0
                    for i = 1, 10 do
                        if harvestNearestCandy() then
                            collected = collected + 1
                            task.wait(0.25)
                        end
                    end
                    WindUI:Notify(
                        {
                            Title = "Candy Harvest Complete",
                            Content = string.format(
                                "Harvested %d candy nodes! New Candy: %d 🍬", collected,
                                getPlayerCandy()
                            ), Duration = 3.0, Icon = "sparkles"
                        }
                    )
                end
            )
        end
    }
)

TabFarm:Toggle(
    {
        Title = "Auto Claim Rewards",
        Desc = "Automatically claim playtime rewards & gifts on cooldown",
        Value = Settings.AutoClaimRewards,
        Callback = function(v)
            Settings.AutoClaimRewards = v
            SaveSettings(false)
        end
    }
)

-- TAB 2: QUESTS & DAILY CHALLENGES
local TabQuests = Window:Tab({Title = "Quests & Daily", Icon = "award"})

local QuestParagraph = TabQuests:Paragraph(
    {Title = "📋 Active Daily Quests & Progress", Desc = "Loading quests..."}
)

-- Background Worker: Live Quest Status Producer
task.spawn(
    function()
        while true do
            task.wait(1.5)
            pcall(
                function()
                    _G.__Cellular_LiveQuestSummary = getActiveQuestsSummary()
                end
            )
        end
    end
)

-- Pure UI Consumer Thread (Maintains full executor capabilities, safely renders WindUI labels)
local cachedStatLabel = nil
local cachedQuestLabel = nil

task.spawn(
    function()
        while true do
            task.wait(0.8)
            pcall(
                function()
                    local hui = gethui and gethui()
                    local wGui = hui and hui:FindFirstChild("WindUI")
                    if not wGui then
                        return
                    end

                    local statText = _G.__Cellular_LiveStatSummary
                    local questText = _G.__Cellular_LiveQuestSummary

                    -- Render Live Stats
                    if statText then
                        if not (cachedStatLabel and cachedStatLabel.Parent) then
                            for _, d in ipairs(wGui:GetDescendants()) do
                                if d:IsA("TextLabel") and d.Text:find("Live Player Economy") then
                                    local card = d:FindFirstAncestorWhichIsA("ImageButton")
                                    if card then
                                        for _, sub in ipairs(card:GetDescendants()) do
                                            if sub:IsA("TextLabel") and sub ~= d then
                                                cachedStatLabel = sub
                                                break
                                            end
                                        end
                                    end
                                    break
                                end
                            end
                        end
                        if cachedStatLabel and cachedStatLabel.Parent then
                            cachedStatLabel.Text = statText
                        end
                    end

                    -- Render Live Quests
                    if questText then
                        if not (cachedQuestLabel and cachedQuestLabel.Parent) then
                            for _, d in ipairs(wGui:GetDescendants()) do
                                if d:IsA("TextLabel") and d.Text:find("Active Daily Quests") then
                                    local card = d:FindFirstAncestorWhichIsA("ImageButton")
                                    if card then
                                        for _, sub in ipairs(card:GetDescendants()) do
                                            if sub:IsA("TextLabel") and sub ~= d then
                                                cachedQuestLabel = sub
                                                break
                                            end
                                        end
                                    end
                                    break
                                end
                            end
                        end
                        if cachedQuestLabel and cachedQuestLabel.Parent then
                            cachedQuestLabel.Text = questText
                        end
                    end
                end
            )
        end
    end
)

TabQuests:Section({Title = "Quest Automation & Instant Rewards"})

TabQuests:Toggle(
    {
        Title = "Auto Take & Pin Quests (Auto Terima Misi)",
        Desc = "Automatically accepts, tracks, and pins all daily quests so they are visible and active",
        Value = Settings.AutoTakeQuests,
        Callback = function(v)
            Settings.AutoTakeQuests = v
            SaveSettings(false)
        end
    }
)

TabQuests:Toggle(
    {
        Title = "Auto Claim Completed Quests (Auto Klaim Hadiah)",
        Desc = "Automatically claims cash and XP as soon as quests reach 100%",
        Value = Settings.AutoClaimQuests,
        Callback = function(v)
            Settings.AutoClaimQuests = v
            SaveSettings(false)
        end
    }
)

TabQuests:Toggle(
    {
        Title = "Auto Claim Weekly Milestones",
        Desc = "Automatically unlocks and claims completed weekly milestone reward tiers",
        Value = Settings.AutoClaimMilestones,
        Callback = function(v)
            Settings.AutoClaimMilestones = v
            SaveSettings(false)
        end
    }
)

TabQuests:Toggle(
    {
        Title = "Auto Solve Race Quests (Bot Balapan Otomatis)",
        Desc = "Automatically queues into races, drives through checkpoints, and finishes races to solve quests",
        Value = Settings.AutoSolveRaceQuests,
        Callback = function(v)
            Settings.AutoSolveRaceQuests = v
            SaveSettings(false)
        end
    }
)

TabQuests:Toggle(
    {
        Title = "Auto Claim Playtime & Free Gifts",
        Desc = "Automatically claims playtime reward chests and leaderboard gifts on cooldown",
        Value = Settings.AutoClaimRewards,
        Callback = function(v)
            Settings.AutoClaimRewards = v
            SaveSettings(false)
        end
    }
)

TabQuests:Button(
    {
        Title = "Claim All Available Quests & Milestones Now",
        Desc = "Sweeps and claims all completed quests, milestones, and gift tokens right now",
        Callback = function()
            local count = checkAndClaimQuests()
            pcall(
                function()
                    WindUI:Notify(
                        {
                            Title = "Quests Claimed",
                            Content = string.format(
                                "Processed and claimed %d quest rewards!", count
                            ), Duration = 2.5, Icon = "check-circle"
                        }
                    )
                end
            )
        end
    }
)

TabQuests:Section({Title = "Race Solver & Instant Finish"})

TabQuests:Button(
    {
        Title = "Auto Finish Active Race Now (Instan Selesai Balapan)",
        Desc = "If currently in a race, instantly drives through checkpoints and completes the race",
        Callback = function()
            task.spawn(
                function()
                    autoSolveActiveRace()
                    pcall(
                        function()
                            WindUI:Notify(
                                {Title = "Race Solver", Content = "Race solved and finished!", Duration = 2.5, Icon = "flag"}
                            )
                        end
                    )
                end
            )
        end
    }
)

local selectedRaceTrack = "Drag"
TabQuests:Dropdown(
    {
        Title = "Select Race Track for Quests",
        Desc = "Select which race to automatically join for completing race challenges",
        Values = {"Drag", "Circuit", "Highway", "SandyShores", "CrossCountry", "SofiaBay"},
        Value = "Drag",
        Callback = function(v)
            selectedRaceTrack = v
        end
    }
)

TabQuests:Button(
    {
        Title = "Join Selected Race Queue",
        Desc = "Queues you into the selected race on the server to complete race challenges",
        Callback = function()
            pcall(
                function()
                    if RaceQueuesController and RaceQueuesController.joinQueue then
                        RaceQueuesController.joinQueue(selectedRaceTrack)
                    elseif RaceQueueRemote then
                        RaceQueueRemote:FireServer(selectedRaceTrack, "Standard", "Join")
                    end
                    WindUI:Notify(
                        {
                            Title = "Race Queue",
                            Content = string.format("Joined %s race queue!", selectedRaceTrack),
                            Duration = 2.0, Icon = "flag"
                        }
                    )
                end
            )
        end
    }
)

TabQuests:Button(
    {
        Title = "Leave Current Race Queue",
        Desc = "Leaves the matchmaking queue if you change your mind",
        Callback = function()
            pcall(
                function()
                    if RaceQueuesController and RaceQueuesController.leaveQueue then
                        RaceQueuesController.leaveQueue(selectedRaceTrack)
                    elseif RaceQueueRemote then
                        RaceQueueRemote:FireServer(selectedRaceTrack, "Standard", "Leave")
                    end
                    WindUI:Notify(
                        {Title = "Race Queue", Content = "Left race queue.", Duration = 2.0, Icon = "x-circle"}
                    )
                end
            )
        end
    }
)

TabQuests:Button(
    {
        Title = "Force Refresh Quest Status",
        Desc = "Instantly re-scans server quest progress and kilometer counts",
        Callback = function()
            pcall(
                function()
                    _G.__Cellular_LiveQuestSummary = getActiveQuestsSummary()
                end
            )
            pcall(
                function()
                    WindUI:Notify(
                        {
                            Title = "Quests Refreshed", Content = "Live quest data synchronized!",
                            Duration = 2.0, Icon = "refresh-cw"
                        }
                    )
                end
            )
        end
    }
)

-- TAB 3: VEHICLE SPAWNER
local TabSpawner = Window:Tab({Title = "Vehicle Spawner", Icon = "key"})
TabSpawner:Section({Title = "Spawn Owned Vehicles"})

local ownedCarsList = getOwnedVehiclesList()
local carDropdown = TabSpawner:Dropdown(
    {
        Title = "Select Vehicle", Desc = "Choose which of your owned cars to spawn",
        Values = ownedCarsList, Value = ownedCarsList[1] or "Nissan-GTR2017",
        Callback = function(v)
            Settings.SelectedVehicleToSpawn = v
            SaveSettings(false)
        end
    }
)

TabSpawner:Button(
    {
        Title = "Spawn Selected Vehicle",
        Desc = "Spawns the chosen vehicle at your current position",
        Callback = function()
            local car = Settings.SelectedVehicleToSpawn or ownedCarsList[1]
            if spawnVehicle(car) then
                WindUI:Notify(
                    {
                        Title = "Vehicle Spawner", Content = "Spawned " .. tostring(car) .. "!",
                        Duration = 2.5, Icon = "check"
                    }
                )
            end
        end
    }
)

TabSpawner:Button(
    {
        Title = "Despawn Current Vehicle", Desc = "Returns your active vehicle back to your garage",
        Callback = function()
            despawnVehicle()
            WindUI:Notify(
                {
                    Title = "Vehicle Spawner", Content = "Despawned current vehicle.",
                    Duration = 2.0, Icon = "trash-2"
                }
            )
        end
    }
)

TabSpawner:Button(
    {
        Title = "Refresh Vehicle List",
        Desc = "Rescans your vehicle inventory and updates dropdown",
        Callback = function()
            local updated = getOwnedVehiclesList()
            if carDropdown and carDropdown.Refresh then
                carDropdown:Refresh(updated)
            end
            WindUI:Notify(
                {
                    Title = "Vehicle Inventory",
                    Content = string.format("Detected %d owned cars!", #updated), Duration = 2.0,
                    Icon = "refresh-cw"
                }
            )
        end
    }
)

TabSpawner:Toggle(
    {
        Title = "Auto Sit On Spawn",
        Desc = "Automatically teleports into driver seat when vehicle spawns",
        Value = Settings.AutoSitOnSpawn,
        Callback = function(v)
            Settings.AutoSitOnSpawn = v
            SaveSettings(false)
        end
    }
)

TabSpawner:Button(
    {
        Title = "Enter Spawned Car Now", Desc = "Teleports character into active car's driver seat",
        Callback = function()
            if enterMyVehicle() then
                WindUI:Notify(
                    {Title = "Vehicle", Content = "Entered driver seat!", Duration = 1.5, Icon = "check"}
                )
            else
                WindUI:Notify(
                    {Title = "Vehicle", Content = "Vehicle not found!", Duration = 2.0, Icon = "alert-triangle"}
                )
            end
        end
    }
)

-- TAB 4: VEHICLE MODS & TUNING
local TabVeh = Window:Tab({Title = "Vehicle Tuning", Icon = "gauge"})
TabVeh:Section({Title = "Engine & Handling Upgrades"})

TabVeh:Toggle(
    {
        Title = "Custom Top Speed Overdrive",
        Desc = "Unlocks maximum velocity beyond default vehicle limits",
        Value = Settings.CustomSpeedEnabled,
        Callback = function(v)
            Settings.CustomSpeedEnabled = v
            SaveSettings(false)
        end
    }
)

TabVeh:Slider(
    {
        Title = "Top Speed Limit", Desc = "Target speed when holding throttle (W)", Step = 10,
        Value = {Min = 100, Max = 500, Default = Settings.VehicleMaxSpeed,},
        Callback = function(v)
            Settings.VehicleMaxSpeed = v
            SaveSettings(false)
        end
    }
)

TabVeh:Toggle(
    {
        Title = "Enhanced Steering Agility",
        Desc = "Sharper, more responsive cornering without drifting out",
        Value = Settings.EnhancedSteerEnabled,
        Callback = function(v)
            Settings.EnhancedSteerEnabled = v
            SaveSettings(false)
        end
    }
)

TabVeh:Slider(
    {
        Title = "Steering Multiplier", Desc = "Steer responsiveness scale", Step = 0.2,
        Value = {Min = 1.0, Max = 4.0, Default = Settings.SteerMultiplier,},
        Callback = function(v)
            Settings.SteerMultiplier = v
            SaveSettings(false)
        end
    }
)

TabVeh:Section({Title = "Flight & Physics"})

TabVeh:Toggle(
    {
        Title = "Vehicle Flight (Car Fly)",
        Desc = "Fly vehicle with WASD + Space (Ascend) + Left Shift (Descend)",
        Value = Settings.VehicleFly,
        Callback = function(v)
            Settings.VehicleFly = v
            if not v then
                emergencyStop()
            end
            SaveSettings(false)
        end
    }
)

TabVeh:Slider(
    {
        Title = "Flight Speed", Desc = "Air cruise flight speed", Step = 10,
        Value = {Min = 50, Max = 350, Default = Settings.VehicleFlySpeed,},
        Callback = function(v)
            Settings.VehicleFlySpeed = v
            SaveSettings(false)
        end
    }
)

TabVeh:Toggle(
    {
        Title = "Vehicle Noclip",
        Desc = "Drive through buildings, trees, and obstacles without crashing",
        Value = Settings.VehicleNoclip,
        Callback = function(v)
            Settings.VehicleNoclip = v
            SaveSettings(false)
        end
    }
)

TabVeh:Toggle(
    {
        Title = "Auto Anti-Roll (Keep Upright)",
        Desc = "Automatically flips vehicle right-side up if tilted or overturned",
        Value = Settings.AutoAntiRoll,
        Callback = function(v)
            Settings.AutoAntiRoll = v
            SaveSettings(false)
        end
    }
)

TabVeh:Button(
    {
        Title = "Instant Handbrake (Stop Vehicle)",
        Desc = "Completely zeroes out vehicle velocity (Hotkey: X)",
        Callback = function()
            emergencyStop()
            WindUI:Notify(
                {Title = "Vehicle", Content = "Emergency brake engaged!", Duration = 1.5, Icon = "octagon"}
            )
        end
    }
)

TabVeh:Button(
    {
        Title = "Upright Car Immediately",
        Desc = "Snaps car orientation straight and levels wheels",
        Callback = function()
            uprightVehicle()
        end
    }
)

-- TAB 5: TELEPORTS & MULTIPLAYER
local TabTP = Window:Tab({Title = "Teleports", Icon = "map-pin"})

local function createTeleportSection(tab, title, locTable)
    tab:Section({Title = title})
    local names = {}
    for k in pairs(locTable) do
        table.insert(names, k)
    end
    table.sort(names)
    local selected = names[1]

    tab:Dropdown(
        {
            Title = "Select " .. title, Desc = "Choose destination location", Values = names,
            Value = selected,
            Callback = function(v)
                selected = v
            end
        }
    )

    tab:Button(
        {
            Title = "Teleport to " .. title,
            Desc = "Instantly teleports character/vehicle to destination",
            Callback = function()
                local targetPos = locTable[selected]
                if targetPos then
                    safeTeleportTarget(targetPos)
                    WindUI:Notify(
                        {
                            Title = "Teleported", Content = "Arrived at " .. tostring(selected),
                            Duration = 2.0, Icon = "navigation"
                        }
                    )
                end
            end
        }
    )
end

createTeleportSection(TabTP, "🎃 Halloween Event Hubs", TeleportLocations.Halloween)
createTeleportSection(TabTP, "Official Race Tracks", TeleportLocations.Races)
createTeleportSection(TabTP, "Vehicle Dealerships", TeleportLocations.Dealerships)
createTeleportSection(TabTP, "Jobs & Services", TeleportLocations.Jobs)
createTeleportSection(TabTP, "Car Meets & Hangouts", TeleportLocations.CarMeets)

TabTP:Section({Title = "👥 Multiplayer & Friend Teleport"})
local function getOtherPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    if #list == 0 then
        table.insert(list, "No other players online")
    end
    table.sort(list)
    return list
end

local otherPlayersList = getOtherPlayers()
local selectedPlayerStr = otherPlayersList[1]

local playerDropdown = TabTP:Dropdown(
    {
        Title = "Select Friend / Player", Desc = "Choose a player on this server to teleport to",
        Values = otherPlayersList, Value = selectedPlayerStr,
        Callback = function(v)
            selectedPlayerStr = v
        end
    }
)

TabTP:Button(
    {
        Title = "Teleport to Friend / Player",
        Desc = "Instantly teleports you and your car directly next to your friend",
        Callback = function()
            local targetName = selectedPlayerStr:match("%(@(.+)%)")
            if not targetName then
                WindUI:Notify(
                    {Title = "Teleport", Content = "No valid player selected!", Duration = 2.0, Icon = "alert-circle"}
                )
                return
            end
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild(
                "HumanoidRootPart"
            ) then
                local pos = targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 5)
                safeTeleportTarget(pos)
                WindUI:Notify(
                    {
                        Title = "Teleported to Friend",
                        Content = "Arrived at " .. targetPlayer.DisplayName .. "!", Duration = 2.5,
                        Icon = "users"
                    }
                )
            else
                WindUI:Notify(
                    {
                        Title = "Teleport", Content = "Player character not found or too far!",
                        Duration = 2.0, Icon = "alert-triangle"
                    }
                )
            end
        end
    }
)

TabTP:Button(
    {
        Title = "Refresh Player List", Desc = "Updates the list of active players in server",
        Callback = function()
            local updated = getOtherPlayers()
            if playerDropdown and playerDropdown.Refresh then
                playerDropdown:Refresh(updated)
            end
            WindUI:Notify(
                {
                    Title = "Players",
                    Content = string.format("Found %d online players!", #updated), Duration = 1.5,
                    Icon = "refresh-cw"
                }
            )
        end
    }
)

-- TAB 6: CHARACTER & ESP
local TabChar = Window:Tab({Title = "Character & ESP", Icon = "user"})
TabChar:Section({Title = "Movement Enhancements"})

TabChar:Toggle(
    {
        Title = "Speed Multiplier", Desc = "Modify your on-foot sprinting speed",
        Value = Settings.CustomWalkSpeedEnabled,
        Callback = function(v)
            Settings.CustomWalkSpeedEnabled = v
            if not v and Humanoid then
                Humanoid.WalkSpeed = 16
            end
            SaveSettings(false)
        end
    }
)

TabChar:Slider(
    {
        Title = "WalkSpeed", Desc = "On-foot sprint speed", Step = 5,
        Value = {Min = 16, Max = 250, Default = Settings.CustomWalkSpeed,},
        Callback = function(v)
            Settings.CustomWalkSpeed = v
            if Settings.CustomWalkSpeedEnabled and Humanoid then
                Humanoid.WalkSpeed = v
            end
            SaveSettings(false)
        end
    }
)

TabChar:Toggle(
    {
        Title = "Jump Multiplier", Desc = "Increase vertical jump height",
        Value = Settings.CustomJumpPowerEnabled,
        Callback = function(v)
            Settings.CustomJumpPowerEnabled = v
            if not v and Humanoid then
                Humanoid.JumpPower = 50
            end
            SaveSettings(false)
        end
    }
)

TabChar:Slider(
    {
        Title = "JumpPower", Desc = "Vertical jump power", Step = 10,
        Value = {Min = 50, Max = 300, Default = Settings.CustomJumpPower,},
        Callback = function(v)
            Settings.CustomJumpPower = v
            if Settings.CustomJumpPowerEnabled and Humanoid then
                Humanoid.JumpPower = v
            end
            SaveSettings(false)
        end
    }
)

TabChar:Toggle(
    {
        Title = "Infinite Jump", Desc = "Allows jumping repeatedly in mid-air",
        Value = Settings.InfiniteJump,
        Callback = function(v)
            Settings.InfiniteJump = v
            SaveSettings(false)
        end
    }
)

TabChar:Toggle(
    {
        Title = "Player Noclip", Desc = "Walk through doors, fences, and walls without obstruction",
        Value = Settings.PlayerNoclip,
        Callback = function(v)
            Settings.PlayerNoclip = v
            SaveSettings(false)
        end
    }
)

TabChar:Section({Title = "Visuals & ESP"})

TabChar:Toggle(
    {
        Title = "Player ESP", Desc = "Highlights all online players with distance indicators",
        Value = Settings.PlayerESP,
        Callback = function(v)
            Settings.PlayerESP = v
            updateESP()
            SaveSettings(false)
        end
    }
)

TabChar:Toggle(
    {
        Title = "Halloween Candy ESP", Desc = "Shows 3D glowing markers above active candy nodes",
        Value = Settings.CandyESP,
        Callback = function(v)
            Settings.CandyESP = v
            updateESP()
            SaveSettings(false)
        end
    }
)

-- TAB 7: SETTINGS & PROFILES
local TabSettings = Window:Tab({Title = "Settings", Icon = "settings"})
TabSettings:Section({Title = "Profile Management"})

TabSettings:Button(
    {
        Title = "Save Current Configuration",
        Desc = "Persists your active settings to JSON storage",
        Callback = function()
            SaveSettings(true)
        end
    }
)

TabSettings:Button(
    {
        Title = "Load Configuration", Desc = "Applies your previously saved configuration",
        Callback = function()
            LoadSettings(true)
        end
    }
)

TabSettings:Button(
    {
        Title = "Restore Defaults", Desc = "Resets all settings to factory defaults",
        Callback = function()
            Settings.AutoFarmMiles = false
            Settings.AutoCollectCandies = false
            Settings.CustomSpeedEnabled = false
            Settings.VehicleFly = false
            Settings.VehicleNoclip = false
            Settings.PlayerNoclip = false
            Settings.PlayerESP = false
            Settings.CandyESP = false
            clearESP()
            emergencyStop()
            WindUI:Notify(
                {Title = "Settings", Content = "Defaults restored!", Duration = 2.0, Icon = "rotate-ccw"}
            )
        end
    }
)

TabSettings:Section({Title = "Termination"})
TabSettings:Button(
    {
        Title = "Unload Cellular HUB",
        Desc = "Safely disconnects all loops, clears ESP, and closes GUI",
        Callback = function()
            if _G.__CellularHub_DrivingEmpire_Cleanup then
                _G.__CellularHub_DrivingEmpire_Cleanup()
            end
            WindUI:Notify(
                {Title = "Unloaded", Content = "Cellular HUB cleanly closed.", Duration = 2.0, Icon = "x-circle"}
            )
        end
    }
)

-- ==============================================================================
-- 7. CLEANUP REGISTRATION
-- ==============================================================================
_G.__CellularHub_DrivingEmpire_Cleanup = function()
    for _, conn in ipairs(ActiveConnections) do
        pcall(
            function()
                conn:Disconnect()
            end
        )
    end
    table.clear(ActiveConnections)

    pcall(
        function()
            if Humanoid then
                Humanoid.WalkSpeed = 16
                Humanoid.JumpPower = 50
            end
        end
    )

    clearESP()
    pcall(
        function()
            ESPFolder:Destroy()
        end
    )

    pcall(
        function()
            Window:Destroy()
        end
    )
    _G.__WindUI = nil
    _G.__CellularHub_DrivingEmpire_Cleanup = nil
end

LoadSettings(false)

WindUI:Notify(
    {
        Title = "Cellular HUB Active",
        Content = "Driving Empire [🎃 Spookfest] loaded!\nAuto Farm & Candy Harvester Ready.\nToggle UI with [Right Control].",
        Duration = 4.0, Icon = "check-circle"
    }
)

print("CELLULAR_HUB_LOADED_SUCCESSFULLY")
