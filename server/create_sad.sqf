// No params required, just needs heat map and sectors defined.
// If not defined then exit as nothing can be done until defined
if (isNil "HunterHeatMap" || isNil "HunterSectors") exitWith {
  diag_log "Attempted to create a SAD group, but heat map and sectors are undefined!" ;
} ;
if (count HunterHeatMap == 0) exitWith {
  diag_log "SAD has not heat map entries to set destination, exiting!" ;
};

private _max_threat = 0 ;
private _spawn_at = [0,0,0] ;
private _last_hm = HunterHeatMap select 0 ; // Last heat map update

// Get the sector threat
{
  _hm = _x ;
  _hm_time = _hm select 0;
  _hm_location = _hm select 2 ;
  _sector = [HunterSectors, _hm_location] call h_getSectorFromPosition ;
  if (! ([_sector] call h_isSectorAtMaxThreat) ) then {
    if (count _sector > 0) then { // check return is not null sector
      _sector_threat = [_sector] call h_getSectorThreat ;
      if (_sector_threat > _max_threat) then {
        _max_threat = _sector_threat;
      };
    };
    
    // Check for the newest entry in the heat map as this will be the primary 
    // search location
    if (_hm_time > (_last_hm select 0)) then {
      _last_hm = _hm ;
    };
  };
}forEach HunterHeatMap ;

private _primary_destination = _last_hm select 2 ;
private _overWater = !(_primary_destination isFlatEmpty  [-1, -1, -1, -1, 2, false] isEqualTo []);
private _all_units = [] ;
private _trypos = [0,0,0] ;
private _vehicleclass = "";

// Determine the type of vehicle and spawn place to use
if (_overWater) then {
  // Get position in water
  _trypos = [_primary_destination, 1000, 1100, 0, 2] call BIS_fnc_findSafePos;
  _vehicleclass = "O_Boat_Armed_01_hmg_F" ;
}else{
  // Get start position on land
  _trypos = [_primary_destination, 1000, 1100, 0, 0] call BIS_fnc_findSafePos;
  private _roads = _trypos nearRoads 500;
  if (count _roads > 0) then {
    // Select a road object and spawn there
    _rnd_road = _roads select (floor random count _roads);
    //_trypos = getPos _rnd_road  ;
  };
  
  // Get a random transport vehicle depending on the sector threat level
  _vehicleclass = [HUNTER_THREAT_SAD_VEHICLE, _max_threat] call h_getRandomThreat ;
} ;

// Create the vehicle, crew and passengers
_grp = createGroup east ;
private _vehicle = [_trypos, _vehicleclass] call h_createVehicle ;
createVehicleCrew _vehicle;
_grpv = group _vehicle ;
// Add killed handler and variables
{
  _x addEventHandler["Killed", {_this call kill_manager}];
  _all_units pushBack _x ;
}forEach crew _vehicle ;

private _freecargo = _vehicle emptyPositions "cargo" ;

while{_freecargo > 0} do {
  _manclass = [HUNTER_THREAT_MAPPING_SOLDIER, _max_threat] call h_getRandomThreat ;
  _sadunit = [_grp, _trypos, [_manclass]] call h_createUnit ;
  _all_units pushBack _sadunit ;
  _sadunit assignAsCargo _vehicle ;
  _sadunit moveInCargo _vehicle;
  _freecargo = _freecargo - 1;
};
diag_log format["SAD vehicle %1 created with %2 units",_vehicleclass, count _all_units];

// Set up travel waypoints, delete default WP
for "_i" from (count waypoints _grpv) - 1 to 0 step -1 do
{
  deleteWaypoint [_grpv, _i];
};

private _wp = _grpv addWaypoint [_primary_destination, 20];
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 100;
_grpv setCurrentWaypoint [_grpv, 0];

