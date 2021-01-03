# Hunter.Tanoa Arma 3 multiplayer mission

Git clone to mpmissions folder and run in game or on dedicated server

## Basic concepts
The game works on key locations across the map of Tanoa. The player(s) start at a predefined base with some basic loadout and equipment. There's no fancy arsenal and infinite kit, everything is gathered and stored at camps and bases. 
With some configuration the concept and game can be recreated on any Arma 3 map. 

### Equipment
All equipment stored in boxes and vehicles within the radius of a base are saved periodically.
Player equipment is retained across saves (against the player slots). Respawning players will restore to bases or camps with the exact kit they had at point of death. 

### Locations
Locations are all occupied at the start of the game, but the type of soldier depends on the treat in the sector. Some locations are so low that they have civilians.
The number of occupants depends on the size of locations. Patrol areas are tiny whilst cities are much larger.
The map is divided into sectors (number is configurable). Each sector holds 2 threat values; a base threat and current threat which increases with each kill. 
Sectors do have a cap on the max threat to stop tanks appearing in tiny villages.
Players can temporarily capture a location if all defenders are cleared. Players can respawn at a captured location. 

### Resupply
If occupants are killed in a location then they will be resupplied to the original maximum occupancy. Depending on the location the resupply could be by road or sea.

### Retribution
Attacks on enemy soldiers in any part of the map will be followed up by the enemy, but don't expect a battalion response. 
The enemy will deploy a search and destroy squad in the general region of your recent attacks.
If you make a menace of yourself in different locations then a spotter plane will be deployed. 
Rapid kills and aggressive behaviour from your party can invoke a close air support response. 

## Configuration
**config\parameters.sqf** - majority of configuration for the game. Interesting settings are spawn distances and types of vehicles and soldiers to spawn.
The sector grid can be adjusted here.

**config\roads.sqf** - contains lists of all road networks. This is a cache of output from *utility\define_road_connections.sqf* which is a very slow procedure as it walks the entire road system.

**config\custom_locations.sqf** - contains additional locations pushed into the HunterLocations global list.
This file can be empty and the game will generate the locations automatically on startup, but this is very slow as the entire map is searched for locations.
If the locations are auto generated then the content for custom_locations will be held on the clipboard.

**server\define_sectors.sqf** - (should be moved to config folder) contains all the sector configuration with base and max threat.

### 3den configuration
The map allows markers to specify the starting base and the 8 playable soldiers.
All soldiers need to be named - hunt1, hunt2, hunt3 ... hunt8.
Custom structures can be added as playable locations. A marker prefixed with the value of HUNTER_SPECIAL_MARKER_PREFIX and ended with a name that matches entries in *predefined\* folder will be loaded into the game.

## Globals

**HunterSectors** - all sector configuration. This is saved to player profile and restored on start-up

**HunterLocations** - every location that will spawn something. A link to the associated sector exists in this global

**HunterNetwork** - all road connections. Generated after locations are defined. Contains locations in the same format as HunterLocations. 
This is an array of networks. Each network is an array of locations that are all connected.

**HunterBases** - an array of player bases. Only 1 base currently exists but can support more in the future. 

**HunterPlayers** - holds the player configuration.

**HunterHeatMap** - A list of locations attacked by the player. Number of kills and when are recorded in the heatmap. Entries expire after time.
 
**HUNTER_CAMP** - information on any deployed player camp

**HunterSpotterLastSeen** - created by the spotter plane, this is a global containing last position spotted and time (given in game time)
