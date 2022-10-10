-----------------------
-------VARIABLES-------
-----------------------


local ADDON_NAME, namespace = ...;
local variables = namespace.variables;
local functions = namespace.functions;
local locale = namespace.locale;

--Create frame to hold tooltip for scanning.
CreateFrame("GameTooltip", "LPTLootRoll_ToolTip", nil, "GameTooltipTemplate");
LPTLootRoll_ToolTip:UnregisterAllEvents();
LPTLootRoll_ToolTip:SetOwner(UIParent, "ANCHOR_NONE");


-----------------------
-----SLASH FUNCTION----
-----------------------


SLASH_LPT1 = "/lpt";
SLASH_LPT2 = "/lptlootroll";
SLASH_LPT3 = "/llr";

SlashCmdList.LPT = 
function(msg)
	msg = strlower(msg);

	if variables.commandArray[msg] then
		variables.commandArray[msg].func();
		return;
	end
	
	print("");
	functions.printOut(GetAddOnMetadata("LPT Loot Roll", "Title") .. " version: " .. GetAddOnMetadata("LPT Loot Roll", "Version"));
	
	if msg and msg ~= "" then
		functions.printOut(locale.commandNotRecognized);
	else
		functions.printOut(locale.commandBlank);
	end

	functions.printCommands();
end


-----------------------
----FILTER FUNCTION----
-----------------------


--Filter function to replace a given string with a link that can directly cause functions to be run when clicked.
--As seen in the weakaura addon (https://github.com/WeakAuras/WeakAuras2/blob/master/WeakAuras/Transmission.lua), simplified for my usage.
local function filterFunction(_, _, msg, ...)
	local _, _, name, rollValues = msg:find("%[LPTLootRoll: ([^%s]+) %- ([^%]]+)%]");

	if name and rollValues then
		msg = "|Hgarrmission:lptlootroll:rollvalues&" .. rollValues .. "|h|cFF00CCFF[LPT Roll Settings: " .. name .. "]|h|r";
		return false, msg, ...;
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filterFunction);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", filterFunction);

--Get data from the custom hyperlinks.
hooksecurefunc("SetItemRef", 
	function(link, text)
		local linkType, addon, param1 = strsplit(":", link);

		if linkType ~= "garrmission" or addon ~= "lptlootroll" then
			return;
		end
		
		local key, value = strsplit("&", param1);

		if not key or not value then
			return;
		end

		if key == "rollvalues" then 
			local dialog = StaticPopup_Show("LPTLootRoll_SettingShare");

			if dialog then
				dialog.data = value;
			end
		elseif key == "command" then
			if variables.commandArray[value] then
				variables.commandArray[value].func();
			end
		elseif key == "roller" then
			local name, rollType = strsplit("-", value)
			local dialog = StaticPopup_Show("LPTLootRoll_DistributeItem", name, rollType);
			
			if dialog then
				dialog.data = value;
			end
		elseif key == "rollItem" then
			if IsControlKeyDown() then
				value = tonumber(value);

				if value then
					functions.popList(value, true);
				end
			end
		end
	end
);


-----------------------
----GLOBAL FUNCTIONS---
-----------------------


--Function for printing out all available commands
function functions.printCommands()
	print("");
	functions.printOut(locale.commandAvailable);
	
	for i, v in pairs(variables.commandArray) do
		print("|Hgarrmission:lptlootroll:command&" .. i .. "|h|cFF00CCFF[" .. i:gsub("^%l", strupper) .. "]|h|r|cFFFFFF00 - " .. v.description);
	end
end

--Custom printout method for yellow message printouts.
function functions.printOut(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg,1,1,0);
end

--Input the current item into the roll frame.
function functions.setItemButtonData(frame, link)
	frame:SetScript("OnMouseDown", 
		function(self,button) 
			if IsModifiedClick("CHATLINK") then 
				ChatEdit_InsertLink(link);
			elseif IsModifiedClick("DRESSUP") then 
				DressUpItemLink(link);
			elseif IsShiftKeyDown() and button=="RightButton" then 
				OpenAzeriteEmpoweredItemUIFromLink(link) 
			end 
		end
	);
	
	frame:SetNormalTexture(select(10,GetItemInfo(link)));
	
	frame:SetScript("OnEnter", 
		function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); 
			GameTooltip:ClearLines(); 
			GameTooltip:SetHyperlink(link); 
			GameTooltip:Show();
		end
	);

	frame:SetScript("OnLeave", functions.hideGametoolTip);
end

--Function for controlling length of history array.
function functions.historyLengthControl()
	while #variables.rollHistory >= llrSettings.historyLength do
		tremove(variables.rollHistory);
	end
end

--Get raidleader
function functions.getRaidLeader()
	for i = 1, GetNumGroupMembers() do
		local name, rank = GetRaidRosterInfo(i);

		if name and rank == 2 then
			return name;
		end
	end
end

--Function for calculating scaling value. When scaling for screens with a higher Y resolution than 1200, you have to take parentscale into the account for it to scale properly.
function functions.calculateScale()
	local yResolution = tonumber(strmatch(GetCVar("gxWindowedResolution"), "%d+x(%d+)"));
	local parentScale = UIParent:GetScale();

	return 768/yResolution/(yResolution > 1200 and parentScale or 1);
end

--Function for showing the config window.
function functions.toggleConfig()
	InterfaceOptionsFrame_OpenToCategory(LPTLootRoll_Config);

	if not LPTLootRoll_Config:IsShown() then
		InterfaceOptionsFrame_OpenToCategory(LPTLootRoll_Config);
	end