private _nearest_enemy = objNull ;
private _dismounted = false ;
private _mergedgroup = false ;
private _sadexpiresat = time + (HUNTER_SAD_TIMEOUT * 60) ;
private _verify_move = position _vehicle ;
private _verify_time = time + 60 ;
// Run search and destroy until heat map is empty or all destroyed
while {(({ alive _x } count (units _grp) > 0) || ({ alive _x } count (units _grpv) > 0)) && 
       (count HunterHeatMap >= 1 || !isNull _nearest_enemy) &&
       time < _sadexpiresat} do {
  sleep 10;
  
  if (alive _vehicle && currentWaypoint _grpv == 0 && !_dismounted && !_mergedgroup && _verify_time < time) then {
    diag_log format ["%1: SAD vehicle last at %2, now at %3, verifying if moving", time, _verify_move, position _vehicle] ;
    if (_verify_move isEqualTo (position _vehicle)) then {
      // not moved, could be stuck so try new position
      if (_overWater) then {
        // Get position in water
        _vehicle setPos ([_primary_destination, 1000, 1100, 0, 2] call BIS_fnc_findSafePos);
      }else{
        _vehicle setPos ([_primary_destination, 1000, 1100, 0, 0] call BIS_fnc_findSafePos);
      };
      diag_log format ["%1: SAD vehicle has not moved, moving vehicle to try again. Resetting waypoint", time] ;
      while {(count (waypoints _grpv)) != 0} do { deleteWaypoint ((waypoints _grpv) select 0) };
      _wp = _grpv addWaypoint [_primary_destination, 20];
      _wp setWaypointType "MOVE";
      _wp setWaypointCompletionRadius 100;
      _grpv setCurrentWaypoint [_grpv, 0];
    };
    // Reset
    _verify_move = position _vehicle ;
    _verify_time = time + 60 ;
  };
  
  /////////////////////////////////////////
  //
  // Check knowledge of enemy
  // ------------------------
  _nearest_enemy = (leader _grpv) findNearestEnemy (leader _grpv) ;
  if (!isNull _nearest_enemy) then {
    _sadexpiresat = time + (HUNTER_SAD_TIMEOUT * 60) ; // reset timeout
    _last_pos = (leader _grpv) getHideFrom _nearest_enemy ;
    diag_log format["%1: SAD detected near enemy at %2", time, _last_pos] ;
    if (!(_last_pos isEqualTo [0,0,0])) then {
      // Remove SAD waypoints
      while {(count (waypoints _grpv)) != 0} do { deleteWaypoint ((waypoints _grpv) select 0) };
      _knowledge = _grpv knowsAbout _nearest_enemy ;
      (leader _grp) reveal [_nearest_enemy, _knowledge] ; // share knowledge of target
      _waypoint = _grpv addWaypoint [_last_pos, 20];
      _waypoint setWaypointType "SAD";
      _waypoint setWaypointBehaviour "COMBAT";
      _grpv setCurrentWaypoint [_grpv, 0];
    };
  };
  
  /////////////////////////////////////////
  //
  // has fuel and still has crew but no driver
  // ------------------------------------------------------------------
  if ((isNull (driver _vehicle) || !alive (driver _vehicle)) && {(_x in _vehicle)} count units _grpv >= 0 && fuel _vehicle > 0) then {
    (leader _grpv) assignAsDriver _vehicle;
    (leader _grpv) moveInDriver _vehicle ;
  };
  
  /////////////////////////////////////////
  //
  // out of fuel or crew have dismounted anyway (flipped, damaged, etc)
  // ------------------------------------------------------------------
  if ((fuel _vehicle == 0 || {(_x in _vehicle)} count units _grpv == 0) && !_mergedgroup) then {
    diag_log format["%1: SAD, no fuel or no crew in vehicle, merge groups", time] ;
    // Get out and go on foot or if already out then merge into one unit group
    units _grp orderGetIn false ;
    doGetOut units _grp ;
    units _grpv orderGetIn false ;
    doGetOut units _grpv ;
    
    // Create one group with vehicle crew
    units _grp joinSilent _grpv ;
    while {(count (waypoints _grpv)) != 0} do {deleteWaypoint ((waypoints _grpv) select 0);};
    _wp = _grpv addWaypoint [_primary_destination, 1];
    _wp setWaypointType "MOVE";
    _wp setWaypointCompletionRadius 100;
    _grpv setCurrentWaypoint [_grpv, 0];

    _mergedgroup = true ;
  };
  
  /////////////////////////////////////////
  //
  // Check if reached destination. Run SAD patrol
  // ----------------------------------------------------
  if (currentWaypoint _grpv > 0 && !_dismounted) then {
    _dismounted = true ;
    
    if ((leader _grpv) distance _primary_destination > 200) then {
      diag_log format["%1: SAD thinks at destination but 200m out, could have failed to route", time] ;
      _sadexpiresat = 0; // force timeout loop ;
    };
    
    diag_log format["%1: SAD reached destination, start search and destroy", time] ;
    
    // If vehicle alive and crew in vehicle, then we've driven here
    if (alive _vehicle && {_x in _vehicle} count units _grpv > 0) then {
      units _grp orderGetIn false ;
      doGetOut units _grp ;
      
      sleep 10 ; // allow get out
          
      while {(count (waypoints _grpv)) != 0} do {deleteWaypoint ((waypoints _grpv) select 0);};
      _waypoint = _grpv addWaypoint [_primary_destination, 300];
      _waypoint setWaypointType "SAD";
      _waypoint setWaypointBehaviour "COMBAT";
      _waypoint setWaypointCombatMode "GREEN";
      _waypoint = _grpv addWaypoint [_primary_destination, 300];
      _waypoint setWaypointType "SAD";
      _waypoint = _grpv addWaypoint [_primary_destination, 300];
      _waypoint setWaypointType "SAD";
      _waypoint = _grpv addWaypoint [_primary_destination, 300];
      _waypoint setWaypointType "SAD";
      _waypoint = _grpv addWaypoint [_primary_destination, 300];
      _waypoint setWaypointType "CYCLE";
      _grpv setCurrentWaypoint [_grpv, 0];
    } ;
    
    // If group has alive units then set waypoints for SAD
    if ({alive _x} count units _grp > 0) then {
      while {(count (waypoints _grp)) != 0} do { deleteWaypoint ((waypoints _grp) select 0) };
      {_x doFollow leader _grp} foreach units _grp;

      while {(count (waypoints _grp)) != 0} do {deleteWaypoint ((waypoints _grp) select 0);};
      _waypoint = _grp addWaypoint [_primary_destination, 200];
      _waypoint setWaypointType "SAD";
      _waypoint setWaypointBehaviour "COMBAT";
      _waypoint setWaypointCombatMode "GREEN";
      _waypoint = _grp addWaypoint [_primary_destination, 200];
      _waypoint setWaypointType "SAD";
      _waypoint = _grp addWaypoint [_primary_destination, 200];
      _waypoint setWaypointType "SAD";
      _waypoint = _grp addWaypoint [_primary_destination, 200];
      _waypoint setWaypointType "SAD";
      _waypoint = _grp addWaypoint [_primary_destination, 200];
      _waypoint setWaypointType "CYCLE";
      _grp setCurrentWaypoint [_grp, 0];
    };
  };
  
};

