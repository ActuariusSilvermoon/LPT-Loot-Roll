-----------------------
----LOCAL VARIABLES----
-----------------------


local _, namespace = ...;
local functions = namespace.functions;
local variables = namespace.variables;
local locale = namespace.locale;

local LPTLootRoll_ConfigWindow = CreateFrame("FRAME", "LPTLootRoll_Config", UIParent);

--Add config to standard wow interface window.
local category = Settings.RegisterCanvasLayoutCategory(LPTLootRoll_ConfigWindow, "LPT Loot Roll");
Settings.RegisterAddOnCategory(category);


-----------------------
----LOCAL FUNCTIONS----
-----------------------


--Function for calculating the movement of a slider.
local function sliderCalc(frame, value)
	local halfStep = frame.stepValue / 2;
	value = value + halfStep - (value + halfStep) % frame.stepValue;
	_G[frame:GetName().."Text"]:SetText(value);
	return value;
end

--Function for selecting what mode history is stored, is it temporary or stored between sessions.
local function rollHistoryMode()
	if llrSettings.saveMode then 
		variables.rollHistory = rollHistoryDB.rollHistory;
	else
		table.wipe(rollHistoryDB.rollHistory);
	end
end

--Function for saving data from config window and closing it.
local function saveData()
	if not variables.addonLoaded then
		return;
	end

	local masterLooter			  = LPTLootRoll_ConfigWindow.masterLooterFrame.editBox:GetText();
	local mainRoll   			  = LPTLootRoll_ConfigWindow.mainSettingFrame.editBox:GetNumber();
	local offRoll   			  = LPTLootRoll_ConfigWindow.offSettingFrame.editBox:GetNumber();
	local mogRoll 	  		  	  = LPTLootRoll_ConfigWindow.mogSettingFrame.editBox:GetNumber();
	local historyLength 		  = LPTLootRoll_ConfigWindow.historySettingFrame.editBox:GetNumber();

	local leadMode   			  = _G["LPTLootRoll_LeadMode"]:GetChecked();
	local scrollMode   			  = _G["LPTLootRoll_ScrollMode"]:GetChecked();
	local saveMode   			  = _G["LPTLootRoll_SaveMode"]:GetChecked();
	local eventMode     		  = _G["LPTLootRoll_EventMode"]:GetChecked();
	local assistMode	 		  = _G["LPTLootRoll_AssistMode"]:GetChecked();
	local lootListener 			  = _G["LPTLootRoll_LootListener"]:GetChecked();
	local whisperListener 		  = _G["LPTLootRoll_WhisperListener"]:GetChecked();
	local masterLooterMode 		  = _G["LPTLootRoll_MasterLooterMode"]:GetChecked();
	local whisperNotificationMode = _G["LPTLootRoll_WhisperNotificationMode"]:GetChecked();

	if
		mainRoll 	  == offRoll or 
		mainRoll 	  == mogRoll or 
		offRoll  	  == mogRoll or
		mainRoll 	  == 0 or
		offRoll  	  == 0 or
		mogRoll 	  == 0 or
		historyLength == 0
	then
		print("");
		functions.printOut(locale.invalidConfigValues);
		print("");
		return;
	end

	llrSettings.mainRoll 	   	 		= mainRoll;
	llrSettings.offRoll 	   	 		= offRoll;
	llrSettings.mogRoll 	  	 		= mogRoll;
	llrSettings.historyLength 	 		= historyLength;
	llrSettings.masterLooter 	 		= masterLooter;

	llrSettings.leadMode 	  	 		= leadMode;
	llrSettings.scrollMode 	  	 		= scrollMode;
	llrSettings.saveMode 	  	 		= saveMode;
	llrSettings.eventMode	  	 		= eventMode;
	llrSettings.assistMode 		 		= assistMode;
	llrSettings.lootListener 	 		= lootListener;
	llrSettings.whisperListener  		= whisperListener;
	llrSettings.masterLooterMode 		= masterLooterMode;
	llrSettings.whisperNotificationMode = whisperNotificationMode;

	rollHistoryMode();
	functions.controlRollListener();
	functions.historyLengthControl();
	functions.toggleWhisperListener();
	functions.toggleLootListener();
	functions.updateLeaderWindowTitles();
end

--Function for sharing the roll settings of the user.
local function shareSettings()
	if not IsShiftKeyDown() then
		return;
	end

	local msg = "[LPTLootRoll: " .. variables.playerName .. " - " .. llrSettings.mainRoll .. "-" .. llrSettings.offRoll .. "-" .. llrSettings.mogRoll .. "]";
	local editbox = GetCurrentKeyBoardFocus();

	if editbox then
		editbox:Insert(msg);
	end
