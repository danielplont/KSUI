-- Core UI

local ADDON_NAME = ...

-- Frame positions
local FRAME_POSITIONS = {
    PLAYER = {X = -450, Y = 300},
    TARGET = {X = -180, Y = 300},
    PARTY  = {X = -450, Y = 200}
}

local CHAT_EVENTS = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_BN_CONVERSATION",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER"
}

local CLASS_NAMES = {
    "DRUID",
    "HUNTER",
    "MAGE",
    "PALADIN",
    "PRIEST",
    "ROGUE",
    "SHAMAN",
    "WARLOCK",
    "WARRIOR"
}

local MANA_COLOR   = {0,       100/255, 240/255}
local RAGE_COLOR   = {256/255,  30/255,   0/255}
local ENERGY_COLOR = {255/255, 245/255, 105/255}

local function MoveAndScaleFrames()
    local positions = FRAME_POSITIONS

    PlayerFrame:SetUserPlaced(true)
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("CENTER", UIParent, "CENTER", positions.PLAYER.X, positions.PLAYER.Y)

    TargetFrame:SetUserPlaced(true)
    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("CENTER", UIParent, "CENTER", positions.TARGET.X, positions.TARGET.Y)

    PartyMemberFrame1:SetUserPlaced(true)
    PartyMemberFrame1:ClearAllPoints()
    PartyMemberFrame1:SetPoint("CENTER", UIParent, "CENTER", positions.PARTY.X, positions.PARTY.Y)

    for _, UnitFrame in pairs ({
        PlayerFrame,
        TargetFrame,
        PartyMemberFrame1,
        PartyMemberFrame2,
        PartyMemberFrame3,
        PartyMemberFrame4
    }) do
        UnitFrame:SetScale(1.15)
    end

    BuffFrame:SetScale(1.15)
    MinimapCluster:SetScale(1.1)
    -- CastingBarFrame:SetScale(1.1)
    ComboFrame:SetScale(1.2)
    CompactRaidFrameContainer:SetScale(1.1)
    MainMenuBarLeftEndCap:Hide()
    MainMenuBarRightEndCap:Hide()
end

local function HideHitIndicators()
    PlayerHitIndicator:SetText(nil)
    PlayerHitIndicator.SetText = function() end

    PetHitIndicator:SetText(nil)
    PetHitIndicator.SetText = function() end
end

local function RegisterHealthbarColors()
    local function ClassColorHealthbars(statusbar, unit)
        local _, class, c
        if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
            _, class = UnitClass(unit)
            c = RAID_CLASS_COLORS[class]
            statusbar:SetStatusBarColor(c.r, c.g, c.b)
            --PlayerFrameHealthBar:SetStatusBarColor(0, 1, 0)
        end
    end

    hooksecurefunc("UnitFrameHealthBar_Update", ClassColorHealthbars)
    hooksecurefunc("HealthBar_OnValueChanged", function(self)
        ClassColorHealthbars(self, self.unit)
    end)
end

local function RegisterChatImprovements()
    -- Add more chat font sizes
    for i = 1, 23 do
        CHAT_FONT_HEIGHTS[i] = i + 7
    end

    -- URL Replace stuff
    local function FormatUrl(url)
        return "|Hurl:"..tostring(url).."|h|cff0099FF"..tostring("["..url.."]").."|r|h"
    end

    local function UrlFilter(self, event, msg, ...)
        local foundUrl = false

        local msg2 = msg:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", function(before, url, after)
            foundUrl = true
            return before..FormatUrl(url)..after
        end)
        if not foundUrl then
            msg2 = msg:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end

        if msg2 ~= msg then
            return false, msg2, ...
        end
    end

    for _, event in pairs(CHAT_EVENTS) do
        ChatFrame_AddMessageEventFilter(event, UrlFilter)
    end

    StaticPopupDialogs["KSUI_UrlCopy"] = {
        text = "Press Ctrl-C to copy the URI",
        button1 = "Done",
        button2 = "Cancel",
        hasEditBox = true,
        whileDead = true,
        hideOnEscape = true,
        timeout = 10,
        enterClicksFirstButton = true
    }

    local OriginalChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
    function ChatFrame_OnHyperlinkShow(frame, link, text, button)
        local type, value = link:match("(%a+):(.+)")
        if (type == "url") then
            local popup = StaticPopup_Show("KSUI_UrlCopy")
            popup.editBox:SetText(value)
            popup.editBox:SetFocus()
            popup.editBox:HighlightText()
        else
            OriginalChatFrame_OnHyperlinkShow(self, link, text, button)
        end
    end

    -- Make arrow keys work without alt in editboxes
    for i = 1, NUM_CHAT_WINDOWS do
        if i ~= 2 then
            local editBox = _G["ChatFrame"..i.."EditBox"]
            editBox:SetAltArrowKeyMode(false)
        end
    end
end

