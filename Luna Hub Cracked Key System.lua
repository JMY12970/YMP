--[[
    Fіle Dеоbfuѕсаtеd Usіng LеаκD
    https://leakd.fr
]]

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local workspaceService = game:GetService("Workspace")
local coreGui = game:GetService("CoreGui")
local statsService = game:GetService("Stats")
local localPlayer = players.LocalPlayer
local currentCamera = workspaceService.CurrentCamera
local v1 = getgenv and getgenv() or _G

if v1.LunaUnload then
  pcall(v1.LunaUnload)
end

local function f1()
  local ok2, result2 = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
  end)

  if not ok2 or type(result2) ~= "table" then
    return nil, tostring(result2)
  end

  return result2
end

local function makeTextLabel(p1)
  local options = p1.Options
  local toggles = p1.Toggles

  local v2 = {
    Accent = Color3.fromRGB(190, 155, 255),
    Accent2 = Color3.fromRGB(139, 92, 246),
    Hidden = Color3.fromRGB(120, 84, 214),
    Target = Color3.fromRGB(255, 190, 245),
    Danger = Color3.fromRGB(255, 96, 128),
    Text = Color3.fromRGB(242, 235, 255),
  }

  pcall(function()
    local scheme = p1.Scheme
    scheme.BackgroundColor = Color3.fromRGB(19, 14, 33)
    scheme.MainColor = Color3.fromRGB(28, 20, 48)
    scheme.AccentColor = v2.Accent
    scheme.OutlineColor = Color3.fromRGB(58, 44, 94)
    scheme.FontColor = v2.Text
  end)

  local v3 = {
    Lavender = Color3.fromRGB(190, 155, 255),
    Violet = Color3.fromRGB(139, 92, 246),
    Orchid = Color3.fromRGB(226, 140, 255),
    Indigo = Color3.fromRGB(129, 140, 255),
  }

  local function f2(key)
    local v4 = toggles[key]
    return v4 ~= nil and v4.Value == true
  end

  local function f3(key2, p2)
    local v5 = options[key2]

    if v5 and v5.Value ~= nil then
      return v5.Value
    end

    return p2
  end

  local function f4(key3, p3)
    local v6 = options[key3]

    if v6 and typeof(v6.Value) == "Color3" then
      return v6.Value
    end

    return p3
  end

  local list = {}

  local function getConnect(p4, p5)
    local connect = p4:Connect(p5)
    table.insert(list, connect)
    return connect
  end

  local drawing = Drawing

  local function f5()
    if gethui then
      local ok3, hui = pcall(gethui)

      if ok3 and hui then
        return hui
      end
    end

    if pcall(function() return coreGui.Name end) then
      return coreGui
    end

    return localPlayer:WaitForChild("PlayerGui")
  end

  local v7 = drawing ~= nil and Drawing.new ~= nil

  local lunaOverlay = Instance.new("ScreenGui")
  lunaOverlay.Name = "LunaOverlay"
  lunaOverlay.ResetOnSpawn = false
  lunaOverlay.IgnoreGuiInset = true
  lunaOverlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  lunaOverlay.DisplayOrder = 50

  local frame = Instance.new("Frame")
  frame.AnchorPoint = Vector2.new(0.5, 0.5)
  frame.Position = UDim2.fromScale(0.5, 0.5)
  frame.Size = UDim2.fromOffset(320, 320)
  frame.BackgroundTransparency = 1
  frame.Visible = false
  frame.Parent = lunaOverlay

  local uiCorner = Instance.new("UICorner")
  uiCorner.CornerRadius = UDim.new(1, 0)
  uiCorner.Parent = frame

  local uiStroke = Instance.new("UIStroke")
  uiStroke.Color = v2.Accent
  uiStroke.Thickness = 1.5
  uiStroke.Transparency = 0.25
  uiStroke.Parent = frame

  lunaOverlay.Parent = f5()

  local raycastParams = RaycastParams.new()
  raycastParams.FilterType = Enum.RaycastFilterType.Exclude
  raycastParams.IgnoreWater = true

  local function f6()
    local filterDescendantsInstances = { currentCamera }

    if localPlayer.Character then
      table.insert(filterDescendantsInstances, localPlayer.Character)
    end

    raycastParams.FilterDescendantsInstances = filterDescendantsInstances
  end

  local function f7(getPlayerFromCharacter)
    if not f2("TeamCheck") then
      return true
    end

    local team = localPlayer:GetAttribute("Team")
    local team2 = getPlayerFromCharacter:GetAttribute("Team")

    if team ~= nil and team2 ~= nil then
      return team ~= team2
    end

    if localPlayer.Team and getPlayerFromCharacter.Team then
      return localPlayer.Team ~= getPlayerFromCharacter.Team
    end

    return true
  end

  local function getCharacter(getPlayerFromCharacter2)
    local character = getPlayerFromCharacter2.Character

    if not character then
      return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid and humanoid.Health <= 0 then
      return nil
    end

    if not character:FindFirstChild("HumanoidRootPart") and not character:FindFirstChild("Head") then
      return nil
    end

    return character, humanoid
  end

  local function f8(head, p6)
    local position = currentCamera.CFrame.Position
    local raycast = workspaceService:Raycast(position, head.Position - position, raycastParams)

    if not raycast then
      return true
    end

    return raycast.Instance:IsDescendantOf(p6)
  end

  local function getVector()
    local viewportSize = currentCamera.ViewportSize
    return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
  end

  local v8 = {}
  local clamped = 0.05
  local v9 = 0

  local function f9(p7)
    if p7 <= 0 then
      return
    end

    v9 = v9 + p7

    if v9 >= 1 then
      v9 = 0

      local ok4, result3 = pcall(function()
        return statsService.Network.ServerStatsItem["Data Ping"]:GetValue()
      end)

      if ok4 and type(result3) == "number" then
        clamped = math.clamp(result3 / 1000, 0.01, 0.5)
      end
    end

    for _, value in ipairs(players:GetPlayers()) do
      if value ~= localPlayer then
        local character2 = value.Character
        local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart then
          local v10 = v8[value]

          if v10 and v10.Char == character2 then
            local v11 = (humanoidRootPart.Position - v10.Pos) / p7

            if v11.Magnitude > 120 then
              v10.Vel = Vector3.zero
            else
              v10.Vel = v10.Vel:Lerp(v11, 0.35)
            end

            v10.Pos = humanoidRootPart.Position
          else
            v8[value] = {
              Char = character2,
              Pos = humanoidRootPart.Position,
              Vel = Vector3.zero,
            }
          end
        else
          v8[value] = nil
        end
      end
    end
  end

  local function f10(plr, part)
    local position2 = part.Position

    if not f2("Predict") then
      return position2
    end

    local v12 = v8[plr]
    local vel = v12 and v12.Vel or part.AssemblyLinearVelocity
    local v13 = f3("LeadMs", 0) / 1000

    if f2("AutoPing") then
      v13 = v13 + (clamped * 0.5 + 0.015)
    end

    return position2 + Vector3.new(vel.X, vel.Y * 0.4, vel.Z) * v13
  end

  local function f11(instance, wallCheck)
    local v14 = f3("AimPart", "Auto")
    local head2 = instance:FindFirstChild("Head")

    local upperTorso = instance:FindFirstChild("UpperTorso") or instance:FindFirstChild("Torso")
      or instance:FindFirstChild("HumanoidRootPart")

    if v14 == "Head" then
      return head2 or upperTorso
    end

    if v14 == "Torso" then
      return upperTorso or head2
    end

    if head2 and (not wallCheck or f8(head2, instance)) then
      return head2
    end

    return upperTorso
  end

  local function f12(plr2, p8, position3, p9, p10)
    if plr2 == localPlayer or not f7(plr2) then
      return nil
    end

    local v15, v16 = getCharacter(plr2)

    if not v15 then
      return nil
    end

    local wallCheck2 = f2("WallCheck")
    local v17 = f11(v15, wallCheck2)

    if not v17 then
      return nil
    end

    local magnitude = (v17.Position - position3).Magnitude

    if magnitude > f3("MaxDist", 1000) then
      return nil
    end

    local worldToViewportPoint = currentCamera:WorldToViewportPoint(v17.Position)

    if worldToViewportPoint.Z <= 0 then
      return nil
    end

    local magnitude2 = (Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
      - p8).Magnitude

    if magnitude2 > p9 then
      return nil
    end

    if wallCheck2 and not f8(v17, v15) then
      return nil
    end

    local health = v16 and v16.Health or 100
    local score

    if p10 == "Distance" then
      score = magnitude
    elseif p10 == "Lowest HP" then
      score = health * 1000 + magnitude2
    else
      score = magnitude2
    end

    return {
      Plr = plr2,
      Part = v17,
      Score = score,
      Dist = magnitude,
      HP = health,
    }
  end

  local plr3

  local function f13()
    local vector = getVector()
    local position4 = currentCamera.CFrame.Position
    local v18 = f3("AimFOV", 160)
    local v19 = f3("TargetMode", "Crosshair")

    if f2("Sticky") and plr3 and plr3.Parent == players then
      local v20 = f12(plr3, vector, position4, v18 * 1.5, v19)

      if v20 then
        return v20
      end

      plr3 = nil
    end

    local v21

    for _, value2 in ipairs(players:GetPlayers()) do
      local v22 = f12(value2, vector, position4, v18, v19)

      if v22 and (not v21 or v22.Score < v21.Score) then
        v21 = v22
      end
    end

    return v21
  end

  local function f14()
    local v23 = f3("AimMode", "RMB")

    if v23 == "Always" then
      return true
    elseif v23 == "RMB" then
      return userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end

    if v23 == "LMB" then
      return userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    end

    local aimKey = options.AimKey
    return aimKey ~= nil and aimKey:GetState() == true
  end

  local zero = Vector2.zero
  local now = 0

  local function f15(p11, p12)
    local worldToViewportPoint2 = currentCamera:WorldToViewportPoint(p11)

    if worldToViewportPoint2.Z <= 0 then
      return
    end

    local v24 = Vector2.new(worldToViewportPoint2.X, worldToViewportPoint2.Y) - getVector()

    if f2("Humanize") then
      local now2 = os.clock()
      local v25 = f3("HumanizeAmt", 2)

      v24 = v24
        + Vector2.new(math.noise(now2 * 2.3, 11) * v25, math.noise(now2 * 2.1, 37) * v25)
    end

    if v24.Magnitude < 1.2 then
      return
    end

    local v26 = 1
      - (1 - math.clamp(1 - f3("AimSmooth", 0.6), 0.03, 1)) ^ (math.clamp(p12, 0, 0.1) * 60)

    local v27 = v24 * v26
    local v28 = f3("MaxStep", 80)

    if v27.Magnitude > v28 then
      v27 = v27.Unit * v28
    end

    if f2("UseMouse") and mousemoverel then
      zero = zero + v27 * f3("MouseGain", 1)
      local v29 = math.round(zero.X)
      local v30 = math.round(zero.Y)

      if v29 ~= 0 or v30 ~= 0 then
        zero = zero - Vector2.new(v29, v30)
        pcall(mousemoverel, v29, v30)
      end
    else
      local cframe = CFrame.new(currentCamera.CFrame.Position, p11)
      currentCamera.CFrame = currentCamera.CFrame:Lerp(cframe, v26)
    end
  end

  local v31, plr4

  local function f16(p13)
    local aimEnabled = f2("AimEnabled")
    frame.Visible = aimEnabled and f2("ShowFOV")

    if frame.Visible then
      local v32 = f3("AimFOV", 160)
      frame.Size = UDim2.fromOffset(v32 * 2, v32 * 2)

      uiStroke.Color = f4("FOVColor", v2.Accent)
      uiStroke.Transparency = v31 and 0 or 0.3
    end

    if not aimEnabled or p1.Toggled or userInputService:GetFocusedTextBox() or not f14() then
      v31 = nil
      plr3 = nil
      plr4 = nil
      zero = Vector2.zero
      return
    end

    local v33 = f13()
    v31 = v33

    if not v33 then
      plr3 = nil
      plr4 = nil
      return
    end

    if f2("Sticky") then
      plr3 = v33.Plr
    end

    if v33.Plr ~= plr4 then
      plr4 = v33.Plr
      now = os.clock()
    end

    if os.clock() - now < f3("ReactionMs", 0) / 1000 then
      return
    end

    f15(f10(v33.Plr, v33.Part), p13)
  end

  local v34 = 0
  local v35 = 0.1
  local v36

  local function f17()
    if not f2("TriggerEnabled") or p1.Toggled then
      v36 = nil
      return
    end

    local vector2 = getVector()
    local viewportPointToRay = currentCamera:ViewportPointToRay(vector2.X, vector2.Y)

    local raycast2 = workspaceService:Raycast(
      viewportPointToRay.Origin, viewportPointToRay.Direction * f3("MaxDist", 1000),
      raycastParams
    )

    local v37 = false

    if raycast2 then
      local model = raycast2.Instance:FindFirstAncestorOfClass("Model")
      local getPlayerFromCharacter3 = model and players:GetPlayerFromCharacter(model)

      if getPlayerFromCharacter3 and getPlayerFromCharacter3 ~= localPlayer
        and f7(getPlayerFromCharacter3) and getCharacter(getPlayerFromCharacter3) then
        v37 = not f2("TriggerHeadOnly") or raycast2.Instance.Name == "Head"
      end
    end

    local now3 = os.clock()

    if not v37 then
      v36 = nil
      return
    end

    v36 = v36 or now3

    if now3 - v36 < f3("TriggerReactMs", 60) / 1000 then
      return
    end

    if now3 - v34 < v35 then
      return
    end

    v34 = now3
    v35 = f3("TriggerDelay", 0.1) + math.random() * f3("TriggerJitter", 0.03)

    if not mouse1click then
      if mouse1press and mouse1release then
        task.delay(0.02, function() end)
      end
    end
  end

  local map = {}

  local function f18(key4)
    local v38 = map[key4]

    if not v38 then
      return
    end

    for _, value3 in ipairs(v38.Objs) do
      pcall(function()
        if typeof(value3) == "Instance" then
          value3:Destroy()
        else
          value3:Remove()
        end
      end)
    end

    map[key4] = nil
  end

  local function makeTextLabel2(key5, p14, head3)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = p14
    highlight.FillColor = v2.Accent2
    highlight.OutlineColor = v2.Accent
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = lunaOverlay

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = head3
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.fromOffset(180, 34)
    billboardGui.StudsOffset = Vector3.new(0, 2.6, 0)
    billboardGui.Parent = lunaOverlay

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 18)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 13
    textLabel.TextColor3 = v2.Text
    textLabel.TextStrokeColor3 = Color3.fromRGB(20, 10, 40)
    textLabel.TextStrokeTransparency = 0.35
    textLabel.Text = key5.DisplayName
    textLabel.Parent = billboardGui

    local frame2 = Instance.new("Frame")
    frame2.Position = UDim2.new(0.5, -40, 0, 22)
    frame2.Size = UDim2.fromOffset(80, 5)
    frame2.BackgroundColor3 = Color3.fromRGB(18, 12, 32)
    frame2.BorderSizePixel = 0
    frame2.Parent = billboardGui

    local uiCorner2 = Instance.new("UICorner")
    uiCorner2.CornerRadius = UDim.new(1, 0)
    uiCorner2.Parent = frame2

    local frame3 = Instance.new("Frame")
    frame3.Size = UDim2.fromScale(1, 1)
    frame3.BackgroundColor3 = v2.Accent
    frame3.BorderSizePixel = 0
    frame3.Parent = frame2

    local uiCorner3 = Instance.new("UICorner")
    uiCorner3.CornerRadius = UDim.new(1, 0)
    uiCorner3.Parent = frame3

    local v39

    if v7 then
      local ok5, newDrawing = pcall(Drawing.new, "Line")

      if ok5 then
        v39 = newDrawing
        v39.Color = v2.Accent
        v39.Thickness = 1.2
        v39.Transparency = 1
        v39.Visible = false
      end
    end

    map[key5] = {
      Char = p14,
      Highlight = highlight,
      Billboard = billboardGui,
      Label = textLabel,
      BarBg = frame2,
      Fill = frame3,
      Tracer = v39,
      Objs = { highlight, billboardGui, v39 },
    }
  end

  local v40 = 0

  local function f19(p15)
    v40 = v40 + p15
    local v41 = v40 >= 0.1

    if v41 then
      v40 = 0
    end

    local position5 = currentCamera.CFrame.Position
    local viewportSize2 = currentCamera.ViewportSize
    local v42 = f3("MaxDist", 1000)
    local esp = f2("ESP")

