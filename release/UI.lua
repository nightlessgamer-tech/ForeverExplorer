local FE = ForeverExplorer

function FE:BuildUI()
    if self.frame then return end
    local f = CreateFrame("Frame", "ForeverExplorerFrame", UIParent)
    f:SetWidth(500)
    f:SetHeight(390)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    f:SetBackdropColor(0.04, 0.06, 0.09, 0.96)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -14)
    title:SetText("Forever Explorer")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    local body = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -48)
    body:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -18, 58)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetNonSpaceWrap(true)
    self.body = body

    local function Button(text, x, action)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetWidth(105); b:SetHeight(24); b:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", x, 18)
        b:SetText(text); b:SetScript("OnClick", action)
        return b
    end
    Button("Précédent", 18, function() FE:SetStepIndex(FE:GetStepIndex() - 1) end)
    Button("Terminé", 132, function() FE:MarkDone() end)
    Button("Suivant", 246, function() FE:SetStepIndex(FE:GetStepIndex() + 1) end)
    Button("Statut", 360, function() FE:ShowStatus() end)

    self.frame = f
    self:Refresh()
end

function FE:Refresh()
    if not self.body then return end
    local steps = (ForeverExplorerData and ForeverExplorerData.steps) or {}
    local index = self:GetStepIndex()
    local step = steps[index]
    if not step then self.body:SetText("Aucune étape chargée."); return end
    local completed = ForeverExplorerDB and ForeverExplorerDB.completed and ForeverExplorerDB.completed[index]
    local text = string.format("Étape %d/%d%s\nNiveau conseillé : %d\nZone : %s\n\n%s\n\n", index, #steps, completed and " — TERMINÉE" or "", step.level, step.zone, step.title)
    text = text .. (step.detail or "")
    text = text .. "\n\n--- Astuces ---\n"
    for i, tip in ipairs((ForeverExplorerData and ForeverExplorerData.tips) or {}) do
        if i <= 3 then text = text .. "• " .. tip .. "\n" end
    end
    text = text .. "\n/fe next • /fe prev • /fe done • /fe status • /fe secrets"
    self.body:SetText(text)
end