end

--Function for hiding tooltip on mouseover.
function functions.hideGametoolTip()
	GameTooltip:Hide();
	ResetCursor();
end

--Function for getting the class color of a given player.
function functions.getClassColor(player)
	local _, playerClass = UnitClass(player);
	
	return RAID_CLASS_COLORS[playerClass].colorStr;
end

--Function for checking if it is mog that the player does not know and can collect.
function functions.usableMog(link)
	local appearId, source = C_TransmogCollection.GetItemInfo(link);
	
	if not appearId or not source then
		return false;
	end

	local collectable = select(2, C_TransmogCollection.PlayerCanCollectSource(source));
	local sources = C_TransmogCollection.GetAppearanceSources(appearId);
	
	if sources and collectable then
		for i, v in pairs(sources) do
			if v.isCollected then 
				return false;
			end
		end
	end
	
	return collectable;
end

--Get the main stats of the item.
function functions.getItemValues(link)
	local valueTable = GetItemStats(link);

	local itemValues = {
		agility 	= valueTable["ITEM_MOD_AGILITY_SHORT"] ~= nil,
		strength 	= valueTable["ITEM_MOD_STRENGTH_SHORT"] ~= nil,
		intellect 	= valueTable["ITEM_MOD_INTELLECT_SHORT"] ~= nil,
		-- socket 		= valueTable["EMPTY_SOCKET_PRISMATIC"] ~= nil,
		-- speed 		= valueTable["ITEM_MOD_CR_SPEED_SHORT"] ~= nil,
		-- avoidance 	= valueTable["ITEM_MOD_CR_AVOIDANCE_SHORT"] ~= nil,
		-- lifesteal 	= valueTable["ITEM_MOD_CR_LIFESTEAL_SHORT"] ~= nil
	};

	return itemValues;
end

--Function for checking if stats of an item are appropriate for the player's class.
function functions.usableStats(stats)
	local agilityUsage   = stats.agility   and variables.classArray[variables.playerClassId].stats.agility;
	local strengthUsage  = stats.strength  and variables.classArray[variables.playerClassId].stats.strength;
	local intellectUsage = stats.intellect and variables.classArray[variables.playerClassId].stats.intellect;

	return agilityUsage or strengthUsage or intellectUsage;
end

--Function to reset LPT tooltip.
function functions.resetTooltip()
	for i = 1, LPTLootRoll_ToolTip:NumLines() or 0 do 
		local left = getglobal(LPTLootRoll_ToolTip:GetName() .. "TextLeft" .. i);
		local right = getglobal(LPTLootRoll_ToolTip:GetName() .. "TextRight" .. i);

		left:SetText();
		left:SetTextColor(0, 0, 0, 0);

		right:SetText();
		right:SetTextColor(0, 0, 0, 0);
	end
end

--Function to scan an item's tooltip for a given string.
function functions.tooltipHasString(searchString)
	for i = 1, LPTLootRoll_ToolTip:NumLines() or 0 do 
		local left = getglobal(LPTLootRoll_ToolTip:GetName() .. "TextLeft" .. i);
		local leftText = left:GetText() or "";
		
		if strlower(leftText):match(strlower(searchString)) then
			return true;
		end
	end

	return false;
end

--Function to scan an item's tooltip for a given string.
function functions.tooltipHasRedText()
	for i = 1, LPTLootRoll_ToolTip:NumLines() or 0 do 
		local left = getglobal(LPTLootRoll_ToolTip:GetName() .. "TextLeft" .. i);
		local right = getglobal(LPTLootRoll_ToolTip:GetName() .. "TextRight" .. i);

		local lr, lg, lb = left:GetTextColor()
		lr = floor(lr * 100 + 0.5) / 100
		lg = floor(lg * 100 + 0.5) / 100
		lb = floor(lb * 100 + 0.5) / 100

		local rr, rg, rb = right:GetTextColor();
		rr = floor(rr * 100 + 0.5) / 100
		rg = floor(rg * 100 + 0.5) / 100
		rb = floor(rb * 100 + 0.5) / 100

		if 
			lr == 1 and lg == 0.13 and lb == 0.13 or 
			rr == 1 and rg == 0.13 and rb == 0.13
		then
			return true;
		end
	end

	return false;
end

--Function for popping a tradeable item for the pop up of looted items.
function functions.popTradeable()
	if #variables.tradeableItemsQueue == 0 then 
		return;
	end

	local head = tremove(variables.tradeableItemsQueue, 1);
	local itemName, link, _, _, _, _, _, _, _, itemIcon = GetItemInfo(head);
	local data = {["name"] = itemName, ["link"] = link, ["texture"] = itemIcon};
	local dialog = StaticPopup_Show("LPTLootRoll_SendTradeable", link, _, data);

	if dialog then
		dialog.data = link;
	end
end

--Function for checking if a player is the leader of a group, or if the player is assist and assistmode has been enabled.
function functions.isLeaderOrAssistWithMode(player)
	return UnitIsGroupLeader(player) or (llrSettings.assistMode and UnitIsGroupAssistant(player));
end

--Function for adding data to log.
function functions.addToDebugHistory(input)
	while #variables.debugHistory >= 50 do
		tremove(variables.debugHistory, 1);
	end
	
	tinsert(
		variables.debugHistory,
		{
			date("%H:%M:%S"),
			input
		}
	)
end

--Function for printing debug history.
function functions.printDebugHistory()
	for i, v in pairs(variables.debugHistory) do
		functions.printOut(v[1] .. ": " .. v[2]);
	end
end