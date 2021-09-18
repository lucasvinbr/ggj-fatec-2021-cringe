local uiManager = require("LuaScripts/ui/UI_Manager")

---@class UiScreen
local Ui = {}

Ui.screenName = "MainMenu"

--- links actions to buttons and etc. Usually, should be run only once
---@param instanceRoot UIElement
Ui.Setup = function (instanceRoot)

    local buttonPlay = instanceRoot:GetChild("ButtonPlay", true)

    SubscribeToEvent(buttonPlay, "Released", function ()
        instanceRoot:SetVisible(false)
        uiManager.ShowUI("Loading")
    end)

    local buttonQuit = instanceRoot:GetChild("ButtonQuit", true)
    SubscribeToEvent(buttonQuit, "Released", function ()
        engine:Exit()
    end)

end

---@param instanceRoot UIElement
---@param dataPassed table
Ui.Show = function (instanceRoot, dataPassed)
    instanceRoot:SetVisible(true)
end

return Ui