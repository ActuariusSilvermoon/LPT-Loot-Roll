-----------------------
-------VARIABLES-------
-----------------------


local ADDON_NAME, namespace = ...;
local functions = namespace.functions;
local variables = namespace.variables;
local locale = namespace.locale;

local LPTLootRoll_MainFrame = CreateFrame("Frame");


-----------------------
-----EVENT HANDLING----
-----------------------


LPTLootRoll_MainFrame:RegisterEvent("CHAT_MSG_RAID_WARNING");
LPTLootRoll_MainFrame:RegisterEvent('GROUP_ROSTER_UPDATE');
LPTLootRoll_MainFrame:RegisterEvent("CHAT_MSG_ADDON");

LPTLootRoll_MainFrame:SetScript("OnEvent",
	function(self, event, ...)
		variables.events[event](...);
	end
);


-----------------------
----GLOBAL FUNCTIONS---
-----------------------


--Function for toggeling the tradeable item listener.
function functions.toggleLootListener()
	if llrSettings.lootListener and UnitInRaid("player") then
		LPTLootRoll_MainFrame:RegisterEvent("ENCOUNTER_LOOT_RECEIVED");
	else 
		LPTLootRoll_MainFrame:UnregisterEvent("ENCOUNTER_LOOT_RECEIVED");
	end
end