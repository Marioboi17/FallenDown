local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MessageGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local messageLabel = Instance.new("TextLabel")
messageLabel.Size = UDim2.new(0.3, 0, 0.05, 0)
messageLabel.Position = UDim2.new(0.35, 0, 0.9, 0)
messageLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
messageLabel.BackgroundTransparency = 0.5
messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
messageLabel.Font = Enum.Font.SourceSansBold
messageLabel.TextSize = 24
messageLabel.Text = ""
messageLabel.Parent = screenGui

local function displayMessage(text, duration)
    messageLabel.Text = text
    task.delay(duration or 3, function()
        if messageLabel.Text == text then
            messageLabel.Text = ""
        end
    end)
end

local success, keyboardOrError = pcall(function()
    return workspace:WaitForChild("Keyboard", 5)
end)

local keyboard = nil
if success and keyboardOrError then
    keyboard = keyboardOrError
    displayMessage("Welcome mate", 5)
else
    displayMessage("Not loaded", 5)
    warn("Keyboard not loaded: ", keyboardOrError)
end

local isPlaying = false
local isLooping = false
local playingThread = nil

local melody = {
    {note = "A4", time = 0.4}, {note = "C5", time = 0.4}, {note = "E5", time = 0.4},
    {note = "D5", time = 0.4}, {note = "C5", time = 0.6}, {note = "A4", time = 0.4},
    {note = "C5", time = 0.4}, {note = "E5", time = 0.4}, {note = "D5", time = 0.4},
    {note = "C5", time = 0.6}, {note = "G4", time = 0.4}, {note = "A4", time = 0.4},
    {note = "B4", time = 0.4}, {note = "C5", time = 0.4}, {note = "D5", time = 0.6},
    {note = "E5", time = 0.6}, {note = "F5", time = 0.3}, {note = "E5", time = 0.3},
    {note = "D5", time = 0.4}, {note = "C5", time = 0.6}, {note = "A4", time = 0.4},
    {note = "C5", time = 0.4}, {note = "E5", time = 0.4}, {note = "D5", time = 0.4},
    {note = "C5", time = 0.6}, {note = "A4", time = 0.4}, {note = "C5", time = 0.4},
    {note = "E5", time = 0.4}, {note = "D5", time = 0.4}, {note = "C5", time = 0.6},
    {note = "G4", time = 0.4}, {note = "A4", time = 0.4}, {note = "B4", time = 0.4},
    {note = "C5", time = 0.4}, {note = "D5", time = 0.6}, {note = "E5", time = 0.6},
    {note = "F5", time = 0.3}, {note = "E5", time = 0.3}, {note = "D5", time = 0.4},
    {note = "C5", time = 0.6},
}

local function pressKey(note)
    if not keyboard then return end
    local key = keyboard:FindFirstChild(note)
    if not key then
        warn("Missing key: " .. note)
        return
    end
    local click = key:FindFirstChildWhichIsA("ClickDetector")
    if click then
        fireclickdetector(click)
    elseif key:FindFirstChildOfClass("Sound") then
        key:FindFirstChildOfClass("Sound"):Play()
    elseif key:FindFirstChild("Activate") then
        key.Activate:Fire()
    end
end

local function playSongLoop()
    while isLooping do
        for _, noteData in ipairs(melody) do
            if not isLooping then break end
            pressKey(noteData.note)
            task.wait(noteData.time)
        end
    end
    isLooping = false
    displayMessage("Loop stopped", 2)
end

local function playSongOnce()
    for _, noteData in ipairs(melody) do
        if not isPlaying then break end
        pressKey(noteData.note)
        task.wait(noteData.time)
    end
    isPlaying = false
    displayMessage("Play once finished", 2)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.F then
        if isLooping then
            isLooping = false
            displayMessage("Loop stopped", 2)
        else
            if isPlaying then
                isPlaying = false -- stop once if running
            end
            if keyboard then
                isLooping = true
                playingThread = task.spawn(playSongLoop)
                displayMessage("Loop started", 2)
            else
                displayMessage("Not loaded", 3)
            end
        end

    elseif input.KeyCode == Enum.KeyCode.G then
        if isPlaying then
            isPlaying = false
            displayMessage("Play once stopped", 2)
        else
            if isLooping then
                isLooping = false -- stop loop if running
            end
            if keyboard then
                isPlaying = true
                playingThread = task.spawn(playSongOnce)
                displayMessage("Play once started", 2)
            else
                displayMessage("Not loaded", 3)
            end
        end
    end
end)