// SAD complete, timeout or no intelligence. Attempt return to base if alive
diag_log "SAD complete" ;

// If vehicle is alive, there is a crew in the vehicle and there's a group alive to load then load
if (alive _vehicle && { alive _x } count (units _grp) > 0 && {alive _x && _x in _vehicle } count (units _grpv) > 0) then {
  {_x assignAsCargo _vehicle}forEach units _grp ;
  (units _grp) orderGetIn true ;
  // wait for all alive soldiers to get into vehicle
  _timeout = time + 120 ;
  waitUntil {sleep 2; {alive _x && !(_x in _vehicle)} count units _grp == 0 || _timeout < time;};
  diag_log "SAD group returned to cargo" ;
};

// If vehicle and crew alive then move
if (alive _vehicle && { alive _x } count (units _grpv) > 0) then {
  _city = nearestLocation [position (leader _grpv), "NameCity"];
  diag_log format ["SAD group moving in vehicle to %1", text _city] ;
  while {(count (waypoints _grpv)) != 0} do {deleteWaypoint ((waypoints _grpv) select 0);};
  _wp = _grpv addWaypoint [locationPosition _city, 50] ;
  _wp setWaypointType "MOVE";
  _wp setWaypointCompletionRadius 100;
  _grpv setCurrentWaypoint [_grpv, 0];
}else{
  // Vehicle may not be an option, move out groups by foot
  if ({ alive _x } count (units _grp) > 0) then {
    _city = nearestLocation [position (leader _grp), "NameCity"];
    diag_log format ["SAD group moving on foot to %1", text _city] ;
    while {(count (waypoints _grp)) != 0} do {deleteWaypoint ((waypoints _grp) select 0);};
    _wp = _grp addWaypoint [locationPosition _city, 50] ;
    _wp setWaypointType "MOVE";
    _wp setWaypointCompletionRadius 100;
    _grp setCurrentWaypoint [_grp, 0];
    
    while {(count (waypoints _grpv)) != 0} do {deleteWaypoint ((waypoints _grpv) select 0);};
    _wp = _grpv addWaypoint [locationPosition _city, 50] ;
    _wp setWaypointType "MOVE";
    _wp setWaypointCompletionRadius 100;
    _grpv setCurrentWaypoint [_grpv, 0];
  };
};

[_grpv] spawn cleanup_manager;
[_grp] spawn cleanup_manager;
[_vehicle] spawn cleanup_manager;


