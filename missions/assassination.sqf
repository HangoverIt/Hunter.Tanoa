params["_id", "_description", "_expiry", "_icon", "_extraparams"] ;
_extraparams params ["_minthreat", "_maxthreat", "_type"] ;

// Setup mission --------------------------------------------
private _title = "Assassinate the target" ;

private _location = _extraparams call generate_mission_location ;

if (_type == "") then { _type = "O_T_Officer_F";};
_grp = createGroup east ;
private _target = _grp createUnit[_type, [0,0,0], [], 10, "NONE"] ;
_target addEventHandler["Killed", {_this call kill_manager}];
private _veh = [[0,0,0], "C_SUV_01_F", [], "NONE", false] call h_createVehicle ;

// Move to better locations
_missionpos = [_location, _target] call get_location_nice_position ;
_target setPos _missionpos ;
_vehpos = [_location, _veh] call get_location_nice_position ;
_veh setPos _vehpos ;
[_veh] spawn spawn_protection; 

if (_icon == "") then {_icon = "kill";};
private _huntermission = [_id, _title, _expiry, _missionpos, _description, _icon] call start_mission;

// Check connected roads and go as far away as possible
_escape_loc = [_missionpos] call h_max_connected_road ;

// Monitor mission --------------------------------------------

private _targetflee = false ;
private _targetfleeing = false ;
private _escapeinvehicle = objNull ;
while {([_huntermission] call isMissionActive)} do {
  sleep 2 ;
  
  if (_targetflee) then {
    
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
        [_huntermission, _target] call setMissionLocation ;
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
  // Check failure condition, has target escaped or mission timed out?
  _outofrange = {_x distance _target < 600} count _players ;
  if ((_outofrange == 0 && _targetflee) || ([_huntermission] call hasMissionExpired)) exitWith {
    // mission failed
    [_this, _huntermission, false] call end_mission ;

    [_veh] spawn cleanup_manager ; // remove vehicle when out of view if still managed
    [_grp] spawn cleanup_manager; // clean-up units when out of player range

  };
  
  // Check victory condition
  if (!alive _target) exitWith {
    [_this, _huntermission] call end_mission ;
    
    [_veh] spawn cleanup_manager ; // remove vehicle when out of view if still managed
    [_grp] spawn cleanup_manager; // clean-up units when out of player range
  };
};

// Mission end --------------------------------------------

diag_log format ["Assassination - exiting mission code"] ;