if game and not game:IsLoaded() then
    game.Loaded:Wait()
end

local function getService(serviceName)
    if Services[serviceName] then
        return Services[serviceName]
    end
    local success, service = pcall(function()
        return cloneref(game:GetService(serviceName))
    end)
    if success and service then
        Services[serviceName] = service
        return service
    end
    return nil
end

local UserInputService = getService("UserInputService")
local RunService = getService("RunService")
local TweenService = getService("TweenService")
local TextService = getService("TextService")
local CoreGui = getService("CoreGui")

local Players = getService("Players")

local Player
local function getPlayer()
    if Player and Player.Parent then
        return Player
    end
    
    Players = getService("Players")
    Player = Players.LocalPlayer
    
    if not Player then
        Players.PlayerAdded:Wait()
        Player = Players.LocalPlayer
    end
    
    return Player
end

Player = getPlayer()
local PlayerGui = Player:FindFirstChild("PlayerGui")

local NotifGui = Instance.new("ScreenGui")
local Container = Instance.new("Frame")

NotifGui.Name = "AkaliNotif"

Container.Name = "Container"
Container.Position = UDim2.new(0, 20, 0.5, -20)
Container.Size = UDim2.new(0, 300, 0.5, 0)
Container.BackgroundTransparency = 1

NotifGui.Parent = PlayerGui or CoreGui
Container.Parent = NotifGui

local function setParent(instance, parent)
    if typeof(instance) ~= "Instance" then
        error("setParent: element must be a Roblox Instance, got " .. typeof(instance))
    end
    instance.Parent = parent
end

local function Image(ID, Button)
    local NewImage = Instance.new(string.format("Image%s", Button and "Button" or "Label"))
    NewImage.Image = ID
    NewImage.BackgroundTransparency = 1
    return NewImage
end

local function Round2px()
    local NewImage = Image("http://www.roblox.com/asset/?id=5761488251")
    NewImage.ScaleType = Enum.ScaleType.Slice
    NewImage.SliceCenter = Rect.new(2, 2, 298, 298)
    NewImage.ImageColor3 = Color3.fromRGB(12, 4, 20)
    NewImage.ImageTransparency = 0.14
    return NewImage
end

local function Shadow2px()
    local NewImage = Image("http://www.roblox.com/asset/?id=5761498316")
    NewImage.ScaleType = Enum.ScaleType.Slice
    NewImage.SliceCenter = Rect.new(17, 17, 283, 283)
    NewImage.Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30)
    NewImage.Position = UDim2.fromOffset(-15, -15)
    NewImage.ImageColor3 = Color3.fromRGB(26, 26, 26)
    return NewImage
end

local Padding = 10
local DescriptionPadding = 10
local InstructionObjects = {}
local TweenTime = 0.3
local TweenStyle = Enum.EasingStyle.Quad
local TweenDirection = Enum.EasingDirection.Out

local LastTick = tick()

local function CalculateBounds(TableOfObjects)
    local Y = 0
    for _, Object in pairs(TableOfObjects) do
        Y = Y + Object.AbsoluteSize.Y
    end
    return {Y = Y, y = Y}
end

local CachedObjects = {}

