private _spawnedthings = [] ;
private _travelto = ["NameCity", "NameVillage", "NameCityCapital", "NameLocal"] ;
private _man_classes = ["C_man_polo_3_F_afro", "C_man_polo_1_F_afro", "C_man_polo_2_F_afro", "C_man_polo_4_F_afro", "C_man_polo_5_F_afro", "C_man_polo_6_F_afro", "C_man_hunter_1_F"] ;

// Loop forever
while {true} do {
  sleep random [HUNTER_AMBIENT_FREQ - (HUNTER_AMBIENT_FREQ * HUNTER_AMBIENT_SPREAD), HUNTER_AMBIENT_FREQ, HUNTER_AMBIENT_FREQ + (HUNTER_AMBIENT_FREQ * HUNTER_AMBIENT_SPREAD)];

  private _players = call BIS_fnc_listPlayers ;
  
  // Check number of spawns, limit the number available
  if (count _spawnedthings < HUNTER_MAX_PEOPLE_AMBIENT && count _players > 0) then { 
    // Randomly choose a player to create a spawn just outside of view range
    private _player = _players select (floor random count _players);
    
    // Suitable location just out of player view on land
    _trypos = [_player, HUNTER_SPAWN_DISTANCE - 200, HUNTER_SPAWN_DISTANCE - 150, 0, 0] call BIS_fnc_findSafePos;
    
    // Randomly choose a class of civilian to spawn
    private _spawn_man_class = _man_classes select (floor random count _man_classes) ;
    
    // Create a new group for this civilian and create the unit
    private _civgrp = createGroup[civilian, true] ;
    private _man = _civgrp createUnit[_spawn_man_class, _trypos, [], 20, "NONE"] ;
    
    // Look for nearest random location type as a destination for the civilian
    private _city = nearestLocation [_player, _travelto select (floor random count _travelto)];
    // Stop civilian running around, just want to walk
    _civgrp setBehaviour "SAFE" ;
    // Delete the original waypoints following spwan (seem to originate at 0,0,0 for new units)
    for "_i" from count waypoints _civgrp - 1 to 0 step -1 do
    {
	    deleteWaypoint [_civgrp, _i];
    };
    private _wp = _civgrp addWaypoint [_trypos, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE" ;
    _wp = _civgrp addWaypoint [locationPosition _city, 150];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE" ;
    _wp = _civgrp addWaypoint [_trypos, 0];
    _wp setWaypointType "CYCLE";
    
    //diag_log format ["%1: created civilian at %2, facing direction %3, travel to %4", time, _trypos, getDir _man, text _city] ;
    
    _spawnedthings pushBack _man ;
  };

  // Clear up any out of vision people
  private _tmpdelete = [] ;
  {
    private _v = _x ;
    private _numInView = {_x distance _v < (HUNTER_SPAWN_DISTANCE)} count _players ;
    if (_numInView == 0) then {
      _tmpdelete pushBack _v ;
      //diag_log format ["%1 Removing civilian %2", time, name _v] ;
    };
  }forEach _spawnedthings ;
  
  // Remove deleted people from main list
  _spawnedthings = _spawnedthings - _tmpdelete ;
  
  // Just iterate though deletion of items and remove from game
  {
    deleteVehicle _x ;
  }forEach _tmpdelete ;
  
};