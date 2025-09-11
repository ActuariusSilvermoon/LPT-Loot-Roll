-----------------------
----LOCAL VARIABLES----
-----------------------


local _, namespace = ...
local functions = namespace.functions;
local variables = namespace.variables;
local locale = namespace.locale;

local LPTLootRoll_UserWindow = CreateFrame("Frame", "LPTLootRoll_User", nil, "BasicFrameTemplate");


-----------------------
-------USER WINDOW-----
-----------------------


LPTLootRoll_UserWindow:SetToplevel(true);
LPTLootRoll_UserWindow:SetSize(200, 90);
LPTLootRoll_UserWindow:SetMovable(true);
LPTLootRoll_UserWindow:EnableMouse(true);
LPTLootRoll_UserWindow:RegisterForDrag("LeftButton");
LPTLootRoll_UserWindow:SetPoint("CENTER");
LPTLootRoll_UserWindow:SetUserPlaced(true);
LPTLootRoll_UserWindow:SetClampedToScreen(true);
LPTLootRoll_UserWindow:SetClampRectInsets(0, 0, 0, 0);
LPTLootRoll_UserWindow:Hide();

LPTLootRoll_UserWindow:SetScript("OnDragStart", LPTLootRoll_UserWindow.StartMoving)
LPTLootRoll_UserWindow:SetScript("OnDragStop", LPTLootRoll_UserWindow.StopMovingOrSizing)
LPTLootRoll_UserWindow:SetScript("OnShow", functions.updateUserScale);

--Title of the window
LPTLootRoll_UserWindow.title = LPTLootRoll_UserWindow:CreateFontString(nil,"OVERLAY");
LPTLootRoll_UserWindow.title:SetFontObject("GameFontHighLight");
LPTLootRoll_UserWindow.title:SetPoint("LEFT", LPTLootRoll_UserWindow.TitleBg, "LEFT", 5, -1);
LPTLootRoll_UserWindow.title:SetText("LPT");

--User window item preview.
LPTLootRoll_UserWindow.itemButton = CreateFrame("Button", nil, LPTLootRoll_UserWindow, "GameMenuButtonTemplate");
LPTLootRoll_UserWindow.itemButton:SetPoint("LEFT", LPTLootRoll_UserWindow, "LEFT", 8, -10);
LPTLootRoll_UserWindow.itemButton:SetSize(60,60);

--Intialize the buttons.
LPTLootRoll_UserWindow.mainSpeccButton = functions.startButton(LPTLootRoll_UserWindow, "CENTER", "TOP", 0, -40, locale.main, 60, 30, 
	function(_)
		RandomRoll(1, llrSettings.mainRoll);
		LPTLootRoll_UserWindow:Hide();
	end
);

LPTLootRoll_UserWindow.offSpeccButton = functions.startButton(LPTLootRoll_UserWindow, "CENTER", "TOP", 0, -70, locale.off, 60, 30, 
	function(_)
		RandomRoll(1, llrSettings.offRoll);
		LPTLootRoll_UserWindow:Hide();
	end
);

LPTLootRoll_UserWindow.mogButton = functions.startButton(LPTLootRoll_UserWindow, "CENTER", "TOP", 60, -40, locale.mog, 60, 30, 
	function(_)
		RandomRoll(1, llrSettings.mogRoll);
		LPTLootRoll_UserWindow:Hide();
	end
);

LPTLootRoll_UserWindow.otherButton = functions.startButton(LPTLootRoll_UserWindow, "CENTER", "TOP", 60, -70, locale.other, 60, 30, 
	function(_)
		StaticPopup_Show("LPTLootRoll_ManualRoll");
	end
);


--Close window script.
LPTLootRoll_UserWindow.CloseButton:SetScript("OnClick",
function()
	C_ChatInfo.SendAddonMessage("LPTLootRoll", variables.itemPrefixKey .. "-" .. variables.itemPassKey, "RAID");
	functions.hideUser();
end);


-----------------------
---GLOBAL FUNCTIONS----
-----------------------


--Function for starting the user window upon new item drop.
function functions.userEvent(link, owner)
	--Setup the item "frame" with tooltip, mog and artifact system implementation.
	functions.setItemButtonData(LPTLootRoll_UserWindow.itemButton, link);
	functions.displayUser();

	LPTLootRoll_UserWindow.title:SetText(locale.userLeaderTitleText(owner));
end


-----------------------
---WINDOW FUNCTIONS----
-----------------------


--Function for displaying the user window.
function functions.displayUser()
	if not LPTLootRoll_UserWindow:IsShown() then
		LPTLootRoll_UserWindow:Show();
	end
end

--Function for hiding the user window.
function functions.hideUser()
	if LPTLootRoll_UserWindow:IsShown() then
		LPTLootRoll_UserWindow:Hide();
	end
end

--Function for resetting the user window position.
function functions.resetUserWindow()
	LPTLootRoll_UserWindow:ClearAllPoints();
	LPTLootRoll_UserWindow:SetPoint("CENTER", UIParent, "CENTER");
end

--Update the names of the lists to reflect their values.
function functions.updateUserWindowTitles()
	LPTLootRoll_UserWindow.mainFrame.title:SetText("Main");
	LPTLootRoll_UserWindow.offFrame.title:SetText("Off");
	LPTLootRoll_UserWindow.mogFrame.title:SetText("Mog");
end

--Function for updating the user window scale.
function functions.updateUserScale()
	LPTLootRoll_UserWindow:SetScale(variables.screenScale*llrSettings.userScale);
end