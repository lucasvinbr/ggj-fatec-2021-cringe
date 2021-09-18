--    - Handle Esc key down to hide Console or exit application

local CringeDebug = {}

CringeDebug.drawDebug = false -- Draw debug geometry flag

local function CringeDebugHandleKeyUp(eventType, eventData)
    local key = eventData["Key"]:GetInt()
    -- Close console (if open) or exit when ESC is pressed
    if key == KEY_ESCAPE then
        if console:IsVisible() then
            console:SetVisible(false)
        else
            engine:Exit()
        end
    end
end

local function CringeDebugHandleKeyDown(eventType, eventData)
    local key = eventData["Key"]:GetInt()

    local uiManager = require("LuaScripts/ui/UI_Manager")

    if key == KEY_F1 then
        console:Toggle()
        uiManager.ShowUI("Loading")
    elseif key == KEY_F2 then
        debugHud:ToggleAll()

        ---@type EndGameScreenData
        local endgameData = {}
        endgameData.hasWon = true

        uiManager.ShowUI("Endgame", endgameData)
    elseif key == KEY_F3 then
        CringeDebug.drawDebug = not CringeDebug.drawDebug
        uiManager.ShowUI("MainMenu")
    elseif key == KEY_F5 then
        Scene_:SaveXML(fileSystem:GetProgramDir().."Data/Scenes/cringe.xml")
        ui.root:SaveXML(fileSystem:GetProgramDir().."Data/cringe.xml")
    end

end

function CringeDebug.DebugSetup()

    -- Create console and debug HUD
    CringeDebug.CreateConsoleAndDebugHud()

    -- Subscribe key down event
    SubscribeToEvent("KeyDown", CringeDebugHandleKeyDown)

    -- Subscribe key up event
    SubscribeToEvent("KeyUp", CringeDebugHandleKeyUp)
end

function CringeDebug.CreateConsoleAndDebugHud()
    -- Get default style
    local uiStyle = cache:GetResource("XMLFile", "UI/DefaultStyle.xml")
    if uiStyle == nil then
        return
    end

    -- Create console
    engine:CreateConsole()
    console.defaultStyle = uiStyle
    console.background.opacity = 0.8

    -- Create debug HUD
    engine:CreateDebugHud()
    debugHud.defaultStyle = uiStyle
end



return CringeDebug
