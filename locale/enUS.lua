-----------------------
-----ENGLISH TABLE-----
-----------------------


local _, namespace = ...;
local variables = namespace.variables;
local locale = namespace.locale;


-----------------------
--------SHARED---------
-----------------------

locale.main = "Main";
locale.off = "Off";
locale.mog = "Mog";
locale.other = "Other";

function locale.userLeaderTitleText(owner)
    return "LPT" .. (owner and (" - Loot from: |c" .. owner.color .. owner.name) or "");
end

-----------------------
-----variables.lua-----
-----------------------

locale.commandArrayLeaderTitle = "leader";
locale.commandArrayLeaderDescription = "Displays the raid leader window.";
locale.commandArrayUserTitle = "user";
locale.commandArrayUserDescription = "Displays the normal user window.";
locale.commandArrayItemTitle = "item";
locale.commandArrayItemDescription = "Open the item list window.";
locale.commandArrayClearTitle = "clear";
locale.commandArrayClearDescription = "Clear all stored roll data.";
locale.commandArrayResetTitle = "reset";
locale.commandArrayResetDescription = "Resets position of windows.";
locale.commandArrayConfigTitle = "config";
locale.commandArrayConfigDescription = "Reset position of windows.";
locale.commandArrayHelpTitle = "help";
locale.commandArrayHelpDescription = "Open the config menu.";
locale.commandArrayDebugTitle = "debug";
locale.commandArrayDebugDescription = "Print debug information."


-----------------------
-----functions.lua-----
-----------------------

locale.commandNotRecognized = "Error: Command not recognized.";
locale.commandBlank = "Error: No command recieved.";
locale.commandAvailable = "Available commands are:";


-----------------------
-------popups.lua------
-----------------------

locale.sendTradeableError = "Player is not in the raid group.";
locale.ownerOrWinnerNotInGroup = "Owner or winner is not in the raid group.";

function locale.whisperKeepItem(item)
    return "You may keep " .. item .. ".";
end

function locale.whisperTradeOwner(owner, item)
    return "Trade " .. owner .. " for " .. item .. ".";
end

function locale.whisperGiveWinner(item, winner, rollType)
    return "Give " .. item .. " to " .. winner .. " for " .. rollType .. ".";
end

function locale.raidWarningOwnerKeeps(owner, itemName)
    return owner .. " keeps " .. itemName .. ".";
end

function locale.raidWarningGiveWinner(winner, itemName, owner, rollType, roll)
    return winner .. " wins " .. itemName .. (owner and (" from " .. owner) or "") .. " for " .. rollType .. " roll.";
end

locale.acceptButton = "Accept";
locale.cancelButton = "Cancel";

locale.manualRollText = "Enter roll (Max: 9999):";
locale.clearHistoryText = "Are you sure you want to reset roll history?";
locale.clearHistoryOutput = "LPT Loot Roll: Item history has been cleared.";
locale.resetPositionText = "Are you sure you want to reset window positions?";
locale.resetPositionOutput = "LPT Loot Roll: Location of windows have been reset.";
locale.sendTradeableText = "Do you want to list %s for trade? If accepted itemlink will be sent to the player below.";
locale.settingShareText = "Are you sure you want to change roll values?";
locale.settingShareOutput = "Roll values have been changed to:";

function locale.distributeItemText(name, rollType)
    return "Give item to " .. name .. " for " .. rollType .. "?";
end


-----------------------
---eventFunctions.lua--
-----------------------




-----------------------
--------main.lua-------
-----------------------




-----------------------
-------config.lua------
-----------------------

locale.invalidConfigValues = "LPT Loot Roll: Invalid settings, please try again. Values cannot be the same or set to 0.";

--Checkboxes
locale.leadModeTitle = "Enable leader mode.";
locale.leadModeDescription = "If checked, the leader window will always open for each item regardless of user having raid leader position or not.";
locale.scrollModeTitle = "Reverse roll list direction.";
locale.scrollModeDescription = "If checked, the roll lists will have highest values at top and lowest at bottom.";
locale.saveModeTitle = "Enable session loot memory.";
locale.saveModeDescription = "If checked, roll/loot history will be kept between sessions.";
locale.eventModeTitle = "Enable constant roll listener.";
locale.eventModeDescription = "If checked, the addon will ALWAYS listen for rolls even when the leader window is hidden.";
locale.assistModeTitle = "Enable assist loot distribution.";
locale.assistModeDescription = "If checked, the addon will allow loot to be distributed by raid assists, this is also required if a raid assist is going to be the master looter.";
locale.lootListenerTitle = "Enable tradeable loot listener.";
locale.lootListenerDescription = "If checked, a pop up window will show upon looting a tradeable item. Accepting the pop up will send the item in a whisper to master looter (defaulted as raid leader).";
locale.whisperListenerTitle = "Enable whisper listener.";
locale.whisperListenerDescription = "If checked and the user is raid leader/raid assist with assist loot enabled, the addon will display an itemlist that is populated by items sent in whisper.";
locale.masterLooterModeTitle = "Enable master looter override.";
locale.masterLooterModeDescription = "If checked, the master looter will always be overwritten to the name in the master looter input box, given they are in the raid group and have at least assist.";
locale.whisperNotificationModeTitle = "Enable whisper notifications.";
locale.whisperNotificationModeDescription = "If checked, when an item is distributed, instead of announcing loot winner in a raid warning, the addon will send a message to the winner and the owner of the distributed item.";

--Editboxes
locale.masterLooterEditBox = "Master looter override:";
locale.mainValueEditBox = "Main Roll Max Value:";
locale.offValueEditBox = "Off Roll Max Value:";
locale.mogValueEditBox = "Mog Roll Max Value:";
locale.historyLengthEditBox = "Max length of history:";

--Scales
locale.itemListScaleTitle = "Item list window scale";
locale.userWindowScaleTitle = "User window scale";
locale.leaderWindowScaleTitle = "Leader window scale";

--Buttons
locale.shareButtonTitle = "Share roll values";
locale.clearDataButtonTitle = "Clear history";
locale.resetPositionButtonTitle = "Reset positions";

locale.shareButtonDesc1 = "Shift click this button while having a chat window open in order to create a clickable link that other users can click.";
locale.shareButtonDesc2 = "If other users click the link, they will get a pop up asking them if they wish to accept your roll settings.";


-----------------------
-----userWindow.lua----
-----------------------




-----------------------
----leaderWindow.lua---
-----------------------

locale.itemDistributed = "Item has already been distributed.";

function locale.distributeItem(name)
    return "Click to give " .. name .. " the item.";
end

locale.possibleRollers = "Possible rollers:";
locale.reacted = "Reacted";
locale.notReacted = "Not reacted";
locale.pass = "Pass";

locale.otherMax = "Other (Max: 9999)";
function locale.mainMax()
    return "Main (Max: " .. llrSettings.mainRoll .. ")";
end

function locale.offMax()
    return "Off (Max: " .. llrSettings.offRoll .. ")";
end

function locale.mogMax() 
    return "Mog (Max: " .. llrSettings.mogRoll .. ")";
end

locale.rollers = "Rollers";


-----------------------
---itemListWindow.lua--
-----------------------

locale.itemListTitle = "LPT Item List";
locale.ctrlClickHelpText = "CTRL-click link to post that item.";

locale.postButtonTitle = "Post Item";
locale.skipButtonTitle = "Skip Item";