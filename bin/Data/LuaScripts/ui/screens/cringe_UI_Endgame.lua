local uiManager = require("LuaScripts/ui/UI_Manager")

---@class UiEndgame : UiScreen
local Ui = {}

Ui.screenName = "Endgame"

local ughSfxNames = {
    "Sounds/cringe/sfx_grunt_v1.ogg",
    "Sounds/cringe/sfx_grunt_v2.ogg",
    "Sounds/cringe/sfx_grunt_v3.ogg",
    "Sounds/cringe/sfx_grunt_v4.ogg",
    "Sounds/cringe/sfx_grunt_v5.ogg",
  }

--- links actions to buttons and etc. Usually, should be run only once
---@param instanceRoot UIElement
Ui.Setup = function (instanceRoot)

    local buttonPlay = instanceRoot:GetChild("ButtonPlay", true)
    SubscribeToEvent(buttonPlay, "Released", function ()
        instanceRoot:SetVisible(false)
        uiManager.ShowUI("Loading")
    end)

end

---@param instanceRoot UIElement
---@param dataPassed EndGameScreenData
Ui.Show = function (instanceRoot, dataPassed)

    StopMusic()

    PlayOneShotSound(ughSfxNames[RandomInt(1, #ughSfxNames + 1)], 1.25)

    instanceRoot:SetVisible(true)

    local deadPic = instanceRoot:GetChild("dead", true)
    deadPic:SetVisible(not dataPassed.hasWon)

    local winnerTxt = instanceRoot:GetChild("winner", true)
    winnerTxt:SetVisible(dataPassed.hasWon)
end

return Ui