local function RegisterEnemyStatusDisplay()
    PlayerFrameHealthBarText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    PlayerFrameHealthBarTextLeft:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    PlayerFrameHealthBarTextRight:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    PlayerFrameManaBarText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    PlayerFrameManaBarTextLeft:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    PlayerFrameManaBarTextRight:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")

    local CustomTargetStatusText = CreateFrame("Frame", nil, TargetFrame)
    CustomTargetStatusText:SetFrameLevel(5)

    for _, v in pairs({"HMiddle", "HLeft", "HRight", "MMiddle", "MLeft", "MRight"}) do
        CustomTargetStatusText[v] = CustomTargetStatusText:CreateFontString(nil, "OVERLAY")
        CustomTargetStatusText[v]:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        CustomTargetStatusText[v]:SetTextColor(1, 1, 1, 1)
        CustomTargetStatusText[v]:SetJustifyV("CENTER")
        CustomTargetStatusText[v]:SetJustifyH("CENTER")
        CustomTargetStatusText[v]:SetText("")
        CustomTargetStatusText[v]:SetShadowColor(0, 0, 0, 0)
        CustomTargetStatusText[v]:SetShadowOffset(1, -1)
    end
    CustomTargetStatusText.HMiddle:SetPoint("CENTER", TargetFrame, -50, 3)
    CustomTargetStatusText.HLeft:SetPoint("CENTER", TargetFrame, -93, 3)
    CustomTargetStatusText.HRight:SetPoint("CENTER", TargetFrame, -4, 3)
    CustomTargetStatusText.MMiddle:SetPoint("CENTER", TargetFrame, -50, -8)
    CustomTargetStatusText.MLeft:SetPoint("CENTER", TargetFrame, -93, -8)
    CustomTargetStatusText.MRight:SetPoint("CENTER", TargetFrame, -4, -8)

    local function UpdateEnemyStatus(self, event)
        if event == "PLAYER_TARGET_CHANGED" or event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" then
            if UnitExists("target") and not UnitIsDeadOrGhost("target") and UnitHealth("target") > 0 then
                if UnitHealthMax("target") > 100 then
                    CustomTargetStatusText.HMiddle:SetText("")
                    CustomTargetStatusText.HLeft:SetText(math.ceil(UnitHealth("target") / UnitHealthMax("target")*100).."%")
                    CustomTargetStatusText.HRight:SetText(UnitHealth("target"))
                else
                    CustomTargetStatusText.HMiddle:SetText(math.ceil(UnitHealth("target") / UnitHealthMax("target")*100).."%")
                    CustomTargetStatusText.HLeft:SetText("")
                    CustomTargetStatusText.HRight:SetText("")
                end
            else
                CustomTargetStatusText.HMiddle:SetText("")
                CustomTargetStatusText.HLeft:SetText("")
                CustomTargetStatusText.HRight:SetText("")
            end
        end

        if event == "PLAYER_TARGET_CHANGED" or event == "UNIT_POWER_UPDATE" then
            if UnitExists("target") and not UnitIsDeadOrGhost("target") and UnitPower("target") > 0 then
                if UnitPowerType("target") == 0 then
                    if UnitPowerMax("target") > 100 then
                        CustomTargetStatusText.MMiddle:SetText("")
                        CustomTargetStatusText.MLeft:SetText(math.ceil(UnitPower("target") / UnitPowerMax("target")*100).."%")
                        CustomTargetStatusText.MRight:SetText(UnitPower("target"))
                    else
                        CustomTargetStatusText.MMiddle:SetText(math.ceil(UnitPower("target") / UnitPowerMax("target")*100).."%")
                        CustomTargetStatusText.MLeft:SetText("")
                        CustomTargetStatusText.MRight:SetText("")
                    end
                else
                    CustomTargetStatusText.MMiddle:SetText(UnitPower("target"))
                    CustomTargetStatusText.MLeft:SetText("")
                    CustomTargetStatusText.MRight:SetText("")
                end
            else
                CustomTargetStatusText.MMiddle:SetText("")
                CustomTargetStatusText.MLeft:SetText("")
                CustomTargetStatusText.MRight:SetText("")
            end
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("UNIT_HEALTH", "target")
    f:RegisterEvent("UNIT_POWER_UPDATE", "target")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:SetScript("OnEvent", UpdateEnemyStatus)
end

local function RegisterVendorGreys()
    local function SellTrash(self, event)
        if (event == "MERCHANT_SHOW") then
            local bag, slot
            for bag = 0, 4 do
                for slot = 0, GetContainerNumSlots(bag) do
                    local link = GetContainerItemLink(bag, slot)
                    if link and (select(3, GetItemInfo(link)) == 0) then
                        UseContainerItem(bag, slot)
                    end
                end
            end
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("MERCHANT_SHOW")
    f:SetScript("OnEvent", SellTrash)
end

local function Init(self, event)
    if event == "PLAYER_LOGIN" then
        MoveAndScaleFrames()
        HideHitIndicators()
        RegisterHealthbarColors()
        RegisterChatImprovements()
        RegisterEnemyStatusDisplay()
        RegisterVendorGreys()

        DEFAULT_CHAT_FRAME:AddMessage(ADDON_NAME.." loaded")
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", Init)

