params["_id", "_description", "_expiry", "_icon", "_extraparams"] ;
_extraparams params ["_minthreat", "_maxthreat", "_type"] ;

// Setup mission --------------------------------------------
private _title = "Rescue" ;

private _location = _extraparams call generate_mission_location ;

// Create civilian captive
if (_type == "") then { _type = "C_man_polo_1_F";};
_grp = createGroup civilian ;
private _captive = _grp createUnit[_type, [0,0,0], [], 10, "NONE"] ;
_missionpos = [_location, _captive, true] call get_location_nice_position ;
_captive setPos _missionpos ;

_captive disableAI "ANIM";
_captive disableAI "MOVE";
_captive playmove "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon" ;
_captive setVariable ["Freed", false] ;

// Create guards
_grpguard = createGroup east ;
private _size = floor(random 5) + 2 ;
for "_i" from 1 to _size do {
  _unit = [_grpguard, _missionpos, HUNTER_THREAT_MAPPING_SOLDIER, _location] call h_createUnit ;
};

private _fn_free_man = {
  params ["_target", "_caller", "_actionId", "_arguments"];
  _target enableAI "ANIM";
  _target enableAI "MOVE";
  _target doMove [0,0,0]; // run somewhere
  _target setVariable ["Freed", true, true] ;
  removeAllActions _target ;
  [(group _target)] spawn cleanup_manager;
};

[_captive,["Set free", _fn_free_man, nil, 1.5, true, true, "", "true", 10, false, "", ""]] remoteExec ["addAction"]; ;

if (_icon == "") then {_icon = "help";};
private _huntermission = [_id, _title, _expiry, _missionpos, _description, _icon] call start_mission;

// Monitor mission --------------------------------------------

while {([_huntermission] call isMissionActive)} do {
  sleep 2 ;
 
  // Check victory condition
  if (!alive _captive || ([_huntermission] call hasMissionExpired)) exitWith {
    // Failed, captive is free to be deleted from game
    if (alive _captive) then {
      [_captive] call _fn_free_man; // let them go anyway
    };
    [_this, _huntermission, false] call end_mission ;
    [_grpguard] spawn cleanup_manager; // remove defending units 
  };
  if (alive _captive && (_captive getVariable "Freed")) exitWith {
    [_this, _huntermission] call end_mission ; // Captive rescued
    [_grpguard] spawn cleanup_manager; // remove defending units 
  };
};

// Mission end --------------------------------------------

diag_log format ["Rescue - exiting mission code"] ;