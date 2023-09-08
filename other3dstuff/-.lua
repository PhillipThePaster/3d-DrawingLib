-- Services
local RunService = game:GetService("RunService");
local PlayersService = game:GetService("Players");

local LocalPlayer = PlayersService.LocalPlayer
local Camera = workspace.CurrentCamera;
local Lines = {};

local function HasCharacter(Player)
    return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart");
end;

local function IsSameTeam(Player)
    if Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then
        return true
    end
    return false
end

local function DrawLine(From, To, color, transparency)
    local FromScreen, FromVisible = Camera:WorldToViewportPoint(From);
    local ToScreen, ToVisible = Camera:WorldToViewportPoint(To);
    if (not FromVisible and not ToVisible) then return; end;
    local FromPos = Vector2.new(FromScreen.X, FromScreen.Y);
    local ToPos = Vector2.new(ToScreen.X, ToScreen.Y);
    local Line = Drawing.new("Line");
    Line.Thickness = espsets.Thickness;
    Line.From = FromPos
    Line.To = ToPos
    Line.Color = color or Color3.fromRGB(255, 255, 255);
    Line.Transparency = transparency or espsets.Transparency;
    Line.ZIndex = 1;
    Line.Visible = true;

    table.insert(Lines, Line)
end

local function GetCorners(Part)
    local CF, Size, Corners = Part.CFrame, Part.Size / 2, {};
    for X = -1, 1, 2 do
        for Y = -1, 1, 2 do
            for Z = -1, 1, 2 do
                Corners[#Corners + 1] = (CF * CFrame.new(Size * Vector3.new(X, Y, Z))).Position;
            end;
        end;
    end;
    return Corners;
end;

local function DrawEsp(Player, transparency)
    if Player ~= LocalPlayer and (not espsets.teamCheck or (espsets.teamCheck and not IsSameTeam(Player))) then
        local HRP = Player.Character.HumanoidRootPart
        local CubeVertices = GetCorners({CFrame = HRP.CFrame * CFrame.new(0, -0.5, 0), Size = Vector3.new(3, 5, 3)})
        local playerColor = espsets.playerColor
        local connections = {
            {1, 2}, {2, 6}, {6, 5}, {5, 1},
            {1, 3}, {2, 4}, {6, 8}, {5, 7},
            {3, 4}, {4, 8}, {8, 7}, {7, 3}
        }
        for _, pair in pairs(connections) do
            DrawLine(CubeVertices[pair[1]], CubeVertices[pair[2]], playerColor, transparency)
        end
    end
end

local function BoxEsp()
    if not espsets.Box then
        for i = 1, #Lines do
            local Line = rawget(Lines, i)
            if Line then
                Line:Remove()
            end
        end
        Lines = {}
        return
    end
    local Players = PlayersService:GetPlayers()
    for i = 1, #Lines do
        local Line = rawget(Lines, i)
        if Line then
            Line:Remove()
        end
    end
    Lines = {}
    for i = 1, #Players do
        local Player = rawget(Players, i)
        if HasCharacter(Player) then
            local HRP = Player.Character.HumanoidRootPart
            if HRP then
                local Distance = (Camera.CFrame.p - HRP.Position).Magnitude
                if Distance <= espsets.distanceLimit then
                    local transparency = espsets.Transparency - (espsets.Transparency * (Distance / espsets.distanceLimit))
                    DrawEsp(Player, transparency)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(BoxEsp)
