local addonName = ...
ForeverExplorer = ForeverExplorer or {}
local FE = ForeverExplorer

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff55ccffForever Explorer:|r " .. tostring(msg))
end

local function GetSteps()
    return (ForeverExplorerData and ForeverExplorerData.steps) or {}
end

function FE:GetStepIndex()
    local steps = GetSteps()
    local level = UnitLevel("player") or 1
    local chosen = 1
    for i, step in ipairs(steps) do
        if step.level <= level then chosen = i end
    end
    if ForeverExplorerDB and ForeverExplorerDB.stepIndex then
        chosen = math.max(1, math.min(#steps, ForeverExplorerDB.stepIndex))
    end
    return math.max(1, math.min(#steps, chosen))
end

function FE:SetStepIndex(index)
    local steps = GetSteps()
    if #steps == 0 then return end
    ForeverExplorerDB = ForeverExplorerDB or {}
    ForeverExplorerDB.stepIndex = math.max(1, math.min(#steps, index))
    if FE.Refresh then FE:Refresh() end
end

function FE:MarkDone()
    local steps = GetSteps()
    local index = self:GetStepIndex()
    ForeverExplorerDB = ForeverExplorerDB or {}
    ForeverExplorerDB.completed = ForeverExplorerDB.completed or {}
    ForeverExplorerDB.completed[index] = true
    Print("Étape terminée : " .. (steps[index] and steps[index].title or index))
    self:SetStepIndex(math.min(#steps, index + 1))
end

function FE:ShowStatus()
    local steps = GetSteps()
    local done = 0
    for _, value in pairs((ForeverExplorerDB and ForeverExplorerDB.completed) or {}) do
        if value then done = done + 1 end
    end
    Print("Niveau " .. UnitLevel("player") .. " — " .. done .. "/" .. #steps .. " étapes validées.")
end

function FE:Show()
    if self.frame then self.frame:Show() end
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
    ForeverExplorerDB = ForeverExplorerDB or { completed = {}, stepIndex = 1 }
    if FE.BuildUI then FE:BuildUI() end
    Print("chargé. Tape /fe pour ouvrir, /fe next, /fe prev, /fe done ou /fe status.")
end)
