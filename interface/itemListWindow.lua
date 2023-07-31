-----------------------
----LOCAL VARIABLES----
-----------------------


local _, namespace = ...
local functions = namespace.functions;
local variables = namespace.variables;
local locale = namespace.locale;

local LPTLootRoll_ItemListWindow = CreateFrame("Frame", "LPTLootRoll_ItemList", nil, "BasicFrameTemplate");


-----------------------
----LOCAL FUNCTIONS----
-----------------------


--Add array to frame function.
local function addArrayToFrame()
    for i,v in ipairs(variables.itemsToRoll) do 
        local itemName, _, quality = GetItemInfo(v[2]);
        local remainingChars = 30-strlen(v[1]);
        local itemLength = strlen(itemName);
        local _, _, _, hexCode = GetItemQualityColor(quality);
        local shortLink = "|c" .. hexCode .. "[" .. strsub(itemName, 1, remainingChars) .. (itemLength > remainingChars and ".." or "]");

		LPTLootRoll_ItemListWindow.itemFrame.messageFrame:AddMessage("|Hgarrmission:lptlootroll:rollItem&" .. i .."|h|c" .. v[3] .. v[1] .. " - " .. shortLink .. "|h|r");
	end
end

--Function for updating the scroll list message frame.
local function updateWindow()
    local frame = LPTLootRoll_ItemListWindow.itemFrame.messageFrame;
    local arrLength = #variables.itemsToRoll;

    frame:Clear();
    LPTLootRoll_ItemListWindow.skipItemButton:SetEnabled(arrLength > 0);
    LPTLootRoll_ItemListWindow.nextItemButton:SetEnabled(arrLength > 0);

    if arrLength == 0 then
        return;
    end

    if arrLength > 15 then
		frame:GetParent().scrollBar:SetMinMaxValues(0, arrLength-15);
	end

    frame:SetMaxLines(arrLength);

	--Determine how the frames should be scrolled before displaying them.
    local scrollBarScroll = 0;
	local frameScroll = arrLength-15;

    addArrayToFrame();
	frame:GetParent().scrollBar:SetValue(scrollBarScroll);
	frame:SetScrollOffset(frameScroll);
end


-----------------------
-----EVENT HANDLING----
-----------------------


LPTLootRoll_ItemListWindow:SetScript("OnEvent",
    function(_, event, ...)
        variables.events[event](...);
    end
);


-----------------------
------ITEM WINDOW------
-----------------------


LPTLootRoll_ItemListWindow:SetToplevel(true);
LPTLootRoll_ItemListWindow:SetSize(200,275);
LPTLootRoll_ItemListWindow:SetMovable(true);
LPTLootRoll_ItemListWindow:EnableMouse(true);
LPTLootRoll_ItemListWindow:RegisterForDrag("LeftButton");
LPTLootRoll_ItemListWindow:SetPoint("CENTER");
LPTLootRoll_ItemListWindow:SetUserPlaced(true);
LPTLootRoll_ItemListWindow:SetClampedToScreen(true);
LPTLootRoll_ItemListWindow:SetClampRectInsets(0, 0, 0, 0);
LPTLootRoll_ItemListWindow:Hide();

LPTLootRoll_ItemListWindow:SetScript("OnDragStart", LPTLootRoll_ItemListWindow.StartMoving)
LPTLootRoll_ItemListWindow:SetScript("OnDragStop", LPTLootRoll_ItemListWindow.StopMovingOrSizing)
LPTLootRoll_ItemListWindow:SetScript("OnShow", functions.updateItemListScale);

LPTLootRoll_ItemListWindow.title = LPTLootRoll_ItemListWindow:CreateFontString(nil,"OVERLAY");
LPTLootRoll_ItemListWindow.title:SetFontObject("GameFontHighLight");
LPTLootRoll_ItemListWindow.title:SetPoint("LEFT", LPTLootRoll_ItemListWindow.TitleBg, "left", 5, -1);
LPTLootRoll_ItemListWindow.title:SetText(locale.itemListTitle);

LPTLootRoll_ItemListWindow.tipText = LPTLootRoll_ItemListWindow:CreateFontString(nil, "OVERLAY");
LPTLootRoll_ItemListWindow.tipText:SetFontObject("GameTooltipTextSmall");
LPTLootRoll_ItemListWindow.tipText:SetPoint("BOTTOM", 5, 5);
LPTLootRoll_ItemListWindow.tipText:SetText("|cFFFFFF00" .. locale.ctrlClickHelpText);