end

--Function for setting values of config to default.
local function setValuesToDefault()
	LPTLootRoll_ConfigWindow.masterLooterFrame.editBox:SetText("");
	LPTLootRoll_ConfigWindow.mainSettingFrame.editBox:SetNumber(100);
	LPTLootRoll_ConfigWindow.offSettingFrame.editBox:SetNumber(50);
	LPTLootRoll_ConfigWindow.mogSettingFrame.editBox:SetNumber(25);
	LPTLootRoll_ConfigWindow.historySettingFrame.editBox:SetNumber(20);

	LPTLootRoll_ConfigWindow.userScaleSlider:SetValue(1);
	LPTLootRoll_ConfigWindow.leaderScaleSlider:SetValue(1);
	LPTLootRoll_ConfigWindow.itemListScaleSlider:SetValue(1);

	_G["LPTLootRoll_LeadMode"]:SetChecked(false);
	_G["LPTLootRoll_ScrollMode"]:SetChecked(false);
	_G["LPTLootRoll_SaveMode"]:SetChecked(false);
	_G["LPTLootRoll_EventMode"]:SetChecked(false);
	_G["LPTLootRoll_AssistMode"]:SetChecked(false);
	_G["LPTLootRoll_LootListener"]:SetChecked(false);
	_G["LPTLootRoll_WhisperListener"]:SetChecked(false);
	_G["LPTLootRoll_MasterLooterMode"]:SetChecked(false);
	_G["LPTLootRoll_WhisperNotificationMode"]:SetChecked(false);
end


-----------------------
-----CONFIG WINDOW-----
-----------------------


--Add logo image.
local configLogo = LPTLootRoll_ConfigWindow:CreateTexture(nil,"BACKGROUND",nil,-8)
configLogo:SetTexture("Interface\\AddOns\\LPT Loot Roll\\textures\\logo.tga")
configLogo:SetSize(256,256);
configLogo:SetPoint("CENTER", 0, 0);

--Create and set title of the config window.
LPTLootRoll_ConfigWindow.title = LPTLootRoll_ConfigWindow:CreateFontString(nil,"OVERLAY");
LPTLootRoll_ConfigWindow.title:SetFontObject("GameFontNormalLarge");
LPTLootRoll_ConfigWindow.title:SetPoint("CENTER", LPTLootRoll_ConfigWindow, "CENTER", 0, -140);
LPTLootRoll_ConfigWindow.title:SetText("Version: " .. C_AddOns.GetAddOnMetadata("LPT Loot Roll", "Version"));

--Create checkboxes.
functions.checkButtonFactory("LPTLootRoll_LeadMode", LPTLootRoll_ConfigWindow, 12, -30, locale.leadModeTitle, locale.leadModeDescription);
functions.checkButtonFactory("LPTLootRoll_ScrollMode", LPTLootRoll_ConfigWindow, 12, -60, locale.scrollModeTitle, locale.scrollModeDescription);
functions.checkButtonFactory("LPTLootRoll_SaveMode", LPTLootRoll_ConfigWindow, 12, -90, locale.saveModeTitle, locale.saveModeDescription);
functions.checkButtonFactory("LPTLootRoll_EventMode", LPTLootRoll_ConfigWindow, 12, -120, locale.eventModeTitle, locale.eventModeDescription);
functions.checkButtonFactory("LPTLootRoll_AssistMode", LPTLootRoll_ConfigWindow, 12, -150, locale.assistModeTitle, locale.assistModeDescription);
functions.checkButtonFactory("LPTLootRoll_LootListener", LPTLootRoll_ConfigWindow, 12, -180, locale.lootListenerTitle, locale.lootListenerDescription);
functions.checkButtonFactory("LPTLootRoll_WhisperListener", LPTLootRoll_ConfigWindow, 12, -210, locale.whisperListenerTitle, locale.whisperListenerDescription);
functions.checkButtonFactory("LPTLootRoll_MasterLooterMode", LPTLootRoll_ConfigWindow, 12, -240, locale.masterLooterModeTitle, locale.masterLooterModeDescription);
functions.checkButtonFactory("LPTLootRoll_WhisperNotificationMode", LPTLootRoll_ConfigWindow, 12, -270, locale.whisperNotificationModeTitle, locale.whisperNotificationModeDescription);

--Create frames to hold the roll settings.
LPTLootRoll_ConfigWindow.masterLooterFrame 	 = CreateFrame("Frame", nil, LPTLootRoll_ConfigWindow);
LPTLootRoll_ConfigWindow.mainSettingFrame 	 = CreateFrame("Frame", nil, LPTLootRoll_ConfigWindow);
LPTLootRoll_ConfigWindow.offSettingFrame 	 = CreateFrame("Frame", nil, LPTLootRoll_ConfigWindow);
LPTLootRoll_ConfigWindow.mogSettingFrame 	 = CreateFrame("Frame", nil, LPTLootRoll_ConfigWindow);
LPTLootRoll_ConfigWindow.historySettingFrame = CreateFrame("Frame", nil, LPTLootRoll_ConfigWindow);

