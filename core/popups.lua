-----------------------
-------VARIABLES-------
-----------------------


local _, namespace = ...;
local variables = namespace.variables;
local functions = namespace.functions;
local locale = namespace.locale;

local masterLooter = "";


-----------------------
----LOCAL FUNCTIONS----
-----------------------


--Function for transmitting the tradeable item to the leader/player's itemList.
local function sendTradeableFunc(self)
	local input = self:GetEditBox():GetText();

	if UnitPlayerOrPetInRaid(input) then
		local _, link = C_Item.GetItemInfo(self.data);

		if input == variables.playerName then
			functions.registerItem(input, link);
		else
			SendChatMessage(link, "WHISPER", nil, input);
		end

		masterLooter = input;
	else
		functions.printOut(locale.sendTradeableError);
	end

	self:Hide();
end

--Function for handling manual rolls.
local function manualRoll(self)
	local number = self:GetEditBox():GetNumber();

	if number then
		functions.hideUser();
		functions.disableLeader();

		RandomRoll(1, number);
	end

	self:Hide();
end

--Function for checking if the player is on the same realm. If not then change the name of roller to be their name + realm.
local function realmCheck(roller)
	if UnitRealmRelationship(roller) ~= 1 then
		local name, realm = UnitName(roller);
		roller = name .. "-" .. realm;
	end

	return roller;
end

--Function for sending the whisper notification.
local function sendWhisperNotification(owner, winner, item, rollType)
	--Make sure both players are in the raid group.
	if not (UnitPlayerOrPetInRaid(owner) and UnitPlayerOrPetInRaid(winner)) then
		functions.printOut(locale.ownerOrWinnerNotInGroup);
		return;
	end

	--Edit the names to include the realm name if they are on a different server than you.
	owner = realmCheck(owner);
	winner = realmCheck(winner);

	--If the winner is the original owner of the item, then tell them to keep it.
	if winner == owner then
		SendChatMessage(locale.whisperKeepItem(item), "WHISPER", "Common", owner);
		return;
	end

	--Check if the distributer is the winner of the item, if so then don't send a trade message to yourself.
	if winner ~= variables.playerName then
		SendChatMessage(locale.whisperTradeOwner(owner, item) , "WHISPER", "Common", winner);
	end

	--Check if the distributer is the owner of the item, if so then don't send a give message to yourself.
	if owner ~= variables.playerName then
		SendChatMessage(locale.whisperGiveWinner(item, winner, rollType), "WHISPER", "Common", owner);
	end
end

--Function for sending winenr in raid warning.
local function sendRaidWarningNotification(owner, winner, item, rollType)
	local itemName = C_Item.GetItemInfo(item);

	local msg =
	(
		owner == winner and 
			locale.raidWarningOwnerKeeps(owner, itemName)
		or
			locale.raidWarningGiveWinner(winner, itemName, owner, rollType, roll)
	);

	SendChatMessage(msg, "RAID_WARNING", nil, nil);
end


-----------------------
-----POPUP WINDOWS-----
-----------------------