--Next item button.
LPTLootRoll_ItemListWindow.nextItemButton = functions.startButton(LPTLootRoll_ItemListWindow, "TOPRIGHT", "TOP", 0, -22, locale.postButtonTitle, (LPTLootRoll_ItemListWindow:GetWidth()-13)/2, 30,
function(_)
    functions.popList(1, true);
end
);
LPTLootRoll_ItemListWindow.nextItemButton:Disable();



--Skip item button
LPTLootRoll_ItemListWindow.skipItemButton = functions.startButton(LPTLootRoll_ItemListWindow, "TOPLEFT", "TOP", 0, -22, locale.skipButtonTitle, (LPTLootRoll_ItemListWindow:GetWidth()-13)/2, 30,
function(_)
    functions.popList();
end
);
LPTLootRoll_ItemListWindow.skipItemButton:Disable();



--Initialize the frames for the rolled lists.
LPTLootRoll_ItemListWindow.itemFrame = CreateFrame("Frame", nil, LPTLootRoll_ItemListWindow);

--Start the item list frame
functions.scrollFrameFactory(LPTLootRoll_ItemListWindow.itemFrame, LPTLootRoll_ItemListWindow, 11, -30, "", LPTLootRoll_ItemListWindow:GetWidth()-20, LPTLootRoll_ItemListWindow:GetHeight()-30, false);

--Enable hyperlink functionality for the messageframe.
LPTLootRoll_ItemListWindow.itemFrame.messageFrame:SetHyperlinksEnabled(1);


--Enable standard mouseover tooltip functionality.
LPTLootRoll_ItemListWindow.itemFrame.messageFrame:SetScript("OnHyperlinkEnter",
    function(_, text, _)
        local index = select(3, text:find("(%d)"));
        index = tonumber(index);

        if not index then
            return;
        end

        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR"); 
		GameTooltip:ClearLines(); 
        GameTooltip:SetHyperlink(variables.itemsToRoll[index][2]); 
		GameTooltip:Show();
    end
);

LPTLootRoll_ItemListWindow.itemFrame.messageFrame:SetScript("OnHyperlinkLeave", functions.hideGametoolTip);
LPTLootRoll_ItemListWindow.itemFrame.messageFrame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow);


-----------------------
---GLOBAL FUNCTIONS----
-----------------------


--Function for registering an incomming item.
function functions.registerItem(sender, item)
    if not (UnitIsGroupLeader("player") or (llrSettings.assistMode and UnitIsGroupAssistant("player"))) then
        return;
    end

    local _, itemLink = GetItemInfo(item);

    if not itemLink then
        return;
    end

    tinsert(
        variables.itemsToRoll,
        {
            sender,
            itemLink,
            functions.getClassColor(sender)
        }
    );

    table.sort(
        variables.itemsToRoll,
        function(a, b)
            if a[2] > b[2] then
                return false;
            elseif a[2] < b[2] then
                return true;
            else 
                return a[1] < b[1];
            end
        end
    );

    functions.displayItemList();

    updateWindow();
end

--Function for the item list buttons.
function functions.popList(index, postBool)
    local head = tremove(variables.itemsToRoll, index or 1);

    updateWindow();

    if postBool then
        C_ChatInfo.SendAddonMessage("LPTLootRoll", variables.closeWindowKey, "RAID");

        SendChatMessage(head[1] .. " - " .. head[2], "RAID_WARNING", nil, nil);
    end

    if #variables.itemsToRoll == 0 then
        functions.hideItemList();
    end
end


-----------------------
---WINDOW FUNCTIONS----
-----------------------


--Function for updating the user window scale.
function functions.updateItemListScale()
	LPTLootRoll_ItemListWindow:SetScale(variables.screenScale*llrSettings.itemListScale);
end

--Function for displaying the user window.
function functions.displayItemList()
	if not LPTLootRoll_ItemListWindow:IsShown() then
		LPTLootRoll_ItemListWindow:Show();
	end
end

--Function for hiding the user window.
function functions.hideItemList()
	if LPTLootRoll_ItemListWindow:IsShown() then
		LPTLootRoll_ItemListWindow:Hide();
	end
end

--Function for resetting the user window position.
function functions.resetItemListWindow()
	LPTLootRoll_ItemListWindow:ClearAllPoints();
	LPTLootRoll_ItemListWindow:SetPoint("CENTER", UIParent, "CENTER");
end

--Function to toggle the whisper listener.
function functions.toggleWhisperListener()
    if llrSettings.whisperListener and UnitInRaid("player") then
        LPTLootRoll_ItemListWindow:RegisterEvent("CHAT_MSG_WHISPER");
    else
        LPTLootRoll_ItemListWindow:UnregisterEvent("CHAT_MSG_WHISPER");
    end
end