//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Assigns a vehicle or unit to a location. This sets the appropriate variables to register to that location
// can also be used to change a location or remove location if set to []
// Sets any man class object to also have a kill handler and removes any old handlers
// Usage: [object, location]
// Return: previous location
//
// Input: object - unit or vehicle
//        location - (optional) location array or empty [] array to remove location
//
params["_o", ["_loc", []]] ;

private _oldloc = [] ;
private _var = _o getVariable "Location" ;
if (!isNil "_var") then {
  _oldloc = _var ;
};

if (_o isKindOf "Man") then {
  // Always set the kill handler
  _o removeAllEventHandlers "Killed" ; // remove old handlers
  _o addEventHandler["Killed", {_this call kill_manager}];
};

// 
if (count _loc > 0) then {
  _o setVariable["Location", _loc] ;
  if (_o isKindOf "Man") then {
    _location_spawn_size = [_loc] call h_locationSpawnSize ;
    _squad_size = _location_spawn_size select 0 ;
    _o setVariable["Percent", (100/_squad_size)] ;
  } ;
}else{ // remove location
  _o setVariable ["Location", nil] ;
  if (_o isKindOf "Man") then {
    _o setVariable ["Percent", nil] ;
  };
};

_oldloc;