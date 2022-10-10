-----------------------
----LOCAL VARIABLES----
-----------------------


local ADDON_NAME, namespace = ...
local functions = namespace.functions;
local variables = namespace.variables;
local locale = namespace.locale;

local LPTLootRoll_LeaderWindow = CreateFrame("Frame", "LPTLootRoll_Leader", nil, "BasicFrameTemplate");
local historyIndex = 1;


-----------------------
----LOCAL FUNCTIONS----
-----------------------


--Function for clearing a frame.
local function clearFrame(frame)
	--Clear list views to prepare for new item.
	frame:Clear();
	
	--Reset scrollbar values. 
	frame:GetParent().scrollBar:SetMinMaxValues(0,0);
	frame:GetParent().scrollBar:SetValue(select(1, frame:GetParent().scrollBar:GetMinMaxValues()));
end

--Function for toggeling of all buttons in a frame.
local function toggleButtons(enabled)
	LPTLootRoll_LeaderWindow.rollFrame.mainSpeccButton:SetEnabled(enabled);
	LPTLootRoll_LeaderWindow.rollFrame.offSpeccButton:SetEnabled(enabled);
	LPTLootRoll_LeaderWindow.rollFrame.mogButton:SetEnabled(enabled);
	LPTLootRoll_LeaderWindow.rollFrame.otherButton:SetEnabled(enabled);
	LPTLootRoll_LeaderWindow.rollFrame.passButton:SetEnabled(enabled);
end

--Reverse array function 
local function reverseArray(array)
	local i, j = 1, #array

	while i < j do
		array[i], array[j] = array[j], array[i]
		i = i + 1
		j = j - 1
	end
end

--Function for updating the scroll list message frame.
local function updateMessageframe(frame, array)
	clearFrame(frame);

	if not array then 
		return;
	end

	local arrLength = #array;

	if arrLength == 0 then
		return;
	end

	if arrLength > 7 then 
		frame:GetParent().scrollBar:SetMinMaxValues(0, arrLength-7);
	end

	frame:SetMaxLines(arrLength);

	--Determine how the frames should be scrolled before displaying them.
	local scrollBarScroll = 0;
	local frameScroll = arrLength-7;

	if not llrSettings.scrollMode then
		reverseArray(array);
		scrollBarScroll = arrLength-7;
		frameScroll = 0;
	end

	for i,v in ipairs(array) do 
		frame:AddMessage("|Hgarrmission:lptlootroll:roller&" .. v[1] .. "-" .. v[4] .. "|h|c" .. v[3] .. "(" .. v[2] .. ") " .. v[1] .. "|h|r");
	end

	frame:GetParent().scrollBar:SetValue(scrollBarScroll);
	frame:SetScrollOffset(frameScroll);
end

--Function for updating all the message frames with values for item at index.
local function updateAllMessageFrames()
	updateMessageframe(LPTLootRoll_LeaderWindow.mainFrame.messageFrame, variables.rollHistory[historyIndex].mainList);
	updateMessageframe(LPTLootRoll_LeaderWindow.offFrame.messageFrame, variables.rollHistory[historyIndex].offList);
	updateMessageframe(LPTLootRoll_LeaderWindow.mogFrame.messageFrame, variables.rollHistory[historyIndex].mogList);
	updateMessageframe(LPTLootRoll_LeaderWindow.otherFrame.messageFrame, variables.rollHistory[historyIndex].otherList);
end