--Pop up for manual rolls.
StaticPopupDialogs["LPTLootRoll_ManualRoll"] =
{
	text = locale.manualRollText,
	button1 = locale.acceptButton,
	button2 = locale.cancelButton,
	hasEditBox = 1,
	maxLetters = 4,
	OnShow =
		function(self)
			local editBox = self:GetEditBox();
			editBox:SetText("");
			editBox:SetFocus();
			editBox:SetNumeric(true);
		end,
	OnAccept =
		function(self)
			manualRoll(self);
		end,
	EditBoxOnEnterPressed =
		function(self)
			manualRoll(self:GetParent());
		end,
	EditBoxOnEscapePressed =
		function(self)
			self:GetParent():Hide();
		end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

--Pop up for resetting history.
StaticPopupDialogs["LPTLootRoll_ClearHistory"] = 
{
	text = locale.clearHistoryText,
	button1 = locale.acceptButton,
	button2 = locale.cancelButton,
	OnAccept =
		function(_)
			functions.resetItemAndRollHistory();
			functions.printOut(locale.clearHistoryOutput);
		end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

--Pop up for resetting locations.
StaticPopupDialogs["LPTLootRoll_ResetPosition"] =
{
	text = locale.resetPositionText,
	button1 = locale.acceptButton,
	button2 = locale.cancelButton,
	OnAccept =
	function(_)
		functions.resetUserWindow();
        functions.resetLeaderWindow();
        functions.resetItemListWindow();
		functions.printOut(locale.resetPositionOutput);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

--Pop up for sending unwanted loot.
StaticPopupDialogs["LPTLootRoll_SendTradeable"] =
{
	text = locale.sendTradeableText,
	button1 = locale.acceptButton,
	button2 = locale.cancelButton,
	hasItemFrame = 1,
	hasEditBox = 1,
	maxLetters = 24,
	OnShow =
	function(self)
		local editBox = self:GetEditBox();

		if llrSettings.masterLooterMode then
			masterLooter = llrSettings.masterLooter;
		end

		if masterLooter == "" or not (UnitPlayerOrPetInRaid(masterLooter) and (UnitIsGroupAssistant(masterLooter) or UnitIsGroupLeader(masterLooter))) then
			masterLooter = functions.getRaidLeader();
		end

		editBox:SetPoint("BOTTOM", 0, 90);
		editBox:SetText(masterLooter or "");
		editBox:SetAutoFocus(false);
		editBox:ClearFocus();
	end,
	OnAccept =
		function(self)
			sendTradeableFunc(self);
		end,
	EditBoxOnEnterPressed =
		function(self)
			sendTradeableFunc(self:GetParent());
		end,
	EditBoxOnEscapePressed =
		function(self)
			self:ClearFocus();
		end,
	OnHide =
		function(self)
			functions.popTradeable();
		end,
	timeout = 0,
	whileDead = 1,
	noCancelOnReuse = 1,
	hideOnEscape = 1
};

--Pop up for accepting settings rolls.
StaticPopupDialogs["LPTLootRoll_SettingShare"] = {
	text = locale.settingShareText,
	button1 = locale.acceptButton,
	button2 = locale.cancelButton,
	OnAccept = 
	function(_, msg)
		--If user accepts the data, parse it to numbers and store it in settings.
		local main, off, mog = strsplit("-", msg);

		main = tonumber(main);
		off  = tonumber(off);
		mog  = tonumber(mog);

		if not (main and off and mog) then
			return;
		end

		llrSettings.mainRoll = main;
		llrSettings.offRoll = off;
		llrSettings.mogRoll = mog;

		functions.printOut(locale.settingShareOutput)
		functions.printOut(locale.main .. ": " .. main);
		functions.printOut(locale.off .. ": " .. off);
		functions.printOut(locale.mog .. ": " .. mog);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

--Pop up for distributing loot.
StaticPopupDialogs["LPTLootRoll_DistributeItem"] =
{
	text = locale.distributeItemText("%s", "%s"),
	button1 = locale.acceptButton,
	button2 = locale.cancelButton,
	OnAccept = 
	function(_, msg)
		local winner, rollType = strsplit("-", msg);

		if not winner or not rollType then
			return;
		end

		local owner = (variables.rollHistory[1].owner and variables.rollHistory[1].owner.name or nil);

		variables.rollHistory[1].distributed = true;

		--Close leader window unless whisperlistener is enabled and there are more items to distribute.
		if not (llrSettings.whisperListener and #variables.itemsToRoll > 0) then
			functions.closeLeaderWindow();
		end

		if llrSettings.whisperNotificationMode then
			sendWhisperNotification(owner, winner, variables.rollHistory[1].item, rollType);
		else
			sendRaidWarningNotification(owner, winner, variables.rollHistory[1].item, rollType);
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};