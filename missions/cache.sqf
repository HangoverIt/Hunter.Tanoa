// Extra params are [min threat, max threat, list of cache items] or [location, [radius min, radius max], list of cache items] 
params["_id", "_title", "_extraparams"] ;
_extraparams params ["_minthreat", "_maxthreat", "_cache"] ;

private _active = true ;

// Setup mission --------------------------------------------
private _description = "Capture the weapons cache by approaching the vehicle. The exact location is not known but should be nearby" ;
private _taskid = format["task%1", _id] ;

private _players = call BIS_fnc_listPlayers ;

_filteredlocations = [] ;
if (typeName _minthreat == "ARRAY") then {
  // Input is an array, assume location has been provided instead of threat
  _location = _minthreat ;
  _radius_min = _maxthreat select 0 ;
  _radius_max = _maxthreat select 1 ;
 
  {
    _locationpos = _x select 2;
    _dis = _locationpos distance _location;
    if (_dis >= _radius_min && _dis <= _radius_max) then {
      _filteredlocations pushBack _x ;
    };
  }forEach HunterLocations ;
  
}else{
  // Get a random location within min and max threat
  {
    _sector = _x select 4 ;
    _locationpos = _x select 2;
    _threat = [_sector] call h_getSectorBaseThreat ;
    _awayfromplayers = true ;
    if (_threat >= _minthreat && _threat <= _maxthreat) then {
      {
        if (_x distance _locationpos <= 500) then {
          _awayfromplayers = false ;
        };
      }forEach _players ;
      if (_awayfromplayers) then {
        _filteredlocations pushBack _x ;
      };
    }; 
  }forEach HunterLocations ;
};

// Fallback to all locations
if (count _filteredlocations == 0) then {
  _filteredlocations = HunterLocations ;
};

private _location = _filteredlocations select (floor random count _filteredlocations) ;
_pos = _location select 2 ;

_trypos = _pos getPos [random 50, random 360] ;
private _giveup = 50 ;
while {!(_trypos isFlatEmpty  [-1, -1, -1, -1, 2, false] isEqualTo []) && _giveup > 0} do {
  _trypos = _pos getPos [random 50, random 360] ;
  _giveup = _giveup - 1; 
};
private _veh = createVehicle ["O_Truck_02_covered_F", _trypos, [], 0, "NONE"];
[_veh] call spawn_protection ;
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

[true, _taskid, [_description, _title, format["missioncache%1", _id]], _pos, true, -1, true, "", false] call BIS_fnc_taskCreate ;

// Monitor mission --------------------------------------------
while {_active} do {
  sleep 2 ;
  if (!alive _veh) then {
    // mission failed
    [_taskid, "FAILED"] call BIS_fnc_taskSetState;
    sleep 5 ;
    [_taskid] call BIS_fnc_deleteTask;
    _active = false ;
  };
  
  _players = call BIS_fnc_listPlayers ;
  if (!isMultiplayer && hasInterface) then {
    _players = [player] ;
  };
  {
    if (_x distance _veh < 5) exitWith {
      _active = false ;
      
      // Mission success, advance to next mission
      [_veh] call h_unsetMissionVehicle ;
      [_taskid, "SUCCEEDED"] call BIS_fnc_taskSetState;
      _this set [4, true] ; // Flag completed
    };
  }forEach _players ;  
};

// Mission end --------------------------------------------

