params ["_trg"] ;
private _l = _trg getVariable "Location";
private _spawned = _trg getVariable "Spawned" ;

if (!isServer || isNil "_l") exitWith{} ;

waitUntil {sleep 0.2; _spawned};

_l_type = (_l select 0) ;
_l_name = (_l select 1) ;
_l_pos = (_l select 2) ;
_l_size = (_l select 3) ;
_l_sector = (_l select 4) ;
_l_percent = (_l select 5) ;
//_l_listvehicles = (_l select 6) ;
_l_spawned_men = (_l select 7) ;
_l_spawned_veh = (_l select 8) ;

_max_size = (_l_size select 0) max (_l_size select 1) ;

diag_log format ["%1: removing all spawned units from location %2", time, _l_name] ;

// flag location as inactive
_l set [9, false] ;

// Remove map indicator
deleteMarker ("trg" + _l_name);

{
  // Remove units from map
  // Check if unit is in a vehicle
  if ((vehicle _x) != _x) then {
    (vehicle _x) deleteVehicleCrew _x ;
  }else{
    deleteVehicle _x ;
  };
}forEach _l_spawned_men ;

// Remove vehicles following soldiers
{
  // Remove vehicle from map if it hasn't been captured by players
  _vehloc = _x getVariable "Location" ;
  if (!isNil "_vehloc") then {
    deleteVehicle _x ;
  };

}forEach _l_spawned_veh ;

// Delete vehicles and ammo boxes in location (curator and added)
{
  {
    _veh = _x ;
    {_veh deleteVehicleCrew _x } forEach crew _veh;
    if (side _veh in [west, civilian] && !([_veh] call h_isManagedVehicle)) then {
      deleteVehicle _veh ;
    };
  }forEach (_l_pos nearObjects [_x, _max_size ]);
}forEach HUNTER_SAVE_CLASSES;

// Reset trigger area for spawn
if (_l_type == HUNTER_CUSTOM_LOCATION) then {
  _trg setTriggerArea [HUNTER_CUSTOM_RADIUS_SPAWN, HUNTER_CUSTOM_RADIUS_SPAWN, 0, false];
}else{
  _trg setTriggerArea [HUNTER_LOCATION_RADIUS_SPAWN, HUNTER_LOCATION_RADIUS_SPAWN, 0, false];
};