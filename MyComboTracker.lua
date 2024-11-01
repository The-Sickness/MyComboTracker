-- My Combo Tracker
-- Made by Sharpedge_Gaming
-- v2.0 - 11.0.5

local addonName, addonTable = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local MyComboTracker = AceAddon:NewAddon(addonName, "AceConsole-3.0")

MyComboTrackerSettings = MyComboTrackerSettings or {}

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetSize(1, 1)
frame:SetPoint("CENTER")

local text = frame:CreateFontString(nil, "OVERLAY")

local ag = text:CreateAnimationGroup()

local move = ag:CreateAnimation("Translation")
move:SetOffset(0, 200)
move:SetDuration(2)
move:SetSmoothing("OUT")

local fade = ag:CreateAnimation("Alpha")
fade:SetFromAlpha(1)
fade:SetToAlpha(0)
fade:SetDuration(2)
fade:SetSmoothing("OUT")
fade:SetStartDelay(1)

ag:SetScript("OnFinished", function() text:Hide() end)

-- Define table containing info for different specializations.
local specializationData = {
    [1] = { maxComboPoints = 5, soundSuffix = "" }, -- Assassination Rogue
    [2] = { maxComboPoints = 5, soundSuffix = "" }, -- Feral Druid
    [3] = { maxComboPoints = 6, soundSuffix = "_6" }, -- Subtlety Rogue
    [4] = { maxComboPoints = 6, soundSuffix = "" }, -- Outlaw Rogue
    [70] = { maxHolyPowerPoints = 5, soundSuffix = "" }, -- Retribution Paladin
}


local function PlaySoundAtComboPoints(comboPoints)
    local spec = GetSpecialization()
    local specData = specializationData[spec]
    
    if specData then
        if comboPoints >= specData.maxComboPoints then
            local selectedSound = MyComboTrackerSettings.selectedSound
            
            if selectedSound then
                local soundFile = MyComboTrackerSettings.soundOptions[selectedSound]
                
                if soundFile then
                    PlaySoundFile(soundFile, "Master")
                end
            end
        end
    end
end


local function UpdateComboPoints()
    local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
    if comboPoints and comboPoints > 0 then
        text:SetText(comboPoints)
        text:SetAlpha(1)
        text:Show()
        ag:Stop()
        move:SetOffset(0, 200)
        ag:Play()

        PlaySoundAtComboPoints(comboPoints)
    end
end


local currentSpec = -1

local function CheckSpec()
    local spec = GetSpecialization()
    if spec ~= currentSpec then
        currentSpec = spec
        local specData = specializationData[currentSpec]

        if specData then
            local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
            if comboPoints >= specData.maxComboPoints then
                local selectedSound = MyComboTrackerSettings.selectedSound .. specData.soundSuffix
                if selectedSound then
                    local soundFile = MyComboTrackerSettings.soundOptions[selectedSound]
                    if soundFile then
                        PlaySoundFile(soundFile, "Master")
                    end
                end
            end
        end
    end
end

-- Create the text label for Holy Power
local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
label:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
label:SetPoint("CENTER", frame, "CENTER")


frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

local function OnEvent(self, event, ...)
    local unit, powerType = ...
    if unit == "player" then
        if powerType == "COMBO_POINTS" then
            -- Update combo points
            UpdateComboPoints()
        elseif powerType == "HOLY_POWER" then
            -- Get current Holy Power
            local currentPower = UnitPower("player", SPELL_POWER_HOLY_POWER)
            
            -- Update the label with Holy Power
            if currentPower and currentPower > 0 and currentPower <= 5 then
                label:SetText(tostring(currentPower))
                label:SetAlpha(1)
                label:Show()
                ag:Stop()
                move:SetOffset(0, 200)
                ag:Play()
            else
                label:SetText("")
                label:Hide()
            end
        end
    elseif event == "ADDON_LOADED" and ... == "MyComboTracker" then
        if not MyComboTrackerSettings.textSize then
            MyComboTrackerSettings.textSize = 25
        end
        text:SetFont("Fonts\\FRIZQT__.TTF", MyComboTrackerSettings.textSize, "OUTLINE")
        text:SetTextColor(204/255, 85/255, 0, 1)
        text:SetPoint("CENTER")
        if not MyComboTracker.initialized then
            MyComboTracker:OnInitialize()
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        CheckSpec()
    end
end

frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
-- Set event handler
frame:SetScript("OnEvent", OnEvent)

-- Set event handler
frame:SetScript("OnEvent", OnEvent)

