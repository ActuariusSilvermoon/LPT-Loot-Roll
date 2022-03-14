if not IsAddOnLoaded("AddonSkins") then 
	return;
end

local AS = unpack(AddOnSkins)

if not AS:CheckAddOn('LPT Loot Roll') then
	return;
end

function AS:LPT_Loot_Roll()
	--User window
	AS:SkinFrame(LPTLootRoll_User);
	AS:SkinButton(LPTLootRoll_User.mainSpeccButton);
	AS:SkinButton(LPTLootRoll_User.offSpeccButton);
	AS:SkinButton(LPTLootRoll_User.mogButton);
	AS:SkinButton(LPTLootRoll_User.otherButton);


	--Leader window.
	AS:SkinFrame(LPTLootRoll_Leader);
	AS:SkinButton(LPTLootRoll_Leader.rollFrame.mainSpeccButton);
	AS:SkinButton(LPTLootRoll_Leader.rollFrame.offSpeccButton);
	AS:SkinButton(LPTLootRoll_Leader.rollFrame.mogButton);
	AS:SkinButton(LPTLootRoll_Leader.rollFrame.otherButton);
	AS:SkinButton(LPTLootRoll_Leader.rollFrame.passButton);

	AS:SkinButton(LPTLootRoll_Leader.historyButtonFrame.nextHistoryPage);
	AS:SkinButton(LPTLootRoll_Leader.historyButtonFrame.previousHistoryPage);

	AS:SkinFrame(LPTLootRoll_Leader.mainFrame.messageFrame);
	AS:SkinFrame(LPTLootRoll_Leader.offFrame.messageFrame);
	AS:SkinFrame(LPTLootRoll_Leader.mogFrame.messageFrame);
	AS:SkinFrame(LPTLootRoll_Leader.otherFrame.messageFrame);

	AS:SkinScrollBar(LPTLootRoll_Leader.mainFrame.scrollBar);
	AS:SkinScrollBar(LPTLootRoll_Leader.offFrame.scrollBar);
	AS:SkinScrollBar(LPTLootRoll_Leader.mogFrame.scrollBar);
	AS:SkinScrollBar(LPTLootRoll_Leader.otherFrame.scrollBar);


	--Item list window.
	AS:SkinFrame(LPTLootRoll_ItemList);

	AS:SkinButton(LPTLootRoll_ItemList.nextItemButton);
	AS:SkinButton(LPTLootRoll_ItemList.skipItemButton);

	AS:SkinFrame(LPTLootRoll_ItemList.itemFrame.messageFrame);

	AS:SkinScrollBar(LPTLootRoll_ItemList.itemFrame.scrollBar);


	--Config window
	AS:SkinButton(LPTLootRoll_Config.shareButton);
	AS:SkinButton(LPTLootRoll_Config.clearData);
	AS:SkinButton(LPTLootRoll_Config.resetPosition);

	AS:SkinCheckBox(LPTLootRoll_LeadMode);
	AS:SkinCheckBox(LPTLootRoll_ScrollMode);
	AS:SkinCheckBox(LPTLootRoll_SaveMode);
	AS:SkinCheckBox(LPTLootRoll_EventMode);
	AS:SkinCheckBox(LPTLootRoll_AssistMode);
	AS:SkinCheckBox(LPTLootRoll_LootListener);
	AS:SkinCheckBox(LPTLootRoll_WhisperListener);
	AS:SkinCheckBox(LPTLootRoll_MasterLooterMode);
	AS:SkinCheckBox(LPTLootRoll_WhisperNotificationMode);

	AS:SkinEditBox(LPTLootRoll_Config.masterLooterFrame.editBox, 100, 12);
	AS:SkinEditBox(LPTLootRoll_Config.mainSettingFrame.editBox, 40, 12);
	AS:SkinEditBox(LPTLootRoll_Config.offSettingFrame.editBox, 40, 12);
	AS:SkinEditBox(LPTLootRoll_Config.mogSettingFrame.editBox, 40, 12);
	AS:SkinEditBox(LPTLootRoll_Config.historySettingFrame.editBox, 40, 12);
end

AS:RegisterSkin('LPT Loot Roll', AS.LPT_Loot_Roll);