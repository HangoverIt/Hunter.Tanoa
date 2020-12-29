params["_id", "_title", "_extraparams"] ;
_extraparams params ["_minthreat", "_maxthreat", "_type"] ;

private _active = true ;

// Setup mission --------------------------------------------
private _description = "Assassinate the target" ;
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
_pos = _location select 2 ;

_trypos = _pos getPos [random 25, random 360] ;
private _giveup = 50 ;
// If over water then try another location until giving up
while {!(_trypos isFlatEmpty  [-1, -1, -1, -1, 2, false] isEqualTo []) && _giveup > 0} do {
  _trypos = _pos getPos [random 25, random 360] ;
  _giveup = _giveup - 1; 
};

if (_type == "") then { _type = "O_T_Officer_F";};
_grp = createGroup east ;
private _target = _grp createUnit[_type, _trypos, [], 10, "NONE"] ;
_target addEventHandler["Killed", {_this call kill_manager}];
private _veh = createVehicle ["C_SUV_01_F", _trypos, [], 20, "NONE"];
[_veh] call spawn_protection ;
[_veh] call h_setMissionVehicle ;

[true, _taskid, [_description, _title, format["missonassassin%1", _id]], _pos, true, -1, true, "", false] call BIS_fnc_taskCreate ;

// Check connected roads and go as far away as possible
_escape_loc = [_trypos] call h_max_connected_road ;

// Monitor mission --------------------------------------------

private _targetflee = false ;
private _targetfleeing = false ;
private _escapeinvehicle = objNull ;
while {_active} do {
  sleep 2 ;
  
  if (_targetflee) then {
  
    [_taskid, _target] call BIS_fnc_taskSetDestination ;
    
    if (isNull _escapeinvehicle || !(alive _escapeinvehicle)) then {
      // Escape vehicle not an option, find another
      _targetflee = false ;
      _target enableAI "AUTOTARGET" ;
      _target enableAI "TARGET" ;
    }else{
      if (_target in _escapeinvehicle && !_targetfleeing) then {
        _target enableAI "AUTOTARGET" ;
        _target enableAI "TARGET" ;
        for "_i" from count waypoints _grp - 1 to 0 step -1 do {
          deleteWaypoint [_grp, _i];
        };
        _wp = _grp addWaypoint [_escape_loc, 0];
        _wp setWaypointType "MOVE";
        _grp setCurrentWaypoint [_grp, 0];
        _targetfleeing = true ;
        diag_log format["Assassination - target in vehicle and going to %1", _escape_loc] ;
      };
    }; 
  } ;
  
  _enemy = _target findNearestEnemy _target ;
  if ((!isNull _enemy || ( damage _target > 0.25 )) && !_targetflee) then {
    // Can see enemy or hit. Target to try and flee
    diag_log format ["Assassination - target knows about %1 or injured, fleeing...", _enemy] ;
    _vehicles = nearestObjects[_target, ["Car", "Tank", "Helicopter", "Ship"], 200] ;
    {
      diag_log format ["Assassination - checking vehicle %1 for driver. value = %2", _x, driver _x];
      if (isNull (driver _x)) exitWith {
        _targetflee = true ;
        _target disableAI "AUTOTARGET" ;
        _target disableAI "TARGET" ;
        if (!isNull _enemy) then {_grp forgetTarget _enemy ;};
        _target assignAsDriver _x ;
        [_target] orderGetIn true ;
        _escapeinvehicle = _x ;
      };
    }forEach _vehicles ;
  };
  
  _players = call BIS_fnc_listPlayers ;
  // Check failure condition, has target escaped?
  _outofrange = {_x distance _target < 600} count _players ;
  if (_outofrange == 0 && _targetflee) exitWith {
    // mission failed
    [_taskid, "FAILED"] call BIS_fnc_taskSetState;
    [_veh] call h_unsetMissionVehicle ;
    sleep 5 ;
    [_taskid] call BIS_fnc_deleteTask;
    _active = false ;
  };
  
  
  // Check victory condition
  if (!alive _target) exitWith {
    _active = false ;
    
    // Mission success, advance to next mission
    [_taskid, "SUCCEEDED"] call BIS_fnc_taskSetState;
    [_veh] call h_unsetMissionVehicle ;
    _this set [4, true] ; // Flag completed
  };
 
 
};

// Mission end --------------------------------------------

diag_log format ["Assassination - exiting mission code"] ;