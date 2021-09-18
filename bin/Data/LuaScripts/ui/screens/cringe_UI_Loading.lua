local uiManager = require("LuaScripts/ui/UI_Manager")

---@class UiLoading: UiScreen
local Ui = {}

Ui.screenName = "Loading"

local printSfxNames = {
    "Sounds/cringe/sfx_text_v1.ogg",
    "Sounds/cringe/sfx_text_v2.ogg",
    "Sounds/cringe/sfx_text_v3.ogg",
  }

local cringeBank = {
    "Revisão: Informação Desnecessária 2021 blablabla",
    "Carregando carregando bliblibli",
    "tuts tuts quero ver",
    "bom era na minha época",
    "me jogue aos lobos e voltarei liderando a matilha",
    "o que importa é o quanto você aguenta apanhar e continuar levantando",
    "não confunda meu silencio com fraqueza",
    "meu calar com aceitação minha bondade com fraqueza ou minha",
    "sinceridade com arrogancia.",
    "com as pedras que atirarem em mim construirei meu castelo.",
    "tá pegando fogo bicho!",
    "AEEEEEEEEE CASSINAO",
    "Antonio Nunes!",
    "Resiliencia",
    "Frigideira anti aderente",
    "quebrou minha mesa!",
    "Máquina Agricola!",
    "Uno com escada",
    "como que é ser um ator global",
    "pagar boleto!",
    "HUEHUEAHUEHUEHUE",
    "Você traiu o movimento cara",
    "No céu tem pão?",
    "BIRRRRL Hora do Show!",
    "Não Consegue né?",
    "Resized scratch buffer to size sei nao mano",
    "Subescrevi, está no capítulo 1",
    "2 em 2 horas não deixo pra depois",
    "apenas que busque conhecimento",
    "beba cola caco babe cola",
    "HACKEADO",
    "EU SEI SEU IP",
    "Intro minecraft dubstep ear rape",
    "mó cringe slk",
    "existem dois lobos dentro de vc",
    "Acumulando patrimônio: mais de 8000",
    "Uma vez perguntaram a um ancião:",
    "É claro que foste o vencedor! Eu abdico.",
    "14"
}

---@type UIElement
local textsContainer = nil
local cachedInstanceRoot = nil

local textColor = Color:new(0.7, 1.0, 0.7, 1.0)

--- links actions to buttons and etc. Usually, should be run only once
---@param instanceRoot UIElement
Ui.Setup = function (instanceRoot)
    cachedInstanceRoot = instanceRoot
    textsContainer = instanceRoot:GetChild("bg", true)

end

Ui.AddRandomText = function ()
    ---@type Text
    local randomTextElement = Text:new()

    local randomText = cringeBank[RandomInt(1, #cringeBank + 1)];
    randomTextElement:SetStyleAuto()

    textsContainer:AddChild(randomTextElement)

    randomTextElement.text = randomText
    randomTextElement:SetFontSize(30)
    randomTextElement:SetColor(textColor)

    PlayOneShotSound(printSfxNames[RandomInt(1, #printSfxNames + 1)], 0.3)
end

Ui.LoadingDone = function ()
    cachedInstanceRoot:SetVisible(false)

    log:Write(LOG_DEBUG, "start now!")
    Scene_.updateEnabled = true
    StartMusic()
end

---@param instanceRoot UIElement
---@param dataPassed table
Ui.Show = function (instanceRoot, dataPassed)
    instanceRoot:SetVisible(true)

    textsContainer:RemoveAllChildren()
    Ui.AddRandomText()

    SetupGameMatch()
end

return Ui