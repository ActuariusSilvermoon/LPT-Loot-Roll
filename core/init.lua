-----------------------
-------VARIABLES-------
-----------------------

local _, namespace = ...;
local variables = {};
local functions = {};
local locale = {};

namespace.variables = variables;
namespace.functions = functions;
namespace.locale = locale;

variables.clientLanguage = GetLocale();

local loadFrame = CreateFrame("FRAME");


-----------------------
-----EVENT HANDLING----
-----------------------

--Initial check to see if addon variables exist, if they don't, create them.
loadFrame:RegisterEvent("ADDON_LOADED");

loadFrame:SetScript("OnEvent",
	function(_, event, addonName, ...)
		if event == "ADDON_LOADED" and addonName == "LPT Loot Roll" then
			--Main setting table.
			if not llrSettings then 
				llrSettings = {};
			end

			--History database control.
			if not rollHistoryDB then 
				rollHistoryDB = {};
			end

			if not rollHistoryDB.rollHistory then
				rollHistoryDB.rollHistory = {};
			end

			--Booleans.
			if not llrSettings.leadMode then
				llrSettings.leadMode = false;
			end

			if not llrSettings.scrollMode then
				llrSettings.scrollMode = false;
			end

			if not llrSettings.saveMode then
				llrSettings.saveMode = false;
			end

			if not llrSettings.eventMode then
				llrSettings.eventMode = false;
			end

			if not llrSettings.assistMode then
				llrSettings.assistMode = false;
			end

			if not llrSettings.lootListener then 
				llrSettings.lootListener = false;
			end

			if not llrSettings.whisperListener then
				llrSettings.whisperListener = false;
			end

			if not llrSettings.masterLooterMode then
				llrSettings.masterLooterMode = false;
			end

			if not llrSettings.whisperNotificationMode then
				llrSettings.whisperNotificationMode = false;
			end

			--Integers.
			if not llrSettings.leaderScale then
				llrSettings.leaderScale = 1;
			end

			if not llrSettings.userScale then
				llrSettings.userScale = 1;
			end

			if not llrSettings.itemListScale then
				llrSettings.itemListScale = 1;
			end

			if not llrSettings.mainRoll then
				llrSettings.mainRoll = 100;
			end

			if not llrSettings.offRoll then
				llrSettings.offRoll = 50;
			end

			if not llrSettings.mogRoll then
				llrSettings.mogRoll = 25;
			end

			if not llrSettings.historyLength then
				llrSettings.historyLength = 20;
			end

			--Strings.
			if not llrSettings.masterLooter then
				llrSettings.masterLooter = "";
			end

			--Save mode binding.
			if llrSettings.saveMode then
				variables.rollHistory = rollHistoryDB.rollHistory;

				--Pre cache history items.
				for _, v in ipairs(variables.rollHistory) do
					C_Item.GetItemInfo(v.item);
				end
			end

			--Create startup variables.
			variables.screenScale = functions.calculateScale();
			variables.addonLoaded = true;

			--Run startup functions.
			functions.updateConfigWindow();
			functions.toggleLootListener();
			functions.updateLeaderWindowTitles();
			functions.toggleWhisperListener();
			functions.controlRollListener();

			loadFrame:UnregisterEvent("ADDON_LOADED");
		end
	end
);