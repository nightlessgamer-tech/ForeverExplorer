local FE = ForeverExplorer

function FE:BuildUI()
    if self.frame then return end
    local f = CreateFrame("Frame", "ForeverExplorerFrame", UIParent)
    f:SetWidth(540)
    f:SetHeight(430)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    if f.SetResizable then f:SetResizable(true) end
    if f.SetMinResize then f:SetMinResize(460, 340) end
    if f.SetMaxResize then f:SetMaxResize(900, 700) end
    if f.SetBackdrop then
        f:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
        if f.SetBackdropColor then f:SetBackdropColor(0.04, 0.06, 0.09, 0.96) end
    end

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -14)
    title:SetText("Forever Explorer  |cff88ccff0.4.0|r")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    local search = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    search:SetWidth(210)
    search:SetHeight(24)
    search:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -43)
    search:SetAutoFocus(false)
    search:SetText("")
    search:Hide()
    self.searchBox = search
    search:SetScript("OnTextChanged", function()
        if FE.view == "zones" then FE:Refresh() end
    end)

    local body = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -76)
    body:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -18, 62)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    if body.SetNonSpaceWrap then body:SetNonSpaceWrap(true) end
    self.body = body

    local function Button(text, x, width, action)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetWidth(width or 96)
        b:SetHeight(24)
        b:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", x, 18)
        b:SetText(text)
        b:SetScript("OnClick", action)
        return b
    end
    Button("Guide", 18, 78, function() FE:SetView("guide") end)
    Button("Zones", 102, 78, function() FE:SetView("zones") end)
    Button("Précédent", 186, 82, function() FE:SetStepIndex(FE:GetStepIndex() - 1) end)
    Button("Terminé", 274, 78, function()
        if FE.view == "zones" then FE:MarkCurrentZoneDone() else FE:MarkDone() end
    end)
    Button("Suivant", 358, 78, function() FE:SetStepIndex(FE:GetStepIndex() + 1) end)
    Button("Statut", 442, 78, function() FE:ShowStatus() end)

    if f.SetResizable and f.StartSizing then
        local grip = CreateFrame("Button", nil, f)
        grip:SetWidth(16)
        grip:SetHeight(16)
        grip:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3, 3)
        grip:EnableMouse(true)
        grip:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
        grip:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)
    end

    self.frame = f
    self.view = self.view or "guide"
    self:Refresh()
end

function FE:Refresh()
    if not self.body then return end
    local steps = (ForeverExplorerData and ForeverExplorerData.steps) or {}
    local db = ForeverExplorerDB or {}
    db.completed = db.completed or {}
    db.exploredZones = db.exploredZones or {}

    if self.view == "zones" then
        if self.searchBox then self.searchBox:Show() end
        local query = self.searchBox and string.lower(self.searchBox:GetText() or "") or ""
        local zones = (ForeverExplorerData and ForeverExplorerData.zones) or {}
        local lines = { "EXPLORATEUR DES ZONES — ALLIANCE", "Recherche : tape le nom d'une zone. Sélectionne un résultat avec la recherche, puis « Terminé » pour basculer son état.", "" }
        local count, firstMatch = 0, nil
        for _, zone in ipairs(zones) do
            if query == "" or string.find(string.lower(zone.name), query, 1, true) then
                count = count + 1
                if not firstMatch then firstMatch = zone.name end
                local state = db.exploredZones[zone.name] and "|cff55dd88[EXPLORÉE]|r" or "[à explorer]"
                local certainty = zone.uncertain and " — indicatif, à confirmer" or ""
                lines[#lines + 1] = string.format("%s  Niv. %s  %s%s", state, zone.level, zone.name, certainty)
                if zone.note and zone.note ~= "" then lines[#lines + 1] = "   " .. zone.note end
            end
        end
        self.currentZoneName = firstMatch
        if count == 0 then lines[#lines + 1] = "Aucune zone ne correspond à cette recherche." end
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Zones explorées : " .. (function()
            local n = 0
            for _, value in pairs(db.exploredZones) do if value then n = n + 1 end end
            return n
        end)() .. "/" .. #zones
        lines[#lines + 1] = "/fe guide pour revenir au guide"
        self.body:SetText(table.concat(lines, "\n"))
        return
    end

    if self.searchBox then self.searchBox:Hide() end
    local index = self:GetStepIndex()
    local step = steps[index]
    if not step then self.body:SetText("Aucune étape chargée."); return end
    local completed = db.completed[index]
    local lines = {
        string.format("GUIDE DE LEVELING — ALLIANCE\nÉtape %d/%d%s", index, #steps, completed and " — TERMINÉE" or ""),
        "Niveau conseillé : " .. tostring(step.level),
        "Zone : " .. tostring(step.zone),
        "",
        tostring(step.title),
        "",
        tostring(step.detail or ""),
        "",
        "--- Astuces ---"
    }
    for i, tip in ipairs((ForeverExplorerData and ForeverExplorerData.tips) or {}) do
        if i <= 3 then lines[#lines + 1] = "- " .. tip end
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Progression sauvegardée automatiquement par WoW."
    lines[#lines + 1] = "Commandes : /fe next • /fe prev • /fe done • /fe zones • /fe status • /fe reset"
    self.body:SetText(table.concat(lines, "\n"))
end