--Function for handling page number display.
local function titleBarControl()
	LPTLootRoll_LeaderWindow.historyButtonFrame.pageNumber:SetText(historyIndex .. " / " .. #variables.rollHistory);
	LPTLootRoll_LeaderWindow.historyButtonFrame.nextHistoryPage:SetEnabled(#variables.rollHistory > historyIndex);
	LPTLootRoll_LeaderWindow.historyButtonFrame.previousHistoryPage:SetEnabled(historyIndex > 1);

	local owner = variables.rollHistory[historyIndex].owner;
	
	LPTLootRoll_LeaderWindow.title:SetText(locale.userLeaderTitleText(owner));
end

--Function for handling history list displays.
local function scrollHistory(bool)
	if #variables.rollHistory > 0 then
		--Increase or decrease history index depending on direction of scroll.
		historyIndex = historyIndex + ((bool and #variables.rollHistory > historyIndex) and 1 or ((not bool and 1 < historyIndex) and -1 or 0));

		titleBarControl();
		functions.setItemButtonData(LPTLootRoll_LeaderWindow.itemButton, variables.rollHistory[historyIndex].item);
		updateAllMessageFrames();
		functions.updateRollerCounter();
	end
end

--Function for handling mouseover of player names in the roll lists.
local function playerMouseover(_, _, input)
	if historyIndex ~= 1 or not functions.isLeaderOrAssistWithMode("player") then
		return;
	end


	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR"); 
	GameTooltip:ClearLines(); 

	if variables.rollHistory[1].distributed then
		GameTooltip:AddLine("|cFFFFFF00" .. locale.itemDistributed);
	else
		local _, _, _, name = input:find("(%b()) (.+)");
		GameTooltip:AddLine("|cFFFFFF00" .. locale.distributeItem(name));
	end

	GameTooltip:Show();
end

--Function for handling link clicks. If it is on the main page and item has not been distrubted, pass click to standard hyperlink handler.
local function hyperLinkClick(self, link, text, button)
	if historyIndex ~= 1 or variables.rollHistory[1].distributed or not (functions.isLeaderOrAssistWithMode("player")) then
		return;
	end
	
	ChatFrame_OnHyperlinkShow(self, link, text, button);
end


-----------------------
-----EVENT HANDLING----
-----------------------


LPTLootRoll_LeaderWindow:SetScript("OnEvent", 
	function(self, event, ...)
		variables.events[event](...);

		--If on main page, then update the message frames.
		if historyIndex == 1 and variables.rollHistory[1] ~= nil then
			updateAllMessageFrames();
		end
	end
);


-----------------------
-----LEADER WINDOW-----
-----------------------


LPTLootRoll_LeaderWindow:SetToplevel(true);
LPTLootRoll_LeaderWindow:SetSize(340,225);
LPTLootRoll_LeaderWindow:SetMovable(true);
LPTLootRoll_LeaderWindow:EnableMouse(true);
LPTLootRoll_LeaderWindow:RegisterForDrag("LeftButton");
LPTLootRoll_LeaderWindow:SetPoint("CENTER");
LPTLootRoll_LeaderWindow:SetUserPlaced(true);
LPTLootRoll_LeaderWindow:SetClampedToScreen(true);
LPTLootRoll_LeaderWindow:SetClampRectInsets(0, 0, 0, 0)
LPTLootRoll_LeaderWindow:Hide();

LPTLootRoll_LeaderWindow:SetScript("OnDragStart", LPTLootRoll_LeaderWindow.StartMoving);
LPTLootRoll_LeaderWindow:SetScript("OnDragStop", LPTLootRoll_LeaderWindow.StopMovingOrSizing);
LPTLootRoll_LeaderWindow:SetScript("OnShow", 
	function(self) 
		functions.updateLeaderScale();
		functions.controlRollListener();
	end
);

LPTLootRoll_LeaderWindow:SetScript("OnHide", 
	function(self) 
		functions.controlRollListener();
	end
);

LPTLootRoll_LeaderWindow:SetScript("OnMouseWheel", 
	function(self, delta)
		scrollHistory(delta < 0);
	end
);

--Title for leader window.
LPTLootRoll_LeaderWindow.title = LPTLootRoll_LeaderWindow:CreateFontString(nil, "OVERLAY");
LPTLootRoll_LeaderWindow.title:SetFontObject("GameFontHighLight");
LPTLootRoll_LeaderWindow.title:SetPoint("LEFT", LPTLootRoll_LeaderWindow.TitleBg, "LEFT", 5, -1);
LPTLootRoll_LeaderWindow.title:SetText("LPT");

--Potential roller text
LPTLootRoll_LeaderWindow.potentialRollers = CreateFrame("Frame", nil, LPTLootRoll_LeaderWindow);
LPTLootRoll_LeaderWindow.potentialRollers:SetPoint("TOPLEFT", 5, -25);
LPTLootRoll_LeaderWindow.potentialRollers:SetSize(85, 10);

LPTLootRoll_LeaderWindow.potentialRollers.text = LPTLootRoll_LeaderWindow.potentialRollers:CreateFontString(nil, "OVERLAY");
LPTLootRoll_LeaderWindow.potentialRollers.text:SetPoint("LEFT");
LPTLootRoll_LeaderWindow.potentialRollers.text:SetFontObject("GameFontHighLight");

LPTLootRoll_LeaderWindow.potentialRollers:SetScript('OnLeave', functions.hideGametoolTip);
LPTLootRoll_LeaderWindow.potentialRollers:SetScript('OnEnter', 
	function() 
		if variables.rollHistory[historyIndex] == nil then
			return;
		end

		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR"); 
		GameTooltip:ClearLines(); 

		GameTooltip:AddLine(locale.possibleRollers);
		GameTooltip:AddLine("(|cff00ff00" .. locale.reacted .. "|r/|cffff0000" .. locale.notReacted .. "|r)");
		GameTooltip:AddLine(" ");

		for i, v in pairs(variables.rollHistory[historyIndex].potentialRollers) do
			GameTooltip:AddLine((v and "|cff00ff00" or "|cffff0000") .. i .. "|r");
		end

		GameTooltip:Show();
	end
);

--Setup the raid leader item preview.
LPTLootRoll_LeaderWindow.itemButton = CreateFrame("Button", nil, LPTLootRoll_LeaderWindow, "GameMenuButtonTemplate");
LPTLootRoll_LeaderWindow.itemButton:SetPoint("TOPLEFT", LPTLootRoll_LeaderWindow, "TOPLEFT", 8, -39);
LPTLootRoll_LeaderWindow.itemButton:SetSize(60,60);

--Initialize raid leader's roll buttons.
LPTLootRoll_LeaderWindow.rollFrame = CreateFrame("Frame","RollButtons", LPTLootRoll_LeaderWindow);
LPTLootRoll_LeaderWindow.rollFrame:SetSize(60,120);
LPTLootRoll_LeaderWindow.rollFrame:SetPoint("BOTTOMLEFT", LPTLootRoll_LeaderWindow, 8, 0);

--Start instance of raid leader buttons.
LPTLootRoll_LeaderWindow.rollFrame.mainSpeccButton = functions.startButton(LPTLootRoll_LeaderWindow.rollFrame, "TOPLEFT", "TOPLEFT", 0, 0, locale.main, 60, 20, 
	function(self) 
		RandomRoll(1,llrSettings.mainRoll);
		toggleButtons(false);
	end
);

LPTLootRoll_LeaderWindow.rollFrame.offSpeccButton = functions.startButton(LPTLootRoll_LeaderWindow.rollFrame, "TOPLEFT", "TOPLEFT", 0, -24, locale.off, 60, 20, 
	function(self) 
		RandomRoll(1,llrSettings.offRoll);
		toggleButtons(false);
	end
);

LPTLootRoll_LeaderWindow.rollFrame.mogButton = functions.startButton(LPTLootRoll_LeaderWindow.rollFrame, "TOPLEFT", "TOPLEFT", 0, -48, locale.mog, 60, 20, 
	function(self) 
		RandomRoll(1,llrSettings.mogRoll);
		toggleButtons(false);
	end
);

LPTLootRoll_LeaderWindow.rollFrame.otherButton = functions.startButton(LPTLootRoll_LeaderWindow.rollFrame, "TOPLEFT", "TOPLEFT", 0, -72, locale.other, 60, 20, 
	function(self) 
		StaticPopup_Show("LPTLootRoll_ManualRoll");
	end
);

LPTLootRoll_LeaderWindow.rollFrame.passButton = functions.startButton(LPTLootRoll_LeaderWindow.rollFrame, "TOPLEFT", "TOPLEFT", 0, -96, locale.pass, 60, 20, 
	function(self) 
		C_ChatInfo.SendAddonMessage("LPTLootRoll", variables.itemPrefixKey .. "-" .. variables.itemPassKey, "RAID");
		toggleButtons(false);
	end
);

--Initalize history buttons
LPTLootRoll_LeaderWindow.historyButtonFrame = CreateFrame("Frame", nil, LPTLootRoll_LeaderWindow);
LPTLootRoll_LeaderWindow.historyButtonFrame:SetSize(20,15);
LPTLootRoll_LeaderWindow.historyButtonFrame:SetPoint("TOPRIGHT", LPTLootRoll_LeaderWindow, "TOPRIGHT", -25, -10);

LPTLootRoll_LeaderWindow.historyButtonFrame.pageNumber = LPTLootRoll_LeaderWindow:CreateFontString(nil,"OVERLAY");
LPTLootRoll_LeaderWindow.historyButtonFrame.pageNumber:SetFontObject("GameFontHighLight");
LPTLootRoll_LeaderWindow.historyButtonFrame.pageNumber:SetPoint("RIGHT", LPTLootRoll_LeaderWindow.historyButtonFrame, "RIGHT", -50, 6);

LPTLootRoll_LeaderWindow.historyButtonFrame.nextHistoryPage 	= functions.startButton(LPTLootRoll_LeaderWindow.historyButtonFrame, "CENTER", "TOP", 0, 0, ">", 20, 20, function(self) scrollHistory(true) end);
LPTLootRoll_LeaderWindow.historyButtonFrame.previousHistoryPage = functions.startButton(LPTLootRoll_LeaderWindow.historyButtonFrame, "CENTER", "TOP", -22, 0, "<", 20, 20, function(self) scrollHistory(false) end);

LPTLootRoll_LeaderWindow.historyButtonFrame.nextHistoryPage:Disable();
LPTLootRoll_LeaderWindow.historyButtonFrame.previousHistoryPage:Disable();

--Initialize the frames for the rolled lists.
LPTLootRoll_LeaderWindow.mainFrame  = CreateFrame("Frame", nil, LPTLootRoll_LeaderWindow);
LPTLootRoll_LeaderWindow.offFrame   = CreateFrame("Frame", nil, LPTLootRoll_LeaderWindow);
LPTLootRoll_LeaderWindow.mogFrame   = CreateFrame("Frame", nil, LPTLootRoll_LeaderWindow);
LPTLootRoll_LeaderWindow.otherFrame = CreateFrame("Frame", nil, LPTLootRoll_LeaderWindow);

--Start the instance of the rolled list frames.
functions.scrollFrameFactory(LPTLootRoll_LeaderWindow.mainFrame, LPTLootRoll_LeaderWindow, 77, 21, locale.main, 120, 130, true);
functions.scrollFrameFactory(LPTLootRoll_LeaderWindow.offFrame, LPTLootRoll_LeaderWindow, 77, -77, locale.off, 120, 130, true);
functions.scrollFrameFactory(LPTLootRoll_LeaderWindow.mogFrame, LPTLootRoll_LeaderWindow, 207, 21, locale.mog, 120, 130, true);
functions.scrollFrameFactory(LPTLootRoll_LeaderWindow.otherFrame, LPTLootRoll_LeaderWindow, 207, -77, locale.otherMax, 120, 130, true);

--Enable hyperlinks for all message frames, to allow for clickable names.
LPTLootRoll_LeaderWindow.mainFrame.messageFrame:SetHyperlinksEnabled(1);
LPTLootRoll_LeaderWindow.mainFrame.messageFrame:SetScript("OnHyperlinkEnter", playerMouseover);
LPTLootRoll_LeaderWindow.mainFrame.messageFrame:SetScript("OnHyperlinkLeave", functions.hideGametoolTip);
LPTLootRoll_LeaderWindow.mainFrame.messageFrame:SetScript('OnHyperlinkClick', hyperLinkClick);

LPTLootRoll_LeaderWindow.offFrame.messageFrame:SetHyperlinksEnabled(1);
LPTLootRoll_LeaderWindow.offFrame.messageFrame:SetScript("OnHyperlinkEnter", playerMouseover);
LPTLootRoll_LeaderWindow.offFrame.messageFrame:SetScript("OnHyperlinkLeave", functions.hideGametoolTip);
LPTLootRoll_LeaderWindow.offFrame.messageFrame:SetScript('OnHyperlinkClick', hyperLinkClick);

LPTLootRoll_LeaderWindow.mogFrame.messageFrame:SetHyperlinksEnabled(1);
LPTLootRoll_LeaderWindow.mogFrame.messageFrame:SetScript("OnHyperlinkEnter", playerMouseover);
LPTLootRoll_LeaderWindow.mogFrame.messageFrame:SetScript("OnHyperlinkLeave", functions.hideGametoolTip);
LPTLootRoll_LeaderWindow.mogFrame.messageFrame:SetScript('OnHyperlinkClick', hyperLinkClick);

LPTLootRoll_LeaderWindow.otherFrame.messageFrame:SetHyperlinksEnabled(1);
LPTLootRoll_LeaderWindow.otherFrame.messageFrame:SetScript("OnHyperlinkEnter", playerMouseover);
LPTLootRoll_LeaderWindow.otherFrame.messageFrame:SetScript("OnHyperlinkLeave", functions.hideGametoolTip);
LPTLootRoll_LeaderWindow.otherFrame.messageFrame:SetScript('OnHyperlinkClick', hyperLinkClick);


-----------------------
---GLOBAL FUNCTIONS----
-----------------------


--Function for resetting all roll and item history.
function functions.resetItemAndRollHistory()
	historyIndex = 1;

	clearFrame(LPTLootRoll_LeaderWindow.mainFrame.messageFrame);
	clearFrame(LPTLootRoll_LeaderWindow.offFrame.messageFrame);
	clearFrame(LPTLootRoll_LeaderWindow.mogFrame.messageFrame);
	clearFrame(LPTLootRoll_LeaderWindow.otherFrame.messageFrame);
	
	table.wipe(variables.rollHistory);

	LPTLootRoll_LeaderWindow.historyButtonFrame.pageNumber:SetText("");
	LPTLootRoll_LeaderWindow.itemButton:SetNormalTexture(nil);
	LPTLootRoll_LeaderWindow.historyButtonFrame.nextHistoryPage:SetEnabled(false);
	LPTLootRoll_LeaderWindow.historyButtonFrame.previousHistoryPage:SetEnabled(false);
end

--Function for starting the leader window upon a new item drop.
function functions.leaderEvent(isUsable)
	functions.displayLeaderWindow();
	
	--If leader can equip, enable buttons, otherwise disable.
	toggleButtons(isUsable);
end


-----------------------
---WINDOW FUNCTIONS----
-----------------------


--Function to display the leader window.
function functions.displayLeaderWindow()
	historyIndex = 1;

	--Toggle LPTLootRoll_LeaderWindow UI.
	if not LPTLootRoll_LeaderWindow:IsShown() then
		LPTLootRoll_LeaderWindow:Show();
	end 

	scrollHistory();
end

--Function for controlling the event listener for rolls.
function functions.controlRollListener()
	if llrSettings.eventMode or LPTLootRoll_LeaderWindow:IsShown() then
		LPTLootRoll_LeaderWindow:RegisterEvent("CHAT_MSG_SYSTEM");
	else
		LPTLootRoll_LeaderWindow:UnregisterEvent("CHAT_MSG_SYSTEM"); 
	end
end

--Function for closing the leader window.
function functions.closeLeaderWindow()
	if LPTLootRoll_LeaderWindow:IsShown() then
		LPTLootRoll_LeaderWindow:Hide();
	end
end

--Function for resetting leader window.
function functions.resetLeaderWindow()
	LPTLootRoll_LeaderWindow:ClearAllPoints();
	LPTLootRoll_LeaderWindow:SetPoint("CENTER", UIParent, "CENTER");
end

--Function for updating scale of the leader window.
function functions.updateLeaderScale()
	LPTLootRoll_LeaderWindow:SetScale(variables.screenScale*llrSettings.leaderScale);
end

--Function to disable leader roll buttons.
function functions.disableLeader()
	if LPTLootRoll_LeaderWindow:IsShown() then
		toggleButtons(false);
	end
end

--Update the names of the lists to reflect their values.
function functions.updateLeaderWindowTitles()
	LPTLootRoll_LeaderWindow.mainFrame.title:SetText(locale.mainMax());
	LPTLootRoll_LeaderWindow.offFrame.title:SetText(locale.offMax());
	LPTLootRoll_LeaderWindow.mogFrame.title:SetText(locale.mogMax());
end

--Update the roller number whenever a new message is recieved.
function functions.updateRollerCounter()
	if not LPTLootRoll_LeaderWindow:IsShown() then
		return;
	end

	local potential, finished = 0, 0;

	for i, v in pairs(variables.rollHistory[historyIndex].potentialRollers) do

		potential = potential + 1;

		if v then
			finished = finished + 1;
		end
	end

	local statusColor = (finished == potential and "|cff00ff00" or (finished > 0 and "|cffffff00" or "|cffff0000"));
 	
	LPTLootRoll_LeaderWindow.potentialRollers.text:SetText(locale.rollers .. ": " .. statusColor .. finished .. " / " .. potential);
end