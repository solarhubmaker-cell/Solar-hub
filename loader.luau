local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- [[ 1. 중복 실행 방지 및 예전 GUI 정리 ]]
if _G.SolarConnections then
    for _, conn in pairs(_G.SolarConnections) do
        if conn then conn:Disconnect() end
    end
end
_G.SolarConnections = {}

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "SOLAR_PREMIUM_UE" then v:Destroy() end
end

-- [[ 2. 최상위 GUI 스크린 생성 ]]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "SOLAR_PREMIUM_UE"
ScreenGui.DisplayOrder = 999

-- [[ 3. 메인 백그라운드 프레임 (영상 속 디자인 반영) ]]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 440)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = true

-- 상단 타이틀 바 고정
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -15, 0, 25)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SOLAR HUB V1 - discord.gg/VtPuHZQt8y"
Title.TextColor3 = Color3.fromRGB(255, 0, 50)
Title.Font = Enum.Font.Code
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left

-- [[ 4. 7대 탭 메뉴 바 디자인 ]]
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -24, 0, 26)
TabBar.Position = UDim2.new(0, 12, 0, 25)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TabBar.BorderSizePixel = 1
TabBar.BorderColor3 = Color3.fromRGB(35, 35, 35)

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 2)

-- 콘텐츠가 들어갈 메인 스크린 영역
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -24, 1, -65)
ContentFrame.Position = UDim2.new(0, 12, 0, 55)
ContentFrame.BackgroundTransparency = 1

-- [[ 5. 탭 페이지 생성 및 레이아웃 빌더 ]]
local Tabs = {}
local function CreateTabPages(tabName)
    local Page = Instance.new("Frame", ContentFrame)
    Page.Name = tabName .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    
    -- 각 탭 내부의 왼쪽 정렬 스크롤바
    local LeftScroll = Instance.new("ScrollingFrame", Page)
    LeftScroll.Name = "Left"
    LeftScroll.Size = UDim2.new(0.5, -5, 1, 0)
    LeftScroll.BackgroundTransparency = 1
    LeftScroll.BorderSizePixel = 0
    LeftScroll.ScrollBarThickness = 2
    LeftScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 50)
    local L_Layout = Instance.new("UIListLayout", LeftScroll)
    L_Layout.Padding = UDim.new(0, 10)
    
    -- 각 탭 내부의 오른쪽 정렬 스크롤바
    local RightScroll = Instance.new("ScrollingFrame", Page)
    RightScroll.Name = "Right"
    RightScroll.Size = UDim2.new(0.5, -5, 1, 0)
    RightScroll.Position = UDim2.new(0.5, 5, 0, 0)
    RightScroll.BackgroundTransparency = 1
    RightScroll.BorderSizePixel = 0
    RightScroll.ScrollBarThickness = 2
    RightScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 50)
    local R_Layout = Instance.new("UIListLayout", RightScroll)
    R_Layout.Padding = UDim.new(0, 10)

    Tabs[tabName] = {Left = LeftScroll, Right = RightScroll, Page = Page}
end

-- 형이 요청한 7대 탭 등록
local TabNames = {"main", "world", "esp", "visuals", "character", "misc", "setting"}
for i, name in ipairs(TabNames) do
    CreateTabPages(name)
end

-- 탭 전환 버튼 스크립트
local function SetupTabButton(name, order)
    local TabBtn = Instance.new("TextButton", TabBar)
    TabBtn.Size = UDim2.new(0, 72, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name:upper()
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.Code
    TabBtn.TextSize = 10
    TabBtn.LayoutOrder = order

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Page.Visible = false end
        for _, b in pairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end
        end
        Tabs[name].Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(255, 0, 50)
    end)
end

for i, name in ipairs(TabNames) do
    SetupTabButton(name, i)
end
Tabs["main"].Page.Visible = true -- 첫 시작은 MAIN 탭 활성화
TabBar:GetChildren()[2].TextColor3 = Color3.fromRGB(255, 0, 50)

-- [[ 6. 버튼 및 슬라이더를 담아줄 섹션 박스 함수 ]]
function _G.AddSection(parent, titleName)
    local SectionFrame = Instance.new("Frame", parent)
    SectionFrame.Size = UDim2.new(1, -5, 0, 150)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    SectionFrame.BorderSizePixel = 1
    SectionFrame.BorderColor3 = Color3.fromRGB(255, 0, 50)
    
    local SecTitle = Instance.new("TextLabel", SectionFrame)
    SecTitle.Size = UDim2.new(1, -10, 0, 18)
    SecTitle.Position = UDim2.new(0, 8, 0, 2)
    SecTitle.BackgroundTransparency = 1
    SecTitle.Text = titleName:lower()
    SecTitle.TextColor3 = Color3.fromRGB(255, 0, 50)
    SecTitle.Font = Enum.Font.Code
    SecTitle.TextSize = 11
    SecTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local Container = Instance.new("Frame", SectionFrame)
    Container.Size = UDim2.new(1, -10, 1, -25)
    Container.Position = UDim2.new(0, 5, 0, 22)
    Container.BackgroundTransparency = 1
    local C_Layout = Instance.new("UIListLayout", Container)
    C_Layout.Padding = UDim.new(0, 4)
    
    return Container
end

