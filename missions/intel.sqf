params["_id", "_description", "_expiry", "_icon", "_extraparams"] ;
_extraparams params ["_minthreat", "_maxthreat"] ;

// Setup mission --------------------------------------------
private _title = "Find the intel" ;

private _location = _extraparams call generate_mission_location ;

_intel = createVehicle["Intel_File1_F", [0,0,0], [], 0, "CAN_COLLIDE"];
_table = createVehicle["Land_CampingTable_small_F", [0,0,0], [], 0, "CAN_COLLIDE"];
_intelpos = [_location, _table, true] call get_location_nice_position ; // table is the largest object
_table setPos _intelpos ;
_tablebb = boundingBox _table ;
_intel attachTo [_table, [0,0,((_tablebb select 2)/2)+0.1]] ;
_table setVectorUp [0,0,1] ;


removeAllActions _intel;

private _fn_intel = {
  params ["_target", "_caller", "_actionId", "_arguments"];
  _caller switchMove "AmovPercMstpSrasWrflDnon_AinvPknlMstpSlayWrflDnon";
  sleep 1;
  deleteVehicle _target ;
};
_intel addAction ["Fetch Intel", _fn_intel, nil, 1.5, true, true, "", "true", 10, false, "", ""] ;

private _huntermission = [_id, _title, _expiry, _intelpos, _description] call start_mission;

// Monitor mission --------------------------------------------

while {([_huntermission] call isMissionActive)} do {
  sleep 2 ;
 
  // Check victory condition
  if (isNull _intel || ([_huntermission] call hasMissionExpired)) exitWith {
    [_this, _huntermission] call end_mission ;
  };
};

// Mission end --------------------------------------------

diag_log format ["Intel - exiting mission code"] ;