local function Update()
    local DeltaTime = tick() - LastTick
    local PreviousObjects = {}
    
    for _, Object in pairs(InstructionObjects) do
        local Label, Delta, Done = Object[1], Object[2], Object[3]
        if not Done then
            if Delta < TweenTime then
                Object[2] = math.clamp(Delta + DeltaTime, 0, 1)
                Delta = Object[2]
            else
                Object[3] = true
            end
        end
        
        local NewValue = TweenService:GetValue(Delta, TweenStyle, TweenDirection)
        local CurrentPos = Label.Position
        local PreviousBounds = CalculateBounds(PreviousObjects)
        local TargetPos = UDim2.new(0, 0, 0, PreviousBounds.Y + (Padding * #PreviousObjects))
        Label.Position = CurrentPos:Lerp(TargetPos, NewValue)
        table.insert(PreviousObjects, Label)
    end
    
    CachedObjects = PreviousObjects
    LastTick = tick()
end

RunService:BindToRenderStep("UpdateList", 0, Update)

local TitleSettings = {
    Font = Enum.Font.GothamSemibold,
    Size = 14,
}

local DescriptionSettings = {
    Font = Enum.Font.Gotham,
    Size = 14,
}

local MaxWidth = Container.AbsoluteSize.X - Padding - DescriptionPadding

local function Label(Text, Font, Size, Button)
    local Label = Instance.new(string.format("Text%s", Button and "Button" or "Label"))
    Label.Text = Text
    Label.Font = Font
    Label.TextSize = Size
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.RichText = true
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    return Label
end

local function TitleLabel(Text)
    return Label(Text, TitleSettings.Font, TitleSettings.Size)
end

local function DescriptionLabel(Text)
    return Label(Text, DescriptionSettings.Font, DescriptionSettings.Size)
end

local PropertyTweenOut = {
    Text = "TextTransparency",
    Fram = "BackgroundTransparency",
    Imag = "ImageTransparency"
}

local function FadeProperty(Object)
    local Prop = PropertyTweenOut[string.sub(Object.ClassName, 1, 4)]
    TweenService:Create(Object, TweenInfo.new(0.2, TweenStyle, TweenDirection), {
        [Prop] = 1
    }):Play()
end

local function SearchTableFor(Table, For)
    for _, v in pairs(Table) do
        if v == For then
            return true
        end
    end
    return false
end

local function FindIndexByDependency(Table, Dependency)
    for Index, Object in pairs(Table) do
        if type(Object) == "table" then
            local Found = SearchTableFor(Object, Dependency)
            if Found then
                return Index
            end
        else
            if Object == Dependency then
                return Index
            end
        end
    end
end

local function ResetObjects()
    for _, Object in pairs(InstructionObjects) do
        Object[2] = 0
        Object[3] = false
    end
end

local function FadeOutAfter(Object, Seconds)
    task.delay(Seconds, function()
        FadeProperty(Object)
        for _, SubObj in pairs(Object:GetDescendants()) do
            FadeProperty(SubObj)
        end
        
        task.delay(0.2, function()
            local index = FindIndexByDependency(InstructionObjects, Object)
            if index then
                table.remove(InstructionObjects, index)
            end
            ResetObjects()
            Object.Visible = false
            task.delay(0.1, function()
                if Object.Parent then
                    Object:Destroy()
                end
            end)
        end)
    end)
end

local function convertToString(arg)
    if type(arg) ~= "string" then
        return tostring(arg)
    end
end

local function convertToNumber(arg)
    if type(arg) ~= "number" then
        return tonumber(arg)
    end
end

local function Notify(Properties)
    Properties = type(Properties) == "table" and Properties or {}
    local Title = Properties.Title or "Notification"
    local Description = Properties.Description or "This is description"
    local Duration = Properties.Duration or 5
    
    Title = convertToString(Title)
    Description = convertToString(Description)
    Duration = convertToNumber(Duration) or 5
    
    task.spawn(function()
        local Y = Title and 26 or 0
        
        if Description then
            local TextSize = TextService:GetTextSize(Description, DescriptionSettings.Size, DescriptionSettings.Font, Vector2.new(MaxWidth, math.huge))
            Y = Y + TextSize.Y + 8
        end

        local NewLabel = Round2px()
        NewLabel.Size = UDim2.new(1, 0, 0, Y)
        NewLabel.Position = UDim2.new(-1, 20, 0, CalculateBounds(CachedObjects).Y + (Padding * #CachedObjects))
        
        if Title then
            local NewTitle = TitleLabel(Title)
            NewTitle.Size = UDim2.new(1, -10, 0, 26)
            NewTitle.Position = UDim2.fromOffset(10, 0)
            setParent(NewTitle, NewLabel)
        end
        
        if Description then
            local NewDescription = DescriptionLabel(Description)
            NewDescription.TextWrapped = true
            NewDescription.Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(-DescriptionPadding, Title and -26 or 0)
            NewDescription.Position = UDim2.fromOffset(10, Title and 26 or 0)
            NewDescription.TextYAlignment = Title and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
            setParent(NewDescription, NewLabel)
        end
        
        setParent(Shadow2px(), NewLabel)
        setParent(NewLabel, Container)
        
        table.insert(InstructionObjects, {NewLabel, 0, false})
        FadeOutAfter(NewLabel, Duration)
    end)
end

local function QuickNotify(message, duration)
    Notify({
        Title = "Info",
        Description = message,
        Duration = duration or 3
    })
end

return {
    Notify,
    QuickNotify,
    NotifGui
}