-- https://leakd.fr
    for _, value4 in ipairs(players:GetPlayers()) do
      if value4 ~= localPlayer then
        local instance2, v43 = getCharacter(value4)

        local humanoidRootPart2 = instance2
          and (instance2:FindFirstChild("HumanoidRootPart") or instance2.PrimaryPart)

        local head4 = instance2 and (instance2:FindFirstChild("Head") or humanoidRootPart2)

        if not (esp and instance2 and humanoidRootPart2 and head4 and (f2("ESPTeam") or f7(value4))
          and (humanoidRootPart2.Position - position5).Magnitude <= v42) then
          f18(value4)
        else
          local v44 = map[value4]

          if v44 and v44.Char ~= instance2 then
            f18(value4)
            v44 = nil
          end

          if not v44 then
            makeTextLabel2(value4, instance2, head4)
            v44 = map[value4]
          end

          v44.Highlight.Enabled = f2("ESPHighlight")
          v44.Label.Visible = f2("ESPName")
          v44.BarBg.Visible = f2("ESPHealth")

          if v41 then
            local v45 = f4("ESPVisColor", v2.Accent)

            if f2("ESPTargetMark") and v31 and v31.Plr == value4 then
              v45 = f4("ESPTargetColor", v2.Target)
            elseif f2("ESPVisCheck") then
              v45 = f8(head4, instance2) and v45 or f4("ESPHiddenColor", v2.Hidden)
            end

            v44.Highlight.FillColor = v45
            v44.Highlight.OutlineColor = v45:Lerp(Color3.new(1, 1, 1), 0.35)
            v44.Label.TextColor3 = v45:Lerp(Color3.new(1, 1, 1), 0.5)

            if v44.Tracer then
              v44.Tracer.Color = v45
            end

            local rounded = math.floor((humanoidRootPart2.Position - position5).Magnitude)
            v44.Label.Text = string.format("%s  ·  %dm", value4.DisplayName, rounded)
            local health2 = v43 and v43.Health or 100
            local maxHealth = v43 and v43.MaxHealth or 100
            local clamped2 = math.clamp(health2 / math.max(maxHealth, 1), 0, 1)

            v44.Fill.Size = UDim2.fromScale(clamped2, 1)
            v44.Fill.BackgroundColor3 = v2.Danger:Lerp(v2.Accent, clamped2)
          end

          if v44.Tracer then
            if f2("ESPTracer") then
              local screenPoint, visible = currentCamera:WorldToViewportPoint(humanoidRootPart2.Position)
              v44.Tracer.Visible = visible

              if visible then
                v44.Tracer.From = Vector2.new(viewportSize2.X / 2, viewportSize2.Y)
                v44.Tracer.To = Vector2.new(screenPoint.X, screenPoint.Y)
              end
            else
              v44.Tracer.Visible = false
            end
          end
        end
      end
    end
  end

  local map2

  local function f20(p16)
    if p16 then
      if not map2 then
        map2 = {
          Brightness = lighting.Brightness,
          ClockTime = lighting.ClockTime,
          FogEnd = lighting.FogEnd,
          GlobalShadows = lighting.GlobalShadows,
          Ambient = lighting.Ambient,
        }
      end

      lighting.Brightness = 2
      lighting.ClockTime = 14
      lighting.FogEnd = 1000000
      lighting.GlobalShadows = false
      lighting.Ambient = Color3.fromRGB(190, 170, 230)
    elseif map2 then
      for key6, value5 in pairs(map2) do
        lighting[key6] = value5
      end

      map2 = nil
    end
  end

  local fieldOfView

  local function f21(p17)
    if p17 then
      fieldOfView = fieldOfView or currentCamera.FieldOfView
    elseif fieldOfView then
      currentCamera.FieldOfView = fieldOfView
      fieldOfView = nil
    end
  end

  local function f22(p18)
    local character3 = localPlayer.Character
    local humanoid2 = character3 and character3:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart3 = character3 and character3:FindFirstChild("HumanoidRootPart")

    if not (humanoid2 and humanoidRootPart3) or humanoid2.Health <= 0 then
      return
    end

    if f2("Speed") then
      local moveDirection = humanoid2.MoveDirection

      if moveDirection.Magnitude > 0 then
        humanoidRootPart3.CFrame = humanoidRootPart3.CFrame
          + moveDirection * f3("SpeedValue", 6) * p18
      end
    end

    if f2("Bhop") and userInputService:IsKeyDown(Enum.KeyCode.Space)
      and not userInputService:GetFocusedTextBox()
      and humanoid2.FloorMaterial ~= Enum.Material.Air then
      humanoid2:ChangeState(Enum.HumanoidStateType.Jumping)
    end
  end

  local lunaHubWindow = p1:CreateWindow({
    Title = "Luna Hub",
    Footer = "Rivals · v2.0",
    ToggleKeybind = Enum.KeyCode.RightShift,
    Center = true,
    AutoShow = true,
    Size = UDim2.fromOffset(660, 540),
    CornerRadius = 8,
    NotifySide = "Right",
    ShowCustomCursor = true,
  })

  local v46 = {
    Combat = lunaHubWindow:AddTab("Combat", "crosshair"),
    Visuals = lunaHubWindow:AddTab("Visuals", "eye"),
    Movement = lunaHubWindow:AddTab("Movement", "zap"),
    Settings = lunaHubWindow:AddTab("UI Settings", "settings"),
  }

  local aimbot = v46.Combat:AddLeftGroupbox("Aimbot")

  aimbot:AddToggle("AimEnabled", {
    Text = "Aimbot",
    Default = false,
    Tooltip = "Aim at the nearest enemy within the FOV circle",
  }):AddKeyPicker("AimKey", {
    Default = "None",
    Mode = "Hold",
    Text = "Aim key",
    NoUI = false,
  })

  aimbot:AddDropdown("AimMode", {
    Text = "Aim activation",
    Values = { "RMB", "LMB", "Always", "Keybind" },
    Default = 1,
    Tooltip = "Keybind = the key from the icon next to the toggle",
  })

  aimbot:AddDropdown("AimPart", {
    Text = "Target part",
    Values = { "Auto", "Head", "Torso" },
    Default = 1,
    Tooltip = "Auto: head, or torso if occluded",
  })

  aimbot:AddDropdown("TargetMode", {
    Text = "Target priority",
    Values = { "Crosshair", "Distance", "Lowest HP" },
    Default = 1,
  })

  aimbot:AddToggle("Sticky", {
    Text = "Sticky target",
    Default = true,
    Tooltip = "Sticks to the target while it remains in view",
  })

  aimbot:AddToggle("WallCheck", { Text = "Wall check", Default = true })
  aimbot:AddToggle("TeamCheck", { Text = "Team check", Default = true })

  aimbot:AddToggle("UseMouse", {
    Text = "Mouse movement mode",
    Default = true,
    Tooltip = "Via mousemoverel. If the executor can't, camera is used",
  })

  local targeting = v46.Combat:AddLeftGroupbox("Targeting")

  targeting:AddSlider("AimFOV", {
    Text = "FOV radius",
    Default = 160,
    Min = 30,
    Max = 500,
    Rounding = 0,
    Suffix = "px",
  })

  targeting:AddToggle("ShowFOV", { Text = "Show FOV circle", Default = true }):AddColorPicker("FOVColor", {
    Default = v2.Accent,
    Title = "FOV color",
  })

  targeting:AddSlider("MaxDist", {
    Text = "Max distance",
    Default = 1000,
    Min = 100,
    Max = 2000,
    Rounding = 0,
    Suffix = "m",
  })

  local target = targeting:AddLabel("Target: -")

  local humanization = v46.Combat:AddRightGroupbox("Humanization")

  humanization:AddSlider("AimSmooth", {
    Text = "Smoothness",
    Default = 0.6,
    Min = 0,
    Max = 0.95,
    Rounding = 2,
  })

  humanization:AddSlider("MaxStep", {
    Text = "Max step per frame",
    Default = 80,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Suffix = "px",
  })

  humanization:AddSlider("MouseGain", {
    Text = "Mouse gain",
    Default = 1,
    Min = 0.2,
    Max = 3,
    Rounding = 2,
    Tooltip = "If it overshoots the target, reduce. If sluggish, increase",
  })

  humanization:AddToggle("Humanize", { Text = "Humanize (noise)", Default = true })

  humanization:AddSlider("HumanizeAmt", {
    Text = "Noise amount",
    Default = 2,
    Min = 0,
    Max = 8,
    Rounding = 1,
    Suffix = "px",
  })

  humanization:AddSlider("ReactionMs", {
    Text = "Reaction delay",
    Default = 40,
    Min = 0,
    Max = 300,
    Rounding = 0,
    Suffix = "ms",
  })

  local prediction = v46.Combat:AddRightGroupbox("Prediction")

  prediction:AddToggle("Predict", {
    Text = "Predict movement",
    Default = true,
    Tooltip = "Target velocity is computed from its actual movement",
  })

  prediction:AddToggle("AutoPing", { Text = "Auto ping compensation", Default = true })

  prediction:AddSlider("LeadMs", {
    Text = "Extra lead",
    Default = 0,
    Min = 0,
    Max = 250,
    Rounding = 0,
    Suffix = "ms",
  })

  local triggerbot = v46.Combat:AddRightGroupbox("Triggerbot")
  triggerbot:AddToggle("TriggerEnabled", { Text = "Triggerbot", Default = false })
  triggerbot:AddToggle("TriggerHeadOnly", { Text = "Head only", Default = false })

  triggerbot:AddSlider("TriggerReactMs", {
    Text = "Reaction",
    Default = 60,
    Min = 0,
    Max = 300,
    Rounding = 0,
    Suffix = "ms",
  })

  triggerbot:AddSlider("TriggerDelay", {
    Text = "Fire interval",
    Default = 0.1,
    Min = 0.03,
    Max = 0.5,
    Rounding = 2,
    Suffix = "s",
  })

  triggerbot:AddSlider("TriggerJitter", {
    Text = "Interval jitter",
    Default = 0.03,
    Min = 0,
    Max = 0.2,
    Rounding = 2,
    Suffix = "s",
  })

  local esp2 = v46.Visuals:AddLeftGroupbox("ESP")

  esp2:AddToggle("ESP", {
    Text = "ESP",
    Default = false,
    Callback = function(value6)
      if not value6 then
        for key7 in pairs(map) do
          f18(key7)
        end
      end
    end,
  })

  esp2:AddToggle("ESPHighlight", { Text = "Highlight", Default = true }):AddColorPicker("ESPVisColor", {
    Default = v2.Accent,
    Title = "Visible color",
  })

  esp2:AddToggle("ESPVisCheck", {
    Text = "Color by visibility",
    Default = true,
    Tooltip = "Color changes if the enemy is behind a wall",
  }):AddColorPicker("ESPHiddenColor", {
    Default = v2.Hidden,
    Title = "Hidden color",
  })

  esp2:AddToggle("ESPTargetMark", { Text = "Mark aim target", Default = true }):AddColorPicker("ESPTargetColor", {
    Default = v2.Target,
    Title = "Target color",
  })

  esp2:AddToggle("ESPName", { Text = "Name + distance", Default = true })
  esp2:AddToggle("ESPHealth", { Text = "Health bar", Default = true })

  esp2:AddToggle("ESPTracer", {
    Text = "Tracers" .. (v7 and "" or " (no Drawing)"),
    Default = false,
  })

  esp2:AddToggle("ESPTeam", { Text = "Show teammates", Default = false })

  local world = v46.Visuals:AddRightGroupbox("World")
  world:AddToggle("CamFOVEnabled", { Text = "Camera FOV", Default = false, Callback = f21 })

  world:AddSlider("CamFOV", {
    Text = "FOV value",
    Default = 90,
    Min = 60,
    Max = 120,
    Rounding = 0,
  })

  world:AddToggle("Fullbright", { Text = "Fullbright", Default = false, Callback = f20 })

  local movement = v46.Movement:AddLeftGroupbox("Movement")

  movement:AddToggle("Speed", {
    Text = "Speed boost",
    Default = false,
    Tooltip = "Start with 4-6; the server may roll back larger values",
  }):AddKeyPicker("SpeedKey", {
    Default = "None",
    Mode = "Toggle",
    Text = "Speed boost",
    SyncToggleState = true,
  })

  movement:AddSlider("SpeedValue", {
    Text = "Extra speed",
    Default = 6,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Suffix = " st/s",
  })

  movement:AddToggle("Bhop", { Text = "Bunny hop (hold Space)", Default = false })

  local menu = v46.Settings:AddLeftGroupbox("Menu")

  menu:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
  })

  p1.ToggleKeybind = options.MenuKeybind

  menu:AddDropdown("AccentPreset", {
    Text = "Accent color",
    Values = { "Lavender", "Violet", "Orchid", "Indigo" },
    Default = 1,
    Callback = function(value7)
      local accentColor = v3[value7]

      if accentColor then
        pcall(function()
          p1.Scheme.AccentColor = accentColor
          p1:UpdateColorsUsingRegistry()
        end)
      end
    end,
  })

  menu:AddButton({
    Text = "Unload Luna Hub",
    Func = function() p1:Unload() end,
    DoubleClick = true,
    Risky = true,
  })

  pcall(function()
    local saveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()
    saveManager:SetLibrary(p1)
    saveManager:IgnoreThemeSettings()
    saveManager:SetIgnoreIndexes({ "MenuKeybind", "AccentPreset" })
    saveManager:SetFolder("LunaHub/Rivals")
    saveManager:BuildConfigSection(v46.Settings)
    saveManager:LoadAutoloadConfig()
  end)

  local seen = {}

  local function f23(key8, p19, ...)
    local ok6, result4 = pcall(p19, ...)

    if not ok6 and not seen[key8] then
      seen[key8] = true
      warn("[Luna] " .. key8 .. ": " .. tostring(result4))
    end
  end

  local v47 = 0

  local function f24(p20)
    v47 = v47 + p20

    if v47 < 0.25 then
      return
    end

    v47 = 0
    local v48 = v31

    if v48 then
      target:SetText(string.format(
        "Target: %s · %dm · %d HP", v48.Plr.DisplayName, v48.Dist, v48.HP
      ))
    else
      target:SetText("Target: -")
    end
  end

  getConnect(runService.RenderStepped, function(p21)
    currentCamera = workspaceService.CurrentCamera or currentCamera

    f23("filter", f6)
    f23("aim", f16, p21)
    f23("trigger", f17)
    f23("esp", f19, p21)
    f23("status", f24, p21)

    if f2("CamFOVEnabled") then
      currentCamera.FieldOfView = f3("CamFOV", 90)
    end
  end)

  getConnect(runService.Heartbeat, function(p22)
    f23("tracker", f9, p22)
    f23("move", f22, p22)
  end)

  getConnect(players.PlayerRemoving, function(key9)
    f18(key9)
    v8[key9] = nil

    if plr3 == key9 then
      plr3 = nil
    end
  end)

  local flag = false

  local function f25()
    if flag then
      return
    end

    flag = true

    for _, value8 in ipairs(list) do
      pcall(function() value8:Disconnect() end)
    end

    table.clear(list)

    for key10 in pairs(map) do
      f18(key10)
    end

    f20(false)
    f21(false)

    if lunaOverlay then
      lunaOverlay:Destroy()
    end

    v1.LunaUnload = nil
  end

  p1:OnUnload(f25)

  function v1.LunaUnload()
    pcall(function() p1:Unload() end)
    f25()
  end

  p1:Notify({ Title = "Luna Hub", Description = "Loaded. Menu: RightShift", Time = 4 })
end

-- Load the hub directly; the custom key gate has been removed.
local library, loadError = f1()
if not library then
  warn("[Luna] Obsidian load failed: " .. tostring(loadError))
  return
end

local ok, buildError = pcall(makeTextLabel, library)
if not ok then
  warn("[Luna] build_hub failed: " .. tostring(buildError))
end