--Create the editBox frames.
LPTLootRoll_ConfigWindow.masterLooterFrame.editBox 	 = CreateFrame("EditBox", nil, LPTLootRoll_ConfigWindow.masterLooterFrame, "InputBoxTemplate");
LPTLootRoll_ConfigWindow.mainSettingFrame.editBox 	 = CreateFrame("EditBox", nil, LPTLootRoll_ConfigWindow.mainSettingFrame, "InputBoxTemplate");
LPTLootRoll_ConfigWindow.offSettingFrame.editBox 	 = CreateFrame("EditBox", nil, LPTLootRoll_ConfigWindow.offSettingFrame, "InputBoxTemplate");
LPTLootRoll_ConfigWindow.mogSettingFrame.editBox 	 = CreateFrame("EditBox", nil, LPTLootRoll_ConfigWindow.mogSettingFrame, "InputBoxTemplate");
LPTLootRoll_ConfigWindow.historySettingFrame.editBox = CreateFrame("EditBox", nil, LPTLootRoll_ConfigWindow.historySettingFrame, "InputBoxTemplate");

--Initialize the loot master name editbox.
functions.editBoxFactory(LPTLootRoll_ConfigWindow.masterLooterFrame, LPTLootRoll_ConfigWindow.masterLooterFrame.editBox, LPTLootRoll_ConfigWindow, 12, 115, locale.masterLooterEditBox, nil, false, 24, 100);

--Initialize the roll setting frames.
functions.editBoxFactory(LPTLootRoll_ConfigWindow.mainSettingFrame, LPTLootRoll_ConfigWindow.mainSettingFrame.editBox, LPTLootRoll_ConfigWindow, 12, 70, locale.mainValueEditBox, LPTLootRoll_ConfigWindow.offSettingFrame, true);
functions.editBoxFactory(LPTLootRoll_ConfigWindow.offSettingFrame, LPTLootRoll_ConfigWindow.offSettingFrame.editBox, LPTLootRoll_ConfigWindow, 12, 30, locale.offValueEditBox, LPTLootRoll_ConfigWindow.mogSettingFrame, true);
functions.editBoxFactory(LPTLootRoll_ConfigWindow.mogSettingFrame, LPTLootRoll_ConfigWindow.mogSettingFrame.editBox, LPTLootRoll_ConfigWindow, 12, -10, locale.mogValueEditBox, LPTLootRoll_ConfigWindow.historySettingFrame, true);

--Initialize the history length setting editbox.
functions.editBoxFactory(LPTLootRoll_ConfigWindow.historySettingFrame, LPTLootRoll_ConfigWindow.historySettingFrame.editBox, LPTLootRoll_ConfigWindow, 12, -50, locale.historyLengthEditBox, LPTLootRoll_ConfigWindow.mainSettingFrame, true);

--Create the sliders.
LPTLootRoll_ConfigWindow.userScaleSlider   		= CreateFrame("Slider", "LLR_User_Scaler", LPTLootRoll_ConfigWindow, "OptionsSliderTemplate");
LPTLootRoll_ConfigWindow.leaderScaleSlider 		= CreateFrame("Slider", "LLR_Leader_Scaler", LPTLootRoll_ConfigWindow, "OptionsSliderTemplate");
LPTLootRoll_ConfigWindow.itemListScaleSlider 	= CreateFrame("Slider", "LLR_Item_List_Scaler", LPTLootRoll_ConfigWindow, "OptionsSliderTemplate");

--Use factories to create the sliders, however add script outside of it as to prevent errors involving llrSettings global variable.
functions.sliderFactory(LPTLootRoll_ConfigWindow, LPTLootRoll_ConfigWindow.itemListScaleSlider, -12, 170, locale.itemListScaleTitle);
LPTLootRoll_ConfigWindow.itemListScaleSlider:SetScript("OnValueChanged", 
	function (_, value)
		llrSettings.itemListScale = sliderCalc(LPTLootRoll_ConfigWindow.itemListScaleSlider, value);
		functions.updateItemListScale();
	end
);

functions.sliderFactory(LPTLootRoll_ConfigWindow, LPTLootRoll_ConfigWindow.userScaleSlider, -12, 100, locale.userWindowScaleTitle);
LPTLootRoll_ConfigWindow.userScaleSlider:SetScript("OnValueChanged", 
	function (_, value)
		llrSettings.userScale = sliderCalc(LPTLootRoll_ConfigWindow.userScaleSlider, value);
		functions.updateUserScale();
	end
);

