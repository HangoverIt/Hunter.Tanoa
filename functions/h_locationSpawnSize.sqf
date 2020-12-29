// Provide a location array
// Returns array of original size and actual based on percent remaining
params["_location"] ;

private _l_type = (_location select 0) ;
private _l_percent = (_location select 5) ;

// Set the spawn size for location. Use a default of 20 for unknown classes
private _squad_size = 20 ;
{
  if ((_x select 0) == _l_type) exitWith{_squad_size = (_x select 1);} ;
} forEach HUNTER_SPAWN_LOCATIONS ;


private _actual_squad_size = ceil (_squad_size * (_l_percent/100)) ;

[_squad_size, _actual_squad_size];