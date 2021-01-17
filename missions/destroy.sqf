params["_id", "_description", "_expiry", "_icon", "_extraparams"] ;
_extraparams params ["_minthreat", "_maxthreat", "_type"] ;

// Setup mission --------------------------------------------
private _title = "Destroy the target" ;

private _location = _extraparams call generate_mission_location ;

if (_type == "") then { _type = "Land_ReservoirTank_V1_F";};

private _target = createVehicle [_type, [0,0,0], [], 0, "NONE"];
_missionpos = [_location, _target] call get_location_nice_position ;
_target setPos _missionpos;

private _sector = _location select 4;
private _threat = [_sector] call h_getSectorThreat ;

// Create defense group
_grp = createGroup east ;
for "_i" from 1 to 6 do {
  _manclass = [HUNTER_THREAT_MAPPING_SOLDIER, _threat] call h_getRandomThreat ;
  _unit = _grp createUnit[_manclass, _missionpos, [], 0, "NONE" ] ;
};

private _huntermission = [_id, _title, _expiry, _missionpos, _description] call start_mission;

// Monitor mission --------------------------------------------

while {([_huntermission] call isMissionActive)} do {
  sleep 2 ;
  
  // Check victory condition
  if (!alive _target || ([_huntermission] call hasMissionExpired)) exitWith {
    // Mission success, advance to next mission
    [_this, _huntermission] call end_mission ;
    
    if ({alive _x} count units _grp > 0) then {
      [_grp] spawn cleanup_manager; // remove defending units 
    };
  };
};

// Mission end --------------------------------------------

diag_log format ["Destruction - exiting mission code"] ;