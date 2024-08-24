-----------------------
-------VARIABLES-------
-----------------------


local _, namespace = ...;
local variables = namespace.variables;
local functions = namespace.functions;
local locale = namespace.locale;

--Clean up the trade time remaining string so that it can be used cross locales.
--As seen in the RCLootConcil2 addon (https://github.com/evil-morfar/RCLootCouncil2).
local trimmedString = escapePatternSymbols(BIND_TRADE_TIME_REMAINING):gsub("%%%%s", "%(%.%+%)");

-----------------------
------EVENT TABLE------
-----------------------


variables.events =
{
    ["ENCOUNTER_LOOT_RECEIVED"] =
    function(...)
        local _, _, item, _, name = ...;

        if name ~= variables.playerName then
            return;
        end

        C_Timer.After(2,
            function()
                for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
                    for slot = 1, C_Container.GetContainerNumSlots(bag) do
                        local bagLink = C_Container.GetContainerItemLink(bag, slot);

                        if bagLink and C_Item.GetItemInfo(bagLink) == C_Item.GetItemInfo(item) then
                            LPTLootRoll_ToolTip:ClearLines();
                            LPTLootRoll_ToolTip:SetBagItem(bag, slot);

                            if functions.tooltipHasString(trimmedString) then
                                tinsert(variables.tradeableItemsQueue, item);

                                if not StaticPopup_Visible("LPTLootRoll_SendTradeable") then
                                    functions.popTradeable();
                                end

                                return;
                            end
                        end
                    end
                end
            end
        );
    end,
    ["GROUP_ROSTER_UPDATE"] =
    function(...)
        functions.toggleLootListener();
        functions.toggleWhisperListener();
        functions.controlRollListener();
    end,
    ["CHAT_MSG_RAID_WARNING"] =
    function(...)
        local msg, author = ...;
        author = strsplit("-", author);

        --Check if the person sending a raidwarning is the raid leader or if assist setting is enabled.
        if not functions.isLeaderOrAssistWithMode(author) then
            return;
        end

        local item = Item:CreateFromItemLink(msg);

        if item:IsItemEmpty() then
            functions.addToDebugHistory("Found no item in raid warning.");
            return;
        end

        item:ContinueOnItemLoad(function()
            functions.addToDebugHistory("Raid warning item is loaded.");
            functions.resetTooltip();

            local _, link, _, _, _, _, itemSubType, _, itemEquipLoc, _, _, itemClassID, itemSubClassID = C_Item.GetItemInfo(msg);

            --Stop if no item link is found.
            if link == nil then
                functions.addToDebugHistory("Found no link.");
                return;
            end

            functions.addToDebugHistory("Item: " .. link);

            local isPet = itemClassID == 15 and itemSubClassID == 2 or nil;

            LPTLootRoll_ToolTip:SetHyperlink(link);
            local isToken =
                (
                    itemSubType == "Context Token" or
                    (
                        itemSubType == "Junk" and
                        (
                            functions.tooltipHasString("Use: Create a soulbound ") or
                            functions.tooltipHasString("Use: Synthesize a soulbound")
                        )
                    )
                );

            --If not relevant items then stop.
            if not
            (
                itemClassID == 4 or --Armor
                itemClassID == 2 or --Weapon
                isPet 			 or	--Pet
                isToken             --Item Token
            )
            then
                functions.addToDebugHistory("Not relevant item.");
                return;
            end

            --Check for pet
            local usabilityVar = isPet;

            --Check if item is a collectable transmog piece.
            if usabilityVar == nil and functions.usableMog(link) then
                usabilityVar = true;
                functions.addToDebugHistory("Item has collectable transmog.");
            end

            --Check for red text in tooltip.
            if usabilityVar == nil then
                functions.resetTooltip();
                LPTLootRoll_ToolTip:SetHyperlink(link);

                if functions.tooltipHasRedText() then
                    functions.addToDebugHistory("Tooltip contains red text.");
                    usabilityVar = false;
                --If no red text and is token.
                elseif isToken then
                    functions.addToDebugHistory("No red text and is token.");
                    usabilityVar = true;
                else
                    functions.addToDebugHistory("No red text and is not token.");
                end
            end

            --Check for special item slots.
            if usabilityVar == nil then
                usabilityVar =
                    (
                        --Check if it item is a cloak.
                        itemEquipLoc == "INVTYPE_CLOAK" or
                        --Check if it is a ring.
                        itemEquipLoc == "INVTYPE_FINGER" or
                        --Check if it is a neck.
                        itemEquipLoc == "INVTYPE_NECK" or
                        --Check if item is an off-hand, and if player "should" use off-hands.
                        (itemEquipLoc == "INVTYPE_HOLDABLE" and variables.classArray[variables.playerClassId][itemEquipLoc])
                    )
                    and
                        true
                    or
                        nil;

                if usabilityVar then
                    functions.addToDebugHistory("Item is for cloak/finger/neck or is holdable and player class can normally use off-hands.");
                end
            end

            --Check for traits of the item (correct stats and equippable).
            if usabilityVar == nil then
                local itemValues = functions.getItemValues(link);
                local usableStats = functions.usableStats(itemValues);
                local anyStats = itemValues.agility or itemValues.strength or itemValues.intellect;

                usabilityVar =
                    (
                        --Check if it is a trinket, if the trinket has any main stats then use that to detect if usable.
                        (itemEquipLoc == "INVTYPE_TRINKET" and ((anyStats and usableStats) or not anyStats)) or
                        --Check if item is an equippable weapon/armor piece with correct stats.
                        (variables.classArray[variables.playerClassId][itemClassID][itemSubClassID] and usableStats)
                    )
                    and
                        true
                    or
                        nil;

                if usabilityVar then
                    functions.addToDebugHistory("Item is either trinket with no stats or correct stats, or of correct item type with correct stats.");
                end
            end

            local ownerName = select(3, msg:find("(.+) (- .+)"));
            local owner =
                (
                    UnitPlayerOrPetInRaid(ownerName)
                    and
                        {
                            name = ownerName,
                            color = functions.getClassColor(ownerName)
                        }
                    or
                        nil
                );

            if usabilityVar then
                C_ChatInfo.SendAddonMessage("LPTLootRoll", variables.itemPrefixKey .. "-" .. variables.itemUsableKey, "RAID");
            end

            functions.addToDebugHistory(usabilityVar and "Item is usable." or "Item is not usable.");

            if UnitIsGroupLeader("player") or llrSettings.leadMode then
                functions.historyLengthControl();

                --Insert the new item into the rollhistory array.
                tinsert(
                    variables.rollHistory, 
                    1,
                    {
                        item 		     = link,
                        mainList 	     = {},
                        offList 	     = {},
                        mogList 	     = {},
                        otherList        = {},
                        distributed      = false,
                        owner            = owner,
                        potentialRollers = {}
                    }
                );
                functions.addToDebugHistory("Item has been added to rollHistory table.");

                functions.leaderEvent(usabilityVar);
                functions.addToDebugHistory("Leader event has been called.");
            elseif usabilityVar then
                functions.userEvent(link, owner);
                functions.addToDebugHistory("User event has been called.");
            end
        end)
    end,
    ["CHAT_MSG_SYSTEM"] =
    function(...)
        if not variables.rollHistory[1] or variables.rollHistory[1].distributed then
			return;
		end

		local msg = ...;
		local author, roll, rollMin, rollMax = strmatch(msg, "(.+) rolls (%d+) %((%d+)-(%d+)%)");

		if not author then
			return;
		end

		--Convert the rolls to numbers.
		roll 	= tonumber(roll);
		rollMin = tonumber(rollMin);
        rollMax = tonumber(rollMax);

        --Make sure the values were found and that it does not exceed the maximum allowed value.
		if not roll or not rollMax or rollMin ~= 1 or rollMax > variables.maxRollValue then 
			return;
		end

        --Determine what array the roller should be added to.
        local determinedArray = variables.rollHistory[1].otherList;
        local rollType = "other";

		if rollMax == llrSettings.mainRoll then
            determinedArray = variables.rollHistory[1].mainList;
            rollType = "main";
		elseif rollMax == llrSettings.offRoll then
			determinedArray = variables.rollHistory[1].offList;
            rollType = "off";
		elseif rollMax == llrSettings.mogRoll then
			determinedArray = variables.rollHistory[1].mogList;
            rollType = "transmog";
		else
			roll = rollMax;
        end

        functions.addToDebugHistory("Roll " .. rollType .. " detected from player " .. author .. ".");

		--Make sure the user has not already rolled.
		if #determinedArray > 0 then
			for _, v in pairs(determinedArray) do 
				if v[1] == author then
					return;
				end
			end
        end

		--Insert the roller into the array.
        tinsert(
            determinedArray,
            {
                author,
                roll,
                functions.getClassColor(author),
                rollType
            }
        );

        variables.rollHistory[1].potentialRollers[author] = true;
        functions.updateRollerCounter();

        --Sort table based primarly by roll number, secondly by name.
        table.sort(
            determinedArray,
            function(a, b)
                if a[2] > b[2] then
                    return true;
                elseif a[2] < b[2] then
                    return false;
                else
                    return a[1] < b[1];
                end
            end
        );
    end,
    ["CHAT_MSG_WHISPER"] =
    function(...)
        local msg, author = ...;
        local name, _ = strsplit("-", author);

        if UnitPlayerOrPetInRaid(name) then
            local item = Item:CreateFromItemLink(msg);

            if item:IsItemEmpty() then
                functions.addToDebugHistory("Found no item in whisper message.");
                return;
            end

            item:ContinueOnItemLoad(function()
                functions.registerItem(name, msg);
                functions.addToDebugHistory("Item is loaded and registered in loot announcer.");
            end);
        end
    end,
    ["CHAT_MSG_ADDON"] =
    function(...)
        local prefix, msg, _, sender = ...;

        if prefix ~= "LPTLootRoll" then
            return;
        end

        local key, value = strsplit("-", msg);

        if key == variables.itemPrefixKey and variables.rollHistory[1] ~= nil and not variables.rollHistory[1].distributed then
            local name, realm = strsplit("-", sender);

            if value == variables.itemUsableKey then
                if #variables.rollHistory[1].potentialRollers > 0 then
                    for i, v in pairs(variables.rollHistory[1].potentialRollers) do
                        if i == name then
                            return;
                        end
                    end
                end

                variables.rollHistory[1].potentialRollers[name] = false;
            elseif value == variables.itemPassKey and variables.rollHistory[1].potentialRollers[name] == false then
                variables.rollHistory[1].potentialRollers[name] = true;
            end

            functions.updateRollerCounter();
        elseif key == variables.closeWindowKey then
            functions.hideUser();
            functions.disableLeader();
        end
    end
};