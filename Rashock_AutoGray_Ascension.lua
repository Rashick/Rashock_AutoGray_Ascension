-- Rashock_AutoGray Ascension
-- Verkauf grauer Items (über Link-Farbe) + Whitelist Items
-- Verkauf nur wenn Toggle aktiv ist: /rag on | /rag off | /rag
-- Client: Englisch (Ausgabe ist Englisch)

local addonTag = "|cffffcc00Rashock_AutoGray:|r"
local frame = CreateFrame("Frame")

-- Saved toggle (im Speicher; ohne SavedVariables bleibt es pro Session)
RASHOCK_AUTOGRAY_ENABLED = RASHOCK_AUTOGRAY_ENABLED or true

-- Whitelist: Items, die immer verkauft werden sollen (per Name)
local ALWAYS_SELL_BY_NAME = {
    ["Staff of Resentful Spirits"] = true,
    ["Councillor's Boots of the Battle-Caster"] = true,
    ["Axe of the Unyielding Vigil"] = true,
    ["Deep Fried Plantains"] = true,
    ["Roasted Quail"] = true,
    ["Homemade Cherry Pie"] = true,
    ["Dried King Bolete"] = true,
    ["Nightcrawlers"] = true, 
    ["Fine Aged Cheddar"] = true,
    
}

local function FormatMoney(copperTotal)
    local gold = math.floor(copperTotal / 10000)
    local silver = math.floor((copperTotal % 10000) / 100)
    local copper = copperTotal % 100
    return gold, silver, copper
end

local function IsGreyByLinkColor(itemLink)
    if not itemLink then return false end
    local hex = itemLink:match("|c(%x%x%x%x%x%x%x%x)")
    if not hex then return false end
    return hex:lower() == "ff9d9d9d"
end

local function IsAlwaysSellItem(itemLink)
    if not itemLink then return false end
    local itemName = itemLink:match("%[(.-)%]")
    if not itemName then return false end
    return ALWAYS_SELL_BY_NAME[itemName] == true
end

local function SellGreyItemsAndWhitelist()
    local totalCopper = 0
    local soldStacks = 0

    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink and (IsGreyByLinkColor(itemLink) or IsAlwaysSellItem(itemLink)) then
                local _, itemCount, locked = GetContainerItemInfo(bag, slot)
                if not locked then
                    local sellPrice = select(11, GetItemInfo(itemLink))
                    if sellPrice and sellPrice > 0 then
                        local count = itemCount or 1
                        totalCopper = totalCopper + (sellPrice * count)
                        soldStacks = soldStacks + 1
                        UseContainerItem(bag, slot)
                    end
                end
            end
        end
    end

    if soldStacks > 0 and totalCopper > 0 then
        local g, s, c = FormatMoney(totalCopper)
        DEFAULT_CHAT_FRAME:AddMessage(
            string.format("%s Sold %d item stacks for %dg %ds %dc.", addonTag, soldStacks, g, s, c)
        )
    else
        DEFAULT_CHAT_FRAME:AddMessage(addonTag .. " No items to sell.")
    end
end

-- Slash commands
SLASH_RASHOCKAUTOGRAY1 = "/rag"
SlashCmdList["RASHOCKAUTOGRAY"] = function(msg)
    msg = (msg or ""):lower()
    if msg == "on" then
        RASHOCK_AUTOGRAY_ENABLED = true
        DEFAULT_CHAT_FRAME:AddMessage(addonTag .. " Auto-sell ENABLED.")
    elseif msg == "off" then
        RASHOCK_AUTOGRAY_ENABLED = false
        DEFAULT_CHAT_FRAME:AddMessage(addonTag .. " Auto-sell DISABLED.")
    else
        RASHOCK_AUTOGRAY_ENABLED = not RASHOCK_AUTOGRAY_ENABLED
        DEFAULT_CHAT_FRAME:AddMessage(addonTag .. " Auto-sell is now " .. (RASHOCK_AUTOGRAY_ENABLED and "ENABLED." or "DISABLED."))
    end
end

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        DEFAULT_CHAT_FRAME:AddMessage(addonTag .. " Addon loaded. Use /rag on to enable auto-sell.")
    elseif event == "MERCHANT_SHOW" then
        if RASHOCK_AUTOGRAY_ENABLED then
            SellGreyItemsAndWhitelist()
        end
    end
end)

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("MERCHANT_SHOW")


