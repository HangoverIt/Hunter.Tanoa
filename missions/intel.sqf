params["_id", "_title", "_extraparams"] ;
_extraparams params ["_minthreat", "_maxthreat"] ;

private _active = true ;

// Setup mission --------------------------------------------
private _description = "Find the intel" ;

private _location = _extraparams call generate_mission_location ;

_intel = createVehicle["Intel_File1_F", [0,0,0], [], 0, "NONE"];
_intelpos = [_location, _intel, true] call get_location_nice_position ;
_intel setPos _intelpos ;

private _intelfound = false ;
private _fn_intel = {
  params ["_target", "_caller", "_actionId", "_arguments"];
  _caller switchMove "AmovPercMstpSrasWrflDnon_AinvPknlMstpSlayWrflDnon";
  sleep 1;
  deleteVehicle _target ;
  _intelfound = true;
};
_intel addAction ["Fetch Intel", _fn_intel, nil, 1.5, false, false, "", "true", 10, false, "", ""] ;

private _huntermission = [_id, _title, _intelpos, _description] call start_mission;

// Monitor mission --------------------------------------------

while {([_huntermission] call isMissionActive)} do {
  sleep 2 ;
 
  // Check victory condition
  if (_intelfound) exitWith {
    [_this, _huntermission] call end_mission ;
  };
};

// Mission end --------------------------------------------

diag_log format ["Intel - exiting mission code"] ;