-- handles opening UI setups that should only be created once. Stores UIs that have already been loaded, hidden or not

-- should receive calls like "open splash screen"; then, it should check if the target screen already exists in the cache.
-- If not, it should load it, store it and return it

local CringeUi = {}

CringeUi.StoredUis = {}

-- if necessary, loads, then returns the specified UI. The Ui must have already been added in the StoredUis list
---@param UIname string
---@return UIElement
function CringeUi.GetUI(UIname)
    local targetUi = CringeUi.StoredUis[UIname]
    if targetUi ~= nil then
        if targetUi.attachedInstance ~= nil then
            return targetUi.attachedInstance
        else
            --load the ui and try again
            CringeUi.LoadUI(UIname)
            return CringeUi.GetUI(UIname)
        end
    end
end


---should display the target Ui, optionally using the provided sentData table to customize the ui's actions and elements
---@param UIname string
---@param sentData table
function CringeUi.ShowUI(UIname, sentData)
    Log:Write(LOG_DEBUG, "UIManager: show UI " .. UIname)

    local targetUi = CringeUi.StoredUis[UIname]
    if targetUi ~= nil then
        if targetUi.attachedInstance == nil then
            CringeUi.LoadUI(UIname)
        end
    else
        Log:Write(LOG_WARNING, "UIManager: attempted to show undeclared UI " .. UIname)
    end

    targetUi.handlerFile.Show(CringeUi.GetUI(UIname), sentData)
end


-- loads resources for the specified UI and creates a disabled instance of it.
-- stores the created UI in the attachedInstance var.
-- The Ui must have already been added in the StoredUis list
---@param UIname string
function CringeUi.LoadUI(UIname)
    local targetUi = CringeUi.StoredUis[UIname]
    if targetUi ~= nil then
        if targetUi.attachedInstance ~= nil then
            return targetUi.attachedInstance
        else
            targetUi.attachedInstance = ui:LoadLayout(cache:GetResource("XMLFile", targetUi.uiFilePath))
            if targetUi["isSetup"] ~= true then
                targetUi.handlerFile.Setup(targetUi.attachedInstance)
                targetUi["isSetup"] = true
            end
            ui.root:AddChild(targetUi.attachedInstance)
            targetUi.attachedInstance:SetVisible(false) -- apparently equal to "setactive false" in unity
        end
    end
end


-- sets/overrides stored ui definitions with the ones defined in the provided array
---@param definitionsArr UiDefinition[]
function CringeUi.AddUiDefinitions (definitionsArr)
    for key, value in pairs(definitionsArr) do
        --Log:Write(LOG_INFO, "added definition " .. value.uiFilePath)
        CringeUi.StoredUis[key] = value
    end
end

return CringeUi