-- [[ 7. 온/오프 토글 스위치 뼈대 함수 ]]
function _G.AddToggle(section, text, default, callback)
    local Row = Instance.new("Frame", section)
    Row.Size = UDim2.new(1, 0, 0, 20)
    Row.BackgroundTransparency = 1
    
    local Box = Instance.new("TextButton", Row)
    Box.Size = UDim2.new(0, 12, 0, 12)
    Box.Position = UDim2.new(0, 5, 0.5, -6)
    Box.BorderSizePixel = 1
    Box.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Box.Text = ""
    Box.BackgroundColor3 = default and Color3.fromRGB(255, 0, 50) or Color3.fromRGB(14, 14, 14)
    
    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(1, -25, 1, 0)
    Label.Position = UDim2.new(0, 22, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text:lower()
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local state = default
    Box.MouseButton1Click:Connect(function()
        state = not state
        Box.BackgroundColor3 = state and Color3.fromRGB(255, 0, 50) or Color3.fromRGB(14, 14, 14)
        callback(state)
    end)
end

-- [[ 8. 수치 조절용 슬라이더 뼈대 함수 ]]
function _G.AddSlider(section, text, min, max, default, callback)
    local SliderRow = Instance.new("Frame", section)
    SliderRow.Size = UDim2.new(1, 0, 0, 32)
    SliderRow.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", SliderRow)
    Label.Size = UDim2.new(1, 0, 0, 14)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text:lower()
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel", SliderRow)
    ValueLabel.Size = UDim2.new(1, -10, 0, 14)
    ValueLabel.Position = UDim2.new(0, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = default .. " / " .. max
    ValueLabel.TextColor3 = Color3.fromRGB(255, 0, 50)
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextSize = 11
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("TextButton", SliderRow)
    Track.Size = UDim2.new(1, -10, 0, 10)
    Track.Position = UDim2.new(0, 5, 0, 16)
    Track.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Track.BorderSizePixel = 1
    Track.BorderColor3 = Color3.fromRGB(40, 40, 40)
    Track.Text = ""

    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
    Fill.BorderSizePixel = 0

    local SetValue = function(input)
        local l = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(l, 0, 1, 0)
        local val = math.floor(min + (max - min) * l)
        ValueLabel.Text = val .. " / " .. max
        callback(val)
    end

    local IsDragging = false
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = true; SetValue(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            SetValue(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = false
        end
    end)
end

-- [[ 9. 모바일/PC 통합 UI 숨기기 마스터 버튼 ]]
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Name = "UIToggleButton"
ToggleBtn.Size = UDim2.new(0, 45, 0, 30)
ToggleBtn.Position = UDim2.new(0, 15, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Text = "SOLAR"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11
ToggleBtn.BorderSizePixel = 1
ToggleBtn.BorderColor3 = Color3.fromRGB(255, 0, 50)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 나머지 빈 탭들 에러 방지용 초기 셋업
for _, name in pairs(TabNames) do
    _G.AddSection(Tabs[name].Left, name .. " options")
end

print("[SOLAR BASE] UI Base Loaded! Ready for Functions.")
-- ====================================================================
-- ⚙️ [CHARACTER - CAMERA-ORIENTED FLY ENGINE]
-- ====================================================================

_G.FlyEnabled = false
local FlySpeed = 50

-- 비행 중 위치 유지를 위한 바디 포지션 오브젝트 세팅
local FlyGyro, FlyPosition

table.insert(_G.SolarConnections, RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        local Hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if _G.FlyEnabled and Hum and Hum.Health > 0 then
            local MoveDirection = Vector3.new(0, 0, 0)
            
            -- [1] PC 키보드 입력 방향 연산 (카메라 LookVector 완벽 동기화)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then MoveDirection = MoveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then MoveDirection = MoveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then MoveDirection = MoveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then MoveDirection = MoveDirection + Camera.CFrame.RightVector end
            
            -- [2] 모바일 조이스틱 입력 방향 연산
            -- 모바일 조이스틱을 움직였을 때, 캐릭터 평면 무빙을 카메라가 바라보는 입체 방향(3D Vector)으로 변환합니다.
            if Hum.MoveDirection.Magnitude > 0 then
                local CameraLook = Camera.CFrame.LookVector
                local CameraRight = Camera.CFrame.RightVector
                
                -- 조이스틱의 앞/뒤, 좌/우 입력을 카메라 시선 기준으로 재조합
                local ForwardMove = CameraLook * (Hum.MoveDirection:Dot(Camera.CFrame.LookVector) / CameraLook.Magnitude)
                local SideMove = CameraRight * (Hum.MoveDirection:Dot(Camera.CFrame.RightVector) / CameraRight.Magnitude)
                
                -- 이동 벡터가 비정상적으로 튀는 현상 방지 보정
                if (ForwardMove + SideMove).Magnitude > 0 then
                    MoveDirection = MoveDirection + (ForwardMove + SideMove).Unit
                end
            end
            
            -- [3] 수직 수동 제어 (PC: 스페이스바 / 모바일: 점프 버튼)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or Hum.Jump then 
                MoveDirection = MoveDirection + Vector3.new(0, 1, 0) 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                MoveDirection = MoveDirection - Vector3.new(0, 1, 0) 
            end
            
            -- [4] 실제 좌표 이동 및 물리 제어
            HRP.Velocity = Vector3.new(0, 0, 0) -- 중력 및 관성 제로화
            
            if MoveDirection.Magnitude > 0 then
                -- 이동 중일 때: 시선 방향 벡터로 정밀 이동
                HRP.CFrame = HRP.CFrame + (MoveDirection.Unit * (FlySpeed / 60))
            else
                -- 정지 중일 때 (호버링): 떨어지지 않고 공중에 고정되도록 강제 좌표 록온
                HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + Camera.CFrame.LookVector * Vector3.new(1, 0, 1))
            end
        end
    end
end))

-- 비행 중 벽 통과 및 낙하 대미지 유발 렉 차단 (Noclip 셋업)
table.insert(_G.SolarConnections, RunService.Stepped:Connect(function()
    if _G.FlyEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))


-- ====================================================================
-- 📦 [CHARACTER 탭 마운트 구역]
-- ====================================================================

-- 기존 베이스 반복문이 미리 만들어둔 빈 character options 상자를 깔끔하게 제거
if Tabs["character"] and Tabs["character"].Left then
    for _, child in pairs(Tabs["character"].Left:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end

-- CHARACTER 탭 왼쪽 스크롤뷰에 개선된 방향성 FLY 기능 배치
local CharacterSection = _G.AddSection(Tabs["character"].Left, "character configuration")
_G.AddToggle(CharacterSection, "cross-platform fly", false, function(state) 
    _G.FlyEnabled = state 
end)
_G.AddSlider(CharacterSection, "fly velocity speed", 20, 200, 50, function(val) 
    FlySpeed = val 
end)

-- 레이아웃 스크롤 리사이징 갱신
task.defer(function()
    local scroll = Tabs["character"].Left
    if scroll and scroll:FindFirstChild("UIListLayout") then
        scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y + 20)
    end
end)

print("[SOLAR] 시선 방향 인지형 3D Fly 엔진 패치 완료!")
-- ====================================================================
-- ⚙️ [MISC - SKIN CHANGER RUNNER] (게임 프리징 방지 우회 프로토콜)
-- ====================================================================

local SkinChangerExecuted = false

local function ExecuteSkinChanger()
    if SkinChangerExecuted then 
        print("[SOLAR] Skin Changer가 이미 백엔드에서 구동 중입니다.")
        return 
    end
    
    SkinChangerExecuted = true
    print("[SOLAR] Skin Changer 안전 로딩 시작...")

    -- task.spawn을 사용하여 메인 UI 스레드와 분리된 독립 스레드에서 실행합니다.
    -- 이 방식으로 실행하면 외부 깃허브 코드가 대량의 스킨 데이터를 불러올 때 발생하는 게임 멈춤(Freezing) 현상을 완전히 해결할 수 있습니다.
    task.spawn(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))()
        end)
        
        if success then
            print("[SOLAR] Skin Changer 소스 로드 성공!")
        else
            warn("[SOLAR] Skin Changer 로드 실패 (실행기 환경 확인 필요):", err)
            SkinChangerExecuted = false -- 에러 발생 시 재시도 가능하도록 초기화
        end
    end)
end


-- ====================================================================
-- 📦 [MISC 탭 마운트 구역]
-- ====================================================================

-- 기존 베이스 반복문이 미리 만들어둔 빈 misc options 상자를 깨끗하게 청소
if Tabs["misc"] and Tabs["misc"].Left then
    for _, child in pairs(Tabs["misc"].Left:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end

-- MISC 탭 왼쪽 스크롤뷰에 진짜 SKIN CHANGER 섹션 생성
local MiscSection = _G.AddSection(Tabs["misc"].Left, "utility configuration")

-- 토글이 켜지는 순간 프리징 방지 코드가 적용된 깃허브 스크립트가 로드됩니다.
_G.AddToggle(MiscSection, "skin changer (unlock all)", false, function(state)
    if state then
        ExecuteSkinChanger()
    end
end)

-- 레이아웃 스크롤 리사이징 자동 갱신
task.defer(function()
    local scroll = Tabs["misc"].Left
    if scroll and scroll:FindFirstChild("UIListLayout") then
        scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y + 20)
    end
end)

print("[SOLAR] MISC 탭에 멈춤 방지형 Skin Changer 연동 완료!")
-- ====================================================================
-- [최종 통합 엔진: 60줄 원본 로직 + 헤드샷 전용]
-- ====================================================================

-- 1. [형이 준 원본 60줄 로직]
local replicated_storage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local camera = workspace.CurrentCamera;
local utility = require(replicated_storage.Modules.Utility);

local get_players = function()
    local entities = {};
    for _, child in workspace:GetChildren() do
        if child:FindFirstChildOfClass("Humanoid") then
            table.insert(entities, child);
        elseif child.Name == "HurtEffect" then
            for _, hurt_player in child:GetChildren() do
                if (hurt_player.ClassName ~= "Highlight") then
                    table.insert(entities, hurt_player);
                end
            end
        end
    end
    return entities
end
local get_closest_player = function()
    local closest, closest_distance = nil, math.huge;
    local character = players.LocalPlayer.Character;
    if (character == nil) then return; end
    for _, player in get_players() do
        if (player == players.LocalPlayer) then continue; end
        if (not player:FindFirstChild("HumanoidRootPart")) then continue; end
        local position, on_screen = camera:WorldToViewportPoint(player.HumanoidRootPart.Position);
        if (on_screen == false) then continue; end
        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
        local distance = (center - Vector2.new(position.X, position.Y)).Magnitude;
        if (distance > closest_distance) then continue; end
        closest = player;
        closest_distance = distance;
    end
    return closest;
end

