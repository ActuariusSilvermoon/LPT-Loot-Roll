<h1>LPT Loot Roll</h1>
<p>&nbsp;</p>
<h2>What is LPT Loot Roll?</h2>
<p>LPT Loot Roll is an addon to help with the distribution of unwanted loot. It was originally designed for the guild Lazy Peon Tavern on Silvermoon to work with our loot system but has later been generalized to allow for other groups to use it.</p>
<p>&nbsp;</p>
<h2>How to use:</h2>
<h3>Normal users:</h3>
<p>Basically, once a player receives an item they do not wish to keep and are able to trade, they link that item in a whisper to the raid leader or to their "loot master". This is either done manually or via the loot listener (which can be enabled in the settings).</p>
<p>&nbsp;</p>
<p>If the raid leader (/raid assist) announces an unwated item in a raid warning, a loot window will pop up for all players that are able to use that item. The players can click a button for mainspec, offspec, transmog or other. By clicking one of the buttons the player performs a /roll. By clicking X the player closes the window without rolling.</p>
<p>&nbsp;</p>
<h3>Leader users:</h3>
<p>The raid leader and anyone else with the toggle leader mode, will get a customized window that serves as an overview to the status of that item. The leader window has four lists that populate automatically with rolls done by users in the raid group. The window also displays how many players have registered the item as usable, and also how many have interacted with the given item. Clicking a player in any of the lists will promt you with a pop up asking if you wish the item to be distributed to that person. If accepted it will send a message to either raid warning or in a whisper message to the related individuals (depending on the settings).</p>
<p>The raid leader/loot master also has the option to enable the whisper listener. The whisper listener will create a frame with a list that will populate automatically when members of your raid group send loot to you in a whisper message. The loot can then be posted in raid warning by either clicking post next, which will pop the top item of the list to the raid warning chat, or the leader can ctrl click any item link in the list for it to be popped. If a user has mislinked something, the leader can also skip items by using the skip button.</p>
<p>The leader window will come up for every loot announced in raid warning, but the buttons for rolling will only be activated if the item is usable for that user. The leader window also stores a history of rolled items, which you can use to go back to see the lists for previous loot. You navigate the history by using the arrows in the top right corner or scrolling anywhere on the leader frame that is not the lists themselves. The leader can navigate back in time for X amount of items, where X is determined by user settings, which is 20 by default. The addon will still pick up rollers for the current item, even if the leader is browsing through the history (this is stored on a session basis, unless changed in the config menu).</p>
<p>&nbsp;</p>
<h2>Important notes</h2>
<p>All users of the addon will only be able to roll once before the window closes/disables and their names can only be registered to a list once. However, if the player misclicked a button, they can do a manual roll again for any of the other lists, or open the loot window again manually and click the buttons there.</p>
<p>As the addon uses the standard wow "/roll" function, all users do not need to have the addon for it to work for your guild. People without the addon can still manually do the rolls and the raid leader view will still pick them up and display it in the view.</p>
<p>The logic behind determining if an item is available for a given class uses multiple factors and these are as follows:</p>
<ul>
<li>Check if the item is a pet or transmog that the player can collect.</li>
<li>Check if it is a cloak/ring/neck, if it is, then mark it as usable.</li>
<li>Check if the item is a weapon or armor type that is relevant to your class, with the appropriate main stats.</li>
<li>Check if the item is a trinket with a mainstat, if it has mainstats, check if it is a relevant main stat to your class, if it has no stats then mark it as usable anyway.</li>
</ul>
<p>If you wish to use a different loot master than the raid leader for the automatic loot detector, then make sure the loot master has been given assist and also that they have enabled the assist mode in the config menu.</p>
<p>&nbsp;</p>
<p>As previously mentioned the addon has 4 rolls, and each of them have their own respective button that will roll the amount associated with them (except for other which will prompt a pop up with an input field). Their default values are listed below, but this can be changed in the settings window.</p>
<p>Main button: 1-100. <br /> Off button: 1-50. <br /> Mog button: 1-25. <br /> The "Other" button allows for custom rolls between 1-X, where X is less than 10 000.</p>
<p>Use "/lpt" to view the available commands for the addon.</p>
<p>&nbsp;</p>
<h2>Settings:</h2>
<p>To enter the config use /lpt config (or navigate via the normal addon tab in the interface settings).</p>
<p>In the config frame you can:</p>
<ul>
<li>Chose to always show the leader frame even if you're a normal user.</li>
<li>Change the way the lists populate (as in highest roller being highest on the list or bottom on the list).</li>
<li>Store roll history between sessions.</li>
<li>Toggle the constant roll listener.</li>
<li>Set a custom scale value for resizing the different windows to the users preferences.</li>
<li>Enable assist loot, which allows for raid assistant item raid warnings to be picked up. This is also required for the alternate loot master function to work properly.</li>
<li>Enable tradeable loot detection, which will make the addon give you a prompt, if you are in a raid group and loot an item that can be traded. The prompt will have an input bux with the current master looter (which is defaulted to raid leader), but this can be changed manually and will be kept for the remainder of the session. Accepting the prompt will send the item in a whisper to the loot master.</li>
<li>Enable whisper listener, this if for raid leaders/loot masters and will display a new window whenever someone in your raid group links an item in whisper. This also includes items sent from yourself with the addon.</li>
<li>Enable master looter override, if this is checked the default master looter in the tradeable item pop up will be set to the name in the "master looter override" input box, given that the name is of a player in your raid group that has at least assist.</li>
<li>Enable whisper notifications, if it is checked the addon will send the distribution messages in a whisper message instead of a raid warning.</li>
<li>Change values of the different rolls. (The max-values need to be different from each other for the addon to know which button is being pressed. Attempting to set the values of the rolls to be the same number as another roll, or attempting to set it to 0 will result in settings not being saved).</li>
</ul>
<p>&nbsp;</p>
<p>Users can also share their roll value settings. This is done by shift clicking the share button while having a chat window open. This will add a link that other users of the addon can click and then set their roll values to match yours.</p>
<p>All windows are drag-able in case you wish to have them somewhere else on your screen and will remember where they were between sessions.</p>
<p>&nbsp;</p>
<p><strong> WARNING: Make sure all users roll settings are the same as the raid leader, as the leader only picks up rolls that match their settings. Always share your settings with the raid, if you make changes. </strong></p>
<p>&nbsp;</p>
<p>The addon also supports using skins from the addonskin addon of the Tukui family of addons. To use these just enable the skin in the standard addonskin menu.</p>
<p>&nbsp;</p>
<h2>Troubleshooting</h2>
<p><b> If the window doesn't appear for you and you have upgraded from a previous version of the addon, attempt to do a /llr reset to reset their positions. Sometimes the locations of the windows will bug out on changes and thus the windows might not be visable. </b></p>
