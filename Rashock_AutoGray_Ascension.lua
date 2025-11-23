-- Rashock_AutoGray Ascension
-- Verkauf grauer Items beim Händler anhand der Link-Farbe (|cff9d9d9d)
-- Ausgabe des verdienten Geldes im Chat (Gold/Silber/Kupfer)
-- Client: Englisch (Ausgabe ist Englisch)

local addonTag = "|cffffcc00Rashock_AutoGray:|r"
local frame = CreateFrame("Frame")

-- Hilfsfunktion: Geld in Gold/Silber/Kupfer umrechnen
local function FormatMoney(copperTotal)
    local gold = math.floor(copperTotal / 10000)
    local silver = math.floor((copperTotal % 10000) / 100)
    local copper = copperTotal % 100
    return gold, silver, copper
end

-- Prüft ob ItemLink grau ist (Poor) über Farbcodierung im Link
local function IsGreyByLinkColor(itemLink)
    if not itemLink then return false end
    local hex = itemLink:match("|c(%x%x%x%x%x%x%x%x)")
    if not hex then return false end
    return hex:lower() == "ff9d9d9d"  -- Grey/Poor
end

local function SellGreyItems()
    local totalCopper = 0
    local soldStacks = 0

    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink and IsGreyByLinkColor(itemLink) then
                local _, itemCount, locked = GetContainerItemInfo(bag, slot)
                if not locked then
                    local sellPrice = select(11, GetItemInfo(itemLink)) -- Kupfer pro Stück
                    if sellPrice and sellPrice > 0 then
                        local count = itemCount or 1
                        totalCopper = totalCopper + (sellPrice * count)
                        soldStacks = soldStacks + 1

                        -- verkauft beim Händler
                        UseContainerItem(bag, slot)
                    end
                end
            end
        end
    end

    if soldStacks > 0 and totalCopper > 0 then
        local g, s, c = FormatMoney(totalCopper)
        DEFAULT_CHAT_FRAME:AddMessage(
            string.format("%s Sold %d grey item stacks for %dg %ds %dc.", addonTag, soldStacks, g, s, c)
        )
    else
        DEFAULT_CHAT_FRAME:AddMessage(addonTag .. " No grey items to sell.")
    end
end

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        DEFAULT_CHAT_FRAME:AddMessage(addonTag .. " Addon loaded.")
    elseif event == "MERCHANT_SHOW" then
        SellGreyItems()
    end
end)

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("MERCHANT_SHOW")
