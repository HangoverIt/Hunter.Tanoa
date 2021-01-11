params ["_trg"] ;
private _l = _trg getVariable "Location" ;
if (!isServer || isNil "_l") exitWith{} ;

_trg setVariable["Spawned", false] ;

private _l_type = (_l select 0) ;
private _l_name = (_l select 1) ;
private _l_pos = (_l select 2) ;
private _l_size = (_l select 3) ;
private _l_sector = (_l select 4) ;
private _l_percent = (_l select 5) ;
private _l_vehicles = (_l select 6) ;
private _max_loc_radius = selectMax _l_size ;

// Restore all vehicles and crates to the location before spawning soldiers
[_l_vehicles] call h_restoreSaveList;

diag_log format ["%1: spawning location %2, type %3, in sector %4, size %5, percent %6", time, _l_name, _l_type, _l_sector, _l_size, _l_percent] ;

// Populate the town
private _allbuildings = [ nearestObjects [_l_pos, ["House"], _max_loc_radius ], { alive _x } ] call BIS_fnc_conditionalSelect;
_buildingpositions = [];
{
	_buildingpositions = _buildingpositions + ( [_x] call BIS_fnc_buildingPositions );
} foreach _allbuildings;

private _grp = createGroup east;

private _location_spawn_size = [_l] call h_locationSpawnSize ;

// Randomise the building positions occupied by soldiers
_buildingpositions = _buildingpositions call BIS_fnc_arrayShuffle ;
_building_iterator = 0 ;

private _remaining_to_spawn = _location_spawn_size select 1 ;
private _threat = [_l_sector] call h_getSectorThreat ;
private _all_units = [] ;
private _all_vehicles = [] ;

while {_remaining_to_spawn > 0} do {
  _selection = floor (random 3) ;
  //diag_log format ["%1: selection %2, building iterator %3, max building positions %4", time, _selection, _building_iterator, count _buildingpositions] ;
  if (_selection == 0) then {
    /////////////////////////////
    // Spawn vehicle
    _vehclass = [HUNTER_THREAT_MAPPING_VEHICLE, _threat] call h_getRandomThreat ;
    _spawnpos = [_l_pos, 0, _max_loc_radius, 0, 0] call BIS_fnc_findSafePos;
    //diag_log format ["%1: spawning vehicle %2 at %3 for threat %4", time, _vehclass, _spawnpos, _threat] ;
    _veh = createVehicle [_vehclass, _spawnpos, [], 0, "NONE"] ;
    [_veh, _spawnpos] spawn spawn_protection ;
    _veh addEventHandler["GetIn", {_this call event_getin}] ;
    _veh addEventHandler["killed", {_this call vehicle_destruction_manager}];
    [_veh, _l] call h_assignToLocation ;

    createVehicleCrew _veh ;
    {
      [_x, _l] call h_assignToLocation ;
      _all_units pushBack _x ;
    }forEach crew _veh ;
    // deduct the number of crew, note that this could make the remaining negative
    _remaining_to_spawn = _remaining_to_spawn - count (crew _veh) ;
    [group (leader _veh), _spawnpos] spawn enemy_base_defense ;
    _all_vehicles pushBack _veh ;
  };
  if (_selection == 1) then {
    if (_building_iterator >= (count _buildingpositions)) then {
      // No more building positions, spawn squad patrol instead
      _selection = 2 ;
    }else{
      //////////////////////////
      // Spawn in building
      //diag_log format ["%1: spawning man in building pos %2 for threat %3", time, (_buildingpositions select _building_iterator), _threat] ;
      _unit = [_grp, (_buildingpositions select _building_iterator), HUNTER_THREAT_MAPPING_SOLDIER, _l] call h_createUnit ;
      _building_iterator = _building_iterator + 1;
      [_unit] spawn enemy_building_defense ;
      
      _all_units pushBack _unit ;
      _remaining_to_spawn = _remaining_to_spawn - 1;
    } ;
  };
  if (_selection == 2) then {
    // Spawn squad patrol
    _patrolgrp = createGroup east ;
    _rndsize = floor(random 3) + 2 ; // Min squad of 2 up to max of 5
    _spawnpos = [_l_pos, 0, _max_loc_radius, 0, 0] call BIS_fnc_findSafePos;
    //diag_log format ["%1: spawning squad size %2 at %3", time, _rndsize, _spawnpos] ;
    for [{private _i = 0}, {_i < _rndsize && _remaining_to_spawn > 0}, {_i = _i + 1}] do {
      //diag_log format ["%1: spawning squad member for threat %2", time, _threat] ;
      _unit = [_grp, _spawnpos, HUNTER_THREAT_MAPPING_SOLDIER, _l] call h_createUnit ;
      
      _all_units pushBack _unit ;
      _remaining_to_spawn = _remaining_to_spawn - 1;
    };
    [_patrolgrp, _spawnpos] spawn enemy_base_defense ;
  };
};

// Save all defending units into the location
_l set [7, _all_units] ;
_l set [8, _all_vehicles] ;
_l set [9, true] ;

_trg setVariable["Spawned", true] ;
