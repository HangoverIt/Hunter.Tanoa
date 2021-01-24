# Hunter Game Framework
This covers all of the game files and how they are all called and depend on each other.  
The game files start from the Arma 3 framework which isn't covered here but can be seen in the Bohimia docs:
- [Initialisation Order](https://community.bistudio.com/wiki/Initialization_Order)  
- [Event Scripts](https://community.bistudio.com/wiki/Event_Scripts)  

## Code 
### Overview
Attempt to show this within markdown (can migrate to image if required).  

```
Game Engine
|
-- onPlayerRespawn.sqf
  |
  -- (Event) player_killed.sqf
|
-- init.sqf  
  |  
  -- client\client_init.sqf  
    |
    -- client\interface_manager.sqf
  |
  -- server\server_init.sqf
    |
    -- server\load_savedgame.sqf
      |
      -- server\build_base.sqf
    |
    -- server\manage_players.sqf
    -- server\define_sectors.sqf
    -- server\define_locations.sqf
      |
      -- utility\create_structure.sqf
      -- config\roads.sqf
    -- server\define_bases.sqf
    -- server\manage_camp.sqf
    -- server\sector_manager.sqf
    -- server\location_manager.sqf
      |
      -- createLocationSupply.sqf
    -- server\manage_missions.sqf
    -- server\save_manager.sqf
    -- server\ambient_enemy_manager.sqf
    -- server\ambient_vehicle_manager.sqf
    -- server\ambient_people_manager.sqf
    -- server\enemy_intelligence.sqf
      |
      -- server\create_sad.sqf
      -- server\create_spotter.sqf
    -- server\manage_economy.sqf
  
```

### onPlayerRespawn.sqf
**Called by the game engine in multiplayer and singleplayer game modes.**  
Always called when player first enters the game so this file covers many of the player setup.  
  
Players equipment is restored with [setUnitLoadout]() from either the PlayerDeathGear or from restored inventory from saved game (pushed over network to clients from server).  
HunterPlayers is only used to load the default gear from the server and doesn't need maintaining by the client.  
HunterPlayers global variable is iterated and the variable hunt1 .. hunt8 (these must be set in the mission.sqm with each playable unit having one of these variable names) is checked to see if this is the player. Once a match is found then the appropriate player gear is loaded. This means that equipment is persisted against the game slots. If a player chooses a different slot in the next game they play then they will be equipped with that slots loadout.  
  
*Note that the functions h_assignGear, h_removeGear and h_assignGear are legacy and should be replaced with the game code to manage unit inventory. Do not use these further in the game code.*  
  
File adds the following player actions
- Deploy Camp if BaseBag is on players back
  
Adds the following event handlers
- Killed
  
The code calls these global variables
- PlayerDeathGear
- HunterPlayers
  
### player_killed.sqf
**Called from an event handler set on the player unit.**  
Saves the gear that the player held into PlayerDeathGear global variable (on client).  
All player event handlers are removed and all the player gear is removed from the dead body. Removal of gear is done to prevent duplication of gear in the game and prevents players dying to obtain more weapons and other equipment.  
  
*Note that another mode of equipment allocation could be used in the game code where a players body retains all equipment and the respawned player has nothing assigned. This would ensure players have to retrieve equipment from storage or from the dead body. This may be a more difficult game mode and could be irritating to the game flow so hasn't been implemented yet.*  

The code calls the following globals
- PlayerDeathGear

### Client_init.sqf
**Parameters:** (None)  
**One time setup code - exits after execution.**  
Runs for all clients from init.sqf. All code from here runs in the [Scheduled](https://community.bistudio.com/wiki/Scheduler#Scheduled_Environment) environment.  
In multiplayer this script runs last in the execution order.  
  
Much of the client initialisation is done in onPlayerRespawn.sqf. Player cannot be assumeded to exist in this file.  
  
Features of this file  
- Functions are compiled 
- Player briefing created  
- Interface_manager.sqf is spawned

### Interface_manager.sqf
**Parameters:** (None)  
**Persistent code - executes for lifetime of client.**  
Creates the GUI overlay defined in description.ext. The code constantly checks if the "GUI" global variable is Nil and enables the interface.  
It's important to check as players who have not spawned will not have the intereface and killed players will have the overlay removed by the game engine.  
  
Interface creates a player status bar along the top of the screen and also shows notifications for attacks and type of cover the player has.  

The code requires global variables
- HunterEconomy
- HunterBases
- GUI (uiNamespace)

### load_savedgame.sqf
**Parameters:** (None)  
**Server calls this code to ensure it is called in sequence. One time call on game start up.**  
  
Loads all save game data from HUNTER_SAVE_VAR. If this doesn't exist yet then the code exits without doing anything.  
  
Save file contents (in the order they are saved)
- Camp list (all camp objects for a deployed camp - supports just 1 camp)
- Base list (contains all player bases)
- Objects saved list (save list of all objects - typically at the player base and camp)
- Hunters (player saved equipement)
- Sectors (saved sector information from game)
- Locations (saved location information)
- Game date & time (restore the game time)
- Heat map (saved information on player activity)

The game date is loaded and pushed to all connected clients with [remoteExec]().  
Game bases are built with a call to build_base.sqf, this can load multiple bases.  

Adds the following actions
- Pack Camp (pushed to all clients if camp exists)

Defines the following globals
- HUNTER_CAMP (pushed to clients)
- HunterPlayers (pushed to clients)

### build_base.sqf
**Parameters:** baselist, first  
**Inputs:**  
- **baselist:** array of bases from save file
- **first (optional):** if true then will create default objects and setup base, otherwise will load from list (default false)

A baselist consists of (in array order)
- Name (game generated name from parameters file)
- Position (relates to crate position)
- Items (all saved items at base to load)

If first is set to true then this will create the base crate and leave any surrounding items as they are (will be saved if in range).  
If first is false then any present items in range will be removed and base restored from baselist.  
Base items are restored via h_restoreSaveList.  
  
Adds the following actions
- CLEAR GAME FILE on the base crate
- RECRUIT SOLDIER on the base crate

Defines the following globals
- HunterBases

### manage_players.sqf
**Parameters:** (None)  
**Called procedure that runs once**  
  
Initialises the HunterPlayers if the global doesn't exist (no load from save game).  
HunterPlayers variable is pushed to all connected clients.  
HunterBlueForGrp global variable defined. This is a west group that all unmanaged spawned soldiers will belong to. Group pushed over network to clients.  
If the game is run in single player environment then all other hunter defined soldiers (playable in EDEN) will be removed leaving just the player.  
  
This procedure enables dynamic groups with [BIS_fnc_dynamicGroups](https://community.bistudio.com/wiki/BIS_fnc_dynamicGroups).  
  
Defines the following globals
- HunterPlayers (pushed to clients)

### define_sectors.sqf
**Parameters:** (None)  
**Called procedure that runs once**  
  
This procedure defines the sectors used by the game. This only happens if HunterSectors global is not defined, which happens when a savegame doesn't exist.  
h_createSectors is called to setup the grid and provide default values. Following the standard setup the game designer can customise the sectors in the code to the map.  

Defines the following globals
- HunterSectors

### define_locations.sqf
**Parameters:** editor  
**Inputs:**  
- **editor:** will this be called from 3den or used for game (see notes)

Responsible procedure for definition of the HunterLocations global variable. If not defined from a save game then this will create all map locations.  
Definition of locations is in stages
- Find all map locations defined in HUNTER_SPAWN_LOCATIONS
- Check for any custom map markers and create as locations
- Check for custom locations (defined in HUNTER_CUSTOM_LOCATION_FILE)
- Generate custom locations if none already exist (copies to clipboard)
  
For each location defined, the procedure saves any objects in vincinity of the location with h_createSaveList.  
  
If the editor flag is not set then the locations are set against sectors, objects in the vincinity of the location are deleted and triggers to activate locations are created.  
  
HunterNetwork defined as a final routine. Must have roads defined in config\roads.sqf to setup networks.  
A network is a list of connected locations. There's no additional information such as which is immediately connected or distances.  
  
Requires global variables
- HunterSectors
  
Defines the following globals
- HunterLocations (pushed to clients)
- HunterNetwork

### roads.sqf
This is a config file containing road network information. This is a list of lists, where each list is a network. Within each network there are defined locations.  
The format is
'''
[[network1], [network2], ...]
network: [location name, location position]
'''
Location names are saved as byte arrays to allow UTF8 strings. These are converted back by [toString]() and compared with existing locations.  
HunterNetwork contains references to HunterLocations after the procedure has completed.  
  
A roads.sqf file contents can be created by running utility\define_road_connections.sqf. This procedure is not called within game and is a tool to create the mapping due to slow execution of the road walk algorithm.

### create_structure.sqf
**Parameters:** centerpos, objects, rotation, create, flat  
**Inputs:**  
- **centerpos:** central position of objects to create
- **objects:** file name of objects or loaded array
- **rotation (optional):** direction of structure with associated objects
- **create (optional):** boolean, create objects with call
- **flat (optional):** boolean, if true then set the lowest object point as reference
**Outputs:**
- **2DSize:** size of 2D area the objects occupy. Size will still be returned if **create** is set to false
  
Creates a predefined structure from file or array of objects. This function allows a dynamic capability for the game code to create structures at any point in the map.  
Despite what this function can do to create a predefined structure, this will not work well on any location that isn't really flat.  

### define_bases.sqf
**Parameters:** (None)  
  
This procedure will define the initial base if HunterBases is not defined. Code is only significant before a savegame is defined.  
Defines the following globals
- HunterBases

### manage_camp.sqf
**Parameters:** (None)  
**Persistent code - executes for lifetime of server.**  
  
Iterates all HunterBases and ensures the base crate has a supply of BaseBags for players to take.  
  
Requires global variables
- HunterBases

### sector_manager.sqf
**Parameters:** oneoff  
**Inputs:**  
- **oneoff:** execute continuously or exit after one execution
  
Draws sectors on the map for all clients. Drops the treats across sectors after defined period of time.  
  
Requires global variables
- HunterSectors
  
### location_manager.sqf
**Parameters:** oneoff  
**Inputs:**  
- **oneoff:** execute continuously or exist after one execution  
  
Manages the resupply of locations. Displays locations on the map for all clients.  
Resupplies are serial, with one supply going out to a location at a time. Any location at max threat will not get further resupplies until cooldown is complete.  
  
Requires global variables
- HunterSectors
- HunterLocations

### createLocationSupply.sqf
**Parameters:** location  
**Inputs:**  
- **location:** a location object (array)  
  
Create a supply vehicle with required number of soldiers to resupply the location. Supply will decide the best vehicle using the HunterNetwork.  
  
Requires global variables
- HunterLocations
- HunterNetwork
  
### manage_missions.sqf
**Parameters:** (None)  
**Persistent code - executes for lifetime of server.**  
  
Create and manage missions in the game. All missions are defined with an array of arrays. Each embedded array is a stage of missions that once the mandatory missions are complete will move to the next set.  
'''
missions = [[mission_group], ...]
mission_group = [[mission1], [mission2], ...]
mission = [id, description, parameters, script, completed, mandatory]
'''
  
ID defines a unique number for active missions.  
Description appears against the task details.  
Parameters is an array to send to the mission script.  
Script is a path to the mission script.  
Completed indicates that the mission is done.  
Mandatory flag missions must be completed to move on. Setting false means mission is not required to complete set.  
  
Requires global variables
- HunterLocations
- HunterBases

Defines the following globals
- HunterMissions
- HunterMissionCurrent

### save_manager.sqf
**Parameters:** (None)  
**Persistent code - executes for lifetime of server.**  
  
Save the location of any deployed camp, all bases with objects in range and player inventory.  
  
Requires global variables
- HunterSectors
- HunterBases
- HunterPlayers
- HunterHeatMap

### ambient_enemy_manager.sqf
**Parameters:** (None)  
**Persistent code - executes for lifetime of server.**  
  
Defines a list of different enemy vehicles to spawn at random on the game map.  
Creates vehicles at distance from a random player. Spawns sea or land vehicles.  

### ambient_vehicle_manager.sqf
**Parameters:** (None)  
**Persistent code - executes for lifetime of server.**  
  
Defines a list of different civilian vehicles to spawn at random on the game map.  
Creates vehicles at distance from a random player. Spawns sea or land vehicles.

### ambient_people_manager.sqf
**Parameters:** (None)  
**Persistent code - executes for lifetime of server.**  
  
Defines a list of different civilians to spawn at random on the game map.  
Creates civilians at distance from a random player. Spawns on land

### enemy_intelligence.sqf
**Parameters:** (None)  
**Persistent code - executes for lifetime of server.**  
  
Defines the HunterHeatMap from player kills. Uses ghe HunterKillList from the kill_manager.sqf for every killed enemy unit.  
Creates search and destroy, close air support and spotter squads. The CAS is spwaned using [BIS_fnc_moduleCAS]().   
  
Requires global variables
- HunterSectors
- HunterKillList
  
Defines the following globals
- HunterHeatMap

### create_sad.sqf
**Parameters:** (None)  
**Called procedure that runs once** 

Requires global variables
- HunterHeatMap
- HunterSectors

Adds the following event handlers
- Killed

### create_spotter.sqf
**Parameters:** (None)  
**Called procedure that runs once** 
  
Requires global variables
- HunterHeatMap
- HunterSectors
  
Defines the following globals
- HunterSpotterLastSeen

### manage_economy.sqf
**Parameters:** (None)  
**Called procedure that runs once**  
  
Sets all ecomony values into globals for money and fuel.  
  
Defines the following globals
- HunterEconomy