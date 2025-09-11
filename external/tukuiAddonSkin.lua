if not C_AddOns.IsAddOnLoaded("AddonSkins") then
	return;
end

local AS, L, S, R = unpack(AddOnSkins)

function AS:LPT_Loot_Roll(event, addon)

	--User window
	S:HandleFrame(LPTLootRoll_User);
	S:HandleButton(LPTLootRoll_User.mainSpeccButton);
	S:HandleButton(LPTLootRoll_User.offSpeccButton);
	S:HandleButton(LPTLootRoll_User.mogButton);
	S:HandleButton(LPTLootRoll_User.otherButton);


	--Leader window.
	S:HandleFrame(LPTLootRoll_Leader);
	S:HandleButton(LPTLootRoll_Leader.rollFrame.mainSpeccButton);
	S:HandleButton(LPTLootRoll_Leader.rollFrame.offSpeccButton);
	S:HandleButton(LPTLootRoll_Leader.rollFrame.mogButton);
	S:HandleButton(LPTLootRoll_Leader.rollFrame.otherButton);
	S:HandleButton(LPTLootRoll_Leader.rollFrame.passButton);

	LPTLootRoll_Leader.historyButtonFrame.nextHistoryPage:SetText("");
	S:HandleNextPrevButton(LPTLootRoll_Leader.historyButtonFrame.nextHistoryPage);
	LPTLootRoll_Leader.historyButtonFrame.previousHistoryPage:SetText("");
	S:HandleNextPrevButton(LPTLootRoll_Leader.historyButtonFrame.previousHistoryPage);

	S:HandleFrame(LPTLootRoll_Leader.mainFrame.messageFrame);
	S:HandleFrame(LPTLootRoll_Leader.offFrame.messageFrame);
	S:HandleFrame(LPTLootRoll_Leader.mogFrame.messageFrame);
	S:HandleFrame(LPTLootRoll_Leader.otherFrame.messageFrame);

	S:HandleScrollBar(LPTLootRoll_Leader.mainFrame.scrollBar);
	S:HandleScrollBar(LPTLootRoll_Leader.offFrame.scrollBar);
	S:HandleScrollBar(LPTLootRoll_Leader.mogFrame.scrollBar);
	S:HandleScrollBar(LPTLootRoll_Leader.otherFrame.scrollBar);


	--Item list window.
	S:HandleFrame(LPTLootRoll_ItemList);

	S:HandleButton(LPTLootRoll_ItemList.nextItemButton);
	S:HandleButton(LPTLootRoll_ItemList.skipItemButton);

	S:HandleFrame(LPTLootRoll_ItemList.itemFrame.messageFrame);

	S:HandleScrollBar(LPTLootRoll_ItemList.itemFrame.scrollBar);


	--Config window
	S:HandleButton(LPTLootRoll_Config.shareButton);
	S:HandleButton(LPTLootRoll_Config.clearData);
	S:HandleButton(LPTLootRoll_Config.resetPosition);

	S:HandleCheckBox(LPTLootRoll_LeadMode);
	S:HandleCheckBox(LPTLootRoll_ScrollMode);
	S:HandleCheckBox(LPTLootRoll_SaveMode);
	S:HandleCheckBox(LPTLootRoll_EventMode);
	S:HandleCheckBox(LPTLootRoll_AssistMode);
	S:HandleCheckBox(LPTLootRoll_LootListener);
	S:HandleCheckBox(LPTLootRoll_WhisperListener);
	S:HandleCheckBox(LPTLootRoll_MasterLooterMode);
	S:HandleCheckBox(LPTLootRoll_WhisperNotificationMode);

	S:HandleEditBox(LPTLootRoll_Config.masterLooterFrame.editBox);
	S:HandleEditBox(LPTLootRoll_Config.mainSettingFrame.editBox);
	S:HandleEditBox(LPTLootRoll_Config.offSettingFrame.editBox);
	S:HandleEditBox(LPTLootRoll_Config.mogSettingFrame.editBox);
	S:HandleEditBox(LPTLootRoll_Config.historySettingFrame.editBox);

	LPTLootRoll_Config.masterLooterFrame.editBox:SetSize(100, 20);
	LPTLootRoll_Config.mainSettingFrame.editBox:SetSize(40, 20);
	LPTLootRoll_Config.offSettingFrame.editBox:SetSize(40, 20);
	LPTLootRoll_Config.mogSettingFrame.editBox:SetSize(40, 20);
	LPTLootRoll_Config.historySettingFrame.editBox:SetSize(40, 20);
end

AS:RegisterSkin('LPT Loot Roll', AS.LPT_Loot_Roll);