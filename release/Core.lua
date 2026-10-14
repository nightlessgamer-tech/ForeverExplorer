local addonName = ...
ForeverExplorer = ForeverExplorer or {}
local FE = ForeverExplorer

local function Print(msg)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff55ccffForever Explorer:|r " .. tostring(msg))
    end
end

local function GetSteps()
    return (ForeverExplorerData and ForeverExplorerData.steps) or {}
end

local function GetZones()
    return (ForeverExplorerData and ForeverExplorerData.zones) or {}
end

local function EnsureDB()
    ForeverExplorerDB = ForeverExplorerDB or {}
    ForeverExplorerDB.completed = ForeverExplorerDB.completed or {}
    ForeverExplorerDB.exploredZones = ForeverExplorerDB.exploredZones or {}
    if not ForeverExplorerDB.stepIndex then ForeverExplorerDB.stepIndex = 1 end
    return ForeverExplorerDB
end

function FE:GetStepIndex()
    local steps = GetSteps()
    if #steps == 0 then return 1 end
    local level = UnitLevel("player") or 1
    local chosen = 1
    for i, step in ipairs(steps) do
        if step.level <= level then chosen = i end
    end
    local db = EnsureDB()
    if db.stepIndex then chosen = math.max(1, math.min(#steps, db.stepIndex)) end
    return math.max(1, math.min(#steps, chosen))
end

function FE:SetStepIndex(index)
    local steps = GetSteps()
    if #steps == 0 then return end
    local db = EnsureDB()
    db.stepIndex = math.max(1, math.min(#steps, tonumber(index) or 1))
    if FE.Refresh then FE:Refresh() end
end

function FE:MarkDone()
    local steps = GetSteps()
    if #steps == 0 then return end
    local index = self:GetStepIndex()
    local db = EnsureDB()
    db.completed[index] = true
    Print("Étape terminée : " .. (steps[index] and steps[index].title or index))
    self:SetStepIndex(math.min(#steps, index + 1))
end

function FE:MarkCurrentZoneDone()
    local name = self.currentZoneName
    if not name or name == "" then
        Print("Recherche une zone, puis utilise « Zone faite ».")
        return
    end
    local db = EnsureDB()
    db.exploredZones[name] = not db.exploredZones[name]
    Print(name .. (db.exploredZones[name] and " marquée comme explorée." or " retirée des zones explorées."))
    if self.Refresh then self:Refresh() end
end

function FE:ResetProgress()
    local db = EnsureDB()
    db.completed = {}
    db.exploredZones = {}
    db.stepIndex = 1
    Print("Progression réinitialisée.")
    if self.Refresh then self:Refresh() end
end

function FE:ShowStatus()
    local steps = GetSteps()
    local zones = GetZones()
    local db = EnsureDB()
    local doneSteps, doneZones = 0, 0
    for _, value in pairs(db.completed) do if value then doneSteps = doneSteps + 1 end end
    for _, value in pairs(db.exploredZones) do if value then doneZones = doneZones + 1 end end
    Print("Niveau " .. tostring(UnitLevel("player") or "?") .. " — étapes " .. doneSteps .. "/" .. #steps .. ", zones explorées " .. doneZones .. "/" .. #zones .. ".")
end

function FE:Show()
    if self.frame then self.frame:Show() end
    if self.Refresh then self:Refresh() end
end

function FE:SetView(view)
    self.view = view == "zones" and "zones" or "guide"
    if self.Refresh then self:Refresh() end
end

SLASH_FOREVEREXPLORER1 = "/fe"
SlashCmdList["FOREVEREXPLORER"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "next" then
        FE:SetStepIndex(FE:GetStepIndex() + 1)
    elseif msg == "prev" then
        FE:SetStepIndex(FE:GetStepIndex() - 1)
    elseif msg == "done" then
        FE:MarkDone()
    elseif msg == "status" then
        FE:ShowStatus()
    elseif msg == "zones" then
        FE:SetView("zones")
        FE:Show()
    elseif msg == "guide" then
        FE:SetView("guide")
        FE:Show()
    elseif msg == "reset" then
        FE:ResetProgress()
    elseif msg == "secrets" then
        local items = (ForeverExplorerData and ForeverExplorerData.secrets) or {}
        Print("Secrets / exploration :")
        for _, item in ipairs(items) do Print("- " .. item.name .. ": " .. item.note) end
    else
        FE:Show()
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    EnsureDB()
    if FE.BuildUI then FE:BuildUI() end
    Print("version 0.4.0 chargée. /fe ouvre le guide, /fe zones ouvre l'explorateur, /fe reset réinitialise la progression.")
end)
