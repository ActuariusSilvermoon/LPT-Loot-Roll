-----------------------
-------VARIABLES-------
-----------------------


local ADDON_NAME, namespace = ...;
local variables = namespace.variables;
local functions = namespace.functions;
local locale = namespace.locale;

variables.prefixStatus = C_ChatInfo.RegisterAddonMessagePrefix("LPTLootRoll");
variables.rollHistory = {};
variables.itemsToRoll = {};
variables.tradeableItemsQueue = {};
variables.debugHistory = {};
_, variables.playerClass, variables.playerClassId = UnitClass("player");
variables.playerName = UnitName("player");
variables.maxRollValue = 9999;

variables.itemPrefixKey = "potentialRollers"
variables.itemUsableKey = "itemUsable";
variables.itemPassKey 	= "itemPassed";

variables.closeWindowKey = "closeWindow";

variables.commandArray =
{
	[locale.commandArrayLeaderTitle] =
	{
		func =
			function()
				functions.displayLeaderWindow();
			end,
		description = locale.commandArrayLeaderDescription
	},
	[locale.commandArrayUserTitle] =
	{
		func = 
			function()
				functions.displayUser();
			end,
		description = locale.commandArrayUserDescription
	},
	[locale.commandArrayItemTitle] =
	{
		func = 
			function()
				functions.displayItemList();
			end,
		description = locale.commandArrayItemDescription
	},
	[locale.commandArrayClearTitle] =
	{
		func =
			function()
				StaticPopup_Show("LPTLootRoll_ClearHistory");
			end,
		description = locale.commandArrayClearDescription
	},
	[locale.commandArrayResetTitle] =
	{
		func =
			function()
				StaticPopup_Show("LPTLootRoll_ResetPosition");
			end,
		description = locale.commandArrayResetDescription
	},
	[locale.commandArrayConfigTitle] =
	{
		func =
			function()
				functions.toggleConfig();
			end,
		description = locale.commandArrayConfigDescription
	},
	[locale.commandArrayHelpTitle] =
	{
		func =
			function()
				functions.printCommands();
			end,
		description = locale.commandArrayHelpDescription
	},
	[locale.commandArrayDebugTitle] =
	{
		func =
			function()
				functions.printDebugHistory();
			end,
		description = locale.commandArrayDebugDescription
	}
};

