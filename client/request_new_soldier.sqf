params ["_target", "_caller", "_actionId", "_arguments"];
waitUntil {!isNil "dlgRecruit"} ;

private _return = [HUNTER_PURCHASE_SOLDIERS] call dlgRecruit ; 

if (count _return > 0) then {
  private _grp = group _caller;
  private _createclass = _return select 0 ;
  private _cost = _return select 1 ;
  
  _cash = HunterEconomy select 0 ;
  
  if (_cash >= _cost) then {
    _unit = _grp createUnit [_createclass, position _caller, [], 20, "NONE"] ;
    [_unit] call h_manageUnit ;
    
    HunterEconomy set [0, _cash - _cost] ;
    publicVariable "HunterEconomy" ;
  };
};