function MyComboTracker:OnInitialize()
    if self.initialized then return end
    self.initialized = true

    local SV = LibStub("AceDB-3.0"):New("MyComboTrackerDB", { profile = { textSize = 25, selectedFont = "Friz Quadrata TT", textColor = { r = 1, g = 1, b = 1, a = 1 } } }, "Default")
    MyComboTracker.db = SV -- Assign the database to your addon's variable
    MyComboTrackerSettings = SV.profile

    MyComboTrackerSettings.soundOptions = {
        ["Sound1"] = "Interface\\Addons\\MyComboTracker\\sounds\\ReadyCheck.mp3",
        ["Sound2"] = "Interface\\Addons\\MyComboTracker\\sounds\\AxeCrit.mp3",
        ["Sound3"] = "Interface\\Addons\\MyComboTracker\\sounds\\Parry.mp3",
        ["Sound4"] = "Interface\\Addons\\MyComboTracker\\sounds\\SealofMight.mp3",
        ["Sound5"] = "Interface\\Addons\\MyComboTracker\\sounds\\Sheldon.mp3",
        ["Sound6"] = "Interface\\Addons\\MyComboTracker\\sounds\\Arrow Swoosh.mp3",
        ["Sound7"] = "Interface\\Addons\\MyComboTracker\\sounds\\Buzzer.mp3",
        ["Sound8"] = "Interface\\Addons\\MyComboTracker\\sounds\\Gun Cocking.mp3",
        ["Sound9"] = "Interface\\Addons\\MyComboTracker\\sounds\\Laser.mp3",
        ["Sound10"] = "Interface\\Addons\\MyComboTracker\\sounds\\Target Acquired.mp3",
		["Sound11"] = "Interface\\Addons\\MyComboTracker\\sounds\\NoAlert.mp3",
    }

    local soundOptionNames = {
        ["Sound1"] = "Ready Check",
        ["Sound2"] = "Axe Crit",
        ["Sound3"] = "Parry",
        ["Sound4"] = "Seal of Might",
        ["Sound5"] = "Sheldon",
        ["Sound6"] = "Arrow Swoosh",
        ["Sound7"] = "Buzzer",
        ["Sound8"] = "Gun Cocking",
        ["Sound9"] = "Laser",
        ["Sound10"] = "Target Acquired",
		["Sound11"] = "No Alert",
    }

    local options = {
        name = addonName,
        type = "group",
        args = {
            textSize = {
                type = "range",
                name = "Text Size",
                desc = "Adjust the size of the combo point text",
                min = 10,
                max = 50,
                step = 1,
                get = function(info) return MyComboTrackerSettings.textSize end,
                set = function(info, value)
                    MyComboTrackerSettings.textSize = value
                    text:SetFont(LSM:Fetch("font", MyComboTrackerSettings.selectedFont), value, "OUTLINE")
                end,
                order = 1,
            },
            fontSelection = {
                type = "select",
                name = "Font Selection",
                desc = "Choose the font for the combo point text",
                values = function()
                    local fontOptionNames = {}
                    for _, fontName in ipairs(LSM:List("font")) do
                        fontOptionNames[fontName] = fontName
                    end
                    return fontOptionNames
                end,
                get = function(info) return MyComboTrackerSettings.selectedFont end,
                set = function(info, value)
                    MyComboTrackerSettings.selectedFont = value
                    text:SetFont(LSM:Fetch("font", value), MyComboTrackerSettings.textSize, "OUTLINE")
                end,
                order = 2,
            },
            colorPicker = {
                type = "color",
                name = "Text Color",
                desc = "Choose the color for the combo point text",
                get = function(info)
                    local color = MyComboTrackerSettings.textColor
                    return color.r, color.g, color.b, color.a
                end,
                set = function(info, r, g, b, a)
                    MyComboTrackerSettings.textColor = { r = r, g = g, b = b, a = a }
                    text:SetTextColor(r, g, b, a)
                end,
                order = 3,
            },
            soundSelection = {
                type = "select",
                name = "Sound Selection",
                desc = "Choose the sound to play when reaching 5 combo points",
                values = soundOptionNames,
                get = function(info) return MyComboTrackerSettings.selectedSound end,
                set = function(info, value)
                    MyComboTrackerSettings.selectedSound = value
                    local soundFile = MyComboTrackerSettings.soundOptions[value]
                    if soundFile then
                        PlaySoundFile(soundFile, "Master")
                    end
                end,
                order = 4,
            },
        },
    }

    AceConfig:RegisterOptionsTable(addonName, options)
    AceConfigDialog:AddToBlizOptions(addonName, addonName)

    -- Set the font and color when the addon is loaded or reloaded
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            text:SetFont(LSM:Fetch("font", MyComboTrackerSettings.selectedFont), MyComboTrackerSettings.textSize, "OUTLINE")
            local color = MyComboTrackerSettings.textColor
            text:SetTextColor(color.r, color.g, color.b, color.a)
        end
    end)
end
















      