variables.classArray =
{
	[1] = 				  -- Warrior
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = false,  -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = true,   -- Plate Armor
			[6] = true,   -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = true,  -- One-Handed Axes
			[1]  = true,  -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = true,  -- One-Handed Maces
			[5]  = true,  -- Two-Handed Maces
			[6]  = false, -- Polearms
			[7]  = true,  -- One-Handed Swords
			[8]  = true,  -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = false, -- Staves
			[13] = false, -- Fist Weapons
			[15] = false, -- Daggers
			[18] = false, -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= false,
			strength 	= true,
			intellect 	= false
		},
		["INVTYPE_HOLDABLE"] = false,
	},
	[2] = 				  -- Paladin
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = false,  -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = true,   -- Plate Armor
			[6] = true,   -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = true,  -- One-Handed Axes
			[1]  = true,  -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = true,  -- One-Handed Maces
			[5]  = true,  -- Two-Handed Maces
			[6]  = false, -- Polearms
			[7]  = true,  -- One-Handed Swords
			[8]  = true,  -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = false, -- Staves
			[13] = false, -- Fist Weapons
			[15] = false, -- Daggers
			[18] = false, -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= false,
			strength 	= true,
			intellect 	= true
		},
		["INVTYPE_HOLDABLE"] = true,
	},
	[3] = 				  -- Hunter
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = false,  -- Leather Armor
			[3] = true,   -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = false, -- One-Handed Axes
			[1]  = false, -- Two-Handed Axes
			[2]  = true,  -- Bows
			[3]  = true,  -- Guns
			[4]  = false, -- One-Handed Maces
			[5]  = false, -- Two-Handed Maces
			[6]  = true,  -- Polearms
			[7]  = false, -- One-Handed Swords
			[8]  = false, -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = true,  -- Staves
			[13] = false, -- Fist Weapons
			[15] = false, -- Daggers
			[18] = true,  -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= true,
			strength 	= false,
			intellect 	= false
		},
		["INVTYPE_HOLDABLE"] = false,
	},
	[4] = 				  -- Rogue
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = true,   -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = true,  -- One-Handed Axes
			[1]  = false, -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = true,  -- One-Handed Maces
			[5]  = false, -- Two-Handed Maces
			[6]  = false, -- Polearms
			[7]  = true,  -- One-Handed Swords
			[8]  = false, -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = false, -- Staves
			[13] = true,  -- Fist Weapons
			[15] = true,  -- Daggers
			[18] = false, -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= true,
			strength 	= false,
			intellect 	= false
		},
		["INVTYPE_HOLDABLE"] = false,
	},
	[5] = 				  -- Priest
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = true,   -- Cloth Armor 
			[2] = false,  -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = false, -- One-Handed Axes
			[1]  = false, -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = true,  -- One-Handed Maces
			[5]  = false, -- Two-Handed Maces
			[6]  = false, -- Polearms
			[7]  = false, -- One-Handed Swords
			[8]  = false, -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = true,  -- Staves
			[13] = false, -- Fist Weapons
			[15] = true,  -- Daggers
			[18] = false, -- Crossbows
			[19] = true,  -- Wands
		},
		stats = {
			agility 	= false,
			strength 	= false,
			intellect 	= true
		},
		["INVTYPE_HOLDABLE"] = true,
	},
	[6] = 				  -- Death Knight
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = false,  -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = true,   -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = true,  -- One-Handed Axes
			[1]  = true,  -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = true,  -- One-Handed Maces
			[5]  = true,  -- Two-Handed Maces
			[6]  = true,  -- Polearms
			[7]  = true,  -- One-Handed Swords
			[8]  = true,  -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = false, -- Staves
			[13] = false, -- Fist Weapons
			[15] = false, -- Daggers
			[18] = false, -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= false,
			strength 	= true,
			intellect 	= false
		},
		["INVTYPE_HOLDABLE"] = false,
	},
	[7] = 				  -- Shaman
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = false,  -- Leather Armor
			[3] = true,   -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = true,   -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = true,  -- One-Handed Axes
			[1]  = false, -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = true,  -- One-Handed Maces
			[5]  = false, -- Two-Handed Maces
			[6]  = false, -- Polearms
			[7]  = false, -- One-Handed Swords
			[8]  = false, -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = true,  -- Staves
			[13] = true,  -- Fist Weapons
			[15] = true,  -- Daggers
			[18] = false, -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= true,
			strength 	= false,
			intellect 	= true
		},
		["INVTYPE_HOLDABLE"] = true,
	},
	[8] = 				  -- Mage
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = true,   -- Cloth Armor 
			[2] = false,  -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = false, -- One-Handed Axes
			[1]  = false, -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = false, -- One-Handed Maces
			[5]  = false, -- Two-Handed Maces
			[6]  = false, -- Polearms
			[7]  = true,  -- One-Handed Swords
			[8]  = false, -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = true,  -- Staves
			[13] = false, -- Fist Weapons
			[15] = true,  -- Daggers
			[18] = false, -- Crossbows
			[19] = true,  -- Wands
		},
		stats = {
			agility 	= false,
			strength 	= false,
			intellect 	= true
		},
		["INVTYPE_HOLDABLE"] = true,
	},
	[9] = 				  -- Warlock
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = true,   -- Cloth Armor 
			[2] = false,  -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = false, -- One-Handed Axes
			[1]  = false, -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = false, -- One-Handed Maces
			[5]  = false, -- Two-Handed Maces
			[6]  = false, -- Polearms
			[7]  = true,  -- One-Handed Swords
			[8]  = false, -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = true,  -- Staves
			[13] = false, -- Fist Weapons
			[15] = true,  -- Daggers
			[18] = false, -- Crossbows
			[19] = true,  -- Wands
		},
		stats = {
			agility 	= false,
			strength 	= false,
			intellect 	= true
		},
		["INVTYPE_HOLDABLE"] = true,
	},
	[10] = 				  -- Monk
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = true,   -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = true,  -- One-Handed Axes
			[1]  = false, -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = true,  -- One-Handed Maces
			[5]  = false, -- Two-Handed Maces
			[6]  = true,  -- Polearms
			[7]  = true,  -- One-Handed Swords
			[8]  = false, -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = true,  -- Staves
			[13] = true,  -- Fist Weapons
			[15] = false, -- Daggers
			[18] = false, -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= true,
			strength 	= false,
			intellect 	= true
		},
		["INVTYPE_HOLDABLE"] = true,
	},
	[11] = 				  -- Druid
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = true,   -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = false, -- One-Handed Axes
			[1]  = false, -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = true,  -- One-Handed Maces
			[5]  = true,  -- Two-Handed Maces
			[6]  = true,  -- Polearms
			[7]  = false, -- One-Handed Swords
			[8]  = false, -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = true,  -- Staves
			[13] = true,  -- Fist Weapons
			[15] = true,  -- Daggers
			[18] = false, -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= true,
			strength 	= true,
			intellect 	= true
		},
		["INVTYPE_HOLDABLE"] = true,
	},
	[12] = 				  -- Demon Hunter
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = true,   -- Leather Armor
			[3] = false,  -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = true,  -- One-Handed Axes
			[1]  = false, -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = false, -- One-Handed Maces
			[5]  = false, -- Two-Handed Maces
			[6]  = false, -- Polearms
			[7]  = true,  -- One-Handed Swords
			[8]  = false, -- Two-Handed Swords
			[9]  = true,  -- Warglaives
			[10] = false, -- Staves
			[13] = true,  -- Fist Weapons
			[15] = false, -- Daggers
			[18] = false, -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= true,
			strength 	= false,
			intellect 	= false
		},
		["INVTYPE_HOLDABLE"] = false,
	},
	[13] = 				  -- Evoker
	{
		[4] = 			  -- Armor Class Type
		{
			[1] = false,  -- Cloth Armor 
			[2] = false,  -- Leather Armor
			[3] = true,   -- Mail Armor
			[4] = false,  -- Plate Armor
			[6] = false,  -- Shield Armor
		},
		[2] = 			  -- Weapons Class Type
		{
			[0]  = true,  -- One-Handed Axes
			[1]  = true,  -- Two-Handed Axes
			[2]  = false, -- Bows
			[3]  = false, -- Guns
			[4]  = true,  -- One-Handed Maces
			[5]  = true,  -- Two-Handed Maces
			[6]  = false, -- Polearms
			[7]  = true,  -- One-Handed Swords
			[8]  = true,  -- Two-Handed Swords
			[9]  = false, -- Warglaives
			[10] = true,  -- Staves
			[13] = true,  -- Fist Weapons
			[15] = true,  -- Daggers
			[18] = false, -- Crossbows
			[19] = false, -- Wands
		},
		stats = {
			agility 	= false,
			strength 	= false,
			intellect 	= true
		},
		["INVTYPE_HOLDABLE"] = true,
	}
};