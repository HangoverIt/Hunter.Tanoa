// Accepts a location array. Creates a resupply convoy heading to the location
params["_l"] ;

private _l_type = (_l select 0) ;
private _l_name = (_l select 1) ;
private _l_pos = (_l select 2) ;
private _l_size = (_l select 3) ;
private _l_sector = (_l select 4) ;
private _l_vehicles = (_l select 6) ;
private _max_loc_radius = selectMax _l_size ;
private _destination_pos = _l_pos ;
private _overWater = false ;
private _trypos = [0,0,0] ;
private _airlift = false ;
private _veh_additional = "NONE" ;

// 10 min timeout
_timeout = 60 * 10 ;

// Determine if land or sea resupply
// If over water position but roads are in the radius of the location then use land
if (!([_l_pos] call h_posOnLand)) then {
  // destination position is in the water
  _roads = _l_pos nearRoads _max_loc_radius;
  if (count _roads > 0) then {
    _destination_pos = (getRoadInfo (_roads select 0)) select 6 ;
  }else{ // No roads nearby, must be by water
    _overWater = true ;
  };
}; 

private _vehclass = "" ;
private _threat = [_l_sector] call h_getSectorThreat ;
if (_overWater) then {
  // start position in water, use fallback routine
  _trypos = [_l, HunterNetwork, [HUNTER_CUSTOM_LOCATION], false, true] call h_locationSupplyPos ;
  // Get water vehicle
  _vehclass = [HUNTER_THREAT_RESUPPLY_SEA, _threat] call h_getRandomThreat ;
}else{ // land resupply attempt
  // Find position to supply over land. If no locations in network then don't try alternative positions. 
  _trypos = [_l, HunterNetwork, [HUNTER_CUSTOM_LOCATION], true, false] call h_locationSupplyPos ;
  // Get a random transport vehicle depending on the sector threat level
  _vehclass = [HUNTER_THREAT_RESUPPLY_VEHICLE, _threat] call h_getRandomThreat ;
} ;

