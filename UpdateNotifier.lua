local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print("Successfully logged in")
        CheckOutOfDateAddons()
    end
end)

local tooltip = CreateFrame("GameTooltip", "UpdateNotifierTooltip", UIParent, "GameTooltipTemplate")
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

function GetAddonVersionFromTooltip(addonName)
    tooltip:ClearLines()
    tooltip:SetHyperlink("addon:" .. addonName)
    local version = _G["UpdateNotifierTooltipTextLeft2"]:GetText()
    return version
end

function CheckOutOfDateAddons()
    print("Checking for out-of-date addons")
    local outOfDateAddons = {}
    for i = 1, GetNumAddOns() do
        local name, title, notes, enabled, loadable, reason, security, newVersion = GetAddOnInfo(i)
        print("Addon:", title or name, "Reason:", reason)
        
        local metadataVersion = addonMetadata[name]
        if metadataVersion and newVersion ~= metadataVersion then
            table.insert(outOfDateAddons, {title or name, newVersion, metadataVersion})
            print("Out-of-date addon found: " .. (title or name))
        end
    end

    if #outOfDateAddons > 0 then
        ShowOutOfDateAddons(outOfDateAddons)
    else
        print("No out-of-date addons found")
    end
end

function GetCurseForgeAddonInfo(addonName)
    local url = "https://www.curseforge.com/wow/addons/" .. addonName
    local request = CreateHTTPRequest()
    request:SetHTTPRequestURL(url)
    request:SetRequestType("GET")
    request:Send(function(response)
        if response.StatusCode == 200 then
            local htmlContent = response.Body
            local version = htmlContent:match('"Game Version": "(%d+%.%d+)"')
            return true, {version = version}
        else
            print("Failed to fetch CurseForge addon info for " .. addonName)
            return false, nil
        end
    end)
end


function ShowOutOfDateAddons(addons)
    print("Displaying out-of-date addons")
    local message = "The following addons are out of date:\n"
    for _, addon in ipairs(addons) do
        message = message .. "- " .. addon .. "\n"
    end

    local frame = CreateFrame("Frame", "UpdateNotifierFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 200)
    frame:SetPoint("CENTER")
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("Update Notifier")

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(260, 140)
    scrollFrame:SetScrollChild(content)

    local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT")
    text:SetText(message)

    local reloadButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    reloadButton:SetPoint("BOTTOMLEFT", 10, 10)
    reloadButton:SetSize(120, 40)
    reloadButton:SetText("Reload UI")
    reloadButton:SetNormalFontObject("GameFontNormalLarge")
    reloadButton:SetHighlightFontObject("GameFontHighlightLarge")
    reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
end