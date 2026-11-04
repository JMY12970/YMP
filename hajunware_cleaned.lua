local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local virtualUser = game:GetService("VirtualUser")
local teleportService = game:GetService("TeleportService")
local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")
local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

_G.ENTITY_PATH = nil
_G.INTERACT_PATH = nil

if _G.ESP_ENABLED == nil then
  _G.ESP_ENABLED = true
end

_G.ESP_Config = {
  BeamWidth = 0.8,
  TracerBeam = true,
  CornerBeams = true,
  CornerWidth = 0.3,
  CornerLen = 0.3,
  CornerPad = 0.4,
  Max_ESP_Radius = 150,
  Max_Screen_Count = 25,
  Colors = {
    Player = Color3.fromRGB(0, 255, 150),
    Interactable = Color3.fromRGB(170, 0, 255),
    DefaultEntity = Color3.fromRGB(255, 0, 80),
    Fuse = Color3.fromRGB(255, 200, 0),
  },
}

_G.HajunESP = _G.HajunESP or {}
_G.HajunTargets = _G.HajunTargets or {}
_G.LiveInteractablesCache = {}
_G.LiveEntitiesCache = {}
_G.LiveFuseCache = {}

function _G.getRoot(instance)
  if not instance then
    return nil
  elseif instance:IsA("BasePart") then
    return instance
  end

  if instance:IsA("Model") then
    return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
  end

  return nil
end

local function styleBeam(instance2, p1, color, textureSpeed)
  instance2.Texture = "rbxassetid://446111271"
  instance2.TextureMode = Enum.TextureMode.Wrap
  instance2.TextureLength = 2
  instance2.TextureSpeed = textureSpeed
  instance2.FaceCamera = true
  instance2.LightEmission = 1
  instance2.Brightness = 8
  instance2.Width0 = p1
  instance2.Width1 = p1
  instance2.Color = ColorSequence.new(color)
end

local function getIsDescendantOf(instance3)
  local interactPATH = _G.INTERACT_PATH

  if not interactPATH then
    return false
  end

  return instance3 == interactPATH or instance3:IsDescendantOf(interactPATH)
end

local function getIsDescendantOf2(instance4)
  local entityPATH = _G.ENTITY_PATH

  if not entityPATH then
    return false
  end

  return instance4 == entityPATH or instance4:IsDescendantOf(entityPATH)
end

local function getESPColor(key)
  local v1 = _G.LiveFuseCache[key]

  if v1 then
    return v1.color
  elseif getIsDescendantOf(key) then
    return _G.ESP_Config.Colors.Interactable
  end

  if getIsDescendantOf2(key) then
    return _G.ESP_Config.Colors.DefaultEntity
  end

  if players:GetPlayerFromCharacter(key) then
    return _G.ESP_Config.Colors.Player
  end

  return _G.ESP_Config.Colors.DefaultEntity
end

function _G.removeESP(key2)
  local v2 = _G.HajunESP[key2]

  if not v2 then
    return
  end

  if v2.connection then
    pcall(function() v2.connection:Disconnect() end)
  end

  pcall(function()
    if v2.beam then
      v2.beam.Enabled = false
      v2.beam:Destroy()
    end
  end)

  pcall(function()
    if v2.attach then
      v2.attach:Destroy()
    end
  end)

  pcall(function()
    if v2.attach0 then
      v2.attach0:Destroy()
    end
  end)

  pcall(function()
    if v2.beamPart then
      v2.beamPart:Destroy()
    end
  end)

  pcall(function()
    if v2.cornerPart then
      v2.cornerPart:Destroy()
    end
  end)

  pcall(function()
    if v2.highlight then
      v2.highlight:Destroy()
    end
  end)

  pcall(function()
    if v2.bill then
      v2.bill:Destroy()
    end
  end)

  _G.HajunESP[key2] = nil
end