// Cannot find a start point. Reason could be due to no locations in network to supply
// Could still be by water if there's a shoreline
if (!_overWater && _trypos isEqualTo [0,0,0]) then {
  // Is there a shoreline to use water? 
  _tmp_pos = [_destination_pos, 0, _max_loc_radius, 0, 1, 0, 1, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
  if (!(_tmp_pos isEqualTo [0,0,0])) then {
    // Found a shore line, switch to trying the water resupply method
    _destination_pos = _tmp_pos ;
    _overWater = true ;
    _trypos = [_l, HunterNetwork, [HUNTER_CUSTOM_LOCATION], false, true] call h_locationSupplyPos ;
    // Get water vehicle
    _vehclass = [HUNTER_THREAT_RESUPPLY_SEA, _threat] call h_getRandomThreat ;
    diag_log format ["createLocationSupply: could not find a land position, tried sea and found %1 using %2", _trypos, _vehclass];
  };
};

// Cannot find a start point. Reason could be due to no locations in network to supply and no route over water
// fallback to air supply`
if (_trypos isEqualTo [0,0,0]) then {
  _vehclass = [HUNTER_THREAT_RESUPPLY_AIR, _threat] call h_getRandomThreat ;
  _veh_additional = "FLY" ;
  _airlift = true ;
  diag_log format ["createLocationSupply: could not find a start point, using air supply using %1", _vehclass];
};

_v = createVehicle [_vehclass, _trypos, [], 0, _veh_additional];
if (_airlift) then {[_v, _trypos] spawn spawn_protection ;};
_v addEventHandler["GetIn", {_this call event_getin}] ;
_v call h_setManagedVehicle ;
createVehicleCrew _v ;

// Calculate the number to resupply
private _loc_spawn = [_l] call h_locationSpawnSize ;
private _respawn_size = (_loc_spawn select 0) - (_loc_spawn select 1) ;
if (!_airlift) then {
  _respawn_size = _respawn_size - count (crew _v) ;
};

// Can only transport up to the max positions in the vehicle
private _freecargo = _v emptyPositions "cargo" ;
if (_freecargo < _respawn_size) then {
  _respawn_size = _freecargo ;
};

// Create resupply units
private _grp = group (leader _v);
private _respawn_counter = _respawn_size;
while {_respawn_counter > 0} do {
  _manclass = [HUNTER_THREAT_MAPPING_SOLDIER, _threat] call h_getRandomThreat ;
  _unit = _grp createUnit[_manclass, _trypos, [], 0, "NONE" ] ;
  _unit assignAsCargo _v ;
  _unit moveInCargo _v ;
  
  _respawn_counter = _respawn_counter - 1;
} ;

// Add kill handler for resupply units
{
  _x addEventHandler["Killed", {_this call kill_manager}];
}forEach units _grp ;

diag_log format["%1: Spawned resupply vehicle %2, with %3 soldiers, going to %4", time, _vehclass, count units _grp, _l_name] ;

// If units spawned within location then skip travel and just attribute to location
if (_trypos distance2D _destination_pos > _max_loc_radius) then {

  // Set up travel waypoints
  for "_i" from (count waypoints _grp) - 1 to 0 step -1 do {
    deleteWaypoint [_grp, _i];
  };

  _wp = _grp addWaypoint [_destination_pos, _max_loc_radius / 2];
  _wp setWaypointType "MOVE";
  _wp setWaypointCompletionRadius _max_loc_radius;
  _grp setCurrentWaypoint [_grp, 0];

  diag_log format ["createLocationSupply: resupply waypoints %2 with current waypoint %3, for group with units %4", time, waypoints _grp, currentWaypoint _grp, _grp, units _grp] ;

  waitUntil {
    sleep 10;
    _timeout = _timeout - 10;
    ( { alive _x } count (units _grp) == 0 ) || currentWaypoint _grp > 0 || _timeout <= 0;
  };
};

// Resupply didn't arrive, delete crew and vehicle
if (_timeout <= 0) exitWith {
  diag_log format ["createLocationSupply: resupply in %1 took too long, deleting", _vehclass] ;
  {
    // Remove units from map
    // Check if unit is in a vehicle
    if (_x in crew _v) then {
      _v deleteVehicleCrew _x ;
    }else{
      deleteVehicle _x ;
    };
  }forEach units _grp ;
  
  if ([_v] call h_isManagedVehicle) then {
    deleteVehicle _v ;
  };
} ;

// Reached destination location or all units are dead
_alive_resupply = { alive _x } count (units _grp) ;

if (_alive_resupply > 0 && _timeout > 0) then {
  _l_active = (_l select 9) ;
  _l_percent = (_l select 5) ;
  // Update percentage resupplied at location
  _newpercent = _l_percent + (_alive_resupply * (100 / (_loc_spawn select 0)));
  if (_newpercent > 100) then {_newpercent = 100;} ;
  _l set [5, _newpercent];
  _l_spawn_man = (_l select 7);
  _l_spawn_veh = (_l select 8);
  
  _helipad = objNull ;
  if (_airlift) then {
    _helipad = createVehicle ["Land_HelipadEmpty_F", _destination_pos, [], 0, "NONE"] ;
    diag_log format ["createLocationSupply: air supply arrived, landing helicoptor at %1", _destination_pos] ;
    sleep 2 ;
    _v land "GET OUT" ;
    sleep 15;
  };
  
  if (_l_active) then {
    diag_log format["%1: Resupply vehicle %2, arrived at active location %4, with %3 soldiers", time, _vehclass, _alive_resupply, _l_name] ;
    // Disembark units and add to location defense
    _newgrp = createGroup east ;
    _unitsnewgrp = [] ;
    {
      if (!(_x in (crew _v))) then {
        [_x] orderGetIn false ;
        doGetOut [_x] ;
      };
      _x setVariable["Location", _l] ;
      _x setVariable["Percent", (100/(_loc_spawn select 0))] ;
      _l_spawn_man pushBack _x ;
      _unitsnewgrp pushBack _x ;

    }forEach units _grp ;
    _unitsnewgrp join _newgrp ; // Split the transport group into crew and cargo groups
    
    if (_airlift) then {
      // Wait for all units to leave vehicle and then set new waypoints
      waitUntil {sleep 3; {alive _x && (_x in _v)} count units _grp == 0;};
      deleteVehicle _helipad ;
      diag_log format ["createLocationSupply: helicoptor unloaded, leaving location %1", _l_name] ;
      for "_i" from (count waypoints _grp) - 1 to 0 step -1 do {
        deleteWaypoint [_grp, _i];
      };

      _wp = _grp addWaypoint [[-1000,-1000,100], 1];
      _wp setWaypointType "MOVE";
      _grp setCurrentWaypoint [_grp, 0];
      
      // Clean up crew and vehicle when out of range of players
      [_grp] spawn cleanup_manager;
      [_vehicle] spawn cleanup_manager;
    }else{
      _l_spawn_veh pushBack _v ;
    };
    
  }else{
    diag_log format["%1: Resupply vehicle %2, arrived at inactive location %4, with %3 soldiers, going to %4", time, _vehclass, _alive_resupply, _l_name] ;
    // Despawn vehicle and units as no one here to see them
    {
      // Remove units from map
      // Check if unit is in a vehicle
      if (_x in crew _v) then {
        _v deleteVehicleCrew _x ;
      }else{
        deleteVehicle _x ;
      };
    }forEach units _grp ;
    
    deleteVehicle _v ;
  };
};