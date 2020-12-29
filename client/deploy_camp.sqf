WaitUntil {!isNil "HunterLocations"} ;

params ["_target", "_caller", "_actionId", "_arguments"];

private _camppos = getPos _caller ;
private _candeploy = true ;

// Check if the camp can be spawned here
// Rules: cannot be within spawn radius of a location plus the radius of the camp
{
  _l_type = (_x select 0) ;
  _l_name = (_x select 1) ;
  _l_pos = (_x select 2) ;
  _l_size = (_x select 3) ;
  _l_sector = (_x select 4) ;
  _l_percent = (_x select 5) ;
  _max_size = (_l_size select 0) max (_l_size select 1) ;
  
  if (_camppos distance _l_pos < _max_size + HUNTER_CAMP_RADIUS) exitWith {
    hint format ["Too close to location %1 to create a camp, move %2 meters away to deploy",  _l_name, (_max_size + HUNTER_CAMP_RADIUS) - (_camppos distance _l_pos)] ;
    _candeploy = false ;
  };
}forEach HunterLocations;

if (_candeploy) then {
  // Remove old camp
  if (count HUNTER_CAMP > 0) then {
    call compileFinal preprocessFileLineNumbers "client\pack_camp.sqf";
  };

  private _fire = createVehicle ["Land_Campfire_F", _camppos, [], 0, "NONE"];
  private _mkr = createMarkerLocal["respawn_west_camp", _camppos] ;
  _mkr setMarkerPosLocal _camppos ; // belts and braces to ensure that this is moved if already exists
  _mkr setMarkerType "respawn_unknown" ;
  HUNTER_CAMP pushBack _fire ;
  HUNTER_CAMP pushBack createVehicle ["Land_TentA_F", [_camppos select 0, (_camppos select 1) + 5, _camppos select 2], [], 0, "NONE"];
  HUNTER_CAMP pushBack createVehicle ["Land_TentA_F", [(_camppos select 0) - 3, (_camppos select 1) + 2, _camppos select 2], [], 0, "NONE"];
  publicVariable "HUNTER_CAMP" ;

  _fire addAction ["Pack Camp", "client\pack_camp.sqf", nil, 1, true, true, "", "true", 10, false, "",""];

  removeBackpack _caller;
};