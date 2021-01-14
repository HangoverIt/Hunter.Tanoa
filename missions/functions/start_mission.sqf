params["_id", "_title", "_pos", "_description"];

private _taskid = format["task%1", _id] ;
[true, _taskid, [_description, _title, format["huntermission%1", _id]], _pos, true, -1, true, "", false] call BIS_fnc_taskCreate ;

// Handle for mission
[true, _description, _taskid];