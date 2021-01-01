params ["_vehicle", "_role", "_unit", "_turret"];

diag_log format ["%1: Vehicle %2 entered by %3", time, _vehicle, _unit] ;

private _location = _vehicle getVariable "Location" ;
private _managed = [_vehicle] call h_isManagedVehicle;

// Detect if player is taking ownership of a spawned vehicle
if (!isNil "_location" && side _unit == west) then {

  _l_name = (_location select 1) ;
  _l_spawned_veh = (_location select 8) ;

  //diag_log format ["%1: vehicle %2 entered at/for location %3, captured by player %4", time, _vehicle, _l_name, name _unit] ;

  // if the entity has left the server instance and was spawned from the location then
  // remove from list of spawned vehicles
  if (_vehicle in _l_spawned_veh) then {
    diag_log format["Vehicle %1 was spawned from location %2 and has been removed", _vehicle, _l_name] ;
    _location set [8, (_l_spawned_veh - [_vehicle])] ;
    _vehicle setVariable ["Location", nil] ; // disassociate with location
  };

  // Not interested in further changes of ownership
  _vehicle removeAllEventHandlers "GetIn" ;
};

// If unit is a server managed unit then remove from server control
if (!isNil "_managed" && side _unit == west) then {
  [_vehicle] call h_unsetManagedVehicle ;
  _vehicle removeAllEventHandlers "GetIn" ;
};