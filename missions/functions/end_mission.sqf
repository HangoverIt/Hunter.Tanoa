params["_missionthis", "_handle", ["_success", true]];

private _taskid = _handle select 2;
_handle set[0,false] ;

// Mission success, advance to next mission
if (_success) then {
  [_taskid, "SUCCEEDED"] call BIS_fnc_taskSetState;
}else{
  [_taskid, "FAILED"] call BIS_fnc_taskSetState;
};

_missionthis set [4, true] ; // Flag completed
