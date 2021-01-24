// Sector handling functions
h_createSectors = compileFinal preprocessFileLineNumbers "functions\h_createSectors.sqf";
h_setSectorBaseThreat = compileFinal preprocessFileLineNumbers "functions\h_setSectorBaseThreat.sqf";
h_getSectorSize = compileFinal preprocessFileLineNumbers "functions\h_getSectorSize.sqf";
h_getSectorLocation = compileFinal preprocessFileLineNumbers "functions\h_getSectorLocation.sqf";
h_getSectorThreat = compileFinal preprocessFileLineNumbers "functions\h_getSectorThreat.sqf";
h_isSectorGeneralBase = compileFinal preprocessFileLineNumbers "functions\h_isSectorGeneralBase.sqf";
h_isSectorInformant = compileFinal preprocessFileLineNumbers "functions\h_isSectorInformant.sqf";
h_isSectorMission = compileFinal preprocessFileLineNumbers "functions\h_isSectorMission.sqf";
h_setSectorThreat = compileFinal preprocessFileLineNumbers "functions\h_setSectorThreat.sqf";
h_getSectorName = compileFinal preprocessFileLineNumbers "functions\h_getSectorName.sqf";
h_getSectorBaseThreat = compileFinal preprocessFileLineNumbers "functions\h_getSectorBaseThreat.sqf";

h_getRandomThreat = compileFinal preprocessFileLineNumbers "functions\h_getRandomThreat.sqf" ;
h_createSaveList = compileFinal preprocessFileLineNumbers "functions\h_createSaveList.sqf" ;
h_restoreSaveList = compileFinal preprocessFileLineNumbers "functions\h_restoreSaveList.sqf" ;
h_locationSpawnSize = compileFinal preprocessFileLineNumbers "functions\h_locationSpawnSize.sqf" ;
h_isManagedVehicle = compileFinal preprocessFileLineNumbers "functions\h_isManagedVehicle.sqf" ;
h_setManagedVehicle = compileFinal preprocessFileLineNumbers "functions\h_setManagedVehicle.sqf" ;
h_unsetManagedVehicle = compileFinal preprocessFileLineNumbers "functions\h_unsetManagedVehicle.sqf" ;
h_isSectorAtMaxThreat = compileFinal preprocessFileLineNumbers "functions\h_isSectorAtMaxThreat.sqf" ;
h_getSectorFromPosition = compileFinal preprocessFileLineNumbers "functions\h_getSectorFromPosition.sqf" ;
h_max_connected_road = compileFinal preprocessFileLineNumbers "functions\h_max_connected_road.sqf" ;
h_roadCallback = compileFinal preprocessFileLineNumbers "functions\h_roadCallback.sqf" ;
h_posOnLand = compileFinal preprocessFileLineNumbers "functions\h_posOnLand.sqf" ;
h_locationSupplyPos = compileFinal preprocessFileLineNumbers "functions\h_locationSupplyPos.sqf" ;
h_createUnit = compileFinal preprocessFileLineNumbers "functions\h_createUnit.sqf" ;
h_createVehicle = compileFinal preprocessFileLineNumbers "functions\h_createVehicle.sqf" ;
h_assignToLocation = compileFinal preprocessFileLineNumbers "functions\h_assignToLocation.sqf" ;

h_getRewardForType = compileFinal preprocessFileLineNumbers "functions\h_getRewardForType.sqf";

//event_capture = compileFinal preprocessFileLineNumbers "server\event_capture.sqf";
event_getin = compileFinal preprocessFileLineNumbers "server\event_getin.sqf";
trigger_spawn_location = compileFinal preprocessFileLineNumbers "server\trigger_spawn_location.sqf";
trigger_despawn_location = compileFinal preprocessFileLineNumbers "server\trigger_despawn_location.sqf";
kill_manager = compileFinal preprocessFileLineNumbers "server\kill_manager.sqf";
vehicle_destruction_manager = compileFinal preprocessFileLineNumbers "server\vehicle_destruction_manager.sqf";
enemy_base_defense = compileFinal preprocessFileLineNumbers "server\enemy_base_defense.sqf" ;
enemy_building_defense = compileFinal preprocessFileLineNumbers "server\enemy_building_defense.sqf" ;
spawn_location = compileFinal preprocessFileLineNumbers "server\spawn_location.sqf" ;
createLocationSupply = compileFinal preprocessFileLineNumbers "server\createLocationSupply.sqf" ;
spawn_protection = compileFinal preprocessFileLineNumbers "server\spawn_protection.sqf" ;
create_spotter = compileFinal preprocessFileLineNumbers "server\create_spotter.sqf" ;
create_sad = compileFinal preprocessFileLineNumbers "server\create_sad.sqf" ;
create_airstrike = compileFinal preprocessFileLineNumbers "server\create_airstrike.sqf";
cleanup_manager = compileFinal preprocessFileLineNumbers "server\cleanup_manager.sqf" ;
build_base = compileFinal preprocessFileLineNumbers "server\build_base.sqf" ;
reset_game_save = compileFinal preprocessFileLineNumbers "server\reset_game_save.sqf" ;

// Missions
end_mission = compileFinal preprocessFileLineNumbers "missions\functions\end_mission.sqf" ;
generate_mission_location = compileFinal preprocessFileLineNumbers "missions\functions\generate_mission_location.sqf" ;
get_location_nice_position = compileFinal preprocessFileLineNumbers "missions\functions\get_location_nice_position.sqf" ;
isMissionActive = compileFinal preprocessFileLineNumbers "missions\functions\isMissionActive.sqf" ;
hasMissionExpired = compileFinal preprocessFileLineNumbers "missions\functions\hasMissionExpired.sqf" ;
setMissionLocation = compileFinal preprocessFileLineNumbers "missions\functions\setMissionLocation.sqf" ;
start_mission = compileFinal preprocessFileLineNumbers "missions\functions\start_mission.sqf" ;

[] call compileFinal preprocessFileLineNumbers "server\load_savegame.sqf";
[] call compileFinal preprocessFileLineNumbers "server\manage_players.sqf";
[] call compileFinal preprocessFileLineNumbers "server\define_sectors.sqf";
[] call compileFinal preprocessFileLineNumbers "server\define_locations.sqf"; // Must run after define_sectors
[] call compileFinal preprocessFileLineNumbers "server\define_bases.sqf";

[] spawn compileFinal preprocessFileLineNumbers "server\manage_camp.sqf";
[] spawn compileFinal preprocessFileLineNumbers "server\sector_manager.sqf";
[] spawn compileFinal preprocessFileLineNumbers "server\location_manager.sqf";
[] spawn compileFinal preprocessFileLineNumbers "server\manage_missions.sqf";
[] spawn compileFinal preprocessFileLineNumbers "server\save_manager.sqf";

[] spawn compileFinal preprocessFileLineNumbers "server\ambient_enemy_manager.sqf";
[] spawn compileFinal preprocessFileLineNumbers "server\ambient_vehicle_manager.sqf";
[] spawn compileFinal preprocessFileLineNumbers "server\ambient_people_manager.sqf";
[] spawn compileFinal preprocessFileLineNumbers "server\enemy_intelligence.sqf";
[] spawn compileFinal preprocessFileLineNumbers "server\manage_economy.sqf";
