
---@class UiDefinition
---@field uiFilePath string
---@field attachedInstance UIElement
local MainMenu = { 
    uiFilePath = "UI/cringe/cringe_screen_title.xml",
    handlerFile = require("LuaScripts/ui/screens/cringe_UI_MainMenu")
 }

---@type UiDefinition[]
local definitions = {
    MainMenu = MainMenu,
    PopupGeneric = { uiFilePath = "UI/cringe/cringe_overlay_popup.xml" },
    PopupInput = {
        uiFilePath = "UI/cringe/cringe_generic_input_overlay.xml",
        handlerFile = require("LuaScripts/ui/screens/cringe_UI_Popup_Input")
    },
    Endgame = { 
        uiFilePath = "UI/cringe/cringe_screen_endgame.xml",
        handlerFile = require("LuaScripts/ui/screens/cringe_UI_Endgame")
    },
    Loading = { 
    uiFilePath = "UI/cringe/cringe_screen_loading.xml",
    handlerFile = require("LuaScripts/ui/screens/cringe_UI_Loading")
    },
}


-- extra emmylua ui-related definitions...

---@class PopupDisplayData
---@field title string
---@field prompt string
---@field buttonInfos PopupButtonInfo[]
local popupDisplayData = {}

---@class InputPopupDisplayData : PopupDisplayData
---@field inputFieldInitialValue string
local inputPopupDisplayData = {}

---@class PopupButtonInfo
---@field buttonText string
---@field buttonAction function
---@field closePopupOnClick boolean
local popupButtonInfo = {}

---@class EndGameScreenData
---@field hasWon boolean
local endGameScreenData = {}


return definitions