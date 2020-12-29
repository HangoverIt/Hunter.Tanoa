params ["_target", "_caller", "_actionId", "_arguments"];

private _grp = group _caller;

_unit = _grp createUnit ["B_Soldier_F", position _caller, [], 20, "NONE"] ;
[_unit] call h_manageUnit ;