function _G.createESP(key3)
  if _G.HajunESP[key3] then
    return
  end

  local g = _G.getRoot(key3)

  if not g then
    return
  end

  local character = localPlayer.Character
  local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

  if not humanoidRootPart then
    return
  end

  local espConfig = _G.ESP_Config
  local v3 = getESPColor(key3)

  local highlight = Instance.new("Highlight")
  highlight.Adornee = key3
  highlight.FillTransparency = 1
  highlight.OutlineColor = v3
  highlight.Parent = playerGui

  local head = key3:FindFirstChild("Head")

  if not head and key3:IsA("Model") then
    local y = -99999

    for _, value in ipairs(key3:GetDescendants()) do
      if value:IsA("BasePart") and value.Position.Y > y then
        y = value.Position.Y
        head = value
      end
    end
  end

  local adornee = head or g

  local billboardGui = Instance.new("BillboardGui")
  billboardGui.Size = UDim2.new(0, 140, 0, 32)
  billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
  billboardGui.AlwaysOnTop = true
  billboardGui.Adornee = adornee
  billboardGui.Parent = playerGui

  local instance5 = Instance.new("TextLabel", billboardGui)
  instance5.Size = UDim2.new(1, 0, 0, 14)
  instance5.BackgroundTransparency = 1
  instance5.Font = Enum.Font.Code
  instance5.TextSize = 10
  instance5.TextColor3 = v3
  instance5.TextStrokeTransparency = 0.2

  local name = key3.Name
  local getPlayerFromCharacter = players:GetPlayerFromCharacter(key3)

  if getPlayerFromCharacter then
    name = getPlayerFromCharacter.Name
  end

  if _G.LiveFuseCache[key3] then
    instance5.Text = "[" .. tostring(_G.LiveFuseCache[key3].label):upper() .. "]"
  else
    instance5.Text = getIsDescendantOf(key3) and "[" .. key3.Name:upper() .. "]"
      or "[" .. name:upper() .. "]"
  end

  local statusTrack = Instance.new("Frame", billboardGui)
  statusTrack.Name = "StatusTrack"
  statusTrack.Size = UDim2.new(0.65, 0, 0, 3)
  statusTrack.Position = UDim2.new(0.175, 0, 0, 16)
  statusTrack.BackgroundColor3 = Color3.fromRGB(15, 22, 30)
  statusTrack.BorderSizePixel = 0

  local fill = Instance.new("Frame", statusTrack)
  fill.Name = "Fill"
  fill.Size = UDim2.new(1, 0, 1, 0)
  fill.BackgroundColor3 = v3
  fill.BorderSizePixel = 0

  local part = Instance.new("Part")
  part.Anchored = true
  part.Transparency = 1
  part.CanCollide = false
  part.CanQuery = false
  part.CanTouch = false
  part.Size = Vector3.new(0.1, 0.1, 0.1)
  part.CFrame = g.CFrame
  part.Parent = workspace

  local instance6 = Instance.new("Attachment", humanoidRootPart)
  local instance7 = Instance.new("Attachment", part)

  local instance8 = Instance.new("Beam", part)
  instance8.Attachment0 = instance6
  instance8.Attachment1 = instance7

  styleBeam(instance8, espConfig.BeamWidth, v3, 3)

  local part2 = Instance.new("Part")
  part2.Anchored = true
  part2.Transparency = 1
  part2.CanCollide = false
  part2.CanQuery = false
  part2.CanTouch = false
  part2.Size = Vector3.new(0.1, 0.1, 0.1)
  part2.CFrame = g.CFrame
  part2.Parent = workspace

  local v4 = {}
  local list = {}

  for i = 1, 12 do
    v4[i] = Instance.new("Attachment", part2)
  end

  for j = 0, 3 do
    for k = 1, 2 do
      local instance9 = Instance.new("Beam", part2)
      instance9.Attachment0 = v4[j * 3 + 1]
      instance9.Attachment1 = v4[j * 3 + 1 + k]

      styleBeam(instance9, espConfig.CornerWidth, v3, 3)
      list[#list + 1] = instance9
    end
  end

  local v5 = { { -1, 1 }, { 1, 1 }, { -1, -1 }, { 1, -1 } }

  local connect

  connect = runService.RenderStepped:Connect(function()
    if not g or not g.Parent or not part.Parent then
      if connect then
        connect:Disconnect()
      end

      return
    end

    local espConfig2 = _G.ESP_Config
    part.CFrame = g.CFrame
    instance8.Enabled = espConfig2.TracerBeam
    local beamWidth = espConfig2.BeamWidth
    local beamWidth2 = espConfig2.BeamWidth

    instance8.Width0 = beamWidth
    instance8.Width1 = beamWidth2

    local cornerBeams = espConfig2.CornerBeams

    for _, value2 in ipairs(list) do
      value2.Enabled = cornerBeams
    end

    if not cornerBeams then
      return
    end

    local cframe, size

    if key3:IsA("Model") then
      cframe, size = key3:GetBoundingBox()
    else
      cframe = key3.CFrame
      size = key3.Size
    end

    local rightVector = workspace.CurrentCamera.CFrame.RightVector
    local vector = Vector3.new(rightVector.X, 0, rightVector.Z)
    local unit = vector.Magnitude > 0.001 and vector.Unit or Vector3.xAxis
    local cornerPad = espConfig2.CornerPad
    local v6 = size.Y + cornerPad
    local v7 = math.max(size.X, size.Z, size.Y * 0.5) + cornerPad
    local v8 = math.min(v7, v6) * espConfig2.CornerLen
    local yAxis = Vector3.yAxis
    local position = cframe.Position
    part2.Position = position

    for m = 1, 4 do
      local v9 = v5[m][1]
      local v10 = v5[m][2]
      local v11 = position + unit * (v9 * v7 / 2) + yAxis * (v10 * v6 / 2)
      local v12 = (m - 1) * 3

      v4[v12 + 1].WorldPosition = v11
      v4[v12 + 2].WorldPosition = v11 - unit * (v9 * v8)
      v4[v12 + 3].WorldPosition = v11 - yAxis * (v10 * v8)
    end

    for _, value3 in ipairs(list) do
      local cornerWidth = espConfig2.CornerWidth
      local cornerWidth2 = espConfig2.CornerWidth

      value3.Width0 = cornerWidth
      value3.Width1 = cornerWidth2
    end
  end)

  _G.HajunESP[key3] = {
    root = g,
    text = instance5,
    highlight = highlight,
    bill = billboardGui,
    statusFill = fill,
    beamPart = part,
    beam = instance8,
    attach = instance7,
    attach0 = instance6,
    cornerPart = part2,
    connection = connect,
  }
end

local watchedContainers = {}
local watchConnections = {}

local function watchContainer(key4, instance10, seen)
  if watchedContainers[key4] == instance10 then
    return
  end

  if watchConnections[key4] then
    for _, value4 in ipairs(watchConnections[key4]) do
      value4:Disconnect()
    end
  end

  watchConnections[key4] = {}

  for key5 in pairs(seen) do
    seen[key5] = nil
    _G.removeESP(key5)
  end

  watchedContainers[key4] = instance10

  if not instance10 then
    return
  end

  for _, value5 in ipairs(instance10:GetChildren()) do
    seen[value5] = true
  end

  table.insert(watchConnections[key4], instance10.ChildAdded:Connect(function(child)
    task.wait(0.2)
    seen[child] = true
  end))

  table.insert(watchConnections[key4], instance10.ChildRemoved:Connect(function(child2)
    seen[child2] = nil
    _G.removeESP(child2)
  end))
end

task.spawn(function()
  while true do
    watchContainer("entity", _G.ENTITY_PATH, _G.LiveEntitiesCache)
    watchContainer("interact", _G.INTERACT_PATH, _G.LiveInteractablesCache)
    task.wait(0.5)
  end
end)

task.spawn(function()
  while true do
    task.wait(0.2)

    if not _G.ESP_ENABLED then
      for key6 in pairs(_G.HajunESP) do
        _G.removeESP(key6)
      end
    else
      local character2 = localPlayer.Character
      local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

      if humanoidRootPart2 then
        local list2 = {}
        local hajunTargets = {}
        local maxESPRadius = _G.ESP_Config.Max_ESP_Radius

        for _, value6 in ipairs(players:GetPlayers()) do
          if value6 ~= localPlayer and value6.Character then
            local g2 = _G.getRoot(value6.Character)

            if g2 then
              local magnitude = (humanoidRootPart2.Position - g2.Position).Magnitude

              if magnitude <= maxESPRadius then
                table.insert(list2, { instance = value6.Character, distance = magnitude })
              end
            end
          end
        end

        for key7 in pairs(_G.LiveInteractablesCache) do
          if key7 and key7.Parent then
            local g3 = _G.getRoot(key7)

            if g3 then
              local magnitude2 = (humanoidRootPart2.Position - g3.Position).Magnitude

              if magnitude2 <= maxESPRadius then
                table.insert(list2, { instance = key7, distance = magnitude2 })
              end
            end
          end
        end

        for key8 in pairs(_G.LiveEntitiesCache) do
          if key8 and key8.Parent then
            local g4 = _G.getRoot(key8)

            if g4 then
              local magnitude3 = (humanoidRootPart2.Position - g4.Position).Magnitude

              if magnitude3 <= maxESPRadius then
                table.insert(list2, { instance = key8, distance = magnitude3 })
              end
            end
          end
        end

        for key9 in pairs(_G.LiveFuseCache) do
          if key9 and key9.Parent and _G.getRoot(key9) then
            table.insert(list2, { instance = key9, distance = 0 })
          end
        end

        table.sort(list2, function(p2, p3) return p2.distance < p3.distance end)

        for n = 1, math.min(#list2, _G.ESP_Config.Max_Screen_Count) do
          hajunTargets[list2[n].instance] = true
        end

        for key10 in pairs(_G.HajunESP) do
          if not hajunTargets[key10] then
            _G.removeESP(key10)
          end
        end

        for key11 in pairs(hajunTargets) do
          _G.createESP(key11)
        end

        _G.HajunTargets = hajunTargets
      end
    end
  end
end)

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua"))()
local options = library.Options
local toggles = library.Toggles

library.ShowToggleFrameInKeybinds = true
library.ShowCustomCursor = true
library.NotifySide = "Left"

local running = true
local connections = {}

local function getHumanoidRootPart()
  local character3 = localPlayer.Character
  return character3 and character3:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
  local character4 = localPlayer.Character
  return character4 and character4:FindFirstChildOfClass("Humanoid")
end

local function track(p4, p5)
  connections[#connections + 1] = p4:Connect(p5)
end

local settings = {
  speed = false,
  walk = 16,
  jump = false,
  jumpPower = 50,
  infJump = false,
  bhop = false,
  noclip = false,
  ghost = false,
  fly = false,
  flySpeed = 50,
  spin = false,
  spinSpeed = 5,
  gravity = false,
  gravityVal = 196,
  clickTP = false,
  antiAfk = true,
  freeze = false,
  fullbright = false,
  fov = false,
  fovVal = 70,
  ringName = true,
  ringNameText = "hajunware",
  nameSize = 28,
  fovRing = false,
  ringRadius = 150,
  ringThick = 3,
  ringWobble = 15,
  ringSpin = 2,
  ringRainbow = true,
  spotPlayers = true,
  spotEntities = true,
  spotInteract = true,
  spotRange = 200,
  autoPrompt = {},
  promptMode = "Near",
  promptRange = 12,
  rbTools = false,
  rbHotbar = false,
  rbSpeed = 0.3,
  espItem = {},
  espGrins = false,
  tpSearch = true,
}

local defaults = {
  walk = 16,
  jumpPower = 50,
  useJumpPower = true,
  gravity = workspace.Gravity,
  fov = workspace.CurrentCamera.FieldOfView,
  light = {
    Brightness = lighting.Brightness,
    ClockTime = lighting.ClockTime,
    FogEnd = lighting.FogEnd,
    GlobalShadows = lighting.GlobalShadows,
    Ambient = lighting.Ambient,
  },
}

local function restoreLighting()
  for key12, value7 in pairs(defaults.light) do
    lighting[key12] = value7
  end
end

local anchoredParts = {}

local function unanchorParts()
  for key13 in pairs(anchoredParts) do
    if key13.Parent then
      key13.Anchored = false
    end

    anchoredParts[key13] = nil
  end
end

local originalTransparency = {}

local function restoreTransparency()
  for key14, value8 in pairs(originalTransparency) do
    if key14.Parent then
      key14.Transparency = value8
    end

    originalTransparency[key14] = nil
  end
end

local bodyVelocity, bodyGyro

local function destroyFlyObjects()
  if bodyVelocity then
    bodyVelocity:Destroy()
    bodyVelocity = nil
  end

  if bodyGyro then
    bodyGyro:Destroy()
    bodyGyro = nil
  end

  local humanoid = getHumanoid()

  if humanoid then
    humanoid.PlatformStand = false
  end
end

local function makeBodyVelocity()
  local parent = getHumanoidRootPart()
  local humanoid2 = getHumanoid()

  if not (parent and humanoid2) then
    return false
  end

  destroyFlyObjects()
  humanoid2.PlatformStand = true

  bodyVelocity = Instance.new("BodyVelocity")
  bodyVelocity.MaxForce = Vector3.one * 100000
  bodyVelocity.Velocity = Vector3.zero
  bodyVelocity.Parent = parent

  bodyGyro = Instance.new("BodyGyro")
  bodyGyro.MaxTorque = Vector3.one * 100000
  bodyGyro.P = 10000
  bodyGyro.Parent = parent

  return true
end

track(runService.Heartbeat, function()
  local currentCamera = workspace.CurrentCamera
  local humanoid3 = getHumanoid()
  local humanoidRootPart3 = getHumanoidRootPart()

  if humanoid3 then
    if settings.speed then
      humanoid3.WalkSpeed = settings.walk
    end

    if settings.jump then
      humanoid3.UseJumpPower = true
      humanoid3.JumpPower = settings.jumpPower
    end

    if settings.bhop and humanoidRootPart3 and humanoid3.FloorMaterial ~= Enum.Material.Air
      and humanoid3.MoveDirection.Magnitude > 0 then
      humanoid3:ChangeState(Enum.HumanoidStateType.Jumping)
    end
  end

  if settings.spin and humanoidRootPart3 then
    humanoidRootPart3.CFrame = humanoidRootPart3.CFrame
      * CFrame.Angles(0, math.rad(settings.spinSpeed), 0)
  end

  if settings.gravity then
    workspace.Gravity = settings.gravityVal
  end

  if settings.fullbright then
    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    lighting.Ambient = Color3.new(1, 1, 1)
  end

  if settings.fly and humanoid3 and bodyVelocity and bodyVelocity.Parent then
    local cframe2 = currentCamera.CFrame
    local moveDirection = humanoid3.MoveDirection
    local zero = Vector3.zero

    if moveDirection.Magnitude > 0 then
      local vector2 = Vector3.new(cframe2.LookVector.X, 0, cframe2.LookVector.Z)
      local vector3 = Vector3.new(cframe2.RightVector.X, 0, cframe2.RightVector.Z)
      local unit2 = vector2.Magnitude > 0.001 and vector2.Unit or Vector3.zero
      local unit3 = vector3.Magnitude > 0.001 and vector3.Unit or Vector3.zero

      zero = (cframe2.LookVector * moveDirection:Dot(unit2)
          + cframe2.RightVector * moveDirection:Dot(unit3))
        * settings.flySpeed
    end

    if userInputService:IsKeyDown(Enum.KeyCode.Space) then
      zero = zero + Vector3.yAxis * settings.flySpeed
    end

    if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
      zero = zero - Vector3.yAxis * settings.flySpeed
    end

    bodyVelocity.Velocity = zero
    bodyGyro.CFrame = cframe2
  end
end)

track(runService.Stepped, function()
  if not (settings.noclip or settings.ghost) then
    return
  end

  local character5 = localPlayer.Character

  if not character5 then
    return
  end

  for _, value9 in ipairs(character5:GetDescendants()) do
    if value9:IsA("BasePart") then
      value9.CanCollide = false

      if settings.ghost then
        if originalTransparency[value9] == nil then
          originalTransparency[value9] = value9.Transparency
        end

        if value9.Transparency < 0.6 then
          value9.Transparency = 0.6
        end
      end
    end
  end
end)

track(userInputService.JumpRequest, function()
  if not settings.infJump then
    return
  end

  local humanoid4 = getHumanoid()

  if humanoid4 then
    humanoid4:ChangeState(Enum.HumanoidStateType.Jumping)
  end
end)

track(userInputService.InputBegan, function(p6, p7)
  if p7 or not settings.clickTP or library.Toggled then
    return
  end

  if p6.UserInputType ~= Enum.UserInputType.MouseButton1
    and p6.UserInputType ~= Enum.UserInputType.Touch then
    return
  end

  local humanoidRootPart4 = getHumanoidRootPart()
  local getMouse = localPlayer:GetMouse()

  if humanoidRootPart4 and getMouse.Hit then
    humanoidRootPart4.CFrame = CFrame.new(getMouse.Hit.Position + Vector3.new(0, 3, 0))
  end
end)

track(localPlayer.Idled, function()
  if not settings.antiAfk then
    return
  end

  local currentCamera2 = workspace.CurrentCamera
  virtualUser:Button2Down(Vector2.new(0, 0), currentCamera2.CFrame)
  task.wait(0.1)
  virtualUser:Button2Up(Vector2.new(0, 0), currentCamera2.CFrame)
end)

track(localPlayer.CharacterAdded, function()
  if settings.fly and toggles.FlyToggle then
    pcall(function() toggles.FlyToggle:SetValue(false) end)
  end
end)

task.spawn(function()
  while running do
    task.wait(0.1)

    if settings.freeze then
      for _, value10 in ipairs(players:GetPlayers()) do
        if value10 ~= localPlayer and value10.Character then
          local humanoidRootPart5 = value10.Character:FindFirstChild("HumanoidRootPart")

          if humanoidRootPart5 and not humanoidRootPart5.Anchored then
            humanoidRootPart5.Anchored = true
            anchoredParts[humanoidRootPart5] = true
          end
        end
      end
    elseif next(anchoredParts) then
      unanchorParts()
    end
  end
end)

local savedSlots = {}

local function teleportToSlot(key15)
  local humanoidRootPart6 = getHumanoidRootPart()

  if not humanoidRootPart6 then
    return
  end

  if not savedSlots[key15] then
    library:Notify("No position in slot " .. key15)
    return
  end

  humanoidRootPart6.CFrame = savedSlots[key15]
end

local topBeacon = {
  part = nil,
  atts = {},
  beams = {},
  shown = false,
}

local function hideTopBeacon()
  if not topBeacon.shown then
    return
  end

  for _, value11 in ipairs(topBeacon.beams) do
    value11.Enabled = false
  end

  topBeacon.shown = false
end

local function destroyTopBeacon()
  if topBeacon.part then
    topBeacon.part:Destroy()
  end

  topBeacon.part = nil
  topBeacon.atts = {}
  topBeacon.beams = {}
  topBeacon.shown = false
end

local function makePart()
  local currentCamera3 = workspace.CurrentCamera

  if topBeacon.part and topBeacon.part.Parent == currentCamera3 then
    return
  end

  destroyTopBeacon()

  local part3 = Instance.new("Part")
  part3.Anchored = true
  part3.Transparency = 1
  part3.CanCollide = false
  part3.CanQuery = false
  part3.CanTouch = false
  part3.Size = Vector3.new(0.1, 0.1, 0.1)
  part3.Parent = currentCamera3

  topBeacon.part = part3

  for i6 = 1, 36 do
    topBeacon.atts[i6] = Instance.new("Attachment", part3)
  end

  for i7 = 1, 36 do
    local instance11 = Instance.new("Beam", part3)
    instance11.Attachment0 = topBeacon.atts[i7]
    instance11.Attachment1 = topBeacon.atts[i7 % 36 + 1]

    styleBeam(instance11, 0.01, Color3.new(1, 1, 1), 3)
    topBeacon.beams[i7] = instance11
  end
end

local glyphStrokes = {}

for key16, value12 in pairs({
  A = { "0,0 0,3 1,4 2,3 2,0", "0,2 2,2" },
  B = { "0,0 0,4 1,4 2,3 1,2 0,2", "1,2 2,1 1,0 0,0" },
  C = { "2,3 1,4 0,3 0,1 1,0 2,1" },
  D = { "0,0 0,4 1,4 2,3 2,1 1,0 0,0" },
  E = { "2,4 0,4 0,0 2,0", "0,2 1,2" },
  F = { "2,4 0,4 0,0", "0,2 1,2" },
  G = { "2,3 1,4 0,3 0,1 1,0 2,1 2,2 1,2" },
  H = { "0,0 0,4", "2,0 2,4", "0,2 2,2" },
  I = { "0,4 2,4", "1,4 1,0", "0,0 2,0" },
  J = { "2,4 2,1 1,0 0,1" },
  K = { "0,0 0,4", "2,4 0,2 2,0" },
  L = { "0,4 0,0 2,0" },
  M = { "0,0 0,4 1,2 2,4 2,0" },
  N = { "0,0 0,4 2,0 2,4" },
  O = { "0,1 0,3 1,4 2,3 2,1 1,0 0,1" },
  P = { "0,0 0,4 1,4 2,3 1,2 0,2" },
  Q = { "0,1 0,3 1,4 2,3 2,1 1,0 0,1", "1,1 2,0" },
  R = { "0,0 0,4 1,4 2,3 1,2 0,2", "1,2 2,0" },
  S = { "2,3 1,4 0,3 1,2 2,1 1,0 0,1" },
  T = { "0,4 2,4", "1,4 1,0" },
  U = { "0,4 0,1 1,0 2,1 2,4" },
  V = { "0,4 1,0 2,4" },
  W = { "0,4 0,0 1,2 2,0 2,4" },
  X = { "0,4 2,0", "2,4 0,0" },
  Y = { "0,4 1,2 2,4", "1,2 1,0" },
  Z = { "0,4 2,4 0,0 2,0" },
  ["0"] = { "0,1 0,3 1,4 2,3 2,1 1,0 0,1" },
  ["1"] = { "0,3 1,4 1,0" },
  ["2"] = { "0,3 1,4 2,3 0,0 2,0" },
  ["3"] = { "0,4 2,4 1,2 2,1 1,0 0,1" },
  ["4"] = { "0,4 0,2 2,2", "2,4 2,0" },
  ["5"] = { "2,4 0,4 0,2 1,2 2,1 1,0 0,1" },
  ["6"] = { "2,4 0,2 0,1 1,0 2,1 1,2 0,2" },
  ["7"] = { "0,4 2,4 1,0" },
  ["8"] = { "1,2 0,3 1,4 2,3 1,2 0,1 1,0 2,1 1,2" },
  ["9"] = { "2,2 1,2 0,3 1,4 2,3 2,1 1,0 0,1" },
  ["-"] = { "0,2 2,2" },
  _ = { "0,0 2,0" },
}) do
  local list5 = {}

  for _, value13 in ipairs(value12) do
    local list6 = {}

    for match, v19 in value13:gmatch("(%d+),(%d+)") do
      list6[#list6 + 1] = { tonumber(match), tonumber(v19) }
    end

    for i8 = 1, #list6 - 1 do
      list5[#list5 + 1] = { list6[i8][1], list6[i8][2], list6[i8 + 1][1], list6[i8 + 1][2] }
    end
  end

  glyphStrokes[key16] = list5
end

local ringLabel = { part = nil, segs = {}, shown = 0 }

local function destroyRingLabel()
  if ringLabel.part then
    ringLabel.part:Destroy()
  end

  ringLabel.part = nil
  ringLabel.segs = {}
  ringLabel.shown = 0
end

local function makePart2(p8)
  local currentCamera4 = workspace.CurrentCamera

  if not (ringLabel.part and ringLabel.part.Parent == currentCamera4) then
    destroyRingLabel()

    local part4 = Instance.new("Part")
    part4.Anchored = true
    part4.Transparency = 1
    part4.CanCollide = false
    part4.CanQuery = false
    part4.CanTouch = false
    part4.Size = Vector3.new(0.1, 0.1, 0.1)
    part4.Parent = currentCamera4

    ringLabel.part = part4
  end

  while #ringLabel.segs < p8 do
    local instance12 = Instance.new("Attachment", ringLabel.part)
    local instance13 = Instance.new("Attachment", ringLabel.part)

    local instance14 = Instance.new("Beam", ringLabel.part)
    instance14.Attachment0 = instance12
    instance14.Attachment1 = instance13

    styleBeam(instance14, 0.01, Color3.new(1, 1, 1), 3)
    instance14.Enabled = false
    ringLabel.segs[#ringLabel.segs + 1] = { a0 = instance12, a1 = instance13, beam = instance14 }
  end
end

local function hideRingLabel()
  for i9 = 1, ringLabel.shown do
    ringLabel.segs[i9].beam.Enabled = false
  end

  ringLabel.shown = 0
end

local function drawRingLabel(p9, p10, cframe3, now, p11)
  local sub = tostring(settings.ringNameText or ""):upper():sub(1, 12)
  local nameSize = settings.nameSize
  local v21 = nameSize / 2
  local v22 = v21 * 0.6
  local v23 = -(#sub * v21 + math.max(#sub - 1, 0) * v22) / 2
  local list7 = {}

  for i10 = 1, #sub do
    local list8 = glyphStrokes[sub:sub(i10, i10)]

    if list8 then
      local v24 = v23 + (i10 - 1) * (v21 + v22)

      for _, value14 in ipairs(list8) do
        list7[#list7 + 1] = {
          v24 + value14[1] / 2 * v21, (value14[2] / 4 - 0.5) * nameSize,
          v24 + value14[3] / 2 * v21, (value14[4] / 4 - 0.5) * nameSize,
        }
      end
    end
  end

  local v25 = #list7
  makePart2(v25)
  local v26 = math.max(settings.ringThick * 0.6, 1) * p9

  for i11 = 1, v25 do
    local v27 = list7[i11]
    local vector32 = Vector3
    local v28 = ringLabel.segs[i11]

    local pointToWorldSpace = cframe3:PointToWorldSpace(vector32.new(
      v27[1] * p9, v27[2] * p9, -p10
    ))

    local pointToWorldSpace2 = cframe3:PointToWorldSpace(Vector3.new(
      v27[3] * p9, v27[4] * p9, -p10
    ))

    local a0 = v28.a0
    local a1 = v28.a1
    a0.WorldPosition = pointToWorldSpace
    a1.WorldPosition = pointToWorldSpace2

    local beam = v28.beam
    beam.Enabled = true
    beam.Width0 = v26
    beam.Width1 = v26
    beam.TextureLength = math.max((pointToWorldSpace - pointToWorldSpace2).Magnitude, 0.0001)

    if settings.ringRainbow then
      local v29 = (now * 0.15 + (i11 - 1) / v25) % 1

      beam.Color = ColorSequence.new(
        Color3.fromHSV(v29, 0.9, 1), Color3.fromHSV((v29 + 1 / v25) % 1, 0.9, 1)
      )
    else
      beam.Color = ColorSequence.new(p11)
    end
  end

  for i12 = v25 + 1, ringLabel.shown do
    ringLabel.segs[i12].beam.Enabled = false
  end

  ringLabel.shown = v25
end

runService:BindToRenderStep("hajunware_ring", Enum.RenderPriority.Camera.Value + 1, function()
  if not settings.fovRing then
    hideRingLabel()
    return hideTopBeacon()
  end

  local currentCamera5 = workspace.CurrentCamera
  makePart()
  topBeacon.shown = true

  local v30 = 6 * math.tan(math.rad(currentCamera5.FieldOfView) / 2)
    / currentCamera5.ViewportSize.Y

  local now2 = os.clock()
  local v31 = settings.ringRadius * v30 * (1 + 0.03 * math.sin(now2 * 2))
  local v32 = settings.ringThick * v30
  local highest = math.max(2 * math.pi * v31 / 36, 0.0001)
  local cframe4 = currentCamera5.CFrame
  local value15 = options.RingColor and options.RingColor.Value or Color3.fromRGB(0, 255, 150)

  if settings.ringName then
    drawRingLabel(v30, 3, cframe4, now2, value15)
  else
    hideRingLabel()
  end

  for i13 = 1, 36 do
    local v33 = (i13 - 1) / 36 * 2 * math.pi + now2 * settings.ringSpin * 0.5
    local v34 = v31 * (1 + settings.ringWobble / 100 * math.sin(v33 * 5 + now2 * 3))

    topBeacon.atts[i13].WorldPosition = (cframe4 * CFrame.new(
      math.cos(v33) * v34, math.sin(v33) * v34, -3
    )).Position

    local v35 = topBeacon.beams[i13]
    v35.Enabled = true
    v35.Width0 = v32
    v35.Width1 = v32
    v35.TextureLength = highest

    if settings.ringRainbow then
      local v36 = (now2 * 0.15 + (i13 - 1) / 36) % 1

      v35.Color = ColorSequence.new(
        Color3.fromHSV(v36, 0.9, 1), Color3.fromHSV((v36 + 0.027777777777777776) % 1, 0.9, 1)
      )
    else
      v35.Color = ColorSequence.new(value15)
    end
  end
end)

runService:BindToRenderStep("hajunware_fov", Enum.RenderPriority.Camera.Value + 2, function()
  if settings.fov then
    workspace.CurrentCamera.FieldOfView = settings.fovVal
  end
end)

local guiParent = gethui and gethui() or playerGui

_G.AI_Config = {
  Notifs = true,
  Stream = true,
  EntityRange = 35,
  InteractRange = 15,
}

local color2 = Color3.fromRGB(0, 210, 255)
local color3 = Color3.fromRGB(255, 0, 80)
local color4 = Color3.fromRGB(170, 0, 255)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ai_" .. httpService:GenerateGUID(false):sub(1, 6)
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local function makeTextLabel(frame, map2)
  local textLabel = Instance.new("TextLabel")
  textLabel.BackgroundTransparency = 1
  textLabel.Font = Enum.Font.Code
  textLabel.TextXAlignment = Enum.TextXAlignment.Left

  for key17, value16 in pairs(map2) do
    textLabel[key17] = value16
  end

  textLabel.Parent = frame
  return textLabel
end

local frame2 = Instance.new("Frame")
frame2.Size = UDim2.fromOffset(240, 0)
frame2.AutomaticSize = Enum.AutomaticSize.Y
frame2.BackgroundTransparency = 1
frame2.Parent = screenGui

local instance15 = Instance.new("UIListLayout", frame2)
instance15.Padding = UDim.new(0, 6)
instance15.SortOrder = Enum.SortOrder.LayoutOrder

local frame3 = Instance.new("Frame")
frame3.Size = UDim2.fromOffset(240, 84)
frame3.LayoutOrder = 1
frame3.BackgroundColor3 = Color3.fromRGB(14, 18, 26)
frame3.BackgroundTransparency = 0.25
frame3.BorderSizePixel = 0
frame3.Parent = frame2

Instance.new("UICorner", frame3).CornerRadius = UDim.new(0, 6)

local instance16 = Instance.new("UIStroke", frame3)
instance16.Color = color2
instance16.Thickness = 1

makeTextLabel(frame3, {
  Size = UDim2.new(1, -10, 0, 16),
  Position = UDim2.fromOffset(6, 3),
  TextSize = 9,
  TextColor3 = color2,
  Text = "▣ AI TERMINAL STREAM",
})

local textLabel2 = makeTextLabel(frame3, {
  Size = UDim2.new(1, -12, 1, -22),
  Position = UDim2.fromOffset(6, 20),
  TextSize = 10,
  TextColor3 = Color3.fromRGB(200, 215, 230),
  TextWrapped = true,
  TextYAlignment = Enum.TextYAlignment.Top,
  Text = "> Initializing neural subsystems...",
})

local frame4 = Instance.new("Frame")
frame4.Size = UDim2.fromOffset(240, 0)
frame4.AutomaticSize = Enum.AutomaticSize.Y
frame4.LayoutOrder = 2
frame4.BackgroundTransparency = 1
frame4.Parent = frame2

local instance17 = Instance.new("UIListLayout", frame4)
instance17.Padding = UDim.new(0, 6)
instance17.SortOrder = Enum.SortOrder.LayoutOrder

local vector4 = Vector2.new(1, 0)
local udim = UDim2.new(1, -12, 0, 10)
local right = Enum.HorizontalAlignment.Right

local notifAnchors = {
  ["Top Right"] = { vector4, udim, right },
  ["Top Left"] = { Vector2.new(0, 0), UDim2.new(0, 12, 0, 60), Enum.HorizontalAlignment.Left },
  ["Top Center"] = {
    Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 10), Enum.HorizontalAlignment.Center,
  },
}

local function setNotifPosition(key18)
  local topRight = notifAnchors[key18] or notifAnchors["Top Right"]
  local position2 = topRight[2]

  frame2.AnchorPoint = topRight[1]
  frame2.Position = position2

  instance15.HorizontalAlignment = topRight[3]
  instance17.HorizontalAlignment = topRight[3]
end

setNotifPosition("Top Right")

local activeNotifs = {}

local function makeFrame(text, text2, p12, p13, color5)
  if not _G.AI_Config.Notifs then
    return
  end

  local v39 = color5 or p13 and color3 or color2

  local frame5 = Instance.new("Frame")
  frame5.Size = UDim2.fromOffset(230, 0)
  frame5.BackgroundColor3 = Color3.fromRGB(3, 5, 7)
  frame5.BackgroundTransparency = 0.15
  frame5.BorderSizePixel = 0
  frame5.ClipsDescendants = true
  frame5.Parent = frame4

  local instance18 = Instance.new("UIStroke", frame5)
  instance18.Color = v39
  instance18.Thickness = 1

  makeTextLabel(frame5, {
    Size = UDim2.new(1, -16, 0, 14),
    Position = UDim2.fromOffset(8, 4),
    TextSize = 9,
    TextColor3 = v39,
    Text = "[SYS]: " .. text:upper(),
  })

  makeTextLabel(frame5, {
    Size = UDim2.new(1, -16, 0, 38),
    Position = UDim2.fromOffset(8, 18),
    TextSize = 9,
    TextColor3 = Color3.fromRGB(190, 205, 220),
    TextWrapped = true,
    TextYAlignment = Enum.TextYAlignment.Top,
    Text = "> " .. text2,
  })

  local instance19 = Instance.new("Frame", frame5)
  instance19.Size = UDim2.new(1, -16, 0, 1)
  instance19.Position = UDim2.new(0, 8, 1, -4)
  instance19.BackgroundColor3 = Color3.fromRGB(15, 22, 30)
  instance19.BorderSizePixel = 0

  local instance20 = Instance.new("Frame", instance19)
  instance20.Size = UDim2.fromScale(1, 1)
  instance20.BackgroundColor3 = v39
  instance20.BorderSizePixel = 0

  tweenService:Create(frame5, TweenInfo.new(0.25), { Size = UDim2.fromOffset(230, 62) }):Play()

  tweenService:Create(instance20, TweenInfo.new(p12, Enum.EasingStyle.Linear), {
    Size = UDim2.fromScale(0, 1),
  }):Play()

  local list10 = {}

  for _, value17 in ipairs(activeNotifs) do
    if value17.Parent then
      list10[#list10 + 1] = value17
    end
  end

  list10[#list10 + 1] = frame5

  while #list10 > 4 do
    table.remove(list10, 1):Destroy()
  end

  activeNotifs = list10

  task.delay(p12, function()
    if not frame5.Parent then
      return
    end

    tweenService:Create(frame5, TweenInfo.new(0.15), {
      Size = UDim2.fromOffset(230, 0),
      BackgroundTransparency = 1,
    }):Play()

    task.wait(0.15)
    frame5:Destroy()
  end)
end

local function destroyNotifGui()
  screenGui:Destroy()
end

local entityNotifCooldown = setmetatable({}, { __mode = "k" })
local interactNotifCooldown = setmetatable({}, { __mode = "k" })

task.spawn(function()
  task.wait(0.2)
  makeFrame("system online", "hajunware initialized. AI stream active.", 4.5, false)

  while running do
    task.wait(0.2)
    local humanoidRootPart7 = getHumanoidRootPart()

    if humanoidRootPart7 then
      local aiConfig = _G.AI_Config
      local v42
      local v43
      local huge = math.huge
      local huge2 = math.huge

      for key19 in pairs(_G.LiveEntitiesCache) do
        if key19 and key19.Parent then
          local g5 = _G.getRoot(key19)

          if g5 then
            local magnitude4 = (humanoidRootPart7.Position - g5.Position).Magnitude

            if magnitude4 < huge then
              huge = magnitude4
              v43 = key19
            end

            if magnitude4 <= aiConfig.EntityRange
              and (not entityNotifCooldown[key19] or os.clock() - entityNotifCooldown[key19] > 6) then
              entityNotifCooldown[key19] = os.clock()

              makeFrame("threat velocity", string.format(
                "%s closing in! [%dm]", key19.Name:upper(), math.floor(magnitude4)
              ), 4, true)
            end
          end
        end
      end

      for key20 in pairs(_G.LiveInteractablesCache) do
        if key20 and key20.Parent then
          local g6 = _G.getRoot(key20)

          if g6 then
            local magnitude5 = (humanoidRootPart7.Position - g6.Position).Magnitude

            if magnitude5 < huge2 then
              huge2 = magnitude5
              v42 = key20
            end

            if magnitude5 <= aiConfig.InteractRange
              and (not interactNotifCooldown[key20] or os.clock() - interactNotifCooldown[key20] > 10) then
              interactNotifCooldown[key20] = os.clock()

              makeFrame(
                "proximity alert",
                string.format("%s nearby [%dm]", key20.Name, math.floor(magnitude5)), 3.5, false
              )
            end
          end
        end
      end

      frame3.Visible = aiConfig.Stream

      if aiConfig.Stream then
        if not (_G.ENTITY_PATH or _G.INTERACT_PATH) then
          instance16.Color = color2
          textLabel2.TextColor3 = Color3.fromRGB(200, 215, 230)
          textLabel2.Text = "> Awaiting ENTITY_PATH / INTERACT_PATH. Set them to enable alerts."
        elseif v43 and huge <= aiConfig.EntityRange then
          instance16.Color = color3
          textLabel2.TextColor3 = Color3.fromRGB(255, 120, 150)

          textLabel2.Text = string.format(
            "> WARNING: %s approaching at [%dm]! Evade immediately.", v43.Name:upper(),
            math.floor(huge)
          )
        elseif v42 and huge2 <= aiConfig.InteractRange then
          instance16.Color = color4
          textLabel2.TextColor3 = Color3.fromRGB(210, 150, 255)

          textLabel2.Text = string.format(
            "> TARGET ACQUIRED: %s right beside you [%dm]. Grab it!", v42.Name,
            math.floor(huge2)
          )
        else
          instance16.Color = color2
          textLabel2.TextColor3 = Color3.fromRGB(200, 215, 230)

          textLabel2.Text = v42 and string.format(
            "> All systems normal. Scanning sectors... nearest target: %dm", math.floor(huge2)
          ) or "> All systems normal. Scanning sectors..."
        end
      end
    end
  end
end)

local color6 = Color3.fromRGB(0, 255, 150)
local spottedTargets = setmetatable({}, { __mode = "k" })
local spotCooldown = setmetatable({}, { __mode = "k" })

local function spotTarget(key21, g7, p14, text3, position3, currentCamera6, p15)
  local worldToViewportPoint = currentCamera6:WorldToViewportPoint(g7.Position)
  local magnitude6 = (position3 - g7.Position).Magnitude

  if not (worldToViewportPoint.Z > 0
    and magnitude6 <= settings.spotRange
    and (Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - p15).Magnitude
      <= settings.ringRadius) then
    spottedTargets[key21] = nil
    return
  end

-- https://leakd.fr
  if spottedTargets[key21] then
    return
  end

  spottedTargets[key21] = true

  if spotCooldown[key21] and os.clock() - spotCooldown[key21] < 3 then
    return
  end

  spotCooldown[key21] = os.clock()
  local rounded = math.floor(magnitude6)

  if p14 == "player" then
    makeFrame(
      "player spotted", string.format("%s in FOV [%dm]", text3, rounded), 3, false, color6
    )
  elseif p14 == "entity" then
    makeFrame(
      "entity spotted", string.format("%s in FOV [%dm]", text3:upper(), rounded), 4, true
    )
  else
    makeFrame(
      "target spotted", string.format("%s in FOV [%dm]", text3, rounded), 3, false, color4
    )
  end
end

task.spawn(function()
  while running do
    task.wait(0.1)

    if not settings.fovRing then
      for key22 in pairs(spottedTargets) do
        spottedTargets[key22] = nil
      end
    else
      local humanoidRootPart8 = getHumanoidRootPart()

      if humanoidRootPart8 then
        local currentCamera7 = workspace.CurrentCamera
        local v45 = currentCamera7.ViewportSize / 2
        local position4 = humanoidRootPart8.Position

        if settings.spotPlayers then
          for _, value18 in ipairs(players:GetPlayers()) do
            local character6 = value18 ~= localPlayer and value18.Character

            local humanoid5 = character6
            humanoid5 = character6 and character6:FindFirstChildOfClass("Humanoid")

            local g8 = character6
            g8 = character6 and _G.getRoot(character6)

            if g8 and humanoid5 and humanoid5.Health > 0 then
              spotTarget(value18, g8, "player", value18.DisplayName, position4, currentCamera7, v45)
            end
          end
        end

        if settings.spotEntities then
          for key23 in pairs(_G.LiveEntitiesCache) do
            if key23 and key23.Parent then
              local g9 = _G.getRoot(key23)

              if g9 then
                spotTarget(key23, g9, "entity", key23.Name, position4, currentCamera7, v45)
              end
            end
          end
        end

        if settings.spotInteract then
          for key24 in pairs(_G.LiveInteractablesCache) do
            if key24 and key24.Parent then
              local g10 = _G.getRoot(key24)

              if g10 then
                spotTarget(key24, g10, "interact", key24.Name, position4, currentCamera7, v45)
              end
            end
          end
        end
      end
    end
  end
end)

local knownPrompts = {
  {
    id = "Grapple",
    text = "Auto grab grapple",
    path = "Chapter1.Tutorial.GrapplePickup.Case.PromptPoint.ProximityPrompt",
  },
  {
    id = "Lockdown",
    text = "Auto lockdown",
    path = "Chapter1.Annex.Control.Console.PromptPoint",
  },
  {
    id = "LiftBrake",
    text = "Auto lift brake",
    path = "Chapter1.Annex.Machine.Brake.PromptPoint",
  },
  {
    id = "LiftDown",
    text = "Auto go down (lift)",
    path = "Chapter1.Lift.Car.Button.EnterPrompt.ProximityPrompt",
  },
  {
    id = "VentKick",
    text = "Auto kick (vent)",
    path = "Chapter1.Lift.Vent.KickPrompt.KickPoint.ProximityPrompt",
  },
  {
    id = "Fuse",
    text = "Auto take fuse",
    path = "Chapter1.Maintenance.FuseBoxes.FuseBoxWorkshop.Back.PromptPoint.ProximityPrompt",
  },
  { id = "Powerbox", text = "Auto insert (powerbox)", path = nil },
}

for _, value19 in ipairs(knownPrompts) do
  settings.autoPrompt[value19.id] = false
  value19.last = 0
end

local function getPromptPosition(instance21)
  local parent2 = instance21.Parent

  if parent2:IsA("Attachment") then
    return parent2.WorldPosition
  end

  if parent2:IsA("BasePart") then
    return parent2.Position
  end

  local g11 = _G.getRoot(parent2)
  return g11 and g11.Position
end

local function findPromptByPath(path)
  if not path then
    return nil
  end

  local v46 = workspace

  for match2 in path:gmatch("[^%.]+") do
    v46 = v46 and v46:FindFirstChild(match2)
  end

  if not v46 then
    return nil
  end

  if v46:IsA("ProximityPrompt") then
    return v46
  end

  return v46:FindFirstChildWhichIsA("ProximityPrompt", true)
end

local grappleNotified = false

task.spawn(function()
  while running do
    task.wait(0.25)
    local humanoidRootPart9 = getHumanoidRootPart()

    if humanoidRootPart9 then
      for _, value20 in ipairs(knownPrompts) do
        if settings.autoPrompt[value20.id] then
          if not fireproximityprompt then
            if not grappleNotified then
              grappleNotified = true
              library:Notify("executor has no fireproximityprompt")
            end
          elseif not value20.path then
            if not value20.warned then
              value20.warned = true
              library:Notify(value20.text .. ": path not set")
            end
          else
            local v47 = findPromptByPath(value20.path)

            if v47 and v47.Enabled then
              local v48 = getPromptPosition(v47)

              if v48 then
                local magnitude7 = (humanoidRootPart9.Position - v48).Magnitude
                local v49 = settings.promptMode == "Anywhere"

                if not (not v49 and magnitude7 > settings.promptRange) then
                  if not (os.clock() - value20.last < 1.5) then
                    if v49 then
                      v47.MaxActivationDistance = 100000
                      v47.RequiresLineOfSight = false
                    end

                    v47.HoldDuration = 0
                    value20.last = os.clock()
                    fireproximityprompt(v47)
                    library:Notify(value20.text .. " fired [" .. math.floor(magnitude7) .. "m]")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end)

local color7 = Color3.fromRGB(60, 140, 255)

local promptTypes = {
  {
    id = "Fuse",
    text = "Fuse",
    match = "fuse",
    color = color7,
  },
  {
    id = "Bandage",
    text = "Bandage",
    match = "bandage",
    color = color7,
  },
  {
    id = "Stamina",
    text = "Stamina drink",
    match = "stamina",
    color = color7,
  },
  {
    id = "Crowbar",
    text = "Crowbar",
    match = "crowbar",
    color = color7,
  },
  {
    id = "Search",
    text = "Search spots (cabinets)",
    match = nil,
    color = color7,
  },
  {
    id = "Other",
    text = "Other pickups",
    match = nil,
    color = color7,
  },
}

local searchPromptType

for _, value21 in ipairs(promptTypes) do
  if value21.id == "Search" then
    searchPromptType = value21
  end
end

for _, value22 in ipairs(promptTypes) do
  settings.espItem[value22.id] = false
end

local function matchPromptType(text4)
  local lower = text4:lower()

  for _, value23 in ipairs(promptTypes) do
    if value23.match and lower:find(value23.match, 1, true) then
      return value23
    end
  end

  return promptTypes[#promptTypes]
end

local livePrompts = {}

local function onDescendantAdded(key25)
  if key25:IsA("ProximityPrompt") then
    livePrompts[key25] = true
  end
end

track(workspace.DescendantAdded, onDescendantAdded)
track(workspace.DescendantRemoving, function(key26) livePrompts[key26] = nil end)

task.spawn(function()
  local count = 0

  for _, value24 in ipairs(workspace:GetDescendants()) do
    onDescendantAdded(value24)
    count = count + 1

    if count % 2000 == 0 then
      task.wait()
    end
  end
end)

local function getPromptOwner(instance22)
  local parent3 = instance22.Parent

  while parent3 and parent3 ~= workspace
    and not (parent3:IsA("BasePart") or parent3:IsA("Model")) do
    parent3 = parent3.Parent
  end

  return parent3 and parent3 ~= workspace and parent3 or nil
end

task.spawn(function()
  while running do
    task.wait(0.5)
    local map3 = {}
    local flag3 = false

    for _, value25 in pairs(settings.espItem) do
      if value25 then
        flag3 = true
        break
      end
    end

    if flag3 then
      local seen5 = {}

      for _, value26 in ipairs(knownPrompts) do
        if value26.id ~= "Fuse" then
          local v51 = findPromptByPath(value26.path)

          if v51 then
            seen5[v51] = true
          end
        end
      end

      local function setPromptAutoFire(p16, enabled, p17)
        if map3[enabled] then
          return
        end

        local v52 = p17 or matchPromptType(p16.ObjectText .. " " .. enabled.Name)

        if settings.espItem[v52.id] then
          map3[enabled] = {
            label = p16.ObjectText ~= "" and p16.ObjectText or enabled.Name,
            color = v52.color,
          }
        end
      end

      for key27 in pairs(livePrompts) do
        if key27.Parent and key27.Enabled and not seen5[key27] then
          local lower2 = key27.ActionText:match("^%s*(.-)%s*$"):lower()

          if lower2 == "take" or lower2 == "search" then
            local v53 = getPromptOwner(key27)

            if v53 then
              setPromptAutoFire(key27, v53, lower2 == "search" and searchPromptType or nil)
            end
          end
        end
      end

      for _, value27 in ipairs(knownPrompts) do
        if value27.id == "Fuse" then
          local v54 = findPromptByPath(value27.path)

          local enabled2 = v54
          enabled2 = v54 and v54.Enabled and getPromptOwner(v54)

          if enabled2 then
            setPromptAutoFire(v54, enabled2, promptTypes[1])
          end
        end
      end
    end

    if settings.espGrins then
      local v55 = workspace

      for match3 in ("GrinsworthBody.Grinsworth"):gmatch("[^%.]+") do
        v55 = v55 and v55:FindFirstChild(match3)
      end

      if v55 and _G.getRoot(v55) then
        map3[v55] = { label = "Grinsworth", color = _G.ESP_Config.Colors.DefaultEntity }
      end
    end

    for key28 in pairs(_G.LiveFuseCache) do
      if not map3[key28] then
        _G.LiveFuseCache[key28] = nil
      end
    end

    for key29, value28 in pairs(map3) do
      _G.LiveFuseCache[key29] = value28
    end
  end
end)

local fuseRunning = false

local function collectKnownPrompts()
  local seen6 = {}

  for _, value29 in ipairs(knownPrompts) do
    if value29.id ~= "Fuse" then
      local v56 = findPromptByPath(value29.path)

      if v56 then
        seen6[v56] = true
      end
    end
  end

  return seen6
end

local function collectExtraPrompts(p18)
  local v57 = collectKnownPrompts()
  local list13 = {}
  local seen7 = {}

  local function addPromptCandidate(key30)
    if seen7[key30] or p18[key30] then
      return
    end

    seen7[key30] = true
    list13[#list13 + 1] = key30
  end

  for key31 in pairs(livePrompts) do
    if key31.Parent and key31.Enabled and not v57[key31] then
      local lower3 = key31.ActionText:match("^%s*(.-)%s*$"):lower()

      if lower3 == "take" or lower3 == "search" then
        local v58 = getPromptOwner(key31)

        if v58 then
          if lower3 == "search" then
            if settings.tpSearch then
              addPromptCandidate(key31)
            end
          elseif matchPromptType(key31.ObjectText .. " " .. v58.Name) == promptTypes[1] then
            addPromptCandidate(key31)
          end
        end
      end
    end
  end

  for _, value30 in ipairs(knownPrompts) do
    if value30.id == "Fuse" then
      local v59 = findPromptByPath(value30.path)

      if v59 and v59.Enabled then
        addPromptCandidate(v59)
      end
    end
  end

  return list13
end

local function teleportFuses()
  if fuseRunning then
    library:Notify("TP fuse already running")
    return
  end

  if not fireproximityprompt then
    library:Notify("executor has no fireproximityprompt")
    return
  end

  local humanoidRootPart10 = getHumanoidRootPart()

  if not humanoidRootPart10 then
    return
  end

  fuseRunning = true
  local cframe5 = humanoidRootPart10.CFrame
  local flag5 = false
  local count2 = 0
  local count3 = 0
  local seen8 = {}

  for i14 = 1, 8 do
    local list14 = {}

    for _, value31 in ipairs(collectExtraPrompts(seen8)) do
      local v60 = getPromptPosition(value31)

      if v60 then
        list14[#list14 + 1] = {
          pp = value31,
          pos = v60,
          d = (v60 - cframe5.Position).Magnitude,
        }
      end
    end

    if #list14 == 0 then
      break
    end

    table.sort(list14, function(p19, p20) return p19.d < p20.d end)

    for _, value32 in ipairs(list14) do
      if not running or not getHumanoidRootPart() then
        flag5 = true
        break
      end

      local pp = value32.pp

      for i15 = 1, pp.ActionText:lower():find("search", 1, true) and 2 or 3 do
        local humanoidRootPart11 = getHumanoidRootPart()

        if not humanoidRootPart11 or not (pp.Parent and pp.Enabled) then
          break
        end

        humanoidRootPart11.AssemblyLinearVelocity = Vector3.zero
        humanoidRootPart11.CFrame = CFrame.new(value32.pos + Vector3.new(0, 3, 0))

        task.wait(0.25)

        pp.HoldDuration = 0
        pp.RequiresLineOfSight = false

        fireproximityprompt(pp)
        task.wait(0.35)
      end

      seen8[pp] = true
      count3 = count3 + 1

      if not (pp.Parent and pp.Enabled) then
        count2 = count2 + 1
      end

      local humanoidRootPart12 = getHumanoidRootPart()

      if humanoidRootPart12 then
        humanoidRootPart12.AssemblyLinearVelocity = Vector3.zero
        humanoidRootPart12.CFrame = cframe5
      end

      task.wait(0.4)
    end

    if flag5 then
      break
    end
  end

  fuseRunning = false

  if count3 == 0 then
    library:Notify("TP fuse: nothing found")
  else
    library:Notify(string.format("TP fuse done: %d/%d interacted", count2, count3))
  end
end

local positionHistoryBuffer = {}

task.spawn(function()
  while running do
    task.wait(0.25)
    local humanoidRootPart13 = getHumanoidRootPart()
    local humanoid6 = getHumanoid()

    if humanoidRootPart13 and humanoid6 and humanoid6.Health > 0 then
      positionHistoryBuffer[#positionHistoryBuffer + 1] = humanoidRootPart13.CFrame

      if #positionHistoryBuffer > 12 then
        table.remove(positionHistoryBuffer, 1)
      end
    end
  end
end)

local deathSpot

local function saveDeathSpot()
  if #positionHistoryBuffer > 0 then
    deathSpot = positionHistoryBuffer[math.max(1, #positionHistoryBuffer - 6)]
    library:Notify("Death spot saved")
  end
end

track(localPlayer:GetAttributeChangedSignal("DeathCause"), saveDeathSpot)
local startLives = localPlayer:GetAttribute("Lives")

track(localPlayer:GetAttributeChangedSignal("Lives"), function()
  local lives2 = localPlayer:GetAttribute("Lives")

  if type(lives2) == "number" and type(startLives) == "number" and lives2 < startLives then
    saveDeathSpot()
  end

  startLives = lives2
end)

local originalColors = setmetatable({}, { __mode = "k" })
local originalImageColors = setmetatable({}, { __mode = "k" })
local toolParts = {}

local function restoreHighlightColors()
  for key32, value33 in pairs(originalColors) do
    if key32.Parent then
      key32.Color = value33
    end

    originalColors[key32] = nil
  end
end

local hotbarImages = {}

local function restoreImageColors()
  for key33, value34 in pairs(originalImageColors) do
    if key33.Parent then
      key33.ImageColor3 = value34
    end

    originalImageColors[key33] = nil
  end
end

local function applyRainbowTools()
  if settings.rbTools then
    local function collectToolParts(instance23)
      for _, value35 in ipairs(instance23:GetDescendants()) do
        if value35:IsA("BasePart") then
          toolParts[#toolParts + 1] = value35
        end
      end
    end

    toolParts = {}
    local character7 = localPlayer.Character

    if character7 then
      for _, value36 in ipairs(character7:GetChildren()) do
        if value36:IsA("Tool") then
          collectToolParts(value36)
        end
      end
    end

    local backpack = localPlayer:FindFirstChildOfClass("Backpack")

    if backpack then
      for _, value37 in ipairs(backpack:GetChildren()) do
        if value37:IsA("Tool") then
          collectToolParts(value37)
        end
      end
    end
  end

  local seen9

  if settings.rbHotbar then
    hotbarImages = {}
    seen9 = {}

    local function collectHotbarImages(key34)
      if (key34:IsA("ImageLabel") or key34:IsA("ImageButton")) and not seen9[key34] then
        seen9[key34] = true
        hotbarImages[#hotbarImages + 1] = key34
      end
    end

    for _, value38 in ipairs(playerGui:GetDescendants()) do
      if value38:IsA("GuiObject") and not value38:IsDescendantOf(screenGui) then
        local lower4 = value38.Name:lower()

        if lower4:find("hotbar", 1, true) or lower4:find("backpack", 1, true)
          or lower4:find("inventory", 1, true) or lower4:find("toolbar", 1, true) then
          collectHotbarImages(value38)

          for _, value39 in ipairs(value38:GetDescendants()) do
            collectHotbarImages(value39)
          end
        end
      end
    end
  end
end

local lastRainbowTick = 0

track(runService.RenderStepped, function()
  if not (settings.rbTools or settings.rbHotbar) then
    return
  end

  local now3 = os.clock()

  if now3 - lastRainbowTick > 1 then
    lastRainbowTick = now3
    applyRainbowTools()
  end

  local v62 = now3 * settings.rbSpeed % 1

  if settings.rbTools then
    for index, value40 in ipairs(toolParts) do
      if value40.Parent then
        if originalColors[value40] == nil then
          originalColors[value40] = value40.Color
        end

        value40.Color = Color3.fromHSV((v62 + index * 0.07) % 1, 0.9, 1)
      end
    end
  end

  if settings.rbHotbar then
    for index2, value41 in ipairs(hotbarImages) do
      if value41.Parent then
        if originalImageColors[value41] == nil then
          originalImageColors[value41] = value41.ImageColor3
        end

        value41.ImageColor3 = Color3.fromHSV((v62 + index2 * 0.1) % 1, 0.8, 1)
      end
    end
  end
end)

local scieorHajunwareWindow = library:CreateWindow({
  Title = "scieor hajunware",
  Center = true,
  AutoShow = true,
  Resizable = true,
  ShowCustomCursor = true,
  UnlockMouseWhileOpen = true,
  NotifySide = "Left",
  TabPadding = 8,
  MenuFadeTime = 0.2,
})

local tabs = {
  Main = scieorHajunwareWindow:AddTab("Main"),
  ESP = scieorHajunwareWindow:AddTab("ESP"),
  Player = scieorHajunwareWindow:AddTab("Player"),
  Visuals = scieorHajunwareWindow:AddTab("Visuals"),
  Config = scieorHajunwareWindow:AddTab("Config"),
}

local autoPrompts = tabs.Main:AddLeftGroupbox("Auto prompts")

for _, value42 in ipairs(knownPrompts) do
  autoPrompts:AddToggle("Auto" .. value42.id, {
    Text = value42.text,
    Default = false,
    Callback = function(value43) settings.autoPrompt[value42.id] = value43 end,
  })
end

autoPrompts:AddDivider()

autoPrompts:AddDropdown("PromptMode", {
  Values = { "Near", "Anywhere" },
  Default = 1,
  Multi = false,
  Text = "Trigger",
  Callback = function(value44) settings.promptMode = value44 end,
})

autoPrompts:AddSlider("PromptRange", {
  Text = "Near range",
  Default = 12,
  Min = 3,
  Max = 50,
  Rounding = 0,
  Suffix = "st",
  Callback = function(value45) settings.promptRange = value45 end,
})

local teleports = tabs.Main:AddRightGroupbox("Teleports")
teleports:AddLabel("Vent exit: go in the vent for a little, then TP (crouch)", true)

teleports:AddButton("Vent exit", function()
  local humanoidRootPart14 = getHumanoidRootPart()

  if not humanoidRootPart14 then
    return
  end

  humanoidRootPart14.AssemblyLinearVelocity = Vector3.zero
  humanoidRootPart14.CFrame = CFrame.new(0.5, -511.5, -64.3)
end)

teleports:AddLabel("TP fuse: you get coins soon after it runs", true)

teleports:AddToggle("TPSearch", {
  Text = "TP fuse: include search spots",
  Default = true,
  Callback = function(value46) settings.tpSearch = value46 end,
})

teleports:AddButton("TP fuse", function()
  task.spawn(function()
    local ok, result = pcall(teleportFuses)

    if not ok then
      fuseRunning = false
      library:Notify("TP fuse error, check console")
      warn(result)
    end
  end)
end)

local vector5 = Vector3.new(1.63, -467.034, 139.143)

teleports:AddDivider()
teleports:AddLabel("To the top: use when you get all fuses", true)

teleports:AddButton("To the top", function()
  local humanoidRootPart15 = getHumanoidRootPart()

  if not humanoidRootPart15 then
    return
  end

  if not vector5 then
    library:Notify("To the top: coords not set")
    return
  end

  humanoidRootPart15.AssemblyLinearVelocity = Vector3.zero
  humanoidRootPart15.CFrame = CFrame.new(vector5)
end)

local topCoords = CFrame.new(
  377.155945, -303.287262, 987.411804, -0.613872409, 0, -0.789405227, 0, 1, 0, 0.789405227, 0,
  -0.613872409
)

teleports:AddButton("To the end", function()
  local humanoidRootPart16 = getHumanoidRootPart()

  if not humanoidRootPart16 then
    return
  end

  humanoidRootPart16.AssemblyLinearVelocity = Vector3.zero
  humanoidRootPart16.CFrame = topCoords
end)

teleports:AddButton("To death spot", function()
  local humanoidRootPart17 = getHumanoidRootPart()

  if not humanoidRootPart17 then
    library:Notify("No body")
    return
  end

  if not deathSpot then
    library:Notify("No death spot saved yet")
    return
  end

  humanoidRootPart17.AssemblyLinearVelocity = Vector3.zero
  humanoidRootPart17.CFrame = deathSpot
end)

local esp = tabs.ESP:AddLeftGroupbox("ESP")

esp:AddToggle("ESPEnabled", {
  Text = "ESP",
  Default = true,
  Tooltip = "Highlight, label, tracer beam and beam corners",
})

toggles.ESPEnabled:OnChanged(function() _G.ESP_ENABLED = toggles.ESPEnabled.Value end)
_G.ESP_ENABLED = toggles.ESPEnabled.Value

esp:AddDivider()

esp:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
  Default = "RightShift",
  NoUI = true,
  Text = "Menu keybind",
})

library.ToggleKeybind = options.MenuKeybind
esp:AddButton("Unload", function() library:Unload() end)
local items = tabs.ESP:AddLeftGroupbox("Items")

for _, value47 in ipairs(promptTypes) do
  items:AddToggle("ESPItem" .. value47.id, {
    Text = value47.text,
    Default = false,
    Callback = function(value48) settings.espItem[value47.id] = value48 end,
  })
end

tabs.ESP:AddRightGroupbox("Entities"):AddToggle("ESPGrins", {
  Text = "Grinsworth",
  Default = false,
  Tooltip = "ESP on workspace.GrinsworthBody.Grinsworth, no radius limit",
  Callback = function(value49) settings.espGrins = value49 end,
})

local movement = tabs.Player:AddLeftGroupbox("Movement")

movement:AddToggle("SpeedToggle", {
  Text = "Speed",
  Default = false,
  Callback = function(value50)
    settings.speed = value50
    local humanoid7 = getHumanoid()

    if value50 then
      if humanoid7 then
        defaults.walk = humanoid7.WalkSpeed
      end
    elseif humanoid7 then
      humanoid7.WalkSpeed = defaults.walk
    end
  end,
})

movement:AddSlider("WalkSpeed", {
  Text = "WalkSpeed",
  Default = 16,
  Min = 16,
  Max = 150,
  Rounding = 0,
  Callback = function(value51) settings.walk = value51 end,
})

movement:AddToggle("JumpToggle", {
  Text = "Jump power",
  Default = false,
  Callback = function(value52)
    settings.jump = value52
    local humanoid8 = getHumanoid()

    if value52 then
      if humanoid8 then
        local jumpPower = humanoid8.JumpPower
        local useJumpPower = humanoid8.UseJumpPower

        defaults.jumpPower = jumpPower
        defaults.useJumpPower = useJumpPower
      end
    elseif humanoid8 then
      humanoid8.UseJumpPower = defaults.useJumpPower
      humanoid8.JumpPower = defaults.jumpPower
    end
  end,
})

movement:AddSlider("JumpPower", {
  Text = "JumpPower",
  Default = 50,
  Min = 50,
  Max = 200,
  Rounding = 0,
  Callback = function(value53) settings.jumpPower = value53 end,
})

movement:AddToggle("InfJump", {
  Text = "Infinite jump",
  Default = false,
  Callback = function(value54) settings.infJump = value54 end,
})

movement:AddToggle("Bhop", {
  Text = "Bunny hop",
  Default = false,
  Callback = function(value55) settings.bhop = value55 end,
})

movement:AddToggle("NoclipToggle", {
  Text = "Noclip",
  Default = false,
  Callback = function(value56) settings.noclip = value56 end,
}):AddKeyPicker("NoclipKey", {
  Default = "X",
  SyncToggleState = true,
  Mode = "Toggle",
  Text = "Noclip",
  NoUI = false,
})

movement:AddToggle("GhostToggle", {
  Text = "Ghost mode",
  Default = false,
  Callback = function(value57)
    settings.ghost = value57

    if not value57 then
      restoreTransparency()
    end
  end,
})

movement:AddToggle("FlyToggle", {
  Text = "Fly",
  Default = false,
  Callback = function(value58)
    settings.fly = value58

    if value58 then
      if not makeBodyVelocity() then
        settings.fly = false
        pcall(function() toggles.FlyToggle:SetValue(false) end)
      end
    else
      destroyFlyObjects()
    end
  end,
}):AddKeyPicker("FlyKey", {
  Default = "F",
  SyncToggleState = true,
  Mode = "Toggle",
  Text = "Fly",
  NoUI = false,
})

movement:AddSlider("FlySpeed", {
  Text = "Fly speed",
  Default = 50,
  Min = 10,
  Max = 200,
  Rounding = 0,
  Callback = function(value59) settings.flySpeed = value59 end,
})

local physics = tabs.Player:AddRightGroupbox("Physics")

physics:AddToggle("GravityToggle", {
  Text = "Custom gravity",
  Default = false,
  Callback = function(value60)
    settings.gravity = value60

    if value60 then
      defaults.gravity = workspace.Gravity
    else
      workspace.Gravity = defaults.gravity
    end
  end,
})

physics:AddSlider("GravityVal", {
  Text = "Gravity",
  Default = 196,
  Min = 5,
  Max = 400,
  Rounding = 0,
  Callback = function(value61) settings.gravityVal = value61 end,
})

physics:AddToggle("SpinToggle", {
  Text = "Spin",
  Default = false,
  Callback = function(value62) settings.spin = value62 end,
}):AddKeyPicker("SpinKey", {
  Default = "Z",
  SyncToggleState = true,
  Mode = "Toggle",
  Text = "Spin",
  NoUI = false,
})

physics:AddSlider("SpinSpeed", {
  Text = "Spin speed",
  Default = 5,
  Min = 1,
  Max = 30,
  Rounding = 0,
  Callback = function(value63) settings.spinSpeed = value63 end,
})

local misc = tabs.Player:AddRightGroupbox("Misc")

misc:AddToggle("AntiAfk", {
  Text = "Anti-AFK",
  Default = true,
  Callback = function(value64) settings.antiAfk = value64 end,
})

misc:AddToggle("ClickTP", {
  Text = "Click / tap teleport",
  Default = false,
  Callback = function(value65) settings.clickTP = value65 end,
})

misc:AddToggle("FreezeOthers", {
  Text = "Freeze others (client side)",
  Default = false,
  Callback = function(value66) settings.freeze = value66 end,
})

misc:AddDivider()

misc:AddButton("Copy position", function()
  local humanoidRootPart18 = getHumanoidRootPart()

  if humanoidRootPart18 and setclipboard then
    local position5 = humanoidRootPart18.Position

    local text5 = string.format(
      "Vector3.new(%.2f, %.2f, %.2f)", position5.X, position5.Y, position5.Z
    )

    setclipboard(text5)
    library:Notify("Copied " .. text5)
  end
end)

misc:AddButton("Rejoin", function()
  if #players:GetPlayers() <= 1 then
    teleportService:Teleport(game.PlaceId, localPlayer)
  else
    teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
  end
end)

misc:AddButton("Server hop", function()
  task.spawn(function()
    local ok2, result2 = pcall(function()
      return httpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"
        .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if ok2 and result2 and result2.data then
      for _, value67 in ipairs(result2.data) do
        if value67.id ~= game.JobId and value67.playing < value67.maxPlayers then
          teleportService:TeleportToPlaceInstance(game.PlaceId, value67.id, localPlayer)
          return
        end
      end

      library:Notify("No other servers found")
    else
      library:Notify("Server list request failed")
    end
  end)
end)

local positionHistory = tabs.Player:AddLeftGroupbox("Position history")

positionHistory:AddButton("Save position", function()
  local humanoidRootPart19 = getHumanoidRootPart()

  if not humanoidRootPart19 then
    return
  end

  table.insert(savedSlots, 1, humanoidRootPart19.CFrame)

  if #savedSlots > 5 then
    table.remove(savedSlots)
  end

  library:Notify("Position saved, slot 1 of " .. #savedSlots)
end)

for i16 = 1, 5 do
  positionHistory:AddButton("Recall slot " .. i16, function() teleportToSlot(i16) end)
end

tabs.Visuals:AddLeftGroupbox("World"):AddToggle("Fullbright", {
  Text = "Fullbright",
  Default = false,
  Callback = function(value68)
    settings.fullbright = value68

    if not value68 then
      restoreLighting()
    end
  end,
})

local camera = tabs.Visuals:AddRightGroupbox("Camera")

camera:AddToggle("FovToggle", {
  Text = "Custom FOV",
  Default = false,
  Callback = function(value69)
    settings.fov = value69

    if value69 then
      defaults.fov = workspace.CurrentCamera.FieldOfView
    else
      workspace.CurrentCamera.FieldOfView = defaults.fov
    end
  end,
})

camera:AddSlider("FovVal", {
  Text = "FOV",
  Default = 70,
  Min = 30,
  Max = 120,
  Rounding = 0,
  Callback = function(value70) settings.fovVal = value70 end,
})

local aiTerminal = tabs.ESP:AddRightGroupbox("AI terminal")

aiTerminal:AddToggle("AIStream", {
  Text = "AI stream box",
  Default = true,
  Callback = function(value71) _G.AI_Config.Stream = value71 end,
})

aiTerminal:AddToggle("AINotifs", {
  Text = "AI notifications",
  Default = true,
  Callback = function(value72) _G.AI_Config.Notifs = value72 end,
})

aiTerminal:AddSlider("AIThreat", {
  Text = "Threat range",
  Default = 35,
  Min = 10,
  Max = 150,
  Rounding = 0,
  Callback = function(value73) _G.AI_Config.EntityRange = value73 end,
})

aiTerminal:AddSlider("AIProx", {
  Text = "Proximity range",
  Default = 15,
  Min = 5,
  Max = 100,
  Rounding = 0,
  Callback = function(value74) _G.AI_Config.InteractRange = value74 end,
})

local fovCircle = tabs.Visuals:AddLeftGroupbox("FOV circle")

fovCircle:AddToggle("FovRing", {
  Text = "Beam FOV circle",
  Default = false,
  Callback = function(value75)
    settings.fovRing = value75

    if not value75 then
      hideTopBeacon()
    end
  end,
})

fovCircle:AddToggle("RingRainbow", {
  Text = "Rainbow",
  Default = true,
  Callback = function(value76) settings.ringRainbow = value76 end,
}):AddColorPicker("RingColor", {
  Default = Color3.fromRGB(0, 255, 150),
  Title = "Ring color (rainbow off)",
})

fovCircle:AddSlider("RingRadius", {
  Text = "Radius (px)",
  Default = 150,
  Min = 40,
  Max = 500,
  Rounding = 0,
  Callback = function(value77) settings.ringRadius = value77 end,
})

fovCircle:AddSlider("RingThick", {
  Text = "Thickness (px)",
  Default = 3,
  Min = 1,
  Max = 10,
  Rounding = 0,
  Callback = function(value78) settings.ringThick = value78 end,
})

fovCircle:AddSlider("RingWobble", {
  Text = "Wobble",
  Default = 15,
  Min = 0,
  Max = 50,
  Rounding = 0,
  Callback = function(value79) settings.ringWobble = value79 end,
})

fovCircle:AddSlider("RingSpin", {
  Text = "Spin speed",
  Default = 2,
  Min = 0,
  Max = 10,
  Rounding = 1,
  Callback = function(value80) settings.ringSpin = value80 end,
})

fovCircle:AddToggle("RingNameOn", {
  Text = "Name tag",
  Default = true,
  Callback = function(value81) settings.ringName = value81 end,
})

fovCircle:AddInput("RingNameText", {
  Default = "hajunware",
  Numeric = false,
  Finished = false,
  Text = "Name",
  Placeholder = "hajunware",
  Callback = function(value82) settings.ringNameText = value82 end,
})

fovCircle:AddSlider("RingNameSize", {
  Text = "Name size (px)",
  Default = 28,
  Min = 10,
  Max = 80,
  Rounding = 0,
  Callback = function(value83) settings.nameSize = value83 end,
})

aiTerminal:AddDropdown("AIPos", {
  Values = { "Top Right", "Top Left", "Top Center" },
  Default = 1,
  Multi = false,
  Text = "Box position",
  Callback = function(value84) setNotifPosition(value84) end,
})

local fovAlerts = tabs.Visuals:AddRightGroupbox("FOV alerts")
fovAlerts:AddLabel("Needs the beam FOV circle on", true)

fovAlerts:AddToggle("SpotPlayers", {
  Text = "Player spotted",
  Default = true,
  Callback = function(value85) settings.spotPlayers = value85 end,
})

fovAlerts:AddToggle("SpotEntities", {
  Text = "Entity spotted",
  Default = true,
  Callback = function(value86) settings.spotEntities = value86 end,
})

fovAlerts:AddToggle("SpotInteract", {
  Text = "Interactable spotted",
  Default = true,
  Callback = function(value87) settings.spotInteract = value87 end,
})

fovAlerts:AddSlider("SpotRange", {
  Text = "Spot range",
  Default = 200,
  Min = 50,
  Max = 1000,
  Rounding = 0,
  Suffix = "m",
  Callback = function(value88) settings.spotRange = value88 end,
})

local rainbowItems = tabs.Visuals:AddLeftGroupbox("Rainbow items")

rainbowItems:AddToggle("RbTools", {
  Text = "Tools (held + backpack)",
  Default = false,
  Callback = function(value89)
    settings.rbTools = value89

    if not value89 then
      restoreHighlightColors()
    end
  end,
})

rainbowItems:AddToggle("RbHotbar", {
  Text = "Hotbar icons",
  Default = false,
  Callback = function(value90)
    settings.rbHotbar = value90

    if not value90 then
      restoreImageColors()
    end
  end,
})

rainbowItems:AddSlider("RbSpeed", {
  Text = "Speed",
  Default = 0.3,
  Min = 0.05,
  Max = 2,
  Rounding = 2,
  Callback = function(value91) settings.rbSpeed = value91 end,
})

local ok3, result3 = pcall(function()
  local themeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/addons/ThemeManager.lua"))()
  local saveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/addons/SaveManager.lua"))()
  themeManager:SetLibrary(library)

  saveManager:SetLibrary(library)
  saveManager:IgnoreThemeSettings()
  saveManager:SetIgnoreIndexes({ "MenuKeybind" })

  themeManager:SetFolder("hajunware")

  saveManager:SetFolder("hajunware/main")
  saveManager:BuildConfigSection(tabs.Config)

  themeManager:ApplyToTab(tabs.Config)
  saveManager:LoadAutoloadConfig()
end)

if not ok3 then
  library:Notify("Config tab failed: " .. tostring(result3))
end

library:OnUnload(function()
  running = false
  restoreHighlightColors()
  restoreImageColors()
  _G.ESP_ENABLED = false

  for _, value92 in ipairs(connections) do
    value92:Disconnect()
  end

  pcall(function() runService:UnbindFromRenderStep("hajunware_ring") end)
  pcall(function() runService:UnbindFromRenderStep("hajunware_fov") end)

  destroyTopBeacon()
  destroyRingLabel()
  destroyNotifGui()
  destroyFlyObjects()
  restoreTransparency()
  unanchorParts()
  restoreLighting()

  workspace.Gravity = defaults.gravity
  workspace.CurrentCamera.FieldOfView = defaults.fov

  local humanoid9 = getHumanoid()

  if humanoid9 then
    if settings.speed then
      humanoid9.WalkSpeed = defaults.walk
    end

    if settings.jump then
      humanoid9.UseJumpPower = defaults.useJumpPower
      humanoid9.JumpPower = defaults.jumpPower
    end
  end
end)

-- https://leakd.fr
