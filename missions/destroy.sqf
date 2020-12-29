params["_id", "_title", "_extraparams"] ;
_extraparams params ["_minthreat", "_maxthreat", "_type"] ;

private _active = true ;

// Setup mission --------------------------------------------
private _description = "Destroy the target" ;
private _taskid = format["task%1", _id] ;

private _players = call BIS_fnc_listPlayers ;
  
_filteredlocations = [] ;
if (typeName _minthreat == "ARRAY" && typeName _maxthreat == "ARRAY") then {
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
private _pos = _location select 2 ;
private _sector = _location select 4 ;
private _threat = [_sector] call h_getSectorThreat ;

_trypos = _pos getPos [random 50, random 360] ;
private _giveup = 50 ;
// If over water then try another location until giving up
while {!(_trypos isFlatEmpty  [-1, -1, -1, -1, 2, false] isEqualTo []) && _giveup > 0} do {
  _trypos = _pos getPos [random 25, random 360] ;
  _giveup = _giveup - 1; 
};

if (_type == "") then { _type = "Land_ReservoirTank_V1_F";};

private _target = createVehicle [_type, _trypos, [], 0, "NONE"];

// Create defense group
_grp = createGroup east ;
for "_i" from 1 to 6 do {
  _manclass = [HUNTER_THREAT_MAPPING_SOLDIER, _threat] call h_getRandomThreat ;
  _unit = _grp createUnit[_manclass, _trypos, [], 0, "NONE" ] ;
};

[true, _taskid, [_description, _title, format["missondestroy%1", _id]], _pos, true, -1, true, "", false] call BIS_fnc_taskCreate ;

// Monitor mission --------------------------------------------

while {_active} do {
  sleep 2 ;
  
  // Check victory condition
  if (!alive _target) exitWith {
    _active = false ;
    
    // Mission success, advance to next mission
    [_taskid, "SUCCEEDED"] call BIS_fnc_taskSetState;
    _this set [4, true] ; // Flag completed
    
    if ({alive _x} count units _grp > 0) then {
      [_grp] spawn cleanup_manager; // remove defending units 
    };
  };
 
 
};

// Mission end --------------------------------------------

diag_log format ["Destruction - exiting mission code"] ;