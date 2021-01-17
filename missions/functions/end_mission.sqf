params["_missionthis", "_handle", ["_success", true]];

private _taskid = _handle select 2;
private _expirytime = _handle select 4 ;
_handle set[0,false] ;

// If mission has expired then set the success to false
if ([_handle] call hasMissionExpired) then {
  _success = false ;
};

// Mission success, advance to next mission
if (_success) then {
  [_taskid, "SUCCEEDED"] call BIS_fnc_taskSetState;
  _missionthis set [6, true] ; // Flag completed
}else{
  [_taskid, "FAILED"] call BIS_fnc_taskSetState;
  sleep 5 ;
  [_taskid] call BIS_fnc_deleteTask;
};
