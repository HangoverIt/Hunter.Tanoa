private _spawnedthings = [] ;
private _travelto = ["NameCity", "NameVillage", "NameCityCapital", "NameLocal"] ;
private _land_classes = ["O_T_LSV_02_armed_F", 
                         "O_T_MRAP_02_ghex_F", 
                         "O_T_MRAP_02_hmg_ghex_F", 
                         "O_G_Offroad_01_AT_F", 
                         "O_G_Offroad_01_armed_F"] ;
private _sea_classes = ["O_Boat_Armed_01_hmg_F"] ;
                         

// Loop forever
while {true} do {
  sleep random [HUNTER_AMBIENT_ENEMY_FREQ - (HUNTER_AMBIENT_ENEMY_FREQ * HUNTER_AMBIENT_SPREAD), HUNTER_AMBIENT_ENEMY_FREQ, HUNTER_AMBIENT_ENEMY_FREQ + (HUNTER_AMBIENT_ENEMY_FREQ * HUNTER_AMBIENT_SPREAD)];

  private _players = call BIS_fnc_listPlayers ;
  
  // Check number of spawns, limit the number available
  if (count _spawnedthings < HUNTER_MAX_VEHICLE_AMBIENT && count _players > 0) then { 
    // Randomly choose a player to spawn just outside of view range
    private _player = _players select (floor random count _players);
    
    // Suitable location just out of player view on or out of water
    _trypos = [_player, HUNTER_SPAWN_DISTANCE, HUNTER_SPAWN_DISTANCE + 100, 0, 1] call BIS_fnc_findSafePos;
    diag_log format ["%1: Selecting position %2, with view distance %3, distance from player %3", time, _trypos, HUNTER_SPAWN_DISTANCE, _trypos distance (getPos _player)] ;
    
    // Check is location is over water
    private _overWater = !(_trypos isFlatEmpty  [-1, -1, -1, -1, 2, false] isEqualTo []);
    private _o = objNull;
    if (_overWater) then {
      // Water
      _o = [_trypos, _sea_classes select (floor random count _sea_classes)] call h_createVehicle ;
      createVehicleCrew _o ;
      _o setDir (random 360) ;
      _grp = group (leader _o);
      
      private _city = nearestLocation [_player, "NameMarine"];
      for "_i" from count waypoints (group _o) - 1 to 0 step -1 do
      {
	      deleteWaypoint [_grp, _i];
      };
      private _wp = _grp addWaypoint [getPos _o, 0];
      _wp setWaypointType "MOVE";
      _wp setWaypointBehaviour "SAFE" ;
      _wp = _grp addWaypoint [locationPosition _city, 200];
      _wp setWaypointType "MOVE";
      _wp = _grp addWaypoint [getPos _o, 200];
      _wp setWaypointType "CYCLE";
      _grp setCurrentWaypoint [_grp, 0];
      
      diag_log format ["%1: created boat at %2, facing direction %3, travel to %4", time, _trypos, getDir _o, text _city] ;
    }else{
      // Land
      private _roads = _trypos nearRoads 100;
      if (count _roads > 0) then {
        // Select a road object and spawn there
        _trypos = getPos (_roads select 0) ;
      
        _o = [_trypos, _land_classes select (floor random count _land_classes)] call h_createVehicle ;

        createVehicleCrew _o ;
        _o setDir (random 360) ;
        _grp = group (leader _o);
        
        for "_i" from count waypoints _grp - 1 to 0 step -1 do
        {
          deleteWaypoint [_grp, _i];
        };
        
        private _city = nearestLocation [_player, "NameCity"];
        private _wp = _grp addWaypoint [getPos _o, 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointBehaviour "SAFE" ;
        _wp = _grp addWaypoint [locationPosition _city, 50];
        _wp setWaypointType "MOVE";
        _wp = _grp addWaypoint [getPos _o, 200];
        _wp setWaypointType "CYCLE";
        _grp setCurrentWaypoint [_grp, 0];
          
        diag_log format ["%1: created truck at %2, facing direction %3, travel to %4", time, _trypos, getDir _o, text _city] ;
      };
    };
    _spawnedthings pushBack _o ;
  };
  
  // Clear up any out of vision vehicles
  // TO DO: clear up crew who have left vehicle (add crew to _spawnedthings)
  private _tmpdelete = [] ;
  {
    private _v = _x ;
    //diag_log format ["%1 Check vehicle %2 at %3 to player %4 at %5, distance %6", time, name _v,getPos _v, name _x, getPos _x, _x distance _v] ;
    private _numInView = {_x distance _v < (HUNTER_SPAWN_DISTANCE +200)} count _players ;
    if (_numInView == 0 && [_v] call h_isManagedVehicle) then {
      // None of the players can now see the vehicle in view distance
      _tmpdelete pushBack _v ;
      diag_log format ["%1 Removing vehicle %2", time, typeOf _v] ;
    };
  }forEach _spawnedthings ;
  
  // Remove deleted vehicles, but keep inscope
  _spawnedthings = _spawnedthings - _tmpdelete ;
  
  // Just iterate though deletion of items and remove from game
  {
    private _v = _x ;
    {_v deleteVehicleCrew _x;} forEach crew _v;
    deleteVehicle _v ;
  }forEach _tmpdelete ;
  
};