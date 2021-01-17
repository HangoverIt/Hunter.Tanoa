// Extra params are [min threat, max threat, list of cache items] or [location, [radius min, radius max], list of cache items] 
params["_id", "_description", "_expiry", "_icon", "_extraparams"] ;
_extraparams params ["_minthreat", "_maxthreat", "_cache"] ;

// Setup mission --------------------------------------------
private _title = "Secure cache" ;

private _location = _extraparams call generate_mission_location ;

private _veh = createVehicle ["O_Truck_02_covered_F", [0,0,0], [], 0, "NONE"];
_missionpos = [_location, _veh] call get_location_nice_position ;
_veh setPos _missionpos ;
[_veh, _missionpos] call spawn_protection ;
[_veh] call h_setMissionVehicle ;

clearItemCargoGlobal _veh;
clearWeaponCargoGlobal _veh;
clearMagazineCargoGlobal _veh;

{
  _veh addItemCargoGlobal _x ;
}foreach (_cache select 0) ;
{
  _veh addWeaponCargoGlobal _x ;
}forEach (_cache select 1) ;
{
  _veh addMagazineCargoGlobal _x ;
}forEach (_cache select 2) ;

private _huntermission = [_id, _title, _expiry, _missionpos, _description] call start_mission;

// Monitor mission --------------------------------------------
while {([_huntermission] call isMissionActive)} do {
  sleep 2 ;
  if (!alive _veh || ([_huntermission] call hasMissionExpired)) then {
    // mission failed
    [_this, _huntermission, false] call end_mission ;
  };
  
  _players = call BIS_fnc_listPlayers ;
  if (!isMultiplayer && hasInterface) then {
    _players = [player] ;
  };
  {
    if (_x distance _veh < 5) exitWith {
      // Mission success, advance to next mission
      [_this, _huntermission] call end_mission ;
      
      [_veh] call h_unsetMissionVehicle ;
    };
  }forEach _players ;  
};

// Mission end --------------------------------------------

