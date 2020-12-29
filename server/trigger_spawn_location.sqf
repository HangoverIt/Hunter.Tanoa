params ["_trg"] ;
private _l = _trg getVariable "Location" ;
if (!isServer) exitWith{} ;

_trg setVariable ["Spawned", false] ;

private _l_type = (_l select 0) ;
private _l_name = (_l select 1) ;
private _l_pos = (_l select 2) ;

// Create a display on the map
if (_l_type == HUNTER_CUSTOM_LOCATION) then {
  // Increase trigger area for despawn
  _trg setTriggerArea [HUNTER_CUSTOM_RADIUS_DESPAWN, HUNTER_CUSTOM_RADIUS_DESPAWN, 0, false];
}else{
  _mkr = createMarker ["trg" + _l_name, _l_pos ];
  _mkr setMarkerShape "ELLIPSE" ;
  _mkr setMarkerSize [HUNTER_LOCATION_RADIUS_DESPAWN, HUNTER_LOCATION_RADIUS_DESPAWN] ;

  // Increase trigger area for despawn
  _trg setTriggerArea [HUNTER_LOCATION_RADIUS_DESPAWN, HUNTER_LOCATION_RADIUS_DESPAWN, 0, false];
};


[_trg] spawn spawn_location ;