-- 2. [헤드샷 전용으로 수정된 Raycast]
local old = utility.Raycast; 
utility.Raycast = function(...)
    local arguments = {...};
    -- 헤드 고정 로직: 999번 식별자일 때만 헤드로 좌표 강제 교체
    if _G.SilentEnabled and (#arguments > 0 and arguments[4] == 999) then
        local closest = get_closest_player();
        if (closest and closest:FindFirstChild("Head")) then
            -- [수정] 몸통이 아닌 무조건 머리 좌표로 고정
            arguments[3] = closest.Head.CFrame.Position; 
        end
    end
    return old(table.unpack(arguments));
end

-- 3. [기능 및 UI 통합 (나머지 기능들)]
_G.SilentEnabled = false; _G.Wallbang = false; _G.AutoShoot = false; _G.AutoFarm = false;

-- Wallbang 로직: 레이캐스트의 4번째 인자(필터)를 없애 벽 통과
local oldRaycast = utility.Raycast
utility.Raycast = function(...)
    local args = {...}
    if _G.Wallbang and #args > 0 and args[4] == 999 then args[4] = nil end
    return oldRaycast(unpack(args))
end

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.AutoShoot then
        local target = get_closest_player()
        if target and players.LocalPlayer.Character and players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
            players.LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
        end
    end
    if _G.AutoFarm and players.LocalPlayer.Character then
        local target = get_closest_player()
        if target and target:FindFirstChild("Head") then
            players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Head.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

task.spawn(function()
    repeat task.wait(0.5) until Tabs and Tabs["main"]
    local M = _G.AddSection(Tabs["main"].Left, "Combat")
    _G.AddToggle(M, "Silent Aim", false, function(s) _G.SilentEnabled = s end)
    _G.AddToggle(M, "Wallbang", false, function(s) _G.Wallbang = s end)
    _G.AddToggle(M, "Auto Shoot", false, function(s) _G.AutoShoot = s end)
    _G.AddToggle(M, "Auto Farm", false, function(s) _G.AutoFarm = s end)
end)
-- ====================================================================
-- 👁️ [ESP 탭 - 버그 수정판: 실시간 2D BOX ESP (단일 루프 최적화)]
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

_G.BoxEspEnabled = false

-- 1. 기존에 엉뚱하게 띄워진 ESP 레이어 싹 다 청소
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("SOLAR_ESP_LAYER") then
    CoreGui.SOLAR_ESP_LAYER:Destroy()
end

-- 2. 완벽한 2D 좌표를 위한 새 도화지 생성 (상단바 여백 무시 설정 필수)
local EspFolder = Instance.new("ScreenGui")
EspFolder.Name = "SOLAR_ESP_LAYER"
EspFolder.IgnoreGuiInset = true -- [핵심] 이거 없으면 모바일에서 좌표 어긋남
EspFolder.Parent = CoreGui

-- 3. ESP 실시간 추적 메인 엔진 (루프 하나로 전체 통제)
local function UpdateESP()
    local cam = workspace.CurrentCamera
    if not cam then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local boxName = player.Name .. "_Box"
            local boxFrame = EspFolder:FindFirstChild(boxName)

            -- 플레이어가 살아있고 ESP가 켜져있을 때만 추적
            if _G.BoxEspEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                
                -- 박스가 없으면 생성 (속이 텅 빈 빨간 테두리)
                if not boxFrame then
                    boxFrame = Instance.new("Frame")
                    boxFrame.Name = boxName
                    boxFrame.BackgroundTransparency = 1
                    boxFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                    
                    local stroke = Instance.new("UIStroke")
                    stroke.Thickness = 1.5
                    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    stroke.Color = Color3.fromRGB(255, 0, 50) -- 솔라 시그니처 레드
                    
                    -- 팀 구별
                    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                        stroke.Color = Color3.fromRGB(0, 255, 100)
                    end
                    
                    stroke.Parent = boxFrame
                    boxFrame.Parent = EspFolder
                end

                local hrp = player.Character.HumanoidRootPart
                local head = player.Character:FindFirstChild("Head")

                if head and hrp then
                    -- 3D -> 2D 화면 좌표로 완벽 변환
                    local rootPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                    if onScreen then
                        -- 머리부터 발끝까지의 길이를 계산해서 박스 크기를 실시간 조절
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height * 0.6 -- 캐릭터 가로 비율

                        boxFrame.Size = UDim2.new(0, width, 0, height)
                        boxFrame.Position = UDim2.new(0, rootPos.X, 0, rootPos.Y)
                        boxFrame.Visible = true
                    else
                        boxFrame.Visible = false -- 화면 밖으로 벗어나면 숨김
                    end
                end
            else
                -- 죽었거나 ESP 끄면 박스 숨김
                if boxFrame then
                    boxFrame.Visible = false
                end
            end
        end
    end
end

-- 초당 60번씩 화면 갱신할 때마다 ESP 좌표 업데이트 (절대 안 멈춤)
if _G.EspRenderLoop then _G.EspRenderLoop:Disconnect() end
_G.EspRenderLoop = RunService.RenderStepped:Connect(UpdateESP)


-- [[ ESP 탭 구역 마운트 및 UI 토글 주입 ]]
task.spawn(function()
    repeat task.wait(0.1) until Tabs and Tabs["esp"] and Tabs["esp"].Left
    
    for _, child in pairs(Tabs["esp"].Left:GetChildren()) do
        if child:IsA("Frame") and child.Name:lower():find("options") then
            child:Destroy()
        end
    end
    
    local EspSection = _G.AddSection(Tabs["esp"].Left, "visual esp options")
    
    _G.AddToggle(EspSection, "enemy box esp", false, function(state)
        _G.BoxEspEnabled = state
        if not state then
            -- 끄면 찌꺼기 박스들 전부 안 보이게 초기화
            for _, child in pairs(EspFolder:GetChildren()) do
                child.Visible = false
            end
        end
    end)

    local scroll = Tabs["esp"].Left
    if scroll and scroll:FindFirstChild("UIListLayout") then
        scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y + 30)
    end
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function applyHighlightAndHealth(character, player)
    -- 내 캐릭터는 제외
    if player == LocalPlayer then return end

    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoidRootPart or not humanoid then return end

    -- 중복 생성 방지를 위한 기존 UI 제거
    if character:FindFirstChild("SOLAR_Highlight") then character.SOLAR_Highlight:Destroy() end
    if humanoidRootPart:FindFirstChild("SOLAR_HealthUI") then humanoidRootPart.SOLAR_HealthUI:Destroy() end

    -- ==========================================
    -- 1. Highlight (캐릭터 색칠) 기능
    -- ==========================================
    local highlight = Instance.new("Highlight")
    highlight.Name = "SOLAR_Highlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(0, 0, 255)       -- 몸통 파란색
    highlight.FillTransparency = 0.6                      -- 반투명
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)      -- 테두리 검은색
    highlight.OutlineTransparency = 0                     
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- 벽 뚫고 보이기
    highlight.Parent = character

    -- ==========================================
    -- 2. 체력바 (옆에 붙는 게이지 + 숫자) 기능
    -- ==========================================
    local healthBillboard = Instance.new("BillboardGui")
    healthBillboard.Name = "SOLAR_HealthUI"
    healthBillboard.AlwaysOnTop = true
    healthBillboard.Size = UDim2.new(0, 80, 0, 60)
    healthBillboard.StudsOffset = Vector3.new(-1.4, 0, 0) -- 캐릭터 왼쪽으로 위치 조정
    healthBillboard.Adornee = humanoidRootPart

    -- 체력바 배경 (검은색 테두리 역할)
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(0, 5, 0, 50)
    healthBarBg.Position = UDim2.new(1, -8, 0.5, -25)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = healthBillboard

    -- 실시간 체력 게이지 (초록색 실선)
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    healthBar.BorderSizePixel = 0
    healthBar.AnchorPoint = Vector2.new(0, 1) -- 아래에서 위로 차오르게 설정
    healthBar.Position = UDim2.new(0, 0, 1, 0)
    healthBar.Parent = healthBarBg

    -- 체력 숫자 (HP 라벨)
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(0, 50, 0, 20)
    hpLabel.Position = UDim2.new(1, -62, 0.5, -10)
    hpLabel.BackgroundTransparency = 1
    hpLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    hpLabel.TextStrokeTransparency = 0
    hpLabel.TextSize = 12
    hpLabel.Font = Enum.Font.SourceSansBold
    hpLabel.TextXAlignment = Enum.TextXAlignment.Right
    hpLabel.Parent = healthBillboard
    
    healthBillboard.Parent = humanoidRootPart

    -- ==========================================
    -- 3. 실시간 동기화 루프 (체력 변동 감지)
    -- ==========================================
    local connection
    connection = RunService.RenderStepped:Connect(function()
        -- 캐릭터가 죽거나 사라지면 UI 지우고 루프 종료
        if not character:IsDescendantOf(workspace) or humanoid.Health <= 0 then
            highlight:Destroy()
            healthBillboard:Destroy()
            connection:Disconnect()
            return
        end

        -- 실시간 체력 계산 및 UI 업데이트
        local currentHP = math.floor(humanoid.Health)
        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        
        hpLabel.Text = tostring(currentHP)
        healthBar.Size = UDim2.new(1, 0, healthRatio, 0)
        
        -- 체력 상태에 따라 색상 변경 (피가 반 이하면 빨간색으로)
        if healthRatio > 0.5 then
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            hpLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            hpLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
end

-- 게임 내 모든 플레이어에게 적용하는 함수
local function setupPlayer(player)
    if player.Character then 
        applyHighlightAndHealth(player.Character, player) 
    end
    player.CharacterAdded:Connect(function(char)
        applyHighlightAndHealth(char, player)
    end)
end

-- 이미 있는 플레이어들 적용 & 새로 들어오는 플레이어 감지
for _, player in ipairs(Players:GetPlayers()) do 
    setupPlayer(player) 
end
Players.PlayerAdded:Connect(setupPlayer)
-- ====================================================================
-- 🔫 RAPID FIRE INTEGRATION (MAIN - COMBAT)
-- ====================================================================
task.spawn(function()
    -- UI 로드 대기
    repeat task.wait(0.5) until Tabs and Tabs["main"] and Tabs["main"].Left

    -- Combat 섹션 찾기 또는 생성
    local CombatSection = nil
    for _, child in pairs(Tabs["main"].Left:GetChildren()) do
        if child:IsA("Frame") and child:FindFirstChildOfClass("TextLabel") then
            if string.find(string.lower(child:FindFirstChildOfClass("TextLabel").Text), "combat") then
                CombatSection = child:FindFirstChildOfClass("Frame")
                break
            end
        end
    end
    
    if not CombatSection then
        CombatSection = _G.AddSection(Tabs["main"].Left, "Combat")
    end

    -- 토글 생성
    _G.AddToggle(CombatSection, "Rapid Fire", false, function(state)
        if state then
            -- 형이 준 코드 그대로 실행
            local Storage = game:GetService("ReplicatedStorage")
            local Items = require(Storage.Modules.ItemLibrary).Items

            for name, data in pairs(Items) do
                if typeof(data) == "table" then
                    if data.ShootCooldown then data.ShootCooldown = 0.001 end
                    if data.ShootBurstCooldown then data.ShootBurstCooldown = 0.001 end
                end
            end
        end
    end)
end)
local RageBotMode = "gun"
local RageBotEnabled = false
local EmoteEnabled = false
local CurrentCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local function anim2track(asset_id)
    local objs = game:GetObjects(asset_id)
    for i = 1, #objs do
        if objs[i]:IsA("Animation") then
            return objs[i].AnimationId
        end
    end
    return assetid
end

local animid = "92281817840531"
local speed = 99999
if not animid:find("rbxassetid://") then
    animid = "rbxassetid://" .. animid
end
animid = anim2track(animid)

local animation = Instance.new("Animation")
animation.AnimationId = animid

local function playAnim(character)
    if not EmoteEnabled then return end
    local Hum = character:FindFirstChildWhichIsA("Humanoid")
    if not Hum then return end
    for _, track in next, Hum:GetPlayingAnimationTracks() do
        track:Stop()
    end
    local anim = Hum:LoadAnimation(animation)
    anim.Priority = Enum.AnimationPriority.Action4
    anim:Play()
    anim:AdjustSpeed(speed)
    anim.Stopped:Connect(function()
        if EmoteEnabled then
            playAnim(character)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    CurrentCharacter = character
    character:WaitForChild("Humanoid")
    if EmoteEnabled then
        playAnim(character)
    end
end)

local function RunRageBotEngine()
    if getgenv().__s9t0u1 then
        pcall(function() getgenv().__s9t0u1:Shutdown() end)
    end
    
    if not RageBotEnabled then return end

    if RageBotMode == "gun" then
        local __a1b2c3 = setmetatable({}, {
            __index = function(__d4e5f6, __g7h8i9)
                local __j0k1l2, __m3n4o5 = pcall(function()
                    return game:GetService(__g7h8i9)
                end)
                if __m3n4o5 then
                    return cloneref(__m3n4o5)
                end
                return nil
            end
        })

        local __p6q7r8 = getgenv()
        if __p6q7r8.__s9t0u1 then
            __p6q7r8.__s9t0u1:Shutdown()
        end

        local __v2w3x4 = __a1b2c3.Players
        local __y5z6a7 = __a1b2c3.RunService
        local __b8c9d0 = __a1b2c3.ReplicatedStorage
        local __e1f2g3 = __a1b2c3.Workspace
        local __h4i5j6 = __a1b2c3.UserInputService
        local __k7l8m9 = __v2w3x4.LocalPlayer
        local __n0o1p2 = __e1f2g3.CurrentCamera
        local __q3r4s5 = __k7l8m9.PlayerScripts
        local __t6u7v8 = require(__q3r4s5.Modules.ItemTypes.Gun)
        local __w9x0y1 = require(__b8c9d0.Modules.Utility)

        local __z2a3b4 = setmetatable({}, {
            __index = function(_, __c5d6e7)
                local __f8g9h0 = __k7l8m9.Character
                if not __f8g9h0 then return nil end
                if __c5d6e7 == "__root" then
                    return __f8g9h0:FindFirstChild("HumanoidRootPart")
                elseif __c5d6e7 == "__head" then
                    return __f8g9h0:FindFirstChild("Head")
                end
                return nil
            end
        })

        __p6q7r8.__s9t0u1 = {}

        do
            local __i1j2k3 = __p6q7r8.__s9t0u1

            function __i1j2k3:__init()
                self.__active = true
                self.__target = nil
                self.__desync = false
                self.__conn1 = nil
                self.__conn2 = nil
                self.__task1 = nil
                self.__oldfunc = nil
                self:__setup()
            end

            function __i1j2k3:__setup()
                self.__conn1 = __y5z6a7.Heartbeat:Connect(function()
                    if not self.__active then return end
                    self.__target = self:__find()
                end)

                local __l4m5n6 = __t6u7v8.StartShooting
                self.__oldfunc = __l4m5n6
                __t6u7v8.StartShooting = function(__o7p8q9, ...)
                    local __r0s1t2 = {__l4m5n6(__o7p8q9, ...)}
                    if not __o7p8q9.ClientFighter or not __o7p8q9.ClientFighter.IsLocalPlayer then
                        return unpack(__r0s1t2)
                    end

                    local __u3v4w5 = __r0s1t2[3]
                    if not __u3v4w5 or typeof(__u3v4w5) ~= "table" then
                        return unpack(__r0s1t2)
                    end

                    __r0s1t2[4] = true
                    local __x6y7z8 = self.__target

                    if not self.__active or not __x6y7z8 or not __x6y7z8.Character then
                        return unpack(__r0s1t2)
                    end

                    if not self.__desync or self.__curr ~= __x6y7z8 then
                        self:__desync_start(__x6y7z8)
                        task.wait(0.1)
                    end

                    if self.__task1 then
                        task.cancel(self.__task1)
                        self.__task1 = nil
                    end

                    local __a9b0c1 = __x6y7z8.Character:FindFirstChild("Head")
                    if not __a9b0c1 then return unpack(__r0s1t2) end

                    local __d2e3f4 = __a9b0c1.Position
                    local __g5h6i7 = __a9b0c1.CFrame
                    local __j8k9l0 = __d2e3f4 - Vector3.new(0, 5, 0)
                    local __m1n2o3 = CFrame.lookAt(__j8k9l0, __d2e3f4)
                    local __p4q5r6 = __g5h6i7:ToObjectSpace(CFrame.new(__d2e3f4 + Vector3.new(math.random(), math.random(), math.random())))

                    __u3v4w5[utf8.char(0)] = __w9x0y1:EncodeCFrame(CFrame.new(__j8k9l0, __d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
                    __u3v4w5[utf8.char(1)] = __w9x0y1:EncodeCFrame(CFrame.new(__d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
                    __u3v4w5[utf8.char(2)] = __a9b0c1
                    __u3v4w5[utf8.char(3)] = __w9x0y1:EncodeCFrame(__p4q5r6)

                    self.__task1 = task.delay(0.15, function()
                        self:__desync_stop()
                    end)

                    return unpack(__r0s1t2)
                end
            end

            function __i1j2k3:__find()
                local myChar = __k7l8m9.Character
                if not myChar then return nil end
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then return nil end
               
                local closest = nil
                local closestDist = math.huge
                local MAX_DISTANCE = 99999999

                for _, player in next, __v2w3x4:GetPlayers() do
                    if player == __k7l8m9 then continue end
                    if player:GetAttribute("TeamID") == __k7l8m9:GetAttribute("TeamID") then continue end
                   
                    local char = player.Character
                    if not char then continue end

                    local root = char:FindFirstChild("HumanoidRootPart")
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildWhichIsA("Humanoid")
                    
                    if not (root and head and hum and hum.Health > 0) then continue end
                   
                    local dist = (myRoot.Position - root.Position).Magnitude
                    
                    if dist > MAX_DISTANCE then continue end
                    
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
                
                return closest
            end

            function __i1j2k3:__desync_start(__c3d4e5)
                if self.__conn2 then self.__conn2:Disconnect() end
                self.__desync = true
                self.__curr = __c3d4e5

                self.__conn2 = __y5z6a7.Heartbeat:Connect(function()
                    if not self.__desync then return end
                    local __f6g7h8 = __z2a3b4.__root
                    if not __f6g7h8 then return end

                    local __i9j0k1 = __c3d4e5.Character and __c3d4e5.Character:FindFirstChild("HumanoidRootPart")
                    if not __i9j0k1 then
                        self:__desync_stop()
                        return
                    end

                    local __l2m3n4 = __f6g7h8.CFrame
                    local __o5p6q7 = __f6g7h8.Velocity
                    local __r8s9t0 = __f6g7h8.RotVelocity

                    __f6g7h8.CFrame = __i9j0k1.CFrame * CFrame.new(0, -5, 0)

                    __y5z6a7:BindToRenderStep("__restore", 101, function()
                        __f6g7h8.CFrame = __l2m3n4
                        __f6g7h8.Velocity = __o5p6q7
                        __f6g7h8.RotVelocity = __r8s9t0
                        __y5z6a7:UnbindFromRenderStep("__restore")
                    end)
                end)
            end

            function __i1j2k3:__desync_stop()
                self.__desync = false
                self.__curr = nil
                if self.__conn2 then
                    self.__conn2:Disconnect()
                    self.__conn2 = nil
                end
            end

            function __i1j2k3:Shutdown()
                self.__active = false
                if self.__conn1 then self.__conn1:Disconnect() end
                if self.__conn2 then self.__conn2:Disconnect() end
                if self.__task1 then task.cancel(self.__task1) end
                if self.__oldfunc then
                    __t6u7v8.StartShooting = self.__oldfunc
                end
            end

            __i1j2k3:__init()
        end

    elseif RageBotMode == "melee" then
        local __a1b2c3 = setmetatable({}, {
            __index = function(__d4e5f6, __g7h8i9)
                local __j0k1l2, __m3n4o5 = pcall(function()
                    return game:GetService(__g7h8i9)
                end)
                if __m3n4o5 then
                    return cloneref(__m3n4o5)
                end
                return nil
            end
        })

        local __p6q7r8 = getgenv()
        if __p6q7r8.__s9t0u1 then
            __p6q7r8.__s9t0u1:Shutdown()
        end

        local __v2w3x4 = __a1b2c3.Players
        local __y5z6a7 = __a1b2c3.RunService
        local __b8c9d0 = __a1b2c3.ReplicatedStorage
        local __e1f2g3 = __a1b2c3.Workspace
        local __h4i5j6 = __a1b2c3.UserInputService
        local __k7l8m9 = __v2w3x4.LocalPlayer
        local __n0o1p2 = __e1f2g3.CurrentCamera
        local __q3r4s5 = __k7l8m9.PlayerScripts
        local __t6u7v8 = require(__q3r4s5.Modules.ItemTypes.Gun)
        local __w9x0y1 = require(__b8c9d0.Modules.Utility)

        local __z2a3b4 = setmetatable({}, {
            __index = function(_, __c5d6e7)
                local __f8g9h0 = __k7l8m9.Character
                if not __f8g9h0 then return nil end
                if __c5d6e7 == "__root" then
                    return __f8g9h0:FindFirstChild("HumanoidRootPart")
                elseif __c5d6e7 == "__head" then
                    return __f8g9h0:FindFirstChild("Head")
                end
                return nil
            end
        })

        __p6q7r8.__s9t0u1 = {}

        do
            local __i1j2k3 = __p6q7r8.__s9t0u1

            function __i1j2k3:__init()
                self.__active = true
                self.__target = nil
                self.__desync = false
                self.__conn1 = nil
                self.__conn2 = nil
                self.__task1 = nil
                self.__oldfunc = nil
                self.__oldMeleeFuncs = {}
                self:__setup()
            end

            function __i1j2k3:__setup()
                self.__conn1 = __y5z6a7.Heartbeat:Connect(function()
                    if not self.__active then return end
                    self.__target = self:__find()
                end)

                local __l4m5n6 = __t6u7v8.StartShooting
                self.__oldfunc = __l4m5n6
                __t6u7v8.StartShooting = function(__o7p8q9, ...)
                    local __r0s1t2 = {__l4m5n6(__o7p8q9, ...)}
                    if not __o7p8q9.ClientFighter or not __o7p8q9.ClientFighter.IsLocalPlayer then
                        return unpack(__r0s1t2)
                    end

                    local __u3v4w5 = __r0s1t2[3]
                    if not __u3v4w5 or typeof(__u3v4w5) ~= "table" then
                        return unpack(__r0s1t2)
                    end

                    __r0s1t2[4] = true
                    local __x6y7z8 = self.__target

                    if not self.__active or not __x6y7z8 or not __x6y7z8.Character then
                        return unpack(__r0s1t2)
                    end

                    if not self.__desync or self.__curr ~= __x6y7z8 then
                        self:__desync_start(__x6y7z8)
                        task.wait(0.1)
                    end

                    if self.__task1 then
                        task.cancel(self.__task1)
                        self.__task1 = nil
                    end

                    local __a9b0c1 = __x6y7z8.Character:FindFirstChild("Head")
                    if not __a9b0c1 then return unpack(__r0s1t2) end

                    local __d2e3f4 = __a9b0c1.Position
                    local __g5h6i7 = __a9b0c1.CFrame
                    local __j8k9l0 = __d2e3f4 - Vector3.new(0, 5, 0)
                    local __m1n2o3 = CFrame.lookAt(__j8k9l0, __d2e3f4)
                    local __p4q5r6 = __g5h6i7:ToObjectSpace(CFrame.new(__d2e3f4 + Vector3.new(math.random(), math.random(), math.random())))

                    __u3v4w5[utf8.char(0)] = __w9x0y1:EncodeCFrame(CFrame.new(__j8k9l0, __d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
                    __u3v4w5[utf8.char(1)] = __w9x0y1:EncodeCFrame(CFrame.new(__d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
                    __u3v4w5[utf8.char(2)] = __a9b0c1
                    __u3v4w5[utf8.char(3)] = __w9x0y1:EncodeCFrame(__p4q5r6)

                    self.__task1 = task.delay(0.15, function()
                        self:__desync_stop()
                    end)

                    return unpack(__r0s1t2)
                end

                for _, child in ipairs(__q3r4s5.Modules.ItemTypes:GetChildren()) do
                    if child:IsA("ModuleScript") and child.Name ~= "Gun" then
                        local success, mod = pcall(require, child)
                        if success and typeof(mod) == "table" then
                            local targetMethods = {"StartShooting", "Swing", "Attack", "Slash", "Activate", "Fire"}
                            for _, methodName in ipairs(targetMethods) do
                                local oldFunc = mod[methodName]
                                if typeof(oldFunc) == "function" then
                                    table.insert(self.__oldMeleeFuncs, {mod = mod, name = methodName, func = oldFunc})
                                    
                                    mod[methodName] = function(__o7p8q9, ...)
                                        if typeof(__o7p8q9) == "table" and __o7p8q9.ClientFighter and not __o7p8q9.ClientFighter.IsLocalPlayer then
                                            return oldFunc(__o7p8q9, ...)
                                        end

                                        local __x6y7z8 = self.__target
                                        if self.__active and __x6y7z8 and __x6y7z8.Character then
                                            if not self.__desync or self.__curr ~= __x6y7z8 then
                                                self:__desync_start(__x6y7z8)
                                            end

                                            if self.__task1 then
                                                task.cancel(self.__task1)
                                                self.__task1 = nil
                                            end

                                            self.__task1 = task.delay(0.15, function()
                                                self:__desync_stop()
                                            end)
                                        end

                                        return oldFunc(__o7p8q9, ...)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            function __i1j2k3:__find()
                local myChar = __k7l8m9.Character
                if not myChar then return nil end
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then return nil end
               
                local closest = nil
                local closestDist = math.huge
                local MAX_DISTANCE = 99999999

                for _, player in next, __v2w3x4:GetPlayers() do
                    if player == __k7l8m9 then continue end
                    if player:GetAttribute("TeamID") == __k7l8m9:GetAttribute("TeamID") then continue end
                   
                    local char = player.Character
                    if not char then continue end

                    local root = char:FindFirstChild("HumanoidRootPart")
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildWhichIsA("Humanoid")
                    
                    if not (root and head and hum and hum.Health > 0) then continue end
                   
                    local dist = (myRoot.Position - root.Position).Magnitude
                    
                    if dist > MAX_DISTANCE then continue end
                    
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
                
                return closest
            end

            function __i1j2k3:__desync_start(__c3d4e5)
                if self.__conn2 then self.__conn2:Disconnect() end
                self.__desync = true
                self.__curr = __c3d4e5

                self.__conn2 = __y5z6a7.Heartbeat:Connect(function()
                    if not self.__desync then return end
                    local __f6g7h8 = __z2a3b4.__root
                    if not __f6g7h8 then return end

                    local __i9j0k1 = __c3d4e5.Character and __c3d4e5.Character:FindFirstChild("HumanoidRootPart")
                    if not __i9j0k1 then
                        self:__desync_stop()
                        return
                    end

                    local __l2m3n4 = __f6g7h8.CFrame
                    local __o5p6q7 = __f6g7h8.Velocity
                    local __r8s9t0 = __f6g7h8.RotVelocity

                    __f6g7h8.CFrame = __i9j0k1.CFrame * CFrame.new(0, -5, 0)

                    __y5z6a7:BindToRenderStep("__restore", 101, function()
                        __f6g7h8.CFrame = __l2m3n4
                        __f6g7h8.Velocity = __o5p6q7
                        __f6g7h8.RotVelocity = __r8s9t0
                        __y5z6a7:UnbindFromRenderStep("__restore")
                    end)
                end)
            end

            function __i1j2k3:__desync_stop()
                self.__desync = false
                self.__curr = nil
                if self.__conn2 then
                    self.__conn2:Disconnect()
                    self.__conn2 = nil
                end
            end

            function __i1j2k3:Shutdown()
                self.__active = false
                if self.__conn1 then self.__conn1:Disconnect() end
                if self.__conn2 then self.__conn2:Disconnect() end
                if self.__task1 then task.cancel(self.__task1) end
                if self.__oldfunc then
                    __t6u7v8.StartShooting = self.__oldfunc
                end
                if self.__oldMeleeFuncs then
                    for _, data in ipairs(self.__oldMeleeFuncs) do
                        pcall(function()
                            data.mod[data.name] = data.func
                        end)
                    end
                end
            end

            __i1j2k3:__init()
        end
    end
end

task.spawn(function()
    repeat task.wait(0.1) until Tabs and Tabs["misc"] and Tabs["misc"].Left
    
    local MiscPageScroll = Tabs["misc"].Left
    local RageBotSection = _G.AddSection(MiscPageScroll, "rage bot")
    
    _G.AddToggle(RageBotSection, "rage bot switch", false, function(state)
        RageBotEnabled = state
        RunRageBotEngine()
    end)
    
    _G.AddToggle(RageBotSection, "attack type: gun (off = melee)", true, function(state)
        if state then
            RageBotMode = "gun"
        else
            RageBotMode = "melee"
        end
        if RageBotEnabled then
            RunRageBotEngine()
        end
    end)

    _G.AddToggle(RageBotSection, "emote", false, function(state)
        EmoteEnabled = state
        if state then
            if CurrentCharacter then
                playAnim(CurrentCharacter)
            end
        else
            if CurrentCharacter and CurrentCharacter:FindFirstChildWhichIsA("Humanoid") then
                for _, track in next, CurrentCharacter:FindFirstChildWhichIsA("Humanoid"):GetPlayingAnimationTracks() do
                    track:Stop()
                end
            end
        end
    end)

    if MiscPageScroll:FindFirstChild("UIListLayout") then
        MiscPageScroll.CanvasSize = UDim2.new(0, 0, 0, MiscPageScroll.UIListLayout.AbsoluteContentSize.Y + 20)
    end
end)

-- ==================== ARCADE SECTION (MISC 탭에 추가) ====================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Utility = require(ReplicatedStorage.Modules.Utility)

-- ==================== SETTINGS ====================
local autoHealth = true
local autoAmmo = true
local autoRespawn = true
local arcadeRageBot = true

-- ==================== ANTI VOID ====================
Workspace.FallenPartsDestroyHeight = -math.huge

local function ProtectCharacter(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.HealthChanged:Connect(function(hp)
            if hp <= 0 then
                hum.Health = 100
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame += Vector3.new(0, 150, 0) end
            end
        end)
    end
end

if LocalPlayer.Character then ProtectCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(ProtectCharacter)

-- ==================== AUTO RESPAWN ====================
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if not autoRespawn then return end
        task.spawn(function()
            while autoRespawn do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    break
                end
                keypress(0x20)
                task.wait(0.1)
                keyrelease(0x20)
                task.wait(0.1)
            end
        end)
    end)
end)

-- ==================== ARCADE RAGE BOT ====================
local target = nil

RunService.Heartbeat:Connect(function()
    if not arcadeRageBot then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local closest, minDist = nil, math.huge
    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer then continue end
        local tTeam = plr:GetAttribute("TeamID")
        local mTeam = LocalPlayer:GetAttribute("TeamID")
        if tTeam and mTeam and tTeam == mTeam then continue end

        local char = plr.Character
        if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (myRoot.Position - char.HumanoidRootPart.Position).Magnitude
                if dist < minDist and dist <= 99999999999 then
                    minDist = dist
                    closest = plr
                end
            end
        end
    end
    target = closest
end)

-- Silent Aim (모든 무기)
local weapons = {"Gun", "Slingshot", "Bow", "Daggers"}
for _, name in ipairs(weapons) do
    pcall(function()
        local mod = require(LocalPlayer.PlayerScripts.Modules.ItemTypes[name])
        local old = mod.StartShooting or mod.Fire
        if old then
            mod.StartShooting = function(obj, ...)
                local args = {old(obj, ...)}
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    local head = target.Character.Head
                    local packet = args[3] or args[2]
                    if packet and typeof(packet) == "table" then
                        local pos = head.Position
                        packet[utf8.char(0)] = Utility:EncodeCFrame(CFrame.new(pos - Vector3.new(0, 3.5, 0), pos))
                        packet[utf8.char(2)] = head
                    end
                end
                return unpack(args)
            end
        end
    end)
end

-- 상대 머리 위 지속 텔레포
RunService.Heartbeat:Connect(function()
    if not arcadeRageBot then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local old = root.CFrame

    if target and target.Character and target.Character:FindFirstChild("Head") then
        root.CFrame = target.Character.Head.CFrame * CFrame.new(0, 7, 0)
    else
        root.CFrame = root.CFrame * CFrame.new(math.random(-25,25), math.random(-10,20), math.random(-25,25))
    end

    RunService:BindToRenderStep("ArcadeRestore", 101, function()
        root.CFrame = old
        RunService:UnbindFromRenderStep("ArcadeRestore")
    end)
end)

-- ==================== AUTO HEALTH + AUTO AMMO ====================
local t = 0
RunService.RenderStepped:Connect(function(dt)
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    t = t + dt * 8
    local bounce = math.sin(t) * 4

    for _, obj in workspace:GetChildren() do
        if obj.Name == "_drop" and obj:IsA("BasePart") then
            if (autoAmmo and obj:FindFirstChild("Ammo")) or (autoHealth and obj:FindFirstChild("Health")) then
                obj.Anchored = true
                obj.CFrame = CFrame.new(hrp.Position + Vector3.new(0, bounce, 0))
                obj.Transparency = 1
                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("MeshPart") or child:IsA("SpecialMesh") then
                        pcall(function() child.Transparency = 1 end)
                    end
                    if child:IsA("BillboardGui") or child:IsA("SurfaceGui") or child:IsA("ParticleEmitter") or child:IsA("SelectionBox") then
                        pcall(function() child.Enabled = false end)
                    end
                end
            end
        end
    end
end)

-- ==================== MISC 탭에 ARCADE 섹션 추가 ====================
task.spawn(function()
    repeat task.wait(0.3) until Tabs and Tabs["misc"] and Tabs["misc"].Left

    local ArcadeSection = _G.AddSection(Tabs["misc"].Left, "arcade")

    _G.AddToggle(ArcadeSection, "arcade rage bot", true, function(state)
        arcadeRageBot = state
    end)

    _G.AddToggle(ArcadeSection, "auto health", true, function(state)
        autoHealth = state
    end)

    _G.AddToggle(ArcadeSection, "auto ammo", true, function(state)
        autoAmmo = state
    end)

    _G.AddToggle(ArcadeSection, "auto respawn", true, function(state)
        autoRespawn = state
    end)

    -- 레이아웃 갱신
    local scroll = Tabs["misc"].Left
    if scroll and scroll:FindFirstChild("UIListLayout") then
        scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y + 30)
    end
end)

print("✅ ARCADE SECTION (4개 기능) MISC 탭에 추가 완료")
task.spawn(function()
    repeat task.wait(0.1) until Tabs and Tabs["misc"] and Tabs["misc"].Right

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local SetControlsRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Replication"):WaitForChild("Fighter"):WaitForChild("SetControls")

    local function spoofDevice(wantedDevice)
        SetControlsRemote:FireServer("MouseKeyboard")
        task.wait(0.3)
        SetControlsRemote:FireServer(wantedDevice)
    end

    local DeviceSection = _G.AddSection(Tabs["misc"].Right, "device changer")

    local SelectedDevice = "MouseKeyboard"
    local DeviceDropdown = Instance.new("TextButton", DeviceSection)
    DeviceDropdown.Size = UDim2.new(1, -10, 0, 28)
    DeviceDropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    DeviceDropdown.BorderSizePixel = 1
    DeviceDropdown.BorderColor3 = Color3.fromRGB(40, 40, 40)
    DeviceDropdown.Text = "▼ Current: Mouse & Keyboard"
    DeviceDropdown.TextColor3 = Color3.fromRGB(180, 180, 180)
    DeviceDropdown.Font = Enum.Font.Code
    DeviceDropdown.TextSize = 11
    DeviceDropdown.TextXAlignment = Enum.TextXAlignment.Left

    local DropList = Instance.new("Frame", DeviceSection)
    DropList.Size = UDim2.new(1, -10, 0, 0)
    DropList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DropList.BorderSizePixel = 1
    DropList.BorderColor3 = Color3.fromRGB(40, 40, 40)
    DropList.Visible = false
    DropList.ClipsDescendants = true

    local DropLayout = Instance.new("UIListLayout", DropList)
    DropLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function createDropItem(displayName, deviceValue)
        local item = Instance.new("TextButton", DropList)
        item.Size = UDim2.new(1, 0, 0, 26)
        item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        item.BorderSizePixel = 0
        item.Text = displayName
        item.TextColor3 = Color3.fromRGB(200, 200, 200)
        item.Font = Enum.Font.Code
        item.TextSize = 11
        item.TextXAlignment = Enum.TextXAlignment.Left

        item.MouseButton1Click:Connect(function()
            SelectedDevice = deviceValue
            DeviceDropdown.Text = "▼ Current: " .. displayName
            DropList.Visible = false
            spoofDevice(deviceValue)
            DeviceDropdown.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
            task.wait(0.2)
            DeviceDropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        end)

        return item
    end

    local items = {
        createDropItem("Mouse & Keyboard", "MouseKeyboard"),
        createDropItem("Gamepad", "Gamepad"),
        createDropItem("Touch (Mobile)", "Touch"),
        createDropItem("VR", "VR")
    }

    local listHeight = #items * 26
    DropList.Size = UDim2.new(1, -10, 0, listHeight)

    DeviceDropdown.MouseButton1Click:Connect(function()
        DropList.Visible = not DropList.Visible
    end)

    if DeviceSection:IsA("Frame") then
        DeviceSection.Size = UDim2.new(1, -5, 0, 160)
    end

    local scroll = Tabs["misc"].Right
    if scroll and scroll:FindFirstChild("UIListLayout") then
        scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y + 40)
    end
end)
repeat task.wait(1) until game:IsLoaded() and Tabs and Tabs["setting"]

if not Tabs or not Tabs["setting"] then
    print("[Config] Waiting for UI...")
    repeat task.wait(1) until Tabs and Tabs["setting"]
end

print("[Config] Loading...")

local ConfigScroll = Tabs["setting"].Right

for _, child in ipairs(ConfigScroll:GetChildren()) do
    if child:IsA("Frame") then
        local label = child:FindFirstChildOfClass("TextLabel")
        if label and label.Text and label.Text:lower() == "config" then
            child:Destroy()
        end
    end
end

local ConfigSection = Instance.new("Frame")
ConfigSection.Size = UDim2.new(1, -5, 0, 380)
ConfigSection.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ConfigSection.BorderSizePixel = 1
ConfigSection.BorderColor3 = Color3.fromRGB(255, 0, 50)
ConfigSection.Parent = ConfigScroll

local SecTitle = Instance.new("TextLabel")
SecTitle.Size = UDim2.new(1, -10, 0, 18)
SecTitle.Position = UDim2.new(0, 8, 0, 2)
SecTitle.BackgroundTransparency = 1
SecTitle.Text = "config"
SecTitle.TextColor3 = Color3.fromRGB(255, 0, 50)
SecTitle.Font = Enum.Font.Code
SecTitle.TextSize = 11
SecTitle.TextXAlignment = Enum.TextXAlignment.Left
SecTitle.Parent = ConfigSection

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -10, 1, -25)
Container.Position = UDim2.new(0, 5, 0, 22)
Container.BackgroundTransparency = 1
Container.Parent = ConfigSection

local C_Layout = Instance.new("UIListLayout")
C_Layout.Padding = UDim.new(0, 4)
C_Layout.Parent = Container

local ConfigNameBox = Instance.new("TextBox")
ConfigNameBox.Size = UDim2.new(1, 0, 0, 30)
ConfigNameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ConfigNameBox.BorderSizePixel = 0
ConfigNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigNameBox.TextSize = 14
ConfigNameBox.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
ConfigNameBox.PlaceholderText = "Config Name..."
ConfigNameBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
ConfigNameBox.TextXAlignment = Enum.TextXAlignment.Center
ConfigNameBox.ClearTextOnFocus = false
ConfigNameBox.Parent = Container

local ConfigCorner = Instance.new("UICorner")
ConfigCorner.CornerRadius = UDim.new(0, 6)
ConfigCorner.Parent = ConfigNameBox

local ConfigSaveBtn = Instance.new("TextButton")
ConfigSaveBtn.Size = UDim2.new(1, 0, 0, 30)
ConfigSaveBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
ConfigSaveBtn.BorderSizePixel = 0
ConfigSaveBtn.Text = "Save Config"
ConfigSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigSaveBtn.TextSize = 14
ConfigSaveBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
ConfigSaveBtn.AutoButtonColor = false
ConfigSaveBtn.Parent = Container

local ConfigSaveCorner = Instance.new("UICorner")
ConfigSaveCorner.CornerRadius = UDim.new(0, 6)
ConfigSaveCorner.Parent = ConfigSaveBtn

local ConfigListFrame = Instance.new("Frame")
ConfigListFrame.Size = UDim2.new(1, 0, 0, 120)
ConfigListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ConfigListFrame.BackgroundTransparency = 0.5
ConfigListFrame.BorderSizePixel = 0
ConfigListFrame.Parent = Container

local ConfigListCorner = Instance.new("UICorner")
ConfigListCorner.CornerRadius = UDim.new(0, 6)
ConfigListCorner.Parent = ConfigListFrame

local ConfigListLayout = Instance.new("UIListLayout")
ConfigListLayout.Padding = UDim.new(0, 4)
ConfigListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConfigListLayout.Parent = ConfigListFrame

local ConfigLoadBtn = Instance.new("TextButton")
ConfigLoadBtn.Size = UDim2.new(1, 0, 0, 28)
ConfigLoadBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
ConfigLoadBtn.BorderSizePixel = 0
ConfigLoadBtn.Text = "Load Selected Config"
ConfigLoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigLoadBtn.TextSize = 13
ConfigLoadBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
ConfigLoadBtn.AutoButtonColor = false
ConfigLoadBtn.Parent = Container

local ConfigLoadCorner = Instance.new("UICorner")
ConfigLoadCorner.CornerRadius = UDim.new(0, 6)
ConfigLoadCorner.Parent = ConfigLoadBtn

local ConfigDeleteBtn = Instance.new("TextButton")
ConfigDeleteBtn.Size = UDim2.new(1, 0, 0, 28)
ConfigDeleteBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
ConfigDeleteBtn.BorderSizePixel = 0
ConfigDeleteBtn.Text = "Delete Selected Config"
ConfigDeleteBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
ConfigDeleteBtn.TextSize = 13
ConfigDeleteBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
ConfigDeleteBtn.AutoButtonColor = false
ConfigDeleteBtn.Parent = Container

local ConfigDeleteCorner = Instance.new("UICorner")
ConfigDeleteCorner.CornerRadius = UDim.new(0, 6)
ConfigDeleteCorner.Parent = ConfigDeleteBtn

local ConfigAutoLabel = Instance.new("TextLabel")
ConfigAutoLabel.Size = UDim2.new(1, 0, 0, 18)
ConfigAutoLabel.BackgroundTransparency = 1
ConfigAutoLabel.Text = "Auto Load: None"
ConfigAutoLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
ConfigAutoLabel.TextSize = 12
ConfigAutoLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
ConfigAutoLabel.TextXAlignment = Enum.TextXAlignment.Center
ConfigAutoLabel.Parent = Container

local ConfigAutoBtn = Instance.new("TextButton")
ConfigAutoBtn.Size = UDim2.new(1, 0, 0, 28)
ConfigAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
ConfigAutoBtn.BorderSizePixel = 0
ConfigAutoBtn.Text = "Set Auto Load"
ConfigAutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigAutoBtn.TextSize = 13
ConfigAutoBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
ConfigAutoBtn.AutoButtonColor = false
ConfigAutoBtn.Parent = Container

local ConfigAutoCorner = Instance.new("UICorner")
ConfigAutoCorner.CornerRadius = UDim.new(0, 6)
ConfigAutoCorner.Parent = ConfigAutoBtn

local ConfigCancelAutoBtn = Instance.new("TextButton")
ConfigCancelAutoBtn.Size = UDim2.new(1, 0, 0, 28)
ConfigCancelAutoBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
ConfigCancelAutoBtn.BorderSizePixel = 0
ConfigCancelAutoBtn.Text = "Cancel Auto Load"
ConfigCancelAutoBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
ConfigCancelAutoBtn.TextSize = 13
ConfigCancelAutoBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
ConfigCancelAutoBtn.AutoButtonColor = false
ConfigCancelAutoBtn.Parent = Container

local ConfigCancelCorner = Instance.new("UICorner")
ConfigCancelCorner.CornerRadius = UDim.new(0, 6)
ConfigCancelCorner.Parent = ConfigCancelAutoBtn

local Configs = {}
local SelectedConfig = nil
local AutoLoadConfig = nil
local ConfigFolder = "SOLARHub/Configs"

if not isfolder(ConfigFolder) then
    makefolder(ConfigFolder)
end

local function GetConfigPath(name)
    return ConfigFolder .. "/" .. name .. ".json"
end

local function GetAllConfigs()
    local result = {}
    if isfolder(ConfigFolder) then
        for _, file in ipairs(listfiles(ConfigFolder)) do
            local name = file:match("([^/]+)%.json$")
            if name then
                table.insert(result, name)
            end
        end
    end
    return result
end

local function GetAllSettings()
    local settings = {}
    
    for key, toggle in pairs(Toggles or {}) do
        local val = nil
        if toggle.GetValue then
            val = toggle:GetValue()
        elseif toggle.Value ~= nil then
            val = toggle.Value
        elseif toggle._value ~= nil then
            val = toggle._value
        end
        settings[key] = {type = "Toggle", value = val}
    end
    
    for key, option in pairs(Options or {}) do
        local val = nil
        if option.GetValue then
            val = option:GetValue()
        elseif option.Value ~= nil then
            val = option.Value
        elseif option._value ~= nil then
            val = option._value
        end
        
        if type(val) == "table" then
            settings[key] = {type = "Dropdown", value = val}
        elseif type(val) == "number" then
            settings[key] = {type = "Slider", value = val}
        elseif type(val) == "string" then
            settings[key] = {type = "Dropdown", value = val}
        else
            settings[key] = {type = "Input", value = val}
        end
    end
    
    return settings
end

local function LoadAllSettings(data)
    for key, setting in pairs(data) do
        local obj = Toggles[key] or Options[key]
        if obj and obj.SetValue then
            obj:SetValue(setting.value)
        end
    end
end

local function RefreshConfigList()
    for _, child in ipairs(ConfigListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    Configs = GetAllConfigs()
    local LayoutOrder = 0

    for _, name in ipairs(Configs) do
        LayoutOrder = LayoutOrder + 1
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 24)
        btn.Position = UDim2.new(0, 5, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 220)
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
        btn.AutoButtonColor = false
        btn.LayoutOrder = LayoutOrder
        btn.Parent = ConfigListFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn

        if name == SelectedConfig then
            btn.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
            btn.BackgroundTransparency = 0.3
        end

        btn.MouseButton1Click:Connect(function()
            SelectedConfig = name
            for _, child in ipairs(ConfigListFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                    child.BackgroundTransparency = 0.5
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
            btn.BackgroundTransparency = 0.3
        end)

        btn.MouseEnter:Connect(function()
            if btn.BackgroundTransparency > 0.3 then
                btn.BackgroundTransparency = 0.3
            end
        end)

        btn.MouseLeave:Connect(function()
            if SelectedConfig ~= name then
                btn.BackgroundTransparency = 0.5
            end
        end)
    end
end

ConfigSaveBtn.MouseButton1Click:Connect(function()
    local name = ConfigNameBox.Text:gsub("%s+", "_")
    if name == "" or name == "Config_Name..." then
        return
    end

    local path = GetConfigPath(name)
    local data = GetAllSettings()
    data._config_name = name
    data._timestamp = os.time()
    data._version = "1.0"

    local success, err = pcall(function()
        writefile(path, game:GetService("HttpService"):JSONEncode(data))
    end)

    if success then
        ConfigNameBox.Text = ""
        RefreshConfigList()
    end
end)

ConfigLoadBtn.MouseButton1Click:Connect(function()
    if not SelectedConfig then
        return
    end

    local path = GetConfigPath(SelectedConfig)
    if not isfile(path) then
        RefreshConfigList()
        return
    end

    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(path))
    end)

    if success and data then
        LoadAllSettings(data)
    end
end)

ConfigDeleteBtn.MouseButton1Click:Connect(function()
    if not SelectedConfig then
        return
    end

    local path = GetConfigPath(SelectedConfig)
    if not isfile(path) then
        RefreshConfigList()
        return
    end

    local success, err = pcall(function()
        delfile(path)
    end)

    if success then
        if AutoLoadConfig == SelectedConfig then
            AutoLoadConfig = nil
            ConfigAutoLabel.Text = "Auto Load: None"
            ConfigAutoLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
            if isfile(ConfigFolder .. "/autoload.txt") then
                delfile(ConfigFolder .. "/autoload.txt")
            end
        end
        SelectedConfig = nil
        RefreshConfigList()
    end
end)

ConfigAutoBtn.MouseButton1Click:Connect(function()
    if not SelectedConfig then
        return
    end

    AutoLoadConfig = SelectedConfig
    ConfigAutoLabel.Text = "Auto Load: " .. AutoLoadConfig
    ConfigAutoLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    writefile(ConfigFolder .. "/autoload.txt", AutoLoadConfig)
end)

ConfigCancelAutoBtn.MouseButton1Click:Connect(function()
    AutoLoadConfig = nil
    ConfigAutoLabel.Text = "Auto Load: None"
    ConfigAutoLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    if isfile(ConfigFolder .. "/autoload.txt") then
        delfile(ConfigFolder .. "/autoload.txt")
    end
end)

if isfile(ConfigFolder .. "/autoload.txt") then
    local name = readfile(ConfigFolder .. "/autoload.txt")
    if name ~= "" and isfile(GetConfigPath(name)) then
        AutoLoadConfig = name
        ConfigAutoLabel.Text = "Auto Load: " .. name
        ConfigAutoLabel.TextColor3 = Color3.fromRGB(100, 255, 150)

        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(GetConfigPath(name)))
        end)

        if success and data then
            LoadAllSettings(data)
        end
    else
        ConfigAutoLabel.Text = "Auto Load: None"
        ConfigAutoLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    end
end

RefreshConfigList()

if ConfigScroll and ConfigScroll:FindFirstChild("UIListLayout") then
    ConfigScroll.CanvasSize = UDim2.new(0, 0, 0, ConfigScroll.UIListLayout.AbsoluteContentSize.Y + 30)
end

print("[Config] Loaded!")
