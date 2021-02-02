params ["_target", "_caller", "_actionId", "_arguments"];
waitUntil {!isNil "dlgRecruit"} ;

private _createclass = [HUNTER_PURCHASE_SOLDIERS] call dlgRecruit ; 

if (count _createclass > 0) then {
  private _grp = group _caller;

  _unit = _grp createUnit [_createclass, position _caller, [], 20, "NONE"] ;
  [_unit] call h_manageUnit ;
  
};