functions.sliderFactory(LPTLootRoll_ConfigWindow, LPTLootRoll_ConfigWindow.leaderScaleSlider, -12, 30, locale.leaderWindowScaleTitle);
LPTLootRoll_ConfigWindow.leaderScaleSlider:SetScript("OnValueChanged", 
	function (_, value)
		llrSettings.leaderScale = sliderCalc(LPTLootRoll_ConfigWindow.leaderScaleSlider, value);
		functions.updateLeaderScale();
	end
);

LPTLootRoll_ConfigWindow:Hide();
LPTLootRoll_ConfigWindow:SetScript("OnShow",
	function(_)
		functions.updateConfigWindow();
	end
);

LPTLootRoll_ConfigWindow:SetScript("OnHide",
	function(_)
		saveData();
	end
);

--Edit history editbox to have a max of two digits.
LPTLootRoll_ConfigWindow.historySettingFrame.editBox:SetMaxLetters(2);

--Create the share button.
LPTLootRoll_ConfigWindow.shareButton = functions.startButton(LPTLootRoll_ConfigWindow, "TOPRIGHT", "TOPRIGHT", -12, -30, locale.shareButtonTitle, 120, 30, function(_) shareSettings() end);

--Create share button tooltip.
LPTLootRoll_ConfigWindow.shareButton:SetScript("OnEnter",
function(self)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
	GameTooltip:ClearLines();
	GameTooltip:AddLine(locale.shareButtonDesc1);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(locale.shareButtonDesc2);
	GameTooltip:Show();
end);

LPTLootRoll_ConfigWindow.shareButton:SetScript("OnLeave", functions.hideGametoolTip);

--Create the clear data button.
LPTLootRoll_ConfigWindow.clearData = functions.startButton(LPTLootRoll_ConfigWindow, "TOPRIGHT", "TOPRIGHT", -12, -70, locale.clearDataButtonTitle, 120, 30, function(_) StaticPopup_Show("LPTLootRoll_ClearHistory") end);

--Create the reset position button.
LPTLootRoll_ConfigWindow.resetPosition = functions.startButton(LPTLootRoll_ConfigWindow, "TOPRIGHT", "TOPRIGHT", -12, -110, locale.resetPositionButtonTitle, 120, 30, function(_) StaticPopup_Show("LPTLootRoll_ResetPosition") end);


-----------------------
---GLOBAL FUNCTIONS----
-----------------------

--Updating the config windows values.
function functions.updateConfigWindow()
	if not variables.addonLoaded then
		return;
	end

	LPTLootRoll_ConfigWindow.mainSettingFrame.editBox:SetNumber(llrSettings.mainRoll);
	LPTLootRoll_ConfigWindow.offSettingFrame.editBox:SetNumber(llrSettings.offRoll);
	LPTLootRoll_ConfigWindow.mogSettingFrame.editBox:SetNumber(llrSettings.mogRoll);
	LPTLootRoll_ConfigWindow.historySettingFrame.editBox:SetNumber(llrSettings.historyLength);
	LPTLootRoll_ConfigWindow.masterLooterFrame.editBox:SetText(llrSettings.masterLooter);

	LPTLootRoll_ConfigWindow.userScaleSlider:SetValue(llrSettings.userScale);
	LPTLootRoll_ConfigWindow.leaderScaleSlider:SetValue(llrSettings.leaderScale);
	LPTLootRoll_ConfigWindow.itemListScaleSlider:SetValue(llrSettings.itemListScale);

	_G["LPTLootRoll_LeadMode"]:SetChecked(llrSettings.leadMode);
	_G["LPTLootRoll_ScrollMode"]:SetChecked(llrSettings.scrollMode);
	_G["LPTLootRoll_SaveMode"]:SetChecked(llrSettings.saveMode);
	_G["LPTLootRoll_EventMode"]:SetChecked(llrSettings.eventMode);
	_G["LPTLootRoll_AssistMode"]:SetChecked(llrSettings.assistMode);
	_G["LPTLootRoll_LootListener"]:SetChecked(llrSettings.lootListener);
	_G["LPTLootRoll_WhisperListener"]:SetChecked(llrSettings.whisperListener);
	_G["LPTLootRoll_MasterLooterMode"]:SetChecked(llrSettings.masterLooterMode);
	_G["LPTLootRoll_WhisperNotificationMode"]:SetChecked(llrSettings.whisperNotificationMode);
end

--Function for showing the config window.
function functions.toggleConfig()
	Settings.OpenToCategory(category:GetID());
end