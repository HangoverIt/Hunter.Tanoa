h_createSectors = compile preprocessFileLineNumbers "functions\h_createSectors.sqf";
h_setSectorBaseThreat = compile preprocessFileLineNumbers "functions\h_setSectorBaseThreat.sqf";
h_getSectorSize = compile preprocessFileLineNumbers "functions\h_getSectorSize.sqf";
h_getSectorLocation = compile preprocessFileLineNumbers "functions\h_getSectorLocation.sqf";
h_getSectorThreat = compile preprocessFileLineNumbers "functions\h_getSectorThreat.sqf";
h_isSectorGeneralBase = compile preprocessFileLineNumbers "functions\h_isSectorGeneralBase.sqf";
h_isSectorInformant = compile preprocessFileLineNumbers "functions\h_isSectorInformant.sqf";
h_isSectorMission = compile preprocessFileLineNumbers "functions\h_isSectorMission.sqf";
h_setSectorThreat = compile preprocessFileLineNumbers "functions\h_setSectorThreat.sqf";
h_getSectorName = compile preprocessFileLineNumbers "functions\h_getSectorName.sqf";
h_getSectorBaseThreat = compile preprocessFileLineNumbers "functions\h_getSectorBaseThreat.sqf";
h_getRandomThreat = compile preprocessFileLineNumbers "functions\h_getRandomThreat.sqf" ;
h_createSaveList = compile preprocessFileLineNumbers "functions\h_createSaveList.sqf" ;
h_restoreSaveList = compile preprocessFileLineNumbers "functions\h_restoreSaveList.sqf" ;
h_locationSpawnSize = compile preprocessFileLineNumbers "functions\h_locationSpawnSize.sqf" ;
h_isManagedVehicle = compile preprocessFileLineNumbers "functions\h_isManagedVehicle.sqf" ;
h_setManagedVehicle = compile preprocessFileLineNumbers "functions\h_setManagedVehicle.sqf" ;
h_unsetManagedVehicle = compile preprocessFileLineNumbers "functions\h_unsetManagedVehicle.sqf" ;
h_isMissionVehicle = compile preprocessFileLineNumbers "functions\h_isMissionVehicle.sqf" ;
h_setMissionVehicle = compile preprocessFileLineNumbers "functions\h_setMissionVehicle.sqf" ;
h_unsetMissionVehicle = compile preprocessFileLineNumbers "functions\h_unsetMissionVehicle.sqf" ;
h_isSectorAtMaxThreat = compile preprocessFileLineNumbers "functions\h_isSectorAtMaxThreat.sqf" ;
h_getSectorFromPosition = compile preprocessFileLineNumbers "functions\h_getSectorFromPosition.sqf" ;
h_max_connected_road = compile preprocessFileLineNumbers "functions\h_max_connected_road.sqf" ;
h_roadCallback = compileFinal preprocessFileLineNumbers "functions\h_roadCallback.sqf" ;

// Does not load any saved game

[] call compile preprocessFileLineNumbers "config\parameters.sqf" ;
[] call compile preprocessFileLineNumbers "server\define_sectors.sqf";
[true] call compile preprocessFileLineNumbers "server\define_locations.sqf";
[true] call compile preprocessFileLineNumbers "server\sector_manager.sqf"; // show sectors on map
[true] call compile preprocessFileLineNumbers "server\location_manager.sqf"; // show markers on map