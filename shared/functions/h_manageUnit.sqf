params ["_unit"] ;

_fn_join = {
  params ["_target", "_caller", "_actionId", "_arguments"];
  [_target] join (group _caller) ;
};

_fn_leave = {
  params ["_target", "_caller", "_actionId", "_arguments"];
  _grp = grpNull ;
  if (!isNil "HunterBlueForGrp") then {
    _grp = HunterBlueForGrp ;
  } ;
  [_target] join _grp ;
};

// Execute action on all clients
[_unit, ["Join", _fn_join, nil, 1, false, true, "", "true", 3, false, "",""]] remoteExec["addAction"] ;
[_unit, ["Leave", _fn_leave, nil, 1, false, true, "", "true", 3, false, "",""]] remoteExec["addAction"] ;