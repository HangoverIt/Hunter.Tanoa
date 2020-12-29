params ["_entity", "_isLocal"];

diag_log format ["%1: Entity %2 changed locality. Is local = %3", time, _entity, _isLocal] ;

private _location = _entity getVariable "Location" ;

if (!isNil "_location" && _isLocal) then {

  _l_name = (_location select 1) ;
  _l_spawned_veh = (_location select 8) ;

  diag_log format ["%1: object %2 changed locality from server", time, _entity] ;

  // if the entity has left the server instance and was spawned from the location then
  // remove from list of spawned vehicles
  if (_entity in _l_spawned_veh) then {
    diag_log format["object %1 was spawned from location %2 and has been removed", _entity, _l_name] ;
    _location set [8, (_l_spawned_veh - [_entity])] ;
    _entity setVariable [nil, "Location"] ; // disassociate with location
  };

  // Not interested in further changes of ownership
  _entity removeAllEventHandlers "Local" ;
};