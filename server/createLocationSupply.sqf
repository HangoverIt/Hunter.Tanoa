// Accepts a location array. Creates a resupply convoy heading to the location
params["_l"] ;

private _l_type = (_l select 0) ;
private _l_name = (_l select 1) ;
private _l_pos = (_l select 2) ;
private _l_size = (_l select 3) ;
private _l_sector = (_l select 4) ;
private _l_vehicles = (_l select 6) ;
private _max_loc_radius = selectMax _l_size ;

// 5 min timeout
_timeout = 60 * 5 ;

private _players = call BIS_fnc_listPlayers ;
private _player = _players select (floor random count _players);

// Suitable location just out of player view on land or water
private _overWater = !(_l_pos isFlatEmpty  [-1, -1, -1, -1, 2, false] isEqualTo []);
private _trypos = [0,0,0];
private _vehclass = "" ;
private _threat = [_l_sector] call h_getSectorThreat ;
if (_overWater) then {
  // Get position in water
  _trypos = [position _player, viewDistance, viewDistance + 100, 0, 2] call BIS_fnc_findSafePos;
  _vehclass = "O_Boat_Transport_01_F" ;
}else{
  // Get start position on land
  _trypos = [position _player, viewDistance, viewDistance + 100, 0, 0] call BIS_fnc_findSafePos;
  private _roads = _trypos nearRoads 500;
  if (count _roads == 0) exitWith {} ;

  // Select a road object and spawn there
  _rnd_road = _roads select (floor random count _roads);
  _trypos = getPos _rnd_road  ;
  
  // Get a random transport vehicle depending on the sector threat level
  _vehclass = [HUNTER_THREAT_RESUPPLY_VEHICLE, _threat] call h_getRandomThreat ;
} ;


_v = createVehicle [_vehclass, _trypos, [], 0, "NONE"];
_v setPosATL _trypos ;
[_v] spawn spawn_protection ;
_v addEventHandler["GetIn", {_this call event_getin}] ;
_v call h_setManagedVehicle ;
createVehicleCrew _v ;

// Calculate the number to resupply
private _loc_spawn = [_l] call h_locationSpawnSize ;
private _respawn_size = (_loc_spawn select 0) - (_loc_spawn select 1) ;
_respawn_size = _respawn_size - count (crew _v) ;

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
if (_trypos distance2D _l_pos > _max_loc_radius) then {

  // Set up travel waypoints
  for "_i" from (count waypoints _grp) - 1 to 0 step -1 do
  {
    deleteWaypoint [_grp, _i];
  };

  //private _wp = _grp addWaypoint [_trypos, 1];
  //_wp setWaypointType "MOVE";
  //_wp setWaypointCompletionRadius 200;
  _wp = _grp addWaypoint [_l_pos, _max_loc_radius / 2];
  _wp setWaypointType "MOVE";
  _wp setWaypointCompletionRadius _max_loc_radius;
  _grp setCurrentWaypoint [_grp, 0];

  diag_log format ["%1: resupply waypoints %2 with current waypoint %3, for group with units %4", time, waypoints _grp, currentWaypoint _grp, _grp, units _grp] ;

  waitUntil {
    sleep 10;
    _timeout = _timeout - 10;
    ( { alive _x } count (units _grp) == 0 ) || currentWaypoint _grp > 0 || _timeout <= 0;
  };
};

// Resupply didn't arrive, delete crew and vehicle
if (_timeout <= 0) exitWith {
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

if (_alive_resupply > 0) then {
  _l_active = (_l select 9) ;
  _l_percent = (_l select 5) ;
  // Update percentage resupplied at location
  _newpercent = _l_percent + (_alive_resupply * (100 / (_loc_spawn select 0)));
  if (_newpercent > 100) then {_newpercent = 100;} ;
  _l set [5, _newpercent];
  _l_spawn_man = (_l select 7);
  _l_spawn_veh = (_l select 8);
  if (_l_active) then {
    diag_log format["%1: Resupply vehicle %2, arrived at active location %4, with %3 soldiers, going to %4", time, _vehclass, _alive_resupply, _l_name] ;
    // Disembark units and add to location defense
    {
      [_x] orderGetIn false ;
      doGetOut [_x] ;
      _x setVariable["Location", _l] ;
      _x setVariable["Percent", (100/(_loc_spawn select 0))] ;
      _l_spawn_man pushBack _x ;
    }forEach units _grp ;
    
    _l_spawn_veh pushBack _v ;
    
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