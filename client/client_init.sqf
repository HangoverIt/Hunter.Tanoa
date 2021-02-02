h_defaultGear = compileFinal preprocessFileLineNumbers "client\functions\h_defaultGear.sqf" ;
h_assignGear = compileFinal preprocessFileLineNumbers "client\functions\h_assignGear.sqf" ;
h_removeGear = compileFinal preprocessFileLineNumbers "client\functions\h_removeGear.sqf" ;
player_killed = compileFinal preprocessFileLineNumbers "client\player_killed.sqf" ;

// Player controls
dlgRecruit = compileFinal preprocessFileLineNumbers "client\ui\dlgRecruit.sqf" ;

[] spawn compileFinal preprocessFileLineNumbers "client\interface_manager.sqf";

player createDiaryRecord ["Diary", 

["Huntdown and kill the general", 
"The general succeeded in a coup against the elected government over 3 years ago.<br>
You escaped the island, but swore to return. Following the coup the general allied with foreign forces, allowing them to share military installations.<br>
CSAT forces now patrol the main airports and cities. The outlying villages are held by militia loyal to the general.<br>
Your benefactors have provided the basics to support your return to the island and, if you show progress finding the general, they will offer further support.<br>
Be resourceful, make use of captured weapons and vehicles, hunt down the general and pave the way to restoring your island"]];

// Allow dynamic